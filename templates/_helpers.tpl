{{/* vim: set filetype=mustache: */}}
{{/*
Expand the name of the chart.
*/}}
{{- define "xl-release.name" -}}
{{- default .Chart.Name .Values.nameOverride | trunc 63 | trimSuffix "-" -}}
{{- end -}}

{{/*
Create a default fully qualified app name.
We truncate at 63 chars because some Kubernetes name fields are limited to this (by the DNS naming spec).
If release name contains chart name it will be used as a full name.
*/}}
{{- define "xl-release.fullname" -}}
{{- if .Values.fullnameOverride -}}
{{- .Values.fullnameOverride | trunc 63 | trimSuffix "-" -}}
{{- else -}}
{{- $name := default .Chart.Name .Values.nameOverride -}}
{{- if contains $name .Release.Name -}}
{{- .Release.Name | trunc 63 | trimSuffix "-" -}}
{{- else -}}
{{- printf "%s-%s" .Release.Name $name | trunc 63 | trimSuffix "-" -}}
{{- end -}}
{{- end -}}
{{- end -}}

{{/*
Create chart name and version as used by the chart label.
*/}}
{{- define "xl-release.chart" -}}
{{- printf "%s-%s" .Chart.Name .Chart.Version | replace "+" "_" | trunc 63 | trimSuffix "-" -}}
{{- end -}}

{{/*
Remove Nginx regex from NOTES.txt.
*/}}
{{- define "path.fullname" -}}
{{- $ingressclass := index .Values "ingress" "annotations" "kubernetes.io/ingress.class" }}
{{- if and .Values.ingress.Enabled }}
{{- if contains $ingressclass "nginx" }}
{{- $name := ( split "(" .Values.ingress.path)._0 -}}
{{- printf "%s" $name -}}/
{{- end -}}
{{- end -}}
{{- end -}}


{{/*
Renders a value that contains template.
Usage:
{{ include "render-value" ( dict "value" .Values.path.to.the.Value "context" $) }}
*/}}
{{- define "render.value" -}}
  {{- if kindIs "string" .value -}}
    {{- tpl .value .context -}}
  {{- else -}}
    {{- tpl (.value | toYaml) .context }}
  {{- end -}}
{{- end -}}

{{- define "render.secret-name" -}}
  {{- if .value -}}
    {{- if kindIs "string" .value -}}
{{ .defaultName }}
    {{- else -}}
{{ .value.valueFrom.secretKeyRef.name }}   
    {{- end -}}
  {{- else -}}
    {{- if .default -}}
{{ .defaultName }}
    {{- end -}}
  {{- end -}}
{{- end -}}

{{- define "render.value-secret" -}}
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

{{- define "render.value-if-not-secret" -}}
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
Compile all warnings into a single message, and call fail.
*/}}
{{- define "release.validateValues" -}}
{{- $messages := list -}}
{{- $messages = append $messages (include "release.validateValues.mandatory" (dict "name" "xlrLicense" "value" .Values.xlrLicense ) ) -}}
{{- $messages = append $messages (include "release.validateValues.mandatory" (dict "name" "RepositoryKeystore" "value" .Values.RepositoryKeystore ) ) -}}
{{- $messages = append $messages (include "release.validateValues.mandatory" (dict "name" "KeystorePassphrase" "value" .Values.KeystorePassphrase ) ) -}}
{{- if .Values.UseExistingDB.Enabled -}}
{{- $messages = append $messages (include "release.validateValues.mandatory" (dict "name" "UseExistingDB.XLR_DB_USER" "value" .Values.UseExistingDB.XLR_DB_USER ) ) -}}
{{- $messages = append $messages (include "release.validateValues.mandatory" (dict "name" "UseExistingDB.XLR_DB_PASS" "value" .Values.UseExistingDB.XLR_DB_PASS ) ) -}}
{{- $messages = append $messages (include "release.validateValues.mandatory" (dict "name" "UseExistingDB.XLR_REPORT_DB_USER" "value" .Values.UseExistingDB.XLR_REPORT_DB_USER ) ) -}}
{{- $messages = append $messages (include "release.validateValues.mandatory" (dict "name" "UseExistingDB.XLR_REPORT_DB_PASS" "value" .Values.UseExistingDB.XLR_REPORT_DB_PASS ) ) -}}
{{- end -}}
{{- if .Values.UseExistingMQ.Enabled -}}
{{- $messages = append $messages (include "release.validateValues.mandatory" (dict "name" "UseExistingMQ.XLR_TASK_QUEUE_USERNAME" "value" .Values.UseExistingMQ.XLR_TASK_QUEUE_USERNAME ) ) -}}
{{- $messages = append $messages (include "release.validateValues.mandatory" (dict "name" "UseExistingMQ.XLR_TASK_QUEUE_PASSWORD" "value" .Values.UseExistingMQ.XLR_TASK_QUEUE_PASSWORD ) ) -}}
{{- end -}}
{{- if .Values.oidc.external -}}
{{- $messages = append $messages (include "release.validateValues.mandatory" (dict "name" "oidc.clientSecret" "value" .Values.oidc.clientSecret ) ) -}}
{{- end -}}
{{- if .Values.AdminPassword -}}
{{- $messages = append $messages (include "validate.existing.secret" (dict "value" .Values.AdminPassword "context" $) ) -}}
{{- end -}}


{{- $messages = without $messages "" -}}
{{- $message := join "\n" $messages -}}

{{- if and $message .Values.K8sSetup.validateValues -}}
{{-   printf "\nVALUES VALIDATION:\n%s" $message | fail -}}
{{- end -}}

{{- end -}}


{{/*
Validate values of Release - KeystorePassphrase
*/}}
{{- define "release.validateValues.mandatory" -}}
{{- if not .value -}}
release: {{ .name }}
    The `{{ .name }}` is empty. It is mandatory to set.
{{- end -}}
{{- end -}}

{{- define "validate.existing.secret" -}}
  {{- if .value -}}
    {{- if not (kindIs "string" .value) -}}
      {{- if .value.valueFrom.secretKeyRef.name }}
        {{- $exists := include "secrets.exists" (dict "secret" .value.valueFrom.secretKeyRef.name "context" .context) -}}
        {{- if not $exists -}}
            secret: {{ .value.valueFrom.secretKeyRef.name }}
                The `{{ .value.valueFrom.secretKeyRef.name }}` does not exist.
        {{- end -}}
      {{- else -}}
          secret: unknown
              The `{{ .value }}` is not reference to secret.
      {{- end -}}
    {{- end -}}
  {{- end -}}
{{- end }}

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
  {{- true -}}
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
{{- if and .secretRef (not (kindIs "string" .secretRef)) .secretRef.valueFrom.secretKeyRef.key -}}
{{ .secretRef.valueFrom.secretKeyRef.key }}
{{- else -}}
{{ .default }}
{{- end -}}
{{- end -}}
