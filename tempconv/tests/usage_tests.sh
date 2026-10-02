CURRENT_TEST_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" &>/dev/null && pwd)"

EXPECTED="Usage: tempconv <temperature> <conversion-flag>

   --c-to-f    Convert Celsius to Fahrenheit
   --f-to-c    Convert Fahrenheit to Celsius
   --k-to-c    Convert Kelvin to Celsius
   --c-to-k    Convert Celsius to Kelvin
   --k-to-f    Convert Kelvin to Fahrenheit
   --f-to-k    Convert Fahrenheit to Kelvin"

source "$CURRENT_TEST_DIR/assertion_helpers.sh"

# Correct usage
assert_cli 0 "32 F -> 0 C" $TEMPCONV 32 --f-to-c

# No arguemnts
assert_cli 1 "$EXPECTED" $TEMPCONV

# Only temperature argument
assert_cli 1 "$EXPECTED" $TEMPCONV 32

# Only conversion flag
assert_cli 1 "$EXPECTED" $TEMPCONV --f-to-c

# Invalid conversion flag
assert_cli 1 "$EXPECTED" $TEMPCONV 32 --f-to-celsius
assert_cli 1 "$EXPECTED" $TEMPCONV 32 --f-to-b
assert_cli 1 "$EXPECTED" $TEMPCONV 32 --b-to-c

# Invalid temperature
assert_cli 1 "$EXPECTED" $TEMPCONV a --f-to-c
assert_cli 1 "$EXPECTED" $TEMPCONV 32b --f-to-c
assert_cli 1 "$EXPECTED" $TEMPCONV 32.5 --f-to-c

# Too many arguments
assert_cli 1 "$EXPECTED" $TEMPCONV 32 --f-to-c bob
assert_cli 1 "$EXPECTED" $TEMPCONV 212 32 --f-to-c
assert_cli 1 "$EXPECTED" $TEMPCONV --f-to-c 32 212 bob alice
