from serial import *
import time

serial = Serial(
    port = '/dev/ttyUSB0',
    baudrate = 9600,
    parity = PARITY_NONE,        # Check this
    stopbits = STOPBITS_ONE,    # Check this
    bytesize = EIGHTBITS
)  

serial.isOpen()


#inputs = input(">> ")
serial.write('abcdefghijklmnopqrstuvwxyz'.encode('ascii'))
time.sleep(1)



out = 0
def getChar():
    while 1:
        while serial.inWaiting() > 0:
            return chr(serial.read(1)[0])
while 1:
    val = getChar()
    print(val)


