/* 
*   random.s - a library for generating pseudo random numbers 
*/

/*
*   Random - generate a pseudo random number
*
*   This implementation uses the quadratic congruence generator.
*
*   Let xn be the nth random number, then xn+1 = axn**2 + bxn + c mod 2**32,
*   where a is even, b = a + 1 mod 4, and c is odd.
*
*   In this case, a = 0xef00, b = 1, and c = 73.
*
*   args:
*       r0 - the last value generated by the function
*
*   returns:
*       r0 - a pseudo random number
*/
.globl Random
Random:
    xnm .req r0
    a .req r1

    mov     a, #0xef00
    mul     a, xnm
    mul     a, xnm

    add     a, xnm
    .unreq  xnm
    add     r0, a, #73
    .unreq  a
    mov     pc, lr
