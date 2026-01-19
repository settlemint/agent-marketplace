# Match API conventions

> **Repository:** oven-sh/bun
> **Dependencies:** @types/bun

Ensure API implementations match established conventions and reference implementations to maintain compatibility and predictability. When implementing APIs that parallel existing systems (like Node.js APIs or REST services), follow their error codes, response formats, and naming conventions precisely.

For error handling, return the same error types as reference implementations:

```zig
// INCORRECT: Using mismatched error type
if (array_buffer.typed_array_type != .ArrayBuffer) {
    return env.setLastError(.arraybuffer_expected); 
}

// CORRECT: Matching Node.js convention
if (array_buffer.typed_array_type != .ArrayBuffer) {
    return env.setLastError(.invalid_arg);
}
```

For memory management in API responses, use memory-safe methods:

```zig
// INCORRECT: Potential memory leak
deletedObject.put(globalObject, JSC.ZigString.static("Key"), bun.String.init(item.key).toJS(globalObject));

// CORRECT: Memory-safe alternative
deletedObject.put(globalObject, JSC.ZigString.static("Key"), bun.String.createUTF8ForJS(globalObject, item.key));
```

Consider API property naming and response structure consistency to ensure your implementation is compatible with expected conventions, while avoiding unintended behaviors and resource leaks.