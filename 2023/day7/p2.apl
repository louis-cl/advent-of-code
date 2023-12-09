 p2←{
     ls←⊃⎕NGET ⍵ 1
     inp←↑' '∘(≠⊆⊢)¨ls
     rank←{
         s←{⍺,≢⍵}⌸⍵
         1=≢s:7 ⍝ only 1 symbol, handle only J
         s←s[⍒s[;2];]
         j←s[;1]∊'J'
         snoj←(~j)⌿s
         snoj[1;2]+←⊃j⌿s[;2]
         s←snoj[;2]
         (1 1 1 1 1)≡s:1
         (2 1 1 1)≡s:2
         (2 2 1)≡s:3
         (3 1 1)≡s:4
         (3 2)≡s:5
         (4 1)≡s:6
         7
     }
     hands←inp[;1]
     hord←⍋'J23456789TQKA'⍋↑hands
     order←⍋⍉↑(rank¨hands)hord
     bets←⍎¨inp[order;2]
     +/bets×⍳≢bets
 }
