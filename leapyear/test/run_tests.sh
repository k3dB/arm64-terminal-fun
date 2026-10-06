RUNNER_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" &>/dev/null && pwd)"

TESTS_PASSED=0
TESTS_FAILED=0
LEAPYEAR="$RUNNER_DIR/../bin/leapyear"

if ! (cd "$RUNNER_DIR/.." && make clean && make); then
    echo "Build failed; tests not run." >&2
    exit 1
fi

source "$RUNNER_DIR/assertion_helpers.sh"

. "$RUNNER_DIR/valid_input_tests.sh"
. "$RUNNER_DIR/invalid_input_tests.sh"

echo
echo "Passed: $TESTS_PASSED"
echo "Failed: $TESTS_FAILED"

if (( TESTS_FAILED > 0 )); then
    exit 1
fi
