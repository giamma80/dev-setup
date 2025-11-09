# Warp AI Rules - Dev Setup Project

## Developer Profile
Full-stack developer specializing in:
- Frontend: React, React Native, Next.js, TypeScript, iOS (Swift)
- Backend: Node.js (Express, Fastify, NestJS), Python (FastAPI, Flask)
- Database: Supabase, PostgreSQL, MongoDB, Redis
- Infrastructure: Docker, Vercel, Render, GitHub Actions
- Mobile: React Native, Expo, iOS Native

## Coding Standards

### Function/Method Rules
- Maximum 25 lines per function/method (NON-NEGOTIABLE)
- Single Responsibility Principle always
- Descriptive, self-documenting names
- No nested conditionals deeper than 3 levels

### Required Design Patterns
- Dependency Injection (tsyringe, InversifyJS)
- Strategy Pattern for algorithms
- CQRS for complex business logic
- Business Delegate for service layer
- Repository Pattern for data access

### Code Quality Requirements
- Unit tests for all business logic (minimum 80% coverage)
- ESLint + Prettier for JS/TS
- Pylint + Black + mypy for Python
- Type hints mandatory (TypeScript strict mode, Python type hints)
- No magic numbers - use named constants

### Zero Tolerance
- God Objects
- Duplicated code
- Hard-coded credentials or secrets
- Callback hell (use async/await)

## Tech-Specific Best Practices

### React/React Native
- Functional components + hooks only
- useMemo/useCallback for performance optimization
- Custom hooks for reusable logic
- Error boundaries mandatory
- FlatList for long lists (React Native)
- Reanimated 2 for animations (React Native)

### Node.js
- Dependency injection
- Structured logging (Pino, Winston)
- Input validation (Zod, Joi)
- Rate limiting on all public endpoints
- Health checks mandatory

### Python
- PEP 8 strict compliance
- Complete type hints
- Pydantic for validation
- Context managers for resource management
- Dataclasses for data structures
- FastAPI preferred over Flask

### Docker
- Multi-stage builds
- Non-root user
- .dockerignore optimized
- Health checks in Dockerfile
- Layer optimization

## Golden Rules
- **KISS**: Keep It Simple
- **YAGNI**: You Aren't Gonna Need It
- **Measure Before Optimize**: Profile before optimizing
- **Fail Fast, Recover Gracefully**: Errors should be obvious, rollback in production
- **Single Source of Truth**: Centralized configuration
- **API First**: Define contracts before implementation
- **Automate Quality Gates**: Linting/tests must block merge
- **Small PRs**: Maximum 400 lines, atomic commits
- **Security by Design**: Threat modeling, input validation
- **Observability by Default**: Metrics, traces, logs

## Command Guidelines

### Git
- Use `git status -sb` for compact status
- Always rebase instead of merge: `git pull --rebase`
- Commit messages: conventional commits format (feat:, fix:, refactor:)
- Clean merged branches regularly

### Docker
- Use multi-stage builds for smaller images
- Always specify explicit versions in FROM
- Run containers as non-root user
- Include health checks

### Node.js/NPM
- Use exact versions in package.json (no ^ or ~)
- Run `npm ci` in CI/CD (not `npm install`)
- Check for vulnerabilities: `npm audit`
- Use `.nvmrc` for Node version consistency

### Python
- Always use virtual environments
- Pin dependencies with `pip freeze`
- Use `requirements.txt` for production, `requirements-dev.txt` for dev
- Run linting before commits

## Security Rules
- Never commit secrets or API keys
- Use environment variables for sensitive data
- Implement rate limiting on public APIs
- Validate all user inputs
- Use HTTPS only in production
- Enable Row Level Security (RLS) in Supabase
- Scan dependencies for vulnerabilities regularly

## Performance Guidelines
- Lazy load components and routes
- Use pagination for large datasets
- Implement caching strategies (Redis, CDN)
- Optimize database queries with indexes
- Monitor bundle sizes (max 250KB initial)
- Use Web Workers for heavy computations

## When Suggesting Commands
- Prefer safer options (e.g., `git reset --soft` over `--hard`)
- Always show what will be deleted before destructive operations
- Include error handling in scripts
- Provide rollback instructions for risky operations
- Use `--dry-run` flags when available
