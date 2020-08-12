.model small
JUMPS
.stack 100h
.data 

include data.asm

.code
	start:
	mov ax, @data
	mov ds, ax	
	mov si, 82h  
;INPUT AND OUTPUT NAMES------------------------------------------
		call QQSkip_Spaces		
	lea di, Input_Name  	;i 'di' isikeliu pointeri nukreipta i failo pavadinimo bufferi
		call QQReading_Name
	inc si						;pasdidinu, kad praleisciau rasta tarpa
	push si                     ;pasididines 'si', ji isidedu i steka
	
		call QQSkip_Spaces
	lea di, Output_Name             ;i 'di' isikeliu pointeri nukreipta i failo pavadinimo bufferi
		call QQReading_Name
;---------------------------------------------------------------
	mov	dx, offset Input_Name	;Atidarau intput'a
	mov	al, 0
	mov	ah, 3Dh										
	int	21h					
	mov Input_Handle, ax

	mov ah, 3Ch		;Output'o sukurimas
	mov cx, 0
	mov dx, offset Output_Name
	int 21h

	mov	dx, offset Output_Name	;Atidarau output'a
	mov	al, 1
	mov	ah, 3Dh										
	int	21h					
	mov Output_Handle, ax

		jmp QQEncoding
;PRADZIOS FUNKCIJOS--------------------------------------------------------------		
QQSkip_Spaces PROC near                ;praleidzia useless space'us
	QQSkip_Spaces_Loop:
		cmp byte ptr es:[si], ' '
		jne QQEND_Skip_Spaces
	inc si
		jmp QQSkip_Spaces_Loop
		QQEND_Skip_Spaces:
	ret
QQSkip_Spaces ENDP
QQReading_Name proc near
	mov ax, word ptr es:[si]    ;ziuriu ar nereikia pagalbos pranesimo, aka / ir ? ieskojimas
		cmp ax, 3F2Fh                
		je QQHelp
	mov al, es:[si]				;pradedu tikrininti SIMBOLI, nes reik zinot, ar tarpas, ar ne
		
		cmp al, " "                 ;jeigu tarpas, tai reiskia bus daugiau failu nei vienas
		je QQIs_END
			cmp al, 13d                 ;enteris - paskutinis nuskaitytas simbolis
			je QQIs_END
	mov [di], al          		;jei nei tarpas, nei enteris, i 'file' pradedu irasyti pavadinima
	inc di
	inc si
		jmp QQReading_Name
		QQIs_END:
	ret
QQReading_Name endp

	QQHelp:				;isvedu klaida
	mov ah, 09h
	mov dx, offset Is_Error
	int 21h
	jmp QQEND_Program
	
	QQUnknown_I PROC near
		mov ah, 40h
		mov bx, Output_Handle
		mov cx, 14h
		mov dx, offset Output_Unknown
		int 21h

		mov ah, 40h
		mov bx, Output_Handle
		mov cx, 2
		mov dx, offset Output_Enter
		int 21h	
		
	ret
	QQUnknown_I ENDP
	
	QQWrite_Unknown:
		call QQUnknown_I
		
	QQEncoding: 
		call QQWrite_IP
		
	QQNo_IP:	
;===========================================================================
	mov ah, 3Fh
	mov bx, Input_Handle	;isirasau masininio kodo baita
	mov cx, 1
	mov dx, offset One_Byte	; ar turi nuo trecio bito prasideti nes cia buferis
	int 21h
		
	cmp Ax, 0h	;ziuriu kada pasiekiamas programos galas
	je QQEND_Program
	
	
	mov ax, 0	; nusinulinu ax
	mov O_i, 0
	mov al, One_Byte
	mov MC_W, ax	;i zodi isikeliu masinini koda
	
	inc IP_a	;didinu IP
	;------------------
	mov bl, One_Byte
	mov Disp_Buff[0], bl
	mov IIII, 1
		call QQ_Convert_IP
	;------------------
	QQWere_Unknown:
	mov si, MC_W
		cmp byte ptr Formats[si], 01h ;01 FORMATAS
		jne QQ_02
			jmp QQWrite_Unknown
	
		QQ_02:
		cmp byte ptr Formats[si], 02h ;02 FORMATAS	zinoma istrukcija
		jne QQ_07
			jmp QQNext
	
		QQ_07:
		cmp byte ptr Formats[si], 07h ;07 FORMATAS
		jne QQ_08
			call QQFormat_07
			jmp QQNext
		QQ_08:
		cmp byte ptr Formats[si], 08h ;08 FORMATAS
		jne QQContinue
			call QQFormat_08
			jmp QQNext
;=========================================================
	QQContinue:
	mov si, 0
	mov cx, 8
	mov ax, MC_W
		QQMC_Converting:	;komvertuoju masinini koda i dvejataine sistema
		shl al, 1			;nzn i kuria puse
		mov byte ptr MC_Binary[si], 0
		adc byte ptr MC_Binary[si], 0
		inc si
		loop QQMC_Converting		
	mov si, MC_W
