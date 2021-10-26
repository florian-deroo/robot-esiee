SYSCTL_PERIPH_GPIO EQU	0x400FE108
	
		AREA    |.text|, CODE, READONLY
		ENTRY
		
		EXPORT PORT_INIT
 
PORT_INIT

	ldr r8, = SYSCTL_PERIPH_GPIO
	mov r0, #0x38 ; Activation de tous les périphériques nécessaire avec l'adresse 0x38
	str r0, [r8]

	nop
	nop	   
	nop
		
	BX	LR
		END 
