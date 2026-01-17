# Reviewers Index

**Total: 353 code review patterns** from top open-source projects.

Generated from [awesome-reviewers](https://github.com/baz-scm/awesome-reviewers) catalog.

## By Technology

### @graphql-typed-document-node/core (40 reviewers)

| Reviewer | Repository | Description |
|----------|------------|-------------|
| [Align configurations with usage](reviewers/align-configurations-with-usage.md) | vuejs/core | Configuration files should accurately reflect the actual req... |
| [API documentation consistency](reviewers/api-documentation-consistency.md) | home-assistant/core | Ensure all API-related descriptions, field names, and docume... |
| [API polling optimization](reviewers/api-polling-optimization.md) | home-assistant/core | Optimize API polling patterns to avoid excessive calls and i... |
| [API response transformation](reviewers/api-response-transformation.md) | home-assistant/core | When integrating external APIs, implement a translation laye... |
| [avoid code duplication](reviewers/avoid-code-duplication.md) | home-assistant/core | Create reusable components instead of duplicating similar co... |
| [Avoid redundant computations](reviewers/avoid-redundant-computations.md) | vuejs/core | Identify and eliminate redundant operations that cause perfo... |
| [Batch operations efficiently](reviewers/batch-operations-efficiently.md) | home-assistant/core | Collect and execute similar operations together rather than ... |
| [Choose semantic descriptive names](reviewers/choose-semantic-descriptive-names.md) | vuejs/core | Names should be clear, descriptive and follow consistent pat... |
| [classify data sensitivity](reviewers/classify-data-sensitivity.md) | home-assistant/core | Properly evaluate whether data contains sensitive informatio... |
| [Clear variable naming](reviewers/clear-variable-naming.md) | home-assistant/core | Use descriptive, unambiguous variable and function names tha... |
| ... | ... | *30 more* |

### @tanstack/react-router (38 reviewers)

| Reviewer | Repository | Description |
|----------|------------|-------------|
| [Avoid redundant computations](reviewers/avoid-redundant-computations.md) | vuejs/core | Identify and eliminate redundant operations that cause perfo... |
| [Documentation clarity standards](reviewers/documentation-clarity-standards.md) | prettier/prettier | Ensure documentation is clear, precise, and technically accu... |
| [API backward compatibility](reviewers/api-backward-compatibility.md) | remix-run/react-router | When evolving APIs, maintain backward compatibility by prese... |
| [API consistency patterns](reviewers/api-consistency-patterns.md) | remix-run/react-router | Ensure API design follows consistent patterns for naming, ty... |
| [API naming consistency](reviewers/api-naming-consistency.md) | remix-run/react-router | Ensure related APIs use consistent naming patterns, paramete... |
| [avoid timing-dependent tests](reviewers/avoid-timing-dependent-tests.md) | remix-run/react-router | Tests should not rely on fixed delays, arbitrary timeouts, o... |
| [Cancel aborted async operations](reviewers/cancel-aborted-async-operations.md) | remix-run/react-router | When working with async operations that can be aborted (like... |
| [Complete accurate documentation](reviewers/complete-accurate-documentation.md) | remix-run/react-router | Documentation should provide complete, accurate guidance tha... |
| [configuration compatibility validation](reviewers/configuration-compatibility-validation.md) | remix-run/react-router | Ensure that code examples and documentation accurately refle... |
| [configuration consistency standards](reviewers/configuration-consistency-standards.md) | remix-run/react-router | Ensure configuration options, flags, and environment setting... |
| ... | ... | *28 more* |

### @types/bun (37 reviewers)

| Reviewer | Repository | Description |
|----------|------------|-------------|
| [Always await promises](reviewers/always-await-promises.md) | oven-sh/bun | Consistently use the `await` keyword when working with Promi... |
| [Assert before cast](reviewers/assert-before-cast.md) | oven-sh/bun | Always validate values before performing unsafe operations l... |
| [Cache repeated accesses](reviewers/cache-repeated-accesses.md) | oven-sh/bun | When accessing the same property or calling the same functio... |
| [Check exceptions consistently](reviewers/check-exceptions-consistently.md) | oven-sh/bun | Always check for exceptions immediately after operations tha... |
| [Clean all error paths](reviewers/clean-all-error-paths.md) | oven-sh/bun | Ensure all error paths properly clean up resources and handl... |
| [Clear accurate documentation](reviewers/clear-accurate-documentation.md) | oven-sh/bun | Documentation should be both technically accurate and contex... |
| [Consistent descriptive identifiers](reviewers/consistent-descriptive-identifiers.md) | oven-sh/bun | Use camelCase for all variables, parameters, methods, and fu... |
| [Descriptive identifier names](reviewers/descriptive-identifier-names.md) | oven-sh/bun | Choose clear, consistent, and accurate identifiers that prec... |
| [Deterministic lock management](reviewers/deterministic-lock-management.md) | oven-sh/bun | Always ensure locks are acquired and released in a determini... |
| [Document configuration variations](reviewers/document-configuration-variations.md) | oven-sh/bun | When documenting or implementing configuration options, alwa... |
| ... | ... | *27 more* |

### @types/node (32 reviewers)

| Reviewer | Repository | Description |
|----------|------------|-------------|
| [Await all promises](reviewers/await-all-promises.md) | nodejs/node | Always explicitly await all asynchronous operations, especia... |
| [Behavior-focused test design](reviewers/behavior-focused-test-design.md) | nodejs/node | Tests should focus on verifying behavior rather than impleme... |
| [Benchmark before optimizing code](reviewers/benchmark-before-optimizing-code.md) | nodejs/node | Performance optimizations should be validated through benchm... |
| [Choose appropriate containers](reviewers/choose-appropriate-containers.md) | nodejs/node | Select data structures based on expected collection size and... |
| [Descriptive behavior-based tests](reviewers/descriptive-behavior-based-tests.md) | nodejs/node | Tests should be named to describe the expected behavior or o... |
| [Descriptive function names](reviewers/descriptive-function-names.md) | nodejs/node | Function and method names should precisely describe their pu... |
| [Document non-intuitive code](reviewers/document-non-intuitive-code.md) | nodejs/node | Add clear comments to explain complex logic, function differ... |
| [Document with precise accuracy](reviewers/document-with-precise-accuracy.md) | nodejs/node | Maintain precise and accurate documentation through both JSD... |
| [Evolve return values](reviewers/evolve-return-values.md) | nodejs/node | When extending APIs with new capabilities, carefully conside... |
| [Export environment variables once](reviewers/export-environment-variables-once.md) | nodejs/node | When writing shell scripts, set and export all environment v... |
| ... | ... | *22 more* |

### @playwright/test (31 reviewers)

| Reviewer | Repository | Description |
|----------|------------|-------------|
| [Test actual functionality](reviewers/test-actual-functionality.md) | cloudflare/agents | Ensure tests verify real operations and integration scenario... |
| [Test security boundaries](reviewers/test-security-boundaries.md) | cloudflare/agents | Security mechanisms should be tested for both success and fa... |
| [Test before documenting](reviewers/test-before-documenting.md) | vercel/ai | Always thoroughly test API features and endpoints before doc... |
| [Test network performance](reviewers/test-network-performance.md) | ant-design/ant-design | Always validate network performance and connectivity before ... |
| [Test organization standards](reviewers/test-organization-standards.md) | ant-design/ant-design | Write tests that are well-organized, maintainable, and refle... |
| [Test configuration precedence](reviewers/test-configuration-precedence.md) | aws/aws-sdk-js | When implementing systems that load configuration from multi... |
| [Test behavior not calls](reviewers/test-behavior-not-calls.md) | crewaiinc/crewai | Tests should validate actual system behavior rather than jus... |
| [Test version compatibility](reviewers/test-version-compatibility.md) | cypress-io/cypress | When testing across different versions of dependencies, proa... |
| [Test structure and clarity](reviewers/test-structure-and-clarity.md) | stanfordnlp/dspy | Organize tests for maximum clarity and maintainability by le... |
| [Test observable behavior](reviewers/test-observable-behavior.md) | flutter/flutter | Focus on testing what users see and experience rather than i... |
| ... | ... | *21 more* |

### @tailwindcss/vite (30 reviewers)

| Reviewer | Repository | Description |
|----------|------------|-------------|
| [Propagate errors with context](reviewers/propagate-errors-with-context.md) | nodejs/node | Always propagate errors with their original context instead ... |
| [Break down complex functions](reviewers/break-down-complex-functions.md) | vitejs/vite | Improve code readability and maintainability by decomposing ... |
| [Clean configuration organization](reviewers/clean-configuration-organization.md) | vitejs/vite | Organize configuration settings logically and avoid redundan... |
| [Clean network resources](reviewers/clean-network-resources.md) | vitejs/vite | Always properly close and clean up network connections to pr... |
| [Code example consistency](reviewers/code-example-consistency.md) | vitejs/vite | Ensure code examples in documentation and comments are synta... |
| [Complete deployment commands](reviewers/complete-deployment-commands.md) | vitejs/vite | Always ensure build commands in CI/CD configurations include... |
| [Configure SSR environments](reviewers/configure-ssr-environments.md) | vitejs/vite | When implementing server-side rendering in Next.js projects ... |
| [Descriptive consistent naming](reviewers/descriptive-consistent-naming.md) | vitejs/vite | Choose variable, function, and class names that accurately r... |
| [Document code purposefully](reviewers/document-code-purposefully.md) | vitejs/vite | High-quality code documentation improves maintainability and... |
| [Document protocol configurations clearly](reviewers/document-protocol-configurations-clearly.md) | vitejs/vite | When documenting network protocol configurations (TLS, HTTP/... |
| ... | ... | *20 more* |

### vite (30 reviewers)

| Reviewer | Repository | Description |
|----------|------------|-------------|
| [Propagate errors with context](reviewers/propagate-errors-with-context.md) | nodejs/node | Always propagate errors with their original context instead ... |
| [Break down complex functions](reviewers/break-down-complex-functions.md) | vitejs/vite | Improve code readability and maintainability by decomposing ... |
| [Clean configuration organization](reviewers/clean-configuration-organization.md) | vitejs/vite | Organize configuration settings logically and avoid redundan... |
| [Clean network resources](reviewers/clean-network-resources.md) | vitejs/vite | Always properly close and clean up network connections to pr... |
| [Code example consistency](reviewers/code-example-consistency.md) | vitejs/vite | Ensure code examples in documentation and comments are synta... |
| [Complete deployment commands](reviewers/complete-deployment-commands.md) | vitejs/vite | Always ensure build commands in CI/CD configurations include... |
| [Configure SSR environments](reviewers/configure-ssr-environments.md) | vitejs/vite | When implementing server-side rendering in Next.js projects ... |
| [Descriptive consistent naming](reviewers/descriptive-consistent-naming.md) | vitejs/vite | Choose variable, function, and class names that accurately r... |
| [Document code purposefully](reviewers/document-code-purposefully.md) | vitejs/vite | High-quality code documentation improves maintainability and... |
| [Document protocol configurations clearly](reviewers/document-protocol-configurations-clearly.md) | vitejs/vite | When documenting network protocol configurations (TLS, HTTP/... |
| ... | ... | *20 more* |

### prettier (28 reviewers)

| Reviewer | Repository | Description |
|----------|------------|-------------|
| [Add explanatory comments](reviewers/add-explanatory-comments.md) | prettier/prettier | Add explanatory comments for complex logic, special cases, o... |
| [Angular syntax parsing](reviewers/angular-syntax-parsing.md) | prettier/prettier | When implementing Angular syntax parsing, ensure robust hand... |
| [API documentation clarity](reviewers/api-documentation-clarity.md) | prettier/prettier | Ensure API documentation provides clear, accurate, and compr... |
| [Benchmark performance optimizations](reviewers/benchmark-performance-optimizations.md) | prettier/prettier | Always measure and validate performance optimizations with c... |
| [Cache correctness validation](reviewers/cache-correctness-validation.md) | prettier/prettier | Ensure caching implementations store the correct data and us... |
| [cache invalidation strategy](reviewers/cache-invalidation-strategy.md) | prettier/prettier | Implement comprehensive cache invalidation mechanisms that a... |
| [consistent spacing patterns](reviewers/consistent-spacing-patterns.md) | prettier/prettier | Maintain consistent spacing patterns around operators, keywo... |
| [Document CI workflow rationale](reviewers/document-ci-workflow-rationale.md) | prettier/prettier | Always include clear comments explaining the reasoning behin... |
| [Documentation clarity standards](reviewers/documentation-clarity-standards.md) | prettier/prettier | Ensure documentation is clear, precise, and technically accu... |
| [Documentation example consistency](reviewers/documentation-example-consistency.md) | prettier/prettier | Ensure all code examples and documentation maintain consiste... |
| ... | ... | *18 more* |

### @testing-library/react (24 reviewers)

| Reviewer | Repository | Description |
|----------|------------|-------------|
| [React component API clarity](reviewers/react-component-api-clarity.md) | ant-design/ant-design | Ensure React component APIs are well-designed with accurate ... |
| [React interface clarity](reviewers/react-interface-clarity.md) | vadimdemedes/ink | Ensure React interfaces have descriptive names and accurate ... |
| [React hooks best practices](reviewers/react-hooks-best-practices.md) | ChatGPTNextWeb/NextChat | Always call React hooks at the top level of components and c... |
| [Balance constraints with flexibility](reviewers/balance-constraints-with-flexibility.md) | facebook/react | When designing APIs, carefully evaluate constraints imposed ... |
| [Check property existence first](reviewers/check-property-existence-first.md) | facebook/react | Always verify that an object and its properties exist before... |
| [Complete hook dependencies](reviewers/complete-hook-dependencies.md) | facebook/react | Always specify complete dependency arrays in React hooks to ... |
| [Defensive Handling of Nullable React Components](reviewers/defensive-handling-of-nullable-react-components.md) | facebook/react | When working with React components that may return null or u... |
| [Document code intent](reviewers/document-code-intent.md) | facebook/react | Add clear comments that explain the intent and behavior of c... |
| [Dry configuration patterns](reviewers/dry-configuration-patterns.md) | facebook/react | Apply DRY (Don't Repeat Yourself) principles to all configur... |
| [Explicit CSP nonce management](reviewers/explicit-csp-nonce-management.md) | facebook/react | When implementing Content Security Policy (CSP) protections,... |
| ... | ... | *14 more* |

### @types/react (24 reviewers)

| Reviewer | Repository | Description |
|----------|------------|-------------|
| [React component API clarity](reviewers/react-component-api-clarity.md) | ant-design/ant-design | Ensure React component APIs are well-designed with accurate ... |
| [React interface clarity](reviewers/react-interface-clarity.md) | vadimdemedes/ink | Ensure React interfaces have descriptive names and accurate ... |
| [React hooks best practices](reviewers/react-hooks-best-practices.md) | ChatGPTNextWeb/NextChat | Always call React hooks at the top level of components and c... |
| [Balance constraints with flexibility](reviewers/balance-constraints-with-flexibility.md) | facebook/react | When designing APIs, carefully evaluate constraints imposed ... |
| [Check property existence first](reviewers/check-property-existence-first.md) | facebook/react | Always verify that an object and its properties exist before... |
| [Complete hook dependencies](reviewers/complete-hook-dependencies.md) | facebook/react | Always specify complete dependency arrays in React hooks to ... |
| [Defensive Handling of Nullable React Components](reviewers/defensive-handling-of-nullable-react-components.md) | facebook/react | When working with React components that may return null or u... |
| [Document code intent](reviewers/document-code-intent.md) | facebook/react | Add clear comments that explain the intent and behavior of c... |
| [Dry configuration patterns](reviewers/dry-configuration-patterns.md) | facebook/react | Apply DRY (Don't Repeat Yourself) principles to all configur... |
| [Explicit CSP nonce management](reviewers/explicit-csp-nonce-management.md) | facebook/react | When implementing Content Security Policy (CSP) protections,... |
| ... | ... | *14 more* |

### react (24 reviewers)

| Reviewer | Repository | Description |
|----------|------------|-------------|
| [React component API clarity](reviewers/react-component-api-clarity.md) | ant-design/ant-design | Ensure React component APIs are well-designed with accurate ... |
| [React interface clarity](reviewers/react-interface-clarity.md) | vadimdemedes/ink | Ensure React interfaces have descriptive names and accurate ... |
| [React hooks best practices](reviewers/react-hooks-best-practices.md) | ChatGPTNextWeb/NextChat | Always call React hooks at the top level of components and c... |
| [Balance constraints with flexibility](reviewers/balance-constraints-with-flexibility.md) | facebook/react | When designing APIs, carefully evaluate constraints imposed ... |
| [Check property existence first](reviewers/check-property-existence-first.md) | facebook/react | Always verify that an object and its properties exist before... |
| [Complete hook dependencies](reviewers/complete-hook-dependencies.md) | facebook/react | Always specify complete dependency arrays in React hooks to ... |
| [Defensive Handling of Nullable React Components](reviewers/defensive-handling-of-nullable-react-components.md) | facebook/react | When working with React components that may return null or u... |
| [Document code intent](reviewers/document-code-intent.md) | facebook/react | Add clear comments that explain the intent and behavior of c... |
| [Dry configuration patterns](reviewers/dry-configuration-patterns.md) | facebook/react | Apply DRY (Don't Repeat Yourself) principles to all configur... |
| [Explicit CSP nonce management](reviewers/explicit-csp-nonce-management.md) | facebook/react | When implementing Content Security Policy (CSP) protections,... |
| ... | ... | *14 more* |

### typescript (20 reviewers)

| Reviewer | Repository | Description |
|----------|------------|-------------|
| [TypeScript naming standards](reviewers/typescript-naming-standards.md) | langchain-ai/langchainjs | Follow consistent naming conventions in TypeScript to improv... |
| [TypeScript configuration setup](reviewers/typescript-configuration-setup.md) | remix-run/react-router | Ensure proper TypeScript configuration for generated types a... |
| [Actionable error messages](reviewers/actionable-error-messages.md) | microsoft/typescript | When designing APIs, provide error messages that are context... |
| [Cache expensive computed values](reviewers/cache-expensive-computed-values.md) | microsoft/typescript | Cache frequently accessed or computed values to avoid redund... |
| [Consistent message terminology](reviewers/consistent-message-terminology.md) | microsoft/typescript | Use clear, consistent terminology in all error messages and ... |
| [Consistent module resolution](reviewers/consistent-module-resolution.md) | microsoft/typescript | Configure consistent module resolution strategies across rel... |
| [Consistent type algorithms](reviewers/consistent-type-algorithms.md) | microsoft/typescript | Implement consistent algorithms for type compatibility and c... |
| [Document function behavior completely](reviewers/document-function-behavior-completely.md) | microsoft/typescript | Functions should be documented with comprehensive JSDoc comm... |
| [Eliminate unnecessary constructs](reviewers/eliminate-unnecessary-constructs.md) | microsoft/typescript | Remove redundant or unnecessary code constructs to improve r... |
| [Extract complex logical expressions](reviewers/extract-complex-logical-expressions.md) | microsoft/typescript | Complex logical expressions should be extracted into well-na... |
| ... | ... | *10 more* |

### @core/database (17 reviewers)

| Reviewer | Repository | Description |
|----------|------------|-------------|
| [Database schema consistency](reviewers/database-schema-consistency.md) | ClickHouse/ClickHouse | Ensure database operations maintain consistent behavior and ... |
| [Database type consistency](reviewers/database-type-consistency.md) | drizzle-team/drizzle-orm | Ensure database-specific types, imports, and serialization a... |
| [Database migration isolation](reviewers/database-migration-isolation.md) | block/goose | When performing database migrations or schema changes, use c... |
| [Database type best practices](reviewers/database-type-best-practices.md) | elie222/inbox-zero | Select appropriate data types and defaults for database colu... |
| [Database configuration clarity](reviewers/database-configuration-clarity.md) | langflow-ai/langflow | When documenting database configuration or setup procedures,... |
| [Database session lifecycle](reviewers/database-session-lifecycle.md) | langflow-ai/langflow | Ensure all database operations and access to database object... |
| [Database migration best practices](reviewers/database-migration-best-practices.md) | langfuse/langfuse | When implementing database schema changes, follow these migr... |
| [Database before memory](reviewers/database-before-memory.md) | neondatabase/neon | When working with database systems that also maintain in-mem... |
| [Database replica promotion safeguards](reviewers/database-replica-promotion-safeguards.md) | neondatabase/neon | When implementing database replica promotion logic, avoid te... |
| [Database API abstraction](reviewers/database-api-abstraction.md) | pola-rs/polars | When designing database interaction layers, carefully consid... |
| ... | ... | *7 more* |

### @dalp/database (17 reviewers)

| Reviewer | Repository | Description |
|----------|------------|-------------|
| [Database schema consistency](reviewers/database-schema-consistency.md) | ClickHouse/ClickHouse | Ensure database operations maintain consistent behavior and ... |
| [Database type consistency](reviewers/database-type-consistency.md) | drizzle-team/drizzle-orm | Ensure database-specific types, imports, and serialization a... |
| [Database migration isolation](reviewers/database-migration-isolation.md) | block/goose | When performing database migrations or schema changes, use c... |
| [Database type best practices](reviewers/database-type-best-practices.md) | elie222/inbox-zero | Select appropriate data types and defaults for database colu... |
| [Database configuration clarity](reviewers/database-configuration-clarity.md) | langflow-ai/langflow | When documenting database configuration or setup procedures,... |
| [Database session lifecycle](reviewers/database-session-lifecycle.md) | langflow-ai/langflow | Ensure all database operations and access to database object... |
| [Database migration best practices](reviewers/database-migration-best-practices.md) | langfuse/langfuse | When implementing database schema changes, follow these migr... |
| [Database before memory](reviewers/database-before-memory.md) | neondatabase/neon | When working with database systems that also maintain in-mem... |
| [Database replica promotion safeguards](reviewers/database-replica-promotion-safeguards.md) | neondatabase/neon | When implementing database replica promotion logic, avoid te... |
| [Database API abstraction](reviewers/database-api-abstraction.md) | pola-rs/polars | When designing database interaction layers, carefully consid... |
| ... | ... | *7 more* |

### better-auth (15 reviewers)

| Reviewer | Repository | Description |
|----------|------------|-------------|
| [API consistency standards](reviewers/api-consistency-standards.md) | better-auth/better-auth | Maintain consistent parameter formats and requirements acros... |
| [API endpoint correctness](reviewers/api-endpoint-correctness.md) | better-auth/better-auth | API endpoints must behave according to their intended design... |
| [comprehensive test coverage](reviewers/comprehensive-test-coverage.md) | better-auth/better-auth | When adding new functionality, configuration options, or plu... |
| [consistent configuration handling](reviewers/consistent-configuration-handling.md) | better-auth/better-auth | Ensure configuration options are handled uniformly across al... |
| [derive from session context](reviewers/derive-from-session-context.md) | better-auth/better-auth | Always derive sensitive identifiers and permissions from the... |
| [Document configuration requirements](reviewers/document-configuration-requirements.md) | better-auth/better-auth | Ensure that configuration requirements, dependencies, and op... |
| [Expose essential configurations](reviewers/expose-essential-configurations.md) | better-auth/better-auth | Carefully evaluate which configuration options should be exp... |
| [Improve documentation clarity](reviewers/improve-documentation-clarity.md) | better-auth/better-auth | Write clear, accessible, and consistent documentation by usi... |
| [Intentional configuration management](reviewers/intentional-configuration-management.md) | better-auth/better-auth | Configuration choices should be intentional, balancing produ... |
| [Optimize database queries](reviewers/optimize-database-queries.md) | better-auth/better-auth | Avoid inefficient database query patterns by using batch ope... |
| ... | ... | *5 more* |

### @core/cache (15 reviewers)

| Reviewer | Repository | Description |
|----------|------------|-------------|
| [Cache repeated accesses](reviewers/cache-repeated-accesses.md) | oven-sh/bun | When accessing the same property or calling the same functio... |
| [Cache expensive operations](reviewers/cache-expensive-operations.md) | discourse/discourse | Identify and eliminate duplicate computations by caching res... |
| [Cache key serialization](reviewers/cache-key-serialization.md) | stanfordnlp/dspy | When implementing caching for functions that accept complex ... |
| [Cache invariant computations](reviewers/cache-invariant-computations.md) | elie222/inbox-zero | Avoid repeatedly computing values that don't change frequent... |
| [Cache state consistency](reviewers/cache-state-consistency.md) | LMCache/LMCache | Ensure cache operations maintain consistent state and handle... |
| [Cache performance preservation](reviewers/cache-performance-preservation.md) | neondatabase/neon | When implementing database failover or restart mechanisms, e... |
| [Cache lifecycle management](reviewers/cache-lifecycle-management.md) | nuxt/nuxt | Implement comprehensive cache lifecycle management that incl... |
| [Cache expensive calculations](reviewers/cache-expensive-calculations.md) | nrwl/nx | Avoid recalculating expensive operations in frequently calle... |
| [cache isolation boundaries](reviewers/cache-isolation-boundaries.md) | nrwl/nx | When documenting caching systems, clearly specify cache isol... |
| [Cache expensive computations](reviewers/cache-expensive-computations.md) | python-poetry/poetry | Identify expensive operations that may be called multiple ti... |
| ... | ... | *5 more* |

### @core/network (13 reviewers)

| Reviewer | Repository | Description |
|----------|------------|-------------|
| [Network API compatibility](reviewers/network-api-compatibility.md) | oven-sh/bun | When implementing networking APIs that mirror Node.js functi... |
| [Network API precision](reviewers/network-api-precision.md) | docker/compose | Use the appropriate Docker network API method based on the s... |
| [Network data encoding](reviewers/network-data-encoding.md) | cypress-io/cypress | Ensure network-related data like URLs and IP addresses are p... |
| [network address validation](reviewers/network-address-validation.md) | denoland/deno | When validating network addresses and interfaces, properly h... |
| [network configuration consistency](reviewers/network-configuration-consistency.md) | istio/istio | Ensure network-related configurations remain consistent acro... |
| [network service identification](reviewers/network-service-identification.md) | LMCache/LMCache | Use descriptive string identifiers instead of numeric ports ... |
| [Network resource limits](reviewers/network-resource-limits.md) | mastodon/mastodon | Implement protective limits for network operations to preven... |
| [Network request configuration](reviewers/network-request-configuration.md) | python-poetry/poetry | When implementing or documenting network functionality, ensu... |
| [Network address clarity](reviewers/network-address-clarity.md) | gravitational/teleport | When documenting or configuring network addresses, DNS names... |
| [Network API design consistency](reviewers/network-api-design-consistency.md) | tokio-rs/tokio | When designing networking APIs, maintain consistency with ex... |
| ... | ... | *3 more* |

### @vitest/ui (13 reviewers)

| Reviewer | Repository | Description |
|----------|------------|-------------|
| [Accessible security indicators](reviewers/accessible-security-indicators.md) | shadcn-ui/ui | Ensure all security-related UI elements such as warnings, er... |
| [Add interactive element roles](reviewers/add-interactive-element-roles.md) | shadcn-ui/ui | When adding event handlers like `onClick` to non-interactive... |
| [Complete configuration paths](reviewers/complete-configuration-paths.md) | shadcn-ui/ui | Always verify that configuration files include all necessary... |
| [Complete optional chaining](reviewers/complete-optional-chaining.md) | shadcn-ui/ui | When using optional chaining (`?.`), ensure that **all subse... |
| [Consistent import paths](reviewers/consistent-import-paths.md) | shadcn-ui/ui | Establish and follow consistent import path conventions thro... |
| [Leverage framework defaults](reviewers/leverage-framework-defaults.md) | shadcn-ui/ui | Avoid redundant or unnecessary configuration by understandin... |
| [Meaningful consistent identifiers](reviewers/meaningful-consistent-identifiers.md) | shadcn-ui/ui | Choose descriptive, semantically accurate names for variable... |
| [Optimize documentation for usability](reviewers/optimize-documentation-for-usability.md) | shadcn-ui/ui | When creating component documentation, prioritize the develo... |
| [Organize tailwind classes](reviewers/organize-tailwind-classes.md) | shadcn-ui/ui | Structure your Tailwind CSS classes for readability and main... |
| [Preprocess data early](reviewers/preprocess-data-early.md) | shadcn-ui/ui | Transform and prepare data structures at their source rather... |
| ... | ... | *3 more* |

### drizzle-orm (8 reviewers)

| Reviewer | Repository | Description |
|----------|------------|-------------|
| [avoid cosmetic formatting changes](reviewers/avoid-cosmetic-formatting-changes.md) | drizzle-team/drizzle-orm | Avoid including purely cosmetic formatting changes in pull r... |
| [Configuration context consistency](reviewers/configuration-context-consistency.md) | drizzle-team/drizzle-orm | Ensure configuration names, values, and settings accurately ... |
| [consistent naming patterns](reviewers/consistent-naming-patterns.md) | drizzle-team/drizzle-orm | Maintain consistent naming conventions across similar constr... |
| [Database type consistency](reviewers/database-type-consistency.md) | drizzle-team/drizzle-orm | Ensure database-specific types, imports, and serialization a... |
| [intuitive API method design](reviewers/intuitive-api-method-design.md) | drizzle-team/drizzle-orm | Design API methods with intuitive names and signatures that ... |
| [optimize algorithmic performance](reviewers/optimize-algorithmic-performance.md) | drizzle-team/drizzle-orm | Prioritize algorithmic efficiency and avoid unnecessary comp... |
| [prefer nullish coalescing operator](reviewers/prefer-nullish-coalescing-operator.md) | drizzle-team/drizzle-orm | Use the nullish coalescing operator (`??`) instead of the lo... |
| [track migration state immediately](reviewers/track-migration-state-immediately.md) | drizzle-team/drizzle-orm | Ensure migration state is recorded in the database immediate... |

### @orpc/openapi (1 reviewers)

| Reviewer | Repository | Description |
|----------|------------|-------------|
| [OpenAPI spec compliance](reviewers/openapi-spec-compliance.md) | appwrite/appwrite | Ensure all API definitions strictly follow OpenAPI specifica... |

### graphql (1 reviewers)

| Reviewer | Repository | Description |
|----------|------------|-------------|
| [GraphQL mutation design](reviewers/graphql-mutation-design.md) | cypress-io/cypress | Design GraphQL mutations to return meaningful objects rather... |

### @core/config (1 reviewers)

| Reviewer | Repository | Description |
|----------|------------|-------------|
| [Config file naming clarity](reviewers/config-file-naming-clarity.md) | jj-vcs/jj | Use descriptive, unambiguous names for configuration files t... |

