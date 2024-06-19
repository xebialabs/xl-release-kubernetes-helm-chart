
# Helm chart for Digital.ai Release

**From 10.2 version helm chart is not used directly. Use operator based installation instead.**

Additional documentation can be found by this link:
- https://digital.ai/products/release/
- https://docs.digital.ai/bundle/devops-release-version-v.24.1/page/release/operator/xl-op-before-you-begin.html
- https://digital-ai.github.io/release-helm-chart

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

To delete all resources with one command (if in the namespace is only release-runner installed) you can delete namespace with:
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

### K8S env parameters

| Name                      | Description                                                                                      | Value      |
| ------------------------- | ------------------------------------------------------------------------------------------------ | ---------- |
| `k8sSetup.platform`       | The platform on which you install the chart. Possible values: AWSEKS/AzureAKS/GoogleGKE/PlainK8s | `PlainK8s` |
| `k8sSetup.validateValues` | Enable validation of the values                                                                  | `true`     |

### Release server parameters

| Name                         | Description                                                                                                                                                                                                         | Value        |
| ---------------------------- | ------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- | ------------ |
| `license`                    | Sets your XL License by passing a base64 string license, which will then be added to the license file.                                                                                                              | `nil`        |
| `licenseAcceptEula`          | Accept EULA, in case of missing license, it will generate temporary license.                                                                                                                                        | `false`      |
| `generateXlConfig`           | Generate configuration from environment parameters passed, and volumes mounted with custom changes. If set to false, a default config will be used and all environment variables and volumes added will be ignored. | `true`       |
| `useIpAsHostname`            | Set IP address of the container as the hostname for the instance.                                                                                                                                                   | `false`      |
| `forceRemoveMissingTypes`    | Force removal of the missing types.                                                                                                                                                                                 | `false`      |
| `clusterMode`                | This is to specify if the HA setup is needed and to specify the HA mode. Possible values: "default", "hot-standby", "full"                                                                                          | `full`       |
| `forceUpgrade`               | It can be used to perform an upgrade in non-interactive mode by passing flag -force-upgrades while starting a service.                                                                                              | `true`       |
| `enableEmbeddedQueue`        | Flag to expose external messaging queue. If set to true, a default embedded-queue will be used and all environment variables will be ignored.                                                                       | `false`      |
| `appProtocol`                | Release protocol (the protocol http or https that will be used by enduser to access Release). It is not used if ingress or route are enabled.                                                                       | `http`       |
| `appHostname`                | Release hostname (the hostname that will be used by enduser to access Release). It is not used if ingress or route are enabled.                                                                                     | `""`         |
| `appContextRoot`             | Release context root.                                                                                                                                                                                               | `/`          |
| `logback.globalLoggingLevel` | Global logging level. Possible values: "trace", "debug", "info", "warn", "error"                                                                                                                                    | `info`       |
| `logback.scanEnabled`        | Enables scanning of logback.xml.                                                                                                                                                                                    | `true`       |
| `logback.scanPeriod`         | Interval for checking logback.xml configuration.                                                                                                                                                                    | `30 seconds` |

### Release hooks

