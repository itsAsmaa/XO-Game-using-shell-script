# XO-Game-using-shell-script


## Overview
This script implements an interactive XO (Tic-Tac-Toe) game in the terminal with several additional features. Players can choose between a fresh game or loading a previously saved game. The game allows five types of moves and tracks the players' scores. The player with the highest score at the end of the game wins.

### Features:
- **Grid Customization**: Choose between a 3x3, 4x4, or 5x5 grid.
- **Multiple Move Types**: Players can place/remove marks, exchange rows/columns, and swap marks.
- **Score Tracking**: Players score points based on their moves.
- **File Loading**: Load a game grid from a file to continue playing a saved game.
  the game grid FORMAT should look like this the input xo doesnt mater also it can be any size :

  |X|O|X|
  
  |X|X|O|
  
  |O|X|O|

- **Game Restart/Exit**: Restart the game or quit after each session.

---

## Requirements:
- **Operating System**: Any Unix-based system (Linux/macOS) with support for bash scripting.
- **Shell**: Bash shell.

---

## Setup and Execution:
1. **Download the script**: Download the script `linux_p1.sh` to your machine.
2. **Make the script executable**:
   ```bash
   chmod +x linux_p1.sh
