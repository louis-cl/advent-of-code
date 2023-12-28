 p1←{ ⍝ input 110x110
     map←↑⊃⎕NGET ⍵ 1
     mv mh mf mb me←map∘=¨'|-/\.'
    ⍝ ⊆ mv mh mf mb
     r l d u←4(⍴∘⊂)0⍴⍨⍴map ⍝ > < v ^
     r[1;1]←1 ⍝ start top-left >
     print←{
         r l d u←⍵
         p←map
         p[⍸r]←'>'
         p[⍸l]←'<'
         p[⍸d]←'v'
         p[⍸u]←'^'
         p
     }
     move←{
         r l d u←⍵
         rr←0,¯1↓[2](d∧mh∨mb)∨(r∧mh∨me)∨(u∧mh∨mf)
         uu←0⍪⍨1↓(r∧mf∨mv)∨(u∧me∨mv)∨(l∧mv∨mb)
         dd←0⍪¯1↓(d∧me∨mv)∨(r∧mb∨mv)∨(l∧mv∨mf)
         ll←0,⍨1↓[2](d∧mh∨mf)∨(l∧me∨mh)∨(u∧mh∨mb)
         (r∨rr)(l∨ll)(d∨dd)(u∨uu)
     }
    ⍝ {'.#'[⍵+1]}¨⊃∨/(move⍣⍺) r l d u
     +⌿∊⊃∨/(move⍣≡)r l d u ⍝ 6978
 }
