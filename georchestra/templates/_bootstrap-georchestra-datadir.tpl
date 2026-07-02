{{- define "georchestra.bootstrap_georchestra_datadir" -}}
- name: bootstrap-georchestra-datadir
  image: "{{ .Values.tooling.general.image.repository }}:{{ .Values.tooling.general.image.tag }}"
  command:
  - /bin/sh
  - -c
  - {{- if .Values.georchestra.datadir.git.ssh_secret }}
    mkdir -p /root/.ssh ;
    cp /ssh-secret/ssh-privatekey /root/.ssh/id_rsa ;
    chmod 0600 /root/.ssh/id_rsa ;
    rm -Rf /etc/georchestra ;
    {{- end }}
    if [ ! -f /etc/georchestra/default.properties ] ; then
      git clone --depth 1 --single-branch {{ .Values.georchestra.datadir.git.url }} -b {{ .Values.georchestra.datadir.git.ref }} /etc/georchestra ;
    fi ;
  {{- if or .Values.georchestra.datadir.git.ssh_secret .Values.georchestra.datadir.git.insecureSkipTlsVerify }}
  env:
    {{- if .Values.georchestra.datadir.git.ssh_secret }}
    - name: GIT_SSH_COMMAND
      value: ssh -o "IdentitiesOnly=yes" -o "StrictHostKeyChecking no"
    {{- end }}
    {{- if .Values.georchestra.datadir.git.insecureSkipTlsVerify }}
    - name: GIT_SSL_NO_VERIFY
      value: "true"
    {{- end }}
  {{- end }}
  volumeMounts:
  - mountPath: /etc/georchestra
    name: georchestra-datadir
  {{- if .Values.georchestra.datadir.git.ssh_secret }}
  - mountPath: /ssh-secret
    name: ssh-secret
  {{- end }}
{{- end -}}
