# Prime numbers
assert_output "2 is a prime number."          "$ISPRIME" 2
assert_output "3 is a prime number."          "$ISPRIME" 3
assert_output "137 is a prime number."        "$ISPRIME" 137
assert_output "4294967311 is a prime number." "$ISPRIME" 4294967311
assert_output "18446744073709551557 is a prime number." "$ISPRIME" 18446744073709551557

# Zero and one are valid inputs, but are not prime.
assert_output "0 is not a prime number." "$ISPRIME" 0
assert_output "1 is not a prime number." "$ISPRIME" 1

# Composite numbers, including the largest unsigned 64-bit value.
assert_output "4 is not a prime number."                   "$ISPRIME" 4
assert_output "27 is not a prime number."                  "$ISPRIME" 27
assert_output "169 is not a prime number."                 "$ISPRIME" 169
assert_output "18446744073709551615 is not a prime number." "$ISPRIME" 18446744073709551615

# Leading zeros are accepted and omitted from the output.
assert_output "7 is a prime number." "$ISPRIME" 0007
