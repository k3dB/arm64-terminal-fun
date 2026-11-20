# Is Prime Utility (`isprime`)

A command-line utility written in ARM64 assembly (AArch64) for macOS that determines whether a given number is prime.

---

## Overview

The program implements a prime number check directly in assembly:
1. A number is prime if it is greater than 1 and has no divisors other than 1 and itself.
2. The program checks divisibility up to the square root of the number for efficiency.

### Key Features
- **Input Validation**: Accepts numbers in the 64-bit unsigned integer range (`0` to `18446744073709551615`).
- **Input Sanitization**: Rejects non-digit characters, overflow, or empty/extra arguments.
- **Leading Zero Handling**: Gracefully parses numbers with leading zeros (e.g., `00137`) and strips them in output formatting (`137 is a prime number.`).
- **Pure Darwin Assembly**: Direct macOS system calls (`write`, `exit`) via `svc #0x80`.

---

## Building and Running

### Build
Run `make` from the `isprime` directory to assemble and link the executable:
```bash
make
```
The compiled binary will be placed at `bin/isprime`.

### Clean
To remove object files and binaries:
```bash
make clean
```

### Running Tests
Execute the automated test suite covering valid numbers, edge cases, and invalid inputs:
```bash
make test
```
Or directly:
```bash
./test/run_tests.sh
```

### Test Timing
`make test` prints elapsed (`real`), CPU (`user`), and system (`sys`) time after
the suite completes. The measurement includes the clean build performed by the
test runner.

Reference run on an Apple M3 Pro (arm64, macOS 27.2): all 39 tests passed in
1.12 seconds elapsed (0.85 seconds user, 0.15 seconds system). Timings vary by
machine and system load.

---

## Usage

```bash
bin/isprime <number>
```

### Parameters
- `<number>`: An integer between `0` and `18446744073709551615`.

### Exit Codes
- `0`: Success (argument parsed and result determined).
- `1`: Error (invalid arguments, invalid number format, or out-of-bounds number).

---

## Examples

### Prime Numbers
```bash
$ bin/isprime 2
2 is a prime number.

$ bin/isprime 137
137 is a prime number.

$ bin/isprime 0007
7 is a prime number.
```

### Not Prime
```bash
$ bin/isprime 4
4 is not a prime number.

$ bin/isprime 27
27 is not a prime number.

$ bin/isprime 169
169 is not a prime number.
```

### Invalid Input / Usage
```bash
$ bin/isprime
Usage: isprime <number>
    <number> must be between 0 and 18446744073709551615 (64-bit unsigned integer)

$ bin/isprime ""
Usage: isprime <number>
    <number> must be between 0 and 18446744073709551615 (64-bit unsigned integer)

$ bin/isprime abc
Usage: isprime <number>
    <number> must be between 0 and 18446744073709551615 (64-bit unsigned integer)

$ bin/isprime 123abc
Usage: isprime <number>
    <number> must be between 0 and 18446744073709551615 (64-bit unsigned integer)

$ bin/isprime -4
Usage: isprime <number>
    <number> must be between 0 and 18446744073709551615 (64-bit unsigned integer)

$ bin/isprime 3.14
Usage: isprime <number>
    <number> must be between 0 and 18446744073709551615 (64-bit unsigned integer)
```

---

## Project Structure

- `src/isprime.s`: Complete assembly source including entry point (`_main`), ASCII parsing, prime number arithmetic, string output routines, and usage/exit handling.
- `Makefile`: Build rules using `as` and `ld` targeting macOS ARM64.
- `test/run_tests.sh`: Bash test harness executing test cases in `valid_input_tests.sh` and `invalid_input_tests.sh`.
