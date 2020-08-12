	Is_Error db 'YRA KLAIDA$'
	
	Input_Name db 13 dup (0)	
	Input_Handle dw ?

	Output_Name db 13 dup (0)	
	Output_Handle dw ?

	One_Byte db 0

	Potencial_MC db 0
	MC_W dw 0
	MC_Binary db 8 dup (0)

	DsV db 0
	W db 0
	SR db 0 ; pakeiciau1 
	
	Disp dw 0
	Disp_Buff db 4 dup (0)
	
	OutL_Buff db 8 dup (0)
	Output_Line db 40 dup (?)
	
	Output_Unknown db 'NEZINOMA INSTRUKCIJA'
	Output_Enter db 13, 10
	
	Output_Text db 'far ', 'word ptr ', 'byte ptr '
;svarbiausi bufferiai-----------------------------------------
Formats db 18, 18, 18, 18, 10, 10, 3, 3, 18, 18, 18, 18, 10, 10, 3, 3
db 18, 18, 18, 18, 10, 10, 3, 3, 18, 18, 18, 18, 10, 10, 3, 3
db 18, 18, 18, 18, 10, 10, 3, 2, 18, 18, 18, 18, 10, 10, 3, 2
db 18, 18, 18, 18, 10, 10, 3, 2, 18, 18, 18, 18, 10, 10, 3, 2
db 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6
db 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6
db 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1
db 7, 7, 7, 7, 7, 7, 7, 7, 7, 7, 7, 7, 7, 7, 7, 7
db 24, 24, 24, 24, 17, 17, 17, 17, 18, 18, 18, 18, 19, 20, 19, 21
db 2, 6, 6, 6, 6, 6, 6, 6, 2, 2, 15, 2, 2 ,2, 2, 2
db 11, 11, 11, 11, 4, 4, 4, 4, 10, 10, 4, 4, 4, 4, 4, 4
db 5, 5, 5, 5, 5, 5, 5, 5, 5, 5, 5, 5, 5, 5, 5, 5
db 1, 1, 12, 2, 20, 20, 25, 25, 1, 1, 12, 2, 2, 8, 2, 2
db 23, 23, 23, 23, 13, 13, 1, 2, 16, 16, 16, 16, 16, 16, 16, 16
db 7, 7, 7, 7, 9, 9, 9, 9, 14, 14, 15, 7, 4, 4, 4, 4
db 2, 1, 2 ,2, 2, 2, 22, 22, 2, 2, 2, 2, 2, 2, 22, 21
; ten kur 0 yra isimtis
;-----------------------------------
Coeff db 0 ;vertimo is masyvo i skaiciu funkcijai
Value_Buff db 00, 01, 0Ah, 0Bh, 64h, 65h, 6Eh, 6Fh
VALUE db 0
PR_i dw 0	;Property index

P_i dw 0	;prefix index
M_i dw 0	;mod index
R_i dw 0	;reg index
RM_i dw 0	;r/m index
O_i dw 0	;output_line index

IP_a dw 100h	;IP registro adresas
Space_Buff db 20 dup (20h)
IP_Buff db 30 dup (0)
IP_i dw 0	;IP_line index
IIII dw 0

E_Comma db ', '
BracketO db '['
BracketC db ']'
PLUS db '+'

REGISTERS STRUC
Reg0 dw 0
Reg1 dw 0
Reg2 dw 0
Reg3 dw 0
REGISTERS ENDS

label Wreg REGISTERS
REGISTERS <'AL', 'CL', 'DL', 'BL'>
REGISTERS <'AH', 'CH', 'DH', 'BH'>
REGISTERS <'AX', 'CX', 'DX', 'BX'>
REGISTERS <'SP', 'BP', 'SI', 'DI'>
REGISTERS <'ES', 'CS', 'SS', 'DS'>

MEMORIES STRUC
Rm0 dw 0
Rm1 dw 0
Rm2 dw 0
Rm3 dw 0
MEMORIES ENDS

label Mems MEMORIES
MEMORIES <'BX', 'BX', 'BP', 'BP'>
MEMORIES <'SI', 'DI', 'BP', 'BX'>

INSTRUCTIONS STRUC
I0 dw 0
I1 dw 0
I2 dw 0
INSTRUCTIONS ENDS

