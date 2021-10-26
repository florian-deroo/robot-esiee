		AREA    |.text|, CODE, READONLY
 
; The GPIODATA register is the data register
; Les switch sont sur la porte D
GPIO_PORTD_BASE			EQU		0x40007000		
; GPIO Port D (APB) base: 0x4000.7000 (p416 datasheet de lm3s9B92.pdf)

; Les bumper sont sur la porte E
GPIO_PORTE_BASE 		EQU     0x40024000
; GPIO Port E (APB) base: 0x4002.4000 (p416 datasheet de lm3s9B92.pdf)
	
BUMPER_LEFT             EQU     0x02
BUMPER_RIGHT        	EQU     0x01

SWITCH_1				EQU 	0x40

; blinking frequency
DUREE   			EQU     0x002FFFFF


	  	ENTRY
		EXPORT	__main
			
		IMPORT  PORT_INIT
		IMPORT  BUMPER_INIT

		IMPORT LED_BOTH_INIT
		IMPORT SWITCH_INIT
		IMPORT LED_BOTH_ON
		IMPORT LED_BOTH_OFF
		IMPORT LED_RIGHT_ON
		IMPORT LED_LEFT_ON
		IMPORT MOTEUR_INIT
		IMPORT MOTEUR_GAUCHE_ON
		IMPORT MOTEUR_GAUCHE_AVANT
		IMPORT MOTEUR_GAUCHE_ARRIERE
		IMPORT MOTEUR_DROIT_ON
		IMPORT MOTEUR_DROIT_AVANT
		IMPORT MOTEUR_DROIT_ARRIERE
		
		IMPORT MOTEUR_AVANCER
		IMPORT MOTEUR_STOP
		IMPORT WAIT_BOTH_BUMPER_ACTIVE

__main	
;Initialisation de tous les composants nécessaires
		BL PORT_INIT
		BL LED_BOTH_INIT
		BL BUMPER_INIT
		BL SWITCH_INIT
		BL MOTEUR_INIT  

;Attente appuie sur le switch 1 pour démarrer
WAIT_START
		ldr r5, = GPIO_PORTD_BASE + (SWITCH_1<<2)
		ldr r0, [r5]
        	CMP r0,#0x00
		BNE WAIT_START

		; Allumer les moteurs
		BL	MOTEUR_DROIT_ON
		BL	MOTEUR_GAUCHE_ON


		; Boucle de pilotage
loop	
		; Le robot avance droit devant
		BL LED_BOTH_OFF
		BL	MOTEUR_DROIT_AVANT	   
		BL	MOTEUR_GAUCHE_AVANT
		
		; Attente que les deux bumper soient actifs
		PUSH {LR}
		BL WAIT_BOTH_BUMPER_ACTIVE
		POP {LR}
	
retry ; Utile si jamais il y a une collision pendant le déplacement
		
		; Faire reculer le robot (si les deux bumpers ont été activés
		BL	MOTEUR_DROIT_ARRIERE
		BL	MOTEUR_GAUCHE_ARRIERE
		
		BL	WAIT
		BL	WAIT
		
		; Tourner à droite de 90°
		BL	MOTEUR_GAUCHE_AVANT
		BL  LED_RIGHT_ON
		
		BL	WAIT
		BL	WAIT
		
		; Avancer un peu
		
		BL  LED_BOTH_OFF
		BL	MOTEUR_DROIT_AVANT	   
		BL	MOTEUR_GAUCHE_AVANT
		BL	WAIT
		
		; Vérifie si un des deux bumper est touché pendant le déplacement
		PUSH {LR}
		BL	CHECK_COLLISIONS
		POP {LR}
		
		BL	WAIT
		
		; Vérifie si un des deux bumper est touché pendant le déplacement
		PUSH {LR}
		BL	CHECK_COLLISIONS
		POP {LR}
		
		; Tourner à gauche
		
		BL  LED_LEFT_ON
		BL	MOTEUR_GAUCHE_ARRIERE 
		
		BL	WAIT
		BL	WAIT
		
		; Reprendre les instructions du départ (le robot avance et attend de toucher avec ses bumper)
		b	loop

		;; Boucle d'attente
WAIT	
		ldr r1, =0xAFFFFF 
wait1	
		subs r1, #1
        	bne wait1
		
		BX	LR

		NOP

; Vérifie si un des deux bumper est touché pendant le déplacement
CHECK_COLLISIONS
		ldr r5, = GPIO_PORTE_BASE + (BUMPER_RIGHT<<2)
		ldr r12, [r5]
        	CMP r12,#0x00
		BEQ retry
		
		ldr r5, = GPIO_PORTE_BASE + (BUMPER_LEFT<<2)
		ldr r12, [r5]
        	CMP r12,#0x00
		BEQ retry
		
		BX LR

		
		BX LR

		NOP
        END
