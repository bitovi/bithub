OAuth linking
-------------

Dinko: t1	     <- logged in with t1
Slavko: m2, g2 
Branko: t3, g3
**************

linking ->  result     | state
********************************
g1      ->  t1, g1     | :not_merge
g2      ->  t1, m2, g2 | :valid_merge
g3      ->  0          | :invalid_merge
