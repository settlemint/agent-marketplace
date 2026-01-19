# React hooks best practices

> **Repository:** ChatGPTNextWeb/NextChat
> **Dependencies:** @testing-library/react, @types/react, react

Always call React hooks at the top level of components and custom hooks to comply with the Rules of Hooks. Handle conditional logic inside hook bodies rather than conditionally calling hooks. When optimizing performance, choose the appropriate hook: use `useMemo` for computed values and `useCallback` for function references.

Example of proper hook usage:
```tsx
function useGlobalShortcut() {
  // Call hooks at the top level to comply with the rules of hooks
  const chatStore = useChatStore();
  const navigate = useNavigate();
  const config = useAppConfig();

  useEffect(() => {
    // Early return if not in environment. This way, the hooks are called unconditionally,
    // but the code inside useEffect only runs conditionally
    if (!window.__TAURI__) {
      return;
    }
    
    // Hook logic here...
  }, [chatStore, navigate, config]); // Include all dependencies
}
```

For optimization, prefer `useMemo` for computed values over `useCallback` when the result is not a function reference.