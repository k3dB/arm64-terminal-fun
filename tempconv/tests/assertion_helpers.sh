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
