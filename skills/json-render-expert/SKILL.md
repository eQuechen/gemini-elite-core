---
name: json-render-expert
description: Expert in json-render (Vercel Labs), specialized in AI-generated UI with guardrails, JSONL patch streaming, and Next.js 16 integration. Use when implementing predictable, catalog-based UI generation, real-time JSON streaming, or exporting AI-generated UIs as standalone React/Next.js code in 2026.
---

# 🚀 json-render-expert (v1.0.0)

## Executive Summary
`json-render` (by Vercel Labs) is the 2026 standard for **Guardrailed AI User Interfaces**. Unlike raw LLM generations that often hallucinate or break, `json-render` forces AI models to work within a strictly defined **Catalog** of components validated by **Zod**. It specializes in **JSONL Patch Streaming**, allowing React components to render incrementally as bits of data arrive, ensuring sub-300ms perceived latency.

---

## 📋 Table of Contents
1. [Core Architecture](#core-architecture)
2. [The Catalog (The Guardrail)](#the-catalog-the-guardrail)
3. [Next.js 16 Integration](#nextjs-16-integration)
4. [Streaming Implementation (AI SDK)](#streaming-implementation-ai-sdk)
5. [The "Do Not" List (Anti-Patterns)](#the-do-not-list-anti-patterns)
6. [Standard Production Patterns](#standard-production-patterns)
7. [Reference Library](#reference-library)

---

## 🏗 Core Architecture
`json-render` operates on a three-pillar system:
- **@json-render/core**: The engine that handles state, data binding, and JSONL patch application.
- **@json-render/react**: The renderer that maps JSON schema to high-performance React 19 components.
- **@json-render/codegen**: The tool for exporting AI-generated state into pure, zero-runtime React code.

### The "State-to-UI" Loop
1. AI Model generates **JSONL Patches**.
2. `JSONRender` client accumulates patches into a **Virtual State**.
3. Components render dynamically based on the **Catalog** whitelist.

---

## 🛡 The Catalog (The Guardrail)
The Catalog is the single source of truth. It defines what the AI *can* build.

### Defining a Component in the Catalog
```typescript
import { z } from 'zod';

export const catalog = {
  components: {
    MetricCard: {
      schema: z.object({
        title: z.string(),
        value: z.number(),
        trend: z.enum(['up', 'down', 'stable']).optional(),
        color: z.string().default('#000'),
      }),
      description: 'Use for displaying key performance indicators (KPIs).',
    },
    DataChart: {
      schema: z.object({
        type: z.enum(['bar', 'line', 'pie']),
        data: z.array(z.object({ label: z.string(), value: z.number() })),
      }),
      description: 'Use for visualizing datasets.',
    }
  }
};
```

---

## ⚡ Next.js 16 Integration
Optimized for **Next.js 16.2 App Router** and **React 19.3**.

### Pattern: The Unified Stream Handler
In 2026, we avoid standard `JSON.parse` for streams. We use `JSONL` (JSON Lines) to allow partial renders.

**Server (app/api/render/route.ts):**
```typescript
import { streamText } from 'ai';
import { google } from '@ai-sdk/google';

export const runtime = 'edge';

export async function POST(req: Request) {
  const { prompt } = await req.json();

  return streamText({
    model: google('gemini-3-flash-preview'),
    system: 'Render the UI using the provided catalog components. Respond ONLY in JSONL format.',
    prompt,
    // json-render requires structural integrity
  }).toDataStreamResponse();
}
```

---

## 🤖 Streaming Implementation (AI SDK)
`json-render` shines when paired with the **Vercel AI SDK**.

### Client-side Progressive Rendering
```tsx
'use client';

import { JSONRender } from '@json-render/react';
import { useChat } from 'ai/react';
import { catalog } from './catalog';

export function AIInterface() {
  const { messages, isLoading } = useChat({ api: '/api/render' });

  // Filter messages for JSON content
  const lastMessage = messages[messages.length - 1];
  
  return (
    <div className="p-4 border rounded-xl shadow-2xl">
      <JSONRender 
        catalog={catalog} 
        json={lastMessage?.content} 
        streaming={isLoading} 
        fallback={<LoadingSkeleton />}
      />
    </div>
  );
}
```

---

## 🚫 The "Do Not" List (Anti-Patterns)

| Anti-Pattern | Why it fails in 2026 | Modern Alternative |
| :--- | :--- | :--- |
| **Open Prompts** | AI generates invalid components or props. | Use **Zod-validated Catalogs**. |
| **Blocking Renders** | User waits for full JSON before seeing UI. | Use **JSONL Patch Streaming**. |
| **Manual DOM Manipulation** | Breaks `json-render` state sync. | Use **Data Binding** paths. |
| **Over-complex Components** | Increases token count and latency. | Build **Atomic Components** in the catalog. |
| **Mixing Business Logic** | Logic inside JSON is hard to test and secure. | Use **Actions** to trigger server-side logic. |

## ⚠️ Common Pitfalls (Troubleshooting)
- **Zod Schema Mismatch**: If the AI sends a field that doesn't match the Zod schema, `json-render` will gracefully omit the component or field. Check the console for "Validation Error" logs.
- **Context Window Overflow**: Large catalogs can consume thousands of tokens. Use "Sub-Catalogs" for specific domains (e.g., `MarketingCatalog` vs `AdminCatalog`).
- **Hydration Mismatches**: Ensure your `JSONRender` components are only initialized on the client if they depend on dynamic streams. Use `dynamic(() => ..., { ssr: false })` if necessary.

## 🛠 Standard Production Patterns

### Pattern A: Two-Way Data Binding
`json-render` allows the AI to "hook" into your application's state using JSON Pointers.

```json
{
  "component": "Input",
  "props": {
    "label": "User Name",
    "value": "/user/profile/name" 
  }
}
```

### Pattern B: Conditional Visibility
Control UI based on external factors without re-prompting the AI.

```json
{
  "component": "AdminPanel",
  "visibility": {
    "rule": "auth.role === 'admin'"
  }
}
```

### Pattern C: Multi-Turn UI Updates
Instead of re-generating the whole UI, send the current JSON state back to the AI and ask for **minimal patches**.

```typescript
// AI Prompt Example
"Here is the current UI state: [JSON]. The user wants to add a 'Clear' button. Respond ONLY with the JSONL patch to add this button."
```

### Pattern D: Custom Renderers for Catalog Components
You can override how a catalog component is rendered without changing the catalog definition.

```tsx
<JSONRender 
  catalog={catalog} 
  json={data} 
  components={{
    MetricCard: (props) => <CustomStyledMetric {...props} />
  }}
/>
```

---

## 📖 Reference Library
Detailed deep-dives for `json-render` mastery:

- [**API Reference**](./references/api-reference.md): Package exports and method details.
- [**Next.js Optimization Guide**](./references/nextjs-optimization.md): Edge runtime and PPR integration.
- [**Catalog Design Patterns**](./references/catalog-design.md): Advanced Zod schemas and AI prompting strategies.
- [**Streaming & JSONL**](./references/streaming-patterns.md): Deep dive into the patch engine and latency.

*Updated: January 22, 2026 - 17:55*