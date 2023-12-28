:Namespace day12
    ⍝ input is 1000 rows of 20 chars
    count←{
      (∨⌿⍺∊'#')∧(0=≢⍵):0 ⍝ need more #
      0=≢⍵:1 ⍝ all empty
      x←⊃⍵
      x>≢⍺:0 ⍝ need more than available
      ⍝ ⎕←⊆'count'⍺ ⍵
      ~∧⌿⍺∊'#?.':999
      skip←⍺{
          '#'=⊃⍺:0 ⍝ cannot skip
          ⍝⎕←⊆'skip '⍺ ⍵
          (1↓⍺)count ⍵
      }⍵
      match←⍺{
          ∨⌿(x↑⍺)∊'.':0 ⍝ . in middle
          '#'=(1+x)⊃⍺,'⊥':0 ⍝ # just after fail, if not end
          ⍝⎕←⊆'match'⍺ ⍵
          ((1+x)↓⍺)count 1↓⍵
      }⍵
      skip+match
    }
    p1←{
      ls←' '(≠⊆⊢)¨⊃⎕NGET ⍵ 1
      rz←(1⊃⊢)¨ls
      sz←⍎¨¨','(≠⊆⊢)¨(2⊃⊢)¨ls
      +/rz({(⊃⍺)count(⊃⍵)}⍤0 0)sz
    }
    ⍝ . is \s+
    ⍝ # is exactly 1 '#'
    ⍝ the first '.' will be \s* by giving a free match
    encode ← { ⍝ 1 1 3 => '.#.#.###.'
       '.',⍨⊃,⌿{'.',⍵⍴'#'}¨⍵
    }
    count2←{
        text ← ⍺
        auto ← encode ⍵
        dots ← auto='.'
        blocks ← auto='#'
        matches ← 0⍨¨auto
        (⊃matches)+← 1 ⍝ free match (\s+ -> \s*)
        ⍝ > is shift right, +> is shift & add
        ⍝    enc=.  enc=#
        ⍝ #    0      >
        ⍝ .    +>     0
        ⍝ ?    +>     >
        +⌿¯2↑ matches {
            ⍵>≢text: ⍺
            c ← ⍵⊃text
            res ← 0,¯1↓⍺ ⍝ shift all
            res +← dots×⍺ ⍝ add to dots
            res ×← ~(dots∧c='#')∨(blocks∧c='.') ⍝ mask
            ⍝ ⎕ ← c res
            res ∇ ⍵+1
        } 1
    }
    p2←{ ⍝ p2 'input' => 160500973317706
      ls←' '(≠⊆⊢)¨⊃⎕NGET ⍵ 1
      rz←{⍵,∊'?',4(↑⍴∘⊂)⍵}¨(1⊃⊢)¨ls
      sz←{∊5(↑⍴∘⊂)⍵}¨⍎¨¨','(≠⊆⊢)¨(2⊃⊢)¨ls
      +/rz({(⊃⍺)count2(⊃⍵)}⍤0 0)sz
    }
:EndNamespace
