SCRIPT_DIR=$( dirname -- "$0"; )
HELM_DIR="${SCRIPT_DIR}/.."
OUTPUT_DIR="${SCRIPT_DIR}/../build/e2e"
TEST_DIR="${SCRIPT_DIR}/../tests/e2e/basic.yaml"
export HELM_REL_PATH=../../..
# require https://kuttl.dev/docs/cli.html#setup-the-kuttl-kubectl-plugin - `kubectl krew install kuttl`
kubectl kuttl test --artifacts-dir $OUTPUT_DIR --config $TEST_DIR
