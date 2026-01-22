---
name: architect-pro
description: Advanced Software Architecture Masterclass. Implements Clean Architecture, Hexagonal (Ports & Adapters), and DDD for 2026 ecosystems (Next.js 16.2, React 19.3, Node.js 24). Optimized for AI-driven development.
---

# Architect Pro: Advanced Software Architecture (2026 Edition)

Master the art of building maintainable, scalable, and testable systems using proven architectural patterns. This skill is optimized for the **Next.js 16.2 / React 19.3 / Node.js 24** ecosystem, focusing on decoupling business logic from infrastructure and enabling **Autonomous AI Agents** to work effectively within your codebase.

## 📌 Table of Contents
1. [Core Philosophy](#core-philosophy)
2. [Quick Start: The 2026 Stack](#quick-start-the-2026-stack)
3. [Standard Pattern: Clean Architecture + Server Actions](#standard-pattern-clean-architecture--server-actions)
4. [Advanced Pattern: Event-Driven DDD](#advanced-pattern-event-driven-ddd)
5. [The 2026 Tech Standards](#the-2026-tech-standards)
6. [The Do Not List (Anti-Patterns)](#the-do-not-list-anti-patterns)
7. [Deep-Dive References](#deep-dive-references)
8. [Repository Analysis & Context Packing](#repository-analysis--context-packing)

---

## 🏛️ Core Philosophy
In 2026, software is increasingly built and refactored by **AI Coding Agents** (GPT-5, o3-deep-research). For an agent to be effective, the codebase must have **predictable boundaries**, **explicit contracts**, and **high-density context**.

- **Decoupling**: Business logic (Domain) must not depend on the database, UI, or frameworks.
- **Testability**: You should be able to test your core logic without spinning up a database or mocking complex framework internals.
- **Independence**: The system should be agnostic of its delivery mechanisms (Web, CLI, Mobile, AI Agents).
- **Predictability**: Files and folders should follow a strict convention so that both humans and AI can locate logic instantly.

---

## ⚡ Quick Start: The 2026 Stack
The most common production stack in 2026 uses **Next.js 16.2** with **Server Functions**, **TypeScript 5.x**, and **Bun/pnpm** monorepos.

### Recommended Folder Structure
```bash
src/
├── domain/           # Entities, Value Objects, Domain Logic (Pure TS)
├── application/      # Use Cases, Interfaces (Ports) - Orchestration
├── infrastructure/   # Adapters (Prisma, Stripe v13, Mailer, Auth.js v5)
├── app/              # Next.js Presentation Layer (Actions, Pages, Components)
└── shared/           # Cross-cutting concerns (Types, Utils, Constants)
```

### The "Hello World" of Architecture
1. **Define the Entity**: `src/domain/Project.ts`
2. **Define the Port**: `src/application/ports/IRepo.ts`
3. **Define the Use Case**: `src/application/use-cases/CreateProject.ts`
4. **Invoke via Action**: `src/app/actions/create-project.ts`

---

## 🛠️ Standard Pattern: Clean Architecture + Server Actions

### 1. The Domain Entity (The Heart of the System)
```typescript
// src/domain/entities/User.ts
import { UserEmail } from '../value-objects/UserEmail';

export class User {
  constructor(
    public readonly id: string,
    public readonly email: UserEmail,
    private _isActive: boolean = true
  ) {}

  public deactivate() {
    this._isActive = false;
  }

  get isActive() { return this._isActive; }
}
```

### 2. The Use Case (Application Layer)
```typescript
// src/application/use-cases/DeactivateUser.ts
import { IUserRepository } from '../ports/IUserRepository';

export class DeactivateUserUseCase {
  constructor(private userRepo: IUserRepository) {}

  async execute(userId: string): Promise<{ success: boolean }> {
    const user = await this.userRepo.findById(userId);
    if (!user) throw new Error("User not found");
    
    user.deactivate();
    await this.userRepo.save(user);
    
    return { success: true };
  }
}
```

### 3. The Server Action (Infrastructure/Adapter Layer)
```typescript
// src/app/actions/user-actions.ts
'use server'

import { DeactivateUserUseCase } from '@/application/use-cases/DeactivateUser';
import { PrismaUserRepository } from '@/infrastructure/repositories/PrismaUserRepository';
import { auth } from '@/auth'; // Auth.js v5

export async function deactivateUserAction(userId: string) {
  const session = await auth();
  if (!session?.user?.isAdmin) throw new Error("Unauthorized");

  // Dependency Injection for 2026
  const repo = new PrismaUserRepository();
  const useCase = new DeactivateUserUseCase(repo);
  
  try {
    return await useCase.execute(userId);
  } catch (error) {
    return { success: false, error: error.message };
  }
}
```

---

## 🚀 Advanced Pattern: Event-Driven DDD
For complex systems, use **Domain Events** to decouple side-effects like notifications, analytics, and third-party integrations (Stripe, AI).

### Triggering the Event
In the Aggregate Root:
```typescript
export class Order {
  private events: any[] = [];
  
  complete() {
    this.status = 'completed';
    this.events.push(new OrderCompletedEvent(this.id, this.total));
  }
  
  pullEvents() {
    const e = [...this.events];
    this.events = [];
    return e;
  }
}
```

---

## 🏗️ The 2026 Tech Standards

### 🔐 Authentication (Auth.js v5)
- **Edge Support**: Native support for Vercel Edge Runtime.
- **AUTH_ Prefix**: Always use `AUTH_SECRET`, `AUTH_GITHUB_ID` etc.
- **Performance**: 25% faster initialization than v4.
- [Detailed Auth Guide](./references/auth-flows.md)

### 🤖 AI Integration (GPT-5 & o3)
- **Autonomous Agents**: Implementing self-correcting loops for task automation.
- **o3-deep-research**: Using specialized models for large-scale codebase analysis.
- [Detailed AI Guide](./references/ai-integration.md)

### 💳 API Design (Stripe v13+)
- **Auto-Pagination**: Native async iterators for list operations.
- **Expanded Objects**: Deep retrieval of related resources in a single call.
- [Detailed API Guide](./references/api-standards.md)

---

## 🚫 The Do Not List (Anti-Patterns)

### 1. **Framework Leakage**
**BAD**: Importing `@prisma/client` inside your `domain/` directory.
**GOOD**: Define an `interface` in `application/ports` and implement it in `infrastructure/`.

### 2. **Anemic Domain Model**
**BAD**: Entities that are just bags of data (only public fields, no methods).
**GOOD**: Put validation and state transition logic inside your Entities.

### 3. **Fat Controllers / Fat Actions**
**BAD**: Writing complex database queries or external API calls directly inside a Server Action.
**GOOD**: Actions should only handle form parsing, auth checks, and delegate to a Use Case.

### 4. **Circular Dependencies**
**BAD**: `infrastructure/` importing `app/` (Presentation).
**GOOD**: Dependency flow must ALWAYS be: `Presentation -> Application -> Domain`.

---

## 📚 Deep-Dive References
Explore our specialized documentation for deeper technical insights:
- [**Auth Flows & Security**](./references/auth-flows.md): Auth.js v5, Edge-first auth, and 2026 security standards.
- [**AI Integration & Agents**](./references/ai-integration.md): GPT-5 patterns, o3-deep-research, and autonomous agent loops.
- [**API Standards & Stripe**](./references/api-standards.md): Stripe SDK v13+, auto-pagination, and robust API design.
- [**Monorepo & Indexing**](./references/monorepo-strategies.md): Bun/pnpm monorepos, Repomix context packing, and large codebase search.

---

## 🔍 Repository Analysis & Context Packing
In 2026, we use **Repomix** to provide AI agents with high-density, noise-free context.

### The "Repomix" Strategy
1. **Compress**: Remove comments and empty lines to save tokens.
2. **Filter**: Only include files relevant to the current architectural layer.
3. **Index**: Use `git grep` and `archive-searcher` patterns for lightning-fast symbol discovery in monorepos.

```bash
# Example: Pack domain logic for an AI Auditor
npx repomix --include "src/domain/**/*.ts" --output domain-context.md --compress
```

---

## 💎 Best Practices Checklist
- [ ] Is my Domain Layer free of external dependencies?
- [ ] Are my Use Cases doing only orchestration?
- [ ] Do I have interfaces (Ports) for all external services (DB, Auth, Mail, Stripe)?
- [ ] Am I using Value Objects for things like Email, Money, and Address?
- [ ] Is my code testable without a real database?
- [ ] Have I used the `AUTH_` prefix for all authentication environment variables?
- [ ] Is my monorepo optimized with Bun or pnpm?

---

*Updated: January 22, 2026 - 15:20*