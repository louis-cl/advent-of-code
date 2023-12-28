 p1←{
     map←↑⊃⎕NGET ⍵ 1
     start←⊃⍸'S'=map
     dirs←↑{4≠⍵⍳map}¨'|LJ' '7|F' '-LF' '-J7' ⍝ nsew
     dirs[;start[1];start[2]]←1 ⍝ start can go anywhere
     opdirs←(⊂2 1 4 3)⌷dirs ⍝ snwe
     deltas←(¯1 0)(1 0)(0 1)(0 ¯1) ⍝ nsew
     p←('S'=map){ ⍝ ⍺ visited mask, ⍵ current position
         next←{
             d←dirs[;⍵[1];⍵[2]]
             new←(⊂⍵)+d/deltas
             match←new⊃⍤0 2⊢d⌿opdirs ⍝ south must reach a north
             n←match/new
             (~⍺[n])/n ⍝ pick only not seen
         }
         n←⍺ next ⍵
         0=≢n:⍺
         (1@n⊢⍺)∇⊃,1⌷n
     }start
     0.5×+⌿∊p
     ⍝ p1 'day10/input' => 6820 in 0.2s
 }
