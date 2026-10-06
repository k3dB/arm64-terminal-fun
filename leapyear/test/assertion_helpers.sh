# Asserts that the command returns 0 and matches the expected output.
# Pattern: assert_output <expected_output> <command> <args...>
# Example: assert_output "100 C -> 212 F" "$TEMPCONV" 100 --c-to-f
assert_output() {
    local expected_output="$1"
    shift

    assert_cli 0 "$expected_output" "$@"
}

# Asserts that the command returns the expected status and output.
# Pattern: assert_cli <expected_status> <expected_output> <command> <args...>
# Example: assert_cli 0 "100 C -> 212 F" "$TEMPCONV" 100 --c-to-f
assert_cli() {
    local expected_status="$1"
    local expected_output="$2"
    shift 2

    local actual_output
    local actual_status
    local GREEN=$'\033[32m'
    local RED=$'\033[31m'
    local RESET=$'\033[0m'

    if actual_output=$("$@" 2>&1); then
        actual_status=0
    else
        actual_status=$?
    fi

    if [[ "$actual_status" == "$expected_status" &&
          "$actual_output" == "$expected_output" ]]; then
        ((TESTS_PASSED += 1))
        echo "${GREEN}SUCCESS:${RESET} $*"
        return 0
    fi

    ((TESTS_FAILED += 1))

    echo "${RED}FAILURE:${RESET} $*"
    echo "   Expected status: $expected_status; got: $actual_status"
    echo "   Expected output: $expected_output"
    echo "   Got output     : $actual_output"
    return 1
}
