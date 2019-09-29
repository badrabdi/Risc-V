;find all divisors
s0: DC "Find all divisors."
s1: DC "Enter i:\0"
s2: DC "Divisors:\0"
s3: DC "prime"
s4: DC "not prime"
addi x28, x0, 0
addi x5, x0, s0
ecall x0, x5, 4 ;prompt s0
addi x5, x0, s1
ecall x1, x5, 4
ecall x6, x0, 5 ;input for n
addi x8, x0, 0
addi x5, x0, s2
ecall x0, x5, 4 ;prompt s0
loop: addi x8, x8, 1
      rem x11, x6, x8
      bne x11, x0, loop
      add x29, x28, x0
      sd x8, 0(x29)
      ecall x0, x29,0
      addi x28, x28, 8 
      bne x8, x6, loop

ld x7, 8(x0)
beq x7, x6, src
addi x5, x0, s4
ecall x0, x5, 4

src:
addi x5,x0, s3 
ecall x0, x5, 4
     


