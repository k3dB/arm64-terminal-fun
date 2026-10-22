EXPECTED="Usage: isprime <number>
    <number> must be between 0 and 18446744073709551615 (64-bit unsigned integer)"

# Missing, empty, or extra arguments.
assert_cli 1 "$EXPECTED" "$ISPRIME"
assert_cli 1 "$EXPECTED" "$ISPRIME" ""
assert_cli 1 "$EXPECTED" "$ISPRIME" 2 3

# Non-decimal input.
assert_cli 1 "$EXPECTED" "$ISPRIME" abc
assert_cli 1 "$EXPECTED" "$ISPRIME" 123abc
assert_cli 1 "$EXPECTED" "$ISPRIME" -4
assert_cli 1 "$EXPECTED" "$ISPRIME" +4
assert_cli 1 "$EXPECTED" "$ISPRIME" 3.14
assert_cli 1 "$EXPECTED" "$ISPRIME" " 4"
assert_cli 1 "$EXPECTED" "$ISPRIME" "4 "

# Values above the unsigned 64-bit maximum.
assert_cli 1 "$EXPECTED" "$ISPRIME" 18446744073709551616
assert_cli 1 "$EXPECTED" "$ISPRIME" 18446744073709551620
