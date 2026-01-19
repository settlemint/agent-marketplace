# React component API clarity

> **Repository:** ant-design/ant-design
> **Dependencies:** @testing-library/react, @types/react, react

Ensure React component APIs are well-designed with accurate TypeScript interfaces, clear documentation, and intuitive developer experience. This includes: (1) Using precise type definitions that match actual functionality, avoiding misleading exposed props from internal implementations, (2) Providing accurate property descriptions in documentation that match the component's actual behavior, (3) Offering clean, intuitive import paths that improve developer experience, and (4) Maintaining consistency between TypeScript interfaces and documentation.

For example, when exposing component props, omit internal implementation details:
```typescript
// Good: Clean public interface
export interface TreeProps<T extends BasicDataNode = DataNode>
  extends Omit<RcTreeProps<T>, 'prefixCls' | 'showLine' | 'dropIndicatorRender'> {
  // Only expose props that users should actually use
}

// Good: Accurate property descriptions
| size | Set the size of tag | `large` \| `middle` \| `small` | `small` |

// Good: Clean import paths
import { createCache, extractStyle, StyleProvider } from 'antd/cssinjs';
```

This approach prevents confusion when developers see auto-complete suggestions for props they shouldn't use, ensures documentation accurately reflects component behavior, and provides a smoother development experience through cleaner APIs.