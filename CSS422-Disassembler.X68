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
*----------------Post: Address will be stored in addrStart and addrEnd
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
        CLR     D5       // Clear D5 for exit address
        MOVE.B  D1, D4   // Move input length into D4, See Convert Pre conditon
        MOVE.B  #$0, d0  // intitiate counter
        JSR     LOOP    // Convert Ending address int Hex
        MOVE.W  #$2200, $6000 // MOVE.L D0, D1, used for testing only
        LEA $6000, A2 //testing
        JSR     OPCODE
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
        
*=======================================================================
*---------Find the first 4 of instruction and determines the instruction
OPCODE:
        JSR     CLRREG
        MOVE.W  (A2), D1
        MOVE.L  D1, D2  //D2 now containse the opperand EA!!!
        LSR.W   #4, D1
        LSR.W   #4, D1
        LSR.W   #4, D1  //Right Shift 3 times
        MOVE.B  D1, D0  // OPCODE FOUND
        MULU    #6, D0
        LEA     JMPTABLE, A2
        JMP     (A2, D0)
        
*========================================================================
*--------Jump table used for different opcode!!! Please orgainze well using decimal
*------- Add your instructions here
JMPTABLE
        JMP     OP0000
        JMP     OP0001
        JMP     OP0010 
         
OP0000:
OP0001:
* -> MOVE.L
* Printed using MOVEL String as a variable on the very bottom
OP0010:
        LEA     MOVEL, A1
        MOVE.B  #14, D0
        TRAP    #15
        BRA     EA
        
        
        
* EA STARTS HERE!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
*=================================================================
*-----------EA-- Calculate EA used for Data Registers
*----------Pre: D2, D0, D1 must be clear
*----------POST: prints out EA, D0 will store Data Register #, D1 will store EA MODE
EA:
        LSL.L   #8, D2 // Remove first 20 bits to get opperand
        LSL.L   #8, D2
        LSL.L   #4, D2
        LSR.L   #8, D2
        LSR.L   #8, D2
        LSR.L   #4, D2 // 12 bits of opperand found
        MOVE.B  D2, D0 Source Data Register
        LSL.B   #5, D0
        LSR.B   #5, D0
        MOVE.B  D2, D1 *Source Data Mode
        LSL.B   #2, D1
        LSR.B   #5, D1
*=================================================
*-----------EA CHECKER------Continues from EA
*-----------Pre: D1 must contain the Mode of EA        
* TODO: ERROR CHECKING, OTHER MODES other than D0
EACHECKER: 
        CMP.B   #$000, D1
        BEQ     JMPTOSRCREG
JMPTOSRCREG:
        LEA     DATAREGTABLE, A1
        MULU    #6, D0  * Multiply by 6 bc Each index between jmp table diff is 6
        JSR     (A1, D0) *JMP To index A1 + D0
        * EA CONTINUES HERE
        JSR     PRINTCOMMA  * Prints comma between two operrands
        LSR.L   #6, D2 *Shift away all Source bits, leaving dest and opcode 
        CLR     D1     * Clear D1 and D0 for opperand mode and register
        CLR     D0
        MOVE.B  D2, D1 * Prepare D1 for Mode
        LSL.B   #5, D1  * Shift 5 bits to get rid of Register and size
        LSR.B   #5, D1
        MOVE.B  D2, D0  *Prepare D0 for Register
        LSL.B   #2, D0
        LSR.B   #5, D0
        CMP.B   #$000, D1 * EA CHECKS BEGIN
        BEQ     JMPTODESTREG
JMPToDestReg: *PRINT OUT DEST Registers
        LEA     DATAREGTABLE, A1
        MULU    #6, D0 * Multiply by 6 bc Each index between jmp table diff is 6
        JSR     (A1, D0) *JMP to A1 + D0
        RTS
        

        
*=================================================================
*---------Data Register Table used for printing out Registers----
*----------Starts from index and use JRS (x,y) to jump to certain index, multiply by #6
DataRegTable
        JMP REG_D0
        JMP REG_D1
        JMP REG_D2
        JMP REG_D3
        JMP REG_D4
        JMP REG_D5
        JMP REG_D6
        JMP REG_D7
        
REG_D0:
        MOVEA.L #$0, A1
        LEA     DREG0, A1
        MOVE.B  #14, D0
        TRAP    #15
        RTS
        
REG_D1:
        LEA     DREG1, A1
        MOVE.B  #14, D0
        TRAP    #15
        RTS
REG_D2:
        LEA     DREG2, A1
        MOVE.B  #14, D0
        TRAP    #15
        RTS
REG_D3:
        LEA     DREG3, A1
        MOVE.B  #14, D0
        TRAP    #15
        RTS
REG_D4:
        LEA     DREG4, A1
        MOVE.B  #14, D0
        TRAP    #15
        RTS
REG_D5:
        LEA     DREG5, A1
        MOVE.B  #14, D0
        TRAP    #15
        RTS
REG_D6:
        LEA     DREG6, A1
        MOVE.B  #14, D0
        TRAP    #15
        RTS
REG_D7:
        LEA     DREG7, A1
        MOVE.B  #14, D0
        TRAP    #15
        RTS
        
PRINTCOMMA: * Prints comma between two operrands
        LEA     COMMA, A1
        MOVE.B  #14, D0
        TRAP    #15
        RTS
        

        
        
        
         
* Clear all registers    
CLRREG:
    CLR D1
    CLR D2
    CLR D3
    CLR D4
    CLR D5
    CLR D6
    RTS
    
    
        
* Put program code here

    SIMHALT             ; halt simulator

* Put variables and constants here
CR  EQU $0D
LF  EQU $0A
WELCOME     DC.B    'Please enter starting address',CR, LF, 0
WELCOME2    DC.B    'Please enter ending address',CR, LF, 0

COMMA       DC.B    ', ', 0


MOVEL       DC.B    'MOVE.L ', 0


*DATA REGISTERS PRINTOUT
DREG0       DC.B    'D0', 0
DREG1       DC.B    'D1', 0
DREG2       DC.B    'D2', 0
DREG3       DC.B    'D3', 0
DREG4       DC.B    'D4', 0
DREG5       DC.B    'D5', 0
DREG6       DC.B    'D6', 0
DREG7       DC.B    'D7', 0 


addrStart   DC.L    1   // Starting address
addrEnd     DC.L    1   // ending address
    END    START        ; last line of source




*~Font name~Courier New~
*~Font size~10~
*~Tab type~1~
*~Tab size~4~
