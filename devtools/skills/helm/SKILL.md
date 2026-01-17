---
name: helm
description: Use when creating Helm charts, configuring Kubernetes deployments, or adding Helm templates. Covers values.yaml, templates, and subchart patterns.
license: MIT
triggers:
  # Intent triggers
  - "create helm chart"
  - "configure kubernetes deployment"
  - "add helm template"
  - "deploy to kubernetes"
  - "helm install"
  - "helm upgrade"

  # Artifact triggers
  - "helm"
  - "Chart\\.yaml"
  - "values\\.yaml"
  - "_helpers\\.tpl"
  - "kubernetes"
  - "k8s"
  - "\\.Values\\."
  - "\\.Release\\."
  - "bitnami"
  - "helmfile"
---

<objective>
Build Kubernetes Helm charts with proper values structure, template helpers, and subchart organization. Follow Bitnami-style conventions for consistency.
</objective>

<mcp_first>
**CRITICAL: Use OctoCode to research external chart capabilities before implementing workarounds.**

```
MCPSearch({ query: "select:mcp__plugin_devtools_octocode__githubSearchCode" })
```

```typescript
// Research external chart values
mcp__octocode__githubGetFileContent({
  owner: "bitnami",
  repo: "charts",
  path: "bitnami/postgresql/values.yaml",
  matchString: "primary",
  mainResearchGoal: "Understand Bitnami chart patterns",
  researchGoal: "Find PostgreSQL configuration options",
  reasoning: "Need to configure external chart correctly",
});
```

</mcp_first>

<quick_start>
**Workflow:**
1. Create `Chart.yaml` with metadata
2. Define `values.yaml` with annotated defaults
3. Create `templates/_helpers.tpl` for shared logic
4. Build resource templates (deployment, service, etc.)
5. Run `helm lint` to validate

**Chart structure:**

```
my-chart/
├── Chart.yaml          # Chart metadata
├── values.yaml         # Default configuration
├── templates/
│   ├── _helpers.tpl    # Template helpers
│   ├── deployment.yaml
│   ├── service.yaml
│   └── configmap.yaml
└── charts/             # Subcharts (optional)
```

**Values annotation (required for readme-generator):**

```yaml
# -- (string) Image repository
image:
  # -- (string) Image registry
  registry: docker.io
  # -- (string) Image name
  repository: my-app
  # -- (string) Image tag
  tag: latest

# -- (int) Number of replicas
replicaCount: 1

# -- (bool) Enable debug mode
debug: false
```

**Template helper:**

```yaml
{{/* Generate labels */}}
{{- define "mychart.labels" -}}
app.kubernetes.io/name: {{ include "mychart.name" . }}
app.kubernetes.io/instance: {{ .Release.Name }}
{{- end }}
```

</quick_start>

<constraints>
**Banned:**
- Hardcoded values in templates — use `.Values`
- Changing label selectors after deployment
- Secrets in values.yaml — use `existingSecret` pattern
- Missing `# -- (type)` annotations
- Template files over 200 lines

**Required:**

- Every values field: `# -- (type) description` annotation
- Standard Kubernetes labels (`app.kubernetes.io/*`)
- Support both inline and `existingSecret` for secrets
- Init containers for service dependencies

**Naming:** Charts=`kebab-case`, Templates=`<resource>.yaml`, Values=`camelCase`
</constraints>

<anti_patterns>

- Hardcoding values that should be configurable
- Changing label selectors on existing deployments (breaks updates)
- Putting secrets directly in values.yaml
- Template files over 200 lines without splitting
- Building workarounds before researching external chart capabilities
  </anti_patterns>

<external_charts>
**Always research external chart capabilities before workarounds:**

1. Find the upstream chart repository
2. Read the chart's `values.yaml`
3. Check chart documentation
4. Use OctoCode to search templates

```typescript
mcp__octocode__githubGetFileContent({
  owner: "grafana",
  repo: "helm-charts",
  path: "charts/grafana/values.yaml",
  matchString: "rbac",
  mainResearchGoal: "Find Grafana RBAC options",
  researchGoal: "Check if namespace-scoped RBAC is supported",
  reasoning: "Avoid custom workaround if chart supports it natively",
});
```

