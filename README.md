# MatchingGame
A simple card matching game designed for iPhones running iOS 13 and iPads running iPadOS 13

### What is MatchingGame?

MatchingGame is simple iOS/iPadOS game built using Xcode 11.4 for a mobile application development course (CSC184). It serves as an example Xcode project as well as a demonstration of the Model View Controller (MVC) architecture pattern. 

### Features
* Cards are randomly placed for each level
* Flip two cards by tapping on them:
  * If the cards match, they remain flipped over
  * If the cards do not match, they automatically flip back after tapping them once more or tapping another card
* Sound effects
  * Sounds play when: 
    * A match is made
    * The game is won
    * The game is lost
  * Note: Sound effects do not play when the device is silenced
* Levels
  * To begin, the user has 100 turns
  * When the game is won, the user proceeds to the next level; each level has ten less turns than the previous
    * The user will always have at least 20 turns regardless of the current level
  * When the game is lost, the user reverts to level one and is once again offered 100 turns
* Cheating
  * Cheating is not recommended the way to play but if the user so chooses, answers can be revealed by shaking the device
  
### How can I try editing the code?
This project is built using Xcode. Xcode only runs on Mac computers but can be downloaded for free from the Mac App Store using a compatible machine. To edit the code, simply download this project and open "MatchingGame.xcodeproj" in Xcode. This will load in the project. When testing the code, an iPad or iPhone simulator will work, but physical devices offer a better experience.

### How is this MatchingGame licensed?
This project is licensed under the GNU GPLv3 agreement. The full agreement can be read here: (https://www.gnu.org/licenses/gpl-3.0.en.html)

### How was MatchingGame Made?
MatchingGame was built using Xcode 11.4 and the following sources were referenced in the making of this project:
* Magnifying glass image used to make the icon
  * https://upload.wikimedia.org/wikipedia/commons/3/3a/Magnifying_glass_01.svg
* Add sounds to a project
  * https://codewithchris.com/avaudioplayer-tutorial/
* Detect shaking of the device
  * https://stackoverflow.com/questions/33503531/detect-shake-gesture-ios-swift
* Class notes and assignments from CSC184
