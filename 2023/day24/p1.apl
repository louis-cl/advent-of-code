 p1←{
     in←↑⍎∘('[@,]'⎕R'')∘('-'⎕R'¯')¨⊃⎕NGET ⍵ 1
     in←in[;1 2 4 5] ⍝ ignore z
     inter←{
         p1 v1←(2↑⍺)(2↓⍺)
         p2 v2←(2↑⍵)(2↓⍵)
         11::⍬ ⍝ domain error => no solution
         sol←(p2-p1)+.×⌹↑v1(-v2)
         ∨⌿sol<0:⍬ ⍝ backward in time
         p1+sol[1]×v1
     }
     sol←∊∘.inter⍨↓in
     ps←(0.5×≢sol)2⍴sol
     0.5×+⌿∧/(ps≥200000000000000)∧(ps≤400000000000000)
 }