| Name                                                                           | Description                                                                                                                 | Value                                                                                                                                                                                   |
| ------------------------------------------------------------------------------ | --------------------------------------------------------------------------------------------------------------------------- |-----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------|
| `hooks.getLicense.enabled`                                                     | set to true to support license auto generation by using helm hook, it is working together with enabled licenseAcceptEula    | `true`                                                                                                                                                                                  |
| `hooks.getLicense.name`                                                        | Name of the resources that will be used during hook execution                                                               | `{{ include "release.name" . }}-license`                                                                                                                                                |
| `hooks.getLicense.deletePolicy`                                                | Helm hook delete policy                                                                                                     | `before-hook-creation,hook-succeeded`                                                                                                                                                   |
| `hooks.getLicense.getCommand`                                                  | The command for getting temporary license, see hooks.getLicense.configuration.bin_get-license                               | `["/opt/xebialabs/xl-release-server/bin/get-license.sh"]`                                                                                                                               |
| `hooks.getLicense.installCommand`                                              | The command for creating the secret with the license, see hooks.getLicense.configuration.bin_install-license                | `["/opt/xebialabs/xl-release-server/bin/install-license.sh"]`                                                                                                                           |
| `hooks.getLicense.image.registry`                                              | getLicense hook container image registry                                                                                    | `docker.io`                                                                                                                                                                             |
| `hooks.getLicense.image.repository`                                            | getLicense hook container image repository                                                                                  | `bitnami/kubectl`                                                                                                                                                                       |
| `hooks.getLicense.image.tag`                                                   | getLicense hook container image tag                                                                                         | `1.28.7-debian-12-r3`                                                                                                                                                                   |
| `hooks.getLicense.image.pullPolicy`                                            | getLicense hook container image pull policy                                                                                 | `IfNotPresent`                                                                                                                                                                          |
| `hooks.getLicense.image.pullSecrets`                                           | Specify docker-registry secret names as an array                                                                            | `[]`                                                                                                                                                                                    |
| `hooks.getLicense.containerSecurityContext.enabled`                            | Enabled get licence containers' Security Context                                                                            | `true`                                                                                                                                                                                  |
| `hooks.getLicense.containerSecurityContext.runAsNonRoot`                       | Set get licence container's Security Context runAsNonRoot                                                                   | `true`                                                                                                                                                                                  |
| `hooks.getLicense.containerSecurityContext.allowPrivilegeEscalation`           | Set get licence container's Security Context allowPrivilegeEscalation                                                       | `false`                                                                                                                                                                                 |
| `hooks.getLicense.containerSecurityContext.capabilities`                       | Set get licence container's Security Context capabilities                                                                   |                                                                                                                                                                                         |
| `hooks.getLicense.containerSecurityContext.seccompProfile`                     | Set get licence container's Security Context seccompProfile                                                                 |                                                                                                                                                                                         |
| `hooks.getLicense.configuration`                                               | Release Configuration file content                                                                                          |                                                                                                                                                                                         |
| `hooks.getLicense.configuration.bin_get-license`                               | The configuration of the script for getting the license                                                                     |                                                                                                                                                                                         |
| `hooks.getLicense.configuration.bin_get-license.path`                          | The path to the script for getting the license                                                                              | `bin/get-license.sh`                                                                                                                                                                    |
| `hooks.getLicense.configuration.bin_get-license.mode`                          | The access mode of the script for getting the license                                                                       | `755`                                                                                                                                                                                   |
| `hooks.getLicense.configuration.bin_get-license.content`                       | Content of the script for getting the license                                                                               | _omitted too long default content_                                                                                                                                                      |
| `hooks.getLicense.configuration.bin_install-license`                           | The configuration of the script for setting up license secret                                                               |                                                                                                                                                                                         |
| `hooks.getLicense.configuration.bin_install-license.path`                      | The path to the script for setting up license secret                                                                        | `bin/install-license.sh`                                                                                                                                                                |
| `hooks.getLicense.configuration.bin_install-license.mode`                      | The access mode of the script for setting up license secret                                                                 | `755`                                                                                                                                                                                   |
| `hooks.getLicense.configuration.bin_install-license.content`                   | Content of the script for setting up license secret                                                                         | _omitted too long default content_                                                                                                                                                      |
| `hooks.genSelfSigned.enabled`                                                  | set to true to support self-signed ket auto generation by using helm hook                                                   | `false`                                                                                                                                                                                 |
| `hooks.genSelfSigned.name`                                                     | Name of the resources that will be used during hook execution                                                               | `{{ include "release.name" . }}-self-signed`                                                                                                                                            |
| `hooks.genSelfSigned.deletePolicy`                                             | Helm hook delete policy                                                                                                     | `before-hook-creation,hook-succeeded`                                                                                                                                                   |
| `hooks.genSelfSigned.genCommand`                                               | The command for getting self-signed key, see hooks.genSelfSigned.configuration.bin_gen-self-signed                          | `["/opt/xebialabs/xl-release-server/bin/gen-self-signed.sh"]`                                                                                                                           |
| `hooks.genSelfSigned.installCommand`                                           | The command for creating the secret with the self-signed key, see hooks.genSelfSigned.configuration.bin_install-self-signed | `["/opt/xebialabs/xl-release-server/bin/install-self-signed.sh"]`                                                                                                                       |
| `hooks.genSelfSigned.image.registry`                                           | genSelfSigned hook container image registry                                                                                 | `docker.io`                                                                                                                                                                             |
| `hooks.genSelfSigned.image.repository`                                         | genSelfSigned hook container image repository                                                                               | `bitnami/kubectl`                                                                                                                                                                       |
| `hooks.genSelfSigned.image.tag`                                                | genSelfSigned hook container image tag                                                                                      | `1.28.7-debian-12-r3`                                                                                                                                                                   |
| `hooks.genSelfSigned.image.pullPolicy`                                         | genSelfSigned hook container image pull policy                                                                              | `IfNotPresent`                                                                                                                                                                          |
| `hooks.genSelfSigned.image.pullSecrets`                                        | Specify docker-registry secret names as an array                                                                            | `[]`                                                                                                                                                                                    |
| `hooks.genSelfSigned.containerSecurityContext.enabled`                         | Enabled generate self-signed containers' Security Context                                                                   | `true`                                                                                                                                                                                  |
| `hooks.genSelfSigned.containerSecurityContext.runAsNonRoot`                    | Set generate self-signed container's Security Context runAsNonRoot                                                          | `true`                                                                                                                                                                                  |
| `hooks.genSelfSigned.containerSecurityContext.allowPrivilegeEscalation`        | Set generate self-signed container's Security Context allowPrivilegeEscalation                                              | `false`                                                                                                                                                                                 |
| `hooks.genSelfSigned.containerSecurityContext.capabilities`                    | Set generate self-signed container's Security Context capabilities                                                          |                                                                                                                                                                                         |
| `hooks.genSelfSigned.containerSecurityContext.seccompProfile`                  | Set generate self-signed container's Security Context seccompProfile                                                        |                                                                                                                                                                                         |
| `hooks.genSelfSigned.configuration`                                            | Release Configuration file content                                                                                          |                                                                                                                                                                                         |
| `hooks.genSelfSigned.configuration.bin_gen-self-signed`                        | The configuration of the script for creating self signed key                                                                |                                                                                                                                                                                         |
| `hooks.genSelfSigned.configuration.bin_gen-self-signed.path`                   | The path to the script forcreating self signed key                                                                          | `bin/gen-self-signed.sh`                                                                                                                                                                |
| `hooks.genSelfSigned.configuration.bin_gen-self-signed.mode`                   | The access mode of the script for creating self signed key                                                                  | `755`                                                                                                                                                                                   |
| `hooks.genSelfSigned.configuration.bin_gen-self-signed.content`                | Content of the script for creating self signed key                                                                          | _omitted too long default content_                                                                                                                                                      |
| `hooks.genSelfSigned.configuration.bin_install-self-signed`                    | The configuration of the script for setting up self-signed key secret                                                       |                                                                                                                                                                                         |
| `hooks.genSelfSigned.configuration.bin_install-self-signed.path`               | The path to the script for setting up self-signed key secret                                                                | `bin/install-self-signed.sh`                                                                                                                                                            |
| `hooks.genSelfSigned.configuration.bin_install-self-signed.mode`               | The access mode of the script for setting up self-signed key secret                                                         | `755`                                                                                                                                                                                   |
| `hooks.genSelfSigned.configuration.bin_install-self-signed.content`            | Content of the script for setting up self-signed key secret                                                                 | _omitted too long default content_                                                                                                                                                      |
| `hooks.installReleaseRunner.enabled`                                           | set to true to support installation of the Remote Runner after Release installation                                         | `false`                                                                                                                                                                                 |
| `hooks.installReleaseRunner.name`                                              | Name of the resources that will be used during hook execution                                                               | `{{ include "release.name" . }}-install-runner`                                                                                                                                         |
| `hooks.installReleaseRunner.deletePolicy`                                      | Helm hook delete policy                                                                                                     | `before-hook-creation,hook-succeeded`                                                                                                                                                   |
| `hooks.installReleaseRunner.releaseName`                                       | The release name for Release Runner installation                                                                            | `""`                                                                                                                                                                                    |
| `hooks.installReleaseRunner.answersSecret`                                     | The secret that will be used during Release Runner installation                                                             | `""`                                                                                                                                                                                    |
| `hooks.installReleaseRunner.installCommand`                                    | The command for Release Runner installation                                                                                 | `["/opt/xebialabs/xl-client/xl","kube","upgrade","--skip-context-check","--local-repo","/opt/xebialabs/xl-op-blueprints","--answers","/opt/xebialabs/xl-client/generated_answers.yaml"]` |
| `hooks.installReleaseRunner.image.registry`                                    | getLicense hook container image registry                                                                                    | `docker.io`                                                                                                                                                                             |
| `hooks.installReleaseRunner.image.repository`                                  | getLicense hook container image repository                                                                                  | `xebialabsunsupported/xl-client`                                                                                                                                                        |
| `hooks.installReleaseRunner.image.tag`                                         | getLicense hook container image tag                                                                                         | `{{ .Chart.AppVersion }}`                                                                                                                                                               |
| `hooks.installReleaseRunner.image.pullPolicy`                                  | getLicense hook container image pull policy                                                                                 | `IfNotPresent`                                                                                                                                                                          |
| `hooks.installReleaseRunner.image.pullSecrets`                                 | Specify docker-registry secret names as an array                                                                            | `[]`                                                                                                                                                                                    |
| `hooks.installReleaseRunner.containerSecurityContext.enabled`                  | Enabled install RR containers' Security Context                                                                             | `true`                                                                                                                                                                                  |
| `hooks.installReleaseRunner.containerSecurityContext.runAsNonRoot`             | Set install RR container's Security Context runAsNonRoot                                                                    | `true`                                                                                                                                                                                  |
| `hooks.installReleaseRunner.containerSecurityContext.allowPrivilegeEscalation` | Set install RR container's Security Context allowPrivilegeEscalation                                                        | `false`                                                                                                                                                                                 |
| `hooks.installReleaseRunner.containerSecurityContext.capabilities`             | Set install RR container's Security Context capabilities                                                                    |                                                                                                                                                                                         |
| `hooks.installReleaseRunner.containerSecurityContext.seccompProfile`           | Set install RR container's Security Context seccompProfile                                                                  |                                                                                                                                                                                         |

