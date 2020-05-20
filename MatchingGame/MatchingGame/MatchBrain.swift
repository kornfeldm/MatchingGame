//
//  MatchBrain.swift
//  MatchingGame
//
//  Created by Mark Kornfeld on 4/13/20.
//  Copyright © 2020 Mark Kornfeld. All rights reserved.
//

import Foundation
//AVFoundation is used by the SoundEffects class
import AVFoundation


//Handles the overall settings of the game (i.e. which level you are on)
class GameManager{
    
    //Stores how many moves are allowed
    var movesAllowed = 100
    //Stores the level a user is on
    var level = 1
    
    init(){
        
    }
    
    //When a game ends, it is either because the player won or lost. This updates the turns and level accordingly
    func reset(win:Bool) -> Int{
        //If the player lost
        if (win == false)
        {
            //Reset everything back to the beginning
            level = 1
            movesAllowed = 100
        //If not, it must be because the player won...
        } else {
            //...so make it harder next time!
            level += 1
            movesAllowed -= 10
            //Quick note: The turns can never be lower than 20. This is because it takes a minimum 10 turns to flip every card. Therefore 20 is the lowest number that is still possible in the absolute worst luck provided the user can memorize every card.
            if (movesAllowed < 20){
                movesAllowed = 20
            }
        }
        //Return the amount of turns that will be in the next level that runs
        return movesAllowed
    }
    
    //Return the current level
    func getLevel() -> Int{
        return level
    }
    //Return the current amount of moves allowed
    func getMovesAllowed() -> Int{
        return movesAllowed
    }
    
    
}

//Handles a particular instance of the game (i.e. the current level and board)
class MatchBrain{
    
    //Defines the struct that will be in the 2D Array
    struct card{
        var emoji = ""
        var status = false
    }
    //Call an instance of SoundEffects which contains a sound for winning, losing and matching as well as a function to vibrate the device.
    var PlaySound:SoundEffects = SoundEffects()
    
    //Will hold the randomized emoji set
    var output: Array<String> = Array(repeating: "", count: 20)
    
    //Stores the actual board
    var cardValues2D: Array<Array<card>> = Array(repeating: Array(repeating: card(), count: 4), count: 5)
    
    //Stores the status of each card in terms of it was part of a completed match. When the size of this array is 20, all possible matches have been made. This is important later.
    var match = Array<Int>()
    
    //Stores if the current move is the first or second card flipped for each more
    var secondCard = false;
    
    //Stores the moved made and left at the current time
    var movesMade = 0;
    var movesLeft = 100;
    
    //Stores the last two cards flipped
    var lastTwo: (Int,Int) = (0,0)
    
    //Prepares the arrays. movesRemaining is called when creating an instance of this class to determine the difficulty of the game.
    init(movesRemaining: Int){
        
        //Set movesLeft to the value given accordingly
        movesLeft = movesRemaining
        
        //Create an array that will store ints from one to 20. This will be used later
        var locations: Array<Int> = Array(repeating: 0, count: 20)
        
        //Set the ten possible emoji
        let options = ["😀","🙃","🤔","🥶","🥺","😨","😤","😞","🤠","😎"]
        
        //Make an consecutive array of ints and shuffle it
        for n in 0...19{
            locations[n] = n
        }
        //Shuffle it so it isn't consecuitve anymore
        locations.shuffle()
        
        //Using that random order to arrange the emoji
        var i = 0
        for n in locations{
            output[n] = options[i]
            i = i + 1
            if (i >= 10)
            {
                i = 0
            }
        }
        
        //And load it into a 2D Array
        i = 0
        var nInt = 0
        var mInt = 0
        for n in cardValues2D{
            for _ in n{
                cardValues2D[nInt][mInt].emoji = output[i]
                i += 1
                mInt += 1
            }
            nInt += 1
            mInt = 0
        }
        
        
        
    }
    
    //Convert the int of a tag to the coordinates in the 2D Array
    func tagToCoordinates(tag:Int) -> (Int,Int){
        var a = 0
        var b = 0
        if (tag != 0)
        {
            for _ in 0...tag - 1 {
                b += 1
                if (b>3){
                    b = 0
                    a += 1
                }
                
            }
        }
        return (a,b)
    }
    
    //Return requests for an emoji of a specific card
    func getEmoji(tag:Int) -> String {
        //Convert tag into a location on the 2D array of emojis
        let coordinates = tagToCoordinates(tag: tag)
        let a = coordinates.0
        let b = coordinates.1
        //And gets the emoji there
        return cardValues2D[a][b].emoji
    }
    
