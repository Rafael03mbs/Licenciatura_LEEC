import threading
import time
import os

import sys
sys.path.append("simulators")
import simulators.GPIOsim as GPIO
import simulators.iSTRwebServer as webServer

import simulators.keyboard as keyboard

keyboardKey = ''
macas=0
peras=0
limoes=0

caixa_macas=0
caixa_peras=0
caixa_limoes=0

timeout=0
emergency_stop = False

def keyboard_input():
    global timetout
    timetout = time.time()
    try:
        if keyboard.is_key_pressed():
            key = keyboard.getChar()
            return key
    except Exception as e:
        print(f"An error occurred: {e}")
        os._exit(0)
    return ''


def idle_keyboard():
    global timeout, emergency_stop
    print("Press 'f' FINISH, 'e' EMERGENCY STOP, 'r' RESUME, 'x' FRUTAS, 'y' CAIXAS")
    while True:
        if time.time() - timeout > 1.0:
            key = keyboard_input()
            if key == 'f':  # Encerrar o programa
                print("Encerrando o programa.")
                sys.exit(0)
                os._exit(0)
            elif key == 'e':  # Tecla para Emergency Stop
                Conveyor_Stop()
                emergency_stop = True
                print("Emergency Stop ativado! Todas as ações estão bloqueadas.")
            elif key == 'r':  # Tecla para resetar o Emergency Stop
                emergency_stop = False
                Conveyor_Move()
                print("Emergency Stop desativado! O sistema está ativo novamente.")
            elif key == 'x':  
                print(f"Número de frutas:")
                print(f" - Número de Maçãs: {macas}")
                print(f" - Número de Peras: {peras}")
                print(f" - Número de Limões: {limoes}")
            elif key == 'y':  
                print(f"Número de caixas:")
                print(f" - Número de caixas de Maçãs: {caixa_macas}")
                print(f" - Número de caixas de Peras: {caixa_peras}")
                print(f" - Número de caixas de Limões: {caixa_limoes}")


# Funções auxiliares e simulações de hardware

def numero_macas(tokensBefore=0, tokensNow=0, tokensCount=0):
    global macas, caixa_macas
    macas += 1
    if macas % 5 == 0:  # Adiciona uma caixa a cada 5 maçãs
        caixa_macas += 1
        macas = 0

def numero_limoes(tokensBefore=0, tokensNow=0, tokensCount=0):
    global limoes, caixa_limoes
    limoes += 1
    if limoes % 5 == 0:  # Adiciona uma caixa a cada 5 limões
        caixa_limoes += 1
        limoes = 0

def numero_peras(tokensBefore=0, tokensNow=0, tokensCount=0):
    global peras, caixa_peras
    peras += 1
    if peras % 5 == 0:  # Adiciona uma caixa a cada 5 peras
        caixa_peras += 1
        peras = 0

def Spawn_Apple(tokensBefore=0, tokensNow=0, tokensCount=0):
    while(emergency_stop):{} 
    GPIO.output(20, GPIO.HIGH)

def Spawn_Pear(tokensBefore=0, tokensNow=0, tokensCount=0):
    while(emergency_stop):{} 
    GPIO.output(21, GPIO.HIGH)

def Spawn_Lemon(tokensBefore=0, tokensNow=0, tokensCount=0):
    while(emergency_stop):{} 
    GPIO.output(22, GPIO.HIGH)

def Conveyor_Move(tokensBefore=0, tokensNow=0, tokensCount=0):
    while(emergency_stop):{} 
    GPIO.output(19, GPIO.HIGH)

def Conveyor_Stop(tokensBefore=0, tokensNow=0, tokensCount=0):
    while(emergency_stop):{} 
    GPIO.output(19, GPIO.LOW)

def CylinderStart_MoveForward(tokensBefore=0, tokensNow=0, tokensCount=0):
    while(emergency_stop):{} 
    GPIO.output(13, GPIO.HIGH)
    GPIO.output(14, GPIO.LOW)

def CylinderStart_MoveBackwards(tokensBefore=0, tokensNow=0, tokensCount=0):
    while(emergency_stop):{} 
    GPIO.output(13, GPIO.LOW)
    GPIO.output(14, GPIO.HIGH)

def Cylinder1_MoveForward(tokensBefore=0, tokensNow=0, tokensCount=0):
    while(emergency_stop):{} 
    GPIO.output(15, GPIO.HIGH)
    GPIO.output(16, GPIO.LOW)

def Cylinder1_MoveBackwards(tokensBefore=0, tokensNow=0, tokensCount=0):
    while(emergency_stop):{}     
    GPIO.output(15, GPIO.LOW)
    GPIO.output(16, GPIO.HIGH)

def Cylinder2_MoveForward(tokensBefore=0, tokensNow=0, tokensCount=0):
    while(emergency_stop):{} 
    GPIO.output(17, GPIO.HIGH)
    GPIO.output(18, GPIO.LOW)

def Cylinder2_MoveBackwards(tokensBefore=0, tokensNow=0, tokensCount=0):
    while(emergency_stop):{} 
    GPIO.output(17, GPIO.LOW)
    GPIO.output(18, GPIO.HIGH)

def ResetBox_apple(tokensBefore=0, tokensNow=0, tokensCount=0):
    global macas, caixa_macas
    if emergency_stop:
        return
    GPIO.output(23, GPIO.HIGH)
   
def ResetBox_pear(tokensBefore=0, tokensNow=0, tokensCount=0):
    global peras, caixa_peras
    if emergency_stop:
        return
    GPIO.output(24, GPIO.HIGH)
    
def ResetBox_Lemon(tokensBefore=0, tokensNow=0, tokensCount=0):
    global caixa_limoes, limoes
    if emergency_stop:
        return
    GPIO.output(25, GPIO.HIGH)  

def isCylinderStart_Working(tokensCount=0):
    return GPIO.input(1) == GPIO.HIGH

def isCylinderStart_Resting(tokensCount=0):
    return GPIO.input(2) == GPIO.HIGH

def isAtApple_atDock1(tokensCount=0):
    return GPIO.input(3) == GPIO.HIGH

def isAtPear_atDock1(tokensCount=0):
    return GPIO.input(4) == GPIO.HIGH

def isAtLemon_atDock1(tokensCount=0):
    return GPIO.input(5) == GPIO.HIGH

def isCylinder1_Working(tokensCount=0):
    return GPIO.input(6) == GPIO.HIGH

def isCylinder1_Resting(tokensCount=0):
    return GPIO.input(7) == GPIO.HIGH

def isFruit_atDock2(tokensCount=0):
    return GPIO.input(8) == GPIO.HIGH

def isCylinder2_Working(tokensCount=0):
    return GPIO.input(9) == GPIO.HIGH

def isCylinder2_Resting(tokensCount=0):
    return GPIO.input(10) == GPIO.HIGH

def isFruit_atDock3(tokensCount=0):
    return GPIO.input(11) == GPIO.HIGH

def isFruit_atEnd(tokensCount=0):
    return GPIO.input(12) == GPIO.HIGH



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

        
        input_thread = threading.Thread(target = idle_keyboard)
        input_thread.start()

    except KeyboardInterrupt:
        print("Programa encerrado pelo utilizador.")
        quit()