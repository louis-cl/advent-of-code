 p1←{
     ls←⊃⎕NGET ⍵ 1
     seeds←⍎¨1↓' '(≠⊆⊢)⊃ls
     maps←↑¨⍎¨¨{(0≠≢¨⍵)/⍵}¨1↓ls⊆⍨~':'∊¨ls
     m1←⊃maps
     f←{
         diff←⍵(-⍤0 1)⍺[;2]
         match←(diff≥0)∧⍺[;3](>⍤1)diff
         where←∨/match ⍝ which seeds are mapped
         repl←,where⌿match(/⍤1)diff(+⍤1)⍺[;1]
         (repl@{where})⍵
     }
     ⌊/maps{
         0=≢⍺:⍵
         (1↓⍺)∇(⊃⍺)f ⍵
     }seeds
 }
