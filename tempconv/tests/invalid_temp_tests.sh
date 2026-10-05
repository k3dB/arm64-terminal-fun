EXPECTED="Temperature below absolute zero."

# Temperatures below absolute zero are not valid.
assert_cli 1 "$EXPECTED" "$TEMPCONV" -1 --k-to-f
assert_cli 1 "$EXPECTED" "$TEMPCONV" -1 --k-to-c
assert_cli 1 "$EXPECTED" "$TEMPCONV" -274 --c-to-f
assert_cli 1 "$EXPECTED" "$TEMPCONV" -274 --c-to-k
assert_cli 1 "$EXPECTED" "$TEMPCONV" -460 --f-to-c
assert_cli 1 "$EXPECTED" "$TEMPCONV" -460 --f-to-k

# One more than minimum invalid temperature.
assert_cli 1 "$EXPECTED" "$TEMPCONV" -2 --k-to-f
assert_cli 1 "$EXPECTED" "$TEMPCONV" -2 --k-to-c
assert_cli 1 "$EXPECTED" "$TEMPCONV" -275 --c-to-f
assert_cli 1 "$EXPECTED" "$TEMPCONV" -275 --c-to-k
assert_cli 1 "$EXPECTED" "$TEMPCONV" -461 --f-to-c
assert_cli 1 "$EXPECTED" "$TEMPCONV" -461 --f-to-k
