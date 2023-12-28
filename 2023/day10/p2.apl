 p2←{
     map←↑⊃⎕NGET ⍵ 1
     start←⍸'S'=map
     map[start]←⍺ ⍝ manually found
     south←4≠'7|F'⍳map
     north←4≠'|LJ'⍳map
     east←4≠'-LF'⍳map
     west←4≠'-J7'⍳map
     dirs←↑north south east west
     opdirs←↑south north west east
     deltas←(¯1 0)(1 0)(0 1)(0 ¯1)
     p←start{ ⍝ ⍺ visited, ⍵ current position
         next←{
             d←dirs[;⍵[1];⍵[2]]
             new←(⊂⍵)+d/deltas ⍝ not visited new pos
             match←new⊃⍤0 2⊢d⌿opdirs ⍝ south must reach a north
             ⍺~⍨match/new
         }
         n←⍺ next ⍵
         0=≢n:⍺
         (⍺,1⌷n)∇⊃,1⌷n
     }⊃start
     path←0⍴⍨⍴map
     path[p]←1
     +⌿,(~path)∧2|+⍀path∧west
     ⍝ '|' p2 'day10/input' => 337
 }
