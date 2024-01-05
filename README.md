
# Helm chart for Digital.ai Release

**From 10.2 version helm chart is not used directly. Use operator based installation instead.**

Additional documentation can be found by this link:
- https://xebialabs.github.io/xl-release-kubernetes-helm-chart

## Prerequisites

- Kubernetes 1.20+
- Helm 3.2.0+

## Minimal configuration for the K3D cluster

To install the chart with the release name `dair`:

```shell
helm dependency update .
helm install dair . -n digitalai  --create-namespace --values tests/values/basic.yaml
```

On finish of the last command you will see information about helm release.

### Minimal configuration for the AWS cluster

Run helm release `dair` installation with creation of the namespace:
```shell
helm dependency update .
helm install dair . -n digitalai --create-namespace --values tests/values/basic.yaml --values tests/values/aws.yaml
```

Note: The installation uses storageClass `my-efs`, change the name in the `tests/values/aws.yaml` if you need something else.

On finish of the last command you will see information about helm release.

### Minimal configuration for the OpenShift cluster (AWS)

Run helm release `dair` installation with creation of the namespace:
```shell
helm dependency update .
helm install dair . -n digitalai --create-namespace --values tests/values/basic.yaml --values tests/values/openshift-route.yaml
```

Note: The installation uses storageClass `gp2`, change the name in the `tests/values/aws.yaml` if you need something else.
The installation is setting the route hostname, change the value of the hostname for the specific setup on the cluster.

On finish of the last command you will see information about helm release.

## Uninstalling the Chart

To uninstall/delete the `dair` release:

```shell
helm delete dair -n digitalai
```
The command removes all the Kubernetes components associated with the chart and deletes the release.
Uninstalling the chart will not remove the PVCs, you need to delete them manually.

To delete all resources with one command (if in the namespace is only remote-runner installed) you can delete namespace with:
```shell
kubectl delete namespace digitalai
```

## Parameters

### Global parameters

| Name                                         | Description                                                    | Value |
| -------------------------------------------- | -------------------------------------------------------------- | ----- |
| `global.imageRegistry`                       | Global Docker image registry                                   | `""`  |
| `global.imagePullSecrets`                    | Global Docker registry secret names as an array                | `[]`  |
| `global.storageClass`                        | Global StorageClass for Persistent Volume(s)                   | `""`  |
| `global.postgresql.service.ports.postgresql` | PostgreSQL service port (overrides `service.ports.postgresql`) | `""`  |

### Env parameters

| Name                      | Description                                                                                      | Value      |
| ------------------------- | ------------------------------------------------------------------------------------------------ | ---------- |
| `k8sSetup.platform`       | The platform on which you install the chart. Possible values: AWSEKS/AzureAKS/GoogleGKE/PlainK8s | `PlainK8s` |
| `k8sSetup.validateValues` | Enable validation of the values                                                                  | `true`     |

### Release server parameters

