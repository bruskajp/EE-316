from serial import *
import time

serial = Serial(
    port = '/dev/ttyUSB1',
    baudrate = 11520,
    parity = PARITY_NONE,        # Check this
    stopbits = STOPBITS_ONE,    # Check this
    bytesize = EIGHTBITS
)  

serial.isOpen()

while True:
    inputs = input(">> ")
    serial.write(inputs.encode('ascii'))

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


