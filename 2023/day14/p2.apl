 p2←{ ⍝ input is 100x100
     map←↑⊃⎕NGET ⍵ 1 ⍝
     slide←{ ⍝ slide rocks to the right, ⍵ matrix
         r←'#'=⍵ ⋄ r[1]←1
         ,⌿{⍵['#.O'⍋⍵]}¨r⊂⍵
     }
     load←{ ⍝ ⍵ is a matrix
         +⌿⊢/¨⍸'O'=⍵ ⍝ load is column index
     }
     cycle←{⊃∘slide⍤1⊢⌽∘⍉⍵}⍣4 ⍝ (rot cw + slide)^4
     search←{ ⍝ brent's algorithm
         pow period←⍺ ⋄ slow fast←⍵
         slow≡fast:(pow-1)slow period ⍝ i (cycle^i map) period
         pow=period:(2×pow)1 ∇ fast(cycle fast)
         pow(1+period)∇ slow(cycle fast)
     }
     i m p←1 1 search map(cycle map)
     load⌽∘⍉cycle⍣(p|1000000000-i)⊢m
 }
