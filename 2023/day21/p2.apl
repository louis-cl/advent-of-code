 p2←{
     m←↑⊃⎕NGET ⍵ 1
     next←{
         '#'=⍵[2;2]:'#'
         neighbor←∨⌿'S'=⍵[(1 2)(2 1)(2 3)(3 2)]
         (1+neighbor)⌷'.S'
     }
     op←(next⌺3 3)
     count←{+⌿∊'S'=⍵}
     m64←op⍣64⊢m ⋄ m65←op m64
     c64 c65←(count m64)(count m65)
     full←{
         one←op ⍵
         {
             ce e co o←⍵
             ne←op o ⋄ no←op ne
             nce←count ne ⋄ nco←count no
             (nce=ce)∧(nco=co):ce co
             ∇ nce ne nco no
         }1 ⍵(count one)one
     }
     even odd←full m
     n←202300
     ((n+1)×odd-c65)-⍨(odd×(n+1)*2)+(even×n*2)+n×even-c64
 }
