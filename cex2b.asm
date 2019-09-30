t: DF 1.0
z: DF 0.0
fld f0, t(x0)
fld f5, z(x0)
addi x6, x0, 8
add x8, x0, x0
addi x7, x0, 0
fact: addi x7, x
loop: addi x8, x8, 1
      beq x0, x0, call 
      fcvt.d.l f2 , x18
      fdiv.d f4, f0, f2
      fadd.d f5, f5, f4
      beq x8, x6, exit
      beq x0, x0, loop
   



exit:
    addi x29, x0, 2