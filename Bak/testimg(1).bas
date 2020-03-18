Dim Shared img(0 To 2524) As Integer  'For testing
Screen 13

BLoad "JAZZA.BSV", @img(0)
Put (0,3),@img(0)

Sleep
End