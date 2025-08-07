import threading
import os
import time

import sys
sys.path.append("simulators")
import simulators.keyboard as keybord
import simulators.GPIOsim as GPIO
import simulators.iSTRwebServer as webServer

conveyorMode = "manual"
keyboardKey = ''
timetout= 0

def control_the_conveyor():
    print("q:left,   e:right,   w:stop,   a:automatic, m:manual, f:exit")
    operation_mode = "manual"
    while True:
        time.sleep(0.01)
        key = keyboard_imput()
        if key == "a":
            operation_mode = "automatic"
            print(operation_mode)
            moveRight()
        if key == "m":
            operation_mode = "manual"
            print(operation_mode)
            stopConveyor()
        elif key == 'f':
                os._exit(0)
        if(operation_mode == "automatic"):
            if isAtLeft():
                #print("Moving Right")
                moveRight()
            if isAtRight():
                #print("Moving Left")
                moveLeft()
        if(operation_mode == "manual"):
            if key == "q":
                #print("Moving Left")
                moveLeft()
            if key == "e":
                #print("Moving Right")
                moveRight()
            if key == "w":
                #print("Stop")
                stopConveyor()
def moveRight():
    GPIO.output(2, GPIO.LOW)
    GPIO.output(3, GPIO.HIGH)

def moveLeft():
    GPIO.output(2, GPIO.HIGH)
    GPIO.output(3, GPIO.LOW)

def stopConveyor():
    GPIO.output(2, GPIO.LOW)
    GPIO.output(3, GPIO.LOW)

def isAtLeft():
    return GPIO.input(4) == GPIO.HIGH

def isAtRight():
    return GPIO.input(5) == GPIO.HIGH

def readKeyboard(tokensBefore=0,tokensNow=0, tokensCount=0):
    global keyboardKey
    k = keyboard_imput()
    if k != '':
        keyboardKey = k
def isManualkey(tokensCount=0):
    global keyboardKey
    return keyboardKey == 'm'
def isAutomaticKey(tokensCount=0):
    global keyboardKey
    return keyboardKey == 'a'
def setToManual(tokensBefore=0,tokensNow=0, tokensCount=0):
    global conveyorMode
    conveyorMode = 'manual'
def setToAutomatic(tokensBefore=0,tokensNow=0, tokensCount=0):
    global conveyorMode
    conveyorMode = 'automatic'
def flushKeyboardMode(tokensBefore=0,tokensNow=0, tokensCount=0):
    global keyboardKey
    if(keyboardKey in ['a','m']):
        keyboardKey = ''
        
def keyboard_imput():
    global timetout
    timetout = time.time()
    try:
        if keybord.is_key_pressed():
            key = keybord.getChar()
            return key
    except Exception as e:
        print(f"An error ocurred: {e}")
        os._exit(0)
    return ''
def idle_keyboard():
    global timetout
    while True:
        time.sleep(0.1)
        if(time.time()-timetout > 1.0):
            key = keyboard_imput()
            if key == 'f':
                os._exit(0)

if __name__ == "__main__":
    server_thread = threading.Thread(target = webServer.run_server, args=('localhost' , 8089, GPIO))
    server_thread.start()

    GPIO.setup(2, GPIO.OUTPUT, GPIO.LOW)
    GPIO.setup(3, GPIO.OUTPUT, GPIO.LOW)
    GPIO.setup(4, GPIO.INPUT)
    GPIO.setup(5, GPIO.INPUT)

    input_thread = threading.Thread(target = control_the_conveyor)
    input_thread.start()

