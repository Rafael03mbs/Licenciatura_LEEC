import threading
import os
import time
from collections import deque
from threading import Lock

import sys
sys.path.append("simulators")
import simulators.keyboard as keybord
import simulators.GPIOsim as GPIO
import simulators.iSTRwebServer as webServer
import time


# Buffer para frutas detectadas na Dock1
fruit_queue = deque()
fruit_queue2 = deque()
queue_lock = Lock()
counter_lock = Lock()

# Estados globais
is_cylinder_busy = threading.Event() 

import time
import threading

fruit_added = False

# Eventos globais
pause_event = threading.Event()  
pause_event.set()  
stop_event = threading.Event() 


apple_count = 0
pear_count = 0
lemon_count = 0

apple_full_boxes = 0
pear_full_boxes = 0
lemon_full_boxes = 0


MAX_FRUITS_PER_BOX = 5

def monitor_fruits():
    """Monitora as frutas no Dock1 e adiciona à fila."""
    global fruit_added

    while True: 
        pause_event.wait()  
        if isCylinderStart_Resting():
            if not fruit_added:
                if isAtApple_atDock1():
                    fruit_queue.append("maçã")
                    fruit_queue2.append("maçã")
                    print("Maçã detectada e adicionada à fila:", fruit_queue)
                    fruit_added = True
                elif isAtPear_atDock1():
                    fruit_queue.append("pera")
                    fruit_queue2.append("pera")
                    print("Pera detectada e adicionada à fila:", fruit_queue)
                    fruit_added = True
                elif isAtLemon_atDock1():
                    fruit_queue.append("limão")
                    fruit_queue2.append("limão")
                    print("Limão detectado e adicionado à fila:", fruit_queue)
                    fruit_added = True
        time.sleep(0.6)
        if not isCylinderStart_Resting():
            fruit_added = False

def process_fruits_in_queue():
    """Processa frutas da fila usando o Cilindro Start."""
    while True:
        pause_event.wait()  
        if fruit_queue2:
            fruit_type = fruit_queue2.popleft()
            print(f"Processando {fruit_type}.")
            is_cylinder_busy.set()
            while not isCylinderStart_Resting():
                time.sleep(0.1)
            CylinderStart_MoveForward()
            time.sleep(2)
            while not isCylinderStart_Working():
                time.sleep(0.1)
            CylinderStart_MoveBackwards()
            while not isCylinderStart_Resting():
                time.sleep(0.1)
            print(f"{fruit_type} processada. Cilindro pronto.")
            is_cylinder_busy.clear()
        time.sleep(0.1)


def control_the_conveyor():
    """Controla o transportador."""
    print("e: emergency stop/resume, f: exit, s: show statistics")

    while True:
        
        if stop_event.is_set():
            Conveyor_Stop()
            break

       
        key = keyboard_imput()

        if key == "f":
            stop_event.set() 
            Conveyor_Stop()  
            quit()  

        elif key == "e":
           
            if pause_event.is_set():
                print("Emergency Stop activated")
                Conveyor_Stop()
                pause_event.clear()
            else:
                print("Resuming operation")
                Conveyor_Move()
                pause_event.set()

        elif key == "s":    
            print("\n============ Estatísticas =============")
            print(f"Maçãs processadas: {apple_count} (Caixas cheias: {apple_full_boxes})")
            print(f"Peras processadas: {pear_count} (Caixas cheias: {pear_full_boxes})")
            print(f"Limões processados: {lemon_count} (Caixas cheias: {lemon_full_boxes})")
            print("=========================================\n")


        if pause_event.is_set():  
            with queue_lock:
                if fruit_queue:
                    current_fruit = fruit_queue[0]
                    if current_fruit == "maçã" and isFruit_atDock2():
                        print("Movendo maçã para Dock2.")
                        Conveyor_Stop()
                        move_cylinder(1)
                        fruit_queue.popleft()
                        Conveyor_Move()
                        increment_counter("maçã")
                    elif current_fruit == "pera" and isFruit_atDock3():
                        print("Movendo pera para Dock3.")
                        Conveyor_Stop()
                        move_cylinder(2)
                        fruit_queue.popleft()
                        Conveyor_Move()
                        increment_counter("pera")
                    elif current_fruit == "limão" and isFruit_atEnd():
                        print("Movendo limão para o fim.")
                        Conveyor_Stop()
                        fruit_queue.popleft()
                        Conveyor_Move()
                        increment_counter("limão")
                else:
                    Conveyor_Move() 

        time.sleep(0.1)  