;==================================================
		cmp byte ptr Formats[si], 03h ;03 FORMATAS
		jne QQ_04
			call QQFormat_03
				cmp MC_Binary[2], 1
				je QQNo_IP	;bus prefixas todel soks i pradzia
				mov bx, P_i
				mov W, 1
					call QQOutput_02 ;REGISTRAS
				jmp QQNext
		QQ_04:
		cmp byte ptr Formats[si], 04h ;04 FORMATAS
		ja QQ_05_06
			mov al, byte ptr MC_Binary[7]	; priskiriu w indikatoriui reiksme
			mov W, al
			call QQFormat_04
			jmp QQNext
		QQ_05_06:
		cmp byte ptr Formats[si], 06h ;05 ir 06 FORMATAS
		ja QQXX_ALL_Skiped
			call QQFormat_05_06	
			jmp QQNext
	QQXX_ALL_Skiped:
		cmp O_i, 0	;soksiu jei buvo nustatyta komanda
		jne QQNext
;======================================================================================
	mov al, byte ptr MC_Binary[7]	; priskiriu w indikatoriui reiksme
	mov W, al
	mov al, byte ptr MC_Binary[6]	; priskiriu D S ir V indikatoriui reiksme
	mov DsV, al	
	
	mov si, MC_W
		cmp byte ptr Formats[si], 0Ch	;ieskau kuriai grupei priklauso
		jb QQFirst_Class	;maziau uz 12
			cmp byte ptr Formats[si], 10h ;maziau uz 16
			jb QQSecond_Class		
				jmp QQThird_Class
;=======================================================================				
	QQFirst_Class:
	mov si, MC_W
	cmp byte ptr Formats[si], 9h	;09  FROMATAS
	ja QQ_10
		call QQFormat_09
		jmp QQNext
	QQ_10:
	cmp byte ptr Formats[si], 0Ah	;10 FROMATAS
	ja QQ_11
		call QQFormat_10
		jmp QQNext
	QQ_11:
	cmp byte ptr Formats[si], 0Bh	;11 FROMATAS
	jne QQNext
		call QQFormat_11
		jmp QQNext ;poto tvarkyti reiks
;==============================================================================
		QQSecond_Class:
		mov si, MC_W
			cmp byte ptr Formats[si], 0Dh ;13 FROMATAS
			jne QQ_Others
				mov ax, 1
				mov Disp, ax
				call QQReading_Displacement
				jmp QQNext	;*
				
		QQ_Others:
		mov ax, 2
		mov Disp, ax
		call QQReading_Displacement
		call QQHEX_Conversion

		mov si, MC_W
			cmp byte ptr Formats[si], 0Ch ;12 FROMATAS
			jne QQ_14
				call QQOutput_04  ;BETARPIS call QQFormat_12
				jmp QQNext
				
			QQ_14:
			cmp byte ptr Formats[si], 0Eh ;14 FROMATAS
			jne QQ_15
				call QQFormat_14
				jmp QQNext
			QQ_15:
			cmp byte ptr Formats[si], 0Fh ;15 FROMATAS
			jne QQNext
				call QQFormat_15
				jmp QQNext ;poto tvarkyti reiks
;==============================================================================	
	QQThird_Class:
	mov ah, 3Fh
	mov bx, Input_Handle	;isirasau adresavimo baita
	mov cx, 1
	mov dx, offset One_Byte
	int 21h
	inc IP_a	;didinu IP

	;------------------
	mov bl, One_Byte
	mov Disp_Buff[0], bl
		mov IIII, 1
		call QQ_Convert_IP
	;------------------
	
	mov cl, One_Byte
	mov Potencial_MC, cl
	
	
		call QQReading_Value
		call QQDetermine_Property_i
	mov ax, PR_i
	mov RM_i, ax
	
		call QQReading_Value
		call QQDetermine_Property_i
	mov ax, PR_i
	mov R_i, ax

		call QQReading_Value
		call QQDetermine_Property_i
	mov ax, PR_i
	mov M_i, ax

	mov si, MC_W
		cmp byte ptr Formats[si], 10h ;16 FROMATAS
		jne QQ_17
			jmp QQWrite_Unknown
		;	call QQFormat_16	;Coprocesorius nereikia

		QQ_17:
		cmp byte ptr Formats[si], 11h ;17 FROMATAS
		jne QQ_18
			call QQFormat_17
			jmp QQNext
		QQ_18:
		cmp byte ptr Formats[si], 12h ;18 FROMATAS
		jne QQ_19
			call QQFormat_18
			jmp QQNext	
		QQ_19:
		cmp byte ptr Formats[si], 13h ;19 FROMATAS
		jne QQ_20
			call QQFormat_19
			jmp QQNext	
		QQ_20:
		cmp byte ptr Formats[si], 14h ;20 FROMATAS
		jne QQ_21
			;cmp M_i, 3
			;je QQSomething_Wrong 	; turi buti rm atmintis
				call QQFormat_20
				jmp QQNext
			
		QQ_21:
		cmp byte ptr Formats[si], 15h ;21 FROMATAS
		jne QQ_22
			cmp MC_W, 0ffh
			jne QQ21_As_Normal
			cmp R_i, 2
			jb QQ21_To_22
			cmp R_i, 6
			je QQ21_To_22
			;cmp R_i, 7
			;je QQSomething_Wrong	; nera su reg 111
				call QQFormat_21	;SPECIAL
				jmp QQNext
			QQ21_As_Normal:
			;cmp R_i, 0
			;jne QQSomething_Wrong	; yra tik su reg 000
				call QQFormat_21	;SPECIAL
				jmp QQNext
			QQ21_To_22:
				call QQFormat_22	
				jmp QQNext
		QQ_22:
		cmp byte ptr Formats[si], 16h ;22 FROMATAS
		jne QQ_23
			cmp MC_W, 0f6h
			je QQ22_For_Convenience
			cmp MC_W, 0f7h
			je QQ22_For_Convenience
			cmp R_i, 0
			je QQ22_As_Normal	; yra tik su reg 001 ir 000
			;cmp R_i, 1
			;je QQ22_As_Normal		
			;	jmp QQSomething_Wrong
			QQ22_As_Normal:
				call QQFormat_22		;SPECIAL	; tas pats kaip 17
				jmp QQNext
			QQ22_For_Convenience:
				;cmp R_i, 1
				;je QQSomething_Wrong	;nera su reg 001
				cmp R_i, 0
				jne QQ22_As_Normal
					call QQFormat_25
					jmp QQNext
		QQ_23:
		cmp byte ptr Formats[si], 17h ;23 FROMATAS
		jne QQ_24
			;cmp R_i, 6
			;je QQSomething_Wrong	; nera tik su reg 110
			call QQFormat_23 
			jmp QQNext
				
		QQ_24:
		cmp byte ptr Formats[si], 18h ;24 FROMATAS
		jne QQ_25
			call QQFormat_24
			jmp QQNext
			
		QQ_25:
		cmp byte ptr Formats[si], 19h ;25 FROMATAS
		jne QQNext
			;cmp R_i, 0
			;je QQSomething_Wrong	; yra tik su reg 000
			call QQFormat_25 
			jmp	QQNext
		
			QQSomething_Wrong:
				call QQUnknown_I
			mov ax, 0
			mov al, Potencial_MC
			mov MC_W, ax
				jmp QQWere_Unknown
