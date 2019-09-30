v1: DF 1.21, 5.85, -7.3, 23.1, -5.55, 0.0
v2: DF 3.14, -2.1, 44.2, 11.0, -7.77, 0.0
t: DF 0
    add x6, x0, x0
    fld f2, t(x0)
loop: fld f0, v1(x6)
      fld f1, v2(x6)
      fmul.d f4, f0, f1
      fadd.d f2, f2, f4
      fcvt.l.d x5, f0
      addi x6, x6,8 
      beq x5, x0, skip
      beq x0,x0, loop

skip:
    fsd f2, 0(x0)

      
