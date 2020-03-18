#include "fbgfx.bi" 

' Useful constants(makes your code easier to read and write).
const FALSE = 0
const TRUE = 1

DIM SHARED background1(64004) AS INTEGER ' An array that will hold the
                                         ' background image
DIM SHARED WarriorSprite(12, 404) AS INTEGER ' An array that will hold
                                             ' the warior sprites.

SCREEN 13,8,2,0 ' 13 means 320*200 graphics resolution; 8 means
                ' 8bit color depth; 2 means two work pages and
                ' 0 means window mode(1 would be full screen mode).
                ' When your program is running you can toggle
                ' between full screen/window mode with ALT+ENTER.
                
SETMOUSE 0,0,0  ' Hides the mouse cursor.

' Let's hide the work page since we are
' going to load program's graphics directly
' onto the screen. Page 1 is set as the
' work page and page 0 as the visible
' page. Everything you paste will be
' pasted on the work page(if you don't 
' specify otherwise) and won't be
' visible(copied to the visible page)
' until you use SCREENCOPY.
SCREENSET 1, 0

' Load the background image and store
' it in an array.
BLOAD "backgrnd.bmp", 0
GET (0,0)-(319,199), background1(0)

CLS ' Clear our screen since we
    ' are loading a new image(not
    ' neccesary but wise).

' Load the warrior sprites onto the screen and 
' store them into an array.
BLOAD "sprites.bmp", 0
FOR imagepos = 1 TO 12
GET (0+(imagepos-1)*24,0)-(19+(imagepos-1)*24,19),  WarriorSprite(imagepos, 0)
NEXT imagepos

' The 12 warrior sprites are saved as follows:
' WarriorSprite(1, 0) - warrior moving down image #1
' WarriorSprite(2, 0) - warrior moving down image #2
' WarriorSprite(3, 0) - warrior moving up image #1
' WarriorSprite(4, 0) - warrior moving up image #2
' WarriorSprite(5, 0) - warrior moving left image #1
' WarriorSprite(6, 0) - warrior moving left image #2
' WarriorSprite(7, 0) - warrior moving right image #1
' WarriorSprite(8, 0) - warrior moving right image #2
' WarriorSprite(9, 0) - warrior swinging up
' WarriorSprite(10, 0) - warrior swinging down
' WarriorSprite(11, 0) - warrior swinging left
' WarriorSprite(12, 0) - warrior swinging right

' Our user defined type containing 8 variables.
TYPE ObjectType
X          AS SINGLE
Y          AS SINGLE
Speed      AS SINGLE
Frame      AS INTEGER
Direction  AS INTEGER
Move       AS INTEGER
Attack     AS INTEGER
Alive      AS INTEGER
END TYPE

DIM SHARED Player AS ObjectType ' Our player.

' Warrior's(player's) initial
' position, speed(constant)
' and direction(1 = right).
Player.X = 150
Player.Y = 90
Player.Speed = 1
Player.Direction = 1

DO
    
' Player.Direction = 1 -> warrior moving right
' Player.Direction = 2 -> warrior moving left
' Player.Direction = 3 -> warrior moving down
' Player.Direction = 4 -> warrior moving up

Player.Move = FALSE ' By deafult player is not
                    ' moving.

' According to pushed key move the
' player and flag the proper direction.
IF MULTIKEY(SC_RIGHT) THEN 
Player.X = Player.X + Player.Speed
Player.Direction = 1
Player.Move = TRUE
END IF
IF MULTIKEY(SC_LEFT) THEN 
Player.X = Player.X - Player.Speed
Player.Direction = 2
Player.Move = TRUE
END IF
IF MULTIKEY(SC_DOWN) THEN 
Player.Y = Player.Y + Player.Speed
Player.Direction = 3
Player.Move = TRUE
END IF
IF MULTIKEY(SC_UP) THEN 
Player.Y = Player.Y - Player.Speed
Player.Direction = 4
Player.Move = TRUE
END IF

' The following 4 conditions prevent
' the warrior to walk off the screen.
IF Player.X < 0 THEN 
Player.Move = FALSE
Player.X = 0
END IF
IF Player.X > 300 THEN 
Player.Move = FALSE
Player.X = 300
END IF
IF Player.Y < 0 THEN 
Player.Move = FALSE
Player.Y = 0
END IF
IF Player.Y > 180 THEN 
Player.Move = FALSE
Player.Y = 180
END IF

' According to player's direction flag the 
' proper sprite.
IF Player.Direction = 1 THEN Player.Frame = 6 + Frame1
IF Player.Direction = 2 THEN Player.Frame = 4 + Frame1
IF Player.Direction = 3 THEN Player.Frame = 0 + Frame1
IF Player.Direction = 4 THEN Player.Frame = 2 + Frame1

' Frame1 changes from 1 to 2 or vice versa every
' 16 cycles(set with Frame2 variable).
Frame2 = (Frame2 MOD 16) + 1
IF Frame2 = 10 THEN Frame1 = (Frame1 MOD 2) + 1
IF Player.Move = FALSE OR Frame1 = 0 THEN Frame1 = 1

' Pastes the background.
PUT (0, 0), background1(0), PSET

' Pastes the warrior on Player.X and Player.Y coordinates, 
' using sprite number Player.Frame and skips background color(TRANS).
PUT (Player.X, Player.Y), WarriorSprite(Player.Frame, 0), TRANS

' Copy the work page(page 1) to the visible page(page 0).
SCREENCOPY
SCREENSYNC ' Wait for vertical blank(use always in all the game 
           ' game loops to get 85 FPS).
           
SLEEP 2    ' Statement used to prevent 100% CPU usage(prevents
           ' the program to use up all the computer cycles - useful
           ' and recommended).

LOOP UNTIL MULTIKEY(SC_Q) OR MULTIKEY(SC_ESCAPE) 
' Execute the loop until the user presses Q or ESCAPE.

END ' End program.