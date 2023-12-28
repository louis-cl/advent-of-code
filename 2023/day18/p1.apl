 p1←{
     ls←{(⊃⍵)(⍎2⊃⍵)}¨(' '∘(≠⊆⊢))¨⊃⎕NGET ⍵ 1
     dirv←(0 1)(1 0)(0 ¯1)(¯1 0)
     dir←{⊃dirv['RDLU'⍳⍵]}
     pos←(⊂1 1){
         0=≢⍵:⍺
         d c←⊃⍵
         new←(⊃¯1↑⍺)+(dir d)×c
         (⍺,⊂new)∇ 1↓⍵
     }ls ⍝ 1st and last are =
     det←{
         a b←⍺ ⋄ c d←⍵
         (d×a)-(b×c)
     }
     area←0.5×-+/2 det/pos
     border←+/2{+/|⍺-⍵}/pos
     ⎕←⊆1 area(border×0.5)
     1+area+border×0.5
 }
