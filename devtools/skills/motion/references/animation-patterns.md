# Animation Patterns

## Variants (Reusable Animations)

```tsx
const containerVariants = {
  hidden: { opacity: 0 },
  visible: {
    opacity: 1,
    transition: {
      staggerChildren: 0.1,
    },
  },
};

const itemVariants = {
  hidden: { opacity: 0, y: 20 },
  visible: { opacity: 1, y: 0 },
};

function List({ items }) {
  return (
    <motion.ul variants={containerVariants} initial="hidden" animate="visible">
      {items.map((item) => (
        <motion.li key={item.id} variants={itemVariants}>
          {item.name}
        </motion.li>
      ))}
    </motion.ul>
  );
}
```

## Layout Animations

```tsx
<motion.div layout>
  {/* Content changes trigger smooth layout animation */}
</motion.div>
```

## Shared Layout (Magic Move)

```tsx
<motion.div layoutId="card">
  {/* Same layoutId creates shared transition */}
</motion.div>
```

## Spring Physics

```tsx
<motion.div
  animate={{ x: 100 }}
  transition={{
    type: "spring",
    stiffness: 300,
    damping: 20,
  }}
/>
```

## Keyframes

```tsx
<motion.div
  animate={{
    scale: [1, 1.2, 1],
    rotate: [0, 180, 360],
  }}
  transition={{ duration: 2 }}
/>
```

## Hooks

```typescript
import {
  useAnimate,
  useMotionValue,
  useTransform,
  useSpring,
} from "motion/react";

// Imperative animations
const [scope, animate] = useAnimate();
animate(scope.current, { opacity: 1 });

// Motion values for performance
const x = useMotionValue(0);
const opacity = useTransform(x, [0, 100], [1, 0]);

// Spring-based values
const smoothX = useSpring(x, { stiffness: 300 });
```
