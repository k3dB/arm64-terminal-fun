CURRENT_TEST_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" &>/dev/null && pwd)"
COMMAND="$CURRENT_TEST_DIR/../bin/tempconv"

source "$CURRENT_TEST_DIR/assertion_helpers.sh"

# Exact / anchor points
assert_output "0 C -> 32 F" $COMMAND 0 --c-to-f       # 0 C -> 32 F
assert_output "100 C -> 212 F" $COMMAND 100 --c-to-f     # 100 C -> 212 F
assert_output "32 F -> 0 C" $COMMAND 32 --f-to-c      # 32 F -> 0 C
assert_output "212 F -> 100 C" $COMMAND 212 --f-to-c     # 212 F -> 100 C
assert_output "-40 C -> -40 F" $COMMAND -40 --c-to-f     # -40 C -> -40 F
assert_output "-40 F -> -40 C" $COMMAND -40 --f-to-c     # -40 F -> -40 C

# Celsius ↔ Kelvin anchors
assert_output "0 C -> 273 K" $COMMAND 0 --c-to-k       # 0 C -> 273 K
assert_output "100 C -> 373 K" $COMMAND 100 --c-to-k     # 100 C -> 373 K
assert_output "-273 C -> 0 K" $COMMAND -273 --c-to-k    # -273 C -> 0 K

assert_output "0 K -> -273 C" $COMMAND 0 --k-to-c       # 0 K -> -273 C
assert_output "273 K -> 0 C" $COMMAND 273 --k-to-c     # 273 K -> 0 C
assert_output "274 K -> 1 C" $COMMAND 274 --k-to-c     # 274 K -> 1 C

# Fahrenheit ↔ Kelvin anchors
assert_output "32 F -> 273 K" $COMMAND 32 --f-to-k      # 32 F -> 273 K
assert_output "212 F -> 373 K" $COMMAND 212 --f-to-k     # 212 F -> 373 K
assert_output "-40 F -> 233 K" $COMMAND -40 --f-to-k     # -40 F -> 233 K

assert_output "273 K -> 32 F" $COMMAND 273 --k-to-f     # 273 K -> 32 F
assert_output "373 K -> 212 F" $COMMAND 373 --k-to-f     # 373 K -> 212 F
assert_output "233 K -> -40 F" $COMMAND 233 --k-to-f     # 233 K -> -40 F
