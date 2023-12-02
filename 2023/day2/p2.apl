 p2←{
     lines←⊃⎕NGET ⍵ 1
     rsplit←{(⊢/¨r)↓¨⍵⊂⍨(⍳≢⍵)∊1+⊃¨r←(⍺,'|^')⎕S 0 1⊢⍵}
     color←'red' 'green' 'blue' ⍝ 1 2 3
     limit←12 13 14
     games←({{' 'rsplit ⍵}¨', 'rsplit ⍵}¨'; 'rsplit 2⊃': 'rsplit⊢)¨lines
     f←{
         s←{(⍎⊃⍵),color⍳⍵[2]}¨⍵
         get←{⊃⊃((⍺=2⊃⊢)¨⍵)/⍵} ⍝ 1 get row returns amount of red
         {⍵ get s}¨⍳3
     }
     +/×/¨(⌈⌿∘↑f¨)¨games
 }
