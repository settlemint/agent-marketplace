---
name: recharts
description: Recharts for React data visualization. Covers line, bar, area, pie charts with responsive containers and customization. Triggers on recharts, chart, LineChart, BarChart.
license: MIT
triggers:
  - "recharts"
  - "chart"
  - "LineChart"
  - "BarChart"
  - "AreaChart"
  - "PieChart"
  - "ScatterChart"
  - "RadarChart"
  - "ComposedChart"
  - "ResponsiveContainer"
  - "graph"
  - "data.?viz"
  - "visualization"
  - "visualize.?data"
  - "plot"
  - "histogram"
  - "trend.?line"
  - "sparkline"
  - "metrics.?chart"
  - "analytics.?chart"
  - "dashboard.?chart"
  - "XAxis"
  - "YAxis"
  - "Tooltip"
  - "CartesianGrid"
  - "Legend"
  - "time.?series"
  - "display.?data"
  - "show.?data.?over.?time"
---

<objective>
Build data visualizations using Recharts - a composable React charting library built on D3. Create responsive, interactive charts with minimal code.
</objective>

<mcp_first>
**CRITICAL: Fetch Recharts documentation before implementing.**

```
MCPSearch({ query: "select:mcp__plugin_devtools_octocode__githubSearchCode" })
```

```typescript
// Recharts component patterns
mcp__octocode__githubSearchCode({
  keywordsToSearch: ["LineChart", "XAxis", "YAxis", "Tooltip"],
  owner: "recharts",
  repo: "recharts",
  path: "src/chart",
  mainResearchGoal: "Understand Recharts component structure",
  researchGoal: "Find chart composition patterns",
  reasoning: "Need current API for chart components",
});

// ResponsiveContainer
mcp__octocode__githubSearchCode({
  keywordsToSearch: ["ResponsiveContainer", "width", "height"],
  owner: "recharts",
  repo: "recharts",
  path: "src/component",
  mainResearchGoal: "Understand responsive charts",
  researchGoal: "Find responsive container patterns",
  reasoning: "Need current API for responsive charts",
});
```

</mcp_first>

<quick_start>
**Line chart:**

```tsx
import {
  LineChart,
  Line,
  XAxis,
  YAxis,
  CartesianGrid,
  Tooltip,
  Legend,
  ResponsiveContainer,
} from "recharts";

const data = [
  { month: "Jan", sales: 4000, profit: 2400 },
  { month: "Feb", sales: 3000, profit: 1398 },
  { month: "Mar", sales: 2000, profit: 9800 },
];

function SalesChart() {
  return (
    <ResponsiveContainer width="100%" height={400}>
      <LineChart data={data}>
        <CartesianGrid strokeDasharray="3 3" />
        <XAxis dataKey="month" />
        <YAxis />
        <Tooltip />
        <Legend />
        <Line type="monotone" dataKey="sales" stroke="#8884d8" />
        <Line type="monotone" dataKey="profit" stroke="#82ca9d" />
      </LineChart>
    </ResponsiveContainer>
  );
}
```

**Bar chart:**

```tsx
import {
  BarChart,
  Bar,
  XAxis,
  YAxis,
  Tooltip,
  ResponsiveContainer,
} from "recharts";

function RevenueChart({ data }) {
  return (
    <ResponsiveContainer width="100%" height={300}>
      <BarChart data={data}>
        <XAxis dataKey="name" />
        <YAxis />
        <Tooltip />
        <Bar dataKey="value" fill="#8884d8" />
      </BarChart>
    </ResponsiveContainer>
  );
}
```

**Area chart:**

```tsx
import {
  AreaChart,
  Area,
  XAxis,
  YAxis,
  Tooltip,
  ResponsiveContainer,
} from "recharts";

function TrendChart({ data }) {
  return (
    <ResponsiveContainer width="100%" height={300}>
      <AreaChart data={data}>
        <XAxis dataKey="date" />
        <YAxis />
        <Tooltip />
        <Area
          type="monotone"
          dataKey="value"
          stroke="#8884d8"
          fill="#8884d8"
          fillOpacity={0.3}
        />
      </AreaChart>
    </ResponsiveContainer>
  );
}
```

**Pie chart:**

