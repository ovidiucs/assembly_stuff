format ELF64 executable 3
; v.04 bug in main  after strlen it called print which called strlen again. core dump
; v.03 create a function to also print the string
; v.02 create function outside of main and 
; calculate the length of the string

segment readable executable

entry main

main:
  lea rdi, [msg]          ; load effective address of msg into rdi - 
                          ; computes the effective address in memory (offset within a segment)
                          ; of a source operand and places it in gp register
                          ; useful for initializing RSI,ESI,RDI,EDI before the exection of
                          ; string instructions
  call .print             ; we call the print function
  xor rdi, rdi            ; exit code of 0 exclusive or / zeroing out the register
  mov rax, 60             ; use sys.exit
  syscall                 ; call OS 

.strlen:
  push rdi                ; push registers to stack
  push rcx                ; saving these values
                          ; after function return leave as intiial state
  sub rcx, rcx            ; set rcx to 0
  mov rcx, -1             ; negative one to rcx
  sub al, al
  cld                     ; clear direction flags - 
                          ; Clearing the DF flag causes the string instructions to auto-increment
                          ; (process strings from low addresses to high addresses).
  repne scasb             ; scans through a strings and compares the characters of string to
                          ; whatever is in 'al' scasb. Look at string char by char and compare to al and reach zero
                          ; repeat if not equal will exit the loop
                          ; The SCAS instruction subtracts the destination string element from the contents of the EAX, AX, or AL register
                          ; (depending on operand length) and updates the status flags according to the results. The string element and
                          ; register contents are not modified. The following “short forms” of the SCAS instruction specify the operand length:
                          ; SCASB (scan byte string), SCASW (scan word string), and SCASD (scan doubleword string).
                          ; When used in string instructions, the ESI and EDI registers
                          ; are automatically incremented or decremented after each iteration of an instruction to point to the next element (byte,
                          ; word, or doubleword) in the string. String operations can thus begin at higher addresses and work toward lower ones,
                          ; or they can begin at lower addresses and  work toward higher ones. The DF flag in the EFLAGS register controls
                          ; whether the registers are incremented (DF = 0) or decremented (DF = 1). The STD and CLD instructions set and
                          ; clear this flag, respectively.
  neg rcx                 ; negate rcx so it will be a positive number
  sub rcx,1               ; our string ends with a zero so we need to sub one
  mov rax,rcx             ; we now have the string length and we should return the value of the
                          ; string length now in rcx into rax register. Returning functions to
                          ; rax is best practice.
  pop rcx                 ; restore the registers to initial state
  pop rdi                 ; restore original rdi value
  ret                     ; return the function

.print:
  call .strlen            ; will have string length in rax 
  mov rdx, rax            ; so this will be copied to rdx
  mov rsi, rdi            ; and also copy the rdi into rsi
  mov rdi, 1              ; stdout - argument
  mov rax, 1              ; syswrite - kernel function
  syscall                 ; call linux os kernel
  ret                     ; return to next instruction - xor rdi, rdi

segment readable writable  ; this is where we put our data

  msg db 'Hello World!', 0xA, 0            ; we call it message and declare bytes and say
                                           ; 'Hello World'. 10 for newline character and end with 0
                                           ; H e l l o\  W o r l d ! 0xA 0 - 14
