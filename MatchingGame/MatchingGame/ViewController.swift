//
//  ViewController.swift
//  MatchingGame
//
//  Created by Mark Kornfeld on 4/8/20.
//  Copyright © 2020 Mark Kornfeld. All rights reserved.
//

//Sources:

//S1: Magnifying glass image used to make the icon: https://upload.wikimedia.org/wikipedia/commons/3/3a/Magnifying_glass_01.svg

//S2: Adding sounds:
//https://codewithchris.com/avaudioplayer-tutorial/

//S3: Code to detect shaking comes from:
//https://stackoverflow.com/questions/33503531/detect-shake-gesture-ios-swift

import UIKit
import AVFoundation

class ViewController: UIViewController {


    
    //Calls an instance of MatchBrain
    //MatchBrain is the model. It handles the logic.
    //The parameter controls the difficulty. This will matter later.
    var Brain:MatchBrain = MatchBrain(movesRemaining: 100)
    
    //Calls an instance of GameManager
    //While MatchBrain handles once instance of the game, GameMansget handles the "big picture" (i.e. which leve you are on)
    var Game:GameManager = GameManager()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.becomeFirstResponder() // To get shake gesture See Source S3
        // Do any additional setup after loading the view.
    }
    
    //Allows the phone to detect shaking. See Source S3
    override var canBecomeFirstResponder: Bool {
        get {
            return true
        }
    }
    
    //Asks the user if they want the answers when the device is shaken. See source S3.
    override func motionEnded(_ motion: UIEvent.EventSubtype, with event: UIEvent?) {
        if motion == .motionShake {
            //Actionsheet will be used to ask question
            let alert = UIAlertController(title: "Show Answers", message: "Do you want to see the answers?", preferredStyle: .actionSheet)
            
            //If the user says no then close the dialog
            alert.addAction(UIAlertAction(title: "Return to Game", style: .cancel, handler: nil))
            
            //If the user says yes call that function that shows them
            alert.addAction(UIAlertAction(title: "Show Answers", style: .destructive, handler: { action in
                self.showAnswers()
            }))
            //Ask the question
            self.present(alert, animated: true)
        }
        
    }
    
    //Outlets for the two labels at the top
    @IBOutlet weak var lblMovesLeft: UILabel!
    @IBOutlet weak var lblMovesMade: UILabel!
    
    //Stores the last cards to be flipped
    var lastCard = (UIButton(), UIButton())
    //Stores if cards need to be flipped back on the next tap
    var flipBack:Bool = false;
    //Stores the level a user is on
    var level = 1
    
    
    //When the user taps a card
    @IBAction func btnClick(_ sender: UIButton) {
        //Check if it's already been matched
        var match = Brain.getMatch()
        
        //If it hasn't been matched
        if !(match.contains(sender.tag))
        {
            //Prepare to flip the card over
            var newLabel: String
            var image:UIImage
            
            if let label = sender.titleLabel!.text{
                newLabel = label
            }else{
                newLabel = ""
            }
            
            //If the card is already flipped
            if Brain.getStatus(card: sender.tag)
            {
                //If the cards are supposed to be flipped (i.e. there's already two flipped and you tap another (or the same card in this case) flip them over
                if (flipBack == true){
                    flipCardBack(item: lastCard.0)
                    flipCardBack(item: lastCard.1)
                    flipBack = false
                }
                //Otherwise do nothing since the card is already flipped
            
            //If the card is not already flipped
            } else {
                //If the cards are supposed to be flipped (i.e. there's already two flipped and you tap another flip them over
                if (flipBack == true){
                    flipCardBack(item: lastCard.0)
                    flipCardBack(item: lastCard.1)
                    flipBack = false
                }
                //If not then flip it over
                image = UIImage()
                newLabel = Brain.getEmoji(tag: sender.tag)
                sender.setTitle(newLabel, for: .normal)
                sender.setBackgroundImage(image, for: .normal)
                //Tell the Brain it's been flipped
                Brain.flipCardUp(card: sender.tag)
                //Have the brain determine what happens by sending the following five flags:
                //0: movesMade:Int -> Used to update label
                //1: movesLeft:Int ->Used to update other label
                //2: changed:Int -> 1/0 determines if two cards were flipped that don't match
                //3: win:Bool -> was the game won?
                //4: lose:Bool -> is the player out of turns?
                let moves = Brain.updateCounter(card: sender.tag)
                //Update the labels
                lblMovesMade.text = String(moves.0)
                lblMovesLeft.text = String(moves.1)
                //If two cards are flipped and don't match flag that next time they need to be switched bacl
                if (moves.2 == 1){
                    //Reset card matches to avoid matching cards from different turns
                    lastCard.1 = lastCard.0
                    flipBack = true
                }
                //Check if the two cards match (if there are not two this will always return false
                match = Brain.getMatch()
                //If all matches are made, the user won. Tell the user and run the reset function
                if moves.3 == true{
                    let alert = UIAlertController(title: "You Win 😎", message: "Congratulations, you won in " + String(moves.0) + " turns!", preferredStyle: .alert)
                    alert.addAction(UIAlertAction(title: "Move on to level " + String(Game.getLevel() + 1) + "!", style: .default, handler: { action in
                        self.reset(win: true)
                    }))
                    self.present(alert, animated: true)
                }
                //Save the card that was tapped as the last card tapped
                lastCard.0 = sender
                
                //If out of turns and the player didn't win, tell the user and run the reset function
                if moves.4 == true{
                    let alert = UIAlertController(title: "You Lose 😞", message: "You were on level " + String(Game.getLevel()), preferredStyle: .alert)
                    alert.addAction(UIAlertAction(title: "Play again", style: .default, handler: { action in
                        self.reset(win: false)
                    }))
                    self.present(alert, animated: true)
                }
            }
            
            
        }
    }
    
    //Function to flip a card back and update the brain
    func flipCardBack(item:UIButton){
        var image:UIImage
        var newLabel: String
        image = (UIImage(named: "Card") as UIImage?)!
        newLabel = ""
        Brain.flipCardDown(card: item.tag)
        item.setTitle(newLabel, for: .normal)
        item.setBackgroundImage(image, for: .normal)
    }
    
    //If the player either won or lost
    func reset(win:Bool){
        //flip all cards back
        for view in self.view.subviews as [UIView] {
            if let btn = view as? UIButton {
                flipCardBack(item: btn)
            }
        }
        let movesAllowed = Game.reset(win: win)
        //Reset screen
        lblMovesMade.text = "0"
        lblMovesLeft.text = String(movesAllowed)
        
        //Reset brain and restart the game with the new settings
        Brain = MatchBrain(movesRemaining: movesAllowed)
    }
    
    //The answers function the runs if the user shakes the device and opts to see the answers
    func showAnswers(){
        //Get the answers from the brain
        let board = Brain.getBoard()
        //Tell the user what they are (the brain does all the formatting work
        let alert = UIAlertController(title: "Here's the board 🤫", message: "\n" + board + "\n", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Got it", style: .default, handler: nil))
        self.present(alert, animated: true)
    }
    

}