### Release security parameters

| Name                                       | Description                                                                                                               | Value                                                                                                   |
| ------------------------------------------ | ------------------------------------------------------------------------------------------------------------------------- | ------------------------------------------------------------------------------------------------------- |
| `auth.adminPassword`                       | Admin password for Release. If user does not provide password, random 10 character alphanumeric string will be generated. | `nil`                                                                                                   |
| `auth.sessionStorage`                      | When enabled it will store session in the DB (it could degrade DB performance).                                           | `false`                                                                                                 |
| `ssl.enabled`                              | Enable SSL to be used on Release                                                                                          | `false`                                                                                                 |
| `ssl.keystorePassword`                     | Keystore password with SSL key.                                                                                           | `nil`                                                                                                   |
| `ssl.keystoreKeypassword`                  | Keystore key password with SSL key.                                                                                       | `nil`                                                                                                   |
| `ssl.keystoreType`                         | Keystore type, options pkcs12 or jks.                                                                                     | `pkcs12`                                                                                                |
| `ssl.keystore`                             | Keystore content in base64 format or it can reference the existing secret.                                                |                                                                                                         |
| `ssl.keystore.valueFrom.secretKeyRef.name` | Name of the secret where the keystore was stored.                                                                         | `{{ include "common.tplvalues.render" ( dict "value" .Values.hooks.genSelfSigned.name "context" $ ) }}` |
| `ssl.keystore.valueFrom.secretKeyRef.key`  | Name of the key in the secret where the keystore was stored.                                                              | `keystore.{{ .Values.ssl.keystoreType }}`                                                               |

### Release external resources

| Name                             | Description                                                                                                    | Value   |
| -------------------------------- | -------------------------------------------------------------------------------------------------------------- | ------- |
| `external.db.enabled`            | Enable external database                                                                                       | `false` |
| `external.db.main.url`           | Main database URL for Release                                                                                  | `""`    |
| `external.db.main.username`      | Main database username for Release                                                                             | `nil`   |
| `external.db.main.password`      | Main database password for Release                                                                             | `nil`   |
| `external.db.main.maxPoolSize`   | Main database max pool size for Release                                                                        | `""`    |
| `external.db.report.url`         | Report database URL for Release                                                                                | `""`    |
| `external.db.report.username`    | Report database username for Release                                                                           | `nil`   |
| `external.db.report.password`    | Report database password for Release                                                                           | `nil`   |
| `external.db.report.maxPoolSize` | Report database max pool size for Release                                                                      | `""`    |
| `external.mq.enabled`            | Enable external message queue                                                                                  | `false` |
| `external.mq.url`                | External message queue broker URL for Release                                                                  | `""`    |
| `external.mq.queueName`          | External message queue name for Release                                                                        | `""`    |
| `external.mq.username`           | External message queue broker username for Release                                                             | `nil`   |
| `external.mq.password`           | External message queue broker password for Release                                                             | `nil`   |
| `external.mq.queueType`          | Applies only for external rabbitmq message broker. Can be either classic(default) or quorum                    | `""`    |
| `external.mq.connector`          | Connector type depending on external message queue broker. Can be either rabbitmq-jms(default) or activemq-jms | `""`    |

### Release keystore and truststore parameters

