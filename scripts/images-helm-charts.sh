SCRIPT_DIR=$( dirname -- "$0"; )
HELM_DIR="${SCRIPT_DIR}/.."
## requires images helm plugin: https://github.com/nikhilsbhat/helm-images
DEFAULT_VALUES="$1"
shift 1
helm images get ${DAI_RELEASE} "${HELM_DIR}" -n $DAI_NAMESPACE --values "$DEFAULT_VALUES" "$@"
