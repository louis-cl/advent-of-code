 p1←{
     ⎕IO←0
     ⍝ x y z xx yy zz
     pos←↑('\d+'⎕S{⍎⍵.Match})¨⊃⎕NGET ⍵ 1
     pos←pos[⍋⌊/pos[;2 5];] ⍝ sort by smallest z first
     pos←{∊s[⍋s←2 3⍴⍵;]}⍤1⊢pos ⍝ sort left and right
     size←1+⌈⌿2 3⍴⌈⌿pos ⍝ input 10x10x300, sample 3x3x10
     pile←size⍴0
     range←{(⍺+⍳⍵-⍺),⍵} ⍝ ⍺ <= ⍵ both included
     _←{ ⍝ process each brick
         ⍵=≢pos:'done'
       ⍝ ⎕ ← 'falling' (⍵⌷pos)
         x y z xx yy zz←⍵⌷pos
         col←∨⌿∨⌿pile[x range xx;y range yy;]
         zi←(⊖∨\⊖col)⍳0
         z zz←(-z)+zi+z zz
         pos[⍵;]←x y z xx yy zz ⍝ update pos
         pile[x range xx;y range yy;z range zz]←⍵+1
         ∇(⍵+1)
     }0
     ⍝ remove each brick and see if anything falls
     0{
         ⍵=≢pos:⍺
         ⍝ ⎕ ← 'checking' (⍵+1) (⍵⌷pos)
         x y z xx yy zz←⍵⌷pos
         above←0~⍨∊∪pile[x range xx;y range yy;zz+1]
         ⍝ ⎕ ← 'it has above' above (≢above) (⍴above)
         0=≢above:(⍺+1)∇ ⍵+1 ⍝ why do i need this ?
         rem←∧⌿⍵{
             x y z xx yy zz←(⍵-1)⌷pos
             ~∧⌿∊pile[x range xx;y range yy;z-1]∊0(⍺+1)
         }¨above
         (⍺+rem)∇ ⍵+1
     }0
 }