| Name                             | Description                                                                                                                                                                                                         | Value        |
| -------------------------------- | ------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- | ------------ |
| `license`                        | Sets your XL License by passing a base64 string license, which will then be added to the license file.                                                                                                              | `""`         |
| `licenseAcceptEula`              | Accept EULA, in case of missing license, it will generate temporary license.                                                                                                                                        | `false`      |
| `generateXlConfig`               | Generate configuration from environment parameters passed, and volumes mounted with custom changes. If set to false, a default config will be used and all environment variables and volumes added will be ignored. | `true`       |
| `useIpAsHostname`                | Set IP address of the container as the hostname for the instance.                                                                                                                                                   | `false`      |
| `forceRemoveMissingTypes`        | Force removal of the missing types.                                                                                                                                                                                 | `false`      |
| `clusterMode`                    | This is to specify if the HA setup is needed and to specify the HA mode. Possible values: "default", "hot-standby", "full"                                                                                          | `full`       |
| `forceUpgrade`                   | It can be used to perform an upgrade in non-interactive mode by passing flag -force-upgrades while starting a service.                                                                                              | `true`       |
| `enableEmbeddedQueue`            | Flag to expose external messaging queue. If set to true, a default embedded-queue will be used and all environment variables will be ignored.                                                                       | `false`      |
| `appProtocol`                    | Release protocol (the protocol http or https that will be used by enduser to access Release). It is not used if ingress or route are enabled.                                                                       | `http`       |
| `appHostname`                    | Release hostname (the hostname that will be used by enduser to access Release). It is not used if ingress or route are enabled.                                                                                     | `""`         |
| `appContextRoot`                 | Release context root.                                                                                                                                                                                               | `/`          |
| `logback.globalLoggingLevel`     | Global logging level. Possible values: "trace", "debug", "info", "warn", "error"                                                                                                                                    | `info`       |
| `logback.scanEnabled`            | Enables scanning of logback.xml.                                                                                                                                                                                    | `true`       |
| `logback.scanPeriod`             | Interval for checking logback.xml configuration.                                                                                                                                                                    | `30 seconds` |
| `auth.adminPassword`             | Admin password for Release. If user does not provide password, random 10 character alphanumeric string will be generated.                                                                                           | `""`         |
| `http2.enabled`                  | Enable HTTP2 communication on Release                                                                                                                                                                               | `false`      |
| `ssl.enabled`                    | Enable SSL to be used on Release                                                                                                                                                                                    | `false`      |
| `ssl.keystorePassword`           | Keystore password with SSL key.                                                                                                                                                                                     | `nil`        |
| `ssl.keystoreKeypassword`        | Keystore key password with SSL key.                                                                                                                                                                                 | `nil`        |
| `ssl.keystore`                   | Keystore content in base64 format.                                                                                                                                                                                  | `nil`        |
| `external.db.enabled`            | Enable external database                                                                                                                                                                                            | `false`      |
| `external.db.main.url`           | Main database URL for Release                                                                                                                                                                                       | `""`         |
| `external.db.main.username`      | Main database username for Release                                                                                                                                                                                  | `""`         |
| `external.db.main.password`      | Main database password for Release                                                                                                                                                                                  | `""`         |
| `external.db.main.maxPoolSize`   | Main database max pool size for Release                                                                                                                                                                             | `""`         |
| `external.db.report.url`         | Report database URL for Release                                                                                                                                                                                     | `""`         |
| `external.db.report.username`    | Report database username for Release                                                                                                                                                                                | `""`         |
| `external.db.report.password`    | Report database password for Release                                                                                                                                                                                | `""`         |
| `external.db.report.maxPoolSize` | Report database max pool size for Release                                                                                                                                                                           | `""`         |
| `external.mq.enabled`            | Enable external message queue                                                                                                                                                                                       | `false`      |
| `external.mq.url`                | External message queue broker URL for Release                                                                                                                                                                       | `""`         |
| `external.mq.queueName`          | External message queue name for Release                                                                                                                                                                             | `""`         |
| `external.mq.username`           | External message queue broker username for Release                                                                                                                                                                  | `""`         |
| `external.mq.password`           | External message queue broker password for Release                                                                                                                                                                  | `""`         |
| `keystore.passphrase`            | Set passphrase for the keystore                                                                                                                                                                                     | `""`         |
| `keystore.keystore`              | Use repository-keystore.jceks files content ecoded with base64                                                                                                                                                      | `""`         |
| `truststore.type`                | Type of truststore, possible value jks or jceks or pkcs12                                                                                                                                                           | `pkcs12`     |
| `truststore.password`            | Truststore password                                                                                                                                                                                                 | `""`         |
| `truststore.truststore`          | Truststore file base64 encoded                                                                                                                                                                                      | `{}`         |
| `networkPolicy.enabled`          | Enable creation of NetworkPolicy resources                                                                                                                                                                          | `false`      |
| `networkPolicy.allowExternal`    | Don't require client label for connections                                                                                                                                                                          | `true`       |
| `networkPolicy.additionalRules`  | Additional NetworkPolicy Ingress "from" rules to set. Note that all rules are OR-ed.                                                                                                                                | `[]`         |

### Metrics Parameters

| Name              | Description                                     | Value   |
| ----------------- | ----------------------------------------------- | ------- |
| `metrics.enabled` | Enable exposing Release metrics to be gathered. | `false` |

### OIDC parameters

