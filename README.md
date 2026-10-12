# ARM64 Terminal Fun

A collection of lightweight command-line utilities written in ARM64 assembly (AArch64) targeting macOS on Apple Silicon. These projects demonstrate low-level systems programming concepts including manual string parsing, integer arithmetic, Darwin system calls, and automated test harnesses written in Bash.

---

## Projects Overview

| Project | Description | Key Features |
| :--- | :--- | :--- |
| **[`leapyear`](leapyear/)** | Gregorian calendar leap year evaluator | Command-line argument parsing, 16-bit range validation (`1..65535`), leap year algorithmic checks, leading-zero normalization. |
| **[`tempconv`](tempconv/)** | Multi-unit temperature conversion tool | Conversions across Celsius, Fahrenheit, and Kelvin; flexible CLI argument ordering; absolute zero validation; half-up / away-from-zero rounding. |

---

## Prerequisites

- **Hardware**: Apple Silicon Mac (M1/M2/M3/M4 or compatible ARM64 processor).
- **Operating System**: macOS.
- **Toolchain**: Xcode Command Line Tools providing:
  - Assembler (`as`)
  - Linker (`ld`)
  - `xcrun` (to locate macOS SDK paths for `libSystem`)
  - GNU Make (`make`)
  - Bash (`bash`)

To install the Command Line Tools if not already available:
```bash
xcode-select --install
```

---

## Building and Testing

Each project contains its own `Makefile` and test suite. You can build and test each utility directly from its directory:

### Leap Year Utility
```bash
cd leapyear
make        # Compiles to bin/leapyear
make clean  # Cleans build artifacts
make test   # Cleans, builds, and runs automated test suite
```

### Temperature Converter Utility
```bash
cd tempconv
make        # Compiles to bin/tempconv
make clean  # Cleans build artifacts
make test   # Cleans, builds, and runs automated test suite
```

---

## Repository Structure

```text
arm64-terminal-fun/
├── README.md               # Repository documentation
├── leapyear/               # Leap year calculation utility
│   ├── Makefile            # Build configuration
│   ├── README.md           # Leap year documentation
│   ├── src/
│   │   └── leapyear.s      # Leap year assembly source code
│   └── test/               # Test runner and validation scripts
└── tempconv/               # Temperature conversion utility
    ├── Makefile            # Build configuration
    ├── README.md           # Temperature conversion documentation
    ├── src/
    │   ├── convert.s       # Conversion formulas and validation
    │   ├── macros.inc      # Shared assembly macros
    │   ├── main.s          # Entry point and argument orchestration
    │   ├── output.s        # Buffer formatting and syscall output
    │   └── parse.s         # String and flag parsing
    └── test/               # Test runner and validation suites
```
