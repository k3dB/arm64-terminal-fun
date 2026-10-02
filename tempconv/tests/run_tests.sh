RUNNER_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" &>/dev/null && pwd)"

. "$RUNNER_DIR/base_tests.sh"
. "$RUNNER_DIR/rounding_tests.sh"
