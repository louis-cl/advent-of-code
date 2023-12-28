 p1←{
     img←'#'=↑⊃⎕NGET ⍵ 1
     exp←0=+/¨img(⍉img)
     dist←{
         i←(⍺⌊⍵)+(0,⍳)¨|⍺-⍵
         x←+⌿∊i({⍺⌷⊃⍵}⍤0)exp
         x++⌿|⍺-⍵
     }
     2÷⍨+⌿∊∘.dist⍨⍸img
 }
