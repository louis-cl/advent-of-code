 p1←{
     lines←⊃⎕NGET ⍵ 1
     rsplit←{(⊢/¨r)↓¨⍵⊂⍨(⍳≢⍵)∊1+⊃¨r←(⍺,'|^')⎕S 0 1⊢⍵}
     color←'red' 'green' 'blue' ⍝ 0 1 2
     limit←12 13 14
     games←({{' 'rsplit ⍵}¨', 'rsplit ⍵}¨'; 'rsplit 2⊃': 'rsplit⊢)¨lines
     possible←{
         c←⍎⊃⍵
         max←limit[color⍳⍵[2]]
         c≤max
     }
     pgames←(∧/∘∊(possible¨¨))¨games
     +/⍸pgames
 }
