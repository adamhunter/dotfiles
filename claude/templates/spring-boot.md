# Spring Boot Project Conventions

Drop-in CLAUDE.md template for Spring Boot REST/data projects. Copy to `<project>/CLAUDE.md` and adapt.

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
