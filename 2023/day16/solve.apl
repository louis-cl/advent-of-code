 solve←{ ⍝ input 110x110
     map←↑⊃⎕NGET ⍵ 1
     mv mh mf mb me←map∘=¨'|-/\.'
     count←{
         move←{
             r l d u←⍵
             rr←0,¯1↓[2](d∧mh∨mb)∨(r∧mh∨me)∨(u∧mh∨mf)
             uu←0⍪⍨1↓(r∧mf∨mv)∨(u∧me∨mv)∨(l∧mv∨mb)
             dd←0⍪¯1↓(d∧me∨mv)∨(r∧mb∨mv)∨(l∧mv∨mf)
             ll←0,⍨1↓[2](d∧mh∨mf)∨(l∧me∨mh)∨(u∧mh∨mb)
             (r∨rr)(l∨ll)(d∨dd)(u∨uu)
         }
         +⌿∊⊃∨/(move⍣≡)⍵
     }
     r l d u←4(⍴∘⊂)0⍴⍨⍴map ⍝ > < v ^
     p1←count(1@(⊂1 1)⊢r)l d u
     m n←⍴map
     rm←⌈⌿{count(1@(⊂⍵ 1)⊢r)l d u}¨⍳m
     lm←⌈⌿{count r(1@(⊂⍵ n)⊢l)d u}¨⍳m
     dm←⌈⌿{count r l(1@(⊂1 ⍵)⊢d)u}¨⍳n
     um←⌈⌿{count r l d(1@(⊂m ⍵)⊢u)}¨⍳n
     p2←⌈⌿rm lm dm um
 }
