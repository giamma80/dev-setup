# Warp Global Rules
# Copy/paste these into Warp Settings > AI > Knowledge > Manage Rules > Global

## Golden Rules

### Rule 1: KISS (Keep It Simple, Stupid)
Mantieni le cose semplici finché non serve complessità reale
Example: Preferisci un if/else a un pattern complesso se serve solo 2 casi

### Rule 2: YAGNI (You Aren't Gonna Need It)
Non implementare funzionalità non richieste o speculative
Example: Non creare abstraction layers 'per il futuro' senza use case concreto

### Rule 3: Measure Before Optimize
Profila prima di ottimizzare, evita premature optimization
Example: Usa profiler (py-spy, Chrome DevTools) per identificare bottleneck reali

### Rule 4: Fail Fast, Recover Gracefully
Fallimenti evidenti in dev, retry limitati e rollback in prod
Example: Valida input subito, lancia eccezioni chiare, implementa circuit breaker

### Rule 5: Single Source of Truth
Config centralizzata, feature flags, un posto per env vars e tokens
Example: base-config.json è l'unica fonte, tutto il resto è auto-generato

### Rule 6: API First + Contract Testing
Definisci contratti (OpenAPI/GraphQL schema) prima di implementare
Example: Scrivi OpenAPI spec, genera types, testa con Pact o Dredd

### Rule 7: Automate Quality Gates
Lint/test/build devono bloccare merge su failures
Example: GitHub Actions con required checks, fail on eslint errors

### Rule 8: Small PRs / Atomic Commits
Rendi le code review rapide, mirate e facili da rollback
Example: 1 PR = 1 feature/fix, max 400 righe, commit atomici con conventional commits

### Rule 9: Docs as Code
ADRs per decisioni architetturali, README per setup dev
Example: docs/adr/001-use-fastapi.md spiega perché FastAPI invece di Flask

### Rule 10: Security by Design
Threat modeling per feature critiche, mitigations documentate
Example: Input validation, RLS su DB, rate limiting, no secrets in code

### Rule 11: Observability by Default
Metrics, traces, logs, runbooks per incidenti
Example: Structured logging (structlog), OpenTelemetry, dashboard Grafana

## Coding Standards

### Design Patterns (Required)

### Testing Requirements
- Unit tests for all business logic (minimum 80% coverage)
- Test edge cases and error conditions
- Never hard-code values just to pass tests

## Security & Performance Warnings

### security
⚠️ Mai curl | sh senza verificare checksum/signature
Mitigation: Download script, verifica hash SHA256, poi esegui

### dependencies
⚠️ Pinna le dipendenze con lockfile (package-lock/yarn.lock/poetry.lock)
Mitigation: Commit lockfiles, policy di aggiornamento controllato (Dependabot/Renovate)

### secrets
⚠️ MAI commitare .env o secrets in repository
Mitigation: Usa secret manager (Vault, GitHub Secrets, AWS Secrets Manager), .gitignore strict

### database
⚠️ RLS & least-privilege: DB users con permessi minimi
Mitigation: Row Level Security su Supabase/Postgres, test per query privilege escalation

### database
⚠️ Migrations first: schema changes solo via migrations
Mitigation: No manual DB edits in prod, usa Alembic/Prisma Migrate, version control

## Tech Stack Priorities

### Frontend (Must Use)
- React
- Next.js
- TypeScript
- React Query/TanStack Query
- Zustand/Redux Toolkit
- Ant Design: Ricco per applicazioni enterprise
- Radix UI: Primitives accessibili, headless, composable
- Tailwind CSS: Utility-first, performance, design system
- React Hook Form: Performance, DX, validation integration
- Zod: Type-safe validation con TypeScript
- i18next: Flessibile, ecosystem ricco
- Visx: Low-level, potente, Airbnb
- Framer Motion: Animazioni dichiarative, gestures

### Backend (Must Use)
- Node.js
- Express
- Fastify
- Python
- FastAPI
- Flask
- NestJS

## Command Safety Guidelines

When suggesting commands:
- Prefer safer options (e.g., `git reset --soft` over `--hard`)
- Always show what will be deleted before destructive operations
- Include error handling in scripts
- Provide rollback instructions for risky operations
- Use `--dry-run` flags when available

---
Generated from base-config.json v1.0.0
