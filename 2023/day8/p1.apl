 p1←{
     ls←⊃⎕NGET ⍵ 1
     ⎕IO←0
     rs←(⊃ls)∊'R' ⍝ L=0, R=1
     nodes←↑('[A-Z]+'⎕S'&')¨2↓ls
     idx←(nodes[;0]⍳⊢) ⍝ index of node
     (idx⊂'AAA'){ ⍝ ⍺ is current node idx, ⍵ is rs idx
         'ZZZ'≡⊃nodes[⍺;0]:⍵
         (⍵+1)∇⍨idx⊂(rs[(≢rs)|⍵])⊃nodes[⍺;1 2]
     }0
 }