label IName INSTRUCTIONS
INSTRUCTIONS <'AD', 'D ', '  '>
INSTRUCTIONS <'OR', '  ', '  '>
INSTRUCTIONS <'AD', 'C ', '  '>
INSTRUCTIONS <'SB', 'B ', '  '>
INSTRUCTIONS <'AN', 'D ', '  '>
INSTRUCTIONS <'SU', 'B ', '  '>
INSTRUCTIONS <'XO', 'R ', '  '>
INSTRUCTIONS <'CM', 'P ', '  '>
;----------------------------------
INSTRUCTIONS <'JO', '  ', '  '>
INSTRUCTIONS <'JN', 'O ', '  '>
INSTRUCTIONS <'JC', '  ', '  '>
INSTRUCTIONS <'JN', 'C ', '  '>
INSTRUCTIONS <'JZ', '  ', '  '>
INSTRUCTIONS <'JN', 'Z ', '  '>
INSTRUCTIONS <'JB', 'E ', '  '>
INSTRUCTIONS <'JN', 'BE', '  '>
INSTRUCTIONS <'JS', '  ', '  '>
INSTRUCTIONS <'JN', 'S ', '  '>
INSTRUCTIONS <'JP', '  ', '  '>
INSTRUCTIONS <'JN', 'P ', '  '>
INSTRUCTIONS <'JL', '  ', '  '>
INSTRUCTIONS <'JN', 'L ', '  '>
INSTRUCTIONS <'JL', 'E ', '  '>
INSTRUCTIONS <'JN', 'LE', '  '>
;-------------------------------------
INSTRUCTIONS <'DA', 'A ', '  '>
INSTRUCTIONS <'DA', 'S ', '  '>
INSTRUCTIONS <'AA', 'A ', '  '>
INSTRUCTIONS <'AA', 'S ', '  '>
INSTRUCTIONS <'NO', 'P ', '  '>
INSTRUCTIONS <'CB', 'W ', '  '>
INSTRUCTIONS <'CW', 'D ', '  '>
INSTRUCTIONS <'WA', 'IT', '  '>
INSTRUCTIONS <'PU', 'SH', 'F '>
INSTRUCTIONS <'PO', 'PF', '  '>
INSTRUCTIONS <'SA', 'HF', '  '>
INSTRUCTIONS <'LA', 'HF', '  '>
INSTRUCTIONS <'RE', 'T ', '  '>
INSTRUCTIONS <'RE', 'TF', '  '>
INSTRUCTIONS <'IN', 'T ', '3 '>
INSTRUCTIONS <'IN', 'TO', '  '>
INSTRUCTIONS <'IR', 'ET', '  '>
INSTRUCTIONS <'XL', 'AT', '  '>
INSTRUCTIONS <'LO', 'CK', '  '>
INSTRUCTIONS <'RE', 'PN', 'Z '>
INSTRUCTIONS <'RE', 'PZ', '  '>
INSTRUCTIONS <'HL', 'T ', '  '>
INSTRUCTIONS <'CM', 'C ', '  '>
INSTRUCTIONS <'CL', 'C ', '  '>
INSTRUCTIONS <'ST', 'C ', '  '>
INSTRUCTIONS <'CL', 'I ', '  '>
INSTRUCTIONS <'ST', 'I ', '  '>
INSTRUCTIONS <'CL', 'D ', '  '>
INSTRUCTIONS <'ST', 'D ', '  '>
INSTRUCTIONS <'XC', 'HG', '  '>
INSTRUCTIONS <'LE', 'A ', '  '>
INSTRUCTIONS <'LE', 'S ', '  '>
INSTRUCTIONS <'LD', 'S ', '  '>
INSTRUCTIONS <'IN', 'T ', '  '>
INSTRUCTIONS <'AA', 'M ', '  '>
INSTRUCTIONS <'AA', 'D ', '  '>
INSTRUCTIONS <'LO', 'OP', 'NZ'>
INSTRUCTIONS <'LO', 'OP', 'Z '>
INSTRUCTIONS <'LO', 'OP', '  '>
INSTRUCTIONS <'JC', 'XZ', '  '>
INSTRUCTIONS <'IN', '  ', '  '>
INSTRUCTIONS <'OU', 'T ', '  '>
;=================================
INSTRUCTIONS <'MO', 'V ', '  '>
INSTRUCTIONS <'TE', 'ST', '  '>
;==================================
INSTRUCTIONS <'IN', 'C ', '  '>
INSTRUCTIONS <'DE', 'C ', '  '>
INSTRUCTIONS <'CA', 'LL', '  '>
INSTRUCTIONS <'JM', 'P ', '  '>
INSTRUCTIONS <'PU', 'SH', '  '>
INSTRUCTIONS <'PO', 'P ', '  '>
;===================================
INSTRUCTIONS <'NO', 'T ', '  '>
INSTRUCTIONS <'NE', 'G ', '  '>
INSTRUCTIONS <'MU', 'L ', '  '>
INSTRUCTIONS <'IM', 'UL', '  '>
INSTRUCTIONS <'DI', 'V ', '  '>
INSTRUCTIONS <'ID', 'IV', '  '>
;==================================
INSTRUCTIONS <'RO', 'L ', '  '>
INSTRUCTIONS <'RO', 'R ', '  '>
INSTRUCTIONS <'RC', 'L ', '  '>
INSTRUCTIONS <'RC', 'R ', '  '>
INSTRUCTIONS <'SH', 'L ', '  '>
INSTRUCTIONS <'SH', 'R ', '  '>
INSTRUCTIONS <'SA', 'R ', '  '>
;------------------------------------
INSTRUCTIONS <'MO', 'VS', 'B '>
INSTRUCTIONS <'MO', 'VS', 'W '>
INSTRUCTIONS <'CM', 'PS', 'B '>
INSTRUCTIONS <'CM', 'PS', 'W '>
INSTRUCTIONS <'ST', 'OS', 'B '>
INSTRUCTIONS <'ST', 'OS', 'W '> 
INSTRUCTIONS <'LO', 'DS', 'B '>
INSTRUCTIONS <'LO', 'DS', 'W '>
INSTRUCTIONS <'SC', 'AS', 'B '>
INSTRUCTIONS <'SC', 'AS', 'W '>
;------------------------------------------------------------

