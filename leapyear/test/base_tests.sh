# Valid leap years
assert_output "2028 is a leap year." "$LEAPYEAR" 2028
assert_output "2024 is a leap year." "$LEAPYEAR" 2024
assert_output "2000 is a leap year." "$LEAPYEAR" 2000
assert_output "1996 is a leap year." "$LEAPYEAR" 1996
assert_output "4 is a leap year."    "$LEAPYEAR"    4
assert_output "8 is a leap year."    "$LEAPYEAR"    8
assert_output "400 is a leap year."  "$LEAPYEAR"  400

# Valid non-leap years
assert_output "2027 is not a leap year." "$LEAPYEAR" 2027
assert_output "2001 is not a leap year." "$LEAPYEAR" 2001
assert_output "1999 is not a leap year." "$LEAPYEAR" 1999
assert_output "1900 is not a leap year." "$LEAPYEAR" 1900
assert_output "1 is not a leap year."    "$LEAPYEAR"    1
assert_output "2 is not a leap year."    "$LEAPYEAR"    2
assert_output "3 is not a leap year."    "$LEAPYEAR"    3
assert_output "5 is not a leap year."    "$LEAPYEAR"    5
assert_output "6 is not a leap year."    "$LEAPYEAR"    6
assert_output "7 is not a leap year."    "$LEAPYEAR"    7
assert_output "100 is not a leap year."  "$LEAPYEAR"  100

# Maximum 16-bit unsigned integer
assert_output "65535 is not a leap year." "$LEAPYEAR" 65535

# Near upper bound
assert_output "65532 is a leap year."     "$LEAPYEAR" 65532
assert_output "65534 is not a leap year." "$LEAPYEAR" 65534
