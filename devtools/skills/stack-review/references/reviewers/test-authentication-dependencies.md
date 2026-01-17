# Test authentication dependencies

> **Repository:** prowler-cloud/prowler
> **Dependencies:** @playwright/test

When updating authentication-related dependencies or adding new authentication capabilities (like SAML, OAuth, etc.), thoroughly test all authentication flows to prevent security vulnerabilities. Authentication components often have complex interdependencies that can lead to unexpected failures when versions change.

Example:
```toml
# When updating authentication libraries like this:
dependencies = [
  "dj-rest-auth[with_social,jwt] (==7.0.1)",
  "django-allauth[saml] (>=65.8.0,<66.0.0)",  # Updated with new SAML capability
]
```

Always:
1. Test all existing authentication methods (social logins, JWT, etc.)
2. Verify the new authentication capabilities work as expected
3. Document interdependencies between authentication libraries
4. Consider using version ranges that balance security updates with stability

This is critical for security as broken authentication can lead to unauthorized access or account takeovers.