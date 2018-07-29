strlen:
  push rdi                ; push registers to stack
  push rcx                ; saving these values
                          ; after function return leave as intiial state
  sub rcx, rcx            ; set rcx to 0
  mov rcx, -1             ; negative one to rcx
  sub al, al              ; subtract al register - lower octet from rax 
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
  ret                     ; return the function result to rax

print:
  call strlen             ; will have string length in rax 
  mov rdx, rax            ; so this will be copied to rdx
  mov rsi, rdi            ; and also copy the rdi into rsi
  mov rdi, 1              ; stdout - argument
  mov rax, sys_write      ; syswrite - kernel function
  syscall                 ; call linux os kernel
  ret                     ; return to next instruction - xor rdi, rdi


read:
  mov rdx, rdi            ; buffer to read to 
  mov rdi, 0              ; stdin - argument 
  mov rax, sys_read       ; sys_read
  syscall                 ; call to linux kernel 
  ret                     ; return 

