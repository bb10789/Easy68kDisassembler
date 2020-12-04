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
       * MOVEA.L  D0, A0   // Testing
        MOVE.W  #$D4E5, $6000 // MOVE.L D0, D1, used for testing only
        LEA     $6000, A2 //testing
        JSR     OPCODE
        JMP     END
END:
        MOVE.B  #9, D0
        TRAP    #15
        
*Please start from here Annabelle
AddrLoop:
        BRA     END     // DELETE THIS WHEN UR WORKING ON IT ANNABELLE!!!!!!!
LOOP

        CMP.L   D0, D4  // Loop until length of word reached
        BGT     CONVERT
        ADD.L   #$2, D0 
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
        JMP     OP0001 *MOVEB
        JMP     OP0010 *MOVEL
        JMP     OP0011 *MOVEW
        JMP     OP0100 *MOVEM
        JMP     OP0101
        JMP     OP0110
        JMP     OP0111
        JMP     OP1000
        JMP     OP1001 *SUB
        JMP     OP1010
        JMP     OP1011
        JMP     OP1100
        JMP     OP1101 *ADD
         
OP0000:
*-> MOVE.B
OP0001:
        LEA     MOVEB, A1
        MOVE.B  #14, D0
        TRAP    #15
        JSR     EA * Find SRC EA
        BRA     DESTEAFINDER * FIND DEST EA
* -> MOVE.L
* Printed using MOVEL String as a variable on the very bottom
OP0010:
        LEA     MOVE_PRINT, A1
        MOVE.B  #14, D0
        TRAP    #15
        JSR     CHECK_MOVEA
        LEA     MOVEL, A1
        MOVE.B  #14, D0
        TRAP    #15
        JSR     EA *Find SRC EA
        BRA     DESTEAFINDER *FIND DEST EA
* -> MOVE.W
OP0011:
        LEA     MOVE_PRINT, A1
        MOVE.B  #14, D0
        TRAP    #15
        JSR     CHECK_MOVEA
        LEA     MOVEW, A1
        MOVE.B  #14, D0
        TRAP    #15
        JSR     EA * FIND SRC EA
        BRA     DESTEAFINDER *FIND DEST EA
OP0100:
OP0101:
        
OP0110:
OP0111:
        



* -> SUB
* Splitting Sub into OPMODE and Register value
OP1001:
        LEA     SUBTRACT, A1
        MOVE.B  #14, D0
        TRAP    #15
        LSL.W   #4, D2
        MOVE.W  D2, D3 *xxx---xxx---0000, D3 contains register #
        LSR.W   #8, D3 * D3 = D register
        LSR.W   #5, D3
        MOVE.W  D2, D4 *D4 = SubOPMODE
        LSL.W   #3, D4
        LSR.W   #8, D4
        LSR.W   #5, D4
        MOVE.W  D2, D1 * D1 = EA Mode
        LSL.W   #6, D1
        LSR.W   #8, D1
        LSR.W   #5, D1
        MOVE.W  D2, D0 * D0 = EA register
        LSL.W   #8, D0
        LSL.W   #1, D0
        LSR.W   #8, D0
        LSR.W   #5, D0
        LEA     SubTable, A2
        MULU    #6, D4
        JSR     (A2, D4)
        
OP1000:
OP1010
OP1011
OP1100
        
* -> ADD
* Spltting Add into OPMODE and Register Value
OP1101:
        LEA     ADDITION, A1
        MOVE.B  #14, D0
        TRAP    #15
        LSL.W   #4, D2
        MOVE.W  D2, D3 *xxx---xxx---0000, D3 contains register #
        LSR.W   #8, D3 * D3 = D register
        LSR.W   #5, D3
        MOVE.W  D2, D4 *D4 = SubOPMODE
        LSL.W   #3, D4
        LSR.W   #8, D4
        LSR.W   #5, D4
        MOVE.W  D2, D1 * D1 = EA Mode
        LSL.W   #6, D1
        LSR.W   #8, D1
        LSR.W   #5, D1
        MOVE.W  D2, D0 * D0 = EA register
        LSL.W   #8, D0
        LSL.W   #1, D0
        LSR.W   #8, D0
        LSR.W   #5, D0
        LEA     SubTable, A2
        MULU    #6, D4
        JSR     (A2, D4)
        
