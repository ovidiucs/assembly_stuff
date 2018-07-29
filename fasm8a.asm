format ELF64 executable 3
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
  xor rbx,rbx   ; clear r8
  call loopString
  ret

loopString:
  lodsb            ; load byte string - a character is a byte - in ascii 
                    ; and we entered ascii text into stdin
                    ; loadsb will load the source element - the number - identified by the
                    ; ESI/RSI register into the EAX/RAX register - for doubleword, AX for word,
                    ; AL for byte string (lodsb,lodsw,lodsd)
                    ; in this case we want just a single byte at a time to load into RAX
  ; movzx rax, byte[rsi]
  cmp al, 0xa       ; compare to newlinecode
  je addctr
;  je loopString     ;                                                                           
;  or al, al        ; is the string that we read null terminated ? -has al reached the 0 marker
                    ; for null terminated strings?
;  jz addctr         ; je 0x40014f jump to addctr address
;  and al, 0xf       ; keep binary value of numerical digit
  and al, 0xf
  imul rbx,10
  add rbx,rax       ; store
 ; add [rbx], r8b
;  inc rbx
;  mov rax, rbx
  xor ax, ax       ; zero out the lower bytes (rightmost byte)
;  inc rdi
;  inc rcx
  jmp loopString    ; return to beginning and do the same taks

  

addctr:
  mov [digitcnt], rcx  ;add to counter how many digits
  ret

segment readable writable  ; this is where we put our data
  prompt db 'Please input number to list its factoriadic values (1024 digits max): ' ,0
  buf rb 1024
  digitcnt dq ?
  numberbuf db 1024 dup(?)
