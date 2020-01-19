;=============================
;SC1602BSLB LCDモジュール ドライバ
;=============================

LCD		EQU	10H		;LCDモジュールのポート番号

ENABLE_BIT	EQU	10000000B	;ENABLE信号のビット番号
RS_DATA		EQU	01000000B	;データレジスタ

;INSTRUCTIONS
INST_CLS	EQU	00000001B	;CLEAR DISPLAY
INST_HOME	EQU	00000010B	;CURSOR AT HOME
INST_ENTRY	EQU	00000100B	;ENTRY MODE SET
INST_DISP	EQU	00001000B	;DISPLAY ON/OFF CONTROL
INST_SHIFT	EQU	00010000B	;CURSOR/DISPLAY SHIFT
INST_FUNC	EQU	00100000B	;FUNCTION SET
INST_CGRAM	EQU	01000000B	;CGRAM ADDRESS SET
INST_DDRAM	EQU	10000000B	;DDRAM ADDRESS SET

CODE_2LINE	EQU	00001000B	;"2LINES"
CODE_INC	EQU	00000010B	;"INCREMENT"
CODE_DISP	EQU	00000100B	;"DISPLAY ON"
CODE_CURS	EQU	00000010B	;"CURSOR ON"
CODE_BLINK	EQU	00000001B	;"BLINK OF CURSOR"


;-----------------------------
;[LCD]LCD初期化
;-----------------------------
INIT_LCD:
	CALL	LCD_WAIT	;
	LD	B,3		;
.L1:	LD	A,00000011B	;8BITモードにセット
	CALL	SEND		;
	DJNZ	.L1		;

	LD	A,00000010B	;4BITモードにセット
	CALL	SEND		;

	LD	A,INST_FUNC+CODE_2LINE 	;
	LD	(COND_FUNC),A	;
	CALL	SEND_INST	;

	LD	A,INST_DISP+CODE_DISP	;
	LD	(COND_DISP),A	;
	CALL	SEND_INST	;

	LD	A,INST_ENTRY+CODE_INC	;
	LD	(COND_ENTRY),A	;
	CALL	SEND_INST	;

	CALL	CMD_CLS		;
	CALL	LCD_LWAIT	;

	RET

;-----------------------------
;[LCD]4BITモードでデータを送る
;IN	A=DATA
;-----------------------------
SEND_DATA:
	LD	B,A		;
	SRL	A		;A<-Aの上位4ビット
	SRL	A		;
	SRL	A		;
	SRL	A		;
	OR	RS_DATA		;RS信号を乗せる
	CALL	SEND		;
	LD	A,B		;
	AND	00001111B	;A<-Aの下位4ビット
	OR	RS_DATA		;
	CALL	SEND		;
	JR	LCD_WAIT	;

;-----------------------------
;[LCD]4BITモードで指示を送る
;IN	A=DATA
;-----------------------------
SEND_INST:
	LD	B,A		;
	SRL	A		;A<-Aの上位4ビット
	SRL	A		;
	SRL	A		;
	SRL	A		;
	CALL	SEND		;
	LD	A,B		;
	AND	00001111B	;A<-Aの下位4ビット
	CALL	SEND		;
	JR	LCD_WAIT	;

;-----------------------------
;[LCD]LCDにデータ・指示を送る
;IN	A=DATA
;-----------------------------
SEND:
	LD	C,LCD		;
	OUT	(C),A		;E<-LO
	CALL	LCD_WAIT		;

	OR	ENABLE_BIT	;E<-HI
	OUT	(C),A		;
	CALL	LCD_WAIT		;

	XOR	ENABLE_BIT	;E<-LO
	OUT	(C),A		;
	CALL	LCD_WAIT		;
	RET

;-----------------------------
;[LCD]現在のカーソル位置に文字列を出力する
;IN	HL=文字列ポインタ(00Hで終了)
;-----------------------------
LCD_PRT:
	PUSH	BC		;
	PUSH	DE		;
.LOOP:	LD	A,(HL)		;
	INC	HL		;
	AND	A		;
	JR	Z,.EXIT		;
	CALL	SEND_DATA	;
	JR	.LOOP		;

.EXIT:	POP	DE		;
	POP	BC		;
	RET			;


;-----------------------------
;[LCD]"LOCATE"
;IN	H=X(0~15),L=Y(0~1)
;OUT	-
;-----------------------------
CMD_LOCATE:
	LD	A,L		;
	AND	A		;
	JR	Z,.L1		;
	LD	A,040H		;
.L1:	ADD	A,H		;
	ADD	A,INST_DDRAM	;
	JR	SEND_INST	;

;-----------------------------
;[LCD]"CLS"
;-----------------------------
CMD_CLS:
	LD	A,INST_CLS	;
	CALL	SEND_INST	;
	JR	LCD_LWAIT	;

;-----------------------------
;[LCD]"HOME"
;-----------------------------
CMD_HOME:
	LD	A,INST_HOME	;
	CALL	SEND_INST	;
	JR	LCD_LWAIT	;

;-----------------------------
;[LCD]ウェイト
;-----------------------------
LCD_WAIT:
	NOP
	NOP
	NOP
	NOP
	NOP
	NOP
	RET

;-----------------------------
;[LCD]ロングウェイト
;-----------------------------
LCD_LWAIT:
	PUSH	BC
	LD	B,26H		;
.L1:	CALL	LCD_WAIT
	DJNZ	.L1
	POP	BC
	RET


COND_ENTRY:	DS	1
COND_DISP:	DS	1
COND_FUNC:	DS	1




