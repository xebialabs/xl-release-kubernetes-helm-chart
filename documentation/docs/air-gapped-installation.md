---
sidebar_position: 10
---

# Release Installation on a Air-gapped K8S Cluster 

## Requirements

- Running k8s cluster
- `kubectl` connected to the cluster
- `xl-cli` installed - version 22.3 or above
- Release operator version above following:
    - 22.3.1

## Installation steps

### Download matching version of the xl-op-blueprints

Check what you need with `xl kube help`, for example:

```
❯ xl kube help

Install, upgrade or clean Digital.ai Deploy or Digital.ai Release on a Kubernetes cluster using operator technology.

Installation blueprint files are used from https://dist.xebialabs.com/public/xl-op-blueprints/22.3.1/.

You need to have kubectl installed and configured for the target Kubernetes cluster.
```

You can see from here that `xl kube` needs blueprints from location [https://dist.xebialabs.com/public/xl-op-blueprints/22.3.1/](https://dist.xebialabs.com/public/xl-op-blueprints/22.3.1/).
You need to download and put all files from that location to the server where you will execute `xl kube`.

:::TIP
You can download zipped version of the xl-op-blueprints from here: 
[https://nexus.xebialabs.com/nexus/content/repositories/digitalai-public/ai/digital/xlclient/blueprints/xl-op-blueprints/](https://nexus.xebialabs.com/nexus/content/repositories/digitalai-public/ai/digital/xlclient/blueprints/xl-op-blueprints/)

Unzip it to the server where you will execute `xl kube`.
:::

### Get the operator related images to your image repository

Push the images according to your planned installation to your image repository.
Following is the list of the images that you will need:

- docker.io/xebialabs/xl-release:22.3.1
- docker.io/xebialabs/tiny-tools:22.2.0
- docker.io/xebialabs/release-operator:22.3.1
- gcr.io/kubebuilder/kube-rbac-proxy:v0.8.0

#### If you are using nginx include

- docker.io/bitnami/nginx:1.21.3-debian-10-r48
- docker.io/bitnami/nginx-ingress-controller:1.0.4-debian-10-r13

#### If you are using haproxy include

- quay.io/jcmoraisjr/haproxy-ingress:v0.13.4

#### If you are using embedded keycloak include

- docker.io/jboss/keycloak:16.1.1

#### If you are using embedded postgresql include

- docker.io/bitnami/postgresql:11.13.0-debian-10-r73

#### If you are using embedded rabbitmq include

- docker.io/bitnami/rabbitmq:3.9.8-debian-10-r6
- docker.io/bitnami/bitnami-shell:10-debian-10-r233

### Use `xl kube install` with dry-run to generate all yaml files 

Run on your air-gapped environment the installation dry-run to generate all the needed files.
Use as repository reference your image repository. 

For example here is example of the dry-run installation on the minikube. 
Example is with the repository myrepo_host/myrepo, so operator image would be: myrepo_host/myrepo/release-operator:22.3.1

```
❯ xl kube install -D -l ./xl-op-blueprints
? Following kubectl context will be used during execution: `minikube`? Yes
? Select the Kubernetes setup where the Digital.ai Devops Platform will be installed, updated or cleaned: PlainK8s [Plain multi-node K8s cluster]
? Do you want to use an custom Kubernetes namespace (current default is 'digitalai'): No
? Do you want to create custom Kubernetes namespace digitalai, it does not exist: Yes
? Product server you want to perform install for: dai-release [Digital.ai Release]
? Enter the repository name (eg: <repositoryName> from <repositoryName>/<imageName>:<tagName>): myrepo_host/myrepo
? Enter the image name (eg: <imageName> from <repositoryName>/<imageName>:<tagName>): xl-release
? Enter the image tag (eg: <tagName> from <repositoryName>/<imageName>:<tagName>): 22.3.1
? Enter the release server replica count: 1
? Enter PVC size for Release (Gi): 1
? Select between supported Access Modes: ReadWriteMany [ReadWriteMany]
? Select between supported ingress types: nginx [NGINX]
? Do you want to enable an TLS/SSL configuration (if yes, requires existing TLS secret in the namespace): No
? Provide DNS name for accessing UI of the server: test.com
? Provide administrator password: OJnEi1BMBRuDm3ny
? Type of the OIDC configuration: no-oidc [No OIDC Configuration]
? Enter the operator image to use (eg: <repositoryName>/<imageName>:<tagName>): myrepo_host/myrepo/release-operator:22.3.1
? Select source of the license: file [Path to the license file (the file can be in clean text or base64 encoded)]
? Provide license file for the server: ./xl-release-license2.lic
? Select source of the repository keystore: generate [Generate the repository keystore during installation (you need to have keytool utility installed in your path)]
? Provide keystore passphrase: ANk9nAJnmQjLmFPy
? Provide storage class for the server: standard
? Do you want to install a new PostgreSQL on the cluster: Yes
? Provide Storage Class to be defined for PostgreSQL: standard
? Provide PVC size for PostgreSQL (Gi): 1
? Do you want to install a new RabbitMQ on the cluster: Yes
? Replica count to be defined for RabbitMQ: 1
? Storage Class to be defined for RabbitMQ: standard
? Provide PVC size for RabbitMQ (Gi): 1

...

? Do you want to proceed to the deployment with these values? Yes
For current process files will be generated in the: digitalai/dai-release/digitalai/20221019-234412/kubernetes
Generated answers file successfully: digitalai/generated_answers_dai-release_digitalai_install-20221019-234412.yaml
Starting install processing.
...
```

Dry run will generate the files in the working folder, in the `digitalai/dai-release/digitalai/20221019-234412/kubernetes` folder like the example says. 

### Edit generated files and update the image repository

Go through generated files and update the image repository. 
There are 3 files that we need to update in the `kubernetes` directory (check the previous step example for details). 

The `spec.ImageRepository` should have already correct value.

#### kubernetes/dai-release_cr.yaml

- spec.TinyToolsImageRepository: "myrepo_host/myrepo/tiny-tools"

##### If you are using nginx

- spec.nginx-ingress-controller.defaultBackend.image.registry: myrepo_host
- spec.nginx-ingress-controller.defaultBackend.image.repository: myrepo/nginx
- spec.nginx-ingress-controller.image.registry: myrepo_host
- spec.nginx-ingress-controller.image.repository: myrepo/nginx-ingress-controller

##### If you are using haproxy

- spec.haproxy-ingress.controller.image.repository: myrepo_host/myrepo/haproxy-ingress

##### If you are using embedded keycloak

- spec.keycloak.image.repository: myrepo_host/myrepo/keycloak
- spec.keycloak.postgresql.image.registry: myrepo_host
- spec.keycloak.postgresql.image.repository: myrepo/postgresql

##### If you are using embedded postgresql

- spec.postgresql.image.registry: myrepo_host
- spec.postgresql.image.repository: myrepo/postgresql

##### If you are using embedded rabbitmq

- spec.rabbitmq.image.registry: myrepo_host
- spec.rabbitmq.image.repository: myrepo/rabbitmq
- spec.rabbitmq.volumePermissions.image.registry: myrepo_host 
- spec.rabbitmq.volumePermissions.image.repository: myrepo/bitnami-shell

#### kubernetes/template/deployment.yaml

- spec.template.spec.containers[0].image: myrepo_host/myrepo/kube-rbac-proxy:v0.8.0

The `spec.template.spec.containers[1].image` should have already correct value.

#### kubernetes/template/postgresql-init-keycloak-db.yaml

- spec.template.spec.initContainers[0].image: myrepo_host/myrepo/tiny-tools:22.2.0
- spec.template.spec.containers[0].image: myrepo_host/myrepo/tiny-tools:22.2.0

### Use `xl kube install` with changed files to apply everything to the cluster

Following command will apply the just changed files on the K8S cluster:

```
❯ xl kube install -f 20221019-234412 -l ./xl-op-blueprints
```

After everything is on the cluster, you will see operator other resources pods running.

## Upgrade steps

Upgrade steps should be same as for usual installation with dry-run.

During upgrade for the question `Edit list of custom resource keys that will migrate to the new Release CR:` append to the list following keys:
```
spec.TinyToolsImageRepository
spec.nginx-ingress-controller.defaultBackend.image.registry
spec.nginx-ingress-controller.defaultBackend.image.repository
spec.nginx-ingress-controller.image.registry
spec.nginx-ingress-controller.image.repository
spec.haproxy-ingress.controller.image.repository
spec.keycloak.image.repository
spec.keycloak.postgresql.image.registry
spec.keycloak.postgresql.image.repository
spec.postgresql.image.registry
spec.postgresql.image.repository
spec.rabbitmq.image.registry
spec.rabbitmq.image.repository
spec.rabbitmq.volumePermissions.image.registry
spec.rabbitmq.volumePermissions.image.repository
```

### Example of running dry-run upgrade

```
❯ xl kube upgrade -D -l ./xl-op-blueprints
...
? Enter the repository name (eg: <repositoryName> from <repositoryName>/<imageName>:<tagName>): localhost:5000/myrepo
...
? Enter the operator image to use (eg: <repositoryName>/<imageName>:<tagName>): localhost:5000/myrepo/release-operator:22.3.1
...
? Edit list of custom resource keys that will migrate to the new Release CR: 
...
? Do you want to proceed to the deployment with these values? Yes
For current process files will be generated in the: digitalai/dai-release/digitalai/20221020-004412/kubernetes
Generated answers file successfully: digitalai/generated_answers_dai-release_digitalai_upgrade-20221020-004412.yaml
Starting upgrade processing.
...
```

### Edit kubernetes/template/deployment.yaml

Update:
- spec.template.spec.containers[0].image: myrepo_host/myrepo/kube-rbac-proxy:v0.8.0

The `spec.template.spec.containers[1].image` should have already correct value.

### Edit kubernetes/template/postgresql-init-keycloak-db.yaml

Update:
- spec.template.spec.initContainers[0].image: myrepo_host/myrepo/tiny-tools:22.2.0
- spec.template.spec.containers[0].image: myrepo_host/myrepo/tiny-tools:22.2.0

### Example of running upgrade with generated files

After doing dry-run upgrade apply the files to the cluster:

```
❯ xl kube upgrade -f 20221020-004412 -l ./xl-op-blueprints
...
```
