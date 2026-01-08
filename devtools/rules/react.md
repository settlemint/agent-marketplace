---
description: React component patterns and best practices
globs: "**/*.tsx,**/*.jsx"
alwaysApply: false
---

# React Standards

## Component Structure

### Function Components Only

```tsx
// GOOD
export function UserCard({ user }: UserCardProps) {
  return <div>{user.name}</div>;
}

// AVOID - class components
class UserCard extends React.Component {}
```

### Props Interface Naming

```tsx
// GOOD
interface UserCardProps {
  user: User;
  onSelect?: (user: User) => void;
}

// AVOID
interface IUserCardProps {}
interface UserCardPropsType {}
```

## Hooks

### Custom Hooks for Logic

```tsx
// GOOD - extracted hook
function useUserData(userId: string) {
  const [user, setUser] = useState<User | null>(null);
  const [loading, setLoading] = useState(true);

  useEffect(() => {
    fetchUser(userId)
      .then(setUser)
      .finally(() => setLoading(false));
  }, [userId]);

  return { user, loading };
}

// Usage
function UserProfile({ userId }: { userId: string }) {
  const { user, loading } = useUserData(userId);
  if (loading) return <Spinner />;
  return <div>{user?.name}</div>;
}
```

### Dependencies Array

```tsx
// GOOD - all dependencies listed
useEffect(() => {
  fetchData(userId, filter);
}, [userId, filter]);

// AVOID - missing dependencies
useEffect(() => {
  fetchData(userId, filter);
}, [userId]); // filter missing
```

## State Management

### Derive Don't Duplicate

```tsx
// GOOD - derived state
function UserList({ users }: { users: User[] }) {
  const activeUsers = users.filter((u) => u.active);
  return <List items={activeUsers} />;
}

// AVOID - duplicated state
function UserList({ users }: { users: User[] }) {
  const [activeUsers, setActiveUsers] = useState<User[]>([]);
  useEffect(() => {
    setActiveUsers(users.filter((u) => u.active));
  }, [users]);
}
```

### Colocate State

Keep state as close to where it's used as possible. Lift only when multiple components need it.

## Event Handlers

### Naming Convention

```tsx
// GOOD - handler prefix
function Button({ onClick }: { onClick: () => void }) {
  const handleClick = () => {
    // local logic
    onClick();
  };
  return <button onClick={handleClick}>Click</button>;
}
```

## Keys

### Stable Unique Keys

```tsx
// GOOD - stable id
{
  items.map((item) => <Item key={item.id} {...item} />);
}

// AVOID - index as key (unless static list)
{
  items.map((item, index) => <Item key={index} {...item} />);
}
```

## Conditional Rendering

### Early Returns

```tsx
// GOOD
function UserProfile({ user }: { user: User | null }) {
  if (!user) return null;
  return <div>{user.name}</div>;
}

// AVOID - nested ternaries
function UserProfile({ user }: { user: User | null }) {
  return user ? <div>{user.name}</div> : null;
}
```

## Performance

### Memoization When Needed

```tsx
// Use when:
// - Component re-renders often with same props
// - Computation is expensive
// - Referential equality matters for children

const MemoizedComponent = memo(ExpensiveComponent);
const memoizedValue = useMemo(() => compute(data), [data]);
const memoizedCallback = useCallback(() => handle(id), [id]);
```
