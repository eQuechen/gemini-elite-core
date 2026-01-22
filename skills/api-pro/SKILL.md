---
name: api-pro
description: Expert in integrating third-party APIs with proper authentication, error handling, rate limiting, and retry logic. Specializes in Auth.js v5, GPT-5 model orchestration, Stripe SDK v13+, and architectural context packing for large codebases. Optimized for 2026 standards with Edge-first performance and autonomous agent integration.
---

# API Integration Specialist (v2026.1)

Expert guidance for integrating external APIs and LLMs into modern applications with production-ready patterns, security best practices, and autonomous agent capabilities.

## 1. Executive Summary: The 2026 Standard

As of January 2026, API integration has shifted from simple REST calls to **Autonomous Orchestration**. Systems must now support:
- **Edge-First Execution**: Minimum latency via Vercel Edge/Cloudflare Workers.
- **Agentic Logic**: Integration with the GPT-5 family for complex reasoning.
- **Context-Aware Architecture**: Using tools like Repomix to provide full repository context to AI agents.
- **High-Velocity Authentication**: Migrating to Auth.js v5 for 25% faster session handling.

## 2. Core Integration Pillars

### 2.1 Authentication & Security (Auth.js v5)

The gold standard for 2026 is **Auth.js v5**, which provides a unified, secret-first approach optimized for the Edge.

#### The `AUTH_` Prefix Standard
All environment variables MUST use the `AUTH_` prefix for automatic discovery by the framework.

```bash
# .env.local
AUTH_SECRET=your_signing_secret_here
AUTH_URL=https://myapp.com/api/auth
AUTH_GOOGLE_ID=google_client_id
AUTH_GOOGLE_SECRET=google_client_secret
```

#### Edge-Compatible Configuration
```typescript
// auth.ts
import NextAuth from "next-auth"
import Google from "next-auth/providers/google"

export const { handlers, auth, signIn, signOut } = NextAuth({
  providers: [Google],
  session: { strategy: "jwt" }, // Optimized for Edge performance
  pages: {
    signIn: "/auth/signin",
  },
  callbacks: {
    async jwt({ token, user, account }) {
      if (account && user) {
        token.accessToken = account.access_token;
      }
      return token;
    },
    async session({ session, token }) {
      session.accessToken = token.accessToken as string;
      return session;
    },
    authorized({ auth, request: { nextUrl } }) {
      const isLoggedIn = !!auth?.user
      const isApiRoute = nextUrl.pathname.startsWith("/api")
      if (isApiRoute && !isLoggedIn) return false
      return true
    },
  },
})
```

#### Performance Gains
- **25% Faster Sessions**: v5 reduces database lookups by caching JWTs aggressively.
- **Edge Runtime**: Full support for `middleware.ts` without Node.js polyfills.

### 2.2 AI & Model Orchestration (GPT-5 & o3)

Integrating the **GPT-5 family** requires understanding "Reasoning Tokens" and autonomous agent loops.

#### GPT-5 Reasoning Integration
```typescript
import { generateText } from "ai"
import { gpt5 } from "@ai-sdk/openai"

async function executeAutonomousTask(goal: string) {
  // 1. Planning with GPT-5 Reasoning
  const plan = await generateText({
    model: gpt5("gpt-5-reasoning"),
    system: "You are a master architect. Plan the solution step-by-step.",
    prompt: goal,
    maxTokens: 5000 // Allow for deep internal reasoning
  })

  // 2. Execution with specialised sub-agents
  const result = await processPlanSteps(plan.text)
  return result
}
```

#### o3-deep-research for Data Gathering
```typescript
import { o3 } from "@ai-sdk/research"

const researchAgent = async (topic: string) => {
  const deepResearch = await o3.conductResearch({
    query: topic,
    maxDepth: 10,
    allowedTools: ["search", "arxiv", "github"],
    autonomousMode: true
  })
  
  return deepResearch.summary
}
```

### 2.3 Financial Engineering (Stripe SDK v13+)

