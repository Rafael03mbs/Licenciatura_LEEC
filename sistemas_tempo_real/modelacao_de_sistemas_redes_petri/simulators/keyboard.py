import platform
system = platform.system()
if system == 'Windows':
    import msvcrt
elif system == 'Linux':
    import sys
    import select
else:
    print("Unsupported operating system")



def is_key_pressed():
    if system == 'Windows':
        return msvcrt.kbhit()
    else:        
        return select.select([sys.stdin], [], [], 0) == ([sys.stdin], [], [])
    
    

def getChar():
    if system == 'Windows':
        return msvcrt.getch().decode('utf-8')
    else:        
        return sys.stdin.read(1)


