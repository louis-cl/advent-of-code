 p1←{
     in←('\w+'⎕S'&')¨⊃⎕NGET ⍵ 1
     vs←1500⌶,∪⊃,⌿in ⍝ input has 1550 vertices, 3464 edges
     vsi←{vs⍳⊂⍵}
     g←{⍵ ⍵⍴0}≢vs
     g[⊃,⌿{
         a←vsi⊃⍵
         {a ⍵}∘vsi¨1↓⍵
     }¨in]←1
     g←g∨⍉g ⍝ undirected
     ⍝ {⍺ (≢⍵)}⌸+⌿g ⍝ deg∊[4,9], 3 would be too easy
     bfs←{ ⍝ ⍺ graph
         start end←⍵ ⋄ g←⍺
         prev←(≢g)⍴0
         prev[start]←¯1
         _←{
             ∨⌿end=⍵:prev
             next←(prev=0)∧⍤1⊢g[⍵;]
             _←⍵({(⍵⌿prev)←⍺}⍤0 1)next
             ∇⍸∨⌿next
         },[0.5]start
         { ⍝ build path
             p←prev[⊃⍵]
             ¯1=p:⍵
             ∇ p,⍵
         }end
     }
     ⍝ find a path for all pairs
     pairs←↓{(≠/vals)⌿vals←?⍵ 2⍴≢g}500 ⍝ sample 500 pairs
     edges←⊃,⌿{2{⍺(⌊,⌈)⍵}/g bfs ⍵}¨pairs
     hist←{⍺(≢⍵)}⌸edges
     cut←⊃,⌿hist[3↑⍒hist[;2];1] ⍝ 3 most frequent edges
     g[cut,⊖¨cut]←0 ⍝ remove them
     u←⊃⊃cut ⍝ vertex in one side
     A←+⌿{ ⍝ parallel bfs
         in←(≢g)⍴0
         in[⍵]←1
         {⍵∨∨⌿⍵⌿g}⍣≡in
     }u
     A(A-⍨≢g) ⍝ wrong answer on sample, too small...
 }
