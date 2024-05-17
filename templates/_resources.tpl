{{/* vim: set filetype=mustache: */}}

{{/*
Return a resource request/limit object based on a given preset.
These presets are for basic testing and not meant to be used in production
{{ include "release.resources.preset" (dict "type" "nano") -}}
*/}}
{{- define "release.resources.preset" -}}
{{/* The limits are as per the documentation. The requests are limits reduced by approximately 150% and rounded.*/}}
{{- $presets := dict 
  "nano" (dict 
      "requests" (dict "cpu" "500m" "memory" "1Gi")
      "limits" (dict "cpu" "1.0" "memory" "2Gi")
   )
  "micro" (dict 
      "requests" (dict "cpu" "1.0" "memory" "2Gi")
      "limits" (dict "cpu" "2.0" "memory" "4Gi")
   )
  "small" (dict 
      "requests" (dict "cpu" "2.0" "memory" "5Gi")
      "limits" (dict "cpu" "4.0" "memory" "8Gi")
   )
  "medium" (dict 
      "requests" (dict "cpu" "5.0" "memory" "10Gi")
      "limits" (dict "cpu" "8.0" "memory" "16Gi")
   )
  "large" (dict 
      "requests" (dict "cpu" "10.0" "memory" "21Gi")
      "limits" (dict "cpu" "16.0" "memory" "32Gi")
   )
  "xlarge" (dict 
      "requests" (dict "cpu" "21.0" "memory" "42Gi")
      "limits" (dict "cpu" "32.0" "memory" "64Gi")
   )
  "2xlarge" (dict 
      "requests" (dict "cpu" "42.0" "memory" "85Gi")
      "limits" (dict "cpu" "64.0" "memory" "128Gi")
   )
 }}
{{- if hasKey $presets .type -}}
{{- index $presets .type | toYaml -}}
{{- else -}}
{{- printf "ERROR: Preset key '%s' invalid. Allowed values are %s" .type (join "," (keys $presets)) | fail -}}
{{- end -}}
{{- end -}}