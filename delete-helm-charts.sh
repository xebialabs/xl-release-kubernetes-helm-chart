helm delete dair -n digital-ai-release
kubectl delete pvc data-dair-postgresql-0 -n digital-ai-release
kubectl delete pvc data-dair-rabbitmq-0 -n digital-ai-release
kubectl delete pvc data-dair-dai-release -n digital-ai-release
kubectl delete pvc data-dair-dai-release-0 -n digital-ai-release
kubectl delete pvc data-dair-dai-release-1 -n digital-ai-release
