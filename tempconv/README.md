# Temperature Converter (`tempconv`)

A modular command-line utility written in ARM64 assembly (AArch64) for macOS that performs integer temperature conversions between Celsius, Fahrenheit, and Kelvin.

---

## Overview

`tempconv` provides accurate integer temperature conversions while enforcing physical boundaries (absolute zero) and standardized rounding (round half away from zero).

### Key Features
- **Supported Units**: Celsius (`C`), Fahrenheit (`F`), and Kelvin (`K`).
- **Flexible Argument Order**: Allows `<temperature> <flag>` or `<flag> <temperature>`.
- **Physical Validation**: Enforces absolute zero constraints (rejects values below `-273°C`, `-459°F`, or `0 K`).
- **Arithmetic Precision & Rounding**: Implements integer arithmetic with round-away-from-zero logic (e.g. `0.5 -> 1`, `-0.5 -> -1`). Direct formulas are used between Kelvin and Fahrenheit to prevent intermediate rounding error through Celsius.
- **Magnitude Validation**: Supports up to 10 decimal digits with a maximum input magnitude of `1,000,000,000`.

---

## Conversion Flags

| Flag | Conversion | Formula / Logic |
| :--- | :--- | :--- |
| `--c-to-f` | Celsius to Fahrenheit | $F = \text{round}\left(\frac{C \times 9}{5}\right) + 32$ |
| `--f-to-c` | Fahrenheit to Celsius | $C = \text{round}\left(\frac{(F - 32) \times 5}{9}\right)$ |
| `--k-to-c` | Kelvin to Celsius | $C = K - 273$ |
| `--c-to-k` | Celsius to Kelvin | $K = C + 273$ |
| `--k-to-f` | Kelvin to Fahrenheit | $F = \text{round}\left(\frac{K \times 180 - 45967}{100}\right)$ |
| `--f-to-k` | Fahrenheit to Kelvin | $K = \text{round}\left(\frac{F \times 100 + 45967}{180}\right)$ |

---

## Building and Running

### Build
From the `tempconv` directory, assemble and link all modular object files:
```bash
make
```
The compiled binary will be placed at `bin/tempconv`.

### Clean
To remove build objects and binary artifacts:
```bash
make clean
```

### Running Tests
Execute the comprehensive test suites (base conversions, rounding, invalid temperatures, and usage):
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
bin/tempconv <temperature> <flag>
# or
bin/tempconv <flag> <temperature>
```

### Parameters
- `<temperature>`: Integer value with optional leading negative sign (e.g. `100`, `-40`, `0`). Maximum magnitude: `1,000,000,000`.
- `<flag>`: One of `--c-to-f`, `--f-to-c`, `--k-to-c`, `--c-to-k`, `--k-to-f`, or `--f-to-k`.

### Exit Codes
- `0`: Success (conversion performed and printed).
- `1`: Error (invalid flag, non-numeric input, out-of-range magnitude, or temperature below absolute zero).

---

## Examples

### Standard Conversions
```bash
$ bin/tempconv 100 --c-to-f
100 C -> 212 F

$ bin/tempconv --f-to-c 32
32 F -> 0 C

$ bin/tempconv 0 --c-to-k
0 C -> 273 K

$ bin/tempconv 300 --k-to-c
300 K -> 27 C

$ bin/tempconv 100 --k-to-f
100 K -> -280 F

$ bin/tempconv 72 --f-to-k
72 F -> 295 K
```

### Negative Values & Boundary Checks
```bash
$ bin/tempconv -40 --c-to-f
-40 C -> -40 F

$ bin/tempconv -273 --c-to-k
-273 C -> 0 K
```

### Absolute Zero Violations
```bash
$ bin/tempconv -300 --c-to-f
Temperature below absolute zero.

$ bin/tempconv -500 --f-to-c
Temperature below absolute zero.

$ bin/tempconv -1 --k-to-c
Temperature below absolute zero.
```

### Usage / Invalid Arguments
```bash
$ bin/tempconv
Usage: tempconv <temperature> <conversion-flag>

   --c-to-f    Convert Celsius to Fahrenheit
   --f-to-c    Convert Fahrenheit to Celsius
   --k-to-c    Convert Kelvin to Celsius
   --c-to-k    Convert Celsius to Kelvin
   --k-to-f    Convert Kelvin to Fahrenheit
   --f-to-k    Convert Fahrenheit to Kelvin

   Maximum temperature: 1,000,000,000
   Use only digits and optional negative sign. No commas or other symbols.
```

---

## Architecture & Code Structure

The assembly source is organized modularly across distinct compilation units:

- **`src/main.s`**: Entry point (`_main`), argument inspection and position swapping, execution flow orchestration, error reporting, and exit handling.
- **`src/parse.s`**: String-to-integer conversion (`parse_temperature`) with sign/magnitude enforcement, and lookup table matching for conversion flags (`find_flag`).
- **`src/convert.s`**: Temperature conversion formulas and absolute zero bounds enforcement (`convert`).
- **`src/output.s`**: Output buffer assembly (`write_prefix`), integer-to-ASCII formatting (`format_int`), and Darwin system call output (`write_stdout`).
- **`src/macros.inc`**: Common macro definitions, including `round_away_from_zero` and `write_const`.
