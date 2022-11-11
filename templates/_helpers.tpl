{{/* vim: set filetype=mustache: */}}

{{/*
Return the proper Release image name
*/}}
{{- define "release.image" -}}
{{ include "common.images.image" (dict "imageRoot" .Values.image "global" .Values.global) }}
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
        {{ randAlphaNum 10 }}
    {{- end -}}
{{- end -}}

{{/*
Remove Nginx regex from path.
*/}}
{{- define "release.path.fullname" -}}
    {{- $ingressclass := index .Values "ingress" "annotations" "kubernetes.io/ingress.class" }}
    {{- if and .Values.ingress.enabled }}
        {{- if contains $ingressclass "nginx" }}
            {{- $name := ( split "(" .Values.ingress.path)._0 }}
            {{- if $name }}
                {{- printf "%s/" $name }}
            {{- else }}
                {{- print "" }}
            {{- end }}
        {{- else -}}
            {{- print "" }}
        {{- end -}}
    {{- else -}}
        {{- print "" }}
    {{- end -}}
{{- end -}}

{{/*
Get the server URL
*/}}
{{- define "release.serverUrl" -}}
    {{- $ingressclass := index .Values "ingress" "annotations" "kubernetes.io/ingress.class" }}
    {{- $hostname := .Values.ingress.hostname }}
    {{- $protocol := "http" }}
    {{- if .Values.ingress.tls }}
        {{- $protocol = "https" }}
    {{- end }}
    {{- if and .Values.ingress.enabled }}
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
    {{- end }}
{{- end -}}

{{/*
Get the main db URL
*/}}
{{- define "release.mainDbUrl" -}}
    {{- if .Values.external.db.enabled -}}
        {{- .Values.external.db.mainUrl -}}
    {{- else -}}
        {{- if .Values.postgresql.install -}}
            jdbc:postgresql://{{ .Release.Name }}-postgresql:{{ .Values.postgresql.service.port }}/xlr-db
        {{- end -}}
    {{- end -}}
{{- end -}}

{{/*
Get the main db username
*/}}
{{- define "release.mainUsername" -}}
    {{- if .Values.external.db.enabled }}
        {{ .Values.external.db.mainUsername }}
    {{- else }}
        {{- if .Values.postgresql.install }}
            xlr
        {{- end -}}
    {{- end -}}
{{- end -}}

{{/*
Get the main db password
*/}}
{{- define "release.mainPassword" -}}
    {{- if .Values.external.db.enabled }}
        {{ .Values.external.db.mainPassword }}
    {{- else }}
        {{- if .Values.postgresql.install }}
            xlr
        {{- end -}}
    {{- end -}}
{{- end -}}

{{/*
Get the report db URL
*/}}
{{- define "release.reportDbUrl" -}}
    {{- if .Values.external.db.enabled -}}
        {{ .Values.external.db.reportUrl }}
    {{- else -}}
        {{- if .Values.postgresql.install -}}
            jdbc:postgresql://{{ .Release.Name }}-postgresql:{{ .Values.postgresql.service.port }}/xlr-report-db
        {{- end -}}
    {{- end -}}
{{- end -}}

{{/*
Get the report db username
*/}}
{{- define "release.reportUsername" -}}
    {{- if .Values.external.db.enabled }}
        {{ .Values.external.db.reportUsername }}
    {{- else }}
        {{- if .Values.postgresql.install }}
            xlr-report
        {{- end -}}
    {{- end -}}
{{- end -}}

{{/*
Get the report db password
*/}}
{{- define "release.reportPassword" -}}
    {{- if .Values.external.db.enabled }}
        {{ .Values.external.db.reportPassword }}
    {{- else }}
        {{- if .Values.postgresql.install }}
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
            "amqp://{{ .Release.Name }}-rabbitmq.{{ .Release.Namespace }}.svc.cluster.local:{{ .Values.rabbitmq.service.ports.amqp }}/"
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
    {{- if .Values.external.mq.enabled }}
        {{ .Values.external.mq.username }}
    {{- else }}
        {{- if .Values.rabbitmq.install }}
            {{ .Values.rabbitmq.auth.username }}
        {{- end -}}
    {{- end -}}
{{- end -}}

{{/*
Get the mq password
*/}}
{{- define "release.mqPassword" -}}
    {{- if .Values.external.mq.enabled }}
        {{ .Values.external.mq.password }}
    {{- else }}
        {{- if .Values.rabbitmq.install }}
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
