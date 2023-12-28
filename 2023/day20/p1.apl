 p1←{
     ls←('%|&|\w+'⎕S'&')¨⊃⎕NGET ⍵ 1
     ops←1↓ls ⍝ broadcast manually put at first instr
     enc←{26⊥⎕A⍳1 ⎕C ⍵} ⍝ base 26 atoi
     names←∪⊃,⌿(1↓⊢)¨ls
     keys←1500⌶,enc¨names
     type←{((⍵[;1])@(⍵[;2]))(≢keys)⍴'.'
     }↑{(⊃⊃⍵)(keys⍳enc 2⊃⍵)}¨ops ⍝
     ⎕←type⍪⍨names⍪⍨,[0.5]⍳≢names

     broad←keys⍳enc¨1↓⊃ls ⍝ broadcast target
     conn←{⍵ ⍵⍴0}≢keys ⍝ row in, col out
     conn[⊃,⌿{ ⍝ ⍵ list of ops
         names←1↓⍵
         ks←keys⍳enc¨names
         from←⊃ks
         {from ⍵}¨(1↓ks)
     }¨ops]←1

     ⍝ broadcast always sends to %, from=0
     pulse←{ ⍝ ⍵ mem state, ⍺ = from to high?
         from to high←⍺
       ⍝⎕ ← ({0=⍵:'broad' ⋄ names[⍵]}from) high (names[to])
         '%'=type[to]:{
             high:⍵ ⍬ ⍝ nth
             s←~⍵[1;to]
             (s@(⊂1 to)⊢⍵)({to ⍵ s}¨⍸conn[to;])
         }⍵
         '&'=type[to]:{
             mem←(high@(⊂from to)⊢⍵)
             s←~∧⌿conn[;to]/mem[;to]
             mem({to ⍵ s}¨⍸conn[to;])
         }⍵
       ⍝ ⎕ ← 'unknown !'
         ⍵ ⍬
     }
     button←{ ⍝ ⍵ = (low high) mem
        ⍝ ⎕ ← '=> button'
         c mem←⍵
         ({0 ⍵ 0}¨broad){ ⍝ ⍺ queue of pulses
             0=≢⍺:⍵
             c mem←⍵
             c[1+3⊃⊃⍺]+←1
             mem2 pulses←(⊃⍺)pulse mem
             (1↓⍺,pulses)∇ c mem2
         }(c+1 0)mem ⍝ add 1 low for button
     }
     ×⌿⊃button⍣1000⊢(0 0)((⍴conn)⍴0) ⍝ all off
 }
