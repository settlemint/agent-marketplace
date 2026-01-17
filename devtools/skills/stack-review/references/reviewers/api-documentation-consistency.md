# API documentation consistency

> **Repository:** home-assistant/core
> **Dependencies:** @graphql-typed-document-node/core

Ensure all API-related descriptions, field names, and documentation accurately reflect the terminology and specifications used by external service providers. Descriptions should be consistent between code comments, user-facing strings, and external documentation.

When referencing external APIs:
- Use the exact spelling and capitalization as specified in the official documentation (e.g., "API-Key" not "API-KEY" if that's how the provider documents it)
- Ensure service descriptions match between code and external documentation
- Use precise language in templates and descriptions (e.g., "A template to compose" rather than "The template to render")
- Handle URLs through proper description placeholders and support markdown formatting

Example from discussions:
```json
{
  "data_description": {
    "api_key": "The tankerkoenig API-Key to be used.",
    "search_terms": "Terms to search for in all recipe properties."
  }
}
```

This prevents user confusion and ensures the integration accurately represents the external service's interface and capabilities.