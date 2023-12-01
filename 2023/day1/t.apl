 t←{
     s←⍵
     pos←{⍵(⍸⍷)s}¨(d2,d1)
     min←(⌊/)¨pos
     max←(⌈/)¨pos
     mini←⌊/min
     maxi←⌈/max
     ⍝ ↑ ((⍳9),⍳9)  pos
     mind←(min=mini)/(⍳9),⍳9
     maxd←(max=maxi)/(⍳9),⍳9
     (10×mind)+maxd
 }
