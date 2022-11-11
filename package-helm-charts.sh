helm repo update
helm dependency update
helm package --destination ./build .
