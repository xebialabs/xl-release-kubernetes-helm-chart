SCRIPT_DIR=$( dirname -- "$0"; )
HELM_DIR="${SCRIPT_DIR}/.."
# require https://github.com/bitnami-labs/readme-generator-for-helm
DEFAULT_VALUES="$1"
shift 1
readme-generator-for-helm --readme "$HELM_DIR/README.md" --values "$DEFAULT_VALUES" "$@"
