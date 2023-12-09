 p1←{
     ls←⊃⎕NGET ⍵ 1
     inp←↑' '∘(≠⊆⊢)¨ls
     rank←{
         s←(≢⊢)⌸⍵
         s←s[⍒s]
         (1 1 1 1 1)≡s:1
         (2 1 1 1)≡s:2
         (2 2 1)≡s:3
         (3 1 1)≡s:4
         (3 2)≡s:5
         (4 1)≡s:6
         7
     }
     hands←inp[;1]
     hord←⍋'23456789TJQKA'⍋↑hands
     order←⍋⍉↑(rank¨hands)hord
     bets←⍎¨inp[order;2]
     +/bets×⍳≢bets
 }
