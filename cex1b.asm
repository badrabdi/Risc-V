;summatior of positive values n-1
s0: DC "sum(1...n-1) Enter n:"
s1: DC "sum(1...n-1)="
s3: DC "(n*(n-1))/2="
addi x5, x0, s0
ecall x1, x5, 4 ;prompt s0
ecall x6, x0, 5 ;input for n
addi x7, x6, -1
add x11, x0, x0
loop: add x11, x11, x7
      addi x7, x7, -1
      bne x7, x0, loop

addi x5, x0, s1
ecall x0, x5, 4 ;prompt s0
ecall x0, x11, 0
addi x7, x6,-1
mul x7, x7, x6
srli x7, x7, 1
addi x5, x0, s3
ecall x0, x5, 4 ;prompt s0
ecall x0, x7, 0