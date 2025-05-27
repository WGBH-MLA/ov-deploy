{{/*
Create the name of the chart: ReleaseName or nameOverride
*/}}
{{- define "openvault.name" -}}
{{- default .Release.Name .Values.nameOverride | trunc 63 | trimSuffix "-" -}}
{{- end -}}

{{/*
Create the backend name: ReleaseName-backendName
*/}}
{{- define "openvault.backend.fullname" -}}
{{- printf "%s-%s" (include "openvault.name" .) .Values.global.backend.name | trunc 63 | trimSuffix "-" -}}
{{- end -}}

{{/*
Create the frontend name: ReleaseName-frontendName
*/}}
{{- define "openvault.frontend.fullname" -}}
{{- printf "%s-%s" (include "openvault.name" .) .Values.global.frontend.name | trunc 63 | trimSuffix "-" -}}
{{- end -}}

{{/*
Create the frontend url: ReleaseName.domain
*/}}
{{- define "openvault.url" -}}
{{- if .Values.global.url -}}
{{- .Values.global.url -}}
{{- else -}}
{{- printf "%s.%s" (include "openvault.name" .) .Values.global.domain -}}
{{- end -}}
{{- end -}}