</external_charts>

<commands>
```bash
helm lint ./my-chart           # Lint chart
helm template my-chart ./my-chart --debug  # Render templates
helm dependency update ./my-chart  # Update dependencies
helm install my-release ./my-chart # Install
```
</commands>

<library_ids>
Skip resolve step for these known IDs:

| Library | Context7 ID |
| ------- | ----------- |
| Helm    | /helm/helm  |

</library_ids>

<research>
**Find patterns on GitHub when stuck:**

```typescript
mcp__plugin_devtools_octocode__githubSearchCode({
  queries: [
    {
      mainResearchGoal: "Find production Helm chart patterns",
      researchGoal: "Search for template and values patterns",
      reasoning: "Need real-world examples of Helm usage",
      keywordsToSearch: [".Values", "define", "include", "template"],
      extension: "yaml",
      limit: 10,
    },
  ],
});
```

**Common searches:**

- Templates: `keywordsToSearch: ["define", "include", "_helpers.tpl"]`
- Values patterns: `keywordsToSearch: [".Values", "existingSecret", "enabled"]`
- Labels: `keywordsToSearch: ["app.kubernetes.io", "labels", "selectorLabels"]`
- Dependencies: `keywordsToSearch: ["Chart.yaml", "dependencies", "subchart"]`
  </research>

<few_shot_examples>
<example name="basic-deployment-chart">
<input>Create a Helm chart for a Node.js API service with configurable replicas and image</input>
<output>
**Chart.yaml:**
```yaml
apiVersion: v2
name: node-api
description: A Helm chart for Node.js API service
type: application
version: 0.1.0
appVersion: "1.0.0"
```

**values.yaml:**
```yaml
# -- (int) Number of replicas
replicaCount: 2

image:
  # -- (string) Image registry
  registry: docker.io
  # -- (string) Image repository
  repository: myorg/node-api
  # -- (string) Image tag (defaults to chart appVersion)
  tag: ""
  # -- (string) Image pull policy
  pullPolicy: IfNotPresent

# -- (list) Image pull secrets
imagePullSecrets: []

service:
  # -- (string) Service type
  type: ClusterIP
  # -- (int) Service port
  port: 3000

resources:
  # -- (object) Resource limits
  limits:
    cpu: 200m
    memory: 256Mi
  # -- (object) Resource requests
  requests:
    cpu: 100m
    memory: 128Mi
```

**templates/_helpers.tpl:**
```yaml
{{/* Chart name */}}
{{- define "node-api.name" -}}
{{- default .Chart.Name .Values.nameOverride | trunc 63 | trimSuffix "-" }}
{{- end }}

{{/* Full name */}}
{{- define "node-api.fullname" -}}
{{- if .Values.fullnameOverride }}
{{- .Values.fullnameOverride | trunc 63 | trimSuffix "-" }}
{{- else }}
{{- $name := default .Chart.Name .Values.nameOverride }}
{{- printf "%s-%s" .Release.Name $name | trunc 63 | trimSuffix "-" }}
{{- end }}
{{- end }}

{{/* Labels */}}
{{- define "node-api.labels" -}}
helm.sh/chart: {{ printf "%s-%s" .Chart.Name .Chart.Version | replace "+" "_" }}
{{ include "node-api.selectorLabels" . }}
app.kubernetes.io/version: {{ .Values.image.tag | default .Chart.AppVersion | quote }}
app.kubernetes.io/managed-by: {{ .Release.Service }}
{{- end }}

{{/* Selector labels */}}
{{- define "node-api.selectorLabels" -}}
app.kubernetes.io/name: {{ include "node-api.name" . }}
app.kubernetes.io/instance: {{ .Release.Name }}
{{- end }}

{{/* Image */}}
{{- define "node-api.image" -}}
{{ printf "%s/%s:%s" .Values.image.registry .Values.image.repository (.Values.image.tag | default .Chart.AppVersion) }}
{{- end }}
```

