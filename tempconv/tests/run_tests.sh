RUNNER_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" &>/dev/null && pwd)"

TESTS_PASSED=0
TESTS_FAILED=0

cd "$RUNNER_DIR/.."
make clean && make
cd -

source "$RUNNER_DIR/assertion_helpers.sh"

. "$RUNNER_DIR/base_tests.sh"
. "$RUNNER_DIR/rounding_tests.sh"
. "$RUNNER_DIR/invalid_temp_tests.sh"
. "$RUNNER_DIR/usage_tests.sh"

echo
echo "Passed: $TESTS_PASSED"
echo "Failed: $TESTS_FAILED"