* =============================================
* JMP Table for SUB OPMODES
SubTable:
        JMP     OPMODE000 * BYTE  EA->DN
        JMP     OPMODE001 * WORD  RA->DN  
        JMP     OPMODE010 * LONG  EA->DN 
        JMP     OPMODE011 * ADDA  WORD
        JMP     OPMODE100 * BYTE  DN->EA
        JMP     OPMODE101 * BYTE  DN->EA
        JMP     OPMODE110 * BYTE  DN->EA
        JMP     OPMODE111 * ADDA  LONG
        
OPMODE000:
        MOVE.B  D0, D5   * TEMP STORAGE for DATA register
        LEA     SIZE_BYTE, A1
        MOVE.B  #14, D0
        TRAP    #15
        BRA     Sub_OPMODE_FIRST
OPMODE001
        MOVE.B  D0, D5   * TEMP STORAGE for DATA register
        LEA     SIZE_Word, A1
        MOVE.B  #14, D0
        TRAP    #15
        BRA     Sub_OPMODE_FIRST
OPMODE010
        MOVE.B  D0, D5   * TEMP STORAGE for DATA register
        LEA     SIZE_Long, A1
        MOVE.B  #14, D0
        TRAP    #15
        BRA     Sub_OPMODE_FIRST
OPMODE011
        MOVE.B  D0, D5
        LEA     MOVEA, A1
        MOVE.B  #14, D0
        TRAP    #15
        LEA     SIZE_WORD, A1
        MOVE.B  #14, D0
        TRAP    #15
        BRA     Sub_OPMODE_ADDA
OPMODE100
        MOVE.B  D0, D5   * TEMP STORAGE for DATA register
        LEA     SIZE_BYTE, A1
        MOVE.B  #14, D0
        TRAP    #15
        BRA     Sub_OPMODE_SECOND
OPMODE101
        MOVE.B  D0, D5   * TEMP STORAGE for DATA register
        LEA     SIZE_Word, A1
        MOVE.B  #14, D0
        TRAP    #15
        BRA     Sub_OPMODE_SECOND
OPMODE110
        MOVE.B  D0, D5   * TEMP STORAGE for DATA register
        LEA     SIZE_LONG, A1
        MOVE.B  #14, D0
        TRAP    #15
        BRA     Sub_OPMODE_SECOND
OPMODE111
        JMP     PRINTInvalidSUB

*===============================================
* Used for Dn->EA for SUB
* Called by 001, 010, 100, 
Sub_OPMODE_FIRST:
        MOVE.B  D5, D0   * TEMP RETURN D0
        JSR     EACHECKER 
        CLR     D0
        CLR     D1
        JSR     PRINTCOMMA
        MOVE.B  D3, D0
        JSR     DestEAChecker 
        BRA     addrloop *EA FINISHED---------------------------------------------------------------------------------------------------------------------------
*===============================================
* Used for Dn->EA for SUB
* Called by 100, 101, 110 
Sub_OPMODE_SECOND:
        MOVE.B  D1, D4   *TEMP STORE D1
        CLR     D0  *Clean D0
        MOVE.B  D3, D0
        CLR     D1
        JSR     EACHECKER 
        CLR     D0
        CLR     D1
        JSR     PRINTCOMMA
        MOVE.B  D5, D0   * TEMP RETURN D0
        MOVE.B  D4, D1   * TEMP RETURN D1
        JSR     DestEAChecker 
        BRA     addrloop *EA FINISHED-----
*===============================================
* Used for Dn->EA for SUB
* Called by 011, 111
Sub_OPMODE_ADDA:
        MOVE.B  D5, D0   * TEMP RETURN D0
        JSR     EACHECKER 
        CLR     D0
        CLR     D1
        JSR     PRINTCOMMA
        MOVE.B  D3, D0
        MOVE.B  #%001, D1
        JSR     DestEAChecker 
        BRA     addrloop *EA FINISHED---------------------------------------------------------------------------------------------------------------------------
        