Itable dw 0, 0, 0, 0, 0, 0, 432, 438, 6, 6, 6, 6, 6, 6, 432, 438
dw 12, 12, 12, 12, 12, 12, 432, 438, 18, 18, 18, 18, 18, 18, 432, 438
dw 24, 24, 24, 24, 24, 24, 1, 144, 30, 30, 30, 30, 30, 30, 1, 150
dw 36, 36, 36, 36, 36, 36, 1, 156, 42, 42, 42, 42, 42, 42, 1, 162
dw 408, 408, 408, 408, 408, 408, 408, 408, 414, 414, 414, 414, 414, 414, 414, 414
dw 432, 432, 432, 432, 432, 432, 432, 432, 438, 438, 438, 438, 438, 438, 438, 438
dw 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1
dw 48, 54, 60, 66, 72, 78, 84, 90, 96, 102, 108, 114, 120, 126, 132, 138
dw 0FFFAh, 0FFFAh, 0FFFAh, 0FFFAh, 402, 402, 318, 318, 396, 396, 396, 396, 396, 324, 396, 438
dw 168, 318, 318, 318, 318, 318, 318, 318, 174, 180, 420, 186, 192, 198, 204, 210
dw 396, 396, 396, 396, 0FFFBh, 0FFFBh, 0FFFBh, 0FFFBh, 402, 402, 0FFFBh, 0FFFBh, 0FFFBh, 0FFFBh, 0FFFBh, 0FFFBh
dw 396, 396, 396, 396, 396, 396, 396, 396, 396, 396, 396, 396, 396, 396, 396, 396
dw 1, 1, 216, 216, 330, 336, 396, 396, 1, 1, 222, 222, 228, 342, 234, 240
dw 0FFFCh, 0FFFCh, 0FFFCh, 0FFFCh, 348, 354, 1, 246, 1, 1, 1, 1, 1, 1, 1, 1
dw 360, 366, 372, 378, 384, 384, 390, 390, 420, 426, 426, 426, 384, 384, 390, 390
dw 252, 1, 258, 264, 270, 276, 0FFFDh, 0FFFDh, 282, 288, 294, 300, 306, 312, 0FFFEh, 0FFFEh