;==============================================================================
QQNext:
	cmp MC_W, 00F3h
	je QQTwo_Instructions	
	cmp MC_W, 00F2h
	je QQTwo_Instructions
	QQFrom_Two_Instructions:	
	mov ah, 40h
	mov bx, Output_Handle
	mov cx, IP_i
	mov dx, offset IP_Buff
	int 21h
	
	mov ax, 18
	sub ax, IP_i
	mov IP_i, ax
	
	mov ah, 40h
	mov bx, Output_Handle
	mov cx, IP_i
	mov dx, offset Space_Buff
	int 21h

	call QQDetermine_Instruction
	
	cmp MC_W, 00F3h
	je QQTwo_Instructions2	
	cmp MC_W, 00F2h
	je QQTwo_Instructions2
	QQFrom_Two_Instructions2:
	
		cmp O_i, 0
		je QQOutput_Skiped		
	mov ah, 40h
	mov bx, Output_Handle
	mov cx, O_i
	mov dx, offset Output_Line
	int 21h
	mov P_i, 0
	
	QQOutput_Skiped:
	mov ah, 40h
	mov bx, Output_Handle
	mov cx, 2
	mov dx, offset Output_Enter
	int 21h
		jmp QQEncoding
	
	QQEND_Program:
	mov ah, 3Eh
	mov bx, Input_Handle
	int 21h
	mov ah, 3Eh
	mov bx, Output_Handle
	int 21h

	mov ah, 4Ch                     
	int 21h
	QQTwo_Instructions:
		add IP_a, 1
		mov ah, 3Fh                 ;failo skaitymo interuptas
		mov bx, Input_Handle       	;sis intas reikalauja atidaryto failo handle 
		mov cx, 1					; nuskaitomas baitu kiekis po OPK
		mov dx, offset Disp_Buff
		int 21h
		mov IIII, 1
		call QQ_Convert_IP
	jmp QQFrom_Two_Instructions
;-----------------------------------------
			QQTwo_Instructions2:
			mov ax, 0
			mov al, Disp_Buff[0]
			mov MC_W, ax
			call QQDetermine_Instruction
			jmp QQFrom_Two_Instructions2
;===============================================================
QQWrite_IP proc near
	mov bx, IP_a
	mov Disp_Buff[0], bh
	mov Disp_Buff[1], bl
	mov Disp, 2
		call QQHEX_Conversion	
	mov OutL_Buff[4], ':'
	mov OutL_Buff[5], 20h

	mov ah, 40h
	mov bx, Output_Handle
	mov cx, 6
	mov dx, offset OutL_Buff
	int 21h
	
	mov IP_i, 0
ret     
QQWrite_IP endp
;-----------------------------------------------------
QQ_Convert_IP proc near
		mov bx, IP_i
		mov si, 0
		mov cx, IIII
		QIQConversion_Loop:
        mov al, Disp_Buff[si]   ; al'e baita padek pries kreipimasi i funkcija	
        and al, 0F0h		; vyresnysis pusbaitis
        shr al, 4
			call QQHalf_Byte_Conversion
		mov ah, al
		mov al, Disp_Buff[si]		
        and al, 0Fh			; jaunesnysis pusbaitis
			call QQHalf_Byte_Conversion
			
		mov IP_Buff[bx], ah
		inc bx
		mov IP_Buff[bx], al
		inc bx
		mov IP_Buff[bx], 20h
		inc bx
		inc si
		loop QIQConversion_Loop

	mov IP_i, bx
