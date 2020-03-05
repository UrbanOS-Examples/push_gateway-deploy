{{/* vim: set filetype=mustache: */}}
{{/*
Common labels
*/}}
{{- define "push-gateway.labels" -}}
app.kubernetes.io/name: push-gateway
helm.sh/chart: push-gateway
app.kubernetes.io/instance: {{ .Release.Name }}
{{- if .Chart.AppVersion }}
app.kubernetes.io/version: {{ .Chart.AppVersion | quote }}
{{- end }}
app.kubernetes.io/managed-by: {{ .Release.Service }}
{{- end -}}
