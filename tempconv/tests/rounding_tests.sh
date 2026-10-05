CURRENT_TEST_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" &>/dev/null && pwd)"
TEMPCONV="$CURRENT_TEST_DIR/../bin/tempconv"

# Positive values that require rounding
assert_output "1 C -> 34 F" "$TEMPCONV" 1 --c-to-f    # 1 C -> 34 F   (33.8)
assert_output "2 C -> 36 F" "$TEMPCONV" 2 --c-to-f    # 2 C -> 36 F   (35.6)
assert_output "33 F -> 1 C" "$TEMPCONV" 33 --f-to-c   # 33 F -> 1 C   (~0.56)
assert_output "34 F -> 1 C" "$TEMPCONV" 34 --f-to-c   # 34 F -> 1 C   (~1.11)
assert_output "35 F -> 2 C" "$TEMPCONV" 35 --f-to-c   # 35 F -> 2 C   (~1.67)

# Negative values that require rounding
assert_output "-1 C -> 30 F" "$TEMPCONV" -1 --c-to-f  # -1 C -> 30 F  (30.2)
assert_output "-2 C -> 28 F" "$TEMPCONV" -2 --c-to-f  # -2 C -> 28 F  (28.4)
assert_output "31 F -> -1 C" "$TEMPCONV" 31 --f-to-c  # 31 F -> -1 C  (~-0.56)
assert_output "30 F -> -1 C" "$TEMPCONV" 30 --f-to-c  # 30 F -> -1 C  (~-1.11)
assert_output "29 F -> -2 C" "$TEMPCONV" 29 --f-to-c  # 29 F -> -2 C  (~-1.67)

# (catches incorrect intermediate rounding)
assert_output "31 F -> 273 K"  "$TEMPCONV" 31 --f-to-k

# Kelvin specific rounding accuracy cases
assert_output "1 C -> 274 K"   "$TEMPCONV"    1 --c-to-k
assert_output "-1 C -> 272 K"  "$TEMPCONV"   -1 --c-to-k
assert_output "274 K -> 1 C"   "$TEMPCONV"  274 --k-to-c
assert_output "-458 F -> 1 K"  "$TEMPCONV" -458 --f-to-k
assert_output "1 K -> -458 F"  "$TEMPCONV"    1 --k-to-f
assert_output "-457 F -> 1 K"  "$TEMPCONV" -457 --f-to-k  # positive rounding
assert_output "2 K -> -456 F"  "$TEMPCONV"    2 --k-to-f  # negative rounding
