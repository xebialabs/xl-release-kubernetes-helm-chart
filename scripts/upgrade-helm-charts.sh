SCRIPT_DIR=$( dirname -- "$0"; )
HELM_DIR="${SCRIPT_DIR}/.."
DEFAULT_VALUES="$1"
shift 1
helm upgrade --install ${DAI_RELEASE} "$HELM_DIR" -n $DAI_NAMESPACE --values "$DEFAULT_VALUES" "$@"

