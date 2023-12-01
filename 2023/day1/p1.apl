 p1←{
     lines←⊃⎕NGET ⍵ 1
     digits←{⍵/⍨⍵∊⎕D}
     f_and_l←{(⊃⍵),⊃¯1↑⍵}
     +/(⍎∘f_and_l∘digits)¨lines
 }
