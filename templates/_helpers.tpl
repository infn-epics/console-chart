# epics-console-chart/templates/_helpers.tpl
{{- define "epics-console-chart.fullname" -}}
{{- printf "%s-%s" .Release.Name .Chart.Name }}
{{- end -}}

{{- define "epics-console-chart.name" -}}
{{- .Chart.Name }}
{{- end -}}
{{- define "epics-console-chart.release" -}}
{{- .Release.Name }}
{{- end -}}

{{- define "epics-console.labels" -}}
helm.sh/chart: {{ include "epics-console.chart" . }}
{{ include "epics-console.selectorLabels" . }}
{{- if .Chart.AppVersion }}
app.kubernetes.io/version: {{ .Chart.AppVersion | quote }}
{{- end }}
app.kubernetes.io/managed-by: {{ .Release.Service }}
{{- end }}

{{- define "epics-console.selectorLabels" -}}
app.kubernetes.io/name: {{ include "epics-console-chart.name" . }}
app.kubernetes.io/instance: {{ .Release.Name }}
beamline: {{ .Values.beamline | quote }}
{{- end }}

{{- define "epics-console.chart" -}}
{{- printf "%s-%s" .Chart.Name .Chart.Version | replace "+" "_" | trunc 63 | trimSuffix "-" }}
{{- end }}