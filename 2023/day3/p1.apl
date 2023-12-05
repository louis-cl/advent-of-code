 p1←{
     schema←↑⊃⎕NGET ⍵ 1
     syms←~schema∊'.',⎕D
     sidx←⍸{∨/∊⍵}⌺3 3⊢syms ⍝ neighbour idx
     nums←⍎¨⊃,/(schema∊⎕D)((⊂⊆)⍤1)schema  ⍝ list of numbers
     nidx←{⍵⊂⍨1,2{⍵≢⍺+0 1}/⍵}⍸schema∊⎕D ⍝ idx of numbers
     ⍝ ⊆ schema sidx nidx
     adj←{∨/⍵∊sidx}¨nidx
     +/adj/nums
 }
