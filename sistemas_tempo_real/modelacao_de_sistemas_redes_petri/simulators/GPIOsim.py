import threading
import time
import json
import os
import inspect

# GPIOsim.py
# GPIO simulation of the API available in: 
# https://pythonhosted.org/RPIO/rpio_py.html#ref-rpio-py-additions


IN = 0
OUT = 1

LOW = 0
HIGH = 1

INPUT = 0

OUTPUT = 1


MODE_BOARD = "BOARD"
MODE_BCW = "BCW"


PUD_OFF     = 0
PUD_UP      = 1
PUD_DOWN    = 2

gpioValuesNow = [
                 LOW, LOW, LOW, LOW, LOW,LOW, LOW, LOW, LOW, LOW,
                 LOW, LOW, LOW, LOW, LOW,LOW, LOW, LOW, LOW, LOW,
                 LOW, LOW, LOW, LOW, LOW,LOW, LOW, LOW, LOW, LOW,
                 LOW, LOW, LOW, LOW, LOW,LOW, LOW, LOW, LOW, HIGH, # pin 39 (out of the raspberry range, to tell the simulator in running)
                 ]

gpioValuesBefore = [
                 LOW, LOW, LOW, LOW, LOW,LOW, LOW, LOW, LOW, LOW,
                 LOW, LOW, LOW, LOW, LOW,LOW, LOW, LOW, LOW, LOW,
                 LOW, LOW, LOW, LOW, LOW,LOW, LOW, LOW, LOW, LOW,
                 LOW, LOW, LOW, LOW, LOW,LOW, LOW, LOW, LOW, HIGH,  # pin 39 (out of the raspberry range, to tell the simulator in running)
                 ]

interruptsTable = [None, None, None, None,None,None,None,None,None,None,
                   None, None, None, None,None,None,None,None,None,None,
                   None, None, None, None,None,None,None,None,None,None,
                   None, None, None, None,None,None,None,None,None,None
                   ]

gpioModes =  [     None, None, None, None,None,None,None,None,None,None,
                   None, None, None, None,None,None,None,None,None,None,
                   None, None, None, None,None,None,None,None,None,None,
                   None, None, None, None,None,None,None,None,None,INPUT # pin 39 (out of the raspberry range, to tell the simulator in running)
                   ]


class GPIOException(Exception):
    def __init__(self, message="GPIOException"):
        self.message = message
        super().__init__(self.message)


def input(gpio_id):
    return gpioValuesNow[gpio_id]

    
def inputBefore(gpio_id):
    return gpioValuesBefore[gpio_id]


def unsafe_output(gpio_id, value):        
    gpioValuesBefore[gpio_id] = input(gpio_id)
    gpioValuesNow[gpio_id] = int(value)
    handle_interrupts()

    
def output(gpio_id, value):
    if gpioModes[gpio_id]["direction"] == INPUT:            
        message = f"FATAL: you trying to output into  gpio {gpio_id}, which was setup as INPUT \n"
        caller_info_strings = []
        for frame_info in inspect.stack()[1:]:
            caller_frame = frame_info.frame
            caller_filename = caller_frame.f_code.co_filename
            caller_line_number = caller_frame.f_lineno
            caller_info_strings.append(f"({caller_filename}, {caller_line_number})")
        message += ',\n'.join(caller_info_strings)
        print(message)
        os._exit(0)        
    unsafe_output(gpio_id, value)

    
"""RPi.GPIO.setup(channel, direction, initial=None): Sets up a GPIO pin for input or output.

    channel: The GPIO pin number.
    direction: Specifies the pin direction. Can be GPIO.IN for input or GPIO.OUT for output.
    initial: Optional. Specifies the initial value of the pin when configured as an output. Can be GPIO.LOW or GPIO.HIGH"""
def setup(gpio_id, direction, initial=None):
    gpioModes[gpio_id] = {}
    gpioModes[gpio_id]["direction"] = direction  
    if initial != None:
        output(gpio_id, initial)        


