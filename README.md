

    helm uninstall dair
    kubectl delete pvc data-dair-dai-release-0
    kubectl delete pvc data-dair-dai-release-1
    
    helm upgrade --install dair . --debug --values ./values-dair.yaml
