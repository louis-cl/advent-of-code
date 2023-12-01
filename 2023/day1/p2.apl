 p2←{
     lines←⊃⎕NGET ⍵ 1
     names←'one' 'two' 'three' 'four' 'five' 'six' 'seven' 'eight' 'nine'
     digits←⍕¨⍳9
     f←{
         s←⍵
         pos←,⌿({⊂(⊃⍵)(⍸⍷)s}⍤0)↑names digits
         first←⌊/¨pos
         last←⌈/¨pos
         a b←(first⍳⌊/first)(last⍳⌈/last)
         b+a×10
     }
     ⍝  ↑digits names
     ⍝  ⍉↑ lines (f¨lines)
     +/f¨lines
 }
