# Leap Year Utility (`leapyear`)

A command-line utility written in ARM64 assembly (AArch64) for macOS that determines whether a given year is a leap year under the Gregorian calendar.

---

## Overview

The program implements Gregorian calendar leap year calculation rules directly in assembly:
1. A year is a leap year if it is divisible by `4`.
2. Exception: If the year is divisible by `100`, it is **not** a leap year unless it is also divisible by `400`.

### Key Features
- **Input Validation**: Accepts years in the 16-bit unsigned integer range (`1` to `65535`).
- **Input Sanitization**: Rejects non-numeric characters, negative numbers, zero, numbers exceeding 65535, or empty/extra arguments.
- **Leading Zero Handling**: Gracefully parses numbers with leading zeros (e.g., `002024`) and strips them in output formatting (`2024 is a leap year.`).
- **Pure Darwin Assembly**: Direct macOS system calls (`write`, `exit`) via `svc #0x80`.

---

## Building and Running

### Build
Run `make` from the `leapyear` directory to assemble and link the executable:
```bash
make
```
The compiled binary will be placed at `bin/leapyear`.

### Clean
To remove object files and binaries:
```bash
make clean
```

### Running Tests
Execute the automated test suite covering valid years, edge cases, and invalid inputs:
```bash
make test
```
Or directly:
```bash
./test/run_tests.sh
```

---

## Usage

```bash
bin/leapyear <year>
```

### Parameters
- `<year>`: An integer between `1` and `65535`.

### Exit Codes
- `0`: Success (argument parsed and result determined).
- `1`: Error (invalid arguments, invalid number format, or out-of-bounds year).

---

## Examples

### Leap Years
```bash
$ bin/leapyear 2024
2024 is a leap year.

$ bin/leapyear 2000
2000 is a leap year.

$ bin/leapyear 0004
4 is a leap year.
```

### Common Years (Not a Leap Year)
```bash
$ bin/leapyear 2023
2023 is not a leap year.

$ bin/leapyear 1900
1900 is not a leap year.
```

### Invalid Input / Usage
```bash
$ bin/leapyear
Usage: leapyear <year>
    <year> must be between 1 and 65535 (16-bit unsigned integer)

$ bin/leapyear 70000
Usage: leapyear <year>
    <year> must be between 1 and 65535 (16-bit unsigned integer)

$ bin/leapyear abc
Usage: leapyear <year>
    <year> must be between 1 and 65535 (16-bit unsigned integer)
```

---

## Project Structure

- `src/leapyear.s`: Complete assembly source including entry point (`_main`), ASCII parsing, leap year arithmetic, string output routines, and usage/exit handling.
- `Makefile`: Build rules using `as` and `ld` targeting macOS ARM64.
- `test/run_tests.sh`: Bash test harness executing test cases in `valid_input_tests.sh` and `invalid_input_tests.sh`.
