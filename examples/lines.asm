;; draw lines

draw:
  jsr $ff10  ; call BGNDRW
  pshb 100   ; startX=100  
  pshb 10    ; startY=10
  pshb 100   ; endX=100
  pshb 100   ; endY=100
  pshb 3     ; cyan
  jsr $ff13  ; call LINOUT
  pshb 100   ; startX=100
  pshb 100   ; startY=100
  pshb 190   ; endX=190
  pshb 100   ; endY=100
  pshb 2     ; red
  jsr $ff13  ; call LINOUT
  jsr $ff11  ; call ENDDRW
  jmp draw
  brk