Stripe SDK v13+ introduces native auto-pagination and expanded object types with deep TypeScript support.

#### Auto-Pagination Example
```typescript
import Stripe from 'stripe';
const stripe = new Stripe(process.env.STRIPE_SECRET_KEY!);

async function cleanupStaleSubscriptions() {
  const subscriptions = stripe.subscriptions.list({
    status: 'past_due',
    limit: 100,
  });

  // Native async iterator handles cursors automatically
  for await (const sub of subscriptions) {
    console.log(`Cancelling sub: ${sub.id} for customer ${sub.customer}`);
    await stripe.subscriptions.cancel(sub.id);
  }
}
```

#### Expanded Objects with Type Safety
```typescript
const session = await stripe.checkout.sessions.retrieve('cs_test_123', {
  expand: ['line_items', 'customer', 'payment_intent.payment_method'],
});

// Accessing expanded data safely
if (typeof session.customer !== 'string' && session.customer !== null) {
  console.log(session.customer.email);
}
```

## 3. Architectural Excellence

### 3.1 Monorepo Strategy (Bun & pnpm)

Modern 2026 projects use **Bun** for speed and **pnpm** for strict dependency management.

- **Bun**: Used for running scripts, tests, and development servers (3x faster than Node).
- **pnpm**: Used for workspace management and ensuring no "phantom dependencies".

#### Workspace Structure
```
/
├── apps/
│   ├── web (Next.js 16)
│   └── agent (Autonomous GPT-5 service)
├── packages/
│   ├── api-client (Shared types/fetchers)
│   ├── ui (Shadcn/Tailwind 4)
│   └── database (Prisma 7/PostgreSQL)
├── package.json (Bun Workspaces)
└── pnpm-workspace.yaml
```

### 3.2 Context Packing (Repomix)

To enable AI agents to understand the codebase, we use **Repomix** to pack context efficiently.

```bash
# Generate context for GPT-5
bun x repomix --include "src/**/*.ts,lib/**/*.ts" --output codebase-context.md
```

## 4. Resilience & Implementation Patterns

### 4.1 Exponential Backoff & Circuit Breaker

```typescript
import { CircuitBreaker } from 'opossum';

const apiCall = async (endpoint: string) => {
  const response = await fetch(endpoint);
  if (!response.ok) throw new Error('API Down');
  return response.json();
};

const breaker = new CircuitBreaker(apiCall, {
  timeout: 3000,
  errorThresholdPercentage: 50,
  resetTimeout: 30000
});

breaker.on('open', () => console.warn('CIRCUIT OPEN: API is failing.'));

async function resilientFetch(url: string) {
  return breaker.fire(url).catch(err => {
    // Fallback logic
    return { error: true, message: 'Service temporarily unavailable' };
  });
}
```

### 4.2 Webhook Signature Verification (Edge Ready)

```typescript
import crypto from 'crypto';

async function verifyWebhook(req: Request, secret: string) {
  const body = await req.text();
  const signature = req.headers.get('x-signature')!;
  
  const hmac = crypto.createHmac('sha256', secret);
  const digest = hmac.update(body).digest('hex');
  
  return crypto.timingSafeEqual(
    Buffer.from(signature),
    Buffer.from(digest)
  );
}
```

## 5. Large Codebase Search & Archive Strategies

When working with massive repositories, standard `grep` is insufficient.

### 5.1 High-Performance Indexing
Maintain a `CODEBASE_INDEX.md` that acts as a Table of Contents for the entire project. This file is updated automatically on every commit.

### 5.2 Fast Search Techniques
- **Git Grep**: Use `git grep "pattern"` to leverage the git index for 10x faster searches.
- **Grep --file**: Use a pattern file to scan for multiple security vulnerabilities simultaneously.
  ```bash
  grep -f security-patterns.txt -r ./src
  ```

### 5.3 Archiving Old Logic
Move deprecated API integrations to `archive/api-v1/` rather than deleting them immediately. This preserves context for AI agents who might encounter old references in the git history.

