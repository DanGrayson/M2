-- this is a hard example from John Harrison
-- can we do it without running out of memory?
-- maybe it ought to be moved to the slow test directory.

  A = ZZ[x0,x1,x2,x3,x4,x5,x6,x7,x8,x9,x10,x11,x12,x13]
  f0 = ((x3 * x0) - (1))
  f1 = ((x1 * x3) - (((3) * (x5 ^ 2)) + (((2) * (x9 * x5)) + (x10 - (x6 * x4)))))
  f2 = ((x2 * x3) - (-((x5 ^ 3)) + ((x10 * x5) + (((2) * x12) - (x7 * x4)))))
  f3 = (x11 - ((x1 ^ 2) + (((x6 * x1) - x9) - ((2) * x5))))
  f4 = (x8 - (((-((x1 + x6)) * x11) - x2) - x7))
  f5 = (x3 - (((2) * x4) + ((x6 * x5) + x7)))
  f6 = (((x4 ^ 2) + ((x6 * (x5 * x4)) + (x7 * x4))) - ((x5 ^ 3) + ((x9 * (x5^ 2)) + ((x10 * x5) + x12))))
  f7 = (((((x8 ^ 2) + ((x6 * (x11 * x8)) + (x7 * x8))) - ((x11 ^ 3) + ((x9 * (x11 ^ 2)) + ((x10 * x11) + x12)))) * x13) - (1))
  I = ideal(f0,f1,f2,f3,f4,f5,f6,f7)

time gens gb I
assert(1 % I == 0)
gbTrace = 3
time(h = 1 // (gens I))
assert((gens I) * h == 1)

