from tkinter import *

top = Tk()
label = Label(top, text='Title')

guessesRemaining = 5

def changePicture(guessesRemaining):
    guessesRemaining -= 1
    pictureName = "assets/Hangman_" + str(5-guessesRemaining) + ".png"
    newImage = PhotoImage(file=pictureName)
    pictureLabel.configure(image=newImage)
    pictureLabel.image=newImage

def resetPicture(guessesRemaining):
    newImage = PhotoImage(file='assets/Hangman_0.png')
    pictureLabel.configure(image=newImage)
    pictureLabel.image=newImage

leftFrame = Frame(top)
leftFrame.pack(side=LEFT)

rightFrame = Frame(top)
rightFrame.pack(side=LEFT)

gameInfoText = StringVar()
gameInfoText.set('GAME INFO: just checking all the \nthings to see if it do the do')

unfinishedWordText = StringVar()
unfinishedWordText.set('_ _ _ _ _')

myImage = PhotoImage(file='assets/Hangman_0.png')
pictureLabel = Label(leftFrame, image=myImage)
submitButton = Button(rightFrame, text="Submit", command=lambda: changePicture(guessesRemaining))
label1 = Label(rightFrame, textvariable=gameInfoText, pady=20, padx=20, width=25)
label2 = Label(rightFrame, textvariable=unfinishedWordText, pady=20, padx=20, width=25)

pictureLabel.grid(column=0, row=1)
submitButton.grid(column=1, row=1)
label1.grid(column=1, row=2)
label2.grid(column=1, row=3)

top.mainloop()

