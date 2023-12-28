 p2←{
     ls←(' '∘(≠⊆⊢))¨⊃⎕NGET ⍵ 1
     hexa←{16⊥¯1+⍵⍳⍨⎕D,⎕A}∘(1∘⎕C)
     ps←{(⍎8⊃⍵)(hexa(⊂2+⍳5)⌷⍵)}∘(3⊃⊢)¨ls
     dirv←(0 1)(1 0)(0 ¯1)(¯1 0)
     pos←(⊂1 1){
         0=≢⍵:⍺
         d c←⊃⍵
         new←(⊃¯1↑⍺)+c×⊃dirv[d+1]
         (⍺,⊂new)∇ 1↓⍵
     }ps ⍝ 1st and last are =
     det←{
         a b←⍺ ⋄ c d←⍵
         (d×a)-(b×c)
     }
     area←0.5×-+/2 det/pos
     border←+/2{+/|⍺-⍵}/pos
     ⎕←⊆1 area(border×0.5)
     1+area+border×0.5
 }
