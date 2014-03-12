/* 
*    main.s - a solution to Baking Pi screen02 lesson: random lines 
*    
*    Drawing lines based on pseudo random numbers.
*/

.section .init
.global _start
_start:
    b       main

.section .text
main:
    @ The text section is stored after the init (0x8000) section in memory due to
    @ the way the makefile and linker scripts work. Here is what memory looks
    @ like:
    @
    @            __________________
    @           |      .text       |
    @           --------------------
    @   0x8000  |      .init       |
    @           --------------------
    @           |(bottom)          |
    @           |                  |
    @           |      Stack       | 
    @           |                  | 
    @   0x???   |(top)             |
    @           -------------------- 
    @           |      ATAGs       |
    @   0x100   |    (RPi info)    |
    @           --------------------
    @   0x0     |    loader stub   |
    @           -------------------- 
    @
    mov     sp, #0x8000

    @ initialize the frame buffer with width 1024, height 768, bitdepth 16
    mov     r0, #1024
    mov     r1, #768
    mov     r2, #16
    bl      InitializeFrameBuffer

    @ check the GPU is ready
    teq     r0, #0
    bne     noError$

    @ turn on OK LED if GPU is not ready
    mov     r0, #16
    mov     r1, #1
    bl      SetGpioFunction
    mov     r0, #16
    mov     r1, #0
    bl      SetGpio

    error$:
        b   error$

    noError$:
        fbInfoAddr .req r4
        mov     fbInfoAddr, r0
        bl      SetGraphicsAddress

        lastRandom .req r7
        lastX .req r8
        lastY .req r9
        color .req r10
        x .req r5
        y .req r6

        mov     lastRandom, #0
        mov     lastX, #0
        mov     lastY, #0
        mov     color, #0

        render$:
            mov     r0, lastRandom
            bl      Random
            mov     x, r0
            bl      Random
            mov     y, r0
            mov     lastRandom, r0

            mov     r0, color
            add     color, #1
            lsl     color, #16
            lsr     color, #16
            bl      SetForeColor

            mov     r0, lastX
            mov     r1, lastY
            lsr     r2, x, #22
            lsr     r3, y, #22

            cmp     r3, #768
            bhs     render$

            mov     lastX, r2
            mov     lastY, r3
            bl      DrawLine           

            b   render$

        .unreq x
        .unreq y
        .unreq lastRandom
        .unreq lastX
        .unreq lastY
        .unreq color
