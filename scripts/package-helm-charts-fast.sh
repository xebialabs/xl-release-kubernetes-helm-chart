SCRIPT_DIR=$( dirname -- "$0"; )
HELM_DIR="${SCRIPT_DIR}/.."
CURRENT_DIR=$(pwd)
cd "$HELM_DIR"
helm dependency update
cd "$CURRENT_DIR"
helm package --destination "$HELM_DIR/build" "$HELM_DIR"
