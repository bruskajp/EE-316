import numpy as np
from Tkinter import *
from matplotlib.figure import Figure
from matplotlib.backends.backend_tkagg import FigureCanvasTkAgg
from math import *

NUM_DATA_POINTS = 9
#NUM_DATA_POINTS = 11520



"""
    TODO:   Single vs Dual
            Zoom in and Zoom out
            Check FFT phase and mag formulas
            Add in serial component
"""



class GraphGui:

    def __init__(self):
        button1 = Button(master=top, text='Get New Data', command=self.update)
        button1.pack(side=TOP)
        button1 = Button(master=top, text='DFFT on Signals', command=self.fourierSigs)
        button1.pack(side=TOP)
        self.graphSignal1 = Graph(top, "Signal 1")
        self.graphSignal2 = Graph(top, "Signal 2")
        button = Button(master=top, text='Quit', command=sys.exit)
        button.pack(side=BOTTOM)

    def update(self):
        self.graphSignal1.getNewData()
        self.graphSignal2.getNewData()
        self.graphSignal1.update()
        self.graphSignal2.update()

    def fourierSigs(self):
        self.app = FourierGui(self.graphSignal1.data, self.graphSignal1.period, self.graphSignal2.data, self.graphSignal2.period)


class Graph:

    def __init__(self, top, name):
        self.name = name
        self.period = 2
        self.figure = Figure(figsize=(12,5))
        self.axes = self.figure.add_subplot(111)
        self.im = self.axes.set_autoscale_on(False)
        self.data = np.zeros(NUM_DATA_POINTS)  # data to plot
        self.im = self.axes.plot(range(NUM_DATA_POINTS), self.data)
        self.im = self.axes.axis([0, NUM_DATA_POINTS-1, -3, 3])
        self.im = self.axes.set_title(self.name)
        self.im = self.axes.set_xlabel("Time (" + str(self.period) + "ns)")
        self.im = self.axes.set_ylabel("Voltage (V)")
        self.canvas = FigureCanvasTkAgg(self.figure, master=top)
        self.canvas.get_tk_widget().pack(side=TOP)

    def getNewData(self):
        for i in range(NUM_DATA_POINTS):
        #    val = input("Input num: ")
        #    self.data[i] = val
            self.data[i] = np.sin(pi*i/4)
        #self.period = input("Input period: ")    

    def update(self):
        self.canvas.get_tk_widget().destroy()
        self.figure = Figure(figsize=(12,5))
        self.axes = self.figure.add_subplot(111)
        self.im = self.axes.set_autoscale_on(False)
        self.im = self.axes.plot([x * self.period for x in range(NUM_DATA_POINTS)], self.data, '-r')
        self.im = self.axes.axis([0, self.period * (NUM_DATA_POINTS-1), -3, 3])
        self.im = self.axes.set_title(self.name)
        self.im = self.axes.set_xlabel("Time (" + str(self.period) + "ns)")
        self.im = self.axes.set_ylabel("Voltage (V)")

        self.canvas = FigureCanvasTkAgg(self.figure, master=top)
        self.canvas.get_tk_widget().pack(side=TOP)


class FourierGui:
    
    def __init__(self, dataSig1, periodSig1, dataSig2, periodSig2):
        self.master1 = Toplevel(top)
        self.frame1 = Frame(self.master1)
        self.graphSignal1 = FourierAmpGraph(self.master1, "Fourier Amplitude of Signal 1", dataSig1, periodSig1)
        self.graphSignal2 = FourierPhaseGraph(self.master1, "Fourier Phase of Signal 1", dataSig1, periodSig1)
        button = Button(master=self.master1, text='Close Window', command=self.close_windows)
        button.pack(side=BOTTOM)
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
        for i in range(len(self.data)):
            print(((self.dataReal[i] ** 2) + (self.dataImag[i] ** 2))**0.5)
        self.period = 0.5
        self.figure = Figure(figsize=(12,5))
        self.axes = self.figure.add_subplot(111)
        data = [np.absolute(x) for x in self.data]
        self.im = self.axes.stem(range(NUM_DATA_POINTS), data) # edit this
        self.im = self.axes.axis([-1, NUM_DATA_POINTS, -1, max(data)+1])
        self.im = self.axes.set_title(self.name)
        self.im = self.axes.set_xlabel("Frequency (" + str(self.period) + "MHz)")
        self.im = self.axes.set_ylabel("Voltage (V)")
        self.canvas = FigureCanvasTkAgg(self.figure, master=master)
        self.canvas.get_tk_widget().pack(side=TOP)


class FourierPhaseGraph:
    
    def __init__(self, master, name, otherData, otherPeriod):
        self.name = name
        self.data = np.fft.fft(otherData)
        print(self.data)
        #self.otherPeriod = otherPeriod
        self.period = 0.5
        self.figure = Figure(figsize=(12,5))
        self.axes = self.figure.add_subplot(111)
        data = [np.angle(x) for x in self.data]
        self.im = self.axes.stem(range(NUM_DATA_POINTS), data) # edit this
        self.im = self.axes.axis([-1, NUM_DATA_POINTS, min(data)-1, max(data)+1])
        self.im = self.axes.set_title(self.name)
        self.im = self.axes.set_xlabel("Frequency (" + str(self.period) + "MHz)")
        self.im = self.axes.set_ylabel("Voltage (V)")
        self.canvas = FigureCanvasTkAgg(self.figure, master=master)
        self.canvas.get_tk_widget().pack(side=TOP)




top = Tk()
graphGui = GraphGui()
menubar = Menu(top)
filemenu = Menu(menubar, tearoff=0)
filemenu.add_command(label="Get New Data", command=graphGui.update)
filemenu.add_command(label="DFFT on Signals", command=graphGui.fourierSigs)
menubar.add_cascade(label="Tool", menu=filemenu)


top.config(menu=menubar)
top.update_idletasks()
top.mainloop()