| Name                                   | Description                                                                                                       | Value        |
| -------------------------------------- | ----------------------------------------------------------------------------------------------------------------- | ------------ |
| `oidc.accessToken.audience`            | Expected audience 'aud' claim value                                                                               | `nil`        |
| `oidc.accessToken.enable`              | Enable access token                                                                                               | `false`      |
| `oidc.accessToken.issuer`              | Expected issuer 'iss' claim value                                                                                 | `nil`        |
| `oidc.accessToken.jwsAlg`              | Expected JSON Web Algorithm                                                                                       | `nil`        |
| `oidc.accessToken.keyRetrievalUri`     | The jwks_uri to retrieve keys for the token                                                                       | `nil`        |
| `oidc.accessToken.secretKey`           | The secret key if MAC based algorithms is used for the token                                                      | `nil`        |
| `oidc.accessTokenUri`                  | The redirect URI to use for returning the access token                                                            | `nil`        |
| `oidc.clientAuthJwt.enable`            | Enable Client Authentication Using private_key_jwt                                                                | `false`      |
| `oidc.clientAuthJwt.jwsAlg`            | Expected JSON Web Algorithm                                                                                       | `nil`        |
| `oidc.clientAuthJwt.keyStore.enable`   | Enable keystore                                                                                                   | `false`      |
| `oidc.clientAuthJwt.keyStore.path`     | The key store file path                                                                                           | `nil`        |
| `oidc.clientAuthJwt.keyStore.password` | The key store password                                                                                            | `nil`        |
| `oidc.clientAuthJwt.keyStore.type`     | The type of keystore                                                                                              | `nil`        |
| `oidc.clientAuthJwt.key.alias`         | Private key alias inside the key store                                                                            | `nil`        |
| `oidc.clientAuthJwt.key.enable`        | Enable private key                                                                                                | `false`      |
| `oidc.clientAuthJwt.key.password`      | Private key password                                                                                              | `nil`        |
| `oidc.clientAuthJwt.tokenKeyId`        | Token key identifier 'kid' header - set it if your OpenID Connect provider requires it                            | `nil`        |
| `oidc.clientAuthMethod`                | Client authentication method                                                                                      | `nil`        |
| `oidc.clientId`                        | Client ID                                                                                                         | `nil`        |
| `oidc.clientSecret`                    | Client secret                                                                                                     | `nil`        |
| `oidc.emailClaim`                      | Email claim                                                                                                       | `nil`        |
| `oidc.enabled`                         | Enable the OIDC configuration                                                                                     | `false`      |
| `oidc.external`                        | Enable the OIDC configuration                                                                                     | `false`      |
| `oidc.externalIdClaim`                 | A unique external ID such as the user's employee ID or GitHub ID. This is an optional claim.                      | `nil`        |
| `oidc.fullNameClaim`                   | FullName claim                                                                                                    | `nil`        |
| `oidc.idTokenJWSAlg`                   | The ID token signature verification algorithm                                                                     | `nil`        |
| `oidc.issuer`                          | OpenID Provider Issuer here                                                                                       | `nil`        |
| `oidc.keyRetrievalUri`                 | The jwks_uri to retrieve keys                                                                                     | `nil`        |
| `oidc.logoutUri`                       | The logout endpoint to revoke token via the browser                                                               | `nil`        |
| `oidc.postLogoutRedirectUri`           | If you need to redirect to the login page after logout, you can use your redirectUri as the postLogoutRedirectUri | `nil`        |
| `oidc.proxyHost`                       | Proxy host                                                                                                        | `nil`        |
| `oidc.proxyPort`                       | Proxy port                                                                                                        | `nil`        |
| `oidc.redirectUri`                     | The redirectUri endpoint must always point to the /oidc-login Release endpoint.                                   | `nil`        |
| `oidc.rolesClaim`                      | Roles claim                                                                                                       | `nil`        |
| `oidc.scopes`                          | Fields described here must be present in the scope.                                                               | `["openid"]` |
| `oidc.userAuthorizationUri`            | The authorize endpoint to request tokens or authorization codes via the browser                                   | `nil`        |
| `oidc.userNameClaim`                   | A unique username for both internal and external users.                                                           | `nil`        |

### Common parameters