    //When a card is flipped
    func updateCounter(card: Int) -> (Int, Int, Int, Bool, Bool){
        //Store variables for game events.
        var win = false //Game won
        var lose = false //Game lost
        var changed = 0 //Two cards that did not match were flipped
        //If this is the second card in the set to be flipped
        if (secondCard == true){
            //Set the second card spot to the current card
            lastTwo.1 = card
            //Toggle secondCard since the next onw will be the first card
            secondCard = false;
            //Update the counters for the moves made
            movesMade += 1
            movesLeft -= 1
            //If the last two cards matched
            //var test = IsMatch(tag1: lastTwo.0, tag2: lastTwo.1)
            if (IsMatch(tag1: lastTwo.0, tag2: lastTwo.1)){
                //Add them to the list of matched cards
                match.append(lastTwo.0)
                match.append(lastTwo.1)
                //Set the last two cards tapped to outside values to prevent cards outside of the set from matching with them
                lastTwo.0 = -1
                lastTwo.1 = -2
                //If there's now 20 matches in the set, all possible matches have been made, so the game is won
                if gameWon(){
                    //Vibrate the phone and play the win sound
                    PlaySound.vibrate()
                    PlaySound.YouWin()
                    //Note that the game has been won
                    win = true
                //If there has been a match but there was still a match, instead play the match sound
                } else {
                    PlaySound.Match()
                }
            //IFf they did not match set the last two cards tapped to outside values to prevent cards outside of the set from matching with them and note this so the viewController knows to flip them back
            } else {
                lastTwo.0 = -1
                lastTwo.1 = -2
                changed = 1
            }
        //If this was the first card
        } else {
            //Save that it was the first card
            lastTwo.0 = card
            //Toggle secondCard since the next card will be the first card
            secondCard = true;
        }
        //If there are no more moves and the user did not make the final match with the last move then the game is lost.
        if (movesLeft == 0 && !gameWon()){
            //Vibrate the phone and play the lose sound
            PlaySound.YouLose()
            PlaySound.vibrate()
            //Note that the game has been lost
            lose = true
        }
        //Return all this information to the viewController so it can update the screen accordingly
        return (movesMade, movesLeft, changed, win, lose)
    }
    
    //Checks if two cards match
    func IsMatch(tag1:Int, tag2:Int)-> Bool{
        return getEmoji(tag: tag1) == getEmoji(tag: tag2)
        
    }
    
    //Get the current status of a card in terms of if it has been flipped over
    func getStatus(card:Int) -> Bool {
        //Convert tag into a location on the 2D array of emojis
        let coordinates = tagToCoordinates(tag: card)
        let a = coordinates.0
        let b = coordinates.1
        //And gets the status there
        return cardValues2D[a][b].status
        //return cardStatus[card]
    }
    
    //Update the card to say it has beem flipped up
    func flipCardUp(card:Int){
        //Convert tag into a location on the 2D array of emojis
        let coordinates = tagToCoordinates(tag: card)
        let a = coordinates.0
        let b = coordinates.1
        //And gets the status there
        cardValues2D[a][b].status = true
        //cardStatus[card] = true
    }
    
    //Update the card to say it has beem flipped back down
    func flipCardDown(card:Int){
        //Convert tag into a location on the 2D array of emojis
        let coordinates = tagToCoordinates(tag: card)
        let a = coordinates.0
        let b = coordinates.1
        //And gets the status there
        cardValues2D[a][b].status = false
        //cardStatus[card] = false
    }
    
    //Return the cards that have been matched so far
    func getMatch() -> Array<Int>{
        return match
    }
    
    //Return if the last card flipped (the current card as far as the viewController is concerned) is the first of second of the two cards in a set
    func getTurnStatus() -> Bool{
        return secondCard
    }
    
    //Determines if the game is won
    func gameWon() -> Bool{
        return match.count == 20
    }
    
    //Return the board (used the the cheat)
    func getBoard() -> String{
        //Prepare a string
        var output:String = String()
        //For each row
        for array in cardValues2D{
            //For each emoji in that row
            for emoji in array{
                //Add the emoji to the string
                output += emoji.emoji + " "
            }
            //At the end of each row break the line
            output += "\n"
        }
        //Return a formatted string of the board
        return output
    }
    
}


//This class handles the sound effects. See source S2.
class SoundEffects{
    
    //Create a variable to play the sounds
    var soundPlayer = AVAudioPlayer()
    
    init(){
        
    }
    
    //The lose sound function loads the losing sound mp3 into the soundPlayer and plays it. If it fails nothing is done since failing to play a sound isn't game-breaking and will not require a recovery to keep the game running.
    func YouLose(){
        //Play Sound
        let GameOver = Bundle.main.path(forResource: "GameOver", ofType: "mp3")
        do{
        soundPlayer = try AVAudioPlayer(contentsOf: URL(fileURLWithPath: GameOver!))
        } catch {
            //Sound didn't play
        }
        soundPlayer.play()
    }
    
    //The win sound function loads the winning sound mp3 into the soundPlayer and plays it. If it fails nothing is done since failing to play a sound isn't game-breaking and will not require a recovery to keep the game running.
    func YouWin(){
        //Play Sound
        let YouWin = Bundle.main.path(forResource: "YouWin", ofType: "mp3")
        do{
        soundPlayer = try AVAudioPlayer(contentsOf: URL(fileURLWithPath: YouWin!))
        } catch {
            //Sound didn't play
        }
        soundPlayer.play()
    }
    
    //The match sound function loads the matching sound mp3 into the soundPlayer and plays it. If it fails nothing is done since failing to play a sound isn't game-breaking and will not require a recovery to keep the game running.
    func Match(){
        //Play Sound
        let GameOver = Bundle.main.path(forResource: "Match", ofType: "mp3")
        do{
        soundPlayer = try AVAudioPlayer(contentsOf: URL(fileURLWithPath: GameOver!))
        } catch {
            //Sound didn't play
        }
        soundPlayer.play()
    }
    
    //Vibrates the phone
    func vibrate(){
        AudioServicesPlayAlertSound(SystemSoundID(kSystemSoundID_Vibrate))
    }
    
}
