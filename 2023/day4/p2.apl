 p2←{
     ls←↑⊃⎕NGET ⍵ 1
     parse←{
         ns←2⊃':'(≠⊆⊢)⍵
         win my←⍎¨'|'(≠⊆⊢)ns
         win my
     }
     wins←{
         win my←⍵
         +/my∊win
     }
     ps←(wins∘parse⍤1)ls
     op←{ ⍝ 1 1 1 1 1 1 op 4 1 = 1 2 2 2 2 1
         c i←⍵
         (((i⌷⍺)+⊢)@(i+⍳c))⍺
     }
     rec←{
         ⍺←1⍴⍨≢⍵
         0=≢⍵:⍺
         r←⍺ op(1⌷⍵)
         r ∇(1↓⍵)
     }
     +/rec⍉↑ps(⍳≢ps)
 }
