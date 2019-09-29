;find all divisors
s0: DC "Find all divisors."
s1: DC "Enter i:"
s3: DC "Divisors:"
addi x28, x0, 0
addi x5, x0, s0
ecall x1, x5, 4 ;prompt s0
ecall x6, x0, 5 ;input for n
add x8, x8, x6
loop: rem x11, x6, x8
      beq x11, x0, src
      addi x8, x8, -1
      bne x8, x0, loop
src:  add x29, x28, x0
      sd 0(x29), x8
      addi x28, x28, 8 

