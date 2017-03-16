import numpy as np

from math import *
from Tkinter import *
from matplotlib.figure import Figure
from matplotlib.backends.backend_tkagg import FigureCanvasTkAgg
from classes.keyboard import MySerial

#NUM_DATA_POINTS = 256
#NUM_DATA_POINTS = 64*32
NUM_DATA_POINTS = 128
NUM_DATA_SAMPLES = 5
NUM_DATA_TOTAL = NUM_DATA_POINTS * NUM_DATA_SAMPLES # 64 * 180 = 11520

"""
    TODO:   Do units need to change?
"""


class GraphGui:

    def __init__(self):
        self.leftSideFrame = Frame(master = top, bg="#444444")
        self.leftSideFrame.pack(side=LEFT, padx=50)
        self.rightSideFrame = Frame(master = top)
        self.rightSideFrame.pack(side=RIGHT)
        
        self.graphSignal1 = Graph(self.rightSideFrame, "Signal 1")
        self.graphSignal2 = Graph(self.rightSideFrame, "Signal 2")
        
        button = Button(master=self.leftSideFrame, text='Get New Data', width=17, command=self.update)
        button.pack(side=TOP, pady=5)
        button = Button(master=self.leftSideFrame, text='DFFT on Signals', width=17, command=self.fourierSigs)
        button.pack(side=TOP, pady=5)
        button = Button(master=self.leftSideFrame, text='Trace Signal 1 and 2', width=17, command=self.setDualTrace)
        button.pack(side=TOP, pady=5)
        button = Button(master=self.leftSideFrame, text='Trace Signal 1', width=17, command=self.setSingleTrace1)
        button.pack(side=TOP, pady=5)
        button = Button(master=self.leftSideFrame, text='Trace Signal 2', width=17, command=self.setSingleTrace2)
        button.pack(side=TOP, pady=5)
        
        self.xMin = StringVar()
        entry = Entry(master=self.leftSideFrame, textvariable=self.xMin)
        entry.pack(side=TOP, pady=5)
        self.xMin.set("x min")
        self.xMax = StringVar()
        entry = Entry(master=self.leftSideFrame, textvariable=self.xMax)
        entry.pack(side=TOP, pady=5)
        self.xMax.set("x max")
        self.yMin = StringVar()
        entry = Entry(master=self.leftSideFrame, textvariable=self.yMin)
        entry.pack(side=TOP, pady=5)
        self.yMin.set("y min")
        self.yMax = StringVar()
        entry = Entry(master=self.leftSideFrame, textvariable=self.yMax)
        entry.pack(side=TOP, pady=5)
        self.yMax.set("y max")
       
        button = Button(master=self.leftSideFrame, text='Zoom Trace 1', width=17, command=self.zoomTrace1)
        button.pack(side=TOP, pady=5)
        button = Button(master=self.leftSideFrame, text='Zoom Trace 2', width=17, command=self.zoomTrace2)
        button.pack(side=TOP, pady=5)
        button = Button(master=self.leftSideFrame, text='Zoom Reset', width=17, command=self.zoomReset)
        button.pack(side=TOP, pady=5)

        button = Button(master=self.leftSideFrame, text='Quit', width=17, command=sys.exit)
        button.pack(side=BOTTOM, pady=80)
        
        self.setDualTrace()
        #self.setSingleTrace2()

    def update(self):
        if self.trace == 3:
            for offset in range(NUM_DATA_SAMPLES):
                serial.readyUp('\x03')
                self.graphSignal1.getNewData(offset)
                self.graphSignal2.getNewData(offset)
                #self.graphSignal2.getWasteData()
                serial.doneReading()
                if offset % 10 == 0:
                    print(offset)
            self.graphSignal1.update()
            self.graphSignal2.update()
        if self.trace == 2:
            for offset in range(NUM_DATA_SAMPLES):
                serial.readyUp('\x03')
                self.graphSignal1.getWasteData()
                self.graphSignal2.getNewData(offset)
            self.graphSignal1.update()
            self.graphSignal2.update()
        if self.trace == 1:
            for offset in range(NUM_DATA_SAMPLES):
                serial.readyUp('\x03')
                self.graphSignal1.getNewData(offset)
                self.graphSignal2.getWasteData()
            self.graphSignal1.update()
            self.graphSignal2.update()
        


    def fourierSigs(self):
        self.app = FourierGui(self.graphSignal1.data, self.graphSignal1.period, self.graphSignal2.data, self.graphSignal2.period)

    def setDualTrace(self):
        self.trace = 3
        #serial.setDualTrace()

    def setSingleTrace1(self):
        self.trace = 1
        #serial.setSingleTrace1()

    def setSingleTrace2(self):
        self.trace = 2
        #serial.setSingleTrace1()

    def zoomTrace1(self):
        self.graphSignal1.zoom(int(self.xMin.get()), int(self.xMax.get()), int(self.yMin.get()), int(self.yMax.get()))
        self.graphSignal2.update()

    def zoomTrace2(self):
        self.graphSignal1.update()
        self.graphSignal2.zoom(int(self.xMin.get()), int(self.xMax.get()), int(self.yMin.get()), int(self.yMax.get()))

    def zoomReset(self):
        self.graphSignal1.update()
        self.graphSignal2.update()
    

