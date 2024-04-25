{{/*
Render configs/values.yaml
*/}}
{{- define "kubeflow_installer.image" -}}
{{ .Values.kubeflow_installer.registry }}/{{ .Values.kubeflow_installer.repository }}:{{ .Values.kubeflow_installer.tag }}
{{- end -}}

{{- define "chart.rendered-values" -}}
{{ if .Values.use_external_mysql }}
{{- tpl (.Files.Get "configs/values.yaml") . -}}
{{ else }}
{{- tpl (.Files.Get "configs/included-mysql-values.yaml") . -}}
{{ end }}
{{- end -}}

{{- define "chart.app-of-apps" -}}
apiVersion: argoproj.io/v1alpha1
kind: Application
metadata:
  name: deploykf-app-of-apps
  namespace: argocd
  labels:
    app.kubernetes.io/name: deploykf-app-of-apps
    app.kubernetes.io/part-of: deploykf
spec:
  project: "default"
  source:
    ## source git repo configuration
    ##  - we use the 'deploykf/deploykf' repo so we can read its 'sample-values.yaml'
    ##    file, but you may use any repo (even one with no files)
    ##
    repoURL: "https://github.com/deployKF/deployKF.git"
    targetRevision: "v0.1.3" # <-- replace with a deployKF repo tag!
    path: "."

    ## plugin configuration
    ##
    plugin:
      name: "deploykf"
      parameters:

        ## the deployKF generator version
        ##  - available versions: https://github.com/deployKF/deployKF/releases
        ##
        - name: "source_version"
          string: "0.1.3" # <-- replace with a deployKF generator version!

        ## paths to values files within the `repoURL` repository
        ##  - the values in these files are merged, with later files taking precedence
        ##  - we strongly recommend using 'sample-values.yaml' as the base of your values
        ##    so you can easily upgrade to newer versions of deployKF
        ##
        - name: "values_files"
          array:
            - "./sample-values.yaml"

        ## a string containing the contents of a values file
        ##  - this parameter allows defining values without needing to create a file in the repo
        ##  - these values are merged with higher precedence than those defined in `values_files`
        ##
        - name: "values"
          string: |-
{{ include "chart.rendered-values" . | indent 12 }}
  destination:
    server: "https://kubernetes.default.svc"
    namespace: "argocd"
{{- end -}}