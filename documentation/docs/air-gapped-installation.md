---
sidebar_position: 10
---

:::caution
This is internal documentation. This document can be used only if it was recommended by the Support Team.
:::

# Release Installation on a Air-gapped K8S Cluster 

## Requirements

- Running k8s cluster
- `kubectl` connected to the cluster
- `xl-cli` installed - version 23.3.5 or above
- Release operator version above following:
    - 22.3.1

## Installation steps

### Download matching version of the xl-op-blueprints

Check what you need with `xl kube help`, for example:

```
❯ xl kube help

Install, upgrade or clean Digital.ai Deploy or Digital.ai Release on a Kubernetes cluster using operator technology.

Installation blueprint files are used from https://dist.xebialabs.com/public/xl-op-blueprints/23.3.5/.

You need to have kubectl installed and configured for the target Kubernetes cluster.
```

You can see from here that `xl kube` needs blueprints from location [https://dist.xebialabs.com/public/xl-op-blueprints/23.3.5/](https://dist.xebialabs.com/public/xl-op-blueprints/23.3.5/).
You need to download and put all files from that location to the server where you will execute `xl kube`.

:::TIP
You can download zipped version of the xl-op-blueprints from here: 
[https://nexus.xebialabs.com/nexus/content/repositories/digitalai-public/ai/digital/xlclient/blueprints/xl-op-blueprints/](https://nexus.xebialabs.com/nexus/content/repositories/digitalai-public/ai/digital/xlclient/blueprints/xl-op-blueprints/)

Unzip it to the server where you will execute `xl kube`.
:::

### Get the operator related images to your image repository

The kubernetes cluster running in airgapped environment cannot download any image from public registry (such as docker.io, gcr.io, quay.io). The images need to be pushed to a image registry accessible to the kubernetes cluster. Create either a private image repository on your cloud provider or a local image repository that is accessible to the kubernetes cluster.

#### Prerequisite Images
Push the images according to your planned installation to your image repository.
For example, for version 23.3.5, following is the list of the images that you will need:

- docker.io/xebialabs/xl-release:23.3.5
- docker.io/xebialabs/tiny-tools:22.2.0
- docker.io/xebialabs/release-operator:23.3.5
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

### How to push image to internally accessible docker registry

You need to pull the required images first on a bastion instance where public internet connectivity is there, then tag it and push it to your internally accessible docker image registry. Your kubernetes cluster will pull images from the docker registry.

For example with a docker registry at `myrepo_host`, the steps to push a docker image(for eg. xl-release) to the repository `myrepo` would be as follows.

```
docker pull docker.io/xebialabs/xl-release:22.3.1
docker tag docker.io/xebialabs/xl-release:22.3.1 myrepo_host/myrepo/xl-release:22.3.1
docker push myrepo_host/myrepo/xl-release:22.3.1
```

> Make sure, you're logged in to the docker registry before pushing the docker image.

### Create registry secret if using a private image registry protected by password

```
kubectl create secret docker-registry regcred \
  --docker-server=myrepo_host \
  --docker-username=<reg-user> \
  --docker-password=<reg-password> \
  -n digitalai
```
This example creates a secret `regcred` which will be used for pull secrets for pulling image when using custom private image registry.

### Use `xl kube install` to install using custom docker image registry option 

When using custom docker registry, the repository name will be of the format `myrepo_host/myrepo` and operator image will be in the format `myrepo_host/myrepo/deploy-operator:image_tag`

Here is example of the installation on minikube with a local docker registry running at `localhost:5000`

In the below example the repository name looks like `localhost:5000/myrepo`, so operator image would be like `localhost:5000/myrepo/deploy-operator:22.3.1`. Remember to override default answer and specify in this format.

```
❯ xl kube install -l ./xl-op-blueprints
? Following kubectl context will be used during execution: `minikube`? Yes
? Select the Kubernetes setup where the Digital.ai Devops Platform will be installed, updated or cleaned: PlainK8s [Plain multi-node K8s cluster]
? Do you want to use an custom Kubernetes namespace (current default is 'digitalai'): No
? Do you want to create custom Kubernetes namespace digitalai, it does not exist: Yes
? Product server you want to perform install for: dai-release [Digital.ai Release]
? Select the type of Image Registry: public [Custom Public Registry (Overrides defaults to use a specific custom public registry)]
? Enter the custom docker image registry name: localhost:5000
? Enter the repository name (eg: <imageRegistryName>/<repositoryName> from <imageRegistryName>/<repositoryName>/<imageName>:<tagName>): localhost:5000/xebialabsunsupported
? Enter PVC size for Release (Gi): 1
? Select between supported Access Modes: ReadWriteMany [ReadWriteMany]
? Select between supported ingress types: nginx [NGINX]
? Do you want to enable an TLS/SSL configuration (if yes, requires existing TLS secret in the namespace): No
? Provide DNS name for accessing UI of the server: test.com
? Provide administrator password: OJnEi1BMBRuDm3ny
? Type of the OIDC configuration: no-oidc [No OIDC Configuration]
? Enter the operator image to use (eg: <repositoryName>/<imageName>:<tagName>): myrepo_host/myrepo/release-operator:22.3.1
? Select source of the license: file [Path to the license file (the file can be in clean text or base64 encoded)]
? Provide license file for the server: ./xl-release-license.lic
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

After the install command completes successfully, you will see operator and other resources pods coming up and running.

## Upgrade steps

Use `xl kube upgrade` to upgrade. It is similar to installation steps. Here the already installed cluster resources are overwritten/upgraded with the newly supplied values.

During upgrade for the question `Edit list of custom resource keys that will migrate to the new Release CR:` append to the list following keys:

### For Default image registry
```
.spec.TinyToolsImageRepository
.spec.nginx-ingress-controller.defaultBackend.image.registry
.spec.nginx-ingress-controller.defaultBackend.image.repository
.spec.nginx-ingress-controller.image.registry
.spec.nginx-ingress-controller.image.repository
.spec.haproxy-ingress.controller.image.repository
.spec.keycloak.image.repository
.spec.keycloak.postgresql.image.registry
.spec.keycloak.postgresql.image.repository
.spec.postgresql.image.registry
.spec.postgresql.image.repository
.spec.rabbitmq.image.registry
.spec.rabbitmq.image.repository
.spec.rabbitmq.volumePermissions.image.registry
.spec.rabbitmq.volumePermissions.image.repository
```
### For custom docker registry (public)
```
.spec.TinyToolsImageRepository
.spec.nginx-ingress-controller.defaultBackend.image.repository
.spec.nginx-ingress-controller.image.repository
.spec.nginx-ingress-controller.global.imageRegistry
.spec.haproxy-ingress.controller.image.repository
.spec.keycloak.image.repository
.spec.keycloak.postgresql.image.registry
.spec.keycloak.postgresql.image.repository
.spec.postgresql.image.repository
.spec.postgresql.global.imageRegistry
.spec.rabbitmq.image.repository
.spec.rabbitmq.global.imageRegistry
.spec.rabbitmq.volumePermissions.image.repository
```

### For custom docker registry (private)
```
.spec.TinyToolsImageRepository
.spec.nginx-ingress-controller.defaultBackend.image.repository
.spec.nginx-ingress-controller.image.repository
.spec.nginx-ingress-controller.global.imageRegistry
.spec.haproxy-ingress.controller.image.repository
.spec.keycloak.image.repository
.spec.keycloak.postgresql.image.registry
.spec.keycloak.postgresql.image.repository
.spec.postgresql.image.repository
.spec.postgresql.global.imageRegistry
.spec.rabbitmq.image.repository
.spec.rabbitmq.global.imageRegistry
.spec.rabbitmq.volumePermissions.image.repository

.spec.nginx-ingress-controller.global.imagePullSecrets
.spec.keycloak.imagePullSecrets.name
.spec.keycloak.postgresql.imagePullSecrets.name
.spec.postgresql.global.imagePullSecrets
.spec.rabbitmq.global.imagePullSecrets
```

### Example of running upgrade using custom docker image registry option

```
❯ xl kube upgrade -l ./xl-op-blueprints
...
? Select the type of Image Registry: public [Custom Public Registry (Overrides defaults to use a specific custom public registry)]
? Enter the custom docker image registry name: localhost:5000
? Enter the repository name (eg: <imageRegistryName>/<repositoryName> from <imageRegistryName>/<repositoryName>/<imageName>:<tagName>): localhost:5000/myrepo
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

## Image repository related fields that are getting updated in Installation and Upgrade process by xl cli when using a custom image registry

#### kubernetes/dai-release_cr.yaml
- spec.ImageRepository: "myrepo_host/myrepo/xl-release"
- spec.TinyToolsImageRepository: "myrepo_host/myrepo/tiny-tools"
- spec.ImagePullSecret: regcred (only for custom private image registry requiring authentication)

##### If you are using nginx

- spec.nginx-ingress-controller.defaultBackend.image.registry: myrepo_host
- spec.nginx-ingress-controller.defaultBackend.image.repository: myrepo/nginx
- spec.nginx-ingress-controller.image.registry: myrepo_host
- spec.nginx-ingress-controller.image.repository: myrepo/nginx-ingress-controller
- spec.nginx-ingress-controller.imagePullSecrets.[0]: regcred (only for custom private image registry requiring authentication)

##### If you are using haproxy

- spec.haproxy-ingress.controller.image.repository: myrepo_host/myrepo/haproxy-ingress
- spec.haproxy-ingress.imagePullSecrets[0].name: regcred (only for custom private image registry requiring authentication)

##### If you are using embedded keycloak

- spec.keycloak.image.repository: myrepo_host/myrepo/keycloak
- spec.keycloak.postgresql.image.registry: myrepo_host
- spec.keycloak.postgresql.image.repository: myrepo/postgresql
- spec.keycloak.imagePullSecrets[0].name: regcred (only for custom private image registry requiring authentication)
- spec.keycloak.postgres.imagePullSecrets[0].name: regcred (only for custom private image registry requiring authentication)

##### If you are using embedded postgresql

- spec.postgresql.image.registry: myrepo_host
- spec.postgresql.image.repository: myrepo/postgresql
- spec.postgres.global.imagePullSecrets.[0]: regcred (only for custom private image registry requiring authentication)

##### If you are using embedded rabbitmq

- spec.rabbitmq.image.registry: myrepo_host
- spec.rabbitmq.image.repository: myrepo/rabbitmq
- spec.rabbitmq.volumePermissions.image.registry: myrepo_host 
- spec.rabbitmq.volumePermissions.image.repository: myrepo/bitnami-shell
- spec.rabbitmq.global.imagePullSecrets.[0]: regcred (only for custom private image registry requiring authentication)

#### kubernetes/template/deployment.yaml

- spec.template.spec.containers[0].image: myrepo_host/myrepo/kube-rbac-proxy:v0.8.0
- spec.template.spec.containers[1].image: myrepo_host/myrepo/release-operator:{operator-imageTag-given-in-xl-cmd-question}
- spec.template.spec.imagePullSecrets[0].name: regcred (only for custom private image registry requiring authentication)

#### kubernetes/template/postgresql-init-keycloak-db.yaml

- spec.template.spec.initContainers[0].image: myrepo_host/myrepo/tiny-tools:22.2.0
- spec.template.spec.containers[0].image: myrepo_host/myrepo/tiny-tools:22.2.0
- spec.template.spec.imagePullSecrets[0].name: regcred (only for custom private image registry requiring authentication)


