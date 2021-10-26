; The GPIODATA register is the data register
; Les LED sont sur la porte F
GPIO_PORTF_BASE		EQU		0x40025000	; 
GPIO Port F (APB) base: 0x4002.5000 (p416 datasheet de lm3s9B92.pdf)

; configure the corresponding pin to be an output
; all GPIO pins are inputs by default
GPIO_O_DIR   		EQU 	0x00000400  ; GPIO Direction (p417 datasheet de lm3s9B92.pdf)

; The GPIODR2R register is the 2-mA drive control register
; By default, all GPIO pins have 2-mA drive.
GPIO_O_DR2R   		EQU 	0x00000500  ; GPIO 2-mA Drive Select (p428 datasheet de lm3s9B92.pdf)

; Digital enable register
; To use the pin as a digital input or output, the corresponding GPIODEN bit must be set.
GPIO_O_DEN  		EQU 	0x0000051C  ; GPIO Digital Enable (p437 datasheet de lm3s9B92.pdf)

; Broches select
BROCHE4				EQU		0x10		; led gauche
BROCHE5				EQU		0x20		; led droite
BROCHE4_5			EQU		0x30		; led1 & led2 sur broche 4 et 5
	
		AREA    |.text|, CODE, READONLY
		ENTRY
		
		EXPORT LED_RIGHT_ON
		EXPORT LED_LEFT_ON
		EXPORT LED_BOTH_INIT
		EXPORT LED_BOTH_ON
		EXPORT LED_BOTH_OFF

 
LED_BOTH_INIT

		;^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^CONFIGURATION LED

        ldr r7, = GPIO_PORTF_BASE+GPIO_O_DIR    ;; 1 Pin du portF en sortie (broche 4 : 00010000)
        ldr r0, = BROCHE4_5 	
        str r0, [r7]
		
		ldr r7, = GPIO_PORTF_BASE+GPIO_O_DEN	;; Enable Digital Function 
        ldr r0, = BROCHE4_5		
        str r0, [r7]
		
		ldr r7, = GPIO_PORTF_BASE+GPIO_O_DR2R	;; Choix de l'intensité de sortie (2mA)
        ldr r0, = BROCHE4_5			
        str r0, [r7]
		     		
		ldr r7, = GPIO_PORTF_BASE + (BROCHE4_5<<2)  ;; @data Register = @base + (mask<<2) ==> LED1
		;vvvvvvvvvvvvvvvvvvvvvvvFin configuration LED
	
		BX	LR	; //FIN initialisation d'init
			
			
LED_BOTH_ON
	mov r3, #BROCHE4_5
	str r3, [r7]
	BX	LR		
	
LED_BOTH_OFF
	mov r3, #0x000
	str r3, [r7]
	BX	LR			

LED_LEFT_ON
	mov r3, #BROCHE5
	str r3, [r7]
	BX	LR

LED_RIGHT_ON
	mov r3, #BROCHE4
	str r3, [r7]
	BX	LR

		END 