def increment_counter(fruit_type):
    global apple_count, pear_count, lemon_count
    global apple_full_boxes, pear_full_boxes, lemon_full_boxes
    with counter_lock:
        if fruit_type == "maçã":
            apple_count += 1
            if apple_count >= MAX_FRUITS_PER_BOX:
                empty_box("maçã")
                apple_full_boxes += 1
                apple_count = 0

        elif fruit_type == "pera":
            pear_count += 1
            if pear_count >= MAX_FRUITS_PER_BOX:
                empty_box("pera")
                pear_full_boxes += 1
                pear_count = 0

        elif fruit_type == "limão":
            lemon_count += 1
            if lemon_count >= MAX_FRUITS_PER_BOX:
                empty_box("limão")
                lemon_full_boxes += 1
                lemon_count = 0


def empty_box(fruit_type):
    """Esvazia a caixa de frutas usando os pinos correspondentes."""
    if fruit_type == "maçã":
        print("Esvaziando a caixa de maçãs...")
        ResetBox_apple()
    elif fruit_type == "pera":
        print("Esvaziando a caixa de peras...")
        ResetBox_pear()
    elif fruit_type == "limão":
        print("Esvaziando a caixa de limões...")
        ResetBox_Lemon()

    print(f"Caixa de {fruit_type} esvaziada.")

def move_cylinder(cylinder_number):
    """Movimenta o cilindro específico."""
    if cylinder_number == 1:
        while not isCylinder1_Resting():
            time.sleep(0.1)
        Cylinder1_MoveForward()
        while not isCylinder1_Working():
            time.sleep(0.1)
        Cylinder1_MoveBackwards()
        while not isCylinder1_Resting():
            time.sleep(0.1)
    elif cylinder_number == 2:
        while not isCylinder2_Resting():
            time.sleep(0.1)
        Cylinder2_MoveForward()
        while not isCylinder2_Working():
            time.sleep(0.1)
        Cylinder2_MoveBackwards()
        while not isCylinder2_Resting():
            time.sleep(0.1)

# Funções auxiliares e simulações de hardware
def Spawn_Apple():
    GPIO.output(20, GPIO.HIGH)

def Spawn_Pear():
    GPIO.output(21, GPIO.HIGH)

def Spawn_Lemon():
    GPIO.output(22, GPIO.HIGH)

def Conveyor_Move():
    GPIO.output(19, GPIO.HIGH)

def Conveyor_Stop():
    GPIO.output(19, GPIO.LOW)

def CylinderStart_MoveForward():
    GPIO.output(13, GPIO.HIGH)
    GPIO.output(14, GPIO.LOW)

def CylinderStart_MoveBackwards():
    GPIO.output(13, GPIO.LOW)
    GPIO.output(14, GPIO.HIGH)

def Cylinder1_MoveForward():
    GPIO.output(15, GPIO.HIGH)
    GPIO.output(16, GPIO.LOW)

def Cylinder1_MoveBackwards():
    GPIO.output(15, GPIO.LOW)
    GPIO.output(16, GPIO.HIGH)

def Cylinder2_MoveForward():
    GPIO.output(17, GPIO.HIGH)
    GPIO.output(18, GPIO.LOW)

def Cylinder2_MoveBackwards():
    GPIO.output(17, GPIO.LOW)
    GPIO.output(18, GPIO.HIGH)