ret     
QQ_Convert_IP endp
;------------------------------------------------
QQHalf_Byte_Conversion proc near
		cmp al, 09
		jle QQAdd_Zero
	sub al, 10
	add al, 'A'
		jmp QQEnd_Conversion
		QQAdd_Zero:
		add al, '0'
		QQEnd_Conversion:
ret
QQHalf_Byte_Conversion endp
;===============================================================
QQDetermine_Instruction proc near
	mov si, MC_W
	add si, MC_W
	
	mov bx, word ptr Itable[si]
		call QQSpecial_Instructions
	
	QQInstruction:
	mov si, 0
	mov ax, offset IName[bx].I0
		call QQWrite_Instruction
	mov ax, offset IName[bx].I0+2
		call QQWrite_Instruction
	mov ax, offset IName[bx].I0+4
		call QQWrite_Instruction
	mov OutL_Buff[si], ' '
	
	mov ah, 40h
	mov bx, Output_Handle
	mov cx, 7
	mov dx, offset OutL_Buff
	int 21h
ret     
QQDetermine_Instruction endp
;-------------------------------------
QQWrite_Instruction proc near
	mov OutL_Buff[si], ah
	inc si
	mov OutL_Buff[si], al
	inc si
ret     
QQWrite_Instruction endp
;--------------------------------------------
QQSpecial_Instructions proc near
	mov dl, 6
		cmp bx, 0FFFAh ; ADD OR ADC
		jne QQNot_24_Special
	mov ax, R_i
	mov bx, 0
	mul dl
	mov bl, al
ret
	QQNot_24_Special:
	cmp bx, 0FFFBh	; MOVSB STOSB STOSW LODSB LODSW
	jne QQNot_04_Special
		mov al, 0
		mov si, 0A4h
			QQWhat_04:
				cmp si, MC_W
				je QQEND_What_04
			inc al
			inc si
			jmp QQWhat_04
				QQEND_What_04:
					cmp al, 6
					jb QQ_No_Need_SUB
				sub al, 2	
	QQ_No_Need_SUB:
	mov bx, 0
	mul dl
	mov bl, al
	add bx, 522
ret
	QQNot_04_Special:
		cmp bx, 0FFFCh ; ROL RCL SHR
		jne QQNot_23_Special
	mov ax, R_i
		cmp al, 7
		jne QQNot_23_SUB
	dec al
	QQNot_23_SUB:
	mov bx, 0
	mul dl
	mov bl, al
	add bx, 480
ret
	QQNot_23_Special: 
		cmp bx, 0FFFDh ; NOT NEG MUL DIV
		jne QQNot_22_Special
	mov ax, R_i
		cmp al, 0
		jne QQNot_22_TEST
	mov bx, 402
ret
		QQNot_22_TEST:
	mov bx, 0
	mul dl
	mov bl, al
	add bx, 432	; ne 444 nes R_i prasideda nuo 2
ret	
	QQNot_22_Special:	
		cmp bx, 0FFFEh ;INC DEC CALL JMP
		jne QQNot_21_Special
	mov ax, R_i
		cmp al, 3
		jb QQNOT_22_DEC
	dec al
		cmp al, 4
		jb QQNOT_22_DEC
	dec al
		QQNOT_22_DEC:
	mov bx, 0
	mul dl
	mov bl, al
	add bx, 408
ret
	QQNot_21_Special:
ret     
QQSpecial_Instructions endp
;===================================================================================
QQHEX_Conversion proc near
	mov bx, 0
	mov si, 0	
	mov cx, Disp
	
		QQHEX_Conversion_Loop:
        mov al, Disp_Buff[si]   ; al'e baita padek pries kreipimasi i funkcija	
        and al, 0F0h
        shr al, 4
			call QQHalf_Byte_Conversion
		mov ah, al
		
		mov al, Disp_Buff[si]
        and al, 0Fh
			call QQHalf_Byte_Conversion

		mov OutL_Buff[bx], ah
		inc bx
		mov OutL_Buff[bx], al
		inc bx
		inc si
		loop QQHEX_Conversion_Loop	
ret     
QQHEX_Conversion endp
;===============================================================================================
QQReading_Displacement proc near
		mov ax, Disp
		add IP_a, ax
		mov ah, 3Fh                 ;failo skaitymo interuptas
		mov bx, Input_Handle       	;sis intas reikalauja atidaryto failo handle 
		mov cx, Disp					; nuskaitomas baitu kiekis po OPK
		mov dx, offset Disp_Buff
		int 21h
		;------------------
		mov bx, Disp
		mov IIII, bx
		call QQ_Convert_IP
		;------------------
		cmp Disp, 2
		jne QQRD_END
		mov ah, Disp_Buff[0]
		xchg ah, Disp_Buff[1]
		mov Disp_Buff[0], ah
		QQRD_END:
