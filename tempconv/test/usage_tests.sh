EXPECTED="Usage: tempconv <temperature> <conversion-flag>

   --c-to-f    Convert Celsius to Fahrenheit
   --f-to-c    Convert Fahrenheit to Celsius
   --k-to-c    Convert Kelvin to Celsius
   --c-to-k    Convert Celsius to Kelvin
   --k-to-f    Convert Kelvin to Fahrenheit
   --f-to-k    Convert Fahrenheit to Kelvin

   Maximum temperature: 1,000,000,000
   Use only digits and optional negative sign. No commas or other symbols."

# Correct usage
assert_cli 0 "32 F -> 0 C" "$TEMPCONV" 32 --f-to-c

# No arguemnts
assert_cli 1 "$EXPECTED" "$TEMPCONV"

# Only temperature argument
assert_cli 1 "$EXPECTED" "$TEMPCONV" 32

# Only conversion flag (or empty temperature)
assert_cli 1 "$EXPECTED" "$TEMPCONV" --f-to-c
assert_cli 1 "$EXPECTED" "$TEMPCONV" "" --f-to-c
assert_cli 1 "$EXPECTED" "$TEMPCONV" - --f-to-c

# Invalid conversion flag
assert_cli 1 "$EXPECTED" "$TEMPCONV" 32 --f-to-celsius
assert_cli 1 "$EXPECTED" "$TEMPCONV" 32 --f-to-b
assert_cli 1 "$EXPECTED" "$TEMPCONV" 32 --b-to-c

# Invalid temperature
assert_cli 1 "$EXPECTED" "$TEMPCONV" a --f-to-c
assert_cli 1 "$EXPECTED" "$TEMPCONV" 32b --f-to-c
assert_cli 1 "$EXPECTED" "$TEMPCONV" 32.5 --f-to-c

# Too many arguments
assert_cli 1 "$EXPECTED" "$TEMPCONV" 32 --f-to-c bob
assert_cli 1 "$EXPECTED" "$TEMPCONV" 212 32 --f-to-c
assert_cli 1 "$EXPECTED" "$TEMPCONV" --f-to-c 32 212 bob alice

# Invalid temperatures (above maximum limit)
assert_cli 1 "$EXPECTED" "$TEMPCONV" 1000000001 --k-to-c
assert_cli 1 "$EXPECTED" "$TEMPCONV" 2000000000 --k-to-f
assert_cli 1 "$EXPECTED" "$TEMPCONV" -1000000001 --c-to-k
assert_cli 1 "$EXPECTED" "$TEMPCONV" 18446744073709551616 --k-to-c
assert_cli 1 "$EXPECTED" "$TEMPCONV" 00000000000 --c-to-k
assert_output "1000000000 C -> 1000000273 K" "$TEMPCONV" 1000000000 --c-to-k
