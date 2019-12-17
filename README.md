# MineSweeper.love
Small implementation of Mine Sweeper in the LOVE2D engine.

## How to Play
[Wikipedia](https://en.wikipedia.org/wiki/Minesweeper_(video_game)): "Minesweeper is a single-player puzzle computer game. The objective of the game is to clear a rectangular board containing hidden "mines" or bombs without detonating any of them, with help from clues about the number of neighboring mines in each field. The game originates from the 1960s, and has been written for many computing platforms in use today. It has many variations and offshoots."

 - Left click: reveal tile.
 - Right click: flag an unrevealed tile.
 - Middle mouse button: reveal all unflagged tiles surrounding a hint tile with enough flags around it to satisfy the number presented.

## Details
It's a very simple one-file implementation, no sound nor sprites nor anything.

Mantains an array for the mine locations themselves, one for the revealed locations, one for the hints and one for the flags.

## Releases
.love and .exe files are available in the Release tab.

## Building the Game
You can follow the instructions over at https://love2d.org/wiki/Game_Distribution to build the game for your preferred platform.
