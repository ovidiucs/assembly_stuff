format ELF64 executable 3

segment readable executable

entry main

main:
  lea rdi, [msg]          ; load effective address of msg into rdi - 
                          ; computes the effective address in memory (offset within a segment)
                          ; of a source operand and places it in gp register
                          ; useful for initializing RSI,ESI,RDI,EDI before the exection of
                          ; string instructions
  mov rax, 14             ; length of message into 'rax' register
  mov rdx, rax            ; moving 'rax' value to 'rdx'
  mov rsi, rdi            ; moving 'rdi' value to 'rsi'
  mov rdi, 1              ; stdout
  mov rax, 1              ; syswrite
  syscall
  xor rdi, rdi            ; exit code of 0 exclusive or / zeroing out the register
  mov rax, 60             ; use sys.exit
  syscall                 ; call OS 

segment readable writable  ; this is where we put our data

  msg db 'Hello World!', 0xA, 0            ; we call it message and declare bytes and say
                                           ; 'Hello World'. 10 for newline character and end with 0
                                           ; H e l l o\  W o r l d ! 0xA 0 - 14
