 p2←{
     inw _←{⍵⊆⍨⊃¨0≠⍴¨⍵}⊃⎕NGET ⍵ 1
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
     wfkeys←⊃¨wfs
     getwf←{⊃wfs[⊃⍸(⍵∘≡)¨wfkeys]}
     countrl←{ ⍝ ⍺ rule, ⍵ range of 2x4
        ⍝ ⎕ ← 'rl' ⍺ ⍵
         var op num then←⍺
         i←'xmas'⍳var
         op='<':{
             t←then countwf((num-1)@(⊂2,i))⍵
             t((num@(⊂1,i))⍵)
         }⍵
         op='>':{
             t←then countwf((num+1)@(⊂1,i))⍵
             t((num@(⊂2,i))⍵)
         }⍵
     }
     countwf←{ ⍝ ⍺ wf, ⍵ a range of 2x4
        ⍝ ⎕←'wf' ⍺ ⍵
         'R'=⊃⍺:0 ⍝ rejected
         'A'=⊃⍺:×⌿1+--⌿⍵ ⍝ combinations
         _ rules endwf←getwf ⍺
         rules{ ⍝ ⍺ rules
             0=≢⍺:endwf countwf ⍵
             total compl←(1⌷⍺)countrl ⍵
             total+(1↓⍺)∇ compl
         }⍵
     }
     'in'countwf↑(4⍴1)(4⍴4000)
 }
