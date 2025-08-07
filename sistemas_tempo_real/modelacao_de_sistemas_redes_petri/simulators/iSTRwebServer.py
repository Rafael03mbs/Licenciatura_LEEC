from http.server import BaseHTTPRequestHandler, HTTPServer
from urllib.parse import urlparse, parse_qs  # Importing urlparse and parse_qs
import os
import json
import gzip
import importlib
import inspect

import re

import sys
# sys.path.append("simulators")

# import GPIOsim as GPIO

petrinetModule = None

GPIO = None

function_cache = {}

def find_function(function_name):
    """
    Find a function with the given name in all modules.
    """
    # Check if the function is already cached
    if function_name in function_cache:
        return function_cache[function_name]
    
    # Iterate over all modules
    for module_name, module in sys.modules.items():
        # Check if the module has the function
        if hasattr(module, function_name):
            function = getattr(module, function_name)
            # Check if the attribute is a function
            if inspect.isfunction(function):
                # Cache the function and return it
                function_cache[function_name] = function
                return function
    
    # If function not found, return None
    return None

def matches(transitionName, regex):
    return bool(re.match(regex, transitionName))


class MyServer(BaseHTTPRequestHandler):

    def log_message(self, format, *args):
        # Suppress logging of HTTP request messages
        pass

    def do_GET(self):   
        # print("received request: " + str(self.path))
        global petrinetModule

        parsed_url = urlparse(self.path)
        query_params = parse_qs(parsed_url.query)

        if parsed_url.path == '/isTransitionTrue':        
            if 'transition' in query_params:
                transition_name = query_params['transition'][0]  # Get the first value if there are multiple
                tokensCount = int(query_params['tokensCount'][0])
               
                result = False
               
                """if hasattr(petrinetModule, transition_name):
                    result = getattr(petrinetModule, transition_name)(tokensCount)
                else:
                    result = True
                """    
                function_name = transition_name
                function = find_function(function_name)
                if function:
                    result = function(tokensCount)  # Call the function    
                    
                # print( "" + transition_name + " replied with: " + str(result) )
                self.send_response(200)
                self.send_header('Content-type', 'text/plain')  # Set content type to plain text
                self.end_headers()
                self.wfile.write(str(result).encode('utf-8'))    
        elif parsed_url.path == '/getTransitionValues':
            if 'transitions' in query_params:
                transitions_json = query_params['transitions'][0]  # Get the first value if there are multiple
                transitions = json.loads(transitions_json)
                # print("transitions: "+ str(transitions))
                response = []
                for transition in transitions:
                    transition_name = transition['name']
                    tokens_count = int(transition['tokensCount'])
                    
                    # HERE
                    result = True
                    
                    function = find_function(transition_name)
                    if function:
                        result = function(tokens_count)  # Call the function
                    else:
                        transitionRegularExpression = r"^T\d+$"
                        if  matches(transition_name, transitionRegularExpression):
                            # print(transition_name)
                            None
                        else:
                            print(f"transition {transition_name} is missing in your Python module...")
                                            
                    # HERE
                    try:
                        response.append({"name": transition_name, "value": str(int(result))})
                    except Exception as e:
                        print(f"Error in transition {transition_name}: ",e)

                self.send_response(200)
                self.send_header('Content-type', 'application/json')  # Set content type to JSON
                self.end_headers()
                self.wfile.write(json.dumps(response).encode('utf-8'))                
        elif  parsed_url.path == '/executeActionsOnPlace':
            if 'place' in query_params:
                place_name      = query_params['place'][0]  # Get the first value if there are multiple
                tokensBefore    = int(query_params['tokensBefore'][0])
                tokensNow       = int(query_params['tokensNow'][0])
                tokensCount     = int(query_params['tokensCount'][0])
                
                """if hasattr(petrinetModule, place_name):
                    getattr(petrinetModule, place_name)(tokensBefore, tokensNow, tokensCount)                
                """
                function_name = place_name
                function = find_function(function_name)
                if function:
                    function(tokensBefore, tokensNow, tokensCount)  # Call the function 
                else:
                    placeRegularExpression = r"^P\d+$"
                    if  matches(function_name, placeRegularExpression):
                        # print(transition_name)
                        None
                    else:
                        print(f"place {function_name} is missing in your Python module...")
                    
                self.send_response(200)
                self.send_header('Content-type', 'text/plain')  # Set content type to plain text
                self.end_headers()
                self.wfile.write("OK".encode('utf-8'))                            
        elif self.path == '/getBitValues':
            # Send the response with pinValues array
            response_data = json.dumps(GPIO.gpioValuesNow)  # Convert pinValues array to JSON string
            self.send_response(200)
            self.send_header('Content-type', 'application/json')  # Set content type to JSON
            self.end_headers()
            self.wfile.write(response_data.encode('utf-8'))  # Write the response data
        else:
            # Serve static files from the 'static' directory
            # filename = self.path[1:]  # Remove the leading slash
            filename = os.path.join("simulators", self.path[1:])
            if os.path.exists(filename) and os.path.isfile(filename):
                # with open(filename, 'rb') as file:
                #    content = file.read()
                self.send_response(200)
                if filename.endswith('.html'):
                    self.send_header('Content-type', 'text/html')
                elif filename.endswith('.js'):
                    self.send_header('Content-type', 'application/javascript')
                elif filename.endswith('.css'):
                    self.send_header('Content-type', 'text/css')
                elif filename.endswith('.wasm'):
                    self.send_header('Content-type', 'application/wasm')
                elif filename.endswith('.gz'):
                    self.send_header('Content-type', 'application/wasm')
                    self.send_header('Content-Encoding', 'gzip')    
                else:
                    self.send_header('Content-type', 'text/plain')
                # self.send_header('Transfer-Encoding', 'chunked')
                self.end_headers()
                # Stream the file in chunks
                chunk_size = 4096
                with open(filename, 'rb') as file:                    
                    while True:                                     
                        chunk = file.read(chunk_size)
                        if not chunk:
                            break                        
                        self.wfile.write(chunk)                
            else:
                self.send_response(404)
                self.send_header('Content-type', 'text/plain')
                self.end_headers()
                self.wfile.write(bytes("Not found", "utf-8"))
    
    def do_POST(self):
        if self.path == '/newPinFromSimulator':
            # Get the length of the request body
            content_length = int(self.headers['Content-Length'])
            # Read the request body
            post_data = self.rfile.read(content_length)
            # Parse the JSON data
            json_data = json.loads(post_data)
            GPIO_ID = json_data.get('GPIO_ID')
            Value = json_data.get('Value')

            # Handle the GPIO ID and value as needed
            # For example, update the moveRightVariable
            GPIO.unsafe_output(GPIO_ID, Value)

            # Send the response with pinValues array
            response_data = json.dumps(GPIO.gpioValuesNow)  # Convert pinValues array to JSON string
            self.send_response(200)
            self.send_header('Content-type', 'application/json')  # Set content type to JSON
            self.end_headers()
            self.wfile.write(response_data.encode('utf-8'))  # Write the response data
        else:
            self.send_error(501, "Unsupported method ('POST')")


def run_server(address, port, GPIO_board, inputPetriNetModule=''):

    global petrinetModule
    global GPIO

    GPIO = GPIO_board 

    if(inputPetriNetModule !=''):
        petrinetModule = importlib.import_module(inputPetriNetModule) 

    server_address = (address, port)
    httpd = HTTPServer(server_address, MyServer)
    print('Starting server on port 8089...')
    httpd.serve_forever()