def ResetBox_apple():
    GPIO.output(23, GPIO.HIGH)
    time.sleep(1)
    GPIO.output(23, GPIO.LOW)

def ResetBox_pear():
    GPIO.output(24, GPIO.HIGH)
    time.sleep(1)
    GPIO.output(24, GPIO.LOW)

def ResetBox_Lemon():
    GPIO.output(25, GPIO.HIGH)
    time.sleep(1)
    GPIO.output(25, GPIO.LOW)

def isCylinderStart_Working():
    return GPIO.input(1) == GPIO.HIGH

def isCylinderStart_Resting():
    return GPIO.input(2) == GPIO.HIGH

def isAtApple_atDock1():
    return GPIO.input(3) == GPIO.HIGH

def isAtPear_atDock1():
    return GPIO.input(4) == GPIO.HIGH

def isAtLemon_atDock1():
    return GPIO.input(5) == GPIO.HIGH

def isCylinder1_Working():
    return GPIO.input(6) == GPIO.HIGH

def isCylinder1_Resting():
    return GPIO.input(7) == GPIO.HIGH

def isFruit_atDock2():
    return GPIO.input(8) == GPIO.HIGH

def isCylinder2_Working():
    return GPIO.input(9) == GPIO.HIGH

def isCylinder2_Resting():
    return GPIO.input(10) == GPIO.HIGH

def isFruit_atDock3():
    return GPIO.input(11) == GPIO.HIGH

def isFruit_atEnd():
    return GPIO.input(12) == GPIO.HIGH

def keyboard_imput():
    global timetout
    timetout = time.time()
    try:
        if keybord.is_key_pressed():
            key = keybord.getChar()
            return key
    except Exception as e:
        print(f"An error occurred: {e}")
        os._exit(0)
    return ''

# Main thread
if __name__ == "__main__":
    try:
        server_thread = threading.Thread(target=webServer.run_server, args=("localhost", 8089, GPIO))
        server_thread.start()

        GPIO.setup(1, GPIO.INPUT)
        GPIO.setup(2, GPIO.INPUT)
        GPIO.setup(3, GPIO.INPUT)
        GPIO.setup(4, GPIO.INPUT)
        GPIO.setup(5, GPIO.INPUT)
        GPIO.setup(6, GPIO.INPUT)
        GPIO.setup(7, GPIO.INPUT)
        GPIO.setup(8, GPIO.INPUT)
        GPIO.setup(9, GPIO.INPUT)
        GPIO.setup(10, GPIO.INPUT)
        GPIO.setup(11, GPIO.INPUT)
        GPIO.setup(12, GPIO.INPUT)
        GPIO.setup(13, GPIO.OUTPUT, GPIO.LOW)
        GPIO.setup(14, GPIO.OUTPUT, GPIO.LOW)
        GPIO.setup(15, GPIO.OUTPUT, GPIO.LOW)
        GPIO.setup(16, GPIO.OUTPUT, GPIO.LOW)
        GPIO.setup(17, GPIO.OUTPUT, GPIO.LOW)
        GPIO.setup(18, GPIO.OUTPUT, GPIO.LOW)
        GPIO.setup(19, GPIO.OUTPUT, GPIO.LOW)
        GPIO.setup(20, GPIO.OUTPUT, GPIO.LOW)
        GPIO.setup(21, GPIO.OUTPUT, GPIO.LOW)
        GPIO.setup(22, GPIO.OUTPUT, GPIO.LOW)
        GPIO.setup(23, GPIO.OUTPUT, GPIO.LOW)
        GPIO.setup(24, GPIO.OUTPUT, GPIO.LOW)  
        GPIO.setup(25, GPIO.OUTPUT, GPIO.LOW)  


        threading.Thread(target=monitor_fruits, daemon=True).start()
        threading.Thread(target=process_fruits_in_queue, daemon=True).start()
        threading.Thread(target=control_the_conveyor, daemon=True).start()

    except KeyboardInterrupt:
        print("Programa encerrado pelo utilizador.")
        quit()