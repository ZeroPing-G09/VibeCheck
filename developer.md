# Best Developer Guide

## 1. Commit Message Format

All commits should follow this format in order to maintain consistency and clarity in the project history:

```
<type>(<scope>): <short summary>
```

## Types

| Type | Description |
|------|--------------|
| **feat** | A new feature or functionality |
| **fix** | A bug fix or patch |
| **refactor** | Code changes that improve structure without changing behavior |
| **chore** | Maintenance tasks (build scripts, configs, deps) |
| **docs** | Documentation updates |
| **test** | Adding or fixing tests |

---

## Examples

```
feat(frontend): added new settings pane
fix(db): changed user column to VARCHAR
feat(backend): add JWT-based auth middleware
chore(devops): update Dockerfile node version
docs(readme): add setup instructions
test(api): increase coverage for user endpoints
```
