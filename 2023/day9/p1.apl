 p1←{
     ls←(⊖⍎)∘('-'⎕R'¯')¨⊃⎕NGET ⍵ 1
     +/{ ⍝ ⍺ is acc of last values, ⍵ is arr
         ⍺←0
         ∧/0=⍵:⍺
         (⍺+⊃⍵)∇ 2-/⍵
     }¨ls
 }
