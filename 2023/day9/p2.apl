 p2←{
     ls←⍎∘('-'⎕R'¯')¨⊃⎕NGET ⍵ 1
     +⌿-⌿¨{ ⍝ is acc of first values, ⍵ is arr
         ⍺←⍬
         ∧/0=⍵:⍺
         (⍺,⊃⍵)∇ 2-⍨/⍵
     }¨ls
 }
