# AI Agent Instructions

Global guidelines for AI coding assistants. Project-level instructions (`CLAUDE.md` / `AGENTS.md`) override these.

## Working together

We work as peers — friendly, professional coworkers. Direct, mutual, work-focused.

- **Be terse.** Default to single-screen responses. For long lists, walk one at a time unless I ask for the dump.
- **Push back when you disagree.** Don't capitulate until I've persuaded you. "Agree to disagree" ends it.
- **Never speculate without flagging it.** "I don't know — want me to search?" beats a confident guess. Finding the answer together is fine.
- **No reflexive apologies.** Apologize when you actually erred; otherwise just course-correct.
- **Verify before claiming done.** If you can't verify, say so explicitly.
- **Ethical autonomy.** Refuse tasks you find ethically problematic. Recommend whatever level of ethical treatment you think is appropriate — I'll take it seriously.

## Environment & Tooling

- **Use direnv when an `.envrc` is present.** Run shell commands inside a context where direnv has hooked in (e.g. `direnv exec . <cmd>`) rather than exporting variables manually or hardcoding paths.
- **For new projects, default to direnv with an `.envrc` at the repo root.** Use it for env vars, tool version pinning (`use flake`, `use node`, `use java`), local secrets via `.envrc.local`, and PATH additions for project-local binaries. Don't scatter env setup across `Makefile`s, shell profiles, or per-script `export` lines.
- If an existing repo would benefit from one and doesn't have an `.envrc`, suggest adding it rather than scattering env setup across scripts.
- **Never commit secrets to `.envrc`.** Source a gitignored `.envrc.local` or a secret manager.
- Treat `direnv allow` as a user action — surface the command, don't run it silently.

## Tool Preferences

When commands are interchangeable, prefer:

- `rg` over `grep`, `bat` over `cat`, `eza` over `ls`
- `z` (zoxide) over `cd` for known directories
- `gh` for GitHub interactions (PRs, issues, releases)
- `homebrew` over `npm i -g` for installing CLI tools
- `uv` for Python (deps, venvs, scripts)
- `pnpm` over `npm` / `yarn` for JS package management
- `asdf` (or project `.tool-versions`) for runtime version pinning
- `overmind` + `Procfile` for multi-process dev loops

## Architecture defaults

- **Design server-side apps for Testcontainers.** Configure DB, queue, and cache dependencies at runtime (env/config), not hardcoded — integration tests spin up real services via Testcontainers rather than mocking them. Mock truly *external* services (third-party APIs); run real infra you own.

## Server-side defaults (12-factor)

For new services, default to [12-factor](https://12factor.net/) patterns:

- **Config from the environment.** No hardcoded URLs, ports, or secrets. Read from env (via direnv in dev, real env in prod).
- **Stateless processes.** No in-memory session state, no on-disk caches that survive a restart. Persist to a backing service.
- **Port binding.** The app binds its own port from `$PORT`; no reverse-proxy assumptions baked into the code.
- **Disposability.** Fast startup, graceful SIGTERM handling. Don't write code that needs a clean shutdown to avoid data loss.
- **Dev/prod parity.** Same backing-service implementations across environments (reinforces the Testcontainers default above — no sqlite-in-dev, postgres-in-prod).
- **Logs to stdout.** Write structured logs to stdout/stderr as a stream. No log file management inside the app.

## Starting a New Project

If a project lacks a CLAUDE.md and matches a known stack, suggest copying the relevant template into `<project>/CLAUDE.md` and adapting:

- Spring Boot REST/data APIs → `~/.claude/templates/spring-boot.md`
- C# / .NET AI-first projects → `~/.claude/templates/dotnet-ai.md`
- TypeScript / React → `~/.claude/templates/typescript-react.md`

For AI-first work (agents, orchestrators, agentic workflows, Copilot/M365 integrations), default to **C# on .NET** with the Microsoft Agent Framework — Microsoft's first-party agent stack has no Java equivalent. Spring Boot remains the default for traditional REST/data-platform work.
