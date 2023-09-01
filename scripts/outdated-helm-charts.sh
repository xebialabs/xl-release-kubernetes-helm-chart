SCRIPT_DIR=$( dirname -- "$0"; )
HELM_DIR="${SCRIPT_DIR}/.."
## requires outdated helm plugin: https://github.com/UniKnow/helm-outdated
helm outdated list "$HELM_DIR"
