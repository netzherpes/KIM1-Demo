# 🎂 KIM-1 Demo Project

A small but heartfelt demo celebrating the **50th birthday of the legendary MOS KIM-1** 🖥️✨

The **KIM-1** first became available in **January 1976** —  
*three months before the Apple I 🍎* and *one month after its sibling, the TIM*.  
An incredible milestone in early microcomputer history!

For this demo, I’ve gathered and connected a few components that were scattered across my repositories 🧩.  
The goal is not just to look back, but to **celebrate, experiment, and build together**.

I warmly invite fellow retro-computing enthusiasts and comrades-in-arms 🤝  
to jump in, contribute ideas, add modules, demos, or improvements, and help this project grow.

Let’s keep the spirit of early computing alive 🚀

---

🎉 **HAPPY BIRTHDAY, KIM-1!** 🎉  
Wishing you — and all of us — a fantastic and hacky **Year 2026** 🥳✨


https://github.com/user-attachments/assets/4e9a981a-51b0-4728-888d-ba34f7d75d37




**Things that are very useful in this code:**

Take any coordinates in HEX out of the memory and use them to place your cursor.
The problem is, that to position your cursur, you need to send the x/y coordinates as single chars to the terminal program, like (ESC)[xx;yyH  - Imagine just having hex data, i.e. $20 (32 dec) and you need to  send a 3 and a 2 separated to your terminal... This routine will do it - seperate the tens from the ones. Now you can like draw a rectangle, a circle or whatever. You can start a painting program if you like.
```
; ANSI Cursor positionieren (Row ; Col)
GOTOXY:
          LDA #$1B      ; ESC
          JSR CHOUT
          LDA #$5B      ; '['
          JSR CHOUT
          
          LDA CURY      ; Row zuerst
          JSR PUTDEC
          
          LDA #$3B      ; ';'
          JSR CHOUT
          
          LDA CURX      ; Column danach
          JSR PUTDEC
          
          LDA #$48      ; 'H'
          JSR CHOUT
          RTS

; Dezimalzahl ausgeben (A-Register, 0-99)
; Benutzt TEMP als temporäre Variable
PUTDEC:
          STA TEMP      ; Wert sichern
          LDY #0        ; Zehner-Zähler
          
PUTDEC_T: CMP #10
          BCS PUTDEC_S  ; >= 10
          JMP PUTDEC_D
PUTDEC_S: SEC
          SBC #10
          INY
          JMP PUTDEC_T
          
PUTDEC_D: ; A enthält Einer
          TAX           ; Einer nach X retten
          
          TYA           ; Zehner
          BNE PUTDEC_Z  ; Wenn nicht 0
          JMP PUTDEC1
PUTDEC_Z: CLC
          ADC #$30      ; In ASCII umwandeln
          JSR CHOUT
          
PUTDEC1:  TXA           ; Einer zurück
          CLC
          ADC #$30      ; In ASCII umwandeln
          JSR CHOUT
          
          LDA TEMP      ; Original wiederherstellen
          RTS
```
