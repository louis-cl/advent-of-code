 p2←{
     ls←⊃⎕NGET ⍵ 1
     seeds←⍎¨1↓' '(≠⊆⊢)⊃ls
     maps←↑¨⍎¨¨{(0≠≢¨⍵)/⍵}¨1↓ls⊆⍨~':'∊¨ls
     rs←(2÷⍨≢seeds)2⍴seeds
     rs[;2]+←¯1+rs[;1]  ⍝ nx2 ranges [min,max]
     mapr←{
         s←⍵
         s[;3]+←¯1+s[;2]
         (⊂⍋s[;2])⌷s
     }¨maps ⍝ each map is dest sourceMin sourceMax sorted inc
     rxs←{ ⍝ m rxs r1 r2 = ranges mapped via m for r1 r2
         ⍺{
             (l r)acc←⍵
             0=≢⍺:acc,(⊂l r)
             b l2 r2←1⌷⍺
             bt←(b-l2)+⊢ ⍝ shift
             l<l2:⍺ ∇(l2 r)(acc,(⊂l(l2-1)))
             l>r2:(1↓⍺)∇(l r)acc
             r≤r2:acc,(⊂(bt l r))
             (1↓⍺)∇((1+r2)r)(acc,(⊂(bt l r2)))
         }⊆⍵ ⍬
     }
     r←rs{ ⍝ apply rxs for all ranges and all maps
         0=≢⍵:⍺
         (1↓⍵)∇⍨↑⊃,/(⊂(⊃⍵)∘rxs)⍤1⊢⍺
     }mapr
     ⌊⌿r[;1] ⍝ min over range starts
 }
