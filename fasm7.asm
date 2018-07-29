format ELF64 executable 3
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
  lea rdi, [prompt]
  call print
  lea rsi, [buf]
  mov rdi, 64
  call read
  mov rdi, rsi            ; copy string we read to rdi
  call print
  xor rdi, rdi            ; exit code of 0 exclusive or / zeroing out the register
  mov rax, sys_exit             ; use sys.exit
  syscall                 ; call OS 

segment readable writable  ; this is where we put our data
  prompt db 'Please type your name: ',0
  buf rb 64