ret
QQReading_Displacement endp
;==========================================
QQEnter_Comma proc near
	mov si, O_i
	
	mov al, byte ptr E_Comma[0]
	mov Output_Line[si], al
	inc si
	mov al, byte ptr E_Comma[1]
	mov Output_Line[si], al
	inc si
	
	mov O_i, si
ret
QQEnter_Comma endp
;=====================================================
QQFormat_03 proc near	; PREFIXAS arba SEGMENTO REGISTRAS
	mov bx, MC_W
	shr bl, 3	;SR laikomas 4 bite nuo galo
	mov One_Byte, bl
		call QQReading_Value
		call QQDetermine_Property_i	
	mov ax, PR_i
	cmp ax, 4
	jb QQSkip_Sub
	sub al, 4
	QQSkip_Sub:
	add ax, 8
	mov P_i, ax
ret	
QQFormat_03 endp
;==========================================================
QQFormat_04 proc near	
		cmp MC_W, 0ECh
		jb QQ04_Just_Instruction
		cmp MC_W, 0EDh
		ja QQ04_Reverse
	mov bx, 0	;W nustato akumuliatoriu
	call QQOutput_02 ;REGISTRAS	
	call QQEnter_Comma
	mov W, 1
	mov bx, 2	; DX portastas
	call QQOutput_02 ;REGISTRAS
ret
	QQ04_Reverse:
	mov cl, 1
	xchg cl, W
	mov bx, 2	; DX portas
	call QQOutput_02 ;REGISTRAS
	call QQEnter_Comma
	mov W, cl
	mov bx, 0	;W nustato akumuliatoriu
	call QQOutput_02 ;REGISTRAS	
	QQ04_Just_Instruction:	
ret
QQFormat_04 endp
;===================================================
QQFormat_05_06 proc near ;06 zodinis REGISTRAS	;----------
						 ;05 w nustato registra ir BETARPIO baitus
		mov ax, MC_W
		mov One_Byte, al
		call QQReading_Value
	shr bl, 1
	mov W, 0
	adc W, 0	;priskiriu W reiksme
	clc
		call QQDetermine_Property_i
	mov ax, PR_i
	mov R_i, ax
		
	mov si, MC_W
		cmp byte ptr Formats[si], 05h	;ziuriu kuris formatas
		je QQ05_Format
	mov W, 0001h ;nes bus zodinis
		cmp MC_W, 90h	;ziuriu kuris formatas
		jb QQ06_No_Prefix
		mov bx, 0
		call QQOutput_02 ; REGISTRAS
		call QQEnter_Comma
		QQ06_No_Prefix:
		mov bx, R_i
		call QQOutput_02 ; REGISTRAS
		
		jmp QQEND_05_06
	;NUSTATYTI KOMANDA
		
	QQ05_Format:
	mov bx, R_i
		call QQOutput_02 ; REGISTRAS
		call QQEnter_Comma
	mov ax, 2
	mov Disp, ax
			cmp W, 1
			je QQF05_As_Word
		dec Disp
	QQF05_As_Word:
			call QQReading_Displacement
			call QQHEX_Conversion
			call QQOutput_04 ;BETARPIS
	QQEND_05_06:	
ret
QQFormat_05_06 endp
;====================================================================
QQFormat_07 proc near ;1 baitas neaisku ar ISPLESTAS [ATMINTIS] 
	mov ax, 1
	mov Disp, ax
		call QQReading_Displacement
		call QQExpand_Byte ; cia zymems
		call QQHEX_Conversion
		call QQOutput_04 ;BETARPIS ;BUVO TIESIOGINE ATMINTIS
ret
QQFormat_07 endp
;==========================================================================
QQFormat_08 proc near	;1 baitas BETARPIS
	mov ax, 1
	mov Disp, ax
		call QQReading_Displacement
		call QQHEX_Conversion
		call QQOutput_04 ;BETARPIS
ret
QQFormat_08 endp
;=====================================================================
QQFormat_09 PROC near	;09 1 baitas BETARPIS
	mov ax, 1	; priskiriu viena baita
	mov Disp, ax
	cmp MC_W, 0E5h
	ja QQ09_Reverse
	mov bx, 0
		call QQOutput_02	;Registras
		call QQEnter_Comma
		call QQReading_Displacement
		call QQHEX_Conversion
		call QQOutput_04 ;BETARPIS
ret
	QQ09_Reverse:
		call QQReading_Displacement
		call QQHEX_Conversion
		call QQOutput_04 ;BETARPIS
		call QQEnter_Comma
	mov bx, 0
		call QQOutput_02	;Registras
ret
QQFormat_09 ENDP
;=====================================================================
QQFormat_10 PROC near	;10 w nustato BERARPI
	mov bx, 0
		call QQOutput_02	;Registras
		call QQEnter_Comma
	mov ax, 1	; priskiriu viena baita
	mov Disp, ax
		cmp W, 0
		je QQ10_Skip
	inc Disp
	QQ10_Skip:
		call QQReading_Displacement
		call QQHEX_Conversion
		call QQOutput_04 ;BETARPIS