class Graph:

    def __init__(self, master, name):
        self.master = master
        self.name = name
        self.period = 2
        self.figure = Figure(figsize=(12,5))
        self.axes = self.figure.add_subplot(111)
        self.im = self.axes.set_autoscale_on(False)
        self.data = np.zeros(NUM_DATA_TOTAL)  # data to plot
        self.im = self.axes.plot(range(NUM_DATA_TOTAL), self.data)
        self.im = self.axes.axis([0, NUM_DATA_TOTAL-1, -3, 3])
        self.im = self.axes.set_title(self.name)
        self.im = self.axes.set_xlabel("Time (" + str(self.period) + "ns)")
        self.im = self.axes.set_ylabel("Voltage (V)")
        self.canvas = FigureCanvasTkAgg(self.figure, master=self.master)
        self.canvas.get_tk_widget().pack(side=TOP)

    def getNewData(self, offset):
        #self.prev = -1
        #self.repeat = -1
        for i in range(NUM_DATA_POINTS):
            trueOffset = offset * NUM_DATA_POINTS

            #self.data[i+trueOffset] = np.sin(2*pi*i/64)
            self.data[i+trueOffset] = (serial.getVal() / 51)-2.5
            print(str(self.name) + " " + str(i+trueOffset) + "\t" + str(self.data[i+trueOffset]))

    def getWasteData(self):
        for i in range(NUM_DATA_POINTS):
            pass
            #waste = serial.getVal()

    def update(self):
        self.canvas.get_tk_widget().destroy()
        self.figure = Figure(figsize=(12,5))
        self.axes = self.figure.add_subplot(111)
        self.im = self.axes.set_autoscale_on(False)
        self.im = self.axes.plot([x * self.period for x in range(NUM_DATA_TOTAL)], self.data, '-r')
        #self.im = self.axes.axis([0, self.period * (NUM_DATA_POINTS-1), -3, 3])
        minData = min(self.data)
        maxData = max(self.data)
        self.im = self.axes.axis([0, self.period * (NUM_DATA_TOTAL-1), minData-abs(minData/6), maxData+maxData/6])
        self.im = self.axes.set_title(self.name)
        self.im = self.axes.set_xlabel("Time (" + str(self.period) + "ns)")
        self.im = self.axes.set_ylabel("Voltage (V)")

        self.canvas = FigureCanvasTkAgg(self.figure, master=self.master)
        self.canvas.get_tk_widget().pack(side=TOP)

    def zoom(self, xMin, xMax, yMin, yMax):
        self.canvas.get_tk_widget().destroy()
        self.figure = Figure(figsize=(12,5))
        self.axes = self.figure.add_subplot(111)
        self.im = self.axes.set_autoscale_on(False)
        self.im = self.axes.plot([x * self.period for x in range(NUM_DATA_TOTAL)], self.data, '-r')
        self.im = self.axes.axis([xMin, xMax, yMin, yMax])
        self.im = self.axes.set_title(self.name)
        self.im = self.axes.set_xlabel("Time (" + str(self.period) + "ns)")
        self.im = self.axes.set_ylabel("Voltage (V)")
        
        self.canvas = FigureCanvasTkAgg(self.figure, master=self.master)
        self.canvas.get_tk_widget().pack(side=TOP)