| Name                                     | Description                                                                                        | Value                                                               |
| ---------------------------------------- | -------------------------------------------------------------------------------------------------- | ------------------------------------------------------------------- |
| `nameOverride`                           | String to partially override release.fullname template (will maintain the release name)            | `""`                                                                |
| `fullnameOverride`                       | String to fully override release.fullname template                                                 | `""`                                                                |
| `namespaceOverride`                      | String to fully override common.names.namespace                                                    | `""`                                                                |
| `kubeVersion`                            | Force target Kubernetes version (using Helm capabilities if not set)                               | `""`                                                                |
| `clusterDomain`                          | Kubernetes Cluster Domain                                                                          | `cluster.local`                                                     |
| `extraDeploy`                            | Array of extra objects to deploy with the Release                                                  | `[]`                                                                |
| `commonAnnotations`                      | Annotations to add to all deployed objects                                                         | `{}`                                                                |
| `commonLabels`                           | Labels to add to all deployed objects                                                              |                                                                     |
| `commonLabels.app.kubernetes.io/version` | Labels Release server version                                                                      | `{{ .Chart.AppVersion }}`                                           |
| `diagnosticMode.enabled`                 | Enable diagnostic mode (all probes will be disabled and the command will be overridden)            | `false`                                                             |
| `diagnosticMode.command`                 | Command to override all containers in the deployment                                               | `["/opt/xebialabs/tini"]`                                           |
| `diagnosticMode.args`                    | Args to override all containers in the deployment                                                  | `["--","sleep","infinity"]`                                         |
| `hostAliases`                            | Deployment pod host aliases                                                                        | `[]`                                                                |
| `dnsPolicy`                              | DNS Policy for pod                                                                                 | `""`                                                                |
| `dnsConfig`                              | DNS Configuration pod                                                                              | `{}`                                                                |
| `jvmArgs`                                | Release JVM arguments                                                                              | `""`                                                                |
| `command`                                | Override default container command (useful when using custom images)                               | `["/opt/xebialabs/tini"]`                                           |
| `args`                                   | Override default container args (useful when using custom images)                                  | `["--","/opt/xebialabs/xl-release-server/bin/run-in-container.sh"]` |
| `lifecycleHooks`                         | Overwrite livecycle for the Release container(s) to automate configuration before or after startup | `{}`                                                                |
| `terminationGracePeriodSeconds`          | Default duration in seconds k8s waits for container to exit before sending kill signal.            | `200`                                                               |
| `extraEnvVars`                           | Extra environment variables to add to Release pods                                                 | `[]`                                                                |
| `extraEnvVarsCM`                         | Name of existing ConfigMap containing extra environment variables                                  | `""`                                                                |
| `extraEnvVarsSecret`                     | Name of existing Secret containing extra environment variables (in case of sensitive data)         | `""`                                                                |
| `containerPorts.releaseHttp`             | Release HTTP port value exposed on the container                                                   | `5516`                                                              |
| `containerPorts.releaseHttps`            | Release HTTPS port value exposed on the container                                                  | `5543`                                                              |
| `extraContainerPorts`                    | Extra ports to be included in container spec, primarily informational                              | `[]`                                                                |
| `configuration`                          | Release Configuration file content: required cluster configuration                                 | `""`                                                                |
| `extraConfiguration`                     | Configuration file content: extra configuration to be appended to Release configuration            | `""`                                                                |
| `extraVolumeMounts`                      | Optionally specify extra list of additional volumeMounts                                           | `[]`                                                                |
| `extraVolumes`                           | Optionally specify extra list of additional volumes .                                              | `[]`                                                                |
| `extraSecrets`                           | Optionally specify extra secrets to be created by the chart.                                       | `{}`                                                                |
| `extraSecretsPrependReleaseName`         | Set this flag to true if extraSecrets should be created with <release-name> prepended.             | `false`                                                             |

### Release Image parameters

| Name                       | Description                                                                                                                      | Value                             |
| -------------------------- | -------------------------------------------------------------------------------------------------------------------------------- | --------------------------------- |
| `image.registry`           | Release image registry                                                                                                           | `docker.io`                       |
| `image.repository`         | Release image repository                                                                                                         | `xebialabsunsupported/xl-release` |
| `image.tag`                | Release image tag (immutable tags are recommended)                                                                               | `{{ .Chart.AppVersion }}`         |
| `image.pullPolicy`         | Release image pull policy                                                                                                        | `IfNotPresent`                    |
| `image.pullSecrets`        | Specify docker-registry secret names as an array                                                                                 | `[]`                              |
| `ingress.enabled`          | Enable ingress resource for Management console                                                                                   | `false`                           |
| `ingress.path`             | Path for the default host. You may need to set this to '/*' in order to use this with ALB ingress controllers.                   | `/`                               |
| `ingress.pathType`         | Ingress path type                                                                                                                | `ImplementationSpecific`          |
| `ingress.hostname`         | Default host for the ingress resource                                                                                            | `""`                              |
| `ingress.annotations`      | Additional annotations for the Ingress resource. To enable certificate autogeneration, place here your cert-manager annotations. | `nil`                             |
| `ingress.tls`              | Enable TLS configuration for the hostname defined at `ingress.hostname` parameter                                                | `false`                           |
| `ingress.selfSigned`       | Set this to true in order to create a TLS secret for this ingress record                                                         | `false`                           |
| `ingress.extraHosts`       | The list of additional hostnames to be covered with this ingress record.                                                         | `[]`                              |
| `ingress.extraPaths`       | An array with additional arbitrary paths that may need to be added to the ingress under the main host                            | `[]`                              |
| `ingress.extraRules`       | The list of additional rules to be added to this ingress record. Evaluated as a template                                         | `[]`                              |
| `ingress.extraTls`         | The tls configuration for additional hostnames to be covered with this ingress record.                                           | `[]`                              |
| `ingress.secrets`          | Custom TLS certificates as secrets                                                                                               | `[]`                              |
| `ingress.ingressClassName` | IngressClass that will be be used to implement the Ingress (Kubernetes 1.18+)                                                    | `""`                              |

### OpenShift Route parameters

