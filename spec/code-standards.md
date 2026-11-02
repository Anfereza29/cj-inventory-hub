# Code Standards — Sistema de Control de Inventario de Obra
## Constructora C&J S.A.S.

<!--
Defines how code is written, structured and reviewed across the project.
Architecture baseline: Clean Architecture. Testing: no unit tests required;
manual verification against acceptance criteria is mandatory (see constitution
Art. VI). Every rule here must stay consistent with spec/constitution.md and
spec/tech-stack.md. If a decision contradicts this document, amend the document
first.
-->

**Versión:** 1.0.0
**Fecha:** 2026-11-01
**Estado:** Activo
**Relacionado con:** `spec/constitution.md`, `spec/tech-stack.md`

---

## 0. Scope and quick rules

These are the non-negotiables. The rest of the document explains them.

1. **Language of code: English only.** All identifiers, file names, folder names,
   commit messages and comments are written in English. The user-facing UI text,
   however, stays in **Spanish** (constitution Art. IV) — only the strings shown
   to users are Spanish.
2. **Architecture: Clean Architecture.** Strictly enforced in the **Flutter app**
   and the **Next.js frontend**. The Supabase/backend side (SQL, policies, edge
   functions) follows a lighter, pragmatic separation (see §5).
3. **No unit tests required.** Instead, every user story is verified **manually
   against its acceptance criteria** before it is considered done (§8).
4. **Formatting and linting are mandatory and automated** (§7). Code that fails
   format or lint is not merged.
5. **Inventory integrity lives in the domain layer.** Any rule touching
   `Saldo = Initial + Entradas − Salidas` belongs to domain logic, never to UI
   (constitution Art. III).

---

## 1. Naming and language conventions

### 1.1 Everything in code is English
- Identifiers, functions, classes, files, folders, branches, commits: **English**.
- Comments and documentation inside code: **English**.
- Only exception: **strings displayed to the user** are in Spanish, and they live
  in a dedicated place (localization / constants), never hardcoded mid-logic.

### 1.2 Domain vocabulary mapping
The business speaks Spanish; the code speaks English. Use this canonical mapping
so the whole team names things the same way. Extend it as new terms appear.

| Dominio (ES) | Code (EN) |
|--------------|-----------|
| Material / insumo | `Material` |
| Catálogo de materiales | `MaterialCatalog` |
| Orden de compra | `PurchaseOrder` |
| Entrada / recepción | `StockEntry` (or `GoodsReceipt`) |
| Vale de salida | `IssueVoucher` / `StockIssue` |
| Salida / despacho | `StockIssue` |
| Frente de obra / actividad | `WorkFront` |
| Obra / proyecto | `Project` / `Site` |
| Operario / contratista | `Operator` |
| Almacenista | `Warehouseman` (role) |
| Residente | `SiteEngineer` (role) |
| Saldo / existencia | `balance` / `stock` |
| Punto de pedido | `reorderPoint` (PP) |
| Stock de seguridad | `safetyStock` (SS) |
| Conteo físico | `PhysicalCount` |
| Conciliación | `Reconciliation` |
| Kardex | `Kardex` (keep the term, it is standard) |
| Desviación de consumo | `consumptionDeviation` |

### 1.3 Casing rules

| Element | Dart (Flutter) | TypeScript (Next.js) |
|---------|----------------|----------------------|
| Classes / types | `PascalCase` | `PascalCase` |
| Variables / functions | `camelCase` | `camelCase` |
| Constants | `lowerCamelCase` (`const kReorderPoint` avoided; use `camelCase`) | `UPPER_SNAKE_CASE` for true constants |
| Files | `snake_case.dart` | `kebab-case.ts` / `PascalCase.tsx` for components |
| Folders | `snake_case` | `kebab-case` |
| Booleans | prefix with `is/has/can/should` | prefix with `is/has/can/should` |
| Database (Postgres) | — | `snake_case` tables and columns |

---

## 2. Clean Architecture — the model

Clean Architecture organizes code in concentric layers. The rule that matters
most is the **Dependency Rule**: source code dependencies point **inward only**.
Inner layers know nothing about outer layers.

```
        ┌─────────────────────────────────────────────┐
        │              PRESENTATION                     │  UI, widgets, pages,
        │        (depends on Application)               │  state, controllers
        │   ┌─────────────────────────────────────┐    │
        │   │           APPLICATION                │    │  use cases,
        │   │      (depends on Domain)             │    │  orchestration
        │   │   ┌─────────────────────────────┐   │    │
        │   │   │          DOMAIN              │   │    │  entities, value
        │   │   │   (depends on nothing)       │   │    │  objects, repo
        │   │   │                              │   │    │  interfaces, rules
        │   │   └─────────────────────────────┘   │    │
        │   └─────────────────────────────────────┘    │
        │              INFRASTRUCTURE                   │  Supabase, SQLite,
        │        (implements Domain interfaces)         │  HTTP, storage, files
        └─────────────────────────────────────────────┘
```

### Layer responsibilities

