# YAML ast-grep Patterns

Pattern reference for YAML files, including Helm charts and Kubernetes manifests.

**Language flag:** `-l yaml`

**Supported extensions:** `.yaml`, `.yml`

## Basic YAML Patterns

### Key-Value Pairs

```bash
# Simple key-value
sg -p '$KEY: $VALUE' -l yaml

# Specific keys
sg -p 'name: $VALUE' -l yaml
sg -p 'image: $VALUE' -l yaml
sg -p 'version: $VALUE' -l yaml

# Nested keys (note: YAML AST is flat, so deep nesting requires multiple patterns)
sg -p 'metadata:' -l yaml
sg -p '  name: $VALUE' -l yaml
```

### Lists

```bash
# List items
sg -p '- $ITEM' -l yaml

# Named lists
sg -p 'items:' -l yaml
sg -p 'containers:' -l yaml
sg -p 'env:' -l yaml
```

## Helm Charts

### Chart.yaml Patterns

```bash
# Chart metadata
sg -p 'apiVersion: $VERSION' -l yaml
sg -p 'name: $NAME' -l yaml
sg -p 'version: $VERSION' -l yaml
sg -p 'appVersion: $VERSION' -l yaml
sg -p 'description: $DESC' -l yaml

# Dependencies
sg -p 'dependencies:' -l yaml
sg -p '  - name: $NAME' -l yaml
sg -p '    version: $VERSION' -l yaml
sg -p '    repository: $REPO' -l yaml
```

### values.yaml Patterns

```bash
# Image configuration
sg -p 'image:' -l yaml
sg -p '  repository: $REPO' -l yaml
sg -p '  tag: $TAG' -l yaml
sg -p '  pullPolicy: $POLICY' -l yaml

# Replica count
sg -p 'replicaCount: $COUNT' -l yaml

# Resources
sg -p 'resources:' -l yaml
sg -p '  limits:' -l yaml
sg -p '  requests:' -l yaml
sg -p '    cpu: $VALUE' -l yaml
sg -p '    memory: $VALUE' -l yaml

# Service configuration
sg -p 'service:' -l yaml
sg -p '  type: $TYPE' -l yaml
sg -p '  port: $PORT' -l yaml

# Ingress
sg -p 'ingress:' -l yaml
sg -p '  enabled: $BOOL' -l yaml
sg -p '  hosts:' -l yaml

# Secrets and ConfigMaps
sg -p 'existingSecret: $NAME' -l yaml
sg -p 'existingConfigMap: $NAME' -l yaml

# Pod annotations
sg -p 'podAnnotations:' -l yaml

# Node selector and tolerations
sg -p 'nodeSelector:' -l yaml
sg -p 'tolerations:' -l yaml
sg -p 'affinity:' -l yaml
```

### Template Patterns (Helm Templating)

Note: ast-grep treats `{{ }}` as part of values, not as special syntax.

```bash
# .Values references
sg -p '{{ .Values.$PATH }}' -l yaml
sg -p '{{ .Release.Name }}' -l yaml
sg -p '{{ .Release.Namespace }}' -l yaml
sg -p '{{ .Chart.Name }}' -l yaml

# Include/define
sg -p '{{- include "$TEMPLATE" $DOT }}' -l yaml
sg -p '{{- define "$NAME" }}' -l yaml

# Conditionals
sg -p '{{- if $CONDITION }}' -l yaml
sg -p '{{- else }}' -l yaml
sg -p '{{- end }}' -l yaml

# Ranges
sg -p '{{- range $ITEMS }}' -l yaml
sg -p '{{ . }}' -l yaml

# With
sg -p '{{- with $VALUE }}' -l yaml
```

## Kubernetes Manifests

### Common Metadata

