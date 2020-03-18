#Include "fbgfx.bi" 

Dim Gravity As Single
Gravity = .5
dim as integer mx,my,mb
dim as uinteger r,b,g,p
dim as uinteger r2,b2,g2,p2
Dim x As Double
Dim y As Double
Dim c As Integer
Dim ct As Integer
Dim Shared ldt(64000) As Integer
Dim CX_Pos As Short
Dim CY_Pos As Short
Dim Ingame As UByte
DIM CurrSng AS Integer
Dim Shared SOpt As UByte
Dim Shared introcval As Integer
Dim Shared SR1 As Integer
Dim Shared SR2 As Integer
Dim Shared SR3 As Integer
Dim Shared SR4 As Integer
Dim Shared img(0 To 256000) As Integer
Dim Shared Level(38,260) As Integer 'Level tiles
Dim Shared LevelMask(38,260) As Integer 'Level tile masks
Dim Shared Jazza(8,315) As Integer  'For testing, will eventually be for player
Dim Shared logo(12748) As Integer  'Logo image
Dim imagepos As Integer
Dim Frame1 As Integer
Dim Frame2 As Integer
Type ObjectType
X          AS SINGLE
Y          AS Single
Speed As Single
Frame      AS INTEGER
Direction  AS INTEGER
Move       AS Integer
Jump As INTEGER
Attack     AS INTEGER
Alive      AS Integer
Y_Velocity As Single
End Type

Dim Shared Player AS ObjectType

ScreenRes 640, 480, 15, 4, 0
SetMouse 0,0,0 ' Hides the mouse cursor
WindowTitle "kill me"

'Intro beggining
For introcval = 1 To 255
Locate 30,28
Color RGB(introcval,introcval,introcval)
Print "Created by Alexander Merchan"
Sleep 4
Next
Sleep 1500
Do Until introcval = 0
	introcval = introcval - 1
	Locate 30,28
	Color RGB(introcval,introcval,introcval)
	Print "Created by Alexander Merchan"
	Sleep 4
Loop
Sleep 1000
'going to menu
ScreenSet 1, 0
BLoad "rkmlogo.bmp", @img(0)
Put (0,0), @img(0)
Get (0,0)-(233,53), logo(0)
Cls
Color RGB(255,255,255)

Do Until MULTIKEY(FB.SC_ESCAPE) Or Ingame = 1
	'mainmenu
	PUT (200, 50), logo(0), Trans
	If MULTIKEY(FB.SC_UP) Then
		SOpt = SOpt - 1
	EndIf
	If MULTIKEY(FB.SC_DOWN) Then
		SOpt = SOpt + 1
	EndIf
	Locate 25,28
	If SOpt = 0 Then Color RGB(255,0,0) Else Color RGB(255,255,255)
	Print "Start a game"
	Locate 30,28
	If SOpt = 1 Then Color RGB(255,0,0) Else Color RGB(255,255,255)
	Print "Join a game"
	Locate 35,28
	If SOpt = 2 Then Color RGB(255,0,0) Else Color RGB(255,255,255)
	Print "Friends (WIP)"
	Locate 40,28
	If SOpt = 3 Then Color RGB(255,0,0) Else Color RGB(255,255,255)
	Print "Settings"
	Locate 45,28
	If SOpt = 4 Then Color RGB(255,0,0) Else Color RGB(255,255,255)
	Print "Quit"
	If SOpt > 4 Then SOpt = 0
	'startgame menu
	If SOpt = 0 And MULTIKEY(FB.SC_ENTER) Then
		Cls
		ScreenCopy 1, 0
		Do Until MULTIKEY(FB.SC_ESCAPE) Or Ingame = 1
			Locate 30,28
			Print "Temporary menu, press P to enter game"
			If MULTIKEY(FB.SC_P) Then Ingame = 1
			ScreenCopy 1,0
		Loop
	EndIf
	ScreenCopy 1, 0
	Sleep 640
Loop


Cls
' Giant f*cking loading routine (i need to optimize my shit)
BLoad "Chars/Jazza/jazza.bmp", @img(0)
Put (0,0), @img(0)
Open "Chars/Jazza/Attribs.txt" For Input As #1
Input #1, SR1
Input #1, SR2
Input #1, SR3
Input #1, SR4
GET (SR1,SR2)-(SR3,SR4), Jazza(1, 0)
Input #1, SR1
Input #1, SR2
Input #1, SR3
Input #1, SR4
GET (SR1,SR2)-(SR3,SR4), Jazza(2, 0)
Input #1, SR1
Input #1, SR2
Input #1, SR3
Input #1, SR4
GET (SR1,SR2)-(SR3,SR4), Jazza(3, 0)
Input #1, SR1
Input #1, SR2
Input #1, SR3
Input #1, SR4
GET (SR1,SR2)-(SR3,SR4), Jazza(4, 0)
Input #1, SR1
Input #1, SR2
Input #1, SR3
Input #1, SR4
GET (SR1,SR2)-(SR3,SR4), Jazza(5, 0)
Input #1, SR1
Input #1, SR2
Input #1, SR3
Input #1, SR4
GET (SR1,SR2)-(SR3,SR4), Jazza(6, 0)
Input #1, SR1
Input #1, SR2
Input #1, SR3
Input #1, SR4
GET (SR1,SR2)-(SR3,SR4), Jazza(7, 0)
Input #1, SR1
Input #1, SR2
Input #1, SR3
Input #1, SR4
GET (SR1,SR2)-(SR3,SR4), Jazza(8, 0)
Input #1, SR1
Close #1
' End of giant f*cking loading routine


Player.X = 320
Player.Y = 240
Player.Speed = SR1
Player.Direction = 1
Player.Frame = 1
CX_Pos = -40
CY_Pos = -480

Cls

