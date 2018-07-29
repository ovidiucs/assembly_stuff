format ELF64 executable 3
; v.05 include files - move functions to separate file
; v.04 bug in main  after strlen it called print which called strlen again. core dump
; v.03 create a function to also print the string
; v.02 create function outside of main and 
; calculate the length of the string

segment readable executable

entry main

include 'io.inc'          ; the name of the file to be included

main:
  lea rdi, [msg]          ; load effective address of msg into rdi - 
                          ; computes the effective address in memory (offset within a segment)
                          ; of a source operand and places it in gp register
                          ; useful for initializing RSI,ESI,RDI,EDI before the exection of
                          ; string instructions
  call print             ; we call the print function
  lea rdi, [msg2]         ; testing with another message
  call print             ; printing it
  xor rdi, rdi            ; exit code of 0 exclusive or / zeroing out the register
  mov rax, 60             ; use sys.exit
  syscall                 ; call OS 

segment readable writable  ; this is where we put our data

  msg db 'Hello World!', 0xA, 0            ; we call it message and declare bytes and say
                                           ; 'Hello World'. 10 for newline character and end with 0
                                           ; H e l l o\  W o r l d ! 0xA 0 - 14

  msg2 db 'This is another string!', 0xA, 0
