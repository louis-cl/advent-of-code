 p2←{ ⍝ input 141x141
     heatc←⍎¨↑⊃⎕NGET ⍵ 1
     dirs←(0 1)(1 0)(0 ¯1)(¯1 0) ⍝ right and cw scan
     sort←{⍵[⍋⍵[;1];]}

     bestc←(⌊/⍬)⍴⍨4 10,⍴heatc ⍝ dir used-in-dir x y
     bestc[1;1;1;2]←heatc[1;2]
     bestc[2;1;2;1]←heatc[2;1]
     next←{ ⍝ nx3 matrix of (dir used x y)
         dir used x y←⍵
         ndir←1+4|¯1+dir+0 1 ¯1 ⍝ f, cw, ccw
         nused←(1+used)1 1
         nxy←x y+⍤1↑dirs[ndir]
         in←(nused≤10)∧∧/(nxy>0)∧(⍴heatc)(≥⍤1)nxy
         ((1,2⍴(used≥4))∧in)⌿ndir,nused,nxy
     }
     ⍝ pred ← 0⍴⍨(⍴heatc),2 ⍝ pred
     ⍝ pred[1;2;] ← 1 1
     ⍝ pred[2;1;] ← 1 1
     ⍝ ⍵ nx5 (heatloss dir used-in-dir x y)
     {
         0=≢⍵:'failure'
         q←sort ⍵ ⍝ imagine having a heap
         ⍝ ⎕ ← ⊆ 'visiting' (1⌷q)
         hl dir used x y←1⌷q
         (used≥4)∧(⍴heatc)≡x y:hl ⍝ found it
         ∇(1↓q){ ⍝ process each neighbor
             0=≢⍵:⍺
             dir2 used2 x2 y2←1⌷⍵
             nhl←hl+heatc[x2;y2]
             nhl≥bestc[dir2;used2;x2;y2]:⍺ ∇ 1↓⍵ ⍝ skip
             bestc[dir2;used2;x2;y2]←nhl
             ⍝ pred[x2;y2;] ← x y
             (⍺⍪nhl dir2 used2 x2 y2)∇ 1↓⍵
         }next dir used x y
     }↑(heatc[1;2]1 1 1 2)(heatc[2;1]2 1 2 1)
     ⍝ 974 for input
 }
