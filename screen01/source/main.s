/* 
*    main.s - a solution to Baking Pi screen01 lesson: graphics 
*    
*    Display a gradient pattern to the screen.
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

        render$:
            fbAddr .req r3
            @ load the address the GPU set, see framebuffer.s data section
            ldr     fbAddr, [fbInfoAddr, #32]

            @ draw
            color .req r0
            y .req r1
            mov     y, #768

            drawRow$:
                x .req r2
                mov     x, #1024
                
                drawPixel$:
                    @ store the lower half of the word at fbAddr
                    strh    color, [fbAddr]
                    add     fbAddr, #2
                    sub     x, #1
                    teq     x, #0
                    bne     drawPixel$

                add     color, #1
                sub     y, #1
                teq     y, #0
                bne     drawRow$

            b   render$

    .unreq  fbAddr
    .unreq  fbInfoAddr
