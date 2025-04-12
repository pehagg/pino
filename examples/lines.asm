;; draw lines

draw:
  jsr $ff10 ; call BGNDRW
  psh 100   ; startX=100  
  psh 10    ; startY=10
  psh 100   ; endX=100
  psh 100   ; endY=100
  psh 3     ; cyan
  jsr $ff13 ; call LINOUT
  psh 100   ; startX=100
  psh 100   ; startY=100
  psh 190   ; endX=190
  psh 100   ; endY=100
  psh 2     ; red
  jsr $ff13 ; call LINOUT
  jsr $ff11 ; call ENDDRW
  jmp draw
  brk