| Name                    | Description                                                    | Value                                                                                                                                                                                                    |
| ----------------------- | -------------------------------------------------------------- | -------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- |
| `keystore.passphrase`   | Set passphrase for the keystore                                | `nil`                                                                                                                                                                                                    |
| `keystore.keystore`     | Use repository-keystore.jceks files content ecoded with base64 | `nil`                                                                                                                                                                                                    |
| `truststore.type`       | Type of truststore, possible value jks or jceks or pkcs12      | `pkcs12`                                                                                                                                                                                                 |
| `truststore.password`   | Truststore password                                            | `nil`                                                                                                                                                                                                    |
| `truststore.truststore` | Truststore file base64 encoded                                 | `{}`                                                                                                                                                                                                     |
| `truststore.params`     | Truststore params in the command line                          | `{{- if .Values.truststore.truststore }} -Djavax.net.ssl.trustStore=$(TRUSTSTORE) -Djavax.net.ssl.trustStorePassword=$(TRUSTSTORE_PASSWORD) -Djavax.net.ssl.trustStoreType=$(TRUSTSTORE_TYPE){{- end }}` |

### Release Network Policy configuration

| Name                            | Description                                                                          | Value   |
| ------------------------------- | ------------------------------------------------------------------------------------ | ------- |
| `networkPolicy.enabled`         | Enable creation of NetworkPolicy resources                                           | `false` |
| `networkPolicy.allowExternal`   | Don't require client label for connections                                           | `true`  |
| `networkPolicy.additionalRules` | Additional NetworkPolicy Ingress "from" rules to set. Note that all rules are OR-ed. | `[]`    |

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

### Common resources parameters

| Name                | Description                                                                             | Value           |
| ------------------- | --------------------------------------------------------------------------------------- | --------------- |
| `nameOverride`      | String to partially override release.fullname template (will maintain the release name) | `""`            |
| `fullnameOverride`  | String to fully override release.fullname template                                      | `""`            |
| `namespaceOverride` | String to fully override common.names.namespace                                         | `""`            |
| `kubeVersion`       | Force target Kubernetes version (using Helm capabilities if not set)                    | `""`            |
| `clusterDomain`     | Kubernetes Cluster Domain                                                               | `cluster.local` |
| `extraDeploy`       | Array of extra objects to deploy with the Release                                       | `[]`            |
| `commonAnnotations` | Annotations to add to all deployed objects                                              | `{}`            |
| `commonLabels`      | Labels to add to all deployed objects                                                   | `{}`            |

### Release debug parameters

| Name                        | Description                                                                                   | Value                                                                                                                        |
| --------------------------- | --------------------------------------------------------------------------------------------- | ---------------------------------------------------------------------------------------------------------------------------- |
| `diagnosticMode.enabled`    | Enable diagnostic mode (all probes will be disabled and the command will be overridden)       | `false`                                                                                                                      |
| `diagnosticMode.command`    | Command to override all containers in the deployment                                          | `["/opt/xebialabs/tini"]`                                                                                                    |
| `diagnosticMode.args`       | Args to override all containers in the deployment                                             | `["--","sleep","infinity"]`                                                                                                  |
| `debugMode.enabled`         | Enable debug mode (it starts all process with debug agent)                                    | `false`                                                                                                                      |
| `debugMode.remoteJvmParams` | Agent lib configuration line with port. Do port forwarding to the port you would like to use. | `{{- if .Values.debugMode.enabled }} -agentlib:jdwp=transport=dt_socket,server=y,suspend=n,address=localhost:8001{{- end }}` |

### Release DNS parameters

| Name          | Description                 | Value |
| ------------- | --------------------------- | ----- |
| `hostAliases` | Deployment pod host aliases | `[]`  |
| `dnsPolicy`   | DNS Policy for pod          | `""`  |
| `dnsConfig`   | DNS Configuration pod       | `{}`  |

### Release runtime parameters

| Name                                                          | Description                                                                                        | Value                                                               |
| ------------------------------------------------------------- | -------------------------------------------------------------------------------------------------- |---------------------------------------------------------------------|
| `jvmArgs`                                                     | Release JVM arguments                                                                              | `""`                                                                |
| `command`                                                     | Override default container command (useful when using custom images)                               | `["/opt/xebialabs/tini"]`                                           |
| `args`                                                        | Override default container args (useful when using custom images)                                  | `["--","/opt/xebialabs/xl-release-server/bin/run-in-container.sh"]` |
| `lifecycleHooks`                                              | Overwrite livecycle for the Release container(s) to automate configuration before or after startup | `{}`                                                                |
| `terminationGracePeriodSeconds`                               | Default duration in seconds k8s waits for container to exit before sending kill signal.            | `200`                                                               |
| `extraEnvVars`                                                | Extra environment variables to add to Release pods                                                 | `[]`                                                                |
| `extraEnvVarsCM`                                              | Name of existing ConfigMap containing extra environment variables                                  | `""`                                                                |
| `extraEnvVarsSecret`                                          | Name of existing Secret containing extra environment variables (in case of sensitive data)         | `""`                                                                |
| `containerPorts.releaseHttp`                                  | Release HTTP port value exposed on the container                                                   | `5516`                                                              |
| `containerPorts.releaseHttps`                                 | Release HTTPS port value exposed on the container                                                  | `5543`                                                              |
| `extraContainerPorts`                                         | Extra ports to be included in container spec, primarily informational                              | `[]`                                                                |
| `configuration`                                               | Release Configuration file content: required cluster configuration                                 |                                                                     |
| `configuration.default-conf_xl-release-conf-template`         | The configuration for the xl-release.conf.template file                                            |                                                                     |
| `configuration.default-conf_xl-release-conf-template.path`    | The path for the xl-release.conf.template file                                                     | `default-conf/xl-release.conf.template`                             |
| `configuration.default-conf_xl-release-conf-template.mode`    | The access mode for the xl-release.conf.template file                                              | `660`                                                               |
| `configuration.default-conf_xl-release-conf-template.content` | Content of the xl-release.conf.template file                                                       | _omitted too long default content_                                  |
| `extraConfiguration`                                          | Configuration file content: extra configuration to be appended to Release configuration            | `{}`                                                                |
| `extraVolumeMounts`                                           | Optionally specify extra list of additional volumeMounts                                           | `[]`                                                                |
| `extraVolumes`                                                | Optionally specify extra list of additional volumes .                                              | `[]`                                                                |
| `extraSecrets`                                                | Optionally specify extra secrets to be created by the chart.                                       | `{}`                                                                |
| `extraSecretsPrependReleaseName`                              | Set this flag to true if extraSecrets should be created with <release-name> prepended.             | `false`                                                             |

