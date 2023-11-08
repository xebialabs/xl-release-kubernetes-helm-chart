{{/* vim: set filetype=mustache: */}}

{{- define "postgresql.subchart" -}}
{{ include "postgresql.primary.fullname" (merge .Subcharts.postgresql (dict "nameOverride" "postgresql")) }}
{{- end -}}

{{- define "rabbitmq.subchart" -}}
{{ include "common.names.fullname" (merge .Subcharts.rabbitmq (dict "nameOverride" "rabbitmq")) }}
{{- end -}}

{{- define "release.name" -}}
{{- $name := ( include "common.names.fullname" . ) -}}
{{- if eq .Values.k8sSetup.platform "Openshift" -}}
{{- printf "%s-ocp" $name -}}
{{- else -}}
{{- $name -}}
{{- end -}}
{{- end -}}

{{/*
Return the proper image name
{{ include "common.images.image" ( dict "imageRoot" .Values.path.to.the.image "global" $) }}
*/}}
{{- define "release.images.image" -}}
{{- $registryName := .imageRoot.registry -}}
{{- $repositoryName := .imageRoot.repository -}}
{{- $tag := (tpl .imageRoot.tag .context) | toString -}}
{{- if .global }}
    {{- if .global.imageRegistry }}
     {{- $registryName = .global.imageRegistry -}}
    {{- end -}}
{{- end -}}
{{- if $registryName }}
{{- printf "%s/%s:%s" $registryName $repositoryName $tag -}}
{{- else -}}
{{- printf "%s:%s" $repositoryName $tag -}}
{{- end -}}
{{- end -}}

{{/*
Return the proper Release image name
*/}}
{{- define "release.image" -}}
{{ include "release.images.image" (dict "imageRoot" .Values.image "global" .Values.global "context" .) }}
{{- end -}}

{{/*
BusyBox image
*/}}
{{- define "release.busyBox.image" -}}
{{ include "common.images.image" (dict "imageRoot" .Values.busyBox.image "global" .Values.global) }}
{{- end }}

{{/*
 Create the name of the service account to use
 */}}
{{- define "release.serviceAccountName" -}}
{{- if .Values.serviceAccount.create -}}
    {{ default (include "common.names.fullname" .) .Values.serviceAccount.name }}
{{- else -}}
    {{ default "default" .Values.serviceAccount.name }}
{{- end -}}
{{- end -}}

{{/*
Get the password secret.
*/}}
{{- define "release.secretPassword" -}}
    {{- if .Values.auth.adminPassword -}}
        {{ .Values.auth.adminPassword }}
    {{- else -}}
        {{- $secretObj := (lookup "v1" "Secret" .Release.Namespace (include "common.names.fullname" .)) | default dict }}
        {{- $secretData := (get $secretObj "data") | default dict }}
        {{- (get $secretData "releasePassword") | b64dec | default (randAlphaNum 10) }}
    {{- end -}}
{{- end -}}

{{/*
Remove Nginx regex from path.
*/}}
{{- define "release.path.fullname" -}}
    {{- if and .Values.ingress.enabled }}
        {{- $ingressclass := index .Values "ingress" "annotations" "kubernetes.io/ingress.class" }}
        {{- if contains $ingressclass "nginx" }}
            {{- $name := ( split "(" .Values.ingress.path)._0 }}
            {{- if $name }}
                {{- printf "%s/" $name }}
            {{- else }}
                {{- print "" }}
            {{- end }}
        {{- else -}}
            {{- printf "%s/" .Values.ingress.path }}
        {{- end -}}
    {{- else -}}
        {{- if .Values.route.enabled }}
            {{- if hasSuffix "/" .Values.route.path }}
                {{- printf "%s" .Values.route.path }}
            {{- else }}
                {{- printf "%s/" .Values.route.path }}
            {{- end }}
        {{- else -}}
            {{- print "" }}
        {{- end -}}
    {{- end -}}
{{- end -}}

