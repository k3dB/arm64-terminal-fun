# Asserts that the command returns 0 and matches the expected output.
# Pattern: assert_output <expected_output> <command> <args...>
# Example: assert_output "100 C -> 212 F" $TEMPCONV 100 --c-to-f
assert_output() {
    local expected_output="$1"
    shift

    local actual_output

    GREEN=$'\033[32m'
    RED=$'\033[31m'
    RESET=$'\033[0m'

    # Verify that the command returns success code of 0
    if ! actual_output=$("$@" 2>&1); then
        echo ""
        echo "${RED}FAILURE:${RESET} Command failed: $*"
        echo "   Output: $actual_output"
        echo ""
        return 1
    fi

    # Verify that the output matches the expected output
    if [[ "$actual_output" == "$expected_output" ]]; then
        echo "${GREEN}SUCCESS:${RESET} $*"
    else
        echo "${RED}FAILURE:${RESET} $*"
        echo "   Expected: $expected_output"
        echo "   Got     : $actual_output"
        echo ""
        return 1
    fi
}

# Asserts that the command returns the expected status and output.
# Pattern: assert_cli <expected_status> <expected_output> <command> <args...>
# Example: assert_cli 0 "100 C -> 212 F" $TEMPCONV 100 --c-to-f
assert_cli() {
    local expected_status="$1"
    local expected_output="$2"
    shift 2

    local actual_output
    local actual_status

    if actual_output=$("$@" 2>&1); then
        actual_status=0
    else
        actual_status=$?
    fi

    if [[ "$actual_status" == "$expected_status" &&
          "$actual_output" == "$expected_output" ]]; then
        echo "${GREEN}SUCCESS:${RESET} $*"
        return 0
    fi

    echo "${RED}FAILURE:${RESET} $*"
    echo "   Expected status: $expected_status; got: $actual_status"
    echo "   Expected output: $expected_output"
    echo "   Got output     : $actual_output"
    return 1
}
