 p2←{
     ls←⊃⎕NGET ⍵ 1
     ⎕IO←0
     rs←(⊃ls)∊'R' ⍝ L=0, R=1
     nodes←↑('\w+'⎕S'&')¨2↓ls
     idx←(nodes[;0]⍳⊢) ⍝ index of node
     nodesA←nodes[;0]/⍨{⍵[2]='A'}¨nodes[;0]
     steps←{ ⍝ ⍺ is current node idx, ⍵ is rs idx
         'Z'≡2⊃⊃nodes[⍺;0]:⍵ ⍝ ends in 'Z'
         (⍵+1)∇⍨idx⊂(rs[(≢rs)|⍵])⊃nodes[⍺;1 2]
     }
     ⍝ lcm of steps for each ..A to ..Z
     ∧⌿{(idx⊂⍵)steps 0}¨nodesA
 }
