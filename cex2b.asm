t: DF 1.0
z: DF 0.0
fld f0, t(x0)
fld f5, z(x0)
addi x6, x0, 17
addi x6, x6, 1 
add x7, x0, x6
addi x11, x0, 1
addi x12, x6, 0
add x8, x0, x6
add x9, x0,x6

fact: 
      addi x7, x7, -1
      mul x8, x8, x7
      add x28, x8, x0
      beq x7, x11, before
      beq x0, x0, fact

before: div x28, x8, x6
         beq x0, x0, loop

loop: addi x9, x9, -1 
      beq x9, x0, exit
      div x28, x28, x9
      
      fcvt.d.l f2 , x28
      fdiv.d f4, f0, f2
      fadd.d f5, f5, f4
      beq x0, x0, loop

exit: fsd f5, 0(x0)
     
