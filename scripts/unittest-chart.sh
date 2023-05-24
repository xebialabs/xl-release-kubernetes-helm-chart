SCRIPT_DIR=$( dirname -- "$0"; )
HELM_DIR="${SCRIPT_DIR}/.."
# require https://github.com/helm-unittest/helm-unittest
helm unittest $HELM_DIR
