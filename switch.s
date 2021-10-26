        AREA    |.text|, CODE, READONLY

; Les SWITCH sont sur la porte D
GPIO_PORTD_BASE		EQU		0x40007000        
GPIO_O_DEN			EQU     0x0000051C  ; GPIO Digital Enable (p437 datasheet de lm3s9B92.pdf)
GPIO_I_PUR			EQU     0x00000510  ; GPIO Pull-Up (p432 datasheet de lm3s9B92.pdf)

SWITCH_1			EQU     0x40

          AREA    |.text|, CODE, READONLY
        ENTRY
        
        EXPORT SWITCH_INIT


SWITCH_INIT

		;^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^CONFIGURATION Switcher 1

		ldr r5, = GPIO_PORTD_BASE+GPIO_I_PUR	;; Pul_up 
        	ldr r0, = SWITCH_1		
        	str r0, [r5]
		
		ldr r5, = GPIO_PORTD_BASE+GPIO_O_DEN	;; Enable Digital Function 
        	ldr r0, = SWITCH_1	
        	str r0, [r5]     
		
		ldr r5, = GPIO_PORTD_BASE + (SWITCH_1<<2)  ;; @data Register = @base + (mask<<2) ==> Switcher
		
		;vvvvvvvvvvvvvvvvvvvvvvvFin configuration Switcher 

		BX LR

                
        END
