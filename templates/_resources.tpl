{{/* vim: set filetype=mustache: */}}

{{/*
Return a resource request/limit object based on a given preset.
These presets are for basic testing and not meant to be used in production
{{ include "release.resources.preset" (dict "type" "nano") -}}
*/}}
{{- define "release.resources.preset" -}}
{{/* The limits are the requests increased by 50% (except ephemeral-storage and xlarge/2xlarge sizes)*/}}
{{- $presets := dict 
  "nano" (dict 
      "requests" (dict "cpu" "1.0" "memory" "2Gi")
      "limits" (dict "cpu" "1.5" "memory" "3Gi")
   )
  "micro" (dict 
      "requests" (dict "cpu" "2.0" "memory" "4Gi")
      "limits" (dict "cpu" "3.0" "memory" "6Gi")
   )
  "small" (dict 
      "requests" (dict "cpu" "4.0" "memory" "8Gi")
      "limits" (dict "cpu" "6.0" "memory" "12Gi")
   )
  "medium" (dict 
      "requests" (dict "cpu" "8.0" "memory" "16Gi")
      "limits" (dict "cpu" "12.0" "memory" "24Gi")
   )
  "large" (dict 
      "requests" (dict "cpu" "16.0" "memory" "32Gi")
      "limits" (dict "cpu" "24.0" "memory" "48Gi")
   )
  "xlarge" (dict 
      "requests" (dict "cpu" "32" "memory" "64Gi")
      "limits" (dict "cpu" "64" "memory" "96Gi")
   )
  "2xlarge" (dict 
      "requests" (dict "cpu" "64" "memory" "128Gi")
      "limits" (dict "cpu" "128" "memory" "256Gi")
   )
 }}
{{- if hasKey $presets .type -}}
{{- index $presets .type | toYaml -}}
{{- else -}}
{{- printf "ERROR: Preset key '%s' invalid. Allowed values are %s" .type (join "," (keys $presets)) | fail -}}
{{- end -}}
{{- end -}}