- **Domain** — The heart. Entities (`Material`, `StockEntry`, `IssueVoucher`),
  value objects, and **business rules** (Kardex balance, PP/SS thresholds).
  Pure Dart / pure TypeScript. **No Flutter, no React, no Supabase imports here.**
  Defines repository **interfaces** (abstractions), not implementations.
- **Application** — Use cases that orchestrate domain objects to fulfill a user
  story: `RegisterStockEntry`, `CreateIssueVoucher`, `GetStockWithAlerts`,
  `ReconcileInventory`, `ExportConsumptionToExcel`. One use case = one action.
  Depends only on Domain (uses the repository interfaces).
- **Infrastructure (Data)** — Concrete implementations: Supabase repositories,
  local SQLite cache, file/photo storage, Excel export. Implements the interfaces
  defined in Domain. This is the only layer that imports Supabase/SQLite SDKs.
- **Presentation** — UI only. Widgets/pages, state management, controllers. Calls
  use cases. Contains **no business rules** and **no direct data access**.

### The absolute rules
1. **Domain depends on nothing.** If a domain file imports Flutter, React,
   Supabase, or `dart:io` / `fs`, it is wrong.
2. **Dependencies point inward.** Presentation → Application → Domain.
   Infrastructure → Domain (by implementing its interfaces).
3. **Cross the boundary with interfaces.** Outer layers depend on abstractions
   defined in Domain, injected from the outside (dependency inversion).
4. **No business logic in the UI.** A widget/page never computes a balance,
   validates a Kardex rule, or calls Supabase directly.

---

## 3. Clean Architecture in the **Flutter app** (strict)

### 3.1 Folder structure (feature-first)
```
lib/
  core/                     # shared across features
    error/                  # Failure types, exceptions
    usecase/                # base UseCase contract
    di/                     # dependency injection setup
    utils/
  features/
    stock_entry/            # one feature = one vertical slice
      domain/
        entities/           # StockEntry, ...
        repositories/       # abstract StockEntryRepository
        usecases/           # RegisterStockEntry
      application/          # (optional) controllers/state orchestrators
      data/
        models/             # DTOs, fromJson/toJson
        datasources/        # SupabaseStockEntryDataSource, LocalStockEntryDataSource
        repositories/       # StockEntryRepositoryImpl
      presentation/
        pages/
        widgets/
        state/              # providers / notifiers
    stock_issue/
    inventory/              # stock list, kardex, PP/SS alerts
    reconciliation/
  l10n/                     # Spanish UI strings
  main.dart
```

### 3.2 Flutter-specific rules
- **State management:** `riverpod` (preferred) or `provider`. Keep providers in
  `presentation/state`. Providers call **use cases**, never data sources.
- **Dependency injection:** wire implementations to interfaces in `core/di`.
  Domain never news-up an infrastructure class.
- **Models vs entities:** `data/models` hold DTOs with `fromJson`/`toJson`;
  `domain/entities` are plain, serialization-free. Map between them in the data
  layer.
- **Errors:** domain/application return a typed result (e.g. `Either<Failure,T>`
  via `dartz`, or a sealed `Result`). Do not throw raw exceptions across layers.
- **Offline-first:** the local SQLite data source and the Supabase data source
  both sit behind the same repository interface; the repository decides
  cache-vs-remote and queues pending writes (see `tech-stack.md` §4).
- **No Supabase calls in widgets.** Ever.
- **UI strings in Spanish** come from `l10n`/constants, not inline literals.

---

## 4. Clean Architecture in the **Next.js frontend** (strict)

React/Next.js has no built-in layering, so we impose it. Business logic must be
framework-independent and testable by reading it, not buried in components.

### 4.1 Folder structure
```
src/
  core/                     # shared contracts, DI, errors, result type
  features/
    inventory/
      domain/
        entities/           # Material, KardexRow
        repositories/       # InventoryRepository (interface)
        usecases/           # getStockWithAlerts, computeDeviation
      data/
        dtos/
        datasources/        # supabase-inventory.datasource.ts
        repositories/       # inventory.repository.impl.ts
      presentation/
        components/         # dumb/presentational React components
        containers/         # wiring components to use cases
        hooks/              # UI hooks that call use cases
    reports/                # quincenal report, Excel export (HU-06, HU-07)
    catalog/                # HU-00
  app/                      # Next.js routes (thin; delegate to features)
  components/ui/            # shared design-system components (no logic)
  lib/                      # supabase client init, config
```

### 4.2 Frontend-specific rules
- **Routes/pages are thin.** `app/` files wire a container and render; they hold
  no business logic and no direct Supabase queries.
- **Components are presentational.** They receive data and callbacks via props.
  A `.tsx` component does not call Supabase and does not compute balances.
- **Use cases are plain functions/classes** in `domain/usecases`, free of React
  and Supabase. They receive repository interfaces by injection.
- **Data access is isolated** in `data/datasources` using `@supabase/supabase-js`.
  Only this layer imports the Supabase client.
