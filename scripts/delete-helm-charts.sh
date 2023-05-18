helm delete ${DAI_RELEASE} -n $DAI_NAMESPACE
kubectl delete pvc data-${DAI_RELEASE}-postgresql-0 -n $DAI_NAMESPACE --ignore-not-found=true
kubectl delete pvc data-${DAI_RELEASE}-rabbitmq-0 -n $DAI_NAMESPACE --ignore-not-found=true
kubectl delete pvc data-${DAI_RELEASE}-rabbitmq-1 -n $DAI_NAMESPACE --ignore-not-found=true
kubectl delete pvc data-${DAI_RELEASE}-rabbitmq-2 -n $DAI_NAMESPACE --ignore-not-found=true
kubectl delete pvc data-${DAI_RELEASE}-dai-release -n $DAI_NAMESPACE --ignore-not-found=true
