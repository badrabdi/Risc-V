;factorial calculator takes n args
s0: DC "n! Enter n:"
s1: DC " !=\0"
addi x5, x0, s0
ecall x1, x5, 4 ;prompt s0
ecall x6, x0, 5 ;input for n
add x7, x0, x6
addi x11, x0, 1
addi x12, x6, 0
loop: 
      addi x7, x7, -1
      mul x6, x6, x7
      bne x7, x11, loop
addi x5, x0, s1


      addi x5, x0, s1
      ecall x0, x12, 0
      ecall x0, x5, 4 ;prompt s0
      ecall x0, x6, 0