**templates/deployment.yaml:**
```yaml
apiVersion: apps/v1
kind: Deployment
metadata:
  name: {{ include "node-api.fullname" . }}
  labels:
    {{- include "node-api.labels" . | nindent 4 }}
spec:
  replicas: {{ .Values.replicaCount }}
  selector:
    matchLabels:
      {{- include "node-api.selectorLabels" . | nindent 6 }}
  template:
    metadata:
      labels:
        {{- include "node-api.selectorLabels" . | nindent 8 }}
    spec:
      {{- with .Values.imagePullSecrets }}
      imagePullSecrets:
        {{- toYaml . | nindent 8 }}
      {{- end }}
      containers:
        - name: {{ .Chart.Name }}
          image: {{ include "node-api.image" . }}
          imagePullPolicy: {{ .Values.image.pullPolicy }}
          ports:
            - name: http
              containerPort: {{ .Values.service.port }}
              protocol: TCP
          resources:
            {{- toYaml .Values.resources | nindent 12 }}
```
</output>
<reasoning>Uses standard Kubernetes labels, template helpers for DRY, annotated values for documentation, and configurable resources. Selector labels are stable (don't include version).</reasoning>
</example>

<example name="secret-with-existing-pattern">
<input>Add database connection configuration that supports both inline values and existing secret</input>
<output>
**values.yaml addition:**
```yaml
database:
  # -- (string) Database host
  host: localhost
  # -- (int) Database port
  port: 5432
  # -- (string) Database name
  name: myapp
  # -- (string) Database user (ignored if existingSecret is set)
  user: postgres
  # -- (string) Database password (ignored if existingSecret is set)
  password: ""
  # -- (string) Name of existing secret containing database credentials
  # Keys expected: DB_USER, DB_PASSWORD
  existingSecret: ""
```

**templates/secret.yaml:**
```yaml
{{- if not .Values.database.existingSecret }}
apiVersion: v1
kind: Secret
metadata:
  name: {{ include "node-api.fullname" . }}-db
  labels:
    {{- include "node-api.labels" . | nindent 4 }}
type: Opaque
stringData:
  DB_USER: {{ .Values.database.user | quote }}
  DB_PASSWORD: {{ .Values.database.password | quote }}
{{- end }}
```

**templates/deployment.yaml env addition:**
```yaml
env:
  - name: DB_HOST
    value: {{ .Values.database.host | quote }}
  - name: DB_PORT
    value: {{ .Values.database.port | quote }}
  - name: DB_NAME
    value: {{ .Values.database.name | quote }}
  - name: DB_USER
    valueFrom:
      secretKeyRef:
        name: {{ .Values.database.existingSecret | default (printf "%s-db" (include "node-api.fullname" .)) }}
        key: DB_USER
  - name: DB_PASSWORD
    valueFrom:
      secretKeyRef:
        name: {{ .Values.database.existingSecret | default (printf "%s-db" (include "node-api.fullname" .)) }}
        key: DB_PASSWORD
```
</output>
<reasoning>Supports both inline secrets (for dev) and existingSecret (for prod). Conditional secret creation prevents duplicate secrets. Standardizes key names for consistency.</reasoning>
</example>
</few_shot_examples>

<related_skills>

**Infrastructure provisioning:** Load via `Skill({ skill: "devtools:terraform" })` when:

- Provisioning Kubernetes cluster before chart deployment
- Managing cloud infrastructure for Helm releases

**Container builds:** Load via `Skill({ skill: "devtools:turbo" })` when:

- Building container images in monorepo
- CI/CD pipelines that build then deploy charts
  </related_skills>

<success_criteria>

1. [ ] All values have `# -- (type)` annotations
2. [ ] Uses `.Values` references (no hardcoding)
3. [ ] Standard Kubernetes labels applied
4. [ ] `existingSecret` pattern for secrets
5. [ ] `helm lint` passes with 0 warnings
6. [ ] External charts researched before workarounds
</success_criteria>

<evolution>
**Extension Points:**
- Create reusable template helpers in _helpers.tpl
- Add conditional resources for optional features
- Build umbrella charts for complex deployments

**Timelessness:** Helm remains the de facto standard for Kubernetes package management; these patterns apply across cloud providers.
</evolution>