### Release Image parameters

| Name                | Description                                        | Value                             |
| ------------------- | -------------------------------------------------- | --------------------------------- |
| `image.registry`    | Release image registry                             | `docker.io`                       |
| `image.repository`  | Release image repository                           | `xebialabsunsupported/xl-release` |
| `image.tag`         | Release image tag (immutable tags are recommended) | `{{ .Chart.AppVersion }}`         |
| `image.pullPolicy`  | Release image pull policy                          | `IfNotPresent`                    |
| `image.pullSecrets` | Specify docker-registry secret names as an array   | `[]`                              |

### Ingress parameters

| Name                       | Description                                                                                                                      | Value                    |
| -------------------------- | -------------------------------------------------------------------------------------------------------------------------------- | ------------------------ |
| `ingress.enabled`          | Enable ingress resource for Management console                                                                                   | `false`                  |
| `ingress.path`             | Path for the default host. You may need to set this to '/*' in order to use this with ALB ingress controllers.                   | `/`                      |
| `ingress.pathType`         | Ingress path type                                                                                                                | `ImplementationSpecific` |
| `ingress.hostname`         | Default host for the ingress resource                                                                                            | `""`                     |
| `ingress.annotations`      | Additional annotations for the Ingress resource. To enable certificate autogeneration, place here your cert-manager annotations. | `nil`                    |
| `ingress.tls`              | Enable TLS configuration for the hostname defined at `ingress.hostname` parameter                                                | `false`                  |
| `ingress.selfSigned`       | Set this to true in order to create a TLS secret for this ingress record                                                         | `false`                  |
| `ingress.extraHosts`       | The list of additional hostnames to be covered with this ingress record.                                                         | `[]`                     |
| `ingress.extraPaths`       | An array with additional arbitrary paths that may need to be added to the ingress under the main host                            | `[]`                     |
| `ingress.extraRules`       | The list of additional rules to be added to this ingress record. Evaluated as a template                                         | `[]`                     |
| `ingress.extraTls`         | The tls configuration for additional hostnames to be covered with this ingress record.                                           | `[]`                     |
| `ingress.secrets`          | Custom TLS certificates as secrets                                                                                               | `[]`                     |
| `ingress.ingressClassName` | IngressClass that will be be used to implement the Ingress (Kubernetes 1.18+)                                                    | `""`                     |

### OpenShift Route parameters

| Name                                      | Description                                                                                        | Value   |
| ----------------------------------------- | -------------------------------------------------------------------------------------------------- | ------- |
| `route.enabled`                           | Enable route resource                                                                              | `false` |
| `route.path`                              | Path for the default host.                                                                         | `/`     |
| `route.hostname`                          | Default host for the route resource                                                                | `""`    |
| `route.annotations`                       | Additional annotations for the route resource.                                                     |         |
| `route.tls`                               | Tls configuration                                                                                  |         |
| `route.tls.enabled`                       | Enable the route TLS configuration                                                                 | `false` |
| `route.tls.secretName`                    | Name of the secret to use with Route TLS setup                                                     | `""`    |
| `route.tls.key`                           | key in PEM-encoded format                                                                          | `""`    |
| `route.tls.certificate`                   | certificate in PEM-encoded format                                                                  | `""`    |
| `route.tls.caCertificate`                 | CA certificate in a PEM-encoded format                                                             | `""`    |
| `route.tls.destinationCACertificate`      | destination CA certificate in a PEM-encoded format (the Release certificate)                       | `""`    |
| `route.tls.insecureEdgeTerminationPolicy` | Redirect HTTP to HTTPS. The only valid values are None, Redirect, or empty for disabled.           | `""`    |
| `route.tls.termination`                   | The accepted values are edge, passthrough and reencrypt.                                           | `edge`  |
| `route.tls.selfSigned`                    | if set to `true` the key and certificate will be auto generated and set in the route configuration | `false` |

### RBAC parameters

| Name                                          | Description                                                                                | Value  |
| --------------------------------------------- | ------------------------------------------------------------------------------------------ | ------ |
| `serviceAccount.create`                       | Enable creation of ServiceAccount for Release pods                                         | `true` |
| `serviceAccount.name`                         | Name of the created serviceAccount                                                         | `""`   |
| `serviceAccount.automountServiceAccountToken` | Auto-mount the service account token in the pod                                            | `true` |
| `serviceAccount.annotations`                  | Annotations for service account. Evaluated as a template. Only used if `create` is `true`. | `{}`   |
| `rbac.create`                                 | Whether RBAC rules should be created                                                       | `true` |

### Persistence parameters

| Name                                              | Description                                      | Value                                          |
| ------------------------------------------------- | ------------------------------------------------ | ---------------------------------------------- |
| `persistence.enabled`                             | Enable Release data persistence using PVC        | `true`                                         |
| `persistence.single`                              | Enable Release data to use single PVC            | `true`                                         |
| `persistence.storageClass`                        | PVC Storage Class for Release data volume        | `""`                                           |
| `persistence.selector`                            | Selector to match an existing Persistent Volume  | `{}`                                           |
| `persistence.accessModes`                         | PVC Access Modes for Release data volume         | `["ReadWriteMany"]`                            |
| `persistence.existingClaim`                       | Provide an existing PersistentVolumeClaims       | `""`                                           |
| `persistence.size`                                | PVC Storage Request for Release data volume      | `8Gi`                                          |
| `persistence.annotations`                         | Persistence annotations. Evaluated as a template |                                                |
| `persistence.annotations.helm.sh/resource-policy` | Persistence annotation for keeping created PVCs  | `keep`                                         |
| `persistence.paths`                               | mounted paths for the Release                    | `["/opt/xebialabs/xl-release-server/reports"]` |

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

