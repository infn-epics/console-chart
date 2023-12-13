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