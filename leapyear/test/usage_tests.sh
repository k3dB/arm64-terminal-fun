EXPECTED="Usage: leapyear <year>
    <year> must be between 1 and 65535 (16-bit unsigned integer)"

# Correct usage
assert_cli 0 "2032 is a leap year." "$LEAPYEAR" 2032

# No arguemnts
assert_cli 1 "$EXPECTED" "$LEAPYEAR"

# Not a number
assert_cli 1 "$EXPECTED" "$LEAPYEAR" Bob

# Empty string
assert_cli 1 "$EXPECTED" "$LEAPYEAR" ""

# More than one argument
assert_cli 1 "$EXPECTED" "$LEAPYEAR" 2032 Bob
assert_cli 1 "$EXPECTED" "$LEAPYEAR" 2032 2028
assert_cli 1 "$EXPECTED" "$LEAPYEAR" 2032 2028 2025
assert_cli 1 "$EXPECTED" "$LEAPYEAR" 2032 Alice 3.14159
assert_cli 1 "$EXPECTED" "$LEAPYEAR" 2032 2027

# Number ouside of acceptable range
assert_cli 1 "$EXPECTED" "$LEAPYEAR" 0
assert_cli 1 "$EXPECTED" "$LEAPYEAR" -1
assert_cli 1 "$EXPECTED" "$LEAPYEAR" -400
assert_cli 1 "$EXPECTED" "$LEAPYEAR" 66000
assert_cli 1 "$EXPECTED" "$LEAPYEAR" 65536
assert_cli 1 "$EXPECTED" "$LEAPYEAR" 65537