```bash
# API version and kind
sg -p 'apiVersion: $VERSION' -l yaml
sg -p 'kind: $KIND' -l yaml

# Specific kinds
sg -p 'kind: Deployment' -l yaml
sg -p 'kind: Service' -l yaml
sg -p 'kind: ConfigMap' -l yaml
sg -p 'kind: Secret' -l yaml
sg -p 'kind: Ingress' -l yaml
sg -p 'kind: Pod' -l yaml
sg -p 'kind: StatefulSet' -l yaml
sg -p 'kind: DaemonSet' -l yaml
sg -p 'kind: CronJob' -l yaml
sg -p 'kind: Job' -l yaml

# Metadata
sg -p 'metadata:' -l yaml
sg -p '  name: $NAME' -l yaml
sg -p '  namespace: $NAMESPACE' -l yaml
sg -p '  labels:' -l yaml
sg -p '  annotations:' -l yaml
```

### Kubernetes Labels

```bash
# Standard labels
sg -p 'app.kubernetes.io/name: $VALUE' -l yaml
sg -p 'app.kubernetes.io/instance: $VALUE' -l yaml
sg -p 'app.kubernetes.io/version: $VALUE' -l yaml
sg -p 'app.kubernetes.io/component: $VALUE' -l yaml
sg -p 'app.kubernetes.io/part-of: $VALUE' -l yaml
sg -p 'app.kubernetes.io/managed-by: $VALUE' -l yaml

# Legacy labels
sg -p 'app: $VALUE' -l yaml
sg -p 'release: $VALUE' -l yaml
sg -p 'chart: $VALUE' -l yaml
sg -p 'heritage: $VALUE' -l yaml
```

### Deployment Spec

```bash
# Deployment spec
sg -p 'spec:' -l yaml
sg -p '  replicas: $COUNT' -l yaml
sg -p '  selector:' -l yaml
sg -p '    matchLabels:' -l yaml
sg -p '  template:' -l yaml

# Strategy
sg -p '  strategy:' -l yaml
sg -p '    type: $TYPE' -l yaml
sg -p '    rollingUpdate:' -l yaml
```

### Container Spec

```bash
# Container definition
sg -p 'containers:' -l yaml
sg -p '  - name: $NAME' -l yaml
sg -p '    image: $IMAGE' -l yaml
sg -p '    imagePullPolicy: $POLICY' -l yaml

# Ports
sg -p '    ports:' -l yaml
sg -p '      - containerPort: $PORT' -l yaml
sg -p '        protocol: $PROTOCOL' -l yaml

# Environment variables
sg -p '    env:' -l yaml
sg -p '      - name: $NAME' -l yaml
sg -p '        value: $VALUE' -l yaml
sg -p '        valueFrom:' -l yaml
sg -p '          secretKeyRef:' -l yaml
sg -p '          configMapKeyRef:' -l yaml
sg -p '          fieldRef:' -l yaml

# Resources
sg -p '    resources:' -l yaml
sg -p '      limits:' -l yaml
sg -p '      requests:' -l yaml

# Probes
sg -p '    livenessProbe:' -l yaml
sg -p '    readinessProbe:' -l yaml
sg -p '    startupProbe:' -l yaml
sg -p '      httpGet:' -l yaml
sg -p '        path: $PATH' -l yaml
sg -p '        port: $PORT' -l yaml
sg -p '      initialDelaySeconds: $SECONDS' -l yaml
sg -p '      periodSeconds: $SECONDS' -l yaml

# Volume mounts
sg -p '    volumeMounts:' -l yaml
sg -p '      - name: $NAME' -l yaml
sg -p '        mountPath: $PATH' -l yaml

# Security context
sg -p '    securityContext:' -l yaml
sg -p '      runAsUser: $UID' -l yaml
sg -p '      runAsNonRoot: $BOOL' -l yaml
sg -p '      readOnlyRootFilesystem: $BOOL' -l yaml
```

### Volumes

```bash
sg -p '  volumes:' -l yaml
sg -p '    - name: $NAME' -l yaml
sg -p '      configMap:' -l yaml
sg -p '        name: $NAME' -l yaml
sg -p '      secret:' -l yaml
sg -p '        secretName: $NAME' -l yaml
sg -p '      persistentVolumeClaim:' -l yaml
sg -p '        claimName: $NAME' -l yaml
sg -p '      emptyDir: {}' -l yaml
sg -p '      hostPath:' -l yaml
sg -p '        path: $PATH' -l yaml
```

