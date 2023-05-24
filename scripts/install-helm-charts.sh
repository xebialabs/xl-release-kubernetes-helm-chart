SCRIPT_DIR=$( dirname -- "$0"; )
HELM_DIR="${SCRIPT_DIR}/.."
CURRENT_DIR=$(pwd)
cd "$HELM_DIR"
helm dependency update
cd "$CURRENT_DIR"
DEFAULT_VALUES="$1"
shift 1
helm install ${DAI_RELEASE} "$HELM_DIR" -n $DAI_NAMESPACE --create-namespace --values "$DEFAULT_VALUES" "$@"
