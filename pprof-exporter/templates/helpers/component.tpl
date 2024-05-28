{{/* vim: set filetype=mustache: */}}
{{/*
Expand the name of the chart.
*/}}
{{- define "component.name" -}}
{{- default .Chart.Name .Values.nameOverride | trunc 63 | trimSuffix "-" }}
{{- end }}

{{/*
Create a default fully qualified app name.
We truncate at 63 chars because some Kubernetes name fields are limited to this (by the DNS naming spec).
If release name contains chart name it will be used as a full name.
*/}}
{{- define "component.fullname" -}}
{{- if .Values.fullnameOverride }}
{{- .Values.fullnameOverride | trunc 63 | trimSuffix "-" }}
{{- else }}
{{- $name := default .Chart.Name .Values.nameOverride }}
{{- if contains $name .Release.Name }}
{{- .Release.Name | trunc 63 | trimSuffix "-" }}
{{- else }}
{{- printf "%s-%s" .Release.Name $name | trunc 63 | trimSuffix "-" }}
{{- end }}
{{- end }}
{{- end }}

{{/*
Selector labels
*/}}
{{- define "component.selectorLabels" -}}
app: {{ include "component.name" . }}
app.kubernetes.io/name: {{ include "component.name" . }}
app.kubernetes.io/instance: {{ .Release.Name }}
{{- end }}

{{/*
Common labels
*/}}
{{- define "component.labels" -}}
helm.sh/chart: {{ include "component.chart" . }}
{{ include "component.selectorLabels" . }}
{{- if .Chart.AppVersion }}
app.kubernetes.io/version: {{ .Chart.AppVersion | quote }}
{{- end }}
app.kubernetes.io/managed-by: {{ .Release.Service }}
{{- end }}

{{/*
Create chart name and version as used by the chart label.
*/}}
{{- define "component.chart" -}}
{{- printf "%s-%s" .Chart.Name .Chart.Version | replace "+" "_" | trunc 63 | trimSuffix "-" }}
{{- end }}

{{/*
Returns Prometheus metrics' annotations depending on input Values
*/}}
{{- define "component.metricsAnnotations" -}}
prometheus.io/scrape: {{ default false .enabled | print | quote }}
prometheus.io/port: {{ default 4242 .port | print | quote }}
prometheus.io/path: {{ default "/metrics" .endpoint | print | quote }}
{{- end }}

{{/*
Returns replica count depending on global Values and HPA settings
*/}}
{{- define "component.replicaCount" -}}
{{- if  not (and .Values.autoscaling .Values.autoscaling.enabled) }}
{{- if and .Values.profile.enabled }}
replicas: {{ get .Values.profile.replicas .Chart.Name }}
{{- else }}
replicas: {{ .Values.replicaCount }}
{{- end }}
{{- end }}
{{- end }}

{{/*
Returns full docker image name 
*/}}
{{- define "component.image" -}}
{{ printf "%s:%s" (print .repository) (print .tag) }}
{{- end }}

{{/*
Returns container ports configuration depending on input service
*/}}
{{- define "component.port" -}}
- name: {{ .name }}
  containerPort: {{ default .port .internalPort }}
  protocol: TCP
{{- end }}

{{/*
Returns component's resource consumption
*/}}
{{- define "component.resources" -}}
{{- if .Values.profile.enabled }}
{{- with .Values.profile }}
resources:
  {{- with .requests }}
  requests:
    cpu: {{ .cpu }}
    memory: {{ .memory }}
  {{- end }}
  {{- with .limits }}
  limits:
    cpu: {{ .cpu }}
    memory: {{ .memory }}
  {{- end }}
{{- end }}
{{- end }}
{{- end }}

{{/*
Returns component's probes
*/}}
{{- define "component.probes" -}}
{{- $svc := get .Values.services .subservice }}
{{- $port := default $svc.port $svc.internalPort }}
{{- range $name, $probe := .Values.probes }}
{{ printf "%sProbe" $name }}:
  httpGet:
    path: {{ default "/health" $probe.path }}
    port: {{ default $port $probe.port }}
  initialDelaySeconds: {{ default 5 $probe.initialDelaySeconds }}
  timeoutSeconds: {{ default 10 $probe.timeoutSeconds }}
  periodSeconds: {{ default 10 $probe.periodSeconds }}
{{- end }}
{{- end }}

{{/*
Returns personal and global component's image pull secrets
*/}}
{{- define "component.imagePullSecrets" -}}
imagePullSecrets:
{{- if .Values.image.pullSecret }}      
- name: {{ .Values.image.pullSecret }}
{{- end }}
{{- end }}

{{/*
Returns personal and global component's node selector labels
*/}}
{{- define "component.nodeSelectorLabels" -}}
nodeSelector:
  {{- if .Values.nodeSelector }}
  {{ toYaml .Values.nodeSelector | nindent 2 }}
  {{- end }}
{{- end }}

{{/*
Returns personal and global component's tolerations
*/}}
{{- define "component.tolerations" -}}
tolerations:
{{- if .Values.tolerations }}
{{ toYaml .Values.tolerations }}
{{- end }}
{{- end }}

{{/*
Returns component pod's affinity
*/}}
{{- define "component.affinity" -}}
affinity:
  {{- if .Values.affinity }}
  {{ toYaml .Values.affinity | nindent 2 }}
  {{- end }}
{{- end }}
