
;******************************* 
;* The KIM-1 is 50 Demo \0/    *
;*                             *
;* coded by netzherpes in 2025 *
;*******************************



; Konstanten
        
CHOUT   = $1EA0		    ; KIM-1 ROM Routine für Zeichenausgabe
GETCH   = $1E5A	        ; KIM-1 ROUTINE for input 
DATAPTR = $00           ; Zero Page Pointer (Low Byte)
DATAPTH = $01           ; Zero Page Pointer (High Byte)
counter = $06
tmp 	= $10
    SAD     = $1740      ; data port for pins 1-4
    SADD    = $1741
    SBD     = $1742      ; data port for pins 5-6
    SBDD    = $1743
    TIMER2  = $1747      ; optional 2nd 6532 timer
    led1    = $08        ; LED selectors (left to right)
    led2    = $0a
    led3    = $0c
    led4    = $0e
    led5    = $10
    led6    = $12
    lout    = $7f        ; set pins as output to left 4 LEDs
    rout    = $1e        ; set pins as output to right 2 LEDs
    tmr     = $db
    ptr     = $dc
    xfrhi   = $dd
    xfrlo   = $de
    tmp1    = $df
    cbuff   = $e8


; Zero Page Variablen TEIL 2
STAR0     = $30      ; Stern 0: Dir, X, Y, OldX, OldY (5 Bytes)
STAR1     = $35      ; Stern 1: Dir, X, Y, OldX, OldY (5 Bytes)
STAR2     = $3A      ; Stern 2: Dir, X, Y, OldX, OldY (5 Bytes)
STAR3     = $3F      ; Stern 3: Dir, X, Y, OldX, OldY (5 Bytes)
STAR4     = $44      ; Stern 4: Dir, X, Y, OldX, OldY (5 Bytes)
RNDVAL    = $49      ; Zufallswert
CURX      = $4A      ; Aktuelle X-Position für GOTOXY
CURY      = $4B      ; Aktuelle Y-Position für GOTOXY
TEMP      = $4C      ; Temporär
STARPTR   = $4D      ; Zeiger auf aktuellen Stern
RADIUS    = $4E      ; Radius
ANGLE     = $4F      ; Winkel (0-3)
DRAWCHAR  = $50      ; Zeichen zum Zeichnen
CENTERX_V = $51      ; Variables Zentrum X
CENTERY_V = $52      ; Variables Zentrum Y
COLOR     = $53      ;the color


; Konstanten
CENTERX   = 40
CENTERY   = 12
STAR_CHR  = $2A      ; ASCII '*'
SPACE_CHR = $20      ; ASCII ' '

; Stern-Struktur
DIR_OFF   = 0        ; Richtung
X_OFF     = 1        ; X-Position
Y_OFF     = 2        ; Y-Position
OLDX_OFF  = 3        ; Alte X-Position
OLDY_OFF  = 4        ; Alte Y-Position

; define some pseudo-alphabet characters
    A_      = $f7
    _a      = $5f
    B_      = $ff
    _b      = $fc
    C_      = $b9
    _c      = $d8
    _d      = $de
    E_      = $f9
    _e      = $7b
    F_      = $f1
    G_      = $bd
    _g      = $ef
    H_      = $f6
    _h      = $f4
    I_      = $b0
    _i      = $10
    J_      = $9e
    K_      = $f0    ; non-standard
    L_      = $b8
    _l      = $86
    _m      = $a3    ; non-standard
    N_      = $b7
    _n      = $54
    O_      = $bf
    _o      = $dc
    P_      = $f3
    _q      = $e7
    R_      = $31
    _r      = $d0
    S_      = $ed
    _t      = $f8
    U_      = $be
    _u      = $9c
    _v      = $c2    ; non-standard
    _w      = $0c    ; the right half after _u
    _x      = $e4    ; non-standard
    Y_      = $ee
    Z_      = $5b
    Qmrk    = $d3
    dsh     = $c0
    spc     = $80
    ch0     = $bf
    ch1     = $86
    ch2     = $dB
    ch3     = $cf
    ch4     = $e6
    ch5     = $ed
    ch6     = $fd
    ch7     = $87
    ch8     = $ff
    ch9     = $ef


.ORG $2000

;--------------PART 1 -------------------------------------------

INIT:   LDA #10
		STA counter	; Repeat the KIM-flash 10 times
START:
        ; Initialisiere Zeiger auf ASCII-Daten
        LDA #<ASCIIDATA     ; Low Byte der Datenadresse
        STA DATAPTR
        LDA #>ASCIIDATA     ; High Byte der Datenadresse  
        STA DATAPTH
				
LOOP:   
        ; Lade nächstes Zeichen
        LDY #$00
        LDA (DATAPTR),Y
        
        ; Prüfe auf String-Ende (Null-Byte)
        BEQ START1 
        
        ; Gebe Zeichen aus
        JSR CHOUT
		; Inkrementiere Zeiger
        INC DATAPTR
        BNE LOOP            ; Wenn Low Byte nicht übergelaufen
        INC DATAPTH         ; Inkrementiere High Byte bei Überlauf
        JMP LOOP
START1:
        ; Initialisiere Zeiger auf ASCII-Daten
        LDA #<ANSIDATA     ; Low Byte der Datenadresse
        STA DATAPTR
        LDA #>ANSIDATA     ; High Byte der Datenadresse  
        STA DATAPTH
				
LOOP1:  
        ; Lade nächstes Zeichen
        LDY #$00
        LDA (DATAPTR),Y
        
        ; Prüfe auf String-Ende (Null-Byte)
        BEQ DONE1
        
        ; Gebe Zeichen aus
        JSR CHOUT

		STA tmp
		LDA #$FF
		STA tmp+1
RLY1:   DEC tmp+1
		nop
		LDA tmp+1
		BNE RLY1
		LDA tmp
				
		; Inkrementiere Zeiger
        INC DATAPTR
        BNE LOOP1            ; Wenn Low Byte nicht übergelaufen
        INC DATAPTH         ; Inkrementiere High Byte bei Überlauf
        JMP LOOP1

