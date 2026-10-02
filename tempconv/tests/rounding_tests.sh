CURRENT_TEST_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" &>/dev/null && pwd)"
COMMAND="$CURRENT_TEST_DIR/../bin/tempconv"

source "$CURRENT_TEST_DIR/assertion_helpers.sh"

# Positive values that require rounding
assert_output "1 C -> 34 F" $COMMAND 1 --c-to-f       # 1 C -> 34 F       (33.8)
assert_output "2 C -> 36 F" $COMMAND 2 --c-to-f       # 2 C -> 36 F       (35.6)
assert_output "33 F -> 1 C" $COMMAND 33 --f-to-c      # 33 F -> 1 C       (~0.56)
assert_output "34 F -> 1 C" $COMMAND 34 --f-to-c      # 34 F -> 1 C       (~1.11)

# Negative values that require rounding
assert_output "-1 C -> 30 F" $COMMAND -1 --c-to-f      # -1 C -> 30 F      (30.2)
assert_output "-2 C -> 28 F" $COMMAND -2 --c-to-f      # -2 C -> 28 F      (28.4)
assert_output "31 F -> -1 C" $COMMAND 31 --f-to-c      # 31 F -> -1 C      (~-0.56)
assert_output "30 F -> -1 C" $COMMAND 30 --f-to-c      # 30 F -> -1 C      (~-1.11)

# Special cases
assert_output "33 F -> 1 C" $COMMAND 33 --f-to-c      # 33 F -> 1 C
assert_output "31 F -> -1 C" $COMMAND 31 --f-to-c      # 31 F -> -1 C