| Name                                                | Description                                                                                                              | Value           |
| --------------------------------------------------- | ------------------------------------------------------------------------------------------------------------------------ | --------------- |
| `replicaCount`                                      | Number of Release replicas to deploy                                                                                     | `3`             |
| `schedulerName`                                     | Use an alternate scheduler, e.g. "stork".                                                                                | `""`            |
| `podManagementPolicy`                               | Pod management policy                                                                                                    | `OrderedReady`  |
| `podLabels`                                         | Release Pod labels. Evaluated as a template                                                                              | `{}`            |
| `podAnnotations`                                    | Release Pod annotations. Evaluated as a template                                                                         | `{}`            |
| `updateStrategy.type`                               | Update strategy type for Release statefulset                                                                             | `RollingUpdate` |
| `statefulsetLabels`                                 | Release statefulset labels. Evaluated as a template                                                                      | `{}`            |
| `statefulsetAnnotations`                            | Release statefulset annotations. Evaluated as a template                                                                 | `{}`            |
| `priorityClassName`                                 | Name of the priority class to be used by Release pods, priority class needs to be created beforehand                     | `""`            |
| `podAffinityPreset`                                 | Pod affinity preset. Ignored if `affinity` is set. Allowed values: `soft` or `hard`                                      | `""`            |
| `podAntiAffinityPreset`                             | Pod anti-affinity preset. Ignored if `affinity` is set. Allowed values: `soft` or `hard`                                 | `soft`          |
| `nodeAffinityPreset.type`                           | Node affinity preset type. Ignored if `affinity` is set. Allowed values: `soft` or `hard`                                | `""`            |
| `nodeAffinityPreset.key`                            | Node label key to match Ignored if `affinity` is set.                                                                    | `""`            |
| `nodeAffinityPreset.values`                         | Node label values to match. Ignored if `affinity` is set.                                                                | `[]`            |
| `affinity`                                          | Affinity for pod assignment. Evaluated as a template                                                                     | `{}`            |
| `nodeSelector`                                      | Node labels for pod assignment. Evaluated as a template                                                                  | `{}`            |
| `tolerations`                                       | Tolerations for pod assignment. Evaluated as a template                                                                  | `[]`            |
| `topologySpreadConstraints`                         | Topology Spread Constraints for pod assignment spread across your cluster among failure-domains. Evaluated as a template | `[]`            |
| `podSecurityContext.enabled`                        | Enable Release pod's Security Context                                                                                    | `true`          |
| `podSecurityContext.runAsUser`                      | Set Release pod's Security Context runAsUser                                                                             | `10001`         |
| `podSecurityContext.fsGroup`                        | Set Release pod's Security Context fsGroup                                                                               | `10001`         |
| `containerSecurityContext.enabled`                  | Enabled Release containers' Security Context                                                                             | `true`          |
| `containerSecurityContext.runAsNonRoot`             | Set Release container's Security Context runAsNonRoot                                                                    | `true`          |
| `containerSecurityContext.allowPrivilegeEscalation` | Set Release container's Security Context allowPrivilegeEscalation                                                        | `false`         |
| `containerSecurityContext.capabilities`             | Set Release container's Security Context capabilities                                                                    |                 |
| `containerSecurityContext.seccompProfile`           | Set Release container's Security Context seccompProfile                                                                  |                 |
| `securityContextConstraints.enabled`                | Enabled SecurityContextConstraints for Release (only on Openshift)                                                       | `true`          |
| `resources.limits`                                  | The resources limits for Release containers                                                                              | `{}`            |
| `resources.requests`                                | The requested resources for Release containers                                                                           | `{}`            |
| `health.enabled`                                    | Enable probes                                                                                                            | `true`          |
| `health.periodScans`                                | Period seconds for probe                                                                                                 | `10`            |
| `health.probeFailureThreshold`                      | Failure threshold for probe                                                                                              | `12`            |
| `health.probesLivenessTimeout`                      | Initial delay seconds for livenessProbe                                                                                  | `60`            |
| `health.probesReadinessTimeout`                     | Initial delay seconds for readinessProbe                                                                                 | `60`            |
| `initContainers`                                    | Add init containers to the Release pod                                                                                   | `[]`            |
| `sidecars`                                          | Add sidecar containers to the Release pod                                                                                | `[]`            |

### Release init Container parameters

| Name                                                        | Description                                                                                                                       | Value                              |
| ----------------------------------------------------------- | --------------------------------------------------------------------------------------------------------------------------------- |------------------------------------|
| `volumePermissions.enabled`                                 | Enable init container that changes the owner and group of the persistent volume(s) mountpoint to `runAsUser:fsGroup`              | `false`                            |
| `volumePermissions.image.registry`                          | Init container volume-permissions image registry                                                                                  | `docker.io`                        |
| `volumePermissions.image.repository`                        | Init container volume-permissions image repository                                                                                | `bitnami/os-shell`                 |
| `volumePermissions.image.tag`                               | Init container volume-permissions image tag                                                                                       | `12-debian-12-r16`                 |
| `volumePermissions.image.digest`                            | Init container volume-permissions image digest in the way sha256:aa.... Please note this parameter, if set, will override the tag | `""`                               |
| `volumePermissions.image.pullPolicy`                        | Init container volume-permissions image pull policy                                                                               | `IfNotPresent`                     |
| `volumePermissions.image.pullSecrets`                       | Specify docker-registry secret names as an array                                                                                  | `[]`                               |
| `volumePermissions.script`                                  | Script for changing the owner and group of the persistent volume(s). Paths are declared in the 'paths' variable.                  | _omitted too long default content_ |
| `volumePermissions.resources.limits`                        | Init container volume-permissions resource limits                                                                                 | `{}`                               |
| `volumePermissions.resources.requests`                      | Init container volume-permissions resource requests                                                                               | `{}`                               |
| `volumePermissions.containerSecurityContext.runAsUser`      | User ID for the init container                                                                                                    | `0`                                |
| `volumePermissions.containerSecurityContext.runAsGroup`     | Group ID for the init container                                                                                                   | `0`                                |
| `volumePermissions.containerSecurityContext.runAsNonRoot`   | Set volume permissions init container's Security Context runAsNonRoot                                                             | `false`                            |
| `volumePermissions.containerSecurityContext.seccompProfile` | Set volume permissions init container's Security Context seccompProfile                                                           |                                    |

