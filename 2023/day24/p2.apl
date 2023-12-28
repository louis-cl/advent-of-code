 p2←{
     in←3↑↑⍎∘('[@,]'⎕R'')∘('-'⎕R'¯')¨⊃⎕NGET ⍵ 1
     x1 v1 x2 v2 x3 v3←{⍉,[0.5]⍵}¨↓6 3⍴in
     crossM←{ ⍝ (crossM a) b = a x b
         x y z←∊⍵
         3 3⍴0(-z)y z 0(-x)(-y)x 0
     }
     mul←(+.×)
     cx1 cx2 cx3 cv1 cv2 cv3←crossM¨x1 x2 x3 v1 v2 v3
     b←{(⍵-cx2 mul v2)⍪(⍵-cx3 mul v3)}(cx1 mul v1)
     A←((cv2-cv1),(cx1-cx2))⍪(cv3-cv1),(cx1-cx3)
     +⌿3↑(⌹A)mul b
     ⍝ 843888100572888 (run a few times with different sets)
 }
