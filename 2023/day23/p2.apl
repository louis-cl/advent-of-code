 p2←{
     map←↑⊃⎕NGET ⍵ 1
     start←⊂1(⊃⍸'.'=map[1;])
     end←⊂(≢map)(⊃⍸'.'=map[≢map;])
     ⍝ branching positions
     nodes←⍸({(3<+⌿∊⍵[(1 2)(2 1)(2 2)(2 3)(3 2)])∧⍵[2;2]}⌺3 3)'#'≠map
     nodes←1500⌶,start,nodes,end
     edges←{⍵ ⍵⍴0}≢nodes ⍝ cost i->j
     dirs←↑(0 1)(1 0)(¯1 0)(0 ¯1)
     next←{ ⍝ ⍵ pos
         t←'>v^<'⍳⍺[⍵]
         t≠5:⊂dirs[t;]+⊃⍵
         n←(⊃⍵)(+⍤1)dirs
         sel←∧/(n>0)∧n(≤⍤1)⍴⍺ ⍝ inside
         n←sel⌿n ⋄ c←⍺[↓n]
         ↓n⌿⍨(c='.')∨c=sel/'>v^<'
     }
     map[start]←'#'
     explore←{
         ⍝ ⎕←'explore'⍵
         from c p←⍵
         n←map next p
         ⍝_ ← {(⊂21 20)≡p: ⎕ ← 'map' map from c p n ⋄ 0}⍵
         0=≢n:⍬ ⍝ done
         map[n]←'#' ⍝ visit
         _←{
             to←nodes⍳⊂⍵
             to=1+≢nodes:explore from(c+1)(⊂⍵)
             map[⊂⍵]←'.' ⍝ keep it open
             to=from:'ignore' ⍝ avoid self loop of size 2
             edges[from;to]←c+1
             ⍝ _ ←{2=c+1: ⎕ ← 'warning' map from c p 'to' ⍵ ⋄ 0}⍵
             explore to 0(⊂⍵)
         }¨n
         ⍬
     }
     _←explore 1 0 start
     edges←edges+⍉edges ⍝ both directions
     ⍝ now find longest path
     ⍝ (0,nodes),nodes⍪edges
     used←0⍴⍨≢nodes
     used[1]←1
     dfs←{
         ⎕←'dfs'⍵
         from cost←⍵
         from=≢nodes:cost
         e←edges[from;]
         n←⍸(~used)∧0≠e
         0=≢n:0 ⍝ why ?
         ⌈⌿{
             ⎕←'from'from'to'⍵
             used[⍵]←1 ⍝ use it
             d←dfs ⍵(cost+e[⍵])
             used[⍵]←0 ⍝ free it
             d
         }¨n
     }
     dfs 1 0
 }
