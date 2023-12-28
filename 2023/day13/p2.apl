 p2←{
     ⍝ input is 100 maps of max 17x17
     ls←(↑¨(⊃0≠∘⍴⊢)¨⊆⊢)⊃⎕NGET ⍵ 1
     reflect←{ ⍝ ⍺ is rows above reflection, ⍵ is matrix
         x←⍺⌊(⍺-⍨≢⍵) ⍝ rows after fold
         up←⍵⌷⍨⊂(⍺-x)+⍳x
         low←⍵⌷⍨⊂⍺+⍳x
         +⌿∊low≠⊖up ⍝ amount of differences
     }
     rnum←{ ⍝ try all rows
         m←⍵
         diffs←{⍵ reflect m}¨⍳(≢⍵)-1
         (1+≢diffs)|diffs⍳1
     }
     +⌿{(100×rnum ⍵)+rnum⍉⍵}¨ls
 }
