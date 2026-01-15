---
name: helm
description: Kubernetes Helm chart development. Use when asked to "create helm chart", "configure kubernetes deployment", or "add helm template". Covers values.yaml, templates, and subchart patterns.
license: MIT
triggers:
  [
    "helm",
    "helms",
    "heml",
    "chart\\.yaml",
    "values\\.yaml",
    "\\.tpl$",
    "_helpers\\.tpl",
    "kubernetes",
    "k8s",
    "kube",
    "deploy.*kubernetes",
    "kubernetes.*deploy",
    "subchart",
    "helm\\s+(install|upgrade|template|lint|package)",
    "\\{\\{-?\\s*(define|include|template)",
    "\\.Values\\.",
    "\\.Release\\.",
    "\\.Chart\\.",
    "bitnami",
    "artifacthub",
    "chart\\s*dependenc",
    "helm\\s*repo",
    "helmfile",
  ]
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
