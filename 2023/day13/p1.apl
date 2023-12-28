 p1←{
     ⍝ input is 100 maps of max 17x17
     ls←(↑¨(⊃0≠∘⍴⊢)¨⊆⊢)⊃⎕NGET ⍵ 1
     reflect←{ ⍝ ⍺ is rows above reflection, ⍵ is matrix
         x←⍺⌊(⍺-⍨≢⍵) ⍝ rows after fold
         up←⍵⌷⍨⊂(⍺-x)+⍳x
         low←⍵⌷⍨⊂⍺+⍳x
       ⍝⊆ x up low ((⍺-x)+⍳x) (⍺+⍳x)
         low≡⊖up
     }
     rnum←{ ⍝ try all rows
         m←⍵
         ⊃⍸{⍵ reflect m}¨⍳(≢⍵)-1
     }
     +⌿{(100×rnum ⍵)+rnum⍉⍵}¨ls
 }
