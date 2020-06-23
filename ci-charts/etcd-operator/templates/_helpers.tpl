{{/* vim: set filetype=mustache: */}}
{{/*
Expand the name of the chart.
*/}}
{{- define "etcd-operator.name" -}}
{{- default .Chart.Name .Values.nameOverride | trunc 63 | trimSuffix "-" -}}
{{- end -}}

{{/*
Create a default fully qualified app name.
We truncate at 63 chars because some Kubernetes name fields are limited to this (by the DNS naming spec).
*/}}
{{- define "etcd-operator.fullname" -}}
{{- printf "%s-%s" .Values.etcdOperator.name .Release.Name | trunc 63 | trimSuffix "-" -}}
{{- end -}}

{{- define "etcd-backup-operator.name" -}}
{{- default .Chart.Name .Values.backupOperator.name | trunc 63 | trimSuffix "-" -}}
{{- end -}}

{{/*
Create a default fully qualified app name.
We truncate at 63 chars because some Kubernetes name fields are limited to this (by the DNS naming spec).
*/}}
{{- define "etcd-backup-operator.fullname" -}}
{{- printf "%s-%s" .Values.backupOperator.name .Release.Name | trunc 63 | trimSuffix "-" -}}
{{- end -}}

{{- define "etcd-restore-operator.name" -}}
{{- default .Chart.Name .Values.restoreOperator.name | trunc 63 | trimSuffix "-" -}}
{{- end -}}

{{/*
Create a default fully qualified app name.
We truncate at 63 chars because some Kubernetes name fields are limited to this (by the DNS naming spec).
*/}}
{{- define "etcd-restore-operator.fullname" -}}
{{- printf "%s-%s" .Values.restoreOperator.name .Release.Name | trunc 63 | trimSuffix "-" -}}
{{- end -}}

{{/*
Create the name of the etcd-operator service account to use
*/}}
{{- define "etcd-operator.serviceAccountName" -}}
{{- if .Values.serviceAccount.etcdOperatorServiceAccount.create -}}
    {{ default (include "etcd-operator.name" .) .Values.serviceAccount.etcdOperatorServiceAccount.name }}
{{- else -}}
    {{ default "default" .Values.serviceAccount.etcdOperatorServiceAccount.name }}
{{- end -}}
{{- end -}}

{{/*
Create the name of the backup-operator service account to use 
*/}}
{{- define "etcd-backup-operator.serviceAccountName" -}}
{{- if .Values.serviceAccount.backupOperatorServiceAccount.create -}}
    {{ default (include "etcd-backup-operator.name" .) .Values.serviceAccount.backupOperatorServiceAccount.name }}
{{- else -}}
    {{ default "default" .Values.serviceAccount.backupOperatorServiceAccount.name }}
{{- end -}}
{{- end -}}

{{/*
Create the name of the restore-operator service account to use 
*/}}
{{- define "etcd-restore-operator.serviceAccountName" -}}
{{- if .Values.serviceAccount.restoreOperatorServiceAccount.create -}}
    {{ default (include "etcd-restore-operator.name" .) .Values.serviceAccount.restoreOperatorServiceAccount.name }}
{{- else -}}
    {{ default "default" .Values.serviceAccount.restoreOperatorServiceAccount.name }}
{{- end -}}
{{- end -}}
