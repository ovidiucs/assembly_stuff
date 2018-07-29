format ELF64 executable 3
; -r5 - move each value to the datasection not suppose to be in stack 
; -r4 
; 0xD3C21BCECCEDA0FFFFFF   
; 0x00000000000f423f                            9 999 99     +8 bytes
; 0x8ac7230489e7fff6    9 999 999 999 999 999 990            STACK
; input:                9 999 999 999 999 999 999 999 99
; -r3 - xor r10, xor rbx - removed on stoerit - they will be overwritten - no needf for theese.
; -r2 - add store it to store a larger than 8 byte - 64 bit value from register onto stack
;       the imul and add are found from the net
; -r1 - remove strlen - string can be arbitrary, max value is 1024
; v.08 factoriadic; change mov rdi 04 to rdi strlen
; v.07 - read from stdin
; v.06 use syscalls names from kernel instead of numerics
; v.05 include files - move functions to separate file
; v.04 bug in main  after strlen it called print which called strlen again. core dump
; v.03 create a function to also print the string
; v.02 create function outside of main and 
; calculate the length of the string


segment readable executable

entry main

include 'unistd64.inc'
include 'io.inc'          ; the name of the file to be included

main:
  lea rdi, [prompt]       ; load effective address of prompt 
  call print              ; print to screen the prompt call 0x4000ce
  
  lea rsi, [buf]          ; load effective address  of buffer 
  mov rdi, 1024           ; 1024 number copy to rdi
  call read               ; read
  call convert            ; call 0x400136
  
  mov rdi, rsi            ; copy string we read to rdi
  call print              ; output to standard out

  xor rdi, rdi            ; exit code of 0 exclusive or / zeroing out the register
  mov rax, sys_exit       ; use sys.exit
  syscall                 ; call OS 

  
; accept string and convert each digit to base 10
; takes as a parameter rsi which points to string
; mov rdi, rsi            ; copy string we read to rdi

convert:
; lea r8, [digitcnt]
; lea r8, [numberbuf]
  xor rdx,rdx
  xor rcx, rcx
  xor rbx,rbx  ; clear r8
  lea rdx,[numberbuf]
  call loopString
  ret

loopString:               ; 0x40013F
  lodsb            ; load byte string - a character is a byte - in ascii 
                    ; and we entered ascii text into stdin
                    ; loadsb will load the source element - the number - identified by the
                    ; ESI/RSI register into the EAX/RAX register - for doubleword, AX for word,
                    ; AL for byte string (lodsb,lodsw,lodsd)
                    ; in this case we want just a single byte at a time to load into RAX
                    ; movzx rax, byte[rsi]
  cmp al, 0xa       ; compare to newlinecode
;  je storeit        ; in case this compare is equal jumpt to condition addcr
  or al, al         ; is the string that we read null terminated ? -has al reached the 0 marker
                    ; for null terminated strings?
  jz addctr         ; je 0x40014f jump to addctr address
  and al, 0xf       ; keep binary value of numerical digit                     
;  imul rbx,10         ; jc storeit
;  add rbx,rax       ; store
  mov [rdx],rax
  inc rdx
  inc rcx
;  xor rbx,rbx
 ; add [dbx], r8b
;  inc rbx
;  mov rax, rbx
;  xor ax, ax       ; zero out the lower bytes (rightmost byte)
;  inc rdi
;  inc rcx
  jmp loopString    ; return to beginning and do the same taks

  
; from: https://stackoverflow.com/questions/7863094/how-can-i-convert-hex-to-decimal
; "123 % 10 gives us 3 and 123 / 10 = 12 conveniently gives us the correct number 
;  to work with in the next iteration"
; DIV stores both the quotient and remainder ax/dx
; after digit to string we need to store the result
addctr:
  push rax              ; save modified regusters
  push rbx              ; 
  push rdx              ; 
  mov rax, rcx          ; copy the rcx - the counted digits into rax
  lea rsi, [buffered]     ; start at end
.convertChar:
  xor rdx, rdx          ; clear the rdx regiter - remainder 
  mov rbx, 0xa          ; put into rbx the number 10 - the base for our division 
  div rbx               ; divides rax by rbx. rax is overriden, stores quotient, reminder is in rdx
  add rdx, 0x30         ; ASCII Literal '0' add 0x30 
  cmp rdx, 0x39         ; is it a hex digit
  jbe .store            ; if not then store it
  add rdx, 'A'-'0'-10   ; 
.store:
  dec rsi
  mov [rsi], dl
  and rax, rax
  jnz .convertChar
  pop rdx
  pop rbx
  pop rax
  ret
  

storeit:                  ; store result onto stack when carry bit is on 
  mov rbp,rsp             ; wanna save that stack pointer so we don't get lost
  sub rsp,64              ; and move down the stack 64 bytes (8*rbx)
  stc                     ; this will clear the carry flagg and cmovc will not run - turn it on
  cmovc r10,rbx           ; cmovc will run if carry flag is set and copy the rbx to r10 -
                          ;  should be another gp register ? 
  push r10                ; then push to stack that is now 8 bytes down 
  mov rsp,rbp             ; point the stack pointer back from the base pointer to resume with
                          ; add rbx,rax
  mov rbx,rax             ; copy the rax register - this was holding a value that is neded rax
                          ; will not clear but will be cleared by next lodsb instruction
  call loopString         ; call the function - loopString - going back to lodsb

segment readable writable  ; this is where we put our data
  prompt db 'Please input number to list its factoriadic values (1024 digits max): ' ,0
  buf rb 1024
  digitcnt db 16 dup(0)
  numberbuf dq 1024 dup(?)
  
buffered:
  db 0
