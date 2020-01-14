
LCD	EQU	10H			;LCD���W���[���̃|�[�g�ԍ�

ENABLE_BIT	EQU	10000000B	;ENABLE�M���̃r�b�g�ԍ�
RS_DATA		EQU	01000000B	;�f�[�^���W�X�^

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

	ORG	0C000H

	JP	INIT_LCD	;

	LD	HL,SAMPLE	;
	CALL	LCD_PRT		;
	RET			;

;-----------------------------
;LCD������
;-----------------------------
INIT_LCD:
	CALL	WAIT		;
	LD	B,3		;
.L1:	LD	A,00000011B	;8BIT���[�h�ɃZ�b�g
	CALL	SEND		;
	DJNZ	.L1		;
	CALL	WAIT		;

	LD	A,00000010B	;4BIT���[�h�ɃZ�b�g
	CALL	SEND		;
	CALL	WAIT		;

	LD	A,INST_FUNC+CODE_2LINE 	;
	LD	(COND_FUNC),A	;
	CALL	SEND_INST	;

	LD	A,INST_DISP+CODE_DISP+CODE_CURS+CODE_BLINK
	LD	(COND_DISP),A	;
	CALL	SEND_INST	;

	LD	A,INST_ENTRY+CODE_INC	;
	LD	(COND_ENTRY),A	;
	CALL	SEND_INST	;

	CALL	CMD_CLS		;

	RET

;-----------------------------
;4BIT���[�h�Ńf�[�^�𑗂�
;IN	A=DATA
;-----------------------------
SEND_DATA:
	LD	B,A		;
	SRL	A		;A<-A�̏��4�r�b�g
	SRL	A		;
	SRL	A		;
	SRL	A		;
	OR	RS_DATA		;RS�M�����悹��
	CALL	SEND		;
	LD	A,B		;
	AND	00001111B	;A<-A�̉���4�r�b�g
	OR	RS_DATA		;
	JR	SEND		;

;-----------------------------
;4BIT���[�h�Ŏw���𑗂�
;IN	A=DATA
;-----------------------------
SEND_INST:
	LD	B,A		;
	SRL	A		;A<-A�̏��4�r�b�g
	SRL	A		;
	SRL	A		;
	SRL	A		;
	CALL	SEND		;
	LD	A,B		;
	AND	00001111B	;A<-A�̉���4�r�b�g
	JR	SEND		;

;-----------------------------
;LCD�Ƀf�[�^�E�w���𑗂�
;IN	A=DATA
;-----------------------------
SEND:
	LD	C,LCD		;
	OUT	(C),A		;E<-LO
	CALL	WAIT		;

	OR	ENABLE_BIT	;E<-HI
	OUT	(C),A		;
	CALL	WAIT		;

	XOR	ENABLE_BIT	;E<-LO
	OUT	(C),A		;
	CALL	WAIT		;
	RET

;-----------------------------
;LCD�ɕ������o�͂���
;IN	HL=TP(00H�ŏI��)
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
;"CLS"
;-----------------------------
CMD_CLS:
	LD	A,INST_CLS	;
	JR	CMD		;

;-----------------------------
;"HOME"
;-----------------------------
CMD_HOME:
	LD	A,INST_HOME	;

CMD:	CALL	SEND_INST	;
	RET

;-----------------------------
;�E�F�C�g
;-----------------------------
WAIT:
	NOP
	NOP
	NOP
	NOP
	RET

SAMPLE:	DB	"HELLO WORLD !!",00H

COND_ENTRY:	DS	1
COND_DISP:	DS	1
COND_FUNC:	DS	1