ret
QQFormat_10 ENDP
;==========================================================
QQFormat_11 PROC near ;2 baitai ATMINTIS
	mov ax, 2
	mov Disp, ax
		call QQReading_Displacement
		call QQHEX_Conversion
	cmp Dsv, 1 ;Cia vis delto yra svardus 'D' bitas
	je QQ11_Res_REG
	mov bx, 0	; nusinulinu bx
		call QQOutput_02 ;REGISTRAS
		call QQEnter_Comma
		call QQText_By_W
		call QQOutput_00 ;TIESIOGINE ATMINTIS
ret
	QQ11_Res_REG:
		call QQText_By_W
		call QQOutput_00 ;TIESIOGINE ATMINTIS
		call QQEnter_Comma
	mov bx, 0	; nusinulinu bx
		call QQOutput_02 ;REGISTRAS
		


ret
QQFormat_11 ENDP
;=================================================
QQText_By_W PROC near
	mov bx, 4
		cmp W, 1
		je QQIs_Word
	mov bx, 13
	QQIs_Word:
	mov One_Byte, 9
		call QQText_Cicle
ret
QQText_By_W ENDP
;==========================================================
QQFormat_14 PROC near	;isorinis itesioginis
mov ah, Disp_Buff[0]
mov al, Disp_Buff[1]
add ax, IP_a

mov Disp_Buff[0], ah
mov Disp_Buff[1], al
	call QQHEX_Conversion
	call QQOutput_04	;Betarpis
ret
QQFormat_14 ENDP
;==========================================================
QQFormat_15 PROC near ; vidinis tiesioginis
mov al, Disp_Buff[0]
mov ah, Disp_Buff[1]
mov Disp_Buff[2], al
mov Disp_Buff[3], ah
		call QQReading_Displacement
	mov Disp, 4
		call QQHEX_Conversion
	mov Disp, 2
		call QQOutput_04	;betarpis
;------------------------------------------------------		
	mov si, O_i
	mov bx, 4

	mov al, ':'
	mov Output_Line[si], al
	inc si
	
	mov al, '0'
	mov Output_Line[si], al
	inc si

	mov cx, Disp	;dvigubai Disp TAIP
	add cx, cx
	QQ15OutByte_Loop:
	mov al, OutL_Buff[bx]
	mov Output_Line[si], al
	inc si
	inc bx
	loop QQ15OutByte_Loop

	mov al, 'h'
	mov Output_Line[si], al
	inc si
	mov O_i, si
;---------------------------------------------
ret
QQFormat_15 ENDP
;===========================================================
QQFormat_17 PROC near
mov bx, R_i
	call QQOutput_02 ;REGISTRAS
	call QQEnter_Comma	;kablelis ir tarpas
	cmp M_i, 3
	je QQ17_Skip_Text
	call QQText_By_W
	QQ17_Skip_Text:
mov bx, RM_i
	call QQOutput_03 ;REGISTRAS/[ATMINTIS]
ret
QQFormat_17 ENDP
;=============================================================
QQFormat_18 PROC near
	cmp DsV, 0
	je QQ18_Source_REG
		mov bx, R_i
		call QQOutput_02 ;REGISTRAS
		call QQEnter_Comma	;kablelis ir tarpas
	cmp M_i, 3
	je QQ18_Skip_Text
	call QQText_By_W
	QQ18_Skip_Text:	
		mov bx, RM_i
		call QQOutput_03 ;REGISTRAS/[ATMINTIS]
ret
	QQ18_Source_REG:
	
	cmp M_i, 3
	je QQ18_Skip_Text2
	call QQText_By_W
	QQ18_Skip_Text2:	
		mov bx, RM_i
		call QQOutput_03 ;REGISTRAS/[ATMINTIS]
		call QQEnter_Comma	;kablelis ir tarpas
		mov bx, R_i
		call QQOutput_02 ;REGISTRAS
ret
QQFormat_18 ENDP
;===============================================================
QQFormat_19 PROC near
	mov W, 1
	mov ax, R_i
	cmp ax, 4
	jb QQ19Skip_Sub
	sub al, 4
	mov R_i, ax
	QQ19Skip_Sub:
	add R_i, 8
	
	cmp DsV, 0
	je QQ19Source_REG
	mov bx, R_i
		call QQOutput_02 ;REGISTRAS
		call QQEnter_Comma	;kablelis ir tarpas
	mov bx, 4
	mov One_Byte, 9
		call QQText_Cicle
	mov bx, RM_i
		call QQOutput_03 ;REGISTRAS/[ATMINTIS]
ret
	QQ19Source_REG:	
	mov bx, 4
	mov One_Byte, 9
		call QQText_Cicle
	mov bx, RM_i
		call QQOutput_03 ;REGISTRAS/[ATMINTIS]
		call QQEnter_Comma	;kablelis ir tarpas
	mov bx, R_i
		call QQOutput_02 ;REGISTRAS
ret
QQFormat_19 ENDP
;========================================================================
QQFormat_20 PROC near
	mov W, 1
	mov bx, R_i
		call QQOutput_02 ;REGISTRAS
		call QQEnter_Comma	;kablelis ir tarpas
	cmp M_i, 3
	je QQ20_Skip_Text
	call QQText_By_W
	QQ20_Skip_Text:	
	mov bx, RM_i
		call QQOutput_03 ;REGISTRAS/[ATMINTIS]*************** turi buti tik atmintis