| Name                                      | Description                                                                              | Value   |
| ----------------------------------------- | ---------------------------------------------------------------------------------------- | ------- |
| `route.enabled`                           | Enable route resource                                                                    | `false` |
| `route.path`                              | Path for the default host.                                                               | `/`     |
| `route.hostname`                          | Default host for the route resource                                                      | `""`    |
| `route.annotations`                       | Additional annotations for the route resource.                                           |         |
| `route.tls`                               | Tls configuration                                                                        |         |
| `route.tls.enabled`                       | Enable the route TLS configuration                                                       | `false` |
| `route.tls.key`                           | key in PEM-encoded format                                                                | `""`    |
| `route.tls.certificate`                   | certificate in PEM-encoded format                                                        | `""`    |
| `route.tls.caCertificate`                 | CA certificate in a PEM-encoded format                                                   | `""`    |
| `route.tls.insecureEdgeTerminationPolicy` | Redirect HTTP to HTTPS. The only valid values are None, Redirect, or empty for disabled. | `""`    |
| `route.tls.termination`                   | The accepted values are edge, passthrough and reencrypt.                                 | `edge`  |

### RBAC parameters

| Name                                          | Description                                                                                | Value  |
| --------------------------------------------- | ------------------------------------------------------------------------------------------ | ------ |
| `serviceAccount.create`                       | Enable creation of ServiceAccount for Release pods                                         | `true` |
| `serviceAccount.name`                         | Name of the created serviceAccount                                                         | `""`   |
| `serviceAccount.automountServiceAccountToken` | Auto-mount the service account token in the pod                                            | `true` |
| `serviceAccount.annotations`                  | Annotations for service account. Evaluated as a template. Only used if `create` is `true`. | `{}`   |
| `rbac.create`                                 | Whether RBAC rules should be created                                                       | `true` |

### Persistence parameters

| Name                                              | Description                                      | Value                                                                                                                                                                                                                 |
| ------------------------------------------------- | ------------------------------------------------ | --------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- |
| `persistence.enabled`                             | Enable Release data persistence using PVC        | `true`                                                                                                                                                                                                                |
| `persistence.single`                              | Enable Release data to use single PVC            | `true`                                                                                                                                                                                                                |
| `persistence.storageClass`                        | PVC Storage Class for Release data volume        | `""`                                                                                                                                                                                                                  |
| `persistence.selector`                            | Selector to match an existing Persistent Volume  | `{}`                                                                                                                                                                                                                  |
| `persistence.accessModes`                         | PVC Access Modes for Release data volume         | `["ReadWriteMany"]`                                                                                                                                                                                                   |
| `persistence.existingClaim`                       | Provide an existing PersistentVolumeClaims       | `""`                                                                                                                                                                                                                  |
| `persistence.size`                                | PVC Storage Request for Release data volume      | `8Gi`                                                                                                                                                                                                                 |
| `persistence.annotations`                         | Persistence annotations. Evaluated as a template |                                                                                                                                                                                                                       |
| `persistence.annotations.helm.sh/resource-policy` | Persistence annotation for keeping created PVCs  | `keep`                                                                                                                                                                                                                |
| `persistence.paths`                               | mounted paths for the Release                    | `["/opt/xebialabs/xl-release-server/conf","/opt/xebialabs/xl-release-server/ext","/opt/xebialabs/xl-release-server/hotfix","/opt/xebialabs/xl-release-server/hotfix/lib","/opt/xebialabs/xl-release-server/reports"]` |

### Exposure parameters

| Name                               | Description                                                                                                                | Value           |
| ---------------------------------- | -------------------------------------------------------------------------------------------------------------------------- | --------------- |
| `service.type`                     | Kubernetes Service type                                                                                                    | `ClusterIP`     |
| `service.portEnabled`              | Release port. Cannot be disabled when `auth.tls.enabled` is `false`. Listener can be disabled with `listeners.tcp = none`. | `true`          |
| `service.ports.releaseHttp`        | Release HTTP port value exposed on the service                                                                             | `80`            |
| `service.ports.releaseHttps`       | Release HTTPS port value exposed on the service                                                                            | `443`           |
| `service.portNames.releaseHttp`    | Release HTTP port name                                                                                                     | `release-http`  |
| `service.portNames.releaseHttps`   | Release HTTPS port name                                                                                                    | `release-https` |
| `service.nodePorts.releaseHttp`    | Release HTTP port value exposed on the node (in case of NodePort service)                                                  | `""`            |
| `service.nodePorts.releaseHttps`   | Release HTTPS port value exposed on the node (in case of NodePort service)                                                 | `""`            |
| `service.extraPorts`               | Extra ports to expose in the service                                                                                       | `[]`            |
| `service.loadBalancerSourceRanges` | Address(es) that are allowed when service is `LoadBalancer`                                                                | `[]`            |
| `service.externalIPs`              | Set the ExternalIPs                                                                                                        | `[]`            |
| `service.externalTrafficPolicy`    | Enable client source IP preservation                                                                                       | `Cluster`       |
| `service.loadBalancerIP`           | Set the LoadBalancerIP                                                                                                     | `""`            |
| `service.clusterIP`                | Kubernetes service Cluster IP                                                                                              | `""`            |
| `service.labels`                   | Service labels. Evaluated as a template                                                                                    | `{}`            |
| `service.annotations`              | Service annotations. Evaluated as a template                                                                               | `{}`            |
| `service.annotationsHeadless`      | Headless Service annotations. Evaluated as a template                                                                      | `{}`            |
| `service.sessionAffinity`          | Session Affinity for Kubernetes service, can be "None" or "ClientIP"                                                       | `None`          |
| `service.sessionAffinityConfig`    | Additional settings for the sessionAffinity                                                                                | `{}`            |

