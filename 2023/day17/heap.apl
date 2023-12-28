:Namespace heap
    ⍝ https://gist.github.com/xpqz/c10b3009a68f9ffdc84c2fb09b44302a
    ⎕io←0
      Insert←{ ⍝ Insert item into leftist tree, returning the resulting tree
          (tree item)←⍵
          1 item ⍬ ⍬ Merge tree
      }

      Pop←{ ⍝ Pop off smallest element from a leftist tree
          0=≢⍵:⍬
          (v l r)←1↓⍵                 ⍝ value left right
          (l Merge r)v               ⍝ Return the resulting tree and the value
      }

      Merge←{ ⍝ Merge two leftist trees, t1 and t2
          t1←⍺ ⋄ t2←⍵
          0=≢t1:t2 ⋄ 0=≢t2:t1                          ⍝ If either is a leaf, return the other
          (key1 left right)←1↓t1 ⋄ key2←1⌷t2
          key1>key2:t2 ∇ t1                              ⍝ Flip order to ensure smallest is root of merged
          merged←right ∇ t2                              ⍝ Merge rightwards
          (⊃left)≥⊃merged:(1+⊃merged)key1 left merged ⍝ Right is shorter
          (1+⊃left)key1 merged left                   ⍝ Left is shorter; make it the new right
      }
:EndNamespace
