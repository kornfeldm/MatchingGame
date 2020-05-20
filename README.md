# MatchingGame
A simple card matching game designed for iPhones running iOS 13 and iPads running iPadOS 13

### What is MatchingGame?

MatchingGame is simple iOS/iPadOS game built using Xcode 11.4 for a mobile application development course (CSC184). It serves as an example Xcode project as well and demonstrates a use of the Model View Controller (MVC) architecture. 

### Features
* Flip two cards by tapping on them:
  * If the cards match, they remain flipped over
  * If the cards do not match, they automatically flip back after tapping another card
* Sound effects:
  * A match is made
  * The game is won
  * The game is lost
  * Note: Sound effects do not play when the device is silenced
* Levels:
  * To begin, the user has 100 turns
  * When the game is won, it proceeds to the next level. Each level has ten less turns than the previous
  * When the game is lost, it reverts to level one and returns to 100 turns
* Cheating:
  * Cheating is not the way to play but if the user so chooses, answers can be revealed by shaking the device
  
###How can I try editing the code?
This project is built using Xcode. Xcode only runs on Mac computers but can be downloaded for free from the Mac App Store. To edit the code, simply download this project and open "MatchingGame.xcodeproj" in Xcode.