## 6. The "Do Not" List (Common Anti-Patterns)

1.  **DO NOT** store API keys in the code. Use `AUTH_` prefixed environment variables for Auth.js.
2.  **DO NOT** use `any` for API responses. Use `zod` to validate and type all incoming data.
3.  **DO NOT** perform heavy processing in Webhook handlers. Acknowledge the receipt (200 OK) and queue the work (e.g., using Inngest or BullMQ).
4.  **DO NOT** use standard Node.js `http` modules in Edge functions. Use the `fetch` API exclusively.
5.  **DO NOT** assume API availability. Always implement timeouts and circuit breakers.
6.  **DO NOT** expose internal database IDs. Use UUIDs or Hashids for public-facing API resources.
7.  **DO NOT** ignore rate limit headers. Implement client-side throttling to stay within limits.

## 7. Reference Directory Map

| File | Description |
| :--- | :--- |
| `references/auth-next.md` | Deep dive into Auth.js v5 and Edge integration. |
| `references/ai-agents.md` | GPT-5 family and o3-deep-research agentic patterns. |
| `references/stripe-v13.md` | Stripe SDK v13+ features (auto-pagination, etc.). |
| `references/architect-archive.md` | Repomix context packing and large codebase indexing. |
| `references/resilience.md` | Advanced retry strategies and circuit breakers. |
| `references/nextjs-integration.md` | Patterns for Next.js 16 Server Components & Actions. |

## 8. Troubleshooting Guide

### 8.1 Authentication Failures
- **Symptom**: "Invalid CSRF Token" in Auth.js.
- **Fix**: Ensure `AUTH_URL` matches the request origin exactly, especially in preview environments.

### 8.2 AI Hallucinations in API Calls
- **Symptom**: GPT-5 generating invalid API parameters.
- **Fix**: Provide the agent with the specific `zod` schema or the Stripe SDK TypeScript definitions in the context.

### 8.3 Rate Limit Cascades
- **Symptom**: One service failing causes all upstream services to crash.
- **Fix**: Implement the Circuit Breaker pattern (see Section 4.1) to fail fast and provide cached fallbacks.

## 9. API Client Boilerplate (2026 Edition)

```typescript
import { z } from 'zod';

const UserSchema = z.object({
  id: z.string().uuid(),
  name: z.string(),
  email: z.string().email(),
});

type User = z.infer<typeof UserSchema>;

export class SecureAPIClient {
  private baseURL: string;
  private apiKey: string;

  constructor() {
    this.baseURL = process.env.API_BASE_URL!;
    this.apiKey = process.env.API_SECRET_KEY!;
  }

  private async request<T>(endpoint: string, schema: z.ZodSchema<T>): Promise<T> {
    const response = await fetch(`${this.baseURL}${endpoint}`, {
      headers: {
        'Authorization': `Bearer ${this.apiKey}`,
        'Content-Type': 'application/json',
      },
    });

    if (!response.ok) {
      const errorData = await response.json().catch(() => ({}));
      throw new Error(`API Request Failed: ${response.status} - ${JSON.stringify(errorData)}`);
    }

    const data = await response.json();
    return schema.parse(data); // Validate at the boundary
  }

  async getUser(id: string): Promise<User> {
    return this.request(`/users/${id}`, UserSchema);
  }
}
```

## 10. Conclusion

Mastering API integration in 2026 requires a shift from manual coding to **Architectural Orchestration**. By leveraging Auth.js v5, GPT-5's reasoning capabilities, and the robust Stripe v13 SDK, developers can build systems that are not only faster but also more autonomous and resilient.

Always prioritize **Context Packing** via Repomix to ensure your AI agents have the clarity they need to assist in complex refactors and debugging sessions.

---

### Integration with other Skills
- **next16-expert**: Combine with `auth-next.md` for secure Server Actions.
- **db-enforcer**: Use for ensuring schema alignment between API models and DB.
- **debug-master**: Utilize trace-based debugging for failed API calls.

*Updated: January 22, 2026 - 15:18
