 p1←{ ⍝ input is 100x100
     map←↑⊃⎕NGET ⍵ 1 ⍝
     slide←{ ⍝ slide rocks to the right, ⍵ matrix
         r←'#'=⍵ ⋄ r[1]←1
         ,⌿{⍵['#.O'⍋⍵]}¨r⊂⍵
     }
     load←{ ⍝ ⍵ is a matrix
         +⌿⊢/¨⍸'O'=⍵ ⍝ load of rock is column index
     }
     load⊃∘slide⍤1⊢⌽∘⍉map ⍝  rotate cw then slide
 }
