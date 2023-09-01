# dai-release

![Version: 23.1.0-1026.113](https://img.shields.io/badge/Version-23.1.0--1026.113-informational?style=flat-square) ![AppVersion: v22.3.1](https://img.shields.io/badge/AppVersion-v22.3.1-informational?style=flat-square)

A Helm chart for Digital.ai Release

**Homepage:** <https://github.com/xebialabs/xl-release-kubernetes-helm-chart>

## Source Code

* <https://github.com/xebialabs/xl-release-kubernetes-helm-chart>
* <https://github.com/xebialabs/xl-release>

## Requirements

| Repository | Name | Version |
|------------|------|---------|
| https://charts.bitnami.com/bitnami | common | 1.17.X |
| https://charts.bitnami.com/bitnami | nginx-ingress-controller | 9.3.19 |
| https://charts.bitnami.com/bitnami | postgresql | 12.1.0 |
| https://charts.bitnami.com/bitnami | rabbitmq | 11.1.1 |
| https://codecentric.github.io/helm-charts | keycloak | 18.3.0 |
| https://haproxy-ingress.github.io/charts | haproxy-ingress | 0.13.9 |

## Values

| Key | Type | Default | Description |
|-----|------|---------|-------------|
| affinity | object | `{}` |  |
| args | list | `[]` |  |
| auth.adminPassword | string | `""` |  |
| busyBox.image.pullPolicy | string | `"IfNotPresent"` |  |
| busyBox.image.pullSecrets | list | `[]` |  |
| busyBox.image.registry | string | `"docker.io"` |  |
| busyBox.image.repository | string | `"library/busybox"` |  |
| busyBox.image.tag | string | `"stable"` |  |
| clusterDomain | string | `"cluster.local"` |  |
| command | list | `[]` |  |
| commonAnnotations | object | `{}` |  |
| commonLabels | object | `{}` |  |
| configuration | string | `"xl {\n  cluster {\n    # mode: \"default\", \"hot-standby\", \"full\"\n    mode = ${XL_CLUSTER_MODE}\n    name = \"xl-release_cluster\"\n    akka {\n      loglevel = \"INFO\"\n      actor.debug.receive = off\n      remote {\n          log-received-messages = off\n          log-sent-messages = off\n      }\n    }\n  }\n\n  license {\n    kind = ${XL_LICENSE_KIND}\n    product = \"xl-release\"\n  }\n\n  database {\n    db-driver-classname=\"${XL_DB_DRIVER}\"\n    db-password=\"${XL_DB_PASSWORD}\"\n    db-url=\"${XL_DB_URL}\"\n    db-username=${XL_DB_USERNAME}\n    max-pool-size=10\n  }\n\n  # TODO Release does not support (H2) running in one schema.\n  reporting {\n    db-driver-classname=\"${XL_DB_DRIVER}\"\n    db-password=\"${XL_REPORT_DB_PASSWORD}\"\n    db-url=\"${XL_REPORT_DB_URL}\"\n    db-username=${XL_REPORT_DB_USERNAME}\n  }\n\n  # Task queue\n  queue {\n    embedded=${ENABLE_EMBEDDED_QUEUE}\n    password=\"${XLR_TASK_QUEUE_PASSWORD}\"\n    queueName=\"${XLR_TASK_QUEUE_NAME}\"\n    url=\"${XLR_TASK_QUEUE_URL}\"\n    username=\"${XLR_TASK_QUEUE_USERNAME}\"\n  }\n\n  metrics {\n    enabled = ${XL_METRICS_ENABLED}\n  }\n\n  security {\n    auth {\n      providers {\n        oidc {\n          {{- if .Values.oidc.external }}\n          clientId={{ .Values.oidc.clientId | quote }}\n          clientSecret={{ .Values.oidc.clientSecret | quote }}\n          {{- if .Values.oidc.clientAuthMethod }}\n          clientAuthMethod={{ .Values.oidc.clientAuthMethod | quote }}\n          {{- end }}\n          {{- if .Values.oidc.clientAuthJwt.enable }}\n          clientAuthJwt {\n              jwsAlg={{ default \"\" .Values.oidc.clientAuthJwt.jwsAlg | quote }}\n              tokenKeyId={{ default \"\" .Values.oidc.clientAuthJwt.tokenKeyId | quote }}\n              {{- if .Values.oidc.clientAuthJwt.keyStore.enable }}\n              keyStore {\n                  path={{ default \"\" .Values.oidc.clientAuthJwt.keyStore.path | quote }}\n                  password={{ default \"\" .Values.oidc.clientAuthJwt.keyStore.password | quote }}\n                  type={{ default \"\" .Values.oidc.clientAuthJwt.keyStore.type | quote }}\n              }\n              {{- end }}\n              {{- if .Values.oidc.clientAuthJwt.key.enable }}\n              key {\n                  alias={{ default \"\" .Values.oidc.clientAuthJwt.key.alias | quote }}\n                  password={{ default \"\" .Values.oidc.clientAuthJwt.key.password | quote }}\n              }\n              {{- end }}\n          }\n          {{- end }}\n          issuer={{ .Values.oidc.issuer | quote }}\n          keyRetrievalUri={{ default \"\" .Values.oidc.keyRetrievalUri | quote }}\n          accessTokenUri={{ default \"\" .Values.oidc.accessTokenUri | quote }}\n          userAuthorizationUri={{ default \"\" .Values.oidc.userAuthorizationUri | quote }}\n          logoutUri={{ default \"\" .Values.oidc.logoutUri | quote }}\n          redirectUri={{ .Values.oidc.redirectUri | quote }}\n          postLogoutRedirectUri={{ .Values.oidc.postLogoutRedirectUri | quote }}\n          userNameClaim={{ default \"\" .Values.oidc.userNameClaim | quote }}\n          fullNameClaim={{ default \"\" .Values.oidc.fullNameClaim | quote }}\n          emailClaim={{ default \"\" .Values.oidc.emailClaim | quote }}\n          {{- if .Values.oidc.externalIdClaim }}\n          externalIdClaim={{ .Values.oidc.externalIdClaim | quote }}\n          {{- end }}\n          rolesClaim={{ default \"\" .Values.oidc.rolesClaim | quote }}\n          {{- if .Values.oidc.scopes }}\n          scopes={{ .Values.oidc.scopes }}\n          {{- else }}\n          scopes=[\"openid\"]\n          {{- end }}\n          {{- if .Values.oidc.idTokenJWSAlg }}\n          idTokenJWSAlg={{ .Values.oidc.idTokenJWSAlg | quote }}\n          {{- end }}\n          {{- if .Values.oidc.accessToken.enable }}\n          access-token {\n              issuer={{ default \"\" .Values.oidc.accessToken.issuer | quote }}\n              audience={{ default \"\" .Values.oidc.accessToken.audience | quote }}\n              keyRetrievalUri={{ default \"\" .Values.oidc.accessToken.keyRetrievalUri | quote }}\n              jwsAlg={{ default \"\" .Values.oidc.accessToken.jwsAlg | quote }}\n              secretKey={{ default \"\" .Values.oidc.accessToken.secretKey | quote }}\n              }\n          {{- end }}\n          {{- if .Values.oidc.proxyHost }}\n          proxyHost={{ .Values.oidc.proxyHost | quote }}\n          {{- end }}\n          {{- if .Values.oidc.proxyPort }}\n          proxyPort={{ .Values.oidc.proxyPort | quote }}\n          {{- end }}\n          {{- else }}\n          clientId=\"release\"\n          clientSecret=\"ab2088f6-2251-4233-9b22-e24db6a67483\"\n          {{- range .Values.keycloak.ingress.rules }}\n          issuer=\"http{{ if $.Values.keycloak.ingress.tls }}s{{ end }}://{{ .host }}/auth/realms/digitalai-platform\"\n          keyRetrievalUri=\"http{{ if $.Values.keycloak.ingress.tls }}s{{ end }}://{{ .host }}/auth/realms/digitalai-platform/protocol/openid-connect/certs\"\n          accessTokenUri=\"http{{ if $.Values.keycloak.ingress.tls }}s{{ end }}://{{ .host }}/auth/realms/digitalai-platform/protocol/openid-connect/token\"\n          userAuthorizationUri=\"http{{ if $.Values.keycloak.ingress.tls }}s{{ end }}://{{ .host }}/auth/realms/digitalai-platform/protocol/openid-connect/auth\"\n          logoutUri=\"http{{ if $.Values.keycloak.ingress.tls }}s{{ end }}://{{ .host }}/auth/realms/digitalai-platform/protocol/openid-connect/logout\"\n          {{- end }}\n          {{- range .Values.ingress.hosts }}\n          redirectUri=\"http{{ if $.Values.ingress.tls }}s{{ end }}://{{ . }}/oidc-login\"\n          postLogoutRedirectUri=\"http{{ if $.Values.ingress.tls }}s{{ end }}://{{ . }}/oidc-login\"\n          {{- end }}\n          userNameClaim=\"preferred_username\"\n          fullNameClaim=\"name\"\n          emailClaim=\"email\"\n          rolesClaim=\"groups\"\n          scopes =[\"openid\"]\n          {{- end }}\n        }\n      }\n    }\n  }\n}"` |  |
| containerPorts.releaseHttp | int | `5516` |  |
| containerSecurityContext.enabled | bool | `true` |  |
| containerSecurityContext.runAsNonRoot | bool | `true` |  |
| containerSecurityContext.runAsUser | int | `1001` |  |
| diagnosticMode.args[0] | string | `"infinity"` |  |
| diagnosticMode.command[0] | string | `"sleep"` |  |
| diagnosticMode.enabled | bool | `false` |  |
| dnsConfig | object | `{}` |  |
| dnsPolicy | string | `""` |  |
| external.db.enabled | bool | `false` |  |
| external.db.mainPassword | string | `""` |  |
| external.db.mainUrl | string | `""` |  |
| external.db.mainUsername | string | `""` |  |
| external.db.reportPassword | string | `""` |  |
| external.db.reportUrl | string | `""` |  |
| external.db.reportUsername | string | `""` |  |
| external.mq.enabled | bool | `false` |  |
| external.mq.password | string | `""` |  |
| external.mq.queueName | string | `""` |  |
| external.mq.url | string | `""` |  |
| external.mq.username | string | `""` |  |
| extraConfiguration | string | `"#{}"` |  |
| extraContainerPorts | list | `[]` |  |
| extraDeploy | list | `[]` |  |
| extraEnvVars | list | `[]` |  |
| extraEnvVarsCM | string | `""` |  |
| extraEnvVarsSecret | string | `""` |  |
| extraSecrets | object | `{}` |  |
| extraSecretsPrependReleaseName | bool | `false` |  |
| extraVolumeMounts | list | `[]` |  |
| extraVolumes | list | `[]` |  |
| forceRemoveMissingTypes | bool | `false` |  |
| fullnameOverride | string | `""` |  |
| generateXlConfig | bool | `true` |  |
| global.imagePullSecrets | list | `[]` |  |
| global.imageRegistry | string | `""` |  |
| global.storageClass | string | `""` |  |
| haproxy-ingress.controller.ingressClass | string | `"haproxy-dair"` |  |
| haproxy-ingress.controller.kind | string | `"Deployment"` |  |
| haproxy-ingress.controller.service.type | string | `"LoadBalancer"` |  |
| haproxy-ingress.install | bool | `false` |  |
| health.enabled | bool | `true` |  |
| health.periodScans | int | `10` |  |
| health.probeFailureThreshold | int | `12` |  |
| health.probes | bool | `true` |  |
| health.probesLivenessTimeout | int | `60` |  |
| health.probesReadinessTimeout | int | `60` |  |
| hostAliases | list | `[]` |  |
| image.pullPolicy | string | `"IfNotPresent"` |  |
| image.pullSecrets | list | `[]` |  |
| image.registry | string | `"docker.io"` |  |
| image.repository | string | `"xebialabsunsupported/xl-release"` |  |
| image.tag | string | `"22.3.1"` |  |
| ingress.annotations."kubernetes.io/ingress.class" | string | `"nginx-dair"` |  |
| ingress.annotations."nginx.ingress.kubernetes.io/affinity" | string | `"cookie"` |  |
| ingress.annotations."nginx.ingress.kubernetes.io/proxy-connect-timeout" | string | `"60"` |  |
| ingress.annotations."nginx.ingress.kubernetes.io/proxy-read-timeout" | string | `"60"` |  |
| ingress.annotations."nginx.ingress.kubernetes.io/proxy-send-timeout" | string | `"60"` |  |
| ingress.annotations."nginx.ingress.kubernetes.io/rewrite-target" | string | `"/"` |  |
| ingress.annotations."nginx.ingress.kubernetes.io/session-cookie-name" | string | `"JSESSIONID"` |  |
| ingress.annotations."nginx.ingress.kubernetes.io/ssl-redirect" | string | `"false"` |  |
| ingress.enabled | bool | `true` |  |
| ingress.extraHosts | list | `[]` |  |
| ingress.extraPaths | list | `[]` |  |
| ingress.extraRules | list | `[]` |  |
| ingress.extraTls | list | `[]` |  |
| ingress.hostname | string | `"-"` |  |
| ingress.ingressClassName | string | `""` |  |
| ingress.path | string | `"/"` |  |
| ingress.pathType | string | `"ImplementationSpecific"` |  |
| ingress.secrets | list | `[]` |  |
| ingress.selfSigned | bool | `false` |  |
| ingress.tls | bool | `false` |  |
| initContainers | list | `[]` |  |
| k8sSetup.platform | string | `"PlainK8s"` |  |
| keycloak.extraEnv | string | `"- name: PROXY_ADDRESS_FORWARDING\n  value: \"true\"\n- name: KEYCLOAK_USER\n  value: admin\n- name: KEYCLOAK_PASSWORD\n  value: admin\n- name: JGROUPS_DISCOVERY_PROTOCOL\n  value: dns.DNS_PING\n- name: JGROUPS_DISCOVERY_PROPERTIES\n  value: 'dns_query={{ include \"keycloak.serviceDnsName\" . }}'\n- name: CACHE_OWNERS_COUNT\n  value: \"2\"\n- name: CACHE_OWNERS_AUTH_SESSIONS_COUNT\n  value: \"2\"\n- name: JAVA_OPTS\n  value: >-\n    -XX:+UseContainerSupport\n    -XX:MaxRAMPercentage=50.0\n    -Djava.net.preferIPv4Stack=true\n    -Djboss.modules.system.pkgs=$JBOSS_MODULES_SYSTEM_PKGS\n    -Djava.awt.headless=true\n- name: DB_VENDOR\n  value: postgres\n- name: DB_ADDR\n  value: {{ .Release.Name }}-postgresql\n- name: DB_PORT\n  value: \"5432\"\n- name: DB_DATABASE\n  value: keycloak\n- name: DB_USER\n  value: keycloak\n- name: DB_PASSWORD\n  value: keycloak\n- name: KEYCLOAK_IMPORT\n  value: /realm/digitalai-platform-realm.json\n"` |  |
| keycloak.extraVolumeMounts | string | `"- name: realm-config\n  mountPath: \"/realm/\"\n  readOnly: true\n"` |  |
| keycloak.extraVolumes | string | `"- name: realm-config\n  configMap:\n    name: {{ .Release.Name }}-release-keycloak\n"` |  |
| keycloak.ingress.annotations."kubernetes.io/ingress.class" | string | `"nginx-dair"` |  |
| keycloak.ingress.annotations."nginx.ingress.kubernetes.io/ssl-redirect" | string | `"false"` |  |
| keycloak.ingress.enabled | bool | `true` |  |
| keycloak.ingress.rules[0].host | string | `"-"` |  |
| keycloak.ingress.rules[0].paths[0].path | string | `"/"` |  |
| keycloak.ingress.rules[0].paths[0].pathType | string | `"Prefix"` |  |
| keycloak.ingress.tls | list | `[]` |  |
| keycloak.install | bool | `false` |  |
| keycloak.postgresql.enabled | bool | `false` |  |
| keycloak.service.type | string | `"LoadBalancer"` |  |
| keystore.keystore | string | `"-"` |  |
| keystore.passphrase | string | `"-"` |  |
| kubeVersion | string | `""` |  |
| license | string | `"-"` |  |
| lifecycleHooks | object | `{}` |  |
| metrics.enabled | bool | `false` |  |
| nameOverride | string | `""` |  |
| namespaceOverride | string | `""` |  |
| networkPolicy.additionalRules | list | `[]` |  |
| networkPolicy.allowExternal | bool | `true` |  |
| networkPolicy.enabled | bool | `false` |  |
| nginx-ingress-controller.extraArgs.ingress-class | string | `"nginx-dair"` |  |
| nginx-ingress-controller.ingressClassResource.controllerClass | string | `"k8s.io/ingress-nginx-dair"` |  |
| nginx-ingress-controller.ingressClassResource.name | string | `"nginx-dair"` |  |
| nginx-ingress-controller.install | bool | `true` |  |
| nginx-ingress-controller.replicaCount | int | `1` |  |
| nginx-ingress-controller.resources.limits | object | `{}` |  |
| nginx-ingress-controller.resources.requests | object | `{}` |  |
| nginx-ingress-controller.service.type | string | `"LoadBalancer"` |  |
| nodeAffinityPreset.key | string | `""` |  |
| nodeAffinityPreset.type | string | `""` |  |
| nodeAffinityPreset.values | list | `[]` |  |
| nodeSelector | object | `{}` |  |
| oidc.accessToken.audience | string | `nil` |  |
| oidc.accessToken.enable | bool | `false` |  |
| oidc.accessToken.issuer | string | `nil` |  |
| oidc.accessToken.jwsAlg | string | `nil` |  |
| oidc.accessToken.keyRetrievalUri | string | `nil` |  |
| oidc.accessToken.secretKey | string | `nil` |  |
| oidc.accessTokenUri | string | `nil` |  |
| oidc.clientAuthJwt.enable | bool | `false` |  |
| oidc.clientAuthJwt.jwsAlg | string | `nil` |  |
| oidc.clientAuthJwt.key.alias | string | `nil` |  |
| oidc.clientAuthJwt.key.enable | bool | `false` |  |
| oidc.clientAuthJwt.key.password | string | `nil` |  |
| oidc.clientAuthJwt.keyStore.enable | bool | `false` |  |
| oidc.clientAuthJwt.keyStore.password | string | `nil` |  |
| oidc.clientAuthJwt.keyStore.path | string | `nil` |  |
| oidc.clientAuthJwt.keyStore.type | string | `nil` |  |
| oidc.clientAuthJwt.tokenKeyId | string | `nil` |  |
| oidc.clientAuthMethod | string | `nil` |  |
| oidc.clientId | string | `nil` |  |
| oidc.clientSecret | string | `nil` |  |
| oidc.emailClaim | string | `nil` |  |
| oidc.enabled | bool | `true` |  |
| oidc.external | bool | `false` |  |
| oidc.externalIdClaim | string | `nil` |  |
| oidc.fullNameClaim | string | `nil` |  |
| oidc.idTokenJWSAlg | string | `nil` |  |
| oidc.issuer | string | `nil` |  |
| oidc.keyRetrievalUri | string | `nil` |  |
| oidc.logoutUri | string | `nil` |  |
| oidc.postLogoutRedirectUri | string | `nil` |  |
| oidc.proxyHost | string | `nil` |  |
| oidc.proxyPort | string | `nil` |  |
| oidc.redirectUri | string | `nil` |  |
| oidc.rolesClaim | string | `nil` |  |
| oidc.scopes[0] | string | `"openid"` |  |
| oidc.userAuthorizationUri | string | `nil` |  |
| oidc.userNameClaim | string | `nil` |  |
| pdb.create | bool | `false` |  |
| pdb.maxUnavailable | string | `""` |  |
| pdb.minAvailable | int | `1` |  |
| persistence.accessModes[0] | string | `"ReadWriteOnce"` |  |
| persistence.annotations."helm.sh/resource-policy" | string | `"keep"` |  |
| persistence.enabled | bool | `true` |  |
| persistence.existingClaim | string | `""` |  |
| persistence.selector | object | `{}` |  |
| persistence.single | bool | `true` |  |
| persistence.size | string | `"8Gi"` |  |
| persistence.storageClass | string | `"-"` |  |
| podAffinityPreset | string | `""` |  |
| podAnnotations | object | `{}` |  |
| podAntiAffinityPreset | string | `"soft"` |  |
| podLabels | object | `{}` |  |
| podManagementPolicy | string | `"OrderedReady"` |  |
| podSecurityContext.enabled | bool | `true` |  |
| podSecurityContext.fsGroup | int | `1001` |  |
| postgresql.initdbScriptsSecret | string | `"{{ .Release.Name }}-release-postgresql"` |  |
| postgresql.install | bool | `true` |  |
| postgresql.persistence.accessMode | string | `"ReadWriteOnce"` |  |
| postgresql.persistence.enabled | bool | `true` |  |
| postgresql.persistence.existingClaim | string | `""` |  |
| postgresql.persistence.size | string | `"8Gi"` |  |
| postgresql.persistence.storageClass | string | `"-"` |  |
| postgresql.postgresqlMaxConnections | string | `"150"` |  |
| postgresql.postgresqlPassword | string | `"postgres"` |  |
| postgresql.postgresqlUsername | string | `"postgres"` |  |
| postgresql.resources.requests.cpu | string | `"250m"` |  |
| postgresql.resources.requests.memory | string | `"256Mi"` |  |
| postgresql.service.port | int | `5432` |  |
| postgresql.service.type | string | `"ClusterIP"` |  |
| postgresql.volumePermissions.enabled | bool | `true` |  |
| priorityClassName | string | `""` |  |
| rabbitmq.auth.erlangCookie | string | `"RELEASERABBITMQCLUSTER"` |  |
| rabbitmq.auth.password | string | `"guest"` |  |
| rabbitmq.auth.username | string | `"guest"` |  |
| rabbitmq.extraConfiguration | string | `"raft.wal_max_size_bytes = 1048576\n"` |  |
| rabbitmq.extraPlugins | string | `"rabbitmq_amqp1_0"` |  |
| rabbitmq.forceBoot | bool | `true` |  |
| rabbitmq.install | bool | `true` |  |
| rabbitmq.loadDefinition.enabled | bool | `true` |  |
| rabbitmq.loadDefinition.existingSecret | string | `"{{ .Release.Name }}-release-rabbitmq"` |  |
| rabbitmq.loadDefinition.file | string | `"/app/release_load_definition.json"` |  |
| rabbitmq.persistence.accessMode | string | `"ReadWriteOnce"` |  |
| rabbitmq.persistence.enabled | bool | `true` |  |
| rabbitmq.persistence.size | string | `"8Gi"` |  |
| rabbitmq.persistence.storageClass | string | `"-"` |  |
| rabbitmq.replicaCount | int | `3` |  |
| rabbitmq.service.type | string | `"ClusterIP"` |  |
| rabbitmq.volumePermissions.enabled | bool | `true` |  |
| rbac.create | bool | `true` |  |
| replicaCount | int | `3` |  |
| resources.limits | object | `{}` |  |
| resources.requests | object | `{}` |  |
| schedulerName | string | `""` |  |
| service.annotations | object | `{}` |  |
| service.annotationsHeadless | object | `{}` |  |
| service.clusterIP | string | `""` |  |
| service.externalIPs | list | `[]` |  |
| service.externalTrafficPolicy | string | `"Cluster"` |  |
| service.extraPorts | list | `[]` |  |
| service.labels | object | `{}` |  |
| service.loadBalancerIP | string | `""` |  |
| service.loadBalancerSourceRanges | list | `[]` |  |
| service.nodePorts.releaseHttp | string | `""` |  |
| service.portEnabled | bool | `true` |  |
| service.portNames.releaseHttp | string | `"release-http"` |  |
| service.ports.releaseHttp | int | `80` |  |
| service.sessionAffinity | string | `"None"` |  |
| service.sessionAffinityConfig | object | `{}` |  |
| service.type | string | `"ClusterIP"` |  |
| serviceAccount.annotations | object | `{}` |  |
| serviceAccount.automountServiceAccountToken | bool | `true` |  |
| serviceAccount.create | bool | `true` |  |
| serviceAccount.name | string | `""` |  |
| sidecars | list | `[]` |  |
| statefulsetLabels | object | `{}` |  |
| terminationGracePeriodSeconds | int | `200` |  |
| tolerations | list | `[]` |  |
| topologySpreadConstraints | list | `[]` |  |
| updateStrategy.type | string | `"RollingUpdate"` |  |
| useIpAsHostname | bool | `false` |  |

----------------------------------------------
Autogenerated from chart metadata using [helm-docs v1.11.0](https://github.com/norwoodj/helm-docs/releases/v1.11.0)
