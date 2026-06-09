{{- define "devops-app.name" -}}
{{- default .Chart.Name .Values.nameOverride | trunc 63 | trimSuffix "-" }}
{{- end }}

{{- define "devops-app.labels" }}
app: {{ include "devops-app.name" . }}
version: {{ .Chart.AppVersion }}
{{- end }}
