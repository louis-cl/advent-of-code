 p1v2←{
     ⎕IO←0
     ⍝ x y z xx yy zz
     pos←↑('\d+'⎕S{⍎⍵.Match})¨⊃⎕NGET ⍵ 1
     pos←pos[⍋⌊/pos[;2 5];] ⍝ sort by smallest z first
     pos←{∊s[⍋s←2 3⍴⍵;]}⍤1⊢pos ⍝ smallest left
     ⍝ size←1+⌈⌿2 3⍴⌈⌿pos ⍝ input 10x10x300, sample 3x3x10
     ⍝ pile←size⍴0
     range←{(⍺+⍳⍵-⍺),⍵} ⍝ ⍺ <= ⍵ both included
     fall←{ ⍝ ⍵ is z-sorted  x y z xx yy zz
         h←(1+2↑⌈⌿2 3⍴⌈⌿⍵)⍴0 ⍝ height x y default to 0
         pos2←⍵
         c←0{ ⍝ ⍺ fall count, ⍵ brick
             ⍵=≢pos2:⍺
             x y z xx yy zz←pos2[⍵;]
             zt←1+⌈⌿∊h[x range xx;y range yy]
             h[x range xx;y range yy]←zt+(zz-z)
             pos2[⍵;]←x y zt xx yy(zt+(zz-z))
             (⍺+zt<z)∇ ⍵+1
         }0
         pos2 c
     }
     pos _←fall pos ⍝ drop all
     cs←{1⊃fall(⍵≠⍳≢pos)⌿pos}¨⍳≢pos ⍝ drop removing one
     (+⌿cs=0)(+⌿cs) ⍝ p1 p2
 }