DONE1:
        ; Programm part 1 beenden - now the greetings
        DEC counter
		LDA counter
		BEQ FINI
		jmp START1

;--------------PART 2 -------------------------------------------

FINI:
		LDA #<GREET     ; Low Byte der Datenadresse
        STA DATAPTR
        LDA #>GREET     ; High Byte der Datenadresse  
        STA DATAPTH
LOOP3:
        ; Lade nächstes Zeichen
        LDY #$00
        LDA (DATAPTR),Y
        
        ; Prüfe auf String-Ende (Null-Byte)
        BEQ END
        
        ; Gebe Zeichen aus
        JSR CHOUT
		; Inkrementiere Zeiger
        INC DATAPTR
        BNE LOOP3            ; Wenn Low Byte nicht übergelaufen
        INC DATAPTH         ; Inkrementiere High Byte bei Überlauf
        JMP LOOP3

END: 
    lo0     = <msg0
    hi0     = >msg0
            
    scroll: ldy #hi0
            lda #lo0
            jsr scan
			jmp scroll
           
    scan:   sty xfrlo       ; y and a get loaded before jsr to scan
            sta xfrhi
            lda #$07        ; init scan forward
            sta tmp1
            ldy #$05        ; init y
    cont:   ldx #$05        ; init x
    char:   lda (xfrhi),y   ; get character
            cmp #$00        ; last character?
            bne more        ; if not, continue
            jmp C_START				; or jumo to the next part? hmmmm
    more:   sta cbuff,x     ; store char
            dey             ; set up next char
            dex             ; set up next store loc
            bpl char        ; loop if not 6th char
            cld             ; binary mode
            clc             ; prepare to add (clear carry flag)
            tya             ; get char pointer
            adc tmp1        ; update for 6 new characters
            sta ptr         ; save new pointer
            jsr dspdly      ; delay display
            ldy ptr         ; restore pointer
            jmp cont        ; continue with rest of message
    dspdly: ldx #$0a        ; set the delay rate here
            stx tmr         ; put in decr. location
    time:   lda #$52        ; load timer
            sta TIMER2      ; start timer
    lite:   jsr disp        ; gosub display rtn
            bit TIMER2      ; timer done?
            bpl lite        ; if not, loop
            dec tmr         ; decrement timer counter
            bne time        ; not finished
            rts             ; now get 6 new characters
    disp:   lda #lout       ; change left led segments
            sta SADD        ; to outputs
            ldy #$00        ; init recall index
            ldx #$09        ; init digit number
    six:    lda cbuff,y     ; get character
            sty $fc         ; save y for monitor disp routine
            jsr $1f4e       ; monitor routine - disp char, delay 500 cycles
            iny             ; set up for next char
            cpy #$06        ; 6 char displayed?
            bcc six         ; no
           	rts

; Let thew show begin!
; First acsii animation


;--------------PART 3 -------------------------------------------

C_START:
          JSR CLEARSCR
          LDA #$10
		  STA counter
          ; Zufallsgenerator initialisieren
          LDA #$A5
          STA RNDVAL
          
          LDA #2
          STA RADIUS
          
          ; Zufälliges Zentrum und Farbe wählen
          JSR NEWCENTER
          JSR NEWCOLOR

GROWLOOP:
          ; Kreis zeichnen
          LDA #0
          STA ANGLE
          
DRAWLOOP: 
          LDA #STAR_CHR
          JSR DRAW_ALL
          
          INC ANGLE
          LDA ANGLE
          CMP #4
          BCC DRAWLOOP
          
          ; Verzögerung
          LDX #$05
DELAY1:   LDY #$80
DELAY2:   DEY
          BNE DELAY2
          DEX
          BNE DELAY1
          
          ; Alten Kreis löschen
          LDA #0
          STA ANGLE
          
ERASELOOP:
          LDA #SPACE_CHR
          JSR DRAW_ALL
          
          INC ANGLE
          LDA ANGLE
          CMP #4
          BCC ERASELOOP
          
          ; Radius erhöhen
          INC RADIUS
          LDA RADIUS
          CMP #12       ; GEÄNDERT: 12 statt 18
          BCC GROWLOOP
          
          ; Von vorne mit neuem Zentrum
		  DEC counter      ;bitte nur 16 wiederholungen
		  LDA counter
		  BEQ STRJMP
          JSR CLEARSCR
          LDA #2
          STA RADIUS
          JSR NEWCENTER
          JSR NEWCOLOR
          JMP GROWLOOP
STRJMP:   
		  LDA #97
		  STA COLOR
		  JSR SETCOLR
		  JMP STERN   ;change to a dispplay scroller!

; Neues zufälliges Zentrum wählen
NEWCENTER:
          ; X: 32-48 (Range 16)
          JSR RANDOM2
          AND #$0F      ; 0-15
          CLC
          ADC #32       ; 32-47
          STA CENTERX_V
          
          ; Y: 8-16 (Range 8)
          JSR RANDOM2
          AND #$07      ; 0-7
          CLC
          ADC #8        ; 8-15
          STA CENTERY_V
          RTS

; Neue zufällige Farbe wählen (31-37)
NEWCOLOR:
          JSR RANDOM2
          AND #$07      ; 0-7
          CMP #7        ; Wenn >= 7, neu würfeln
          BCS NEWCOLOR
          CLC
          ADC #31       ; 31-37
          STA COLOR
          