{{/*
Get the server URL
*/}}
{{- define "release.serverUrl" -}}
    {{- $protocol := "http" }}
    {{- if .Values.ingress.enabled }}
        {{- if .Values.ingress.tls }}
            {{- $protocol = "https" }}
        {{- end }}
        {{- $ingressclass := index .Values "ingress" "annotations" "kubernetes.io/ingress.class" }}
        {{- $hostname := .Values.ingress.hostname }}
        {{- if and (contains $ingressclass "nginx") (ne .Values.ingress.path "/") }}
            {{- $path := include "release.path.fullname" $ }}
            {{- if $path }}
                {{- printf "%s://%s%s" $protocol $hostname $path }}
            {{- else }}
                {{- printf "%s://%s" $protocol $hostname }}
            {{- end }}
        {{- else }}
            {{- printf "%s://%s" $protocol $hostname }}
        {{- end }}
    {{- else -}}
        {{- if .Values.route.enabled }}
            {{- if .Values.route.tls.enabled }}
                {{- $protocol = "https" }}
            {{- end }}
            {{- $hostname := .Values.route.hostname }}
            {{- $path := include "release.path.fullname" $ }}
            {{- if $path }}
                {{- printf "%s://%s%s" $protocol $hostname $path }}
            {{- else }}
                {{- printf "%s://%s" $protocol $hostname }}
            {{- end }}
        {{- else -}}
            {{- print "" }}
        {{- end }}
    {{- end }}
{{- end -}}

{{/*
Get the main db URL
*/}}
{{- define "release.mainDbUrl" -}}
    {{- if .Values.external.db.enabled -}}
        {{- .Values.external.db.main.url -}}
    {{- else -}}
        {{- if .Values.postgresql.install -}}
            jdbc:postgresql://{{ include "postgresql.subchart" . }}:{{ include "postgresql.service.port" . }}/xlr-db
        {{- end -}}
    {{- end -}}
{{- end -}}

{{/*
Get the main db username
*/}}
{{- define "release.mainUsername" -}}
    {{- if .Values.external.db.enabled -}}
        {{ .Values.external.db.main.username }}
    {{- else -}}
        {{- if .Values.postgresql.install -}}
            xlr
        {{- end -}}
    {{- end -}}
{{- end -}}

{{/*
Get the main db password
*/}}
{{- define "release.mainPassword" -}}
    {{- if .Values.external.db.enabled -}}
        {{ .Values.external.db.main.password }}
    {{- else -}}
        {{- if .Values.postgresql.install -}}
            xlr
        {{- end -}}
    {{- end -}}
{{- end -}}

{{/*
Get the report db URL
*/}}
{{- define "release.reportDbUrl" -}}
    {{- if .Values.external.db.enabled -}}
        {{ .Values.external.db.report.url }}
    {{- else -}}
        {{- if .Values.postgresql.install -}}
            jdbc:postgresql://{{ include "postgresql.subchart" . }}:{{ include "postgresql.service.port" . }}/xlr-report-db
        {{- end -}}
    {{- end -}}
{{- end -}}

{{/*
Get the report db username
*/}}
{{- define "release.reportUsername" -}}
    {{- if .Values.external.db.enabled -}}
        {{ .Values.external.db.report.username }}
    {{- else -}}
        {{- if .Values.postgresql.install -}}
            xlr-report
        {{- end -}}
    {{- end -}}
{{- end -}}

{{/*
Get the report db password
*/}}
{{- define "release.reportPassword" -}}
    {{- if .Values.external.db.enabled -}}
        {{ .Values.external.db.report.password }}
    {{- else -}}
        {{- if .Values.postgresql.install -}}
            xlr-report
        {{- end -}}
    {{- end -}}
{{- end -}}

{{/*
Get the mq URL
*/}}
{{- define "release.mqUrl" -}}
    {{- if .Values.external.mq.enabled -}}
        {{ .Values.external.mq.url }}
    {{- else -}}
        {{- if .Values.rabbitmq.install -}}
            "amqp://{{ include "rabbitmq.subchart" . }}:{{ .Values.rabbitmq.service.ports.amqp }}/"
        {{- end -}}
    {{- end -}}
{{- end -}}