BLoad "Maps/Debug/debugtiles.bmp", @img(0)
Put (0,0), @img(0)
x = 0
Do Until x = 15
	GET (x*16,0)-((x*16)+15,15), Level(x+1, 0)
	x = x + 1
Loop

CLS

x = 0
y = 0
c = 0

BLoad "Maps/Debug/debugmask.bmp", @img(0)
Put (0,0), @img(0)
x = 0
Do Until x = 15
	GET (x*16,0)-((x*16)+15,15), LevelMask(x+1, 0)
	x = x + 1
Loop

CLS

x = 0
y = 0
c = 0

ScreenSet 1, 1
Open "Maps/Debug/tilemap.txt" For Input As #1
Do Until Eof(1)
	Input #1, ct
	ldt(c) = ct
	c = c + 1
Loop
Close #1


'Get (0,0)-(320,240), TileArQ1(0)
'Get (320,240)-(240,240), TileArQ2(0)
Cls
ScreenSet 1, 0
Open "Maps/Debug/tilemap.txt" For Input As #1
Do Until Eof(1)
	Input #1, ct
	ldt(c) = ct
	c = c + 1
Loop
Close #1
Do
c = 0
x = 0
y = 0
ScreenSet 3, 0
Cls
ScreenSet 2, 0
Cls
c = 0
Do Until y = 65
	If ldt(c) <> 0 Then
		ScreenSet 3, 0
		Put ((x*16)+CX_Pos,(y*16)+CY_Pos), LevelMask(ldt(c), 0), PSet
		ScreenSet 2, 0
		Put ((x*16)+CX_Pos,(y*16)+CY_Pos), Level(ldt(c), 0), Trans
	End If
	If x = 96 Then
		x = 0
		y = y + 1
	Else
		x = x + 1
	EndIf
	c = c + 1
Loop
ScreenSet 1, 0
ScreenCopy 2, 1
Player.Move = FALSE ' By deafult player is not
                    ' moving.

' According to pushed key move the
' player and flag the proper direction.
IF MULTIKEY(FB.SC_RIGHT) THEN 
CX_Pos = CX_Pos - Player.Speed
Player.Direction = 1
Player.Move = TRUE
END IF
IF MULTIKEY(FB.SC_LEFT) THEN 
CX_Pos = CX_Pos + Player.Speed
Player.Direction = 2
Player.Move = TRUE
END If

IF Player.Direction = 1 THEN Player.Frame = 0 + Frame1
IF Player.Direction = 2 THEN Player.Frame = 4 + Frame1

Frame2 = (Frame2 MOD 16) + 1
IF Frame2 = 10 THEN Frame1 = (Frame1 MOD 2) + 1
IF Player.Move = FALSE OR Frame1 = 0 THEN Frame1 = 1

If MultiKey(FB.SC_LSHIFT) Then
	Player.Speed = 5
Else
	Player.Speed = 3
EndIf

If MultiKey(FB.SC_UP) And Player.Jump = FALSE Then
	Player.Y_Velocity = -6
	Player.Jump = TRUE
EndIf

CY_Pos = CY_Pos - Player.Y_Velocity
If Player.Y_Velocity >= 8 Then Player.Y_Velocity = 8.5

'collision

ScreenSet 3, 0
'floor collision a
p = point(Player.X, Player.Y + 24)
r = p shr 16 and 255
g = p shr 8 and 255
b = p and 255
If r+g+b = 765 Then
	Player.Y_Velocity = 0
	Player.Jump = FALSE
Else
	Player.Y_Velocity = Player.Y_Velocity + Gravity
EndIf

'floor collision b
p = point(Player.X-15, Player.Y - 17)
r = p shr 16 and 255
g = p shr 8 and 255
b = p and 255
p2 = point(Player.X-15, Player.Y - 16)
r2 = p shr 16 and 255
g2 = p shr 8 and 255
b2 = p and 255
If r+g+b+r2+g2+b2 = 765 And Player.Move = TRUE Then
	Player.Y_Velocity = +Player.Speed
	Player.Jump = FALSE
EndIf

'right wall collision
p = point(Player.X+15, Player.Y+8)
r = p shr 16 and 255
g = p shr 8 and 255
b = p and 255

If r+g+b= 765 Then
	CX_Pos = CX_Pos + Player.Speed
EndIf

'left wall collision
p = point(Player.X-1, Player.Y+8)
r = p shr 16 and 255
g = p shr 8 and 255
b = p and 255

If r+g+b= 765 Then
	CX_Pos = CX_Pos - Player.Speed
EndIf

ScreenSet 1, 0
Locate 1, 1
Print r+g+b
Locate 1, 5
Print r2+g2+b2

Locate 3, 1
Print CX_Pos
Locate 3, 5
Print CY_Pos

Locate 5, 5
Print &H3DA

Locate 5, 1
Print Player.Y_Velocity

If Player.Jump = TRUE Then
	If Player.Direction = 1 Then
		Player.Frame = 4
	Else
		Player.Frame = 8
	EndIf
EndIf
' Pastes the background.
'PUT (CX_Pos,CY_Pos), TileArQ1(0), Trans
'PUT (CX_Pos+320,CY_Pos), TileArQ2(0), Trans
'PUT (CX_Pos,CY_Pos+240), TileArQ3(0), Trans
'PUT (CX_Pos+320,CY_Pos+240), TileArQ4(0), Trans

' Pastes the warrior on Player.X and Player.Y coordinates, 
' using sprite number Player.Frame and skip background color.
PUT (Player.X, Player.Y), Jazza(Player.Frame, 0), Trans
ScreenCopy 1, 0
ScreenSync
CLS
Loop UNTIL MULTIKEY(FB.SC_Q) Or MULTIKEY(FB.SC_ESCAPE)

End