apiVersion: apps/v1
kind: StatefulSet
metadata:
  name: greenplum-exporter-{{VERSION}}
  namespace: greenplum
spec:
  serviceName: greenplum-exporter-{{VERSION}}
  replicas: 1
  selector:
    matchLabels:
      app: greenplum-exporter-{{VERSION}}
  template:
    metadata:
      annotations:
        telegraf.influxdata.com/interval: 1s
        telegraf.influxdata.com/inputs: |+
          [[inputs.cpu]]
            percpu = false
            totalcpu = true
            collect_cpu_time = true
            report_active = true

          [[inputs.disk]]
            ignore_fs = ["tmpfs", "devtmpfs", "devfs", "iso9660", "overlay", "aufs", "squashfs"]

          [[inputs.diskio]]

          [[inputs.kernel]]

          [[inputs.mem]]

          [[inputs.processes]]

          [[inputs.system]]
            fielddrop = ["uptime_format"]

          [[inputs.net]]
            ignore_protocol_stats = true

          [[inputs.procstat]]
          ## pattern as argument for pgrep (ie, pgrep -f <pattern>)
            pattern = "exporter"
        telegraf.influxdata.com/class: opentsdb
        telegraf.influxdata.com/env-fieldref-NAMESPACE: metadata.namespace
        telegraf.influxdata.com/limits-cpu: '300m'
        telegraf.influxdata.com/limits-memory: '300Mi'
      labels:
        app: greenplum-exporter-{{VERSION}}
        exporter_type: greenplum
        pod_type: exporter
    spec:
      nodeSelector:
        node-role: worker
      shareProcessNamespace: true
      containers:
      - name: greenplum-exporter-{{VERSION}}
        image: registry-svc:25000/library/greenplum-exporter:latest
        imagePullPolicy: Always
        envFrom:
          - configMapRef:
              name: greenplum-dsn-{{VERSION}}
        securityContext:
          allowPrivilegeEscalation: false
          runAsUser: 0
        resources:
          requests:
            cpu: 100m
            memory: 100Mi
          limits:
            cpu: 300m
            memory: 300Mi
        ports:
        - containerPort: 9297

---
apiVersion: v1
kind: Service
metadata:
  labels:
    app: greenplum-exporter-{{VERSION}}
  name: greenplum-exporter-{{VERSION}}
  namespace: greenplum
  annotations:
    prometheus.io/scrape: "true"
    prometheus.io/port: "9297"
    prometheus.io/path: '/metrics'
spec:
  ports:
  - port: 9297
    protocol: TCP
    targetPort: 9297
  selector:
    app: greenplum-exporter-{{VERSION}}
