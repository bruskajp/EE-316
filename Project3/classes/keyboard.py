from time import *
import serial
from serial import *

class MySerial:
    serial = Serial(
        port = '/dev/ttyUSB0',
        #port = '/dev/serial/by-path/pci-0000:00:14.0-usb-0:5:1.0-port0',
        baudrate = 9600,
        parity = PARITY_NONE,        # Check this
        stopbits = STOPBITS_ONE,    # Check this
        bytesize = EIGHTBITS
    )

    def __init__(self):
        self.serial.isOpen()

    def sendData(self, text):
        if(len(text) > 20):
            for index in range(0, len(text)-20):
                part = text[index:index+20]
                self.sendShortData(part)
                print(part)
                time.sleep(0.25) # 250ms
        else:
            self.sendShortData(text)
    
    def sendShortData(self, text):
        self.initDisplayValues()
        for character in text:
            values = self.asciiToRs232(character)
            for value in values:
                self.serial.write(value)
                time.sleep(0.005) # 5ms
        self.serial.write(bytes([0]))

    def getChar(self):
        while 1:
            while self.serial.inWaiting() > 0:
                return chr(self.serial.read(1)[0])
   
    # 8 bits
    # | 

    def asciiToRs232(self,character):
        values = []
        enBits = 16
        rsBits = 32
      
        values.append(bytes([(character.encode('ascii')[0] >> 4) | enBits | rsBits]))
        values.append(bytes([(character.encode('ascii')[0] >> 4) | rsBits]))
        values.append(bytes([(character.encode('ascii')[0] >> 4) | enBits | rsBits]))
        print(hex((character.encode('ascii')[0] >> 4) | enBits | rsBits))
        
        values.append(bytes([(character.encode('ascii')[0] & 15) | enBits | rsBits]))
        values.append(bytes([(character.encode('ascii')[0] & 15) | rsBits]))
        values.append(bytes([(character.encode('ascii')[0] & 15) | enBits | rsBits]))
        print(hex((character.encode('ascii')[0] & 15) | enBits | rsBits))
        return values

    def initDisplay(self):
        #values = [3,19,3,3,19,3,3,19,3,2,18,2,2,18,2,4,20,4,0,16,0,12,28,12,0,16,0,1,17,1,0,16,0,6,22,6]
        #values = [19,3,19,19,3,19,19,3,19,18,2,18,18,2,18,20,4,20,16,0,16,28,12,28,16,0,16,17,1,17,16,0,16,22,6,22]
        values = [19,3,19,19,3,19,19,3,19,18,2,18,18,2,18,20,4,20,16,0,16,24,8,24,16,0,16,17,1,17,16,0,16,22,6,22,16,0,16,31,15,31,17,1,17,16,0,16]
        #values = [3,19,3,0,16,0,3,19,3,0,16,0,3,19,3,0,16,0,2,18,2,0,16,0,2,18,2,0,16,0,0,16,0,0,16,0,0,16,0,0,16,0,6,22,6,0,16,0,0,16,0,0,16,0,0,16,0,12,28,12,0,16,0,0,16,0,0,16,0,1,17,1]

        #values = [19,3,19,19,3,19,19,3,19,18,2,18,18,2,18,24,8,24,16,0,16,24,8,24,16,0,16,17,1,17,16,0,16,22,6,22,16,0,16,28,12,28]

        for command in values:
            self.serial.write(bytes([command]))
            time.sleep(0.005) # 5ms
            print(hex(command))
        time.sleep(0.025)

    def initDisplayValues(self):
        initDisplay = [0,1,0,6,8,0]
        #initDisplay = []
        values = []
        enBits = 16
        
        for command in initDisplay:
            self.serial.write(bytes([command | enBits]))
            time.sleep(0.005) # 5ms
            self.serial.write(bytes([command]))
            time.sleep(0.005) # 5ms
            self.serial.write(bytes([command | enBits]))
            time.sleep(0.005) # 5ms
   
    def sendLcdCommand(self, command):
        values = []
        enBits = 16

        self.serial.write(bytes([(command >> 4) | enBits]))
        time.sleep(0.005) # 5ms
        self.serial.write(bytes([(command >> 4)]))
        time.sleep(0.005) # 5ms
        self.serial.write(bytes([(command >> 4) | enBits]))
        time.sleep(0.005) # 5ms

        self.serial.write(bytes([(command & 15) | enBits]))
        time.sleep(0.005) # 5ms
        self.serial.write(bytes([(command & 15)]))
        time.sleep(0.005) # 5ms
        self.serial.write(bytes([(command & 15) | enBits]))
        time.sleep(0.005) # 5ms

    def decrementCounter(self):
        self.serial.write(bytes([64]))
        self.serial.write(bytes([0]))

    def resetCounter(self):
        self.serial.write(bytes([128]))
        self.serial.write(bytes([0]))
        self.serial.write(bytes([64]))
        self.serial.write(bytes([0]))
        self.serial.write(bytes([64]))
        self.serial.write(bytes([0]))






