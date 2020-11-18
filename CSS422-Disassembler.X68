*-----------------------------------------------------------
* Title      :
* Written by :
* Date       :
* Description:
*-----------------------------------------------------------
    ORG    $1000
*=================================================================
*                     THIS IS OUR MAIN METHOD
*               Don't throw random stuff in it, keep it to a minimum

START:                  ; first instruction of program
        JSR     GETINPUT
*=================================================================
*---------------Get starting and ending addresss------- Kelvin
*--------------- PRE: will be using D0, D5, A1
*----------------Post Address will be stored in addrStart and addrEnd
GETINPUT:
        LEA     WELCOME, A1
        MOVE.B  #14,    D0
        TRAP    #15
        MOVEA   #$0, A1 // Clear A1 to prevent screen freeze
        MOVE.B  #2,D0
        TRAP    #15
        MOVE.L  D1, D4   // Move input length into D4, See Convert Pre conditon
        MOVE.L  #$0, d0  // intitiate counter
        JSR     LOOP    // Convert starting address into hex
        MOVE.L  D5, addrStart
        LEA     WELCOME2, A1
        MOVE.B  #14,    D0
        TRAP    #15
        MOVEA   #$0, A1 // Clear A1 to prevent screen freeze
        MOVE.B  #2,D0
        TRAP    #15
        MOVE.L  D5, addrEnd
        MOVE.B  D1, D4   // Move input length into D4, See Convert Pre conditon
        MOVE.B  #$0, d0  // intitiate counter
        JSR     LOOP    // Convert starting address into hex
        JMP     END
END:
        MOVE.B  #9, D0
        TRAP    #15
LOOP
        CMP.L   D0, D4  // Loop until length of word reached
        BGT     CONVERT
        RTS 

*=================================================================
*---------------NUMBER CONVERSION FROM INPUT TO HEX------- Kelvin
*PRE      D4 must contain input length, d0 must be 0
*POST     D5 WILL CONTAIN ADDRESS VALUE IN HEX        
CONVERT:
        ADDQ.L  #$1, D0 // increment counter
        move.b  (A1),D1    // Get next bit from Input
        adda.L  #1, A1      // Increment Input
        sub.b   #$30,D1     //
        cmp.b   #$10,D1   // Check if value is larger than 10
        bgt     CHAR      // Find Hex
        move.b  D1, D2    // IF it is less than 10
        JMP     ADDVAL        
CHAR:
        CMP.B   #$11, D1 // Convert each hex into an appropriate hex
        BEQ     A
        CMP.B   #$12, D1
        BEQ     B
        CMP.B   #$13, D1
        BEQ     C
        CMP.B   #$14, D1
        BEQ     D
        CMP.B   #$15, D1
        BEQ     E
        CMP.B   #$16, D1
        BEQ     F

ADDVAL:
        lsl.l    #$4, D5 // Shift based on position
        add.l    D2, D5 //Add value into Input
        BRA      LOOP
    
A:
        MOVE.L  #$A, D2 
        jmp ADDVAL
B:
        MOVE.L  #$B, D2
        jmp ADDVAL
C:
        MOVE.L  #$C, D2
        jmp ADDVAL
D:
        MOVE.L  #$D, D2
        jmp ADDVAL
E:
        MOVE.L  #$E, D2
        jmp ADDVAL
F:
        MOVE.L  #$F, D2
        jmp ADDVAL
        
* Put program code here

    SIMHALT             ; halt simulator

* Put variables and constants here
CR  EQU $0D
LF  EQU $0A
WELCOME     DC.B    'Please enter starting address',CR, LF, 0
WELCOME2    DC.B    'Please enter ending address',CR, LF, 0
addrStart   DC.L    1
addrEnd     DC.L    1
    END    START        ; last line of source



*~Font name~Courier New~
*~Font size~10~
*~Tab type~1~
*~Tab size~4~