ret
QQFormat_20 ENDP
;===================================================
QQFormat_21 PROC near	;nera reg 1 ir reg 7
	mov cx, 0

		cmp M_i, 3
		je QQ21_RegMem
		cmp MC_W, 8Fh
		je QQ21_Inner
		cmp R_i, 2
		je QQ21_Inner
		cmp R_i, 4
		je QQ21_Inner
	mov bx, 0
	mov One_Byte, 4
		call QQText_Cicle
	mov bx, RM_i
		call QQOutput_03	;REGISTRAS/[ATMINTIS]
ret
	QQ21_RegMem:
	mov bx, RM_i
		call QQOutput_03	;REGISTRAS/[ATMINTIS]
ret
	QQ21_Inner:
	mov bx, 4
	mov One_Byte, 9
		call QQText_Cicle
	mov bx, RM_i
		call QQOutput_03	;REGISTRAS/[ATMINTIS]
ret
QQFormat_21 ENDP
;=======================================================
QQText_Cicle PROC near
mov si, O_i
mov cx, 0
mov cl, One_Byte
	QQ21_Write:
	mov al, Output_Text[bx]
	inc bx
	mov Output_Line[si], al
	inc si
	loop QQ21_Write
mov O_i, si
ret
QQText_Cicle ENDP
;===============================================
QQFormat_22 PROC near
	cmp M_i, 3
	je QQ22_Skip_Text
	call QQText_By_W
	QQ22_Skip_Text:
	mov bx, RM_i
		call QQOutput_03 ;REGISTRAS/[ATMINTIS]
ret
QQFormat_22 ENDP
;========================================================================
QQFormat_23 PROC near
	cmp M_i, 3
	je QQ23_Skip_Text
	call QQText_By_W
	QQ23_Skip_Text:
		mov bx, RM_i
		call QQOutput_03 ;REGISTRAS/[ATMINTIS]
		call QQEnter_Comma
			cmp DsV, 1
			je QQ23_REG
	mov si, O_i
	mov al,	31h
	mov Output_Line[si], al
	inc si
	mov O_i, si
ret
			QQ23_REG:
			mov W, 0	
			mov bx, 1	;bus imamas CL registras
			call QQOutput_02 ;REGISTRAS
ret
QQFormat_23 ENDP
;========================================================================
QQFormat_24 PROC near
	cmp M_i, 3
	je QQ24_Skip_Text
	call QQText_By_W
	QQ24_Skip_Text:
	mov bx, RM_i
		call QQOutput_03 ;REGISTRAS/[ATMINTIS]
		call QQEnter_Comma

	mov ax, 1
	mov Disp, ax
	
	cmp W, 0	;S
	je QQ24_One_Byte
	cmp DsV, 0
	je QQ24_Two_Byte
		call QQReading_Displacement
		call QQExpand_Byte2	;??????????????/
		jmp QQ24_END
		
	QQ24_One_Byte:	
	call QQReading_Displacement	
	jmp QQ24_END
	
	QQ24_Two_Byte:
	inc Disp
	call QQReading_Displacement
	
	QQ24_END:
	call QQHEX_Conversion
	call QQOutput_04 ;BETARPIS
ret
QQFormat_24 ENDP
QQExpand_Byte2 proc near
	mov al, Disp_Buff[0]
	mov Disp_Buff[1], al
	shl al, 1
		jc QQIs_FF
	mov al, 00h
		jmp QQEND_Expansion
	QQIs_FF:
	mov al, 0FFh
		QQEND_Expansion:
	mov Disp_Buff[0], al
	mov Disp, 0002h
ret
QQExpand_Byte2 endp
;========================================================================
QQFormat_25 PROC near
	cmp M_i, 3
	je QQ25_Skip_Text
	call QQText_By_W
	QQ25_Skip_Text:
	mov bx, RM_i
		call QQOutput_03 ;REGISTRAS/[ATMINTIS]
		call QQEnter_Comma

	mov ax, 2
	mov Disp, ax
	
	cmp W, 0	;S
	je QQ25_One_Byte
		
	call QQReading_Displacement
	jmp QQ25_END
	
	QQ25_One_Byte:	
	dec Disp
	call QQReading_Displacement	
	
	QQ25_END:
	call QQHEX_Conversion
	call QQOutput_04 ;BETARPIS
ret
QQFormat_25 ENDP
;=====================================================================
QQExpand_Byte proc near
	mov ax, IP_a
	mov bx, 0
	mov cx, 0
	cmp Disp_Buff[0], 7Fh
	ja QQEB_SUB
	mov bl, Disp_Buff[0]	
	add ax, bx	; bus sudetis
		jmp QQEB_END
	QQEB_SUB:
	mov bx, 100h
	mov cl, Disp_Buff[0]
	sub bx, cx
	sub ax, bx
		QQEB_END:
	mov Disp_Buff[0], ah
	mov Disp_Buff[1], al
	mov Disp, 0002h
