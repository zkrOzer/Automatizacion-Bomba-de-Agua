	list    p=16f887		    ;declaracion del procesador
	#include<p16f887.inc>

 __CONFIG _CONFIG1, _FOSC_INTRC_NOCLKOUT & _WDTE_OFF & _PWRTE_ON & _MCLRE_ON & _CP_ON & _CPD_OFF & _BOREN_OFF & _IESO_OFF & _FCMEN_OFF & _LVP_OFF
 __CONFIG _CONFIG2, _BOR4V_BOR21V & _WRT_OFF
    
; inicio
          org     0x00
          goto    inicio
          org     0x04
          goto    INTER
			
	cont	    EQU	    0x23
	cont2	    EQU	    0x24
	cont3	    EQU	    0x25
; Se transmite via Serie el dato que esta en el registro W
TX_DATO   bcf     PIR1,TXIF      ; Restaura el flag del transmisor
          movwf   TXREG          ; Mueve el byte a transmitir al registro de transmision
          bsf     STATUS,RP0     ; Bank01
          bcf     STATUS,RP1

TX_DAT_W  btfss   TXSTA,TRMT     ; ?Byte transmitido?
          goto    TX_DAT_W       ; No, esperar
          bcf     STATUS,RP0     ; Si, vuelta a Bank00
	  call	RETARDO
          return

; Tratamiento de interrupci?n
INTER     btfss   PIR1,RCIF      ; ?Interrupci?n por recepci?n?
          goto    VOLVER         ; No, falsa interrupci?n
          bcf     PIR1,RCIF      ; Si, reponer flag
          movf    RCREG,W        ; Lectura del dato recibido
          movwf   PORTB          ; Visualizaci?n del dato
          call    TX_DATO        ; Transmisi?n del dato como eco
VOLVER    retfie

; Comienzo del programa principal
inicio    clrf    PORTB          ; Limpiar salidas
          clrf    PORTC
          bsf     STATUS,RP0     ; Bank01
          bcf     STATUS,RP1
	  movlw	  0xff		 ;PORTD como entrada
	  movwf	  TRISD
          clrf    TRISB          ; PORTB como salida
          movlw   b'10111111'    ; RC7/RX entrada,
          movwf   TRISC          ; RC6/TX salida
          movlw   b'00100100'    ; Configuraci?n USART
          movwf   TXSTA          ; y activaci?n de transmisi?n
          movlw   .25            ; 9600 baudios
          movwf   SPBRG
          bsf     PIE1,RCIE      ; Habilita interrupci?n en recepci?n
          bcf     STATUS,RP0     ; Bank00
          movlw   b'10010000'    ; Configuraci?n del USART para recepci?n continua
          movwf   RCSTA          ; Puesta en ON
          movlw   b'11000000'    ; Habilitaci?n de las
          movwf   INTCON         ; interrupciones en general
	  
	        movlw   b'11001111'
      movwf   OPTION_REG   ;Preescaler de 128 asociado al WDT
	 
    BUCLE  
    
    
		    btfss	PORTD,2
		    goto	CISTERNAVACIA
		    btfsc	PORTD,0
		    goto	TINACO100
		    btfss	PORTD,1
		    goto	BOMBEAR
		    movlw	0x77	    ;tinaco en uso
		    call	TX_DATO
		    goto	BUCLE
		    
    CISTERNAVACIA   		   
		    movlw	0x78	    ;cisterna vacia
		    call	TX_DATO
		    goto	BUCLE
    
    TINACO100	    
		       movlw	0x79	    ;tinaco lleno
		       call	TX_DATO
		 
		    goto	BUCLE
		    
    BOMBEAR
		    movlw	0x01
		    movwf	PORTB
		   
    SIGUE	    btfss	PORTD,0
		    goto	BOMBEANDO
		    movlw	0x00
		    movwf	PORTB	

		    goto	BUCLE
		    
    
    BOMBEANDO	     		   
		    movlw	0x7A        ;bombeando
		    call	TX_DATO
		    goto	SIGUE
		   	    
	
    RETARDO	    
		    movlw	0xF0	    ;P
		    movwf	cont3
	CICLO3	    movlw	0x0F	    ;M
		    movwf	cont2
	CICLO2	    movlw	0x0F	    ;N
		    movwf	cont
	CICLO	    decfsz	cont,F
		    goto	CICLO
		    decfsz	cont2,f
		    goto	CICLO2
		    decfsz	cont3,f
		    goto	CICLO3
		    RETURN
		    
		    
          goto    BUCLE
	  
	  
	
          end


