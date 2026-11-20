# Prime numbers
assert_output "2 is a prime number."   "$ISPRIME" 2
assert_output "3 is a prime number."   "$ISPRIME" 3
assert_output "5 is a prime number."   "$ISPRIME" 5
assert_output "7 is a prime number."   "$ISPRIME" 7
assert_output "137 is a prime number." "$ISPRIME" 137

# Large prime numbers
assert_output "4294967311 is a prime number."           "$ISPRIME" 4294967311
assert_output "18446744073709551557 is a prime number." "$ISPRIME" 18446744073709551557

# Zero and one are valid inputs, but are not prime
assert_output "0 is not a prime number." "$ISPRIME" 0
assert_output "1 is not a prime number." "$ISPRIME" 1

# Composite numbers
assert_output "4 is not a prime number."   "$ISPRIME" 4
assert_output "26 is not a prime number."  "$ISPRIME" 26
assert_output "27 is not a prime number."  "$ISPRIME" 27
assert_output "99 is not a prime number."  "$ISPRIME" 99
assert_output "169 is not a prime number." "$ISPRIME" 169
assert_output "256 is not a prime number." "$ISPRIME" 256
assert_output "999 is not a prime number." "$ISPRIME" 999

# Large composite number
assert_output "4294967312 is not a prime number."           "$ISPRIME" 4294967312
assert_output "18446744073709551615 is not a prime number." "$ISPRIME" 18446744073709551615

# Square root boundaries
assert_output "47 is a prime number."     "$ISPRIME" 47
assert_output "48 is not a prime number." "$ISPRIME" 48
assert_output "49 is not a prime number." "$ISPRIME" 49
assert_output "50 is not a prime number." "$ISPRIME" 50
assert_output "51 is not a prime number." "$ISPRIME" 51

# Leading zeros are accepted and omitted from the output
assert_output "0 is not a prime number." "$ISPRIME" 0000000
assert_output "7 is a prime number."     "$ISPRIME" 0007
assert_output "9 is not a prime number." "$ISPRIME" 0009

# Leading zeros with a large number
assert_output "18446744073709551615 is not a prime number." "$ISPRIME" 00018446744073709551615
