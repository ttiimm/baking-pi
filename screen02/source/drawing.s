/* 
*   drawing.s - a library of drawing functions
*/

.section .data
.align 1
foreColor:
    .hword 0xFFFF

.align 2
graphicsAddress:
    .int 0


.section .text


/*
*   SetForeColor - set the color to draw with
*
*   args:
*       r0 - the color
*/
.globl  SetForeColor
SetForeColor:
    cmp     r0, #0x10000
    @ movhs   pc, lr
    movhi   pc, lr
    moveq   pc, lr
    ldr     r1, =foreColor
    strh    r0, [r1]
    mov     pc, lr


/*
*   SetGraphicsAddress - set the address to draw at
*
*   args:
*       r0 - the address to draw at
*/
.globl  SetGraphicsAddress
SetGraphicsAddress:
    ldr     r1, =graphicsAddress
    str     r0, [r1]
    mov     pc, lr


/*
*   DrawPixel - draw a pixel at the given location
*
*   args:
*       r0 - the x coordinate
*       r1 - the y coordinate
*/
.globl  DrawPixel
DrawPixel:
    px .req r0
    py .req r1
    addr .req r2
    ldr     addr, =graphicsAddress
    ldr     addr, [addr]

    @ check that py < height
    height .req r3
    ldr     height, [addr, #4]
    sub     height, #1
    cmp     py, height
    movhi   pc, lr
    .unreq  height

    @ check that px < width
    width .req r3
    ldr     width, [addr, #0]
    sub     width, #1
    cmp     px, width
    movhi   pc, lr

    @ compute the address of the pixel to write
    @ frameBufferAddress + (x + y * width) * pixel size
    @ this is dependent on the high color mode
    ldr     addr, [addr, #32]
    add     width, #1
    mla     px, py, width, px
    .unreq  width
    .unreq  py
    add     addr, px, lsl #1
    .unreq  px

    @ load the fore color, high color mode specific
    fore .req r3
    ldr     fore, =foreColor
    ldrh    fore, [fore]

    strh    fore, [addr]
    .unreq  fore
    .unreq  addr
    mov     pc, lr


/*
*   DrawLine - draw a line between two points
*
*   This draws lines using Bresenham's Algorithm, given in pseudocode below.
*
*   if x1 > x0 then
*   
*   set deltax to x1 - x0
*   set stepx to +1
*   
*   otherwise
*   
*   set deltax to x0 - x1
*   set stepx to -1
*   
*   end if
*
*   if y1 > y0 then
*
*   set deltay to y1 - y0
*   set stepy to -1
*
*   otherwise
*
*   set deltay to y0 - y1
*   set stepy to 1
*
*   end if
*   
*   set error to deltax - deltay
*   until x0 = x1 + stepx or y0 = y1 + stepy
*   
*   setPixel(x0, y0)
*   if error × 2 ≥ -deltay then
*   
*   set x0 to x0 + stepx
*   set error to error - deltay
*   
*   end if
*   if error × 2 ≤ deltax then
*   
*   set y0 to y0 + stepy
*   set error to error + deltax
*   
*   end if
*   
*   repeat
*
*   args:
*       r0 - the x0 coordinate
*       r1 - the y0 coordinate
*       r2 - the x1 coordinate
*       r3 - the y1 coordinate
*/
.globl  DrawLine
DrawLine:
    push {r4, r5, r6, r7, r8, r9, r10, r11, r12, lr}
    x0 .req r9
    x1 .req r10
    y0 .req r11
    y1 .req r12

    mov     x0, r0
    mov     x1, r2
    mov     y0, r1
    mov     y1, r3

    dx .req r4
    @ only use negative dy
    dyn .req r5
    sx .req r6
    sy .req r7
    err .req r8

    cmp     x0, x1
    subgt   dx, x0, x1
    movgt   sx, #-1
    suble   dx, x1, x0
    movle   sx, #1

    cmp     y0, y1
    subgt   dyn, y1, y0
    movgt   sy, #-1
    suble   dyn, y0, y1
    movle   sy, #1

    add     err, dx, dyn
    @ not sure why these additions are done here
    add     x1, sx
    add     y1, sy

    pixelLoop$:
        @ stop if x0 == x1 and y0 == y1
        teq     x0, x1
        teqne   y0, y1
        popeq   {r4, r5, r6, r7, r8, r9, r10, r11, r12, pc}

        @ draw this point
        mov     r0, x0
        mov     r1, y0
        bl      DrawPixel

        cmp     dyn, err, lsl #1
        addle   err, dyn
        addle   x0, sx

        cmp     dx, err, lsl #1
        addge   err, dx
        addge   y0, sy

        b       pixelLoop$

    .unreq  x0
    .unreq  x1
    .unreq  y0
    .unreq  y1
    .unreq  dx
    .unreq  dyn
    .unreq  sx
    .unreq  sy
    .unreq  err
