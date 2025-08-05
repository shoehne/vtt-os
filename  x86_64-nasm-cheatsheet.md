
# 🧠 x86_64 NASM Assembly Cheatsheet

## 📌 General Purpose Registers

| Size     | Registers                          |
|----------|------------------------------------|
| 64-bit   | rax, rbx, rcx, rdx, rsi, rdi, rsp, rbp, r8–r15 |
| 32-bit   | eax, ebx, ecx, edx, esi, edi, esp, ebp, r8d–r15d |
| 16-bit   | ax, bx, cx, dx, si, di, sp, bp, r8w–r15w |
| 8-bit    | al, bl, cl, dl, sil, dil, spl, bpl, r8b–r15b |

---

## 📌 Data Definition & Reservation

| Directive | Description                         |
|-----------|-------------------------------------|
| `db`      | Define byte                         |
| `dw`      | Define word (2 bytes)               |
| `dd`      | Define double word (4 bytes)        |
| `dq`      | Define quad word (8 bytes)          |
| `resb N`  | Reserve N bytes                     |
| `resw N`  | Reserve N words (2 bytes each)      |
| `resd N`  | Reserve N double words (4 bytes each) |
| `resq N`  | Reserve N quad words (8 bytes each) |

---

## 📌 Common Instructions

| Category       | Instructions                             |
|----------------|------------------------------------------|
| Data Movement  | `mov`, `lea`, `xchg`                     |
| Arithmetic     | `add`, `sub`, `mul`, `div`, `inc`, `dec` |
| Logic          | `and`, `or`, `xor`, `not`, `test`        |
| Control Flow   | `jmp`, `je`, `jne`, `call`, `ret`        |
| Stack          | `push`, `pop`                            |
| Comparison     | `cmp`                                    |
| Shift/Rotate   | `shl`, `shr`, `rol`, `ror`               |

---

## 📌 Linux x86_64 Syscall Convention

```asm
mov rax, syscall_number   ; syscall number
mov rdi, arg1             ; first argument
mov rsi, arg2             ; second argument
mov rdx, arg3             ; third argument
mov r10, arg4             ; fourth argument
mov r8,  arg5             ; fifth argument
mov r9,  arg6             ; sixth argument
syscall                   ; invoke syscall
