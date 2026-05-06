<!-- starter; expand as conventions emerge -->

# TypeScript / React Project Conventions

Drop-in CLAUDE.md template for TypeScript / React projects. Copy to `<project>/CLAUDE.md` and adapt.

## Tooling

- **Package manager:** `pnpm` (not `npm` or `yarn`).
- **Formatter:** Prettier.
- **Type checking:** run `tsc --noEmit` as a verification step before claiming work is done.

## TypeScript

- `strict: true`. Avoid `any` — prefer `unknown` + narrowing.
- Prefer `type` over `interface` unless declaration merging is needed.

## React

- Function components + hooks only; no class components.

## TBD

These need to be filled in per project:

- Testing framework (Vitest? Jest? Playwright for e2e?)
- State management (none / Zustand / Redux Toolkit / Tanstack Query?)
- Styling (CSS modules / Tailwind / vanilla-extract?)
- Routing (React Router / Tanstack Router?)
- Component library / design system