"""RPi.GPIO.setmode(mode): Sets the numbering mode for the GPIO pins.
    mode: Specifies the numbering mode. Can be GPIO.BOARD or GPIO.BCM."""
def setmode(mode):
    under_development = True
  


def getPinValuesToJson():
    json_string = json.dumps(gpioValuesNow)
    return json_string
       
    
def handle_interrupts():
    for gpio_id, interruptEntry in enumerate(interruptsTable):
        if interruptEntry == None:
            continue
        # print(gpio_id)
        # os._exit(0)
        callback = interruptEntry['callback']
        edge = interruptEntry['edge']
        pull_up_down = interruptEntry['pull_up_down']
        threaded_callback = interruptEntry['threaded_callback']
        debounce_timeout_ms = interruptEntry['debounce_timeout_ms']

        call_the_callback = False
        if input(gpio_id) != inputBefore(gpio_id):
            if debounce_timeout_ms != None:            
                if "debounce_timeout_start" in interruptEntry:                    
                    time_elapsed = time.time() - interruptEntry["debounce_timeout_start"]
                    if(time_elapsed <  debounce_timeout_ms):
                        continue # it is less than the debounce timout, so ignore this one and proceed to the next gpio_id
                    else:
                        interruptsTable[gpio_id].pop("debounce_timeout_start", None)


            gpioValuesBefore[gpio_id] = input(gpio_id)
            gpio_value = input(gpio_id)

            if edge == 'both':
                call_the_callback = True
            elif (edge == 'rising' and gpio_value!=0 ):
                call_the_callback = True
            elif (edge == 'falling' and gpio_value==0 ):
                call_the_callback = True
            
             # Check if pull-up or pull-down is configured
            if pull_up_down == PUD_UP:
                # If pull-up is configured, callback is only called on falling edges (input goes from high to low)
                call_the_callback = call_the_callback and edge == 'falling'
            elif pull_up_down == PUD_DOWN:
                # If pull-down is configured, callback is only called on rising edges (input goes from low to high)
                call_the_callback = call_the_callback and edge == 'rising'
            
            if call_the_callback:
                if(threaded_callback):                
                    thread = threading.Thread(target = callback, args=(gpio_id, input(gpio_id)))
                    thread.start()
                else:
                    callback(gpio_id, input(gpio_id))


    

def interrupt_pool(threaded, epoll_timeout):
    print("interrupt_pool_thread()")     
    if threaded:
        while True:
            # Perform interrupt handling logic here
            handle_interrupts()
            time.sleep(0.001)  
    else:
        start_time = time.time()
        while True:
            # Perform interrupt handling logic here
            handle_interrupts()
            time.sleep(0.001)            
            elapsed_time = time.time() - start_time
            if elapsed_time >= epoll_timeout:
                break  



# This is the main blocking loop which, while active, will listen for interrupts and start your custom callbacks. 
# At some point in your script you need to start this to receive interrupt callbacks. 
# This blocking method is perfectly suited as “the endless loop that keeps your script running”.
# With the argument threaded=True, this method starts in the background while your script continues in the main thread (RPIO will automatically shut down the thread when your script exits):
# https://pythonhosted.org/RPIO/rpio_py.html#ref-rpio-py-additions
def wait_for_interrupts(threaded=False, epoll_timeout=1):
    print("wating for interrupts")
    if(threaded):
        thread= threading.Thread(target = interrupt_pool, args=(threaded, epoll_timeout))
        thread.start()
    else:
        interrupt_pool(threaded, epoll_timeout)
        


#interrupts
def add_interrupt_callback(gpio_id, callback, edge='both', pull_up_down=PUD_OFF, threaded_callback=False, debounce_timeout_ms=None):
    interruptsTable[gpio_id] = {}
    interruptsTable[gpio_id]['callback']            = callback
    interruptsTable[gpio_id]['edge']                = edge
    interruptsTable[gpio_id]['pull_up_down']        = pull_up_down
    interruptsTable[gpio_id]['threaded_callback']   = threaded_callback
    interruptsTable[gpio_id]['debounce_timeout_ms'] = debounce_timeout_ms