{{/*
Get the mq queue name
*/}}
{{- define "release.mqQueueName" -}}
    {{- if .Values.external.mq.enabled -}}
        {{ .Values.external.mq.queueName }}
    {{- else -}}
        {{- if .Values.rabbitmq.install -}}
            "xlr-tasks-queue"
        {{- end -}}
    {{- end -}}
{{- end -}}

{{/*
Get the mq username
*/}}
{{- define "release.mqUsername" -}}
    {{- if .Values.external.mq.enabled -}}
        {{ .Values.external.mq.username }}
    {{- else -}}
        {{- if .Values.rabbitmq.install -}}
            {{ .Values.rabbitmq.auth.username }}
        {{- end -}}
    {{- end -}}
{{- end -}}

{{/*
Get the mq password
*/}}
{{- define "release.mqPassword" -}}
    {{- if .Values.external.mq.enabled -}}
        {{ .Values.external.mq.password }}
    {{- else -}}
        {{- if .Values.rabbitmq.install -}}
            {{ .Values.rabbitmq.auth.password }}
        {{- end -}}
    {{- end -}}
{{- end -}}

{{/*
Compile all warnings into a single message, and call fail.
*/}}
{{- define "release.validateValues" -}}
{{- $messages := list -}}
{{- $messages = append $messages (include "release.validateValues.ingress.tls" .) -}}
{{- $messages = append $messages (include "release.validateValues.keystore.passphrase" .) -}}
{{- $messages = append $messages (include "release.validateValues.license" .) -}}
{{- if .Values.auth.adminPassword -}}
{{- $messages = append $messages (include "validate.existing.secret" (dict "value" .Values.auth.adminPassword "context" $) ) -}}
{{- end -}}
{{- $messages = without $messages "" -}}
{{- $message := join "\n" $messages -}}

{{- if and $message .Values.k8sSetup.validateValues -}}
{{-   printf "\nVALUES VALIDATION:\n%s" $message | fail -}}
{{- end -}}

{{- end -}}

{{/*
Validate values of Release - TLS configuration for Ingress
*/}}
{{- define "release.validateValues.ingress.tls" -}}
{{- if and .Values.ingress.enabled .Values.ingress.tls (not (include "common.ingress.certManagerRequest" ( dict "annotations" .Values.ingress.annotations ))) (not .Values.ingress.selfSigned) (empty .Values.ingress.extraTls) }}
release: ingress.tls
    You enabled the TLS configuration for the default ingress hostname but
    you did not enable any of the available mechanisms to create the TLS secret
    to be used by the Ingress Controller.
    Please use any of these alternatives:
      - Use the `ingress.extraTls` and `ingress.secrets` parameters to provide your custom TLS certificates.
      - Relay on cert-manager to create it by setting the corresponding annotations
      - Relay on Helm to create self-signed certificates by setting `ingress.selfSigned=true`
{{- end -}}
{{- end -}}

{{/*
Validate values of Release - keystore.passphrase
*/}}
{{- define "release.validateValues.keystore.passphrase" -}}
{{- if not .Values.keystore.passphrase }}
release: keystore.passphrase
    The `keystore.passphrase` is empty. It is mandatory to set.
{{- end -}}
{{- end -}}

{{/*
Validate values of Release - license and licenseAcceptEula
*/}}
{{- define "release.validateValues.license" -}}
{{- if not .Values.licenseAcceptEula }}
{{- if not .Values.license }}
release: keystore.license
    The `license` is empty. It is mandatory to set if `licenseAcceptEula` is disabled.
{{- end -}}
{{- end -}}
{{- end -}}