### Statefulset parameters

| Name                                                            | Description                                                                                                                       | Value                       |
| --------------------------------------------------------------- | --------------------------------------------------------------------------------------------------------------------------------- |-----------------------------|
| `replicaCount`                                                  | Number of Release replicas to deploy                                                                                              | `3`                         |
| `schedulerName`                                                 | Use an alternate scheduler, e.g. "stork".                                                                                         | `""`                        |
| `podManagementPolicy`                                           | Pod management policy                                                                                                             | `OrderedReady`              |
| `podLabels`                                                     | Release Pod labels. Evaluated as a template                                                                                       | `{}`                        |
| `podAnnotations`                                                | Release Pod annotations. Evaluated as a template                                                                                  | `{}`                        |
| `updateStrategy.type`                                           | Update strategy type for Release statefulset                                                                                      | `RollingUpdate`             |
| `statefulsetLabels`                                             | Release statefulset labels. Evaluated as a template                                                                               | `{}`                        |
| `statefulsetAnnotations`                                        | Release statefulset annotations. Evaluated as a template                                                                          | `{}`                        |
| `priorityClassName`                                             | Name of the priority class to be used by Release pods, priority class needs to be created beforehand                              | `""`                        |
| `podAffinityPreset`                                             | Pod affinity preset. Ignored if `affinity` is set. Allowed values: `soft` or `hard`                                               | `""`                        |
| `podAntiAffinityPreset`                                         | Pod anti-affinity preset. Ignored if `affinity` is set. Allowed values: `soft` or `hard`                                          | `soft`                      |
| `nodeAffinityPreset.type`                                       | Node affinity preset type. Ignored if `affinity` is set. Allowed values: `soft` or `hard`                                         | `""`                        |
| `nodeAffinityPreset.key`                                        | Node label key to match Ignored if `affinity` is set.                                                                             | `""`                        |
| `nodeAffinityPreset.values`                                     | Node label values to match. Ignored if `affinity` is set.                                                                         | `[]`                        |
| `affinity`                                                      | Affinity for pod assignment. Evaluated as a template                                                                              | `{}`                        |
| `nodeSelector`                                                  | Node labels for pod assignment. Evaluated as a template                                                                           | `{}`                        |
| `tolerations`                                                   | Tolerations for pod assignment. Evaluated as a template                                                                           | `[]`                        |
| `topologySpreadConstraints`                                     | Topology Spread Constraints for pod assignment spread across your cluster among failure-domains. Evaluated as a template          | `[]`                        |
| `podSecurityContext.enabled`                                    | Enable Release pod's Security Context                                                                                             | `true`                      |
| `podSecurityContext.runAsUser`                                  | Set Release pod's Security Context runAsUser                                                                                      | `10001`                     |
| `podSecurityContext.runAsGroup`                                 | Set Release pod's Security Context runAsGroup                                                                                     | `10001`                     |
| `podSecurityContext.fsGroup`                                    | Set Release pod's Security Context fsGroup                                                                                        | `10001`                     |
| `containerSecurityContext.enabled`                              | Enabled Release containers' Security Context                                                                                      | `true`                      |
| `containerSecurityContext.runAsUser`                            | Set Release containers' Security Context runAsUser                                                                                | `10001`                     |
| `containerSecurityContext.runAsNonRoot`                         | Set Release container's Security Context runAsNonRoot                                                                             | `true`                      |
| `resources.limits`                                              | The resources limits for Release containers                                                                                       | `{}`                        |
| `resources.requests`                                            | The requested resources for Release containers                                                                                    | `{}`                        |
| `health.enabled`                                                | Enable probes                                                                                                                     | `true`                      |
| `health.periodScans`                                            | Period seconds for probe                                                                                                          | `10`                        |
| `health.probeFailureThreshold`                                  | Failure threshold for probe                                                                                                       | `12`                        |
| `health.probesLivenessTimeout`                                  | Initial delay seconds for livenessProbe                                                                                           | `60`                        |
| `health.probesReadinessTimeout`                                 | Initial delay seconds for readinessProbe                                                                                          | `60`                        |
| `initContainers`                                                | Add init containers to the Release pod                                                                                            | `[]`                        |
| `sidecars`                                                      | Add sidecar containers to the Release pod                                                                                         | `[]`                        |
| `volumePermissions.enabled`                                     | Enable init container that changes the owner and group of the persistent volume(s) mountpoint to `runAsUser:fsGroup`              | `false`                     |
| `volumePermissions.image.registry`                              | Init container volume-permissions image registry                                                                                  | `docker.io`                 |
| `volumePermissions.image.repository`                            | Init container volume-permissions image repository                                                                                | `bitnami/bitnami-shell`     |
| `volumePermissions.image.tag`                                   | Init container volume-permissions image tag                                                                                       | `11-debian-11-r92`          |
| `volumePermissions.image.digest`                                | Init container volume-permissions image digest in the way sha256:aa.... Please note this parameter, if set, will override the tag | `""`                        |
| `volumePermissions.image.pullPolicy`                            | Init container volume-permissions image pull policy                                                                               | `IfNotPresent`              |
| `volumePermissions.image.pullSecrets`                           | Specify docker-registry secret names as an array                                                                                  | `[]`                        |
| `volumePermissions.script`                                      | Script for changing the owner and group of the persistent volume(s). Paths are declared in the 'paths' variable.                  |                             |
| `volumePermissions.resources.limits`                            | Init container volume-permissions resource limits                                                                                 | `{}`                        |
| `volumePermissions.resources.requests`                          | Init container volume-permissions resource requests                                                                               | `{}`                        |
| `volumePermissions.containerSecurityContext.runAsUser`          | User ID for the init container                                                                                                    | `0`                         |
| `pdb.create`                                                    | Enable/disable a Pod Disruption Budget creation                                                                                   | `false`                     |
| `pdb.minAvailable`                                              | Minimum number/percentage of pods that should remain scheduled                                                                    | `1`                         |
| `pdb.maxUnavailable`                                            | Maximum number/percentage of pods that may be made unavailable                                                                    | `""`                        |
| `busyBox.image.registry`                                        | busyBox container image registry                                                                                                  | `docker.io`                 |
| `busyBox.image.repository`                                      | busyBox container image repository                                                                                                | `library/busybox`           |
| `busyBox.image.tag`                                             | busyBox container image tag                                                                                                       | `stable`                    |
| `busyBox.image.pullPolicy`                                      | busyBox container image pull policy                                                                                               | `IfNotPresent`              |
| `busyBox.image.pullSecrets`                                     | Specify docker-registry secret names as an array                                                                                  | `[]`                        |
| `haproxy-ingress.install`                                       | Enable Haproxy Ingress helm subchart installation                                                                                 | `false`                     |
| `haproxy-ingress.controller.ingressClass`                       | Name of the ingress class to route through this controller                                                                        | `haproxy-dair`              |
| `haproxy-ingress.controller.service.type`                       | Kubernetes Service type for Controller                                                                                            | `LoadBalancer`              |
| `nginx-ingress-controller.install`                              | Enable NGINX Ingress Controller helm subchart installation                                                                        | `false`                     |
| `nginx-ingress-controller.extraArgs`                            | Additional command line arguments to pass to nginx-ingress-controller                                                             |                             |
| `nginx-ingress-controller.extraArgs.ingress-class`              | Name of the IngressClass resource                                                                                                 | `nginx-dair`                |
| `nginx-ingress-controller.ingressClassResource.name`            | Name of the IngressClass resource                                                                                                 | `nginx-dair`                |
| `nginx-ingress-controller.ingressClassResource.controllerClass` | IngressClass identifier for the controller                                                                                        | `k8s.io/ingress-nginx-dair` |
| `nginx-ingress-controller.replicaCount`                         | Desired number of Controller pods                                                                                                 | `1`                         |

