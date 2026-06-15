# AGENTS.md

## General Rules

- MUST: Use @antfu/ni. Use `ni` to install, `nr SCRIPT_NAME` to run. `nun` to uninstall.
- MUST: Use TypeScript interfaces over types.
- MUST: Never comment unless absolutely necessary.
  - If the code is a hack (like a setTimeout or potentially confusing code), it must be prefixed with // HACK: reason for hack
- MUST: Do not type cast ("as") unless absolutely necessary.
- MUST: Ask for permission before committing to PRs. Never commit directly without approval.
- MUST: Remove unused code and don't repeat yourself.
- MUST: Frequently re-evaluate and refactor variable names to be more accurate and descriptive.

## Tech Stack

- **Language**: TypeScript (strict mode, ESNext target, Bundler module resolution)
- **Module System**: ESM (`"type": "module"`)
- **Bundler**: tsdown (with `vscode` as external, dependencies inlined)
- **Package Manager**: pnpm (with catalogs in `pnpm-workspace.yaml`)
- **Linter**: ESLint via `@vida0905/eslint-config`

## Commands

```bash
nr dev          # Start dev server (tsdown --watch)
nr build        # Production build
nr lint:fix     # Auto-fix lint issues
nr typecheck    # TypeScript type checking
nr test         # Run tests (vitest)
```

## Code Conventions

### Code Style

- Prefer early return

### TypeScript

- Strict mode — never use `any`
- Validate rather than assert

### Commits

- Use [Conventional Commits](https://www.conventionalcommits.org/): `type(scope): description` (lowercase subject).

### Tests

- Use [Vitest](https://npmx.dev/package/vitest) as test framework.
- Never change snapshot manually.
