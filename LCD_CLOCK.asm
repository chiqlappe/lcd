
;============================================================
;割り込みモード１を使用したLCD時計表示プログラム for PC-8001
;2020/1/19
;============================================================

TMR_RD		EQU	1602H		;タイマリード
MON		EQU	5C66H		;モニタ
TMR_WRK		EQU	0EA76H		;タイマのワークエリア
RS232BUF	EQU	0EDCEH		;RS-232Cバッファ
RST38		EQU	0F1E3H		;RST 38Hのジャンプ先

	ORG	RS232BUF

;-----------------------------
;割り込み初期化
;-----------------------------
INIT_INT:
	IM	1		;割り込みモード1に設定
	DI
	LD	HL,RST38
	LD	(HL),0C3H	;="JP"
	INC	HL
	LD	(HL),INT_MAIN - (INT_MAIN / 100H) * 100H
	INC	HL
	LD	(HL),INT_MAIN / 100H

	CALL	INIT_LCD	;LCD初期化

	EI
	JP	MON

;-----------------------------
;割り込み処理
;-----------------------------
INT_MAIN:
	DI
	PUSH	AF
	PUSH	BC
	PUSH	DE
	PUSH	HL
	PUSH	IX
	PUSH	IY

	CALL	LCD_CLOCK	;

	POP	IY
	POP	IX
	POP	HL
	POP	DE
	POP	BC
	POP	AF
	EI
	RETI

;-----------------------------
;LCD時計
;-----------------------------

LCD_CLOCK:
	CALL	TMR_RD		;(TMR_WRK)にタイマー情報をBCDでセットする

	LD	HL,0300H	;LOCATE 3,0
	CALL	CMD_LOCATE	;
	LD	HL,TMR_WRK+5	;SEC,MIN,HOUR,DAY,MONTH,YEAR
	LD	A,(HL)		;YEAR
	DEC	HL		;
	CALL	PRT_BCD		;
	LD	A,"/"		;
	CALL	SEND_DATA	;
	LD	A,(HL)		;MONTH
	DEC	HL		;
	CALL	PRT_BCD		;
	LD	A,"/"		;
	CALL	SEND_DATA	;
	LD	A,(HL)		;DAY
	DEC	HL		;
	CALL	PRT_BCD		;

	PUSH	HL		;
	LD	HL,0301H	;LOCATE 3,1
	CALL	CMD_LOCATE	;
	POP	HL		;

	LD	A,(HL)		;HOUR
	DEC	HL		;
	CALL	PRT_BCD		;
	LD	A,":"		;
	CALL	SEND_DATA	;
	LD	A,(HL)		;MIN
	DEC	HL		;
	CALL	PRT_BCD		;
	LD	A,":"		;
	CALL	SEND_DATA	;
	LD	A,(HL)		;SEC
	DEC	HL		;
	CALL	PRT_BCD		;

	RET

;-----------------------------
;BCDをLCDに出力
;IN	A=BCD
;-----------------------------
PRT_BCD:
	PUSH	AF
	AND	0F0H
	SRL	A
	SRL	A
	SRL	A
	SRL	A
	CALL	.SUB
	POP	AF
	AND	0FH
.SUB:	ADD	A,"0"
	CALL	SEND_DATA
	RET


INCLUDE	"LCD.asm"		;LCDドライバ

