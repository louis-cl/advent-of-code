 p1←{
     m←↑⊃⎕NGET ⍵ 1
     next←{
         '#'=⍵[2;2]:'#'
         neighbor←∨⌿'S'=⍵[(1 2)(2 1)(2 3)(3 2)]
         (1+neighbor)⌷'.S'
     }
     op←(next⌺3 3)
     +⌿∊'S'=op⍣⍺⊢m
     ⍝ 64 p1 'input' = 3751
 }
