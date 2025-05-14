{{/*
Create the name of the chart: ReleaseName or nameOverride
*/}}
{{- define "openvault.name" -}}
{{- default .Release.Name .Values.nameOverride | trunc 63 | trimSuffix "-" -}}
{{- end -}}

{{/*
Create the frontend name: ReleaseName-frontendName
*/}}
{{- define "openvault.frontend.fullname" -}}
{{- printf "%s-%s" .Release.Name .Values.global.frontend.name | trunc 63 | trimSuffix "-" -}}
{{- end -}}
{{/*
Create the frontend url: ReleaseName.domain
*/}}
{{- define "openvault.frontend.url" -}}
{{- if .Values.global.frontend.url -}}
{{- .Values.global.frontend.url -}}
{{- else -}}
{{- printf "%s.%s" .Release.Name .Values.global.domain -}}
{{- end -}}
{{- end -}}

{{/*
Create the backend name: ReleaseName-backendName
*/}}
{{- define "openvault.backend.fullname" -}}
{{- printf "%s-%s" .Release.Name .Values.global.backend.name | trunc 63 | trimSuffix "-" -}}
{{- end -}}
{{/*
Create the backend url: backend.release.domain
*/}}
{{- define "openvault.backend.url" -}}
{{- if .Values.global.backend.url -}}
{{- .Values.global.backend.url -}}
{{- else -}}
{{- printf "%s.%s.%s" .Values.global.backend.name .Release.Name .Values.global.domain -}}
{{- end -}}
{{- end -}}
