---
sidebar_position: 10
---

:::caution
This is internal documentation. This document can be used only if it was recommended by the Support Team.
:::

## Install Release with http2 backend enabled
This article describes the settings to be configured before you install Release with http2 backend enabled on a Kubernetes cluster.

When Release is started with http2, it starts on https/ssl endpoint. And the xl-release backend communicates with ingress on the configured http2 backend endpoint.

## Prerequisites

* [kubectl](https://kubernetes.io/docs/tasks/tools/#kubectl)
* [XL CLI 22.3.5 or later](https://docs.digital.ai/bundle/devops-deploy-version-v.22.3/page/deploy/how-to/install-the-xl-cli.html)
* [yq 4.18.2 or later](https://github.com/mikefarah/yq)
* [openssl] (https://www.openssl.org/source/)
* keytool (Comes with Java JDK. Required only when generating keystore)

### Create Keystore and Certificate using openssl

Run the following command:
```
openssl req -x509 -out localhost.crt -keyout localhost.key \ 
  -newkey rsa:2048 -sha256 \
  -subj '/CN=localhost'

openssl pkcs12 -export -in localhost.crt -inkey localhost.key -name localhost -out ssl-keystore.p12 
```
**Keep this handy:**

The **keystore password** and **keystore key password** that are generated after running the openssl command. These are required as inputs when you install Release using `xl kube install` for http2 enabled setup.

### Specifying Keystore for Release server when enabling http2

When you use XL-CLI, you can specify the created keystore in 2 ways:
* base64 encoded string (in a editor or specify the keystore file location)
* generic secret

#### Create base64 encoded string of Keystore file
Run the following command:
```
cat ssl-keystore.p12 | base64 -w 0
```

#### Create generic secret for Keystore

> **Important**: This step is required only when specifying keystore as secret.

Run the following command:
```
kubectl create secret generic http2-tls-secret --from-file=ssl-keystore.p12=ssl-keystore.p12 -n digital-ai-release
```

### Examples

Below are two examples of running xl kube install with enabling http2 for release

#### Example 1: `xl kube install` using the Release server Keystore file
```
C:\Users\Administrator>xl-client-23.1.0-rc.2-windows-amd64.exe kube install
? Following kubectl context will be used during execution: `arn:aws:eks:us-east-1:932770550094:cluster/devops-operator-cluster-test-cluster`? Yes
? Select the Kubernetes setup where the Digital.ai Devops Platform will be installed, updated or cleaned: AWSEKS [AWS EKS]
? Do you want to use an custom Kubernetes namespace (current default is 'digitalai'): No
? Product server you want to perform install for: dai-release [Digital.ai Release]
? Select type of image registry: default
? Enter the repository name (eg: <repositoryName> from <repositoryName>/<imageName>:<tagName>): xebialabsunsupported
? Enter the image name (eg: <imageName> from <repositoryName>/<imageName>:<tagName>): xl-release
? Enter the image tag (eg: <tagName> from <repositoryName>/<imageName>:<tagName>): 23.1.0-rc.2
? Enter the release server replica count: 1
? Enter PVC size for Release (Gi): 1
? Select between supported Access Modes: ReadWriteMany [ReadWriteMany]
? Do you want to enable http2 for release: Yes
? Select source of the keystore for the server: file [Path to the keystore file (the file can be in the raw format or base64 encoded)]
? Provide keystore file for the server: C:\Users\Administrator\certs\localhost.p12
? Provide the server keystore password: test
? Provide the server keystore key passphrase: test
? Select between supported ingress types: none [None - Ingress will not be set up during installation]
? Provide administrator password: admin
? Type of the OIDC configuration: no-oidc [No OIDC Configuration]
? Enter the operator image to use (eg: <repositoryName>/<imageName>:<tagName>): xebialabsunsupported/release-operator:23.1.0-rc.2
? Select source of the license: file
? Provide license file for the server: C:\Users\Administrator\license\release-license.lic
? Select source of the repository keystore: generate
? Provide keystore passphrase: 4rSuEqVf21G6wS3g
? Provide storage class for the server: my-efs
? Do you want to install a new PostgreSQL on the cluster: Yes
? Provide Storage Class to be defined for PostgreSQL: my-efs
? Provide PVC size for PostgreSQL (Gi): 1
? Do you want to install a new RabbitMQ on the cluster: Yes
? Replica count to be defined for RabbitMQ: 1
? Storage Class to be defined for RabbitMQ: my-efs
? Provide PVC size for RabbitMQ (Gi): 1
         -------------------------------- ----------------------------------------------------
        | LABEL                          | VALUE                                              |
         -------------------------------- ----------------------------------------------------
        | AccessModeRelease              | ReadWriteMany                                      |
        | AdminPassword                  | admin                                              |
        | CleanBefore                    | false                                              |
        | CreateNamespace                | true                                               |
        | EnablePostgresql               | true                                               |
        | EnableRabbitmq                 | true                                               |
        | ExternalOidcConf               | external: false                                    |
        | GenerationDateTime             | 20230502-114403                                    |
        | Http2EnabledRelease            | true                                               |
        | ImageNameRelease               | xl-release                                         |
        | ImageRegistryType              | default                                            |
        | ImageTag                       | 23.1.0-rc.2                                        |
        | IngressType                    | none                                               |
        | IsCustomImageRegistry          | false                                              |
        | K8sSetup                       | AWSEKS                                             |
        | KeystorePassphrase             | 4rSuEqVf21G6wS3g                                   |
        | License                        | LS0tIExpY2Vuc2UgLS0tCkxpY2Vuc2UgdmVyc2lvbjogMwpQ.. |
        | LicenseFile                    | C:\Users\Administrator\license\release-license.lic |
        | LicenseSource                  | file                                               |
        | OidcConfigType                 | no-oidc                                            |
        | OidcConfigTypeInstall          | no-oidc                                            |
        | OperatorImageReleaseGeneric    | xebialabsunsupported/release-operator:23.1.0-rc.2  |
        | OsType                         | windows                                            |
        | PostgresqlPvcSize              | 1                                                  |
        | PostgresqlStorageClass         | my-efs                                             |
        | ProcessType                    | install                                            |
        | PvcSizeRelease                 | 1                                                  |
        | RabbitmqPvcSize                | 1                                                  |
        | RabbitmqReplicaCount           | 1                                                  |
        | RabbitmqStorageClass           | my-efs                                             |
        | ReleaseKeystore                | MIIJ/AIBAzCCCcIGCSqGSIb3DQEHAaCCCbMEggmvMIIJqzCC.. |
        | ReleaseKeystoreFile            | C:\Users\Administrator\certs\localhost.p12         |
        | ReleaseKeystoreKeyPassword     | test                                               |
        | ReleaseKeystorePassword        | test                                               |
        | ReleaseKeystoreSource          | file                                               |
        | RemoteRunnerUseDefaultLocation | true                                               |
        | RepositoryKeystoreSource       | generate                                           |
        | RepositoryName                 | xebialabsunsupported                               |
        | ServerType                     | dai-release                                        |
        | ShortServerName                | xlr                                                |
        | StorageClass                   | my-efs                                             |
        | UseCustomNamespace             | false                                              |
        | XlrReplicaCount                | 1                                                  |
? Do you want to proceed to the deployment with these values? Yes
For current process files will be generated in the: digitalai/dai-release/digitalai/20230502-114403/kubernetes
Generated answers file successfully: digitalai\generated_answers_dai-release_digitalai_install-20230502-114403.yaml
Starting install processing.
Created keystore digitalai/dai-release/digitalai/20230502-114403/kubernetes/repository-keystore.jceks
Skip creating namespace digitalai, already exists
Generated files successfully for AWSEKS installation.
Applying resources to the cluster!
Applied resource clusterrole/xlr-operator-proxy-role from the file digitalai\dai-release\digitalai\20230502-114403\kubernetes\template\cluster-role-digital-proxy-role.yaml
Applied resource clusterrole/xlr-operator-manager-role from the file digitalai\dai-release\digitalai\20230502-114403\kubernetes\template\cluster-role-manager-role.yaml
Applied resource clusterrole/xlr-operator-metrics-reader from the file digitalai\dai-release\digitalai\20230502-114403\kubernetes\template\cluster-role-metrics-reader.yaml
Applied resource service/xlr-operator-controller-manager-metrics-service from the file digitalai\dai-release\digitalai\20230502-114403\kubernetes\template\controller-manager-metrics-service.yaml
Applied resource customresourcedefinition/digitalaireleases.xlr.digital.ai from the file digitalai\dai-release\digitalai\20230502-114403\kubernetes\template\custom-resource-definition.yaml
Applied resource deployment/xlr-operator-controller-manager from the file digitalai\dai-release\digitalai\20230502-114403\kubernetes\template\deployment.yaml
Applied resource role/xlr-operator-leader-election-role from the file digitalai\dai-release\digitalai\20230502-114403\kubernetes\template\leader-election-role.yaml
Applied resource rolebinding/xlr-operator-leader-election-rolebinding from the file digitalai\dai-release\digitalai\20230502-114403\kubernetes\template\leader-election-rolebinding.yaml
Applied resource clusterrolebinding/xlr-operator-manager-rolebinding from the file digitalai\dai-release\digitalai\20230502-114403\kubernetes\template\manager-rolebinding.yaml
Applied resource clusterrolebinding/xlr-operator-proxy-rolebinding from the file digitalai\dai-release\digitalai\20230502-114403\kubernetes\template\proxy-rolebinding.yaml
Applied resource digitalairelease/dai-xlr from the file digitalai/dai-release/digitalai/20230502-114403/kubernetes/dai-release_cr.yaml
Install finished successfully!
```

#### Example 2: `xl kube install` using the Release server Keystore secret

```
C:\Users\Administrator>xl-client-23.1.0-rc.2-windows-amd64.exe kube install
? Following kubectl context will be used during execution: `arn:aws:eks:us-east-1:932770550094:cluster/devops-operator-cluster-test-cluster`? Yes
? Select the Kubernetes setup where the Digital.ai Devops Platform will be installed, updated or cleaned: AWSEKS [AWS EKS]
? Do you want to use an custom Kubernetes namespace (current default is 'digitalai'): No
? Product server you want to perform install for: dai-release [Digital.ai Release]
? Select type of image registry: default
? Enter the repository name (eg: <repositoryName> from <repositoryName>/<imageName>:<tagName>): xebialabsunsupported
? Enter the image name (eg: <imageName> from <repositoryName>/<imageName>:<tagName>): xl-release
? Enter the image tag (eg: <tagName> from <repositoryName>/<imageName>:<tagName>): 23.1.0-rc.2
? Enter the release server replica count: 1
? Enter PVC size for Release (Gi): 1
? Select between supported Access Modes: ReadWriteMany [ReadWriteMany]
? Do you want to enable http2 for release: Yes
? Select source of the keystore for the server: secret [Generic Secret containing keystore file with key as ssl-keystore.p12]
? Provide the generic secret name with the release server keystore added as key ssl-keystore.p12: http2-tls-secret
? Provide the server keystore password: test
? Provide the server keystore key passphrase: test
? Select between supported ingress types: none [None - Ingress will not be set up during installation]
? Provide administrator password: admin
? Type of the OIDC configuration: no-oidc [No OIDC Configuration]
? Enter the operator image to use (eg: <repositoryName>/<imageName>:<tagName>): xebialabsunsupported/release-operator:23.1.0-rc.2
? Select source of the license: file
? Provide license file for the server: C:\Users\Administrator\license\release-license.lic
? Select source of the repository keystore: generate
? Provide keystore passphrase: JILR8MbG18U479RG
? Provide storage class for the server: my-efs
? Do you want to install a new PostgreSQL on the cluster: Yes
? Provide Storage Class to be defined for PostgreSQL: my-efs
? Provide PVC size for PostgreSQL (Gi): 1
? Do you want to install a new RabbitMQ on the cluster: Yes
? Replica count to be defined for RabbitMQ: 1
? Storage Class to be defined for RabbitMQ: my-efs
? Provide PVC size for RabbitMQ (Gi): 1
         -------------------------------- ----------------------------------------------------
        | LABEL                          | VALUE                                              |
         -------------------------------- ----------------------------------------------------
        | AccessModeRelease              | ReadWriteMany                                      |
        | AdminPassword                  | admin                                              |
        | CleanBefore                    | false                                              |
        | CreateNamespace                | true                                               |
        | EnablePostgresql               | true                                               |
        | EnableRabbitmq                 | true                                               |
        | ExternalOidcConf               | external: false                                    |
        | GenerationDateTime             | 20230502-125654                                    |
        | Http2EnabledRelease            | true                                               |
        | ImageNameRelease               | xl-release                                         |
        | ImageRegistryType              | default                                            |
        | ImageTag                       | 23.1.0-rc.2                                        |
        | IngressType                    | none                                               |
        | IsCustomImageRegistry          | false                                              |
        | K8sSetup                       | AWSEKS                                             |
        | KeystorePassphrase             | JILR8MbG18U479RG                                   |
        | License                        | LS0tIExpY2Vuc2UgLS0tCkxpY2Vuc2UgdmVyc2lvbjogMwpQ.. |
        | LicenseFile                    | C:\Users\Administrator\license\release-license.lic |
        | LicenseSource                  | file                                               |
        | OidcConfigType                 | no-oidc                                            |
        | OidcConfigTypeInstall          | no-oidc                                            |
        | OperatorImageReleaseGeneric    | xebialabsunsupported/release-operator:23.1.0-rc.2  |
        | OsType                         | windows                                            |
        | PostgresqlPvcSize              | 1                                                  |
        | PostgresqlStorageClass         | my-efs                                             |
        | ProcessType                    | install                                            |
        | PvcSizeRelease                 | 1                                                  |
        | RabbitmqPvcSize                | 1                                                  |
        | RabbitmqReplicaCount           | 1                                                  |
        | RabbitmqStorageClass           | my-efs                                             |
        | ReleaseKeystoreKeyPassword     | test                                               |
        | ReleaseKeystorePassword        | test                                               |
        | ReleaseKeystoreSecretName      | http2-tls-secret                                   |
        | ReleaseKeystoreSource          | secret                                             |
        | RemoteRunnerUseDefaultLocation | true                                               |
        | RepositoryKeystoreSource       | generate                                           |
        | RepositoryName                 | xebialabsunsupported                               |
        | ServerType                     | dai-release                                        |
        | ShortServerName                | xlr                                                |
        | StorageClass                   | my-efs                                             |
        | UseCustomNamespace             | false                                              |
        | XlrReplicaCount                | 1                                                  |
? Do you want to proceed to the deployment with these values? Yes
For current process files will be generated in the: digitalai/dai-release/digitalai/20230502-125654/kubernetes
Generated answers file successfully: digitalai\generated_answers_dai-release_digitalai_install-20230502-125654.yaml
Starting install processing.
Created keystore digitalai/dai-release/digitalai/20230502-125654/kubernetes/repository-keystore.jceks
Skip creating namespace digitalai, already exists
Generated files successfully for AWSEKS installation.
Applying resources to the cluster!
Applied resource clusterrole/xlr-operator-proxy-role from the file digitalai\dai-release\digitalai\20230502-125654\kubernetes\template\cluster-role-digital-proxy-role.yaml
Applied resource clusterrole/xlr-operator-manager-role from the file digitalai\dai-release\digitalai\20230502-125654\kubernetes\template\cluster-role-manager-role.yaml
Applied resource clusterrole/xlr-operator-metrics-reader from the file digitalai\dai-release\digitalai\20230502-125654\kubernetes\template\cluster-role-metrics-reader.yaml
Applied resource service/xlr-operator-controller-manager-metrics-service from the file digitalai\dai-release\digitalai\20230502-125654\kubernetes\template\controller-manager-metrics-service.yaml
Applied resource customresourcedefinition/digitalaireleases.xlr.digital.ai from the file digitalai\dai-release\digitalai\20230502-125654\kubernetes\template\custom-resource-definition.yaml
Applied resource deployment/xlr-operator-controller-manager from the file digitalai\dai-release\digitalai\20230502-125654\kubernetes\template\deployment.yaml
Applied resource role/xlr-operator-leader-election-role from the file digitalai\dai-release\digitalai\20230502-125654\kubernetes\template\leader-election-role.yaml
Applied resource rolebinding/xlr-operator-leader-election-rolebinding from the file digitalai\dai-release\digitalai\20230502-125654\kubernetes\template\leader-election-rolebinding.yaml
Applied resource clusterrolebinding/xlr-operator-manager-rolebinding from the file digitalai\dai-release\digitalai\20230502-125654\kubernetes\template\manager-rolebinding.yaml
Applied resource clusterrolebinding/xlr-operator-proxy-rolebinding from the file digitalai\dai-release\digitalai\20230502-125654\kubernetes\template\proxy-rolebinding.yaml
Applied resource digitalairelease/dai-xlr from the file digitalai/dai-release/digitalai/20230502-125654/kubernetes/dai-release_cr.yaml
Install finished successfully!
```

### Fields updated for http2 configuration in the cr.yaml
The following fields in cr yaml are updated to configure http2 for release.

```
.spec.http2.enabled
.spec.ssl.enabled
.spec.ssl.keystorePassword
.spec.ssl.keystoreKeypassword
.spec.ssl.keystore
```

### Accessing the release UI
The ingress controller charts we support in the release helm chart(nginx and haproxy) do not support http2 backend. We need to setup external ingress controller seperately and configure to handle http2 backends, to expose the release server over public url. 

For accessing release UI without ingress controller setup, suggest to use kubectl port forward release http2 port to localhost and access release UI from localhost:5543.

#### Command to port-forward Release to localhost port
```
kubectl port-forward pod/<release-pod-name> 5543:5543
```
After port forwarding, release UI will be accessible from https://localhost:5543
