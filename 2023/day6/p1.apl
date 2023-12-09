 p1←{
     T R←↓⍵
     d←0.5*⍨(T*2)+¯4×R
     l h←(0.5×T+⊢)¨(-d)d
     ll hh←(⌈l)(⌊h)
     ×/1+(hh-hh=h)-ll+ll=l
 }
