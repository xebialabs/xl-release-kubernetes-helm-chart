SCRIPT_DIR=$( dirname -- "$0"; )
HELM_DIR="${SCRIPT_DIR}/.."
## requires diff helm plugin: https://github.com/databus23/helm-diff
helm diff upgrade $DAI_RELEASE "$HELM_DIR" -n $DAI_NAMESPACE
