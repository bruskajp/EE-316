from time import *
import serial
from serial import *

class MySerial:
    serial = Serial(
        port = '/dev/ttyUSB0',
        baudrate = 115200,
        parity = PARITY_NONE,        # Check this
        stopbits = STOPBITS_ONE,    # Check this
        bytesize = EIGHTBITS
    )

    def __init__(self):
        self.serial.isOpen()

    def getVal(self):
        while 1:
            while self.serial.inWaiting() > 0:
                #print(ord(self.serial.read(1)))
                return ord(self.serial.read(1))

    def setNoTrace(self):
        self.serial.write(bytes([0]))
   
    def setSingleTrace1(self):
        self.serial.write(bytes([1]))
    
    def setSingleTrace2(self):
        self.serial.write(bytes([2]))

    def setDualTrace(self):
        self.serial.write(bytes([3]))




