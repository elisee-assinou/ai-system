# Frontend Architecture Rules (DDD + Hexagonal + Event-driven)

## 1. Architecture principle

The frontend is modular and domain-driven.

Each module = bounded context (business feature).

Modules must be:
- independent
- testable
- self-contained
- not tightly coupled

No business logic outside modules.

---

## 2. GLOBAL STRUCTURE (Next.js App Router)

src/
app/                → Next.js routing layer ONLY
modules/           → business domains
shared/            → reusable UI + utils
core/              → infrastructure (event bus, config)

---

## 3. EXECUTION FLOW (IMPORTANT)

Every feature follows this flow:

UI (React)
→ Event (optional)
→ Application (use case)
→ Domain (business rules)
→ Infrastructure (API / external)
→ Response
→ UI update

---

## 4. MODULE STRUCTURE (MANDATORY)

Each module MUST contain:

module/
domain/
entities/
value-objects/
rules/

application/
use-cases/

infrastructure/
api/
repositories/

ui/
components/
pages/
hooks/

events/
definitions/

---

## 5. HEXAGONAL RULE (STRICT)

- UI never calls API directly
- UI only calls application layer
- Application depends on domain
- Infrastructure implements interfaces from domain/application

Dependency rule:

UI → Application → Domain ← Infrastructure

---

## 6. DOMAIN RULES

- Pure TypeScript only
- No React
- No API calls
- No framework dependency
- Contains only business logic

---

## 7. APPLICATION RULES

- Contains use cases (business workflows)
- Orchestrates domain logic
- Calls infrastructure through interfaces
- No UI logic allowed

Example:
- loginUser()
- updateProfile()
- fetchDashboard()

---

## 8. INFRASTRUCTURE RULES

- API calls only here
- Fetch / Axios / storage
- Implements domain interfaces
- Must be replaceable (mockable)

---

## 9. UI RULES (REACT / NEXT.JS)

- Presentation only
- Can use local state (UI state only)
- No business logic
- No API calls
- Uses application layer only

---

## 10. EVENT SYSTEM (REAL IMPLEMENTATION RULE)

Events are used ONLY for:

- UI decoupling
- cross-module communication

Flow:

UI Action → Emit Event → Application Handler → Domain → UI Update

Events examples:
- user.loggedIn
- profile.updated
- payment.completed

Events MUST NOT contain business logic.

---

## 11. NEXT.JS RULES

- Use App Router only
- Prefer Server Components
- Client Components only when needed
- Avoid unnecessary hydration
- Use server actions when possible

---

## 12. SHARED LAYER RULES

shared/
- UI components only
- utilities only
- NO business logic
- NO domain rules

---

## 13. CORE LAYER RULES

core/
- event bus implementation
- app config
- base abstractions
- global utilities

---

## 14. FORBIDDEN PATTERNS

- API calls inside UI
- Business logic inside React components
- Cross-module domain imports
- Shared mutable global state
- God components (>150 lines)
- Direct coupling between modules

---

## 15. DESIGN PHILOSOPHY

- Composition over inheritance
- Explicit flows over magic
- Modular independence over reuse
- Predictability over cleverness

## 16. FILE NAMING RULES

Use explicit file naming conventions.

Examples:

- LoginPage.tsx
- LoginForm.tsx
- useLogin.ts
- login.repository.ts
- login.api.ts
- login.use-case.ts
- login.events.ts

Rules:
- Components → PascalCase
- Hooks → camelCase starting with use
- Infrastructure → kebab-case
- Domain entities → PascalCase

## 17. IMPORT RULES

Allowed imports:

- UI can import:
    - application
    - shared
    - ui

- Application can import:
    - domain

- Infrastructure can import:
    - domain
    - application

Forbidden:
- UI importing infrastructure directly
- Cross-module domain imports
- Shared importing modules

## 18. COMPONENT RULES

Components must:
- stay focused
- have single responsibility
- avoid business logic
- avoid large JSX trees

Rules:
- Prefer composition
- Split components over 150 lines
- Extract reusable UI into shared/

## 19. HOOKS RULES

Custom hooks:
- contain UI orchestration only
- no business rules
- no direct API calls

Hooks can:
- call application layer
- manage local UI state

Hooks cannot:
- contain domain logic

## 20. STATE MANAGEMENT RULES

Global state is allowed ONLY for:
- authentication
- theme
- app-wide session state

Feature state should remain inside modules.

Avoid:
- massive global stores
- shared mutable state

## 21. AI EXECUTION RULES

When generating code:

- ALWAYS respect module boundaries
- NEVER place business logic inside UI
- ALWAYS separate application/domain/ui
- ALWAYS generate reusable components
- ALWAYS prefer explicit architecture
- NEVER bypass layers for convenience

Before generating code:
- determine the module
- determine the layer
- determine responsibilities
---
*Elisee ASSINOU*