- **Server state:** TanStack Query in the presentation layer, calling use cases.
- **Strict TypeScript:** `strict: true`. No `any` unless justified with a comment.
- **UI strings in Spanish**, centralized (constants / i18n), not inline.

---

## 5. Backend side (Supabase) — pragmatic, not strict

Per constitution Art. II, we do not over-engineer the backend.

- **Schema:** `snake_case` tables/columns. Enforce integrity in the database:
  foreign keys, `CHECK (quantity >= 0)`, and a **Kardex balance** computed via a
  view or a transactional function so `balance = initial + entradas - salidas`
  always holds (Art. III).
- **Row Level Security:** policies per role (warehouseman, site engineer, manager,
  accountant). Every table that holds project data has RLS enabled.
- **SQL organization:** keep migrations versioned in the repo (`/supabase/migrations`).
  One migration per logical change, with a descriptive English name.
- **Edge functions (if ever needed):** keep them small and single-purpose. Prefer
  database constraints and views over procedural code.
- No service layer, no ORM, no microservices. The clients talk to Supabase through
  their own data/infrastructure layer.

---

## 6. General coding rules (both stacks)

- **Single Responsibility:** one class/function does one thing. One use case per
  user action.
- **Small functions:** if a function needs scrolling to read, split it.
- **Immutability by default:** prefer `final`/`const` (Dart) and `const`/readonly
  (TS). Entities are immutable; create new instances instead of mutating.
- **No magic numbers/strings:** name them (`reorderPoint`, `safetyStock`,
  `maxVoucherItems`).
- **Explicit types at boundaries:** public functions, use cases and repository
  methods have explicit parameter and return types.
- **Error handling is typed:** return `Result`/`Either` across layers; convert
  exceptions to domain failures in the data layer.
- **No dead code / commented-out blocks** committed. Delete it; Git remembers.
- **Comments explain _why_, not _what_.** The code already says what.
- **Dependency injection over singletons** for anything replaceable (repos,
  data sources).
- **Keep UI and domain apart:** validation of a Kardex rule is domain code and is
  reused by both the mobile app and the admin web through their respective layers.

---

## 7. Formatting and linting (mandatory, automated)

| Stack | Formatter | Linter | Config |
|-------|-----------|--------|--------|
| Flutter / Dart | `dart format` | `flutter_lints` (via `analysis_options.yaml`) | enforced |
| Next.js / TS | **Prettier** | **ESLint** (Next.js + TypeScript rules) | enforced |

Rules:
- Code must pass `dart format`/Prettier and the linter **before merge**. A failing
  format or lint blocks the merge.
- Run format + lint locally before pushing. Recommended: a pre-commit hook and/or
  a CI check in GitHub that runs `flutter analyze` and `eslint`/`prettier --check`.
- Do not disable lint rules inline except with a short English comment explaining
  why.
- Keep one consistent config per stack, committed to the repo. No personal
  overrides.

---

## 8. Verification — no unit tests, manual acceptance required

There is **no requirement to write unit tests**. Correctness is verified as
follows (this satisfies constitution Art. VI's definition of "terminada"):

1. **Acceptance criteria are the contract.** Every user story (HU-00…HU-07) is
   checked manually against its Given/When/Then criteria before being marked done.
2. **Manual verification checklist per story** (record it in the PR or the backlog
   item):
   - [ ] Each acceptance criterion reproduced and passing manually.
   - [ ] Kardex identity holds after the action (`balance = initial + in − out`).
   - [ ] PP/SS alerts (yellow/red) behave as specified where relevant.
   - [ ] Offline capture + later sync works (mobile stories).
   - [ ] UI strings are in Spanish; no untranslated or hardcoded text.
   - [ ] `dart format`/Prettier and linters pass.
3. **Build must run clean.** The app builds and the web compiles with no errors
   and no new linter warnings before a story is closed.
4. **Validate with the user** (site engineer / warehouseman) for field-facing
   stories, as the constitution requires (Art. IV, VI), and keep the evidence.

> Optional, not required: if a piece of domain logic is tricky (e.g. deviation
> math), the author **may** add a focused test, but it is never mandatory.

---

## 9. Git and collaboration

- **Branches:** `feature/<hu-id>-short-description` (e.g.
  `feature/hu01-stock-entry`), `fix/<short-description>`.
- **Commits:** English, imperative mood, concise. Conventional style encouraged:
  `feat: register stock entry against purchase order`.
- **No direct commits to the main branch.** Changes go through a branch and a
  review (constitution Art. VII).
- **Pull requests** reference the HU id and include the manual verification
  checklist from §8.
- **One feature slice per PR** when possible; keep PRs reviewable.

---

## 10. Definition of Done (per user story)

A story is **Done** only when all of the following are true:

1. Implemented following Clean Architecture (strict on Flutter + frontend).
2. All acceptance criteria verified **manually** and passing (§8).
3. Kardex integrity preserved (constitution Art. III).
4. Format + lint pass; build/compile clean (§7).
5. Code is English; user-facing text is Spanish and centralized.
6. Field-facing stories validated with the client and evidence kept.
7. Merged via branch + review, referencing the HU id.