class FourierGui:
    
    def __init__(self, dataSig1, periodSig1, dataSig2, periodSig2):
        self.master1 = Toplevel(top)
        self.frame1 = Frame(self.master1)
        self.graphSignal1 = FourierAmpGraph(self.master1, "Fourier Amplitude of Signal 1", dataSig1, periodSig1)
        self.graphSignal2 = FourierPhaseGraph(self.master1, "Fourier Phase of Signal 1", dataSig1, periodSig1)
        #button = Button(master=self.master1, text='Close Window', command=self.close_windows)
        #button.pack(side=BOTTOM)
        self.frame1.pack()
         
        self.master2 = Toplevel(top)
        self.frame2 = Frame(self.master2)
        self.graphSignal1 = FourierAmpGraph(self.master2, "Fourier Amplitude of Signal 2", dataSig2, periodSig2)
        self.graphSignal2 = FourierPhaseGraph(self.master2, "Fourier Phase of Signal 2", dataSig2, periodSig2)
        self.frame2.pack()
        

    def close_windows(self):
        self.master.destroy()


class FourierAmpGraph:
    
    def __init__(self, master, name, otherData, otherPeriod):
        self.name = name
        self.data = np.fft.fft(otherData)
        self.dataReal = self.data.real
        self.dataImag = self.data.imag
        print(self.data)
        print(self.dataReal)
        print(self.dataImag)
        #self.otherPeriod = otherPeriod
        #for i in range(len(self.data)):
        #    print(((self.dataReal[i] ** 2) + (self.dataImag[i] ** 2))**0.5)
        self.period = 0.5
        self.figure = Figure(figsize=(12,5))
        self.axes = self.figure.add_subplot(111)
        data = [np.absolute(x) for x in self.data]
        dataRange = [x * 500000 for x in np.fft.fftfreq(NUM_DATA_TOTAL)]
        #dataRange = range(NUM_DATA_TOTAL)

        self.im = self.axes.stem(dataRange, data) # edit this
        maxData = max(data)
        minDataRange = min(dataRange)
        maxDataRange = max(dataRange)
        self.im = self.axes.axis([minDataRange, maxDataRange, -1, maxData+maxData/6])
        self.im = self.axes.set_title(self.name)
        #self.im = self.axes.set_xlabel("Frequency (" + str(self.period) + "MHz)")
        self.im = self.axes.set_xlabel("Frequency (Hz)")
        self.im = self.axes.set_ylabel("Voltage (V)")
        self.canvas = FigureCanvasTkAgg(self.figure, master=master)
        self.canvas.get_tk_widget().pack(side=TOP)
        #for i in range(NUM_DATA_TOTAL):
        #    print(str(dataRange[i]) + "  " + str(data[i]))


class FourierPhaseGraph:
    
    def __init__(self, master, name, otherData, otherPeriod):
                
        self.name = name
        self.data = np.fft.fft(otherData)
        #self.otherPeriod = otherPeriod
        self.period = 0.5
        self.figure = Figure(figsize=(12,5))
        self.axes = self.figure.add_subplot(111)
        data = [np.angle(x) for x in self.data]
        dataRange = [x * 500000 for x in np.fft.fftfreq(NUM_DATA_TOTAL)]
        #dataRange = range(NUM_DATA_TOTAL)
        self.im = self.axes.stem(dataRange, data) # edit this
        minData = min(data)
        maxData = max(data)
        minDataRange = min(dataRange)
        maxDataRange = max(dataRange)
        self.im = self.axes.axis([minDataRange, maxDataRange, minData-abs(minData/6), maxData+maxData/6])
        self.im = self.axes.set_title(self.name)
        #self.im = self.axes.set_xlabel("Frequency (" + str(self.period) + "MHz)")
        self.im = self.axes.set_xlabel("Frequency (Hz)")
        self.im = self.axes.set_ylabel("Voltage (V)")
        self.canvas = FigureCanvasTkAgg(self.figure, master=master)
        self.canvas.get_tk_widget().pack(side=TOP)
        #for i in range(NUM_DATA_TOTAL):
        #    print(str(dataRange[i]) + "  " + str(data[i]))


serial = MySerial()

top = Tk()
top.configure(background='#444444')
graphGui = GraphGui()
menubar = Menu(top)
filemenu = Menu(menubar, tearoff=0)
filemenu.add_command(label="Get New Data", command=graphGui.update)
filemenu.add_command(label="DFFT on Signals", command=graphGui.fourierSigs)
menubar.add_cascade(label="Tool", menu=filemenu)


top.config(menu=menubar)
top.update_idletasks()
top.mainloop()
