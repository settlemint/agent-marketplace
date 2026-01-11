---
name: helm
description: Kubernetes Helm chart development with values.yaml, templates, and subchart patterns. Triggers on helm, chart, kubernetes, values.yaml.
triggers: ["helm", "chart", "kubernetes", "k8s", "values\\.yaml", "\\.tpl"]
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
  reasoning: "Need to configure external chart correctly"
})
```
</mcp_first>

<quick_start>
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
  reasoning: "Avoid custom workaround if chart supports it natively"
})
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

<success_criteria>
- [ ] All values have `# -- (type)` annotations
- [ ] Uses `.Values` references (no hardcoding)
- [ ] Standard Kubernetes labels
- [ ] `existingSecret` pattern for secrets
- [ ] `helm lint` passes with 0 warnings
- [ ] External charts researched before workarounds
</success_criteria>