* CHECK FOR MOVEA BC it has the same OPCODE as MOVE
CHECK_MOVEA
        MOVE.L  D2, D3  * HOlding D2 in D3 temp
        LSL.L   #8, D2 // Remove first 20 bits to get opperand
        LSL.L   #8, D2
        LSL.L   #4, D2
        LSR.L   #8, D2
        LSR.L   #8, D2
        LSR.L   #4, D2 // 12 bits of opperand found
        LSR.L   #6, D2 *Shift away all Source bits, leaving dest and opcode 
        MOVE.B  D2, D1 * Prepare D1 for Mode
        LSL.B   #5, D1  * Shift 5 bits to get rid of Register and size
        LSR.B   #5, D1
        CMP.B   #%001, D1
        BEQ     PRINTA
        MOVE.L  D3, D2 
        RTS * Goes back to OP Value
        
PRINTA
        LEA     MOVEA, A1
        MOVE.B  #14, D0
        TRAP    #15
        MOVE.L  D3, D2
        RTS * Goes back to CHECK_MOVEA
        
        
* EA STARTS HERE!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!! 
*=================================================================
*-----------EA-- Calculate EA used for Data Registers
*----------Pre: D2, D0, D1 must be clear
*----------POST: prints out EA, D0 will store Data Register #, D1 will store EA MODE
EA:
        CLR     D0  * Clear D0 and D1 so they don't conflict
        CLR     D1
        CLR     D3
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
*-----------Pre: D1 must contain the Mode of EA, D0 must store register# of EA        
* TODO: ERROR CHECKING, OTHER MODES other than D0, USE 4 HEX FOR COMPARISON
EACHECKER: 
        CMP.B   #%0000, D1
        BEQ     JMPTOSRCREG *JUMPS TO Source D registers
        CMP.B   #%0001, D1
        BEQ     JMPTO_SRC_ADDR_REG
        CMP.B   #%0010, D1
        BEQ     JMPTO_SRC_INDR_ADDR_REG
        CMP.B   #%0011, D1
        BEQ     JMPTO_SRC_INDR_ADDR_REG
        CMP.B   #%0100, D1
        BEQ     JMPTO_SRC_INDR_ADDR_REG
        JMP     PRINTINVALIDEA
        
*=================================================
*-----------DEST EA CHECKER------Continues from EA
*-----------Pre: D1 must contain the Mode of EA, D0 must store register# of EA        
* TODO: ERROR CHECKING, OTHER MODES other than D0, USE 4 HEX FOR COMPARISON        
DESTEACHECKER:
        CMP.B   #%0000, D1
        BEQ     JMPTODestREG *JUMPS TO Source D registers
        CMP.B   #%0001, D1
        BEQ     JMPTO_DEST_ADDR_REG
        CMP.B   #%0010, D1
        BEQ     JMPTO_DEST_INDR_ADDR_REG
        CMP.B   #%0011, D1
        BEQ     JMPTO_DEST_INDR_ADDR_REG
        CMP.B   #%0100, D1
        BEQ     JMPTO_DEST_INDR_ADDR_REG
        JMP     PRINTINVALIDEA
        
*=================================================      
* Dest EA Finder
* PRE: ONLY USED FOR MOVE
* POST: PRINTS DEST EA  
DestEAFinder:
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
        JSR     DESTEACHECKER
        JMP     END     ****Remember to send this back to next step loop&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&

        
*===================================================
*-------------Data Register checker------------------        
JMPTOSRCREG:
        LEA     DATAREGTABLE, A1
        MULU    #6, D0  * Multiply by 6 bc Each index between jmp table diff is 6
        JSR     (A1, D0) *JMP To index A1 + D0
        * EA CONTINUES HERE
        RTS * BRA DESTEAFINDER DELETED
JMPToDestReg: *PRINT OUT DEST Registers
        LEA     DATAREGTABLE, A1
        MULU    #6, D0 * Multiply by 6 bc Each index between jmp table diff is 6
        JSR     (A1, D0) *JMP to A1 + D0
        RTS    * Goes Back to DestEAFinder
        

*===================================================
*-------------Address Register checker------------------             
JMPTO_SRC_ADDR_REG:
        LEA     AddrREGTABLE, A1
        MULU    #6, D0  * Multiply by 6 bc Each index between jmp table diff is 6
        JSR     (A1, D0) *JMP To index A1 + D0
        * EA CONTINUES HERE
        RTS * BRA DESTEAFINDER DELETED
