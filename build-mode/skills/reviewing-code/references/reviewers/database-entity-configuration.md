# Database entity configuration

> **Repository:** supabase/supabase
> **Dependencies:** @core/database, @dalp/database

Configure database entities with appropriate defaults and clear type distinctions. For triggers, prefer AFTER/ROW over BEFORE/STATEMENT as defaults for most use cases. When working with database views, clearly distinguish between regular views and materialized views in your code. When counting database resources like replicas, ensure accurate counting by excluding the primary instance.

```typescript
// Good: Clear distinction between view types
const isView = entity.type === ENTITY_TYPE.VIEW;
const isMaterializedView = entity.type === ENTITY_TYPE.MATERIALIZED_VIEW;
const isViewEntity = isView || isMaterializedView;

// Good: Accurate counting of replicas
const replicasCount = (replicasData?.length ?? 1) - 1; // Subtract primary instance

// Good: Appropriate trigger defaults
const defaultValues = {
  name: '',
  schema: '',
  table: '',
  activation: 'AFTER', // AFTER is typically more common
  orientation: 'ROW',  // ROW level is more frequently needed
}
```