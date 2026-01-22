---
name: api-pro
description: Senior Architect specializing in high-performance, resilient, and secure API integrations. Optimized for Next.js 16, React 19, and the 2026 AI-agent ecosystem. Handles OIDC/Passkeys, RFC 7807 error patterns, and typed client contracts with Zod/Valibot.
---

# API Integration Specialist (v2026.1)

Expert guidance for integrating external APIs into modern applications with production-ready patterns, ultra-resilient logic, and deep security protocols.

## Table of Contents
1. [Core Integration Philosophy](#core-integration-philosophy)
2. [The "Do Not" List (Anti-Patterns)](#the-do-not-list-anti-patterns)
3. [Quick Start: 2026 Baseline](#quick-start-2026-baseline)
4. [Advanced Architectural Patterns](#advanced-architectural-patterns)
    - [Typed Contract Pattern](#typed-contract-pattern)
    - [The Resilience Wrapper](#the-resilience-wrapper)
    - [AI-Agent Ready Endpoints](#ai-agent-ready-endpoints)
5. [Security & Authentication (OIDC/Passkeys)](#security--authentication-oidcpasskeys)
6. [Resilience & Performance](#resilience--performance)
7. [Testing & Verification](#testing--verification)
8. [Deep Dive References](#deep-dive-references)

---

## Core Integration Philosophy
In 2026, API integration is no longer just about `fetch`. It's about **Contract Integrity**, **Zero-Trust Security**, and **Agentic Compatibility**. We treat every external API as a potentially failing, potentially malicious, but necessary extension of our system.

- **Zero-Trust**: Always validate every byte coming from an external source.
- **Fail-Fast & Graceful**: Use Circuit Breakers to prevent cascading failures.
- **AI-Native**: Structure responses so they are easily consumable by LLMs and AI Agents.

---

## The "Do Not" List (Anti-Patterns)

| Anti-Pattern | Why it fails in 2026 | Modern Alternative |
| :--- | :--- | :--- |
| **Trusting JSON** | External APIs change without notice, breaking TS types. | **Zod/Valibot Runtime Validation**. |
| **LocalStorage Tokens** | Vulnerable to XSS and token theft. | **Secure, HTTP-Only Cookies**. |
| **Plain `fetch` Retries** | Can cause "Thundering Herd" on servers. | **Exponential Backoff + Jitter**. |
| **Global `any` Errors** | Hard to debug and machine-unfriendly. | **RFC 7807 Problem Details**. |
| **Secrets in Frontend** | `NEXT_PUBLIC_` secrets are exposed to the world. | **Next.js Server Actions / Components**. |
| **Manual Pagination** | Prone to off-by-one errors and slow UI. | **Infinite Scroll with `useOptimistic`**. |

---

## Quick Start: 2026 Baseline

The minimum viable production-ready API call in 2026 requires:
1. Runtime Validation (Zod)
2. Proper Error Handling (RFC 7807)
3. Timeout protection

```typescript
import { z } from 'zod';

const UserSchema = z.object({
  id: z.string().uuid(),
  name: z.string(),
  email: z.string().email()
});

async function fetchUser(id: string) {
  const controller = new AbortController();
  const timeoutId = setTimeout(() => controller.abort(), 5000);

  try {
    const response = await fetch(`https://api.example.com/v1/users/${id}`, {
      signal: controller.signal,
      headers: { 'Accept': 'application/problem+json' }
    });

    if (!response.ok) {
      // Handle RFC 7807 Error
      const problem = await response.json();
      throw new Error(problem.detail || 'API Request Failed');
    }

    const data = await response.json();
    return UserSchema.parse(data); // Runtime validation
  } finally {
    clearTimeout(timeoutId);
  }
}
```

---

## Advanced Architectural Patterns

### 1. Typed Contract Pattern
Instead of scattered fetch calls, wrap your API in a typed client that enforces schemas.

```typescript
// lib/api/client.ts
import { z } from 'zod';

class APIClient {
  private baseUrl: string;
  private apiKey: string;

  constructor(baseUrl: string, apiKey: string) {
    this.baseUrl = baseUrl;
    this.apiKey = apiKey;
  }

  private async request<T>(endpoint: string, schema: z.ZodType<T>, options: RequestInit = {}): Promise<T> {
    const url = `${this.baseUrl}${endpoint}`;
    const res = await fetch(url, {
      ...options,
      headers: {
        'Authorization': `Bearer ${this.apiKey}`,
        'Content-Type': 'application/json',
        ...options.headers,
      },
    });

    if (!res.ok) throw await this.handleError(res);
    
    const data = await res.json();
    const result = schema.safeParse(data);
    
    if (!result.success) {
      console.error(`[API Contract Violation] ${url}:`, result.error);
      throw new Error("Invalid API Response Structure");
    }

    return result.data;
  }

  private async handleError(res: Response) {
    const isProblem = res.headers.get('Content-Type')?.includes('application/problem+json');
    if (isProblem) return res.json();
    return { title: 'Unknown Error', status: res.status };
  }

  // Public Methods
  public async getUser(id: string) {
    return this.request(`/users/${id}`, UserSchema);
  }
}
```

### 2. The Resilience Wrapper
Integrating Circuit Breakers and Smart Retries.

```typescript
import { CircuitBreaker } from 'lib/resilience'; // Hypothetical lib

const breaker = new CircuitBreaker({
  failureThreshold: 5,
  resetTimeout: 30000
});

async function resilientCall<T>(fn: () => Promise<T>): Promise<T> {
  return breaker.execute(async () => {
    return await retryWithJitter(fn);
  });
}
```

### 3. AI-Agent Ready Endpoints
When building APIs that AI Agents (like Gemini CLI) will use, provide "Actionable Metadata".

```json
{
  "result": "Order processed",
  "status": "success",
  "next_steps": [
    {
      "action": "track_package",
      "method": "GET",
      "url": "/api/orders/123/track",
      "description": "Poll this endpoint to see real-time location."
    }
  ]
}
```

---

## Security & Authentication

### OIDC & Passkeys
Moving beyond passwords. We prioritize WebAuthn for user-facing apps and OIDC with PKCE for federation.

- **Use PKCE**: Always include `code_challenge` and `code_verifier`.
- **Token Rotation**: Set `refresh_token_rotation: true` in your provider.
- **Session Sync**: Use Cross-device session management if available.

### API Key Security
- **Never Log Keys**: Use a dedicated logger that masks `Authorization` headers.
- **Key Scoping**: Generate keys with minimum viable permissions (Least Privilege).
- **Environment Parity**: Use different keys for `development`, `staging`, and `production`.

---

## Resilience & Performance

### Caching Strategy (Next.js 16)
Next.js 16 handles caching at multiple levels.

```typescript
// Time-based Revalidation
fetch('https://...', { next: { revalidate: 3600 } });

// Tag-based Revalidation (on demand)
fetch('https://...', { next: { tags: ['products'] } });
// Then elsewhere: revalidateTag('products')
```

### Response Streaming
For large datasets, use the `ReadableStream` API to process chunks as they arrive.

## Performance Optimization



### 1. Connection Pooling & HTTP/2

In server-side environments (Node.js/Bun), ensure you are reusing connections to avoid the TCP/TLS handshake overhead for every request.



```typescript

// Bun 1.2+ native fetch automatically pools connections.

// For Node.js, use undici's Agent.

import { Agent } from 'undici';



const agent = new Agent({

  connections: 100,

  maxRedirections: 3

});



const res = await fetch('https://api.example.com', { dispatcher: agent });

```



### 2. Request Collapsing

If 50 users hit the same page that fetches a product, don't make 50 API calls. Use a library or a built-in cache to collapse these into one.



```typescript

// Next.js cache() does this automatically for the duration of a request.

import { cache } from 'react';



export const getCachedData = cache(async (id: string) => {

  return await fetch(`https://api.example.com/data/${id}`).then(r => r.json());

});

```



### 3. Payload Compression

Always send `Accept-Encoding: gzip, br` and ensure your API client handles decompression (most modern ones do by default).



---



## Real-World Case Study: Integrating Stripe with Next.js 16



### The Scenario

A SaaS platform needs to handle subscriptions. We must ensure:

1. No raw card data touches our server (PCI compliance).

2. UI stays in sync with Stripe's state.

3. Webhooks are handled reliably even if our server is down.



### The Implementation Strategy



#### A. The Secure Checkout Action

Instead of a complex client-side setup, we use a Server Action to generate the checkout session.



```typescript

// app/actions/stripe.ts

'use server';



import { stripe } from '@/lib/stripe';

import { auth } from '@/auth';



export async function createCheckoutSession(priceId: string) {

  const session = await auth();

  if (!session?.user) throw new Error('Unauthorized');



  const checkoutSession = await stripe.checkout.sessions.create({

    customer: session.user.stripeCustomerId,

    line_items: [{ price: priceId, quantity: 1 }],

    mode: 'subscription',

    success_url: `${process.env.NEXT_PUBLIC_URL}/dashboard?success=true`,

    cancel_url: `${process.env.NEXT_PUBLIC_URL}/pricing?canceled=true`,

    metadata: { userId: session.user.id }

  });



  return { url: checkoutSession.url };

}

```



#### B. The Idempotent Webhook Handler

Webhooks can be sent multiple times. We must handle them once.



```typescript

// app/api/webhooks/stripe/route.ts

import { headers } from 'next/headers';

import { stripe } from '@/lib/stripe';

import { db } from '@/lib/db';



export async function POST(req: Request) {

  const body = await req.text();

  const signature = headers().get('Stripe-Signature') as string;



  let event;

  try {

    event = stripe.webhooks.constructEvent(

      body, 

      signature, 

      process.env.STRIPE_WEBHOOK_SECRET!

    );

  } catch (err) {

    return new Response(`Webhook Error: ${err.message}`, { status: 400 });

  }



  // Idempotency check: Have we processed this event ID before?

  const alreadyProcessed = await db.processedEvents.findUnique({

    where: { id: event.id }

  });

  if (alreadyProcessed) return new Response('OK', { status: 200 });



  switch (event.type) {

    case 'customer.subscription.deleted':

      await handleSubscriptionDeleted(event.data.object);

      break;

    // ... handle other events

  }



  // Mark as processed

  await db.processedEvents.create({ data: { id: event.id } });



  return new Response('OK', { status: 200 });

}

```



---



## Testing & Verification



### Mocking with MSW (Mock Service Worker)

Stop mocking `fetch` manually. Use MSW to intercept requests at the network level.



```typescript

import { http, HttpResponse } from 'msw';



export const handlers = [

  http.get('https://api.example.com/user', () => {

    return HttpResponse.json({ id: '1', name: 'Test User' });

  }),

];

```



### Contract Testing

Run a nightly cron job that validates the production API against your Zod schemas using `scripts/validate-api.ts`.



---



## Deep Dive References

- [Authentication (OIDC/Passkeys)](./references/auth.md)

- [Resilience & RFC 7807](./references/resilience.md)

- [Next.js 16 Integration](./references/nextjs-integration.md)

- [Stripe Integration](./references/stripe.md)



---



## Troubleshooting FAQ



### "My API Key is leaking in the network tab!"

**Cause**: You probably used `NEXT_PUBLIC_` or fetched on the client.

**Fix**: Move the fetch logic to a **Server Component** or a **Server Action**.



### "The API response doesn't match my Interface!"

**Cause**: The external team changed the API without telling you.

**Fix**: Implement the **Typed Contract Pattern** using Zod's `.parse()` to catch this at the entry point.



### "I'm getting 429 Too Many Requests."

**Cause**: You're hitting the rate limit without a client-side throttle.

**Fix**: Implement a **Queue/Rate-Limiter** on your side or increase the `resetTimeout` in your Circuit Breaker.



---



*Updated: January 22, 2026 - 15:18*
