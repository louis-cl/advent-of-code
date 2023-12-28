 p2←{
     hash←{
         ⍺←0
         (0∊⍴)⍵:⍺
         (256|17×⍺+⎕UCS⊃⍵)∇ 1↓⍵
     }
     parse←{
         '-'=(⊃⌽)⍵:'-'(¯1↓⍵)
         l r←'='(≠⊆⊢)⍵
         '='l(⍎r)
     }
     instr←parse¨','(≠⊆⊢)⍵
     set←{
         k v←⍵ ⋄ h←1+hash k ⋄ box←h⊃⍺
         s←⍸(k∘≡)¨box[1;]
         s≡⍬:((⊂box,k v)@h)⍺ ⍝ concat
         ⍝ ⎕ ← ⊆ 'found' k 'at' s 'in' box
         box[2;⊃s]←v
         ((⊂box)@h)⍺
     }
     del←{
         h←1+hash ⍵ ⋄ box←h⊃⍺
         ((⊂box/⍨(⍵∘≢)¨box[1;])@h)⍺
     }
     exe←{ ⍝ ⍺ memory, one instr
        ⍝ ⎕ ← ⍕ ⊆ 'exe' ⍵
         '='=⊃⍵:⍺ set 1↓⍵
         ⍺ del 2⊃⍵
     }
     m←(256⍴(⊂2 0⍴0)){
         (0∊⍴)⍵:⍺
         (⍺ exe⊃⍵)∇ 1↓⍵
     }instr
     mul←{+/∊(⍳≢⍵)×⍵}
     mul{mul 2⌷⍵}¨m
     ⍝ p2 ⊃⊃⎕nget'input'1 => 244342
 }