### Release Pod Disruption Budget parameters

| Name                 | Description                                                    | Value   |
| -------------------- | -------------------------------------------------------------- | ------- |
| `pdb.create`         | Enable/disable a Pod Disruption Budget creation                | `false` |
| `pdb.minAvailable`   | Minimum number/percentage of pods that should remain scheduled | `1`     |
| `pdb.maxUnavailable` | Maximum number/percentage of pods that may be made unavailable | `""`    |

### Release Busy-box parameters

| Name                        | Description                                      | Value             |
| --------------------------- | ------------------------------------------------ | ----------------- |
| `busyBox.image.registry`    | busyBox container image registry                 | `docker.io`       |
| `busyBox.image.repository`  | busyBox container image repository               | `library/busybox` |
| `busyBox.image.tag`         | busyBox container image tag                      | `stable`          |
| `busyBox.image.pullPolicy`  | busyBox container image pull policy              | `IfNotPresent`    |
| `busyBox.image.pullSecrets` | Specify docker-registry secret names as an array | `[]`              |

### Ingress HAProxy

| Name                                      | Description                                                | Value          |
| ----------------------------------------- | ---------------------------------------------------------- | -------------- |
| `haproxy-ingress.install`                 | Enable Haproxy Ingress helm subchart installation          | `false`        |
| `haproxy-ingress.controller.ingressClass` | Name of the ingress class to route through this controller | `haproxy-dair` |
| `haproxy-ingress.controller.service.type` | Kubernetes Service type for Controller                     | `LoadBalancer` |

### Ingress Nginx

| Name                                                            | Description                                                           | Value                       |
| --------------------------------------------------------------- | --------------------------------------------------------------------- | --------------------------- |
| `nginx-ingress-controller.install`                              | Enable NGINX Ingress Controller helm subchart installation            | `false`                     |
| `nginx-ingress-controller.image.tag`                            | NGINX Ingress Controller image tag (immutable tags are recommended)   | `1.9.6-debian-12-r8`        |
| `nginx-ingress-controller.defaultBackend.image.tag`             | Default backend image tag (immutable tags are recommended)            | `1.25.4-debian-12-r3`       |
| `nginx-ingress-controller.extraArgs`                            | Additional command line arguments to pass to nginx-ingress-controller |                             |
| `nginx-ingress-controller.extraArgs.ingress-class`              | Name of the IngressClass resource                                     | `nginx-dair`                |
| `nginx-ingress-controller.ingressClassResource.name`            | Name of the IngressClass resource                                     | `nginx-dair`                |
| `nginx-ingress-controller.ingressClassResource.controllerClass` | IngressClass identifier for the controller                            | `k8s.io/ingress-nginx-dair` |
| `nginx-ingress-controller.replicaCount`                         | Desired number of Controller pods                                     | `1`                         |

### Traffic exposure parameters

| Name                                    | Description                            | Value          |
| --------------------------------------- | -------------------------------------- | -------------- |
| `nginx-ingress-controller.service.type` | Kubernetes Service type for Controller | `LoadBalancer` |

### Postgresql

| Name                   | Description                                           | Value                 |
| ---------------------- | ----------------------------------------------------- | --------------------- |
| `postgresql.install`   | Enable PostgreSQL helm subchart installation          | `true`                |
| `postgresql.image.tag` | PostgreSQL image tag (immutable tags are recommended) | `15.6.0-debian-12-r7` |

### PostgreSQL Primary parameters

| Name                                                    | Description                                                                             | Value                                                      |
| ------------------------------------------------------- | --------------------------------------------------------------------------------------- |------------------------------------------------------------|
| `postgresql.primary.initdb.scriptsSecret`               | Secret with scripts to be run at first boot (in case it contains sensitive information) | `{{ include "postgresql.v1.primary.fullname" . }}-release` |
| `postgresql.primary.extendedConfiguration`              | Extended PostgreSQL Primary configuration (appended to main or default configuration)   | `max_connections = 150`                                    |
| `postgresql.primary.persistence.enabled`                | Enable PostgreSQL Primary data persistence using PVC                                    | `true`                                                     |
| `postgresql.primary.persistence.accessModes`            | PVC Access Mode for PostgreSQL volume                                                   | `["ReadWriteOnce"]`                                        |
| `postgresql.primary.persistence.storageClass`           | PVC Storage Class for PostgreSQL Primary data volume                                    | `""`                                                       |
| `postgresql.primary.persistence.size`                   | PVC Storage Request for PostgreSQL volume                                               | `8Gi`                                                      |
| `postgresql.primary.persistence.existingClaim`          | Name of an existing PVC to use                                                          | `""`                                                       |
| `postgresql.primary.resources.requests.memory`          | The requested memory for the PostgreSQL Primary containers                              | `256Mi`                                                    |
| `postgresql.primary.resources.requests.cpu`             | The requested cpu for the PostgreSQL Primary containers                                 | `250m`                                                     |
| `postgresql.primary.service.ports.postgresql`           | PostgreSQL service port                                                                 | `5432`                                                     |
| `postgresql.primary.service.type`                       | Kubernetes Service type                                                                 | `ClusterIP`                                                |
| `postgresql.primary.securityContextConstraints.enabled` | Enabled SecurityContextConstraints for Postgresql (only on Openshift)                   | `true`                                                     |

