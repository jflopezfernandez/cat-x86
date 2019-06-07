
;==============================================================================
;
;  Executable name : x86
;  Version         : 1.0
;  Created date    : 6/6/2019
;  Last update     : 6/6/2019
;  Author          : Jose Fernando Lopez Fernandez
;  Description     : Rewrite of the Unix cat utility in x86 assembly.
;
;  Build using these commands:
;    nasm -f elf -g -F stabs main.asm
;    ld -m elf_i386 -o x86 main.o
;
;==============================================================================
;
;                          PREPROCESSOR DEFINITIONS
;
;------------------------------------------------------------------------------

    %define     EOF             0

    %define     STDIN           0
    %define     STDOUT          1
    %define     STDERR          2

    %define     SYSCALL_EXIT    1
    %define     SYSCALL_READ    3
    %define     SYSCALL_WRITE   4

    %define     SECTOR_SIZE     512
    %define     BUFFER_SIZE     SECTOR_SIZE

;==============================================================================
;
;                            DATA SEGMENT
;
;==============================================================================

                SECTION .data
		
;==============================================================================
;
;                             BSS SEGMENT
;
;==============================================================================

                SECTION .bss

BUFF            RESB    BUFFER_SIZE         ; Input buffer for reading input

;==============================================================================
;
;
;
;==============================================================================

                SECTION .text			    ; Section containing code

                GLOBAL 	_start			    ; Global entry point
                GLOBAL  EXIT

;==============================================================================
;
;                               EXIT
;
;==============================================================================
;
;       This is the exit point of the application. The function passes
;       on its argument in RBX as the exit code unmodifed. For this
;       reason, the onus is on the calling functions to specify an 
;       actual return code in RBX, as calling the EXIT function without
;       ensuring a value is being purposely set will result in a non-
;       zero return code nearly all of the time, statistically speaking.
;
;       This is signficant because a non-zero exit code signifies a run-
;       time error in the application, and therefore a false alarm in 
;       this specific case.
;
;------------------------------------------------------------------------------

EXIT:           MOV     EAX,SYSCALL_EXIT
                INT     80H                 ; Return exit code in RBX

;==============================================================================
;
;                           PROGRAM START
;
;==============================================================================

_start:			

.READ:          MOV     EAX,SYSCALL_READ    ; Set system call read
                MOV     EBX,STDIN           ; File descriptor stdin
                MOV     ECX,BUFF            ; Buffer address (.bss)
                MOV     EDX,BUFFER_SIZE     ; Size of the buffer (SECTOR_SIZE)
                INT     80H                 ; Call kernel

                CMP     EAX,EOF             ; Check for EOF signal
                JE      .DONE               ; Exit if finished

.PRINT:         MOV     EAX,SYSCALL_WRITE
                MOV     EBX,STDOUT
                MOV     ECX,BUFF
                MOV     EDX,BUFFER_SIZE
                INT     80H

                MOV     ESI,BUFF            ; Prepare to zero out the input buff
                XOR     EDI,EDI             ; Initialize offset to zero 

.CLEARBUFF:     CMP     EDI,BUFFER_SIZE     ; for (i = 0; i < BUFFER_SIZE; ++i)
                JE      .BUFFCLEAR          ; If buffer is clear, move on
                MOV     BYTE[BUFF+EDI],0    ; BUFF[i] = 0
                INC     EDI
                JMP     .CLEARBUFF

.BUFFCLEAR:     JMP     .READ
                
.DONE:          PUSH    10                  ; Push newline char to stack
                MOV     EAX,SYSCALL_WRITE   ; Set system call
                MOV     EBX,STDOUT          ; Set file descriptor
                MOV     ECX,ESP             ; Pass location of newline char
                MOV     EDX,1               ; Length of string
                INT     80H                 ; Call kernel
                POP     EAX                 ; Reset stack
                CALL    EXIT                ; Call exit subroutine