```tsx
import { PieChart, Pie, Cell, Tooltip, ResponsiveContainer } from "recharts";

const COLORS = ["#0088FE", "#00C49F", "#FFBB28", "#FF8042"];

function DistributionChart({ data }) {
  return (
    <ResponsiveContainer width="100%" height={300}>
      <PieChart>
        <Pie
          data={data}
          dataKey="value"
          nameKey="name"
          cx="50%"
          cy="50%"
          outerRadius={100}
          label
        >
          {data.map((entry, index) => (
            <Cell key={`cell-${index}`} fill={COLORS[index % COLORS.length]} />
          ))}
        </Pie>
        <Tooltip />
      </PieChart>
    </ResponsiveContainer>
  );
}
```

</quick_start>

<chart_types>
| Component | Use Case |
|-----------|----------|
| `LineChart` | Trends over time |
| `BarChart` | Comparisons |
| `AreaChart` | Volume/cumulative data |
| `PieChart` | Part-to-whole |
| `ScatterChart` | Correlations |
| `RadarChart` | Multi-dimensional comparisons |
| `ComposedChart` | Mixed chart types |
</chart_types>

<customization>
**Custom tooltip:**

```tsx
const CustomTooltip = ({ active, payload, label }) => {
  if (!active || !payload) return null;

  return (
    <div className="bg-white p-2 border rounded shadow">
      <p className="font-bold">{label}</p>
      {payload.map((entry) => (
        <p key={entry.name} style={{ color: entry.color }}>
          {entry.name}: {entry.value}
        </p>
      ))}
    </div>
  );
};

<Tooltip content={<CustomTooltip />} />;
```

**Custom axis tick:**

```tsx
const CustomTick = ({ x, y, payload }) => (
  <g transform={`translate(${x},${y})`}>
    <text textAnchor="middle" dy={16}>
      {formatDate(payload.value)}
    </text>
  </g>
);

<XAxis tick={<CustomTick />} />;
```

</customization>

<constraints>
**Required:**
- Always wrap in `ResponsiveContainer` for responsive sizing
- Provide `width` and `height` to ResponsiveContainer
- Use `dataKey` to map data fields

**Performance:**

- Limit data points for large datasets
- Use `isAnimationActive={false}` for static charts
- Consider virtualization for very large datasets
  </constraints>

<anti_patterns>
**Common mistakes to avoid:**

- Charts without ResponsiveContainer (breaks on resize)
- Missing width/height props causing invisible charts
- Animation enabled on large datasets (performance issues)
- Wrong chart type for data (pie chart for trends, line for categories)
- Inaccessible color schemes with poor contrast
  </anti_patterns>

<library_ids>
Skip resolve step for these known IDs:

| Library  | Context7 ID        |
| -------- | ------------------ |
| Recharts | /recharts/recharts |

</library_ids>

<research>
**Find patterns on GitHub when stuck:**

```typescript
mcp__plugin_devtools_octocode__githubSearchCode({
  queries: [
    {
      mainResearchGoal: "Find production Recharts patterns",
      researchGoal: "Search for chart composition and customization",
      reasoning: "Need real-world examples of Recharts usage",
      keywordsToSearch: ["LineChart", "ResponsiveContainer", "recharts"],
      extension: "tsx",
      limit: 10,
    },
  ],
});
```

**Common searches:**

- Custom tooltips: `keywordsToSearch: ["CustomTooltip", "Tooltip content", "recharts"]`
- Dashboard charts: `keywordsToSearch: ["AreaChart", "ComposedChart", "dashboard"]`
- Time series: `keywordsToSearch: ["XAxis", "time series", "date format"]`
  </research>

<related_skills>

**React components:** Load via `Skill({ skill: "devtools:react" })` when:

- Building chart wrapper components
- Managing chart state and data
- Integrating with data fetching

**Design system:** Load via `Skill({ skill: "devtools:design-principles" })` when:

- Choosing chart colors and theming
- Ensuring accessible color contrast
- Maintaining consistent visual hierarchy
  </related_skills>

<success_criteria>

- [ ] Chart wrapped in ResponsiveContainer
- [ ] Proper axes with labels
- [ ] Tooltip for interactivity
- [ ] Appropriate chart type for data
- [ ] Accessible colors (sufficient contrast)
      </success_criteria>

<evolution>
**Extension Points:**

- Create custom chart components with consistent theming
- Add domain-specific tooltip and legend formatters
- Build dashboard-ready chart wrappers with loading states

**Timelessness:** Data visualization principles and chart composition patterns apply across all charting libraries.
</evolution>
