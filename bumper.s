        AREA    |.text|, CODE, READONLY
 
SYSCTL_PERIPH_GPIO	EQU	0x400FE108

; Les bumper sont sur la porte E
GPIO_PORTE_BASE		EQU	0x40024000
GPIO_O_DEN          	EQU	0x0000051C
GPIO_I_PUR			EQU	0x00000510  

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