JMPTo_Dest_ADDR_Reg: *PRINT OUT DEST Registers
        LEA     AddrREGTABLE, A1
        MULU    #6, D0 * Multiply by 6 bc Each index between jmp table diff is 6
        JSR     (A1, D0) *JMP to A1 + D0
        RTS     * Goes Back to DESTEAFinder
        
*===================================================
*-------------Indirect Address Register checker------------------
*Copied from Address Register checker, basically adding parenthesis () around Address register
* Also Detects ()+ and -()
* PRE: D1 stores mode, D0 stores register #
* D1 to D5 are off limits
JMPTO_SRC_INDR_ADDR_REG:
       MOVE.B   D0, D5  *TEMP storage for D0 because it will be used by PRINT
       CMP.B    #%100, D1       * IF IT IS -()
       BEQ      PRE_DECREMENT_SRC
       LEA      INDR_LEFT, A1
       MOVE.B   #14, D0
       TRAP     #15
       MOVE.B   D5, D0   *TEMP storage for D0 because it will be used by PRINT
       LEA     AddrREGTABLE, A1
       MULU    #6, D0  * Multiply by 6 bc Each index between jmp table diff is 6
       JSR     (A1, D0) *JMP To index A1 + D0
       LEA      INDR_RIGHT, A1
       MOVE.B   #14, D0
       TRAP     #15
       CMP.B    #%0011, D1 * IF IT IS ()+
       BEQ      POST_INCREMENT_SRC
       RTS * BRA DESTEAFINDER DELETED
       
JMPTO_DEST_INDR_ADDR_REG:
       MOVE.B   D0, D3  *TEMP storage for D0 because it will be used by PRINT
       CMP.B    #%100, D1
       BEQ      PRE_DECREMENT_DEST * IF IT IS -()
       LEA      INDR_LEFT, A1
       MOVE.B   #14, D0
       TRAP     #15
       MOVE.B   D3, D0   *TEMP storage for D0 because it will be used by PRINT
       LEA     AddrREGTABLE, A1
       MULU    #6, D0  * Multiply by 6 bc Each index between jmp table diff is 6
       JSR     (A1, D0) *JMP To index A1 + D0
       LEA      INDR_RIGHT, A1
       MOVE.B   #14, D0
       TRAP     #15
       CMP.B    #%0011, D1  // IF IT IS ()+
       BEQ      POST_INCREMENT_DEST
       RTS      * Goes Back to DestEAFinder
       
POST_INCREMENT_SRC:
       LEA      POST_INCRE, A1
       MOVE.B   #14, D0
       TRAP     #15
       RTS * BRA DESTEAFINDER DELETED
       
PRE_DECREMENT_SRC:
       LEA      PRE_DECRE, A1
       MOVE.B   #14, D0
       TRAP     #15
       LEA      INDR_LEFT, A1
       MOVE.B   #14, D0
       TRAP     #15
       MOVE.B   D5, D0   *TEMP storage for D0 because it will be used by PRINT
       LEA     AddrREGTABLE, A1
       MULU    #6, D0  * Multiply by 6 bc Each index between jmp table diff is 6
       JSR     (A1, D0) *JMP To index A1 + D0
       LEA      INDR_RIGHT, A1
       MOVE.B   #14, D0
       TRAP     #15
       RTS * BRA DESTEAFINDER DELETED

POST_INCREMENT_DEST
       LEA      POST_INCRE, A1
       MOVE.B   #14, D0
       TRAP     #15
       RTS      * Goes Back to DestEAFinder
       
PRE_DECREMENT_DEST:
       LEA      PRE_DECRE, A1
       MOVE.B   #14, D0
       TRAP     #15
       LEA      INDR_LEFT, A1
       MOVE.B   #14, D0
       TRAP     #15
       MOVE.B   D5, D0   *TEMP storage for D0 because it will be used by PRINT
       LEA     AddrREGTABLE, A1
       MULU    #6, D0  * Multiply by 6 bc Each index between jmp table diff is 6
       JSR     (A1, D0) *JMP To index A1 + D0
       LEA      INDR_RIGHT, A1
       MOVE.B   #14, D0
       TRAP     #15
       RTS      * Goes Back to DestEAFinder
       


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

