;; draw lines

draw:
  jsr $ff01   ; call BGNDRW
  lit $0a     ; startX=10
  lit $0a     ; startY=10
  lit $64     ; endX=100
  lit $64     ; endY=100
  lit $3      ; cyan
  jsr $ff04   ; call LINOUT
  lit $64     ; startX=100
  lit $64     ; startY=100
  lit $c8     ; endX=200
  lit $64     ; endY=100
  lit $2      ; red
  jsr $ff04   ; call LINOUT
  jsr $ff02   ; call ENDDRW
  jmp draw
  brk
