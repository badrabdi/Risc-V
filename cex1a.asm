;factorial calculator takes n args
s0: DC "n! Enter n:\0"
s1: DC "=\0"
add x5, x0, s0
ecall x0, x5, 4
