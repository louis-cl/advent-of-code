 p2←{
     schema←↑⊃⎕NGET ⍵ 1
     gears←⍸schema='*'
     nidx←{⍵⊂⍨1,2{⍵≢⍺+0 1}/⍵}⍸schema∊⎕D
     nums←⍎¨⊃,/(schema∊⎕D)((⊂⊆)⍤1)schema  ⍝ list of numbers
     dist←{⌈/|⍺-⍵}
     ratio←{ ⍝ ratio or 0
         g←⍵ ⍝ gear position
         ns←{1∊{g dist ⍵}¨⍵}¨nidx
         2≠+/ns:0 ⍝ 0 if not exactly 2 numbers
         ×/ns/nums
     }
     +/ratio¨gears
 }
