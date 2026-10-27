{{/* Common labels */}}
{{- define "voting-app.labels" -}}
app.kubernetes.io/part-of: {{ .Chart.Name }}
app.kubernetes.io/managed-by: {{ .Release.Service }}
app.kubernetes.io/instance: {{ .Release.Name }}
helm.sh/chart: {{ .Chart.Name }}-{{ .Chart.Version }}
{{- end }}

{{/* Image reference for one of our own services */}}
{{- define "voting-app.image" -}}
{{ .root.Values.image.registry }}/voting-app-{{ .name }}:{{ .root.Values.image.tag }}
{{- end }}

{{/* Hardened container security context for our own images */}}
{{- define "voting-app.containerSecurity" -}}
allowPrivilegeEscalation: false
readOnlyRootFilesystem: true
capabilities:
  drop: ["ALL"]
{{- end }}
