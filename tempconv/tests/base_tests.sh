CURRENT_TEST_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" &>/dev/null && pwd)"
TEMPCONV="$CURRENT_TEST_DIR/../bin/tempconv"

# Argument order agnostic (other tests will use temperature first)
assert_output "32 F -> 0 C"    "$TEMPCONV" --f-to-c 32      # 32 F -> 0 C
assert_output "100 C -> 212 F" "$TEMPCONV" --c-to-f 100     # 100 C -> 212 F
assert_output "32 F -> 0 C"    "$TEMPCONV" --f-to-c 32      # 32 F -> 0 C
assert_output "212 F -> 100 C" "$TEMPCONV" --f-to-c 212     # 212 F -> 100 C
assert_output "-40 C -> -40 F" "$TEMPCONV" --c-to-f -40     # -40 C -> -40 F
assert_output "-40 F -> -40 C" "$TEMPCONV" --f-to-c -40     # -40 F -> -40 C

# Exact / anchor points
assert_output "0 C -> 32 F"    "$TEMPCONV" 0 --c-to-f       # 0 C -> 32 F
assert_output "100 C -> 212 F" "$TEMPCONV" 100 --c-to-f     # 100 C -> 212 F
assert_output "32 F -> 0 C"    "$TEMPCONV" 32 --f-to-c      # 32 F -> 0 C
assert_output "212 F -> 100 C" "$TEMPCONV" 212 --f-to-c     # 212 F -> 100 C
assert_output "-40 C -> -40 F" "$TEMPCONV" -40 --c-to-f     # -40 C -> -40 F
assert_output "-40 F -> -40 C" "$TEMPCONV" -40 --f-to-c     # -40 F -> -40 C

# Celsius ↔ Kelvin anchors
assert_output "0 C -> 273 K"   "$TEMPCONV" 0 --c-to-k       # 0 C -> 273 K
assert_output "100 C -> 373 K" "$TEMPCONV" 100 --c-to-k     # 100 C -> 373 K
assert_output "-273 C -> 0 K"  "$TEMPCONV" -273 --c-to-k    # -273 C -> 0 K

assert_output "0 K -> -273 C"  "$TEMPCONV" 0 --k-to-c       # 0 K -> -273 C
assert_output "273 K -> 0 C"   "$TEMPCONV" 273 --k-to-c     # 273 K -> 0 C

# Fahrenheit ↔ Kelvin anchors
assert_output "32 F -> 273 K"  "$TEMPCONV" 32 --f-to-k      # 32 F -> 273 K
assert_output "212 F -> 373 K" "$TEMPCONV" 212 --f-to-k     # 212 F -> 373 K
assert_output "-40 F -> 233 K" "$TEMPCONV" -40 --f-to-k     # -40 F -> 233 K
assert_output "-459 F -> 0 K"  "$TEMPCONV" -459 --f-to-k    # absolute zero F -> K

assert_output "0 K -> -460 F"  "$TEMPCONV" 0 --k-to-f       # absolute zero K -> F
assert_output "273 K -> 32 F"  "$TEMPCONV" 273 --k-to-f     # 273 K -> 32 F
assert_output "373 K -> 212 F" "$TEMPCONV" 373 --k-to-f     # 373 K -> 212 F
assert_output "233 K -> -40 F" "$TEMPCONV" 233 --k-to-f     # 233 K -> -40 F