### Service Spec

```bash
sg -p 'spec:' -l yaml
sg -p '  type: $TYPE' -l yaml
sg -p '  ports:' -l yaml
sg -p '    - port: $PORT' -l yaml
sg -p '      targetPort: $PORT' -l yaml
sg -p '      protocol: $PROTOCOL' -l yaml
sg -p '  selector:' -l yaml
```

### Ingress Spec

```bash
sg -p 'spec:' -l yaml
sg -p '  ingressClassName: $CLASS' -l yaml
sg -p '  tls:' -l yaml
sg -p '    - hosts:' -l yaml
sg -p '      secretName: $SECRET' -l yaml
sg -p '  rules:' -l yaml
sg -p '    - host: $HOST' -l yaml
sg -p '      http:' -l yaml
sg -p '        paths:' -l yaml
sg -p '          - path: $PATH' -l yaml
sg -p '            pathType: $TYPE' -l yaml
```

### ConfigMap and Secret

```bash
# ConfigMap
sg -p 'data:' -l yaml
sg -p '  $KEY: $VALUE' -l yaml

# Secret
sg -p 'stringData:' -l yaml
sg -p 'type: $TYPE' -l yaml
```

## Common Audit Patterns

### Security Issues

```bash
# Running as root
sg -p 'runAsUser: 0' -l yaml
sg -p 'runAsNonRoot: false' -l yaml

# Privileged containers
sg -p 'privileged: true' -l yaml

# Host network/PID
sg -p 'hostNetwork: true' -l yaml
sg -p 'hostPID: true' -l yaml

# No resource limits
sg -p 'containers:' -l yaml | grep -v "resources:"

# Latest tag
sg -p 'image: $REPO:latest' -l yaml
sg -p 'tag: latest' -l yaml

# Hardcoded secrets
sg -p 'password: $VALUE' -l yaml
sg -p 'apiKey: $VALUE' -l yaml
sg -p 'secret: $VALUE' -l yaml
```

### Best Practices

```bash
# Missing probes
sg -p 'containers:' -l yaml | grep -v "livenessProbe"

# No pull policy
sg -p 'containers:' -l yaml | grep -v "imagePullPolicy"

# Missing labels
sg -p 'metadata:' -l yaml | grep -v "labels:"

# Service without selector
sg -p 'kind: Service' -l yaml
```

## Common Refactoring

```bash
# Update image tag
sg -p 'tag: "v1.0.0"' -r 'tag: "v2.0.0"' -l yaml

# Change replica count
sg -p 'replicaCount: 1' -r 'replicaCount: 3' -l yaml

# Update resource limits
sg -p 'memory: 128Mi' -r 'memory: 256Mi' -l yaml

# Change service type
sg -p 'type: ClusterIP' -r 'type: LoadBalancer' -l yaml

# Add missing pull policy
sg -p '    image: $IMAGE' -r '    image: $IMAGE\n    imagePullPolicy: IfNotPresent' -l yaml
```

## GitHub Actions (YAML)

```bash
# Workflow triggers
sg -p 'on:' -l yaml
sg -p '  push:' -l yaml
sg -p '  pull_request:' -l yaml
sg -p '  schedule:' -l yaml
sg -p '  workflow_dispatch:' -l yaml

# Jobs
sg -p 'jobs:' -l yaml
sg -p '  $JOB:' -l yaml
sg -p '    runs-on: $RUNNER' -l yaml
sg -p '    steps:' -l yaml

# Steps
sg -p '      - uses: $ACTION' -l yaml
sg -p '      - run: $COMMAND' -l yaml
sg -p '      - name: $NAME' -l yaml

# With parameters
sg -p '        with:' -l yaml

# Environment
sg -p '        env:' -l yaml
sg -p '          $VAR: $VALUE' -l yaml

# Secrets
sg -p '${{ secrets.$NAME }}' -l yaml
```