### Postgresql Authentication parameters

| Name                                 | Description                                                                                            | Value      |
| ------------------------------------ | ------------------------------------------------------------------------------------------------------ | ---------- |
| `postgresql.auth.enablePostgresUser` | Assign a password to the "postgres" admin user. Otherwise, remote access will be blocked for this user | `true`     |
| `postgresql.auth.username`           | Name for a custom user to create                                                                       | `postgres` |
| `postgresql.auth.postgresPassword`   | Password for the "postgres" admin user. Ignored if `auth.existingSecret` is provided                   | `postgres` |
| `postgresql.serviceAccount.create`   | Enable creation of ServiceAccount for PostgreSQL pod                                                   | `true`     |

### Postgresql Volume Permissions parameters

| Name                                     | Description                                                                     | Value              |
| ---------------------------------------- | ------------------------------------------------------------------------------- | ------------------ |
| `postgresql.volumePermissions.enabled`   | Enable init container that changes the owner and group of the persistent volume | `true`             |
| `postgresql.volumePermissions.image.tag` | Init container volume-permissions image tag (immutable tags are recommended)    | `12-debian-12-r16` |

### RabbitMQ

| Name                                     | Description                                                                                         | Value                                             |
| ---------------------------------------- | --------------------------------------------------------------------------------------------------- | ------------------------------------------------- |
| `rabbitmq.install`                       | Enable Rabbitmq helm subchart installation                                                          | `true`                                            |
| `rabbitmq.image.tag`                     | RabbitMQ image tag (immutable tags are recommended)                                                 | `3.12.13-debian-12-r2`                            |
| `rabbitmq.clustering.forceBoot`          | Force boot of an unexpectedly shut down cluster (in an unexpected order).                           | `true`                                            |
| `rabbitmq.replicaCount`                  | Number of RabbitMQ replicas to deploy                                                               | `3`                                               |
| `rabbitmq.auth.username`                 | RabbitMQ application username                                                                       | `guest`                                           |
| `rabbitmq.auth.password`                 | RabbitMQ application password                                                                       | `guest`                                           |
| `rabbitmq.auth.existingErlangSecret`     | Existing secret with RabbitMQ Erlang cookie (must contain a value for `rabbitmq-erlang-cookie` key) | `{{ include "common.names.fullname" . }}-release` |
| `rabbitmq.extraPlugins`                  | Extra plugins to enable (single string containing a space-separated list)                           | `rabbitmq_amqp1_0, rabbitmq_jms_topic_exchange`   |
| `rabbitmq.loadDefinition.enabled`        | Enable loading a RabbitMQ definitions file to configure RabbitMQ                                    | `true`                                            |
| `rabbitmq.loadDefinition.file`           | Name of the definitions file                                                                        | `/app/release_load_definition.json`               |
| `rabbitmq.loadDefinition.existingSecret` | Existing secret with the load definitions file                                                      | `{{ include "common.names.fullname" . }}-release` |
| `rabbitmq.extraConfiguration`            | Configuration file content: extra configuration to be appended to RabbitMQ configuration            | `""`                                              |

### RabbitMQ persistence parameters

| Name                                                         | Description                                                                       | Value               |
| ------------------------------------------------------------ | --------------------------------------------------------------------------------- | ------------------- |
| `rabbitmq.persistence.enabled`                               | Enable RabbitMQ data persistence using PVC                                        | `true`              |
| `rabbitmq.persistence.accessModes`                           | PVC Access Modes for RabbitMQ data volume                                         | `["ReadWriteOnce"]` |
| `rabbitmq.persistence.storageClass`                          | PVC Storage Class for RabbitMQ data volume                                        | `""`                |
| `rabbitmq.persistence.size`                                  | PVC Storage Request for RabbitMQ data volume                                      | `8Gi`               |
| `rabbitmq.containerSecurityContext.allowPrivilegeEscalation` | Set volume permissions init container's Security Context allowPrivilegeEscalation | `false`             |
| `rabbitmq.containerSecurityContext.capabilities`             | Set volume permissions init container's Security Context capabilities             |                     |
| `rabbitmq.containerSecurityContext.seccompProfile`           | Set volume permissions init container's Security Context seccompProfile           |                     |
| `rabbitmq.securityContextConstraints.enabled`                | Enabled SecurityContextConstraints for Rabbitmq (only on Openshift)               | `true`              |

### RabbitMQ Exposure parameters

| Name                    | Description             | Value       |
| ----------------------- | ----------------------- | ----------- |
| `rabbitmq.service.type` | Kubernetes Service type | `ClusterIP` |

### RabbitMQ Init Container Parameters

| Name                                                                 | Description                                                                                                          | Value              |
| -------------------------------------------------------------------- | -------------------------------------------------------------------------------------------------------------------- | ------------------ |
| `rabbitmq.volumePermissions.enabled`                                 | Enable init container that changes the owner and group of the persistent volume(s) mountpoint to `runAsUser:fsGroup` | `true`             |
| `rabbitmq.volumePermissions.image.tag`                               | Init container volume-permissions image tag (immutable tags are recommended)                                         | `12-debian-12-r16` |
| `rabbitmq.volumePermissions.containerSecurityContext.runAsUser`      | User ID for the init container                                                                                       | `0`                |
| `rabbitmq.volumePermissions.containerSecurityContext.runAsGroup`     | Group ID for the init container                                                                                      | `0`                |
| `rabbitmq.volumePermissions.containerSecurityContext.runAsNonRoot`   | Set volume permissions init container's Security Context runAsNonRoot                                                | `false`            |
| `rabbitmq.volumePermissions.containerSecurityContext.seccompProfile` | Set volume permissions init container's Security Context seccompProfile                                              |                    |
