        AREA    |.text|, CODE, READONLY
 
; This register controls the clock gating logic in normal Run mode
SYSCTL_PERIPH_GPIO	EQU	0x400FE108    ; SYSCTL_RCGC2_R (p291 datasheet de lm3s9b92.pdf)

; The GPIODATA register is the data register
; Les bumper sont sur la porte E
GPIO_PORTE_BASE		EQU	0x40024000		; GPIO Port E (APB) base: 0x4002.4000 (p416 datasheet de lm3s9B92.pdf)

; Digital enable register
; To use the pin as a digital input or output, the corresponding GPIODEN bit must be set.
GPIO_O_DEN          EQU	0x0000051C  ; GPIO Digital Enable (p437 datasheet de lm3s9B92.pdf)

; Pul_up
GPIO_I_PUR			EQU	0x00000510  ; GPIO Pull-Up (p432 datasheet de lm3s9B92.pdf)

BUMPER_LEFT			EQU	0x02
BUMPER_RIGHT        		EQU	0x01
BUMPER_BOTH			EQU	0x03


          AREA    |.text|, CODE, READONLY
        ENTRY
        
        EXPORT BUMPER_INIT
		EXPORT WAIT_BOTH_BUMPER_ACTIVE

        IMPORT LED_RIGHT_ON
        IMPORT LED_LEFT_ON
        IMPORT LED_BOTH_ON
		IMPORT MOTEUR_STOP
        IMPORT MOTEUR_AVANCER
		IMPORT MOTEUR_GAUCHE_AVANT
		IMPORT MOTEUR_DROIT_AVANT
		IMPORT MOTEUR_GAUCHE_ARRIERE
		IMPORT MOTEUR_DROIT_ARRIERE


BUMPER_INIT
        ;^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^CONFIGURATION Bumper

        ldr r5, = GPIO_PORTE_BASE+GPIO_I_PUR
        ldr r3, = BUMPER_BOTH        
        str r3, [r5]
        
        ldr r5, = GPIO_PORTE_BASE+GPIO_O_DEN 
        ldr r3, = BUMPER_BOTH    
        str r3, [r5]     
        
        ldr r5, = GPIO_PORTE_BASE + (BUMPER_BOTH<<2)  ;; @data Register = @base + (mask<<2)
        
        ;vvvvvvvvvvvvvvvvvvvvvvvFin configuration Bumper 
        
  
        
        BX LR
       
; ####################################################################
; FONCTIONNEMENT DE CETTE PARTIE DÉCRITE PAR LE SCHÉMA DANS LE RAPPORT
; ####################################################################

CHECK_RIGHT

		ldr r5, = GPIO_PORTE_BASE + (BUMPER_RIGHT<<2)  ;; @data Register = @base + (mask<<2)
		ldr r4, [r5]
        	CMP r4,#0x00
		
       	 	BNE WAIT_BOTH_BUMPER_ACTIVE
		
		PUSH {LR}
		BL MOTEUR_DROIT_ARRIERE
		BL LED_RIGHT_ON
		POP {LR}

wait_left

        	ldr r5, = GPIO_PORTE_BASE + (BUMPER_LEFT<<2)  ;; @data Register = @base + (mask<<2)
		ldr r3, [r5]
        	CMP r3,#0x00
        	BNE wait_left
		
		PUSH {LR}
		BL LED_BOTH_ON
		POP {LR}
		BX LR



WAIT_BOTH_BUMPER_ACTIVE
		
		ldr r5, = GPIO_PORTE_BASE + (BUMPER_LEFT<<2)
		ldr r10, [r5]
		CMP r10,#0x00
		BNE CHECK_RIGHT
		
		PUSH {LR}
		BL MOTEUR_GAUCHE_ARRIERE
		BL LED_LEFT_ON
		POP {LR}
		
wait_right

		ldr r5, = GPIO_PORTE_BASE + (BUMPER_RIGHT<<2)
		ldr r11, [r5]
		CMP r11,#0x00
		BNE wait_right
		
		PUSH {LR}
		BL LED_BOTH_ON
		POP {LR}
		
		BX LR
        END