### Traffic exposure parameters

| Name                                    | Description                                  | Value          |
| --------------------------------------- | -------------------------------------------- | -------------- |
| `nginx-ingress-controller.service.type` | Kubernetes Service type for Controller       | `LoadBalancer` |
| `postgresql.install`                    | Enable PostgreSQL helm subchart installation | `true`         |

### PostgreSQL Primary parameters

| Name                                           | Description                                                                                            | Value                                                   |
| ---------------------------------------------- | ------------------------------------------------------------------------------------------------------ | ------------------------------------------------------- |
| `postgresql.primary.initdb.scriptsSecret`      | Secret with scripts to be run at first boot (in case it contains sensitive information)                | `{{ include "postgresql.primary.fullname" . }}-release` |
| `postgresql.primary.extendedConfiguration`     | Extended PostgreSQL Primary configuration (appended to main or default configuration)                  | `max_connections = 150
`                                |
| `postgresql.primary.persistence.enabled`       | Enable PostgreSQL Primary data persistence using PVC                                                   | `true`                                                  |
| `postgresql.primary.persistence.accessModes`   | PVC Access Mode for PostgreSQL volume                                                                  | `["ReadWriteOnce"]`                                     |
| `postgresql.primary.persistence.storageClass`  | PVC Storage Class for PostgreSQL Primary data volume                                                   | `""`                                                    |
| `postgresql.primary.persistence.size`          | PVC Storage Request for PostgreSQL volume                                                              | `8Gi`                                                   |
| `postgresql.primary.persistence.existingClaim` | Name of an existing PVC to use                                                                         | `""`                                                    |
| `postgresql.primary.resources.requests.memory` | The requested memory for the PostgreSQL Primary containers                                             | `256Mi`                                                 |
| `postgresql.primary.resources.requests.cpu`    | The requested cpu for the PostgreSQL Primary containers                                                | `250m`                                                  |
| `postgresql.primary.service.ports.postgresql`  | PostgreSQL service port                                                                                | `5432`                                                  |
| `postgresql.primary.service.type`              | Kubernetes Service type                                                                                | `ClusterIP`                                             |
| `postgresql.auth.enablePostgresUser`           | Assign a password to the "postgres" admin user. Otherwise, remote access will be blocked for this user | `true`                                                  |
| `postgresql.auth.username`                     | Name for a custom user to create                                                                       | `postgres`                                              |
| `postgresql.auth.postgresPassword`             | Password for the "postgres" admin user. Ignored if `auth.existingSecret` is provided                   | `postgres`                                              |
| `postgresql.serviceAccount.create`             | Enable creation of ServiceAccount for PostgreSQL pod                                                   | `true`                                                  |