{{- define "render.secret-name" -}}
  {{- if .value -}}
    {{- if kindIs "map" .value -}}
{{ .value.valueFrom.secretKeyRef.name }}
    {{- else if kindIs "string" .value -}}
{{ .defaultName }}
    {{- else -}}
{{- fail "Invalid argument value to function render.secret-name" -}}
    {{- end -}}
  {{- else -}}
    {{- if .default -}}
{{ .defaultName }}
    {{- end -}}
  {{- end -}}
{{- end -}}

{{/*
Returns the name of the secret key if exists, in other case it gives the default value

Usage:
{{ include "secrets.key" (dict "secretRef" .Values.secretObjectRef "default" "defaultValue") }}

Params:
  - secretRef - dict - Required - Name of the 'Secret' resource where the password is stored.
  - default - String - Required - Default value if, there is no secret reference under secretRef
*/}}
{{- define "secrets.key" -}}
{{- if and .secretRef (kindIs "map" .secretRef) -}}
{{ .secretRef.valueFrom.secretKeyRef.key }}
{{- else if kindIs "string" .secretRef -}}
{{ .default }}
{{- else -}}
{{- fail "Invalid argument value to function secrets.key" -}}
{{- end -}}
{{- end -}}

{{- define "render.value-secret" -}}
{{- if and .sourceEnabled .source (kindIs "map" .source) -}}
  {{- tpl (.source | toYaml) .context }}
{{- else -}}
  {{- if .value -}}
    {{- if kindIs "string" .value -}}
valueFrom:
    secretKeyRef:
        name: {{ .defaultName }}
        key: {{ .defaultKey }}
    {{- else -}}
        {{- tpl (.value | toYaml) .context }}
    {{- end -}}
  {{- else -}}
    {{- if .default -}}
valueFrom:
    secretKeyRef:
        name: {{ .defaultName }}
        key: {{ .defaultKey }}
    {{- end -}}
  {{- end -}}
{{- end -}}
{{- end -}}

{{- define "render.value-if-not-secret" -}}
{{- if or (not .source) (not (kindIs "map" .source)) -}}
    {{- if .value -}}
        {{- if kindIs "string" .value -}}
            {{ .key }}: {{ .value | b64enc | quote }}
        {{- end -}}
    {{- else -}}
      {{- if .default -}}
        {{ .key }}: {{ .default | b64enc | quote }}
      {{- end -}}
    {{- end -}}
{{- end -}}
{{- end -}}

{{- define "render.value-if-not-secret-decode" -}}
    {{- if .value -}}
        {{- if kindIs "string" .value -}}
            {{ .key }}: {{ .value | b64dec | b64enc | quote }}
        {{- end -}}
    {{- else -}}
      {{- if .default -}}
        {{ .key }}: {{ .default | b64dec | b64enc | quote }}
      {{- end -}}
    {{- end -}}
{{- end -}}

{{/*
Returns whether a previous generated secret already exists

Usage:
{{ include "secrets.exists" (dict "secret" "secret-name" "context" $) }}

Params:
  - secret - String - Required - Name of the 'Secret' resource where the password is stored.
  - context - Context - Required - Parent context.
*/}}
{{- define "secrets.exists" -}}
{{- $secret := (lookup "v1" "Secret" .context.Release.Namespace .secret) -}}
{{- if $secret -}}
true
{{- else -}}
false
{{- end -}}
{{- end -}}

{{- define "validate.existing.secret" -}}
  {{- if .value -}}
    {{- if kindIs "map" .value -}}
      {{- if .value.valueFrom.secretKeyRef.name }}
        {{- $exists := include "secrets.exists" (dict "secret" .value.valueFrom.secretKeyRef.name "context" .context) -}}
        {{- if not $exists -}}
            secret: {{ .value.valueFrom.secretKeyRef.name }}:
                The secret `{{ .value.valueFrom.secretKeyRef.name }}` does not exist in namespace `{{ .context.Release.Namespace }}`.
        {{- end -}}
      {{- else -}}
          secret: unknown
              The `{{ .value }}` is not reference to secret.
      {{- end -}}
    {{- end -}}
  {{- end -}}
{{- end }}
