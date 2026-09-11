# Playbook: Binary Analysis

## Prerequisites

### Tools Required
| Tool | Purpose |
|------|---------|
| Ghidra / IDA | Disassembly and decompilation |
| GDB / pwndbg / gef | Dynamic analysis |
| pwntools | Exploit development |
| checksec | Binary protections check |
| ROPgadget / ropper | ROP chain building |
| strace / ltrace | System/library call tracing |
| radare2 / rizin | CLI reversing |
| angr | Symbolic execution |
| AFL++ / libFuzzer | Fuzzing |

## Phase 1: Initial Analysis

### Binary Info Worker
```
Objective: Gather basic info about [binary]
Steps:
1. file [binary] — type, arch, linking
2. checksec [binary] — NX, PIE, canary, RELRO
3. strings [binary] | grep -i password/key/secret/flag/admin
4. ldd [binary] — shared libraries
5. readelf -h / readelf -S [binary] — headers, sections
6. Identify binary type: ELF, PE, Mach-O, firmware
Output: Binary profile with protections and initial observations
```

### Protection Matrix
| Protection | Status | Impact on Exploitation |
|------------|--------|----------------------|
| NX/DEP | ? | Can't execute shellcode on stack |
| Stack Canary | ? | Need info leak or format string to bypass |
| PIE/ASLR | ? | Need info leak for addresses |
| Full RELRO | ? | GOT overwrite not possible |
| Fortify | ? | Checks on dangerous functions |

## Phase 2: Static Analysis

### Decompilation Workers

#### Function Discovery Worker
```
Objective: Map all functions and identify interesting ones
Steps:
1. Load binary in Ghidra/IDA
2. Auto-analyze
3. List all functions, sorted by size
4. Flag functions containing:
   - String operations (strcpy, sprintf, strcat)
   - Memory operations (malloc, free, memcpy)
   - System calls (system, execve, popen)
   - File operations (open, read, write, fopen)
   - Network operations (socket, connect, send, recv)
   - User input (scanf, gets, fgets, read from stdin/socket)
5. Map call graph for flagged functions
Output: List of interesting functions with decompiled code
```

#### Vulnerability Pattern Worker
```
Objective: Find [vuln type] patterns in decompiled code
Types:
- Buffer overflow: fixed-size buffers with unbounded input
- Format string: printf-family with user-controlled format
- Integer overflow: arithmetic without bounds checking
- Use-after-free: free() with continued pointer use
- Double free: multiple free() paths to same allocation
- Heap overflow: heap allocations with unbounded writes
- Race condition: shared resources without proper locking
- Command injection: system/exec with controllable arguments
Steps:
1. Search for pattern-specific function calls
2. Trace back to find user input sources
3. Check if any sanitization/bounds checking exists
4. Document the vulnerable path
Output: Confirmed patterns with function addresses and data flow
```

## Phase 3: Dynamic Analysis

### Debugging Workers

#### Input Fuzzing Worker
```
Objective: Fuzz [input vector] of [binary]
Steps:
1. Identify input format (CLI args, stdin, file, network)
2. Create initial corpus from valid inputs
3. Run AFL++/libFuzzer with appropriate harness
4. Monitor for crashes (ASAN recommended)
5. Triage crashes — unique bugs, reproducibility
6. Minimize crashing inputs
Output: Crash reports with minimized inputs and stack traces
```

#### Runtime Tracing Worker
```
Objective: Trace execution for [specific scenario]
Steps:
1. Run with strace/ltrace to see system/library calls
2. Set breakpoints at interesting functions (from static analysis)
3. Observe memory layout, stack frames, heap state
4. Track user input through execution
5. Identify exploitable states
Output: Execution trace with annotated observations
```

## Phase 4: Exploitation

### Exploit Development

#### Stack Buffer Overflow
```
1. Find overflow — input that overwrites return address
2. Calculate offset — pattern_create + pattern_offset
3. Check protections:
   - No NX → shellcode on stack
   - NX → ROP chain
   - Canary → leak canary first (format string, info leak)
   - PIE → leak base address first
4. Build exploit
5. Test locally
6. Adapt for remote (if applicable)
```

#### Heap Exploitation
```
1. Identify heap primitive — overflow, UAF, double free
2. Determine allocator (ptmalloc2, jemalloc, tcmalloc, etc.)
3. Choose technique based on glibc version:
   - 2.26+: tcache attacks
   - 2.29+: tcache key checks
   - 2.32+: safe-linking
4. Build exploit chain:
   - Heap feng shui → control allocations
   - Overlap/corruption → write primitive
   - Write-what-where → code execution
5. Achieve arbitrary write → overwrite __free_hook/GOT/vtable
```

#### Format String
```
1. Confirm format string — %x.%x.%x.%x or %p.%p.%p.%p
2. Find offset — %N$x to find input on stack
3. Use for:
   - Info leak: %s to read arbitrary strings
   - Arbitrary write: %n to write to addresses
   - Canary leak: find canary position on stack
   - PIE bypass: leak return address
4. Chain with other bugs for full exploit
```

## Phase 5: Firmware / Embedded

### Firmware Analysis Workers
```
Objective: Extract and analyze firmware from [device/file]
Steps:
1. binwalk -e [firmware] — extract file systems
2. Find web interfaces, config files, credentials
3. Identify busybox/shell versions
4. Check for hardcoded keys/certs
5. Analyze custom binaries with Ghidra
6. Check for debug interfaces (UART, JTAG, SSH)
Output: Extracted contents, found credentials, vulnerable binaries
```

## Severity Guidelines

| Vulnerability | Typical Severity |
|--------------|-----------------|
| Remote Code Execution | CRITICAL |
| Arbitrary Read/Write | CRITICAL |
| Auth bypass | CRITICAL |
| Local privilege escalation | HIGH |
| Denial of Service (crash) | MEDIUM |
| Information disclosure | MEDIUM |
| Hardcoded credentials | HIGH-CRITICAL |
| Memory corruption (no exploit) | MEDIUM-HIGH |
