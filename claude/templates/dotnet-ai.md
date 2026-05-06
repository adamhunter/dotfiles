# C# / .NET AI-First Project Conventions

Drop-in CLAUDE.md template for AI-first .NET projects (agents, orchestrators, agentic workflows, Copilot/M365 integrations). Copy to `<project>/CLAUDE.md` and adapt.

## Stack

- **Runtime:** .NET 9+ (LTS-aware), C# 13+.
- **Orchestration:** Microsoft Agent Framework. Semantic Kernel / Agent Framework is the first-party path for Azure AI, Foundry, and Copilot extensibility.
- **Hosting:** ASP.NET Core minimal APIs for HTTP surfaces; Azure Container Apps or Azure Functions for deploy targets.
- **AI clients:** `Azure.AI.OpenAI`, `Microsoft.Extensions.AI`, `Microsoft.SemanticKernel`. Prefer the `Microsoft.Extensions.AI` abstractions over provider-specific SDKs where possible.
- **Auth:** `Microsoft.Identity.Web` for OIDC / Entra ID. Use managed identity in Azure, never client secrets.
- **Config:** `IOptions<T>` bound from `appsettings.json` + environment, loaded through direnv locally.
- **Testing:** xUnit + `Microsoft.Extensions.AI.Evaluation` for model/agent evals, not just unit tests. Use `Testcontainers` (NuGet) for owned infra (Postgres, Redis, etc.); mock third-party HTTP APIs only.
- **Packaging:** Project SDK style (`Microsoft.NET.Sdk.Web`), central package management via `Directory.Packages.props`.

## Long text & prompts

Extract non-trivial multi-line strings (system prompts, MCP server instructions, templates) to files under a `Resources/` folder marked `<EmbeddedResource>` in the csproj. Read at runtime via `Assembly.GetManifestResourceStream`. Mirrors Java's `src/main/resources/`. Keeps C# source readable, prompt iteration out of code-review diff noise, and the file editable in any markdown/text tool.

## Dev process loop

Manage `dotnet run` and any sidecars via [overmind](https://github.com/DarthSim/overmind) with a `Procfile` in the repo root. In each `Procfile` line, pipe output through `tee logs/<name>.log` — output stays visible in overmind's multiplexer AND lands in a file for grep / AI inspection / post-mortems. Use a committed `logs/.keep` plus `.gitignore` rules (`/logs/*` and `!/logs/.keep`) so the folder is tracked but contents aren't. Restart individual processes with `overmind restart <name>` instead of stop-rebuild-start cycles.
