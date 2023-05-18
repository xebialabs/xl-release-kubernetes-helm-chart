SCRIPT_DIR=$( dirname -- "$0"; )
HELM_DIR="${SCRIPT_DIR}/.."
## requires datree helm plugin: https://github.com/datreeio/helm-datree
DEFAULT_VALUES="$1"
shift 1
helm datree ${DAI_RELEASE} "${HELM_DIR}" -- -n $DAI_NAMESPACE --values "$DEFAULT_VALUES" "$@"
