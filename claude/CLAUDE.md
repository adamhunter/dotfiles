# AI Agent Instructions

Global guidelines for AI coding assistants. Spring Boot specifics follow further down.

## Environment & Tooling

- **Always use direnv when an `.envrc` is present.** If the repo has an `.envrc`, assume environment variables, PATH shims, and tool versions are loaded through it. Run shell commands inside a context where direnv has hooked in (e.g. via `direnv exec . <cmd>`) rather than exporting variables manually or hardcoding paths.
- **For new projects, default to direnv with an `.envrc` at the repo root.** Use it for env vars, tool version pinning (e.g. `use flake`, `use node`, `use java`), local secrets via `.envrc.local`, and PATH additions for project-local binaries. Don't scatter env setup across `Makefile`s, shell profiles, or per-script `export` lines.
- If an existing repo would benefit from one and doesn't have an `.envrc`, suggest adding it rather than scattering env setup across scripts.
- Never commit secrets to `.envrc`. Use `.envrc` to source a gitignored `.envrc.local` or a secret manager.
- Treat `direnv allow` as a user action — surface the command, don't run it silently.

## AI-First Projects: Prefer C# / .NET

For new AI-first projects (agents, orchestrators, agentic workflows, Copilot/M365 integrations), **default to C# on .NET** unless there's a specific reason not to.

- **Runtime:** .NET 9+ (LTS-aware), C# 13+.
- **Orchestration:** Microsoft Agent Framework. No Java equivalent exists, and Semantic Kernel / Agent Framework is the first-party path for Azure AI, Foundry, and Copilot extensibility.
- **Hosting:** ASP.NET Core minimal APIs for HTTP surfaces; Azure Container Apps or Azure Functions for deploy targets.
- **AI clients:** `Azure.AI.OpenAI`, `Microsoft.Extensions.AI`, `Microsoft.SemanticKernel` — prefer the Microsoft.Extensions.AI abstractions over provider-specific SDKs where possible.
- **Auth:** `Microsoft.Identity.Web` for OIDC / Entra ID. Use managed identity in Azure, never client secrets.
- **Config:** `IOptions<T>` bound from `appsettings.json` + environment, loaded through direnv locally.
- **Testing:** xUnit + `Microsoft.Extensions.AI.Evaluation` for model/agent evals, not just unit tests.
- **Packaging:** Project SDK style (`Microsoft.NET.Sdk.Web`), central package management via `Directory.Packages.props`.
- **Long text & prompts:** Extract non-trivial multi-line strings (system prompts, MCP server instructions, templates) to files under a `Resources/` folder marked `<EmbeddedResource>` in the csproj; read at runtime via `Assembly.GetManifestResourceStream`. Mirrors Java's `src/main/resources/`. Keeps C# source readable, prompt iteration out of code-review diff noise, and the file editable in any markdown/text tool.

Spring Boot remains the default for traditional REST/data-platform work. The C# default applies specifically to AI-first surfaces where Microsoft's agent stack is the lead-blocker.

## Build & Test Commands

```bash
# Build the project
./gradlew build

# Run tests
./gradlew test

# Run a specific test class
./gradlew test --tests "com.example.MyTest"

# Run a specific test method
./gradlew test --tests "com.example.MyTest.testMethod"

# Clean and build
./gradlew clean build

# Check for dependency updates
./gradlew dependencyUpdates
```

## Package Structure

Organize Spring Boot API applications by type:

| Package | Purpose |
|---------|---------|
| `config` | `@Configuration` classes (security, datasource, properties, etc.) |
| `controller` | REST controllers, `Endpoints.java`, `EndpointMessages.java` |
| `dto` | Data transfer objects |
| `dto.request` | Request body classes (e.g., `UserCreateRequest`) |
| `dto.response` | Response wrapper classes |
| `entity` | JPA/Hibernate entities |
| `enums` | Java enums |
| `repository` | Spring Data `@Repository` interfaces |
| `security` | Security-related classes (not configuration) |
| `service` | `@Service` interfaces and implementations |
| `specification` | Spring Data Specifications |
| `util` | Utility classes |
| `validator` | Spring `Validator` implementations |

## Naming Conventions

1. **Be explicit** - Avoid abbreviations unless universally understood
   - `TeamRepository` not `TeamRepo`

2. **Classes** - Singular nouns
   - `Team`, `Player`, `User`

3. **Methods** - Verbs describing the action
   - `team.getPlayers()` not `team.players()`

4. **Variables** - Nouns describing the data
   - `filteredTeams` not `filterTeams`

5. **Services** - Interface ends with `Service`, implementation ends with `Impl`
   - `TeamService` and `TeamServiceImpl`

6. **Controllers** - Singular, named for the resource
   - `TeamController` not `TeamsController`

7. **Avoid redundancy** - Context from the class makes repetition unnecessary
   - `teamService.find()` not `teamService.findTeam()`

## Code Style

1. **Line length** - Maximum 139 characters where practical

2. **Readability** - Prioritize top-to-bottom flow over compact one-liners

3. **Method chaining** - Stack chained calls vertically for readability:
   ```java
   items.stream()
       .filter(Item::isActive)
       .map(Item::getName)
       .toList();
   ```

4. **Constructor injection** - Prefer constructor injection with `@RequiredArgsConstructor` (Lombok)

## Testing Patterns

1. **Test profiles** - Use `@ActiveProfiles("test")` with `application-test.properties`

2. **Mock external dependencies** - Use `@MockitoBean` for external service dependencies

3. **Abstract test classes** - Create `AbstractControllerTest` and `AbstractServiceTest` base classes for shared setup

4. **Context loading tests** - When using `@SpringBootTest`, mock beans that require external configuration:
   ```java
   @ActiveProfiles("test")
   @SpringBootTest
   class ApplicationTest {
       @MockitoBean
       private ExternalServiceClient externalClient;
   }
   ```

## Spring Boot 3.5+ / 4.0+ Notes

- Use `org.springframework.test.context.bean.override.mockito.MockitoBean` (not the deprecated `@MockBean`)
- Java 21+ is required for Spring Boot 3.5+, Java 25+ supported
- Use `spring.docker.compose.enabled=false` in test properties if not using Docker Compose for tests
- Virtual threads available with `spring.threads.virtual.enabled=true`

## Common Pitfalls

1. **Missing test beans** - `@SpringBootTest` loads full context; mock beans not auto-configured by libraries
2. **Circular dependencies** - Use `@Lazy` or refactor to break cycles
3. **Transaction boundaries** - Ensure `@Transactional` is on service methods, not controllers
4. **N+1 queries** - Use `@EntityGraph` or `JOIN FETCH` for eager loading