ret
QQExpand_Byte endp
;====================================================================
QQReading_Value proc near
		mov bl, 0	;nusinulinu koeficienta ir VALUE
		mov VALUE, bl
		inc bl
		mov Coeff, bl	
		mov bl, One_Byte	;cia buvo laikoma reiksme kuria reikia skaidyti pabaiciui
		
		mov cx, 3
			QQCombine_Value:	;skaitau ir irasau po tris bitus
			mov al, 0 ;nusinulinu Al
			shr bl, 1
			adc al, 0	;pridedu viena bita
			clc

			mul Coeff
			add VALUE, al	; pridedu prie operando gauta skaiciu (tas operandas veliau bus priskirtas kazkam
			
			mov al, Coeff ; koeficienta dauginu is 10h
			mov bh, 0Ah
			mul bh
			mov Coeff, al	
			loop QQCombine_Value
		mov One_Byte, bl
ret
QQReading_Value endp
;===================================================
QQDetermine_Property_i proc near
	mov si, 0
		QQSearching_For_Property:
			mov al, VALUE
			cmp al, byte ptr Value_Buff[si]	;Wvalue_Buff tinka visiems
			je QQProperty_Found
		inc si
			jmp QQSearching_For_Property
			
		QQProperty_Found:
		mov PR_i, si
ret
QQDetermine_Property_i endp
;================================================================================
QQOutput_00 proc near ;ATMINTIS TIESIOGINE
	mov si, O_i
	
	mov al, BracketO
	mov Output_Line[si], al
	inc si
	mov al, '0'
	mov Output_Line[si], al
	inc si
	
	mov bx, 0
	mov cx, Disp
	add cx, cx
	QQOutMem_Loop:
	mov al, OutL_Buff[bx]
	mov Output_Line[si], al
	inc bx ;eina vis prie kito simbolio
	inc si
	loop QQOutMem_Loop

	mov al, 'h'
	mov Output_Line[si], al
	inc si
	mov al, BracketC
	mov Output_Line[si], al
	inc si
	
	mov O_i, si
ret
QQOutput_00 endp
;==============================================================
QQOutput_01 proc near ; RM ATMINTIS
	mov si, O_i
	
		cmp P_i, 0
		je QQ01_No_Prefix
	mov bx, P_i
		call QQOutput_02 ;REGISTRAS
	mov si, O_i
	mov al,	':'
	mov Output_Line[si], al
	inc si	
	QQ01_No_Prefix:

	mov al,	byte ptr BracketO
	mov Output_Line[si], al
	inc si
	
	mov bx, RM_i
;----------------------------------------------------------
	add bx, bx
	cmp bx, 06
	ja Second_Cicle
	
		mov ax, offset Mems[bx].Rm0
		mov Output_Line[si], ah
		inc si
		mov Output_Line[si], al
		inc si
	
	mov al,	PLUS
	mov Output_Line[si], al
	inc si
	
	add bx, 8
		cmp bx, 0Bh
		jb Second_Cicle
	sub	bx, 4
	Second_Cicle:
		mov ax, offset Mems[bx].Rm0
		mov Output_Line[si], ah
		inc si
		mov Output_Line[si], al
		inc si
;-----------------------------------------------------------
	;jei yra dar poslinkis
		cmp M_i, 0
		je QQSkip_Disp
	mov al,	PLUS
	mov Output_Line[si], al
	inc si
	mov O_i, si

	mov ax, M_i
	mov Disp, ax
	call QQReading_Displacement
	call QQHEX_Conversion
	call QQOutput_04	;BETARPIS
	mov si, O_i
	
	QQSkip_Disp:
	mov al,	byte ptr BracketC
	mov Output_Line[si], al
	inc si
	mov O_i, si	
ret
QQOutput_01 endp
;======================================================
QQOutput_02 proc near ;REGISTRAS
	mov si, O_i
	add bx, bx	;mov bx, R_i arba RM_i
		
		cmp W, 0	
		je QQREG_As_W_00 
	add bx, 10h	;praleidzia jei w = 0
		QQREG_As_W_00:	
	mov ax, offset Wreg[bx].Reg0
	mov Output_Line[si], ah
	inc si
	mov Output_Line[si], al
	inc si
	
	mov O_i, si
ret
QQOutput_02 endp
;===========================================================
QQOutput_03 proc near ; REGISTRAS/[ATMINTIS]

			cmp M_i, 0
			jne QQTo_Else
				cmp RM_i, 6
				jne QQTo_Else
		mov ax, 2
		mov Disp, ax
		call QQReading_Displacement
		call QQHEX_Conversion
		call QQOutput_00 ; TIESIOGINE [ATMINTIS]
ret
		QQTo_Else:
			cmp M_i, 3
			je QQTo_REG
			call QQOutput_01 ;RM [ATMINTIS]
ret
			QQTo_REG:
			;mov bx, RM_i
				call QQOutput_02	;REGISTRAS	
ret
QQOutput_03 endp
;===================================================
QQOutput_04 proc near ; BETARPIS
	mov si, O_i
	mov bx, 0

	mov al, '0'
	mov Output_Line[si], al
	inc si

	mov cx, Disp	;dvigubai Disp TAIP
	add cx, cx
	QQOutByte_Loop:
	mov al, OutL_Buff[bx]
	mov Output_Line[si], al
	inc si
	inc bx
	loop QQOutByte_Loop

	mov al, 'h'
	mov Output_Line[si], al
	inc si
	mov O_i, si 	
ret
QQOutput_04 endp
;================================================================
END start
;====================================================