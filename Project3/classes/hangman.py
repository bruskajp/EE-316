from random import randint
from enum import Enum
from time import sleep

class Game:
    words = []
    wordsMissed = []
    wordsCorrect = [] 
    round = ''
    gameInfo = ''

    def initWords(self, fileName):
        file = open(fileName, "r")
        self.words = file.read().split('\n')
        self.words[:] = [list(x) for x in self.words if x != '']
        file.close()       
    
    def startGame(self):
        roundCount = 0
        while roundCount != len(self.words):
            print("New Game? ")
            self.gameInfo = "New Game?"
            inputStart = input(">> ")
            if inputStart == 'y':
                roundCount += 1
                roundWord = self.nextRoundWord()
                self.round = Round(roundWord)
                roundResult = self.round.playRound()
                if roundResult == RoundState.WIN:
                    self.wordsCorrect.append(roundWord)
                    print("Well done! You have solved " + str(len(self.wordsCorrect)) + " puzzles out of " + str(len(self.wordsCorrect)+len(self.wordsMissed)))
                    self.gameInfo = "Well done! You have solved " + str(len(self.wordsCorrect)) + " puzzles out of " + str(len(self.wordsCorrect)+len(self.wordsMissed))
                    sleep(3)
                elif roundResult == RoundState.LOSE:
                    self.wordsMissed.append(roundWord)
                    print("Sorry! The correct word was " + ''.join(roundWord) + " You have solved " + str(len(self.wordsCorrect)) + " puzzles out of " + str(len(self.wordsCorrect)+len(self.wordsMissed)))
                    self.gameInfo = "Sorry! The correct word was " + ''.join(roundWord) + " You have solved " + str(len(self.wordsCorrect)) + " puzzles out of " + str(len(self.wordsCorrect)+len(self.wordsMissed))
                    sleep(3)
                else:
                    # ERROR
                    print("Round state error")
            elif inputStart == 'n' and roundCount != 0:
                break
        print("You have solved " + str(len(self.wordsCorrect)) + " puzzles out of " + str(len(self.wordsCorrect)+len(self.wordsMissed)))
        self.gameInfo = "You have solved " + str(len(self.wordsCorrect)) + " puzzles out of " + str(len(self.wordsCorrect)+len(self.wordsMissed))
        sleep(3)
        print("GAME OVER")
        self.gameInfo = "GAME OVER"

    def nextRoundWord(self):
        word = self.words[randint(0,len(self.words)-1)]
        while (word in self.wordsMissed) or (word in self.wordsCorrect):
            word = self.words[randint(0,len(self.words)-1)] 
            print(word)
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
    guessesRemaining = 5
    roundState = RoundState.INIT

    def __init__(self, word):
        self.initRound(word)

    def printUnfinishedWord(self):
        print(''.join(self.unfinishedWord))

    def initRound(self, word):
        self.word = word
        self.wordLetters = set(word)
        self.unfinishedWord = list('_' * len(word))
        self.roundState = RoundState.READY
    
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
        inputLetter = input(">> ")
        if inputLetter in self.wordLetters:
            self.wordLetters.remove(inputLetter)
            letterIndices = [i for i, letter in enumerate(self.word) if letter == inputLetter]
            for letterIndex in letterIndices:
                self.unfinishedWord[letterIndex] = inputLetter
            # send changed letter and letterIndices to serial
            if '_' not in self.unfinishedWord:
                self.roundState = RoundState.WIN 
        else:
            self.guessesRemaining = self.guessesRemaining - 1
            if self.guessesRemaining == 0:
                self.roundState = RoundState.LOSE
        self.printUnfinishedWord() # gui version needed 
                




