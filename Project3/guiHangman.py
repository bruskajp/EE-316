from tkinter import *
from random import randint
from enum import Enum
from time import sleep
from classes.keyboard import MySerial

top = Tk()
label = Label(top, text='Title')

leftFrame = Frame(top)
leftFrame.pack(side=LEFT)

rightFrame = Frame(top)
rightFrame.pack(side=LEFT)

gameInfoText = StringVar()
gameInfoText.set('GAME INFO: just checking all the \nthings to see if it do the do')

unfinishedWordText = StringVar()
unfinishedWordText.set('')

myImage = PhotoImage(file='assets/Hangman_0.png')
pictureLabel = Label(leftFrame, image=myImage)
titleLabel = Label(rightFrame, text="HANGMAN\n----------------", pady=20, padx=20)
label1 = Label(rightFrame, textvariable=gameInfoText, pady=20, padx=20)
label2 = Label(rightFrame, textvariable=unfinishedWordText, pady=20, padx=20)

pictureLabel.grid(column=0, row=1)
titleLabel.grid(column=1, row=1)
label1.grid(column=1, row=2)
label2.grid(column=1, row=3)

top.update_idletasks()

serial = MySerial()

def resetPicture():
    newImage = PhotoImage(file='assets/Hangman_0.png')
    pictureLabel.configure(image=newImage)
    pictureLabel.image=newImage

class Game:
    words = []
    wordsMissed = []
    wordsCorrect = []
    round = ''
    top = ''
    gameInfo = ''
    unfinishedWord = ''
    pictureLabel = ''

    def __init__(self, top, gameInfoText, unfinishedWordText, pictureLabel):
        self.top = top
        self.gameInfo = gameInfoText
        self.unfinishedWord = unfinishedWordText
        self.pictureLabel = pictureLabel
        serial.initDisplay()

    def printGameInfo(self, gameInfo):
        self.gameInfo.set(gameInfo)
        top.update_idletasks()
        print(gameInfo)
        serial.sendData(gameInfo) # serial output

    def initWords(self, fileName):
        file = open(fileName, "r")
        self.words = file.read().split('\n')
        self.words[:] = [list(x) for x in self.words if x != '']
        file.close()

    def startGame(self):
        roundCount = 0
        while roundCount != len(self.words):
            self.printGameInfo("New Game? ")
            self.unfinishedWord.set("")
            #inputStart = input(">> ") # command line input
            inputStart = serial.getChar() # serial input
            if inputStart == 'y':
                self.printGameInfo("Guess a letter!")
                roundCount += 1
                roundWord = self.nextRoundWord()
                self.round = Round(roundWord, top, self.unfinishedWord, self.pictureLabel)
                roundResult = self.round.playRound()
                if roundResult == RoundState.WIN:
                    self.wordsCorrect.append(roundWord)
                    self.printGameInfo("Well done! You have solved " + str(len(self.wordsCorrect)) + " puzzles out of " + str(len(self.wordsCorrect)+len(self.wordsMissed)))
                    sleep(3)
                elif roundResult == RoundState.LOSE:
                    self.wordsMissed.append(roundWord)
                    self.printGameInfo("Sorry! The correct word was " + ''.join(roundWord) + " You have solved " + str(len(self.wordsCorrect)) + " puzzles out of " + str(len(self.wordsCorrect)+len(self.wordsMissed)))
                    sleep(3)
                else:
                    # ERROR
                    print("Round state error")
            elif inputStart == 'n' and roundCount != 0:
                break
        self.printGameInfo("You have solved " + str(len(self.wordsCorrect)) + " puzzles out of " + str(len(self.wordsCorrect)+len(self.wordsMissed)))
        sleep(3)
        self.printGameInfo("GAME OVER")
        sleep(3)

    def nextRoundWord(self):
        word = self.words[randint(0,len(self.words)-1)]
        while (word in self.wordsMissed) or (word in self.wordsCorrect):
            word = self.words[randint(0,len(self.words)-1)]
        print(''.join(word))
        return word

class RoundState(Enum):
    INIT = 1
    READY = 2
    PLAYING = 4
    WIN = 5
    LOSE = 6

class Round:
    word = []
    wordLetters = []
    unfinishedWord = []
    unfinishedWordPlain = ''
    guessesRemaining = 5
    roundState = RoundState.INIT
    top = ''

    def __init__(self, word, top, unfinishedWord, pictureLabel):
        self.initRound(word)
        self.top = top
        self.unfinishedWordPlain = unfinishedWord
        self.pictureLabel = pictureLabel
        serial.resetCounter() # serial output

    def printUnfinishedWord(self):
        self.unfinishedWordPlain.set(" ".join(self.unfinishedWord))
        top.update_idletasks()
        print(self.unfinishedWord)
        serial.sendData(self.unfinishedWord) # serial output

    def updateImage(self):
        pictureName = "assets/Hangman_" + str(5-self.guessesRemaining) + ".png"
        newImage = PhotoImage(file=pictureName)
        self.pictureLabel.configure(image=newImage)
        self.pictureLabel.image=newImage
        top.update_idletasks()

    def initRound(self, word):
        self.word = word
        self.wordLetters = set(word)
        self.unfinishedWord = list('_' * len(word))
        self.roundState = RoundState.READY
        resetPicture()

    def playRound(self):
        if(self.roundState == RoundState.READY):
            self.roundState = RoundState.PLAYING
            self.printUnfinishedWord()
            while self.roundState == RoundState.PLAYING:
                self.takeTurn()
            return self.roundState
        else:
            # ERROR
            print("Round not ready")

    def takeTurn(self):
        #inputLetter = input(">> ") # command line input
        inputLetter = serial.getChar() # serial input
        if inputLetter in self.wordLetters:
            self.wordLetters.remove(inputLetter)
            letterIndices = [i for i, letter in enumerate(self.word) if letter == inputLetter]
            for letterIndex in letterIndices:
                self.unfinishedWord[letterIndex] = inputLetter
            if '_' not in self.unfinishedWord:
                self.roundState = RoundState.WIN
        else:
            self.guessesRemaining = self.guessesRemaining - 1
            serial.decrementCounter() # serial output
            if self.guessesRemaining == 0:
                self.roundState = RoundState.LOSE
        self.printUnfinishedWord() 
        self.updateImage() 

game = Game(top, gameInfoText, unfinishedWordText, pictureLabel)
game.initWords("words.txt")
game.startGame()


'''

from time import sleep
from threading import *

class FuncThread(Thread):
    def __init__(self, target, *args):
        Thread.__init__(self)
        self._target = target
        self._args = args
    
    def run(self):
        self._target(*self._args)

def updateGameView(top, game):
    while 1:
        sleep(1)
        gameInfoText.set(game.gameInfo)
        print(game.gameInfo)
        #unfinishedWordText.set()
        top.update_idletasks()

def gameThing(game):
    game.startGame

game = Game(top)
game.initWords("words.txt")
threadedGameViewUpdater = FuncThread(gameThing, game)
threadedGameViewUpdater.start()
threadedGameViewUpdater.join()
updateGameView(top, game)

'''




