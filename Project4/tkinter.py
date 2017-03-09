import numpy as np
from Tkinter import *
from matplotlib.figure import Figure
from matplotlib.backends.backend_tkagg import FigureCanvasTkAgg

class Graph:

    def __init__(self, data, top):
        self.data = data
        self.figure = Figure(figsize=(12,4))
        self.axes = self.figure.add_subplot(111)
        self.im = self.axes.plot(data)
        self.canvas = FigureCanvasTkAgg(self.figure, master=top)
        self.canvas.get_tk_widget().pack(side=TOP)

    def update(self, data):
        self.canvas.get_tk_widget().destroy()
        self.data = data
        self.figure = Figure(figsize=(12,4))
        self.axes = self.figure.add_subplot(111)
        self.im = self.axes.plot(data, '-r')
        self.canvas = FigureCanvasTkAgg(self.figure, master=top)
        self.canvas.get_tk_widget().pack(side=TOP)


class GraphGui:

    def __init__(self, data):
        self.graphSignal1 = Graph(data, top)
        self.graphSignal2 = Graph(data, top)
        button = Button(master=top, text='Quit', command=sys.exit)
        button.pack(side=BOTTOM)

    def update(self):
        self.graphSignal1.update(np.arange(100)+10*(np.random.rand(100)-0.5))
        self.graphSignal2.update(np.arange(5,50))

    def fourierSig1(self):
        print("DFFT: Signal 1") 

    def fourierSig2(self):
        print("DFFT: Signal 2") 


top = Tk()
data = np.arange(100)  # data to plot
graphGui = GraphGui(data)
menubar = Menu(top)
filemenu = Menu(menubar, tearoff=0)
filemenu.add_command(label="Update Graphs", command=graphGui.update)
filemenu.add_command(label="DFFT: Signal 1", command=graphGui.fourierSig1)
filemenu.add_command(label="DFFT: Signal 2", command=graphGui.fourierSig2)
menubar.add_cascade(label="Tool", menu=filemenu)


top.config(menu=menubar)
top.mainloop()
