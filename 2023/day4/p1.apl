 p1←{
     ls←↑⊃⎕NGET ⍵ 1
     parse←{
         ns←2⊃':'(≠⊆⊢)⍵
         win my←⍎¨'|'(≠⊆⊢)ns
         win my
     }
     points←{
         win my←⍵
         c←+/my∊win
         0=c:0
         2*¯1+c
     }
     +/(points∘parse⍤1)ls
 }
