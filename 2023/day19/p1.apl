 p1←{
     inw inp←{⍵⊆⍨⊃¨0≠⍴¨⍵}⊃⎕NGET ⍵ 1
     wfs←{
         name←⊃('^\w+(?={)'⎕S'&')⍵
         work←','(≠⊆⊢)⊃('(?<={).*(?=})'⎕S'&')⍵
         endrule←⊃¯1↑work
         rules←↑{
             match←⊃('^(\w+)([<>])(\d+):(\w+)$'⎕S'\1 \2 \3 \4')⍵
             var op num then←' '(≠⊆⊢)match
             (⊃var)(⊃op)(⍎num)then
         }¨¯1↓work
         name rules endrule
     }¨inw
     parts←↑{
         ⊃,/⍎¨('\d+'⎕S'&')⍵
     }¨inp
     wfkeys←⊃¨wfs
     getwf←{⊃wfs[⊃⍸(⍵∘≡)¨wfkeys]}
     exe←{ ⍝ run the workflows ar ⍵ on part ⍺
        ⍝ ⎕ ← ⊆ 'exe' ⍵ ⍺
         _ rules endrule←getwf ⍵
         part←⍺
         nextwf←{
             0=≢⍵:endrule
             var op num then←1⌷⍵
             val←part['xmas'⍳var]
             (val<num)∧op='<':then
             (val>num)∧op='>':then
             ∇ 1↓⍵
         }rules
         'A'=⊃nextwf:1
         'R'=⊃nextwf:0
         ⍺ ∇ nextwf
     }
     +⌿∊parts⌿⍨{⍵ exe'in'}⍤1⊢parts
 }