### Volume Permissions parameters

| Name                                     | Description                                                                                         | Value                                             |
| ---------------------------------------- | --------------------------------------------------------------------------------------------------- | ------------------------------------------------- |
| `postgresql.volumePermissions.enabled`   | Enable init container that changes the owner and group of the persistent volume                     | `true`                                            |
| `rabbitmq.install`                       | Enable Rabbitmq helm subchart installation                                                          | `true`                                            |
| `rabbitmq.clustering.forceBoot`          | Force boot of an unexpectedly shut down cluster (in an unexpected order).                           | `true`                                            |
| `rabbitmq.replicaCount`                  | Number of RabbitMQ replicas to deploy                                                               | `3`                                               |
| `rabbitmq.auth.username`                 | RabbitMQ application username                                                                       | `guest`                                           |
| `rabbitmq.auth.password`                 | RabbitMQ application password                                                                       | `guest`                                           |
| `rabbitmq.auth.existingErlangSecret`     | Existing secret with RabbitMQ Erlang cookie (must contain a value for `rabbitmq-erlang-cookie` key) | `{{ include "common.names.fullname" . }}-release` |
| `rabbitmq.extraPlugins`                  | Extra plugins to enable (single string containing a space-separated list)                           | `rabbitmq_amqp1_0`                                |
| `rabbitmq.loadDefinition.enabled`        | Enable loading a RabbitMQ definitions file to configure RabbitMQ                                    | `true`                                            |
| `rabbitmq.loadDefinition.file`           | Name of the definitions file                                                                        | `/app/release_load_definition.json`               |
| `rabbitmq.loadDefinition.existingSecret` | Existing secret with the load definitions file                                                      | `{{ include "common.names.fullname" . }}-release` |
| `rabbitmq.extraConfiguration`            | Configuration file content: extra configuration to be appended to RabbitMQ configuration            | `""`                                              |

### Persistence parameters

| Name                                | Description                                  | Value               |
| ----------------------------------- | -------------------------------------------- | ------------------- |
| `rabbitmq.persistence.enabled`      | Enable RabbitMQ data persistence using PVC   | `true`              |
| `rabbitmq.persistence.accessModes`  | PVC Access Modes for RabbitMQ data volume    | `["ReadWriteOnce"]` |
| `rabbitmq.persistence.storageClass` | PVC Storage Class for RabbitMQ data volume   | `""`                |
| `rabbitmq.persistence.size`         | PVC Storage Request for RabbitMQ data volume | `8Gi`               |

### Exposure parameters

| Name                    | Description             | Value       |
| ----------------------- | ----------------------- | ----------- |
| `rabbitmq.service.type` | Kubernetes Service type | `ClusterIP` |

### Init Container Parameters

| Name                                 | Description                                                                                                          | Value  |
| ------------------------------------ | -------------------------------------------------------------------------------------------------------------------- | ------ |
| `rabbitmq.volumePermissions.enabled` | Enable init container that changes the owner and group of the persistent volume(s) mountpoint to `runAsUser:fsGroup` | `true` |