; Farbe setzen: ESC[Xm
SETCOLR:   LDA #$1B      ; ESC
          JSR CHOUT
          LDA #$5B      ; '['
          JSR CHOUT
          LDA COLOR
          JSR PUTDEC
          LDA #$6D      ; 'm'
          JSR CHOUT
          RTS

; Zufallszahl 0-255 erzeugen
RANDOM2:
          LDA RNDVAL
          ASL           ; Bit 7 ins Carry
          BCC RAND2
          EOR #$1D      ; Polynom für 8-bit LFSR
RAND2:    STA RNDVAL
          RTS

; Alle 4 Quadranten zeichnen
; A = Zeichen (STAR oder SPACE)
DRAW_ALL:
          STA DRAWCHAR  ; In eigene Variable!
          
          JSR CALC_Q0
          JSR PLOT
          
          JSR CALC_Q1
          JSR PLOT
          
          JSR CALC_Q2
          JSR PLOT
          
          JSR CALC_Q3
          JSR PLOT
          
          RTS

PLOT:
          JSR GOTOXY
          LDA DRAWCHAR  ; Von eigener Variable lesen
          JSR CHOUT
          RTS

; Q0: X=center+cos*r (VOLL), Y=center-sin*r/2 (HALB!)
CALC_Q0:
          LDA #4
          SEC
          SBC ANGLE
          TAX
          LDA SINTAB,X
          JSR SCALE
          ; X bleibt voll
          CLC
          ADC CENTERX_V
          STA CURX
          
          LDX ANGLE
          LDA SINTAB,X
          JSR SCALE
          LSR           ; Y halbieren für 2:1 Verhältnis!
          STA TEMP
          LDA CENTERY_V
          SEC
          SBC TEMP
          STA CURY
          RTS

; Q1: X=center-sin*r (VOLL), Y=center-cos*r/2 (HALB!)
CALC_Q1:
          LDX ANGLE
          LDA SINTAB,X
          JSR SCALE
          ; X bleibt voll
          STA TEMP
          LDA CENTERX_V
          SEC
          SBC TEMP
          STA CURX
          
          LDA #4
          SEC
          SBC ANGLE
          TAX
          LDA SINTAB,X
          JSR SCALE
          LSR           ; Y halbieren!
          STA TEMP
          LDA CENTERY_V
          SEC
          SBC TEMP
          STA CURY
          RTS

; Q2: X=center-cos*r (VOLL), Y=center+sin*r/2 (HALB!)
CALC_Q2:
          LDA #4
          SEC
          SBC ANGLE
          TAX
          LDA SINTAB,X
          JSR SCALE
          ; X bleibt voll
          STA TEMP
          LDA CENTERX_V
          SEC
          SBC TEMP
          STA CURX
          
          LDX ANGLE
          LDA SINTAB,X
          JSR SCALE
          LSR           ; Y halbieren!
          CLC
          ADC CENTERY_V
          STA CURY
          RTS

; Q3: X=center+sin*r (VOLL), Y=center+cos*r/2 (HALB!)
CALC_Q3:
          LDX ANGLE
          LDA SINTAB,X
          JSR SCALE
          ; X bleibt voll
          CLC
          ADC CENTERX_V
          STA CURX
          
          LDA #4
          SEC
          SBC ANGLE
          TAX
          LDA SINTAB,X
          JSR SCALE
          LSR           ; Y halbieren!
          CLC
          ADC CENTERY_V
          STA CURY
          RTS

SCALE:
          STA TEMP
          LDY RADIUS
          BEQ SCDONE
          LDA #0
SCLOOP:   CLC
          ADC TEMP
          DEY
          BNE SCLOOP
          ; Jetzt / 20 (weil SINTAB jetzt 0-20 statt 0-10)
          LDX #0
DIVLOOP:  CMP #20
          BCC DIVDONE
          SEC
          SBC #20
          INX
          JMP DIVLOOP
DIVDONE:  TXA
SCDONE:   RTS

;--------------PART 4 -------------------------------------------

STERN:   JSR CLEARSCR  ; Bildschirm löschen
          
; the end 
          LDA #24
		  STA CURY
		  LDA #60
		  STA CURX
		  JSR GOTOXY
		  LDA #$54    ;T
          JSR CHOUT
          LDA #$48    ;H
          JSR CHOUT
          LDA #$45    ;E 
          JSR CHOUT
          LDA #$20    ;SPC 
          JSR CHOUT
		  LDA #$20    ;SPC 
          JSR CHOUT
		  LDA #$45    ;E
          JSR CHOUT
          LDA #$4E    ;N 
          JSR CHOUT
          LDA #$44    ;D 
          JSR CHOUT
		  
          LDA #$A5      ; Seed für Zufallsgenerator
          STA RNDVAL
          
          ; Alle 5 Sterne initialisieren
          LDA #STAR0
          JSR INITSTAR
          LDA #STAR1
          JSR INITSTAR
          LDA #STAR2
          JSR INITSTAR
          LDA #STAR3
          JSR INITSTAR
          LDA #STAR4
          JSR INITSTAR

MAINLOOP:
          ; Verzögerung
          LDX #$80
DELAY3:   DEX
          BNE DELAY3
          
          ; Alle 5 Sterne bewegen
          LDA #STAR0
          JSR MOVESTAR
          LDA #STAR1
          JSR MOVESTAR
          LDA #STAR2
          JSR MOVESTAR
          LDA #STAR3
          JSR MOVESTAR
          LDA #STAR4
          JSR MOVESTAR
          
          JMP MAINLOOP

; Stern initialisieren
; A = Adresse des Sterns
INITSTAR:
          STA STARPTR
          LDX STARPTR
          
          ; Zufällige Richtung (1-16)
          JSR RANDOM
          CLC
          ADC #1
          STA DIR_OFF,X
          
          ; Position in Mitte
          LDA #CENTERX
          STA X_OFF,X
          LDA #CENTERY
          STA Y_OFF,X
          
          ; Alte Position = aktuelle Position
          STA OLDY_OFF,X
          LDA #CENTERX
          STA OLDX_OFF,X
          
          RTS

; Stern bewegen
; A = Adresse des Sterns
MOVESTAR:
          STA STARPTR
          LDX STARPTR
          
          ; Alte Position speichern
          LDA X_OFF,X
          STA OLDX_OFF,X
          LDA Y_OFF,X
          STA OLDY_OFF,X
          
          ; Richtung laden und bewegen
          LDA DIR_OFF,X
          STA TEMP
          
          LDA TEMP
          CMP #1
          BNE CHK2
          JMP DIR1
CHK2:     CMP #2
          BNE CHK3
          JMP DIR2
CHK3:     CMP #3
          BNE CHK4
          JMP DIR3
CHK4:     CMP #4
          BNE CHK5
          JMP DIR4
CHK5:     CMP #5
          BNE CHK6
          JMP DIR5
CHK6:     CMP #6
          BNE CHK7
          JMP DIR6
CHK7:     CMP #7
          BNE CHK8
          JMP DIR7
CHK8:     CMP #8
          BNE CHK9
          JMP DIR8
CHK9:     CMP #9
          BNE CHK10
          JMP DIR9
CHK10:    CMP #10
          BNE CHK11
          JMP DIR10
CHK11:    CMP #11
          BNE CHK12
          JMP DIR11
CHK12:    CMP #12
          BNE CHK13
          JMP DIR12
CHK13:    CMP #13
          BNE CHK14
          JMP DIR13
CHK14:    CMP #14
          BNE CHK15
          JMP DIR14
CHK15:    CMP #15
          BNE CHK16
          JMP DIR15
CHK16:    JMP DIR16

DIR1:     ; Zwei nach links
          LDX STARPTR
          LDA X_OFF,X
          SEC
          SBC #2
          STA X_OFF,X
          JMP CHECKMOVE
          
DIR2:     ; Zwei nach rechts
          LDX STARPTR
          LDA X_OFF,X
          CLC
          ADC #2
          STA X_OFF,X
          JMP CHECKMOVE
          
DIR3:     ; Eins nach oben
          LDX STARPTR
          LDA Y_OFF,X
          SEC
          SBC #1
          STA Y_OFF,X
          JMP CHECKMOVE
          
DIR4:     ; Eins nach unten
          LDX STARPTR
          LDA Y_OFF,X
          CLC
          ADC #1
          STA Y_OFF,X
          JMP CHECKMOVE
          
DIR5:     ; Zwei rechts, eins oben
          LDX STARPTR
          LDA X_OFF,X
          CLC
          ADC #2
          STA X_OFF,X
          LDA Y_OFF,X
          SEC
          SBC #1
          STA Y_OFF,X
          JMP CHECKMOVE
          
DIR6:     ; Eins rechts, zwei oben
          LDX STARPTR
          LDA X_OFF,X
          CLC
          ADC #1
          STA X_OFF,X
          LDA Y_OFF,X
          SEC
          SBC #2
          STA Y_OFF,X
          JMP CHECKMOVE
          
DIR7:     ; Eins rechts, zwei unten
          LDX STARPTR
          LDA X_OFF,X
          CLC
          ADC #1
          STA X_OFF,X
          LDA Y_OFF,X
          CLC
          ADC #2
          STA Y_OFF,X
          JMP CHECKMOVE
          
DIR8:     ; Zwei rechts, eins unten
          LDX STARPTR
          LDA X_OFF,X
          CLC
          ADC #2
          STA X_OFF,X
          LDA Y_OFF,X
          CLC
          ADC #1
          STA Y_OFF,X
          JMP CHECKMOVE
          
DIR9:     ; Eins links, zwei oben
          LDX STARPTR
          LDA X_OFF,X
          SEC
          SBC #1
          STA X_OFF,X
          LDA Y_OFF,X
          SEC
          SBC #2
          STA Y_OFF,X
          JMP CHECKMOVE
          
DIR10:    ; Zwei links, eins unten
          LDX STARPTR
          LDA X_OFF,X
          SEC
          SBC #2
          STA X_OFF,X
          LDA Y_OFF,X
          CLC
          ADC #1
          STA Y_OFF,X
          JMP CHECKMOVE
          
DIR11:    ; Eins links, ein unten
          LDX STARPTR
          LDA X_OFF,X
          SEC
          SBC #1
          STA X_OFF,X
          LDA Y_OFF,X
          CLC
          ADC #1
          STA Y_OFF,X
          JMP CHECKMOVE
          
DIR12:    ; Zwei links, eins oben
          LDX STARPTR
          LDA X_OFF,X
          SEC
          SBC #2
          STA X_OFF,X
          LDA Y_OFF,X
          SEC
          SBC #1
          STA Y_OFF,X
          JMP CHECKMOVE

DIR13:    ; Vier rechts, eins oben
          LDX STARPTR
          LDA X_OFF,X
          CLC
          ADC #4
          STA X_OFF,X
          LDA Y_OFF,X
          SEC
          SBC #1
          STA Y_OFF,X
          JMP CHECKMOVE

DIR14:    ; Vier rechts, eins unten
          LDX STARPTR
          LDA X_OFF,X
          CLC
          ADC #4
          STA X_OFF,X
          LDA Y_OFF,X
          CLC
          ADC #1
          STA Y_OFF,X
          JMP CHECKMOVE

DIR15:    ; Vier links, eins oben
          LDX STARPTR
          LDA X_OFF,X
          SEC
          SBC #4
          STA X_OFF,X
          LDA Y_OFF,X
          SEC
          SBC #1
          STA Y_OFF,X
          JMP CHECKMOVE

DIR16:    ; Vier links, eins unten
          LDX STARPTR
          LDA X_OFF,X
          SEC
          SBC #4
          STA X_OFF,X
          LDA Y_OFF,X
          CLC
          ADC #1
          STA Y_OFF,X

CHECKMOVE:
          ; Prüfen ob außerhalb des Bildschirms
          LDX STARPTR
          LDA X_OFF,X
          BEQ RESTART   ; X=0
          CMP #80
          BCS RESTART   ; X>=80
          LDA Y_OFF,X
          BEQ RESTART   ; Y=0
          CMP #25
          BCS RESTART   ; Y>=25
          
          ; Alte Position löschen
          LDA OLDX_OFF,X
          STA CURX
          LDA OLDY_OFF,X
          STA CURY
          JSR GOTOXY
          LDA #SPACE_CHR
          JSR CHOUT
          
          ; Neue Position zeichnen
          LDX STARPTR
          LDA X_OFF,X
          STA CURX
          LDA Y_OFF,X
          STA CURY
          JSR GOTOXY
          LDA #STAR_CHR
          JSR CHOUT
          RTS

RESTART:
          ; Alte Position löschen bevor Stern neu startet
          LDX STARPTR
          LDA OLDX_OFF,X
          STA CURX
          LDA OLDY_OFF,X
          STA CURY
          JSR GOTOXY
          LDA #SPACE_CHR
          JSR CHOUT
          
          ; Stern neu starten
          LDA STARPTR
          JSR INITSTAR
          RTS

; Zufallszahl 0-15 erzeugen
; Ergebnis in A-Register
RANDOM:
          LDA RNDVAL
          ASL           ; Bit 7 ins Carry
          BCC RAND1
          EOR #$1D      ; Polynom für 8-bit LFSR
RAND1:    STA RNDVAL
          
          ; Jetzt auf 0-15 reduzieren durch Rechtsshift
          LSR           ; Shift right
          LSR           ; Shift right
          LSR           ; Shift right
          LSR           ; Shift right
          ; A enthält jetzt 0-15
          RTS

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

; Bildschirm löschen (ANSI)
CLEARSCR:
          LDA #$1B      ; ESC
          JSR CHOUT
          LDA #$5B      ; '['
          JSR CHOUT
          LDA #$32      ; '2'
          JSR CHOUT
          LDA #$4A      ; 'J'
          JSR CHOUT
          RTS


ANSIDATA:
        
; positionieren

	    .BYTE $1B, "[13;20H"    ; Position Y=12, X=20

; Sequenz 1: Weißer, blinkender Text
        .BYTE $1B, "[37m"   ; Hell, blink, weiß
        .BYTE "*** 50 YEARS KIM-1 ***"
        
; Pause durch Spaces (für Timing)
        .BYTE "                "  ; 16 Leerzeichen

; Zurück zur Position
        .BYTE $1B, "[13;20H"

; Sequenz 2: Hellblauer, blinkender Text
        .BYTE $1B, "[36m"   ; Hell, blink, hellblau (bright cyan)
        .BYTE "*** 50 YEARS KIM-1 ***"
        .BYTE "                "

; Zurück zur Position  
        .BYTE $1B, "[13;20H"

; Sequenz 3: Dunkelblauer, blinkender Text
        .BYTE $1B, "[34m"   ; Hell, blink, blau
        .BYTE "*** 50 YEARS KIM-1 ***"
        .BYTE "                "

; Zurück zur Position
        .BYTE $1B, "[13;20H"

; Sequenz 4: Schwarzer Text (unsichtbar)
        .BYTE $1B, "[30m"   ; Hell, blink, schwarz
        .BYTE "*** 50 YEARS KIM-1 ***"
        .BYTE "                "
        .BYTE $1B, "[0m"      
; Attribute zurücksetzen
        .BYTE $00               ; String-Terminator

; Now the BG picture 
; tadaaaaa
	
ASCIIDATA:
		.BYTE $1B, "[H"         ; Position home
		.BYTE $1B, "[?25l"      ; cursor off
        .BYTE $1B, "[2J"        ; Clear screen
        .byte $20
        .byte $58
        .byte $58
        .byte $58
        .byte $58
        .byte $58
        .byte $20
        .byte $58
        .byte $58
        .byte $58
        .byte $20
        .byte $20
        .byte $20
        .byte $58
        .byte $58
        .byte $58
        .byte $20
        .byte $20
        .byte $20
        .byte $20
        .byte $20
        .byte $20
        .byte $20
        .byte $20
        .byte $20
        .byte $20
        .byte $58
        .byte $58
        .byte $58
        .byte $58
        .byte $58
        .byte $58
        .byte $20
        .byte $20
        .byte $20
        .byte $20
        .byte $20
        .byte $20
        .byte $20
        .byte $20
        .byte $20
        .byte $20
        .byte $20
        .byte $58
        .byte $58
        .byte $58
        .byte $58
        .byte $58
        .byte $58
        .byte $58
        .byte $58
        .byte $58
        .byte $58
        .byte $58
        .byte $58
        .byte $0D
        .byte $0A
        .byte $20
        .byte $58
        .byte $58
        .byte $58
        .byte $58
        .byte $58
        .byte $20
        .byte $58
        .byte $58
        .byte $58
        .byte $58
        .byte $58
        .byte $20
        .byte $58
        .byte $58
        .byte $58
        .byte $58
        .byte $58
        .byte $20
        .byte $20
        .byte $20
        .byte $20
        .byte $20
        .byte $58
        .byte $58
        .byte $58
        .byte $58
        .byte $58
        .byte $58
        .byte $58
        .byte $58
        .byte $58
        .byte $58
        .byte $58
        .byte $58
        .byte $20
        .byte $20
        .byte $20
        .byte $20
        .byte $20
        .byte $20
        .byte $58
        .byte $58
        .byte $58
        .byte $58
        .byte $58
        .byte $58
        .byte $58
        .byte $58
        .byte $58
        .byte $58
        .byte $58
        .byte $58
        .byte $58
        .byte $58
        .byte $0D
        .byte $0A
        .byte $20
        .byte $58
        .byte $58
        .byte $58
        .byte $58
        .byte $58
        .byte $20
        .byte $58
        .byte $58
        .byte $58
        .byte $58
        .byte $58
        .byte $20
        .byte $58
        .byte $58
        .byte $58
        .byte $58
        .byte $58
        .byte $20
        .byte $20
        .byte $20
        .byte $20
        .byte $58
        .byte $58
        .byte $58
        .byte $58
        .byte $58
        .byte $58
        .byte $58
        .byte $58
        .byte $58
        .byte $58
        .byte $58
        .byte $58
        .byte $58
        .byte $58
        .byte $20
        .byte $20
        .byte $20
        .byte $20
        .byte $58
        .byte $58
        .byte $58
        .byte $58
        .byte $58
        .byte $58
        .byte $58
        .byte $58
        .byte $58
        .byte $58
        .byte $58
        .byte $58
        .byte $58
        .byte $58
        .byte $58
        .byte $0D
        .byte $0A
        .byte $20
        .byte $58
        .byte $58
        .byte $58
        .byte $58
        .byte $58
        .byte $20
        .byte $58
        .byte $58
        .byte $58
        .byte $58
        .byte $58
        .byte $20
        .byte $58
        .byte $58
        .byte $58
        .byte $58
        .byte $58
        .byte $20
        .byte $20
        .byte $20
        .byte $58
        .byte $58
        .byte $58
        .byte $58
        .byte $58
        .byte $58
        .byte $58
        .byte $58
        .byte $58
        .byte $58
        .byte $58
        .byte $58
        .byte $58
        .byte $58
        .byte $58
        .byte $58
        .byte $0D
        .byte $0A
        .byte $20
        .byte $58
        .byte $58
        .byte $58
        .byte $58
        .byte $58
        .byte $20
        .byte $58
        .byte $58
        .byte $58
        .byte $58
        .byte $58
        .byte $20
        .byte $58
        .byte $58
        .byte $58
        .byte $58
        .byte $58
        .byte $20
        .byte $20
        .byte $58
        .byte $58
        .byte $58
        .byte $58
        .byte $58
        .byte $58
        .byte $58
        .byte $58
        .byte $58
        .byte $58
        .byte $58
        .byte $58
        .byte $58
        .byte $58
        .byte $58
        .byte $58
        .byte $58
        .byte $58
        .byte $20
        .byte $20
        .byte $58
        .byte $58
        .byte $58
        .byte $58
        .byte $58
        .byte $58
        .byte $58
        .byte $58
        .byte $58
        .byte $58
        .byte $58
        .byte $58
        .byte $58
        .byte $58
        .byte $58
        .byte $0D
        .byte $0A
        .byte $20
        .byte $58
        .byte $58
        .byte $58
        .byte $58
        .byte $58
        .byte $20
        .byte $58
        .byte $58
        .byte $58
        .byte $58
        .byte $58
        .byte $20
        .byte $58
        .byte $58
        .byte $58
        .byte $58
        .byte $58
        .byte $20
        .byte $20
        .byte $58
        .byte $58
        .byte $58
        .byte $58
        .byte $58
        .byte $58
        .byte $58
        .byte $58
        .byte $58
        .byte $58
        .byte $58
        .byte $58
        .byte $58
        .byte $58
        .byte $58
        .byte $58
        .byte $58
        .byte $58
        .byte $20
        .byte $20
        .byte $58
        .byte $58
        .byte $58
        .byte $58
        .byte $58
        .byte $58
        .byte $58
        .byte $58
        .byte $58
        .byte $58
        .byte $58
        .byte $58
        .byte $58
        .byte $58
        .byte $58
        .byte $0D
        .byte $0A
        .byte $20
        .byte $58
        .byte $58
        .byte $58
        .byte $58
        .byte $58
        .byte $20
        .byte $58
        .byte $58
        .byte $58
        .byte $58
        .byte $58
        .byte $20
        .byte $58
        .byte $58
        .byte $58
        .byte $58
        .byte $58
        .byte $20
        .byte $20
        .byte $58
        .byte $58
        .byte $58
        .byte $58
        .byte $58
        .byte $58
        .byte $58
        .byte $58
        .byte $58
        .byte $58
        .byte $58
        .byte $58
        .byte $58
        .byte $58
        .byte $58
        .byte $58
        .byte $58
        .byte $58
        .byte $20
        .byte $20
        .byte $58
        .byte $58
        .byte $58
        .byte $58
        .byte $58
        .byte $58
        .byte $58
        .byte $58
        .byte $58
        .byte $58
        .byte $58
        .byte $58
        .byte $58
        .byte $58
        .byte $58
        .byte $0D
        .byte $0A
        .byte $20
        .byte $58
        .byte $58
        .byte $58
        .byte $58
        .byte $58
        .byte $20
        .byte $58
        .byte $58
        .byte $58
        .byte $58
        .byte $58
        .byte $20
        .byte $58
        .byte $58
        .byte $58
        .byte $58
        .byte $58
        .byte $20
        .byte $20
        .byte $20
        .byte $58
        .byte $58
        .byte $58
        .byte $58
        .byte $58
        .byte $58
        .byte $58
        .byte $58
        .byte $58
        .byte $58
        .byte $58
        .byte $58
        .byte $58
        .byte $58
        .byte $58
        .byte $58
        .byte $0D
        .byte $0A
        .byte $20
        .byte $58
        .byte $58
        .byte $58
        .byte $58
        .byte $58
        .byte $20
        .byte $58
        .byte $58
        .byte $58
        .byte $58
        .byte $58
        .byte $20
        .byte $58
        .byte $58
        .byte $58
        .byte $58
        .byte $58
        .byte $20
        .byte $20
        .byte $20
        .byte $20
        .byte $58
        .byte $58
        .byte $58
        .byte $58
        .byte $58
        .byte $58
        .byte $58
        .byte $58
        .byte $58
        .byte $58
        .byte $58
        .byte $58
        .byte $58
        .byte $58
        .byte $20
        .byte $20
        .byte $20
        .byte $20
        .byte $58
        .byte $58
        .byte $58
        .byte $58
        .byte $58
        .byte $58
        .byte $58
        .byte $58
        .byte $58
        .byte $58
        .byte $58
        .byte $58
        .byte $58
        .byte $58
        .byte $58
        .byte $0D
        .byte $0A
        .byte $20
        .byte $58
        .byte $58
        .byte $58
        .byte $58
        .byte $58
        .byte $20
        .byte $58
        .byte $58
        .byte $58
        .byte $58
        .byte $58
        .byte $20
        .byte $58
        .byte $58
        .byte $58
        .byte $58
        .byte $58
        .byte $20
        .byte $20
        .byte $20
        .byte $20
        .byte $20
        .byte $58
        .byte $58
        .byte $58
        .byte $58
        .byte $58
        .byte $58
        .byte $58
        .byte $58
        .byte $58
        .byte $58
        .byte $58
        .byte $58
        .byte $20
        .byte $20
        .byte $20
        .byte $20
        .byte $20
        .byte $58
        .byte $58
        .byte $58
        .byte $58
        .byte $58
        .byte $58
        .byte $58
        .byte $58
        .byte $58
        .byte $58
        .byte $58
        .byte $58
        .byte $58
        .byte $58
        .byte $0D
        .byte $0A
        .byte $20
        .byte $58
        .byte $58
        .byte $58
        .byte $58
        .byte $58
        .byte $20
        .byte $58
        .byte $58
        .byte $58
        .byte $58
        .byte $58
        .byte $20
        .byte $58
        .byte $58
        .byte $58
        .byte $58
        .byte $58
        .byte $20
        .byte $20
        .byte $20
        .byte $20
        .byte $20
        .byte $20
        .byte $20
        .byte $20
        .byte $58
        .byte $58
        .byte $58
        .byte $58
        .byte $58
        .byte $58
        .byte $20
        .byte $20
        .byte $20
        .byte $20
        .byte $20
        .byte $20
        .byte $20
        .byte $20
        .byte $58
        .byte $58
        .byte $58
        .byte $58
        .byte $58
        .byte $58
        .byte $58
        .byte $58
        .byte $58
        .byte $58
        .byte $58
        .byte $58
        .byte $0D
        .byte $0A
        .byte $0D
        .byte $0A
        .byte $0D
        .byte $0A
        .byte $0D
        .byte $0A
        .byte $58
        .byte $58
        .byte $58
        .byte $58
        .byte $20
        .byte $20
        .byte $20
        .byte $58
        .byte $58
        .byte $58
        .byte $58
        .byte $20
        .byte $20
        .byte $20
        .byte $58
        .byte $58
        .byte $58
        .byte $58
        .byte $20
        .byte $20
        .byte $58
        .byte $58
        .byte $58
        .byte $58
        .byte $20
        .byte $20
        .byte $20
        .byte $20
        .byte $20
        .byte $20
        .byte $20
        .byte $20
        .byte $20
        .byte $20
        .byte $58
        .byte $58
        .byte $58
        .byte $58
        .byte $20
        .byte $20
        .byte $20
        .byte $20
        .byte $20
        .byte $20
        .byte $20
        .byte $20
        .byte $20
        .byte $20
        .byte $58
        .byte $58
        .byte $58
        .byte $58
        .byte $58
        .byte $58
        .byte $58
        .byte $58
        .byte $0D
        .byte $0A
        .byte $58
        .byte $58
        .byte $58
        .byte $58
        .byte $20
        .byte $20
        .byte $58
        .byte $58
        .byte $58
        .byte $58
        .byte $20
        .byte $20
        .byte $20
        .byte $20
        .byte $58
        .byte $58
        .byte $58
        .byte $58
        .byte $20
        .byte $20
        .byte $58
        .byte $58
        .byte $58
        .byte $58
        .byte $58
        .byte $58
        .byte $20
        .byte $20
        .byte $20
        .byte $20
        .byte $20
        .byte $20
        .byte $58
        .byte $58
        .byte $58
        .byte $58
        .byte $58
        .byte $58
        .byte $20
        .byte $20
        .byte $20
        .byte $20
        .byte $20
        .byte $20
        .byte $20
        .byte $20
        .byte $20
        .byte $20
        .byte $58
        .byte $58
        .byte $58
        .byte $58
        .byte $58
        .byte $58
        .byte $58
        .byte $58
        .byte $0D
        .byte $0A
        .byte $58
        .byte $58
        .byte $58
        .byte $58
        .byte $20
        .byte $58
        .byte $58
        .byte $58
        .byte $58
        .byte $20
        .byte $20
        .byte $20
        .byte $20
        .byte $20
        .byte $58
        .byte $58
        .byte $58
        .byte $58
        .byte $20
        .byte $20
        .byte $58
        .byte $58
        .byte $58
        .byte $58
        .byte $58
        .byte $58
        .byte $58
        .byte $20
        .byte $20
        .byte $20
        .byte $20
        .byte $58
        .byte $58
        .byte $58
        .byte $58
        .byte $58
        .byte $58
        .byte $58
        .byte $20
        .byte $20
        .byte $20
        .byte $20
        .byte $20
        .byte $20
        .byte $20
        .byte $20
        .byte $20
        .byte $20
        .byte $20
        .byte $20
        .byte $58
        .byte $58
        .byte $58
        .byte $58
        .byte $0D
        .byte $0A
        .byte $58
        .byte $58
        .byte $58
        .byte $58
        .byte $58
        .byte $58
        .byte $58
        .byte $58
        .byte $20
        .byte $20
        .byte $20
        .byte $20
        .byte $20
        .byte $20
        .byte $58
        .byte $58
        .byte $58
        .byte $58
        .byte $20
        .byte $20
        .byte $58
        .byte $58
        .byte $58
        .byte $58
        .byte $20
        .byte $58
        .byte $58
        .byte $58
        .byte $20
        .byte $20
        .byte $58
        .byte $58
        .byte $58
        .byte $20
        .byte $58
        .byte $58
        .byte $58
        .byte $58
        .byte $20
        .byte $20
        .byte $58
        .byte $58
        .byte $58
        .byte $58
        .byte $58
        .byte $58
        .byte $20
        .byte $20
        .byte $20
        .byte $20
        .byte $58
        .byte $58
        .byte $58
        .byte $58
        .byte $0D
        .byte $0A
        .byte $58
        .byte $58
        .byte $58
        .byte $58
        .byte $58
        .byte $58
        .byte $58
        .byte $58
        .byte $20
        .byte $20
        .byte $20
        .byte $20
        .byte $20
        .byte $20
        .byte $58
        .byte $58
        .byte $58
        .byte $58
        .byte $20
        .byte $20
        .byte $58
        .byte $58
        .byte $58
        .byte $58
        .byte $20
        .byte $58
        .byte $58
        .byte $58
        .byte $20
        .byte $20
        .byte $58
        .byte $58
        .byte $58
        .byte $20
        .byte $58
        .byte $58
        .byte $58
        .byte $58
        .byte $20
        .byte $20
        .byte $58
        .byte $58
        .byte $58
        .byte $58
        .byte $58
        .byte $58
        .byte $20
        .byte $20
        .byte $20
        .byte $20
        .byte $58
        .byte $58
        .byte $58
        .byte $58
        .byte $0D
        .byte $0A
        .byte $58
        .byte $58
        .byte $58
        .byte $58
        .byte $20
        .byte $58
        .byte $58
        .byte $58
        .byte $58
        .byte $20
        .byte $20
        .byte $20
        .byte $20
        .byte $20
        .byte $58
        .byte $58
        .byte $58
        .byte $58
        .byte $20
        .byte $20
        .byte $58
        .byte $58
        .byte $58
        .byte $58
        .byte $20
        .byte $20
        .byte $58
        .byte $58
        .byte $58
        .byte $58
        .byte $58
        .byte $58
        .byte $20
        .byte $20
        .byte $58
        .byte $58
        .byte $58
        .byte $58
        .byte $20
        .byte $20
        .byte $20
        .byte $20
        .byte $20
        .byte $20
        .byte $20
        .byte $20
        .byte $20
        .byte $20
        .byte $20
        .byte $20
        .byte $58
        .byte $58
        .byte $58
        .byte $58
        .byte $0D
        .byte $0A
        .byte $58
        .byte $58
        .byte $58
        .byte $58
        .byte $20
        .byte $20
        .byte $58
        .byte $58
        .byte $58
        .byte $58
        .byte $20
        .byte $20
        .byte $20
        .byte $20
        .byte $58
        .byte $58
        .byte $58
        .byte $58
        .byte $20
        .byte $20
        .byte $58
        .byte $58
        .byte $58
        .byte $58
        .byte $20
        .byte $20
        .byte $58
        .byte $58
        .byte $58
        .byte $58
        .byte $58
        .byte $58
        .byte $20
        .byte $20
        .byte $58
        .byte $58
        .byte $58
        .byte $58
        .byte $20
        .byte $20
        .byte $20
        .byte $20
        .byte $20
        .byte $20
        .byte $20
        .byte $20
        .byte $20
        .byte $20
        .byte $20
        .byte $20
        .byte $58
        .byte $58
        .byte $58
        .byte $58
        .byte $0D
        .byte $0A
        .byte $58
        .byte $58
        .byte $58
        .byte $58
        .byte $20
        .byte $20
        .byte $20
        .byte $58
        .byte $58
        .byte $58
        .byte $58
        .byte $20
        .byte $20
        .byte $20
        .byte $58
        .byte $58
        .byte $58
        .byte $58
        .byte $20
        .byte $20
        .byte $58
        .byte $58
        .byte $58
        .byte $58
        .byte $20
        .byte $20
        .byte $20
        .byte $58
        .byte $58
        .byte $58
        .byte $58
        .byte $20
        .byte $20
        .byte $20
        .byte $58
        .byte $58
        .byte $58
        .byte $58
        .byte $20
        .byte $20
        .byte $20
        .byte $20
        .byte $20
        .byte $20
        .byte $20
        .byte $20
        .byte $20
        .byte $20
        .byte $58
        .byte $58
        .byte $58
        .byte $58
        .byte $58
        .byte $58
        .byte $58
        .byte $58
        .byte $0D
        .byte $0A
        .byte $58
        .byte $58
        .byte $58
        .byte $58
        .byte $20
        .byte $20
        .byte $20
        .byte $20
        .byte $58
        .byte $58
        .byte $58
        .byte $58
        .byte $20
        .byte $20
        .byte $58
        .byte $58
        .byte $58
        .byte $58
        .byte $20
        .byte $20
        .byte $58
        .byte $58
        .byte $58
        .byte $58
        .byte $20
        .byte $20
        .byte $20
        .byte $58
        .byte $58
        .byte $58
        .byte $58
        .byte $20
        .byte $20
        .byte $20
        .byte $58
        .byte $58
        .byte $58
        .byte $58
        .byte $20
        .byte $20
        .byte $20
        .byte $20
        .byte $20
        .byte $20
        .byte $20
        .byte $20
        .byte $20
        .byte $20
        .byte $58
        .byte $58
        .byte $58
        .byte $58
        .byte $58
        .byte $58
        .byte $58
        .byte $58
        .byte $0D
        .byte $0A
		.byte $00
		
GREET:  
		.BYTE $1B, "[2J"        ; Clear screen
		.BYTE $1B, "[5;10H"
        .BYTE $1B, "[36m"
        .BYTE "greetings to:"
        .BYTE $1B, "[37m"
		.BYTE $1B, "[6;11H"
		.BYTE "Hans O"
		.BYTE $1B, "[7;12H"
		.BYTE "John K"
		.BYTE $1B, "[8;13H"
		.BYTE "Liu G"
		.BYTE $1B, "[9;14H"
		.BYTE "Dave H"
		.BYTE $1B, "[10;15H"
		.BYTE "Eduardo C"
		.BYTE $1B, "[11;16H"
		.BYTE "Ronny"
		.BYTE $1B, "[12;17H"
		.BYTE "Michael D"
		.BYTE $1B, "[13;18H"
		.BYTE "C.I.H.S (Dave)"
		.BYTE $1B, "[14;19H"
		.BYTE "Jim "
		.BYTE $1B, "[17;10H"
		.BYTE "Ruud B, Cameron K, Bob L, HJM, Ryan R, Carl M and all the rest I forgot"
		.BYTE $1B, "[19;10H"
		.BYTE $1B, "[36m"
		.BYTE "and now a little scroller :D"
		.BYTE $1B, "[37m"
	    .BYTE $00               ; String-Terminator

SINTAB:   .BYTE 0, 10, 17, 20, 20

 msg0:  .BYTE spc, spc, spc, spc, spc, H_, _a, P_, P_, Y_, spc, B_, _i, _r
		.BYTE _t, _h, _d, _a, Y_, spc, spc, ch5, ch0, spc
		.BYTE Y_, _e, _a, _r, S_, spc, spc, spc, spc, spc, $00
ending:
.END
        
		
		
		