AddrRegTable:
        
        JMP REG_A0
        JMP REG_A1
        JMP REG_A2
        JMP REG_A3
        JMP REG_A4
        JMP REG_A5
        JMP REG_A6
        JMP REG_A7

* Data Registers Printing        
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
        
*--------------------Addr Reigster printing ------------------------*        
REG_A0:
        MOVEA.L #$0, A1
        LEA     AREG0, A1
        MOVE.B  #14, D0
        TRAP    #15
        RTS
        
REG_A1:
        LEA     AREG1, A1
        MOVE.B  #14, D0
        TRAP    #15
        RTS
REG_A2:
        LEA     AREG2, A1
        MOVE.B  #14, D0
        TRAP    #15
        RTS
REG_A3:
        LEA     AREG3, A1
        MOVE.B  #14, D0
        TRAP    #15
        RTS
REG_A4:
        LEA     AREG4, A1
        MOVE.B  #14, D0
        TRAP    #15
        RTS
REG_A5:
        LEA     AREG5, A1
        MOVE.B  #14, D0
        TRAP    #15
        RTS
REG_A6:
        LEA     AREG6, A1
        MOVE.B  #14, D0
        TRAP    #15
        RTS
REG_A7:
        LEA     AREG7, A1
        MOVE.B  #14, D0
        TRAP    #15
        RTS
        
*====================================================PRinting/ ERROR method comes down here=========================================
PRINTCOMMA: * Prints comma between two operrands
        LEA     COMMA, A1
        MOVE.B  #14, D0
        TRAP    #15
        RTS
        
PrintInvalidEA:
        LEA     Invalid_EA_Addr, A1
        MOVE.B  #14, D0
        TRAP    #15
        JMP     AddrLoop
        
PrintInvalidSUB:
        LEA     Invalid_EA_SUB, A1
        MOVE.B  #14, D0
        TRAP    #15
        JMP     AddrLoop
        
        
        
         
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
Invalid_EA_ADDR DC.B   'Invalid EA detected', CR, LF, 0
INVALID_EA_SUB  DC.B    'Invalid SUB OPMODE Detected', CR, LF, 0

COMMA       DC.B    ', ', 0

*DATASIZE
SIZE_BYTE       DC.B    '.B ', 0
SIZE_WORD       DC.B    '.W ', 0
SIZE_LONG       DC.B    '.L ', 0

*MOVE OPCODES
MOVE_PRINT  DC.B    'MOVE', 0
MOVEB       DC.B    'MOVE.B ', 0
MOVEW       DC.B    '.W ', 0
MOVEL       DC.B    '.L ', 0
MOVEA       DC.B    'A', 0


*DATA REGISTERS PRINTOUT
DREG0       DC.B    'D0', 0
DREG1       DC.B    'D1', 0
DREG2       DC.B    'D2', 0
DREG3       DC.B    'D3', 0
DREG4       DC.B    'D4', 0
DREG5       DC.B    'D5', 0
DREG6       DC.B    'D6', 0
DREG7       DC.B    'D7', 0 

*ADDR REGISTERS PRINTOUT
AREG0       DC.B    'A0', 0
AREG1       DC.B    'A1', 0
AREG2       DC.B    'A2', 0
AREG3       DC.B    'A3', 0
AREG4       DC.B    'A4', 0
AREG5       DC.B    'A5', 0
AREG6       DC.B    'A6', 0
AREG7       DC.B    'A7', 0 

*INDR_ADDR REGISTERS PRINTOUT
INDR_LEFT   DC.B    '(', 0
INDR_RIGHT  DC.B    ')', 0
POST_INCRE   DC.B    '+', 0
PRE_DECRE   DC.B    '-', 0

*SUB
SUBTRACT    DC.B    'SUB', 0
ADDITION    DC.B    'ADD', 0

addrStart   DC.L    1   // Starting address
addrEnd     DC.L    1   // ending address
    END    START        ; last line of source







*~Font name~Courier New~
*~Font size~10~
*~Tab type~1~
*~Tab size~4~