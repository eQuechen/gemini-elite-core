---
name: ai-pro
description: Professional AI-driven asset generation and image manipulation suite. Optimized for Gemini 3, FLUX.2, and 2026 production workflows. Handles everything from photorealistic generation to intelligent image enhancement.
---

# AI-Pro: Professional Asset Generation Suite (2026)

*Updated: January 22, 2026 - 15:18*

AI-Pro is the definitive skill for high-fidelity image generation, editing, and enhancement. It leverages the latest multimodal models (Gemini 3 Pro, FLUX.2 Pro, SD4) to deliver production-ready visual assets.

---

## Table of Contents
1. [Core Capabilities](#core-capabilities)
2. [Model Selection Strategy 2026](#model-selection-strategy-2026)
3. [Quick Start](#quick-start)
4. [Standard Production Patterns](#standard-production-patterns)
5. [The "Do Not" List (Anti-Patterns)](#the-do-not-list-anti-patterns)
6. [Advanced Workflows](#advanced-workflows)
7. [Ethical AI & SynthID](#ethical-ai--synthid)
8. [Troubleshooting & FAQ](#troubleshooting--faq)
9. [Reference Library](#reference-library)

---

## Core Capabilities

- **High-Fidelity Generation**: Native 4K generation using FLUX.2 Pro and Gemini 3 Pro.
- **Intelligent Inpainting**: Precise image editing and object replacement.
- **Multimodal Feedback**: Using Gemini 3 Vision to refine and critique generated assets.
- **Professional Upscaling**: 2026-grade enhancement for low-res screenshots and photos.
- **Character Consistency**: Multi-reference support for maintaining brand identity.

---

## Model Selection Strategy 2026

Choosing the right model is critical for cost and quality optimization.

| Use Case | Recommended Model | Rationale |
| :--- | :--- | :--- |
| **Marketing Hero Images** | `black-forest-labs/flux.2-pro` | Best photorealism and text rendering. |
| **Complex Scientific Visuals** | `google/gemini-3-pro-image-preview` | Superior reasoning for intricate instructions. |
| **Rapid UI Mockups** | `google/gemini-3-flash` | Ultra-fast latency and low cost. |
| **Artistic/Stylized Assets** | `midjourney/v8` | Leading aesthetic variety. |
| **Local/Private Workflows** | `stability-ai/sdxl-turbo-v2` | Fast, local-capable, no cloud dependency. |

---

## Quick Start

### 1. Environment Setup
Ensure your `OPENROUTER_API_KEY` is set in your `.env` file.

```bash
# Check if key is present
grep "OPENROUTER_API_KEY" .env
```

### 2. Basic Generation
Generate a professional landscape in 16:9 aspect ratio.

```bash
python scripts/generate_image.py "Cinematic wide shot of a futuristic Tokyo at sunset, hyper-realistic, 8k" --output assets/tokyo_2026.png
```

### 3. Basic Editing
Change the weather in an existing photo.

```bash
python scripts/generate_image.py "Add heavy snow and winter atmosphere" --input assets/tokyo_2026.png --output assets/tokyo_winter.png
```

---

## Standard Production Patterns

### Pattern A: The Branding Suite
Maintaining consistency across multiple assets.

```python
# Pseudo-code for a batch branding script
prompts = [
    "Corporate headshot of a CEO in a tech office, professional lighting",
    "Company logo displayed on a glass building facade",
    "Team of diverse engineers working on a hologram"
]

for i, prompt in enumerate(prompts):
    generate_image(prompt, model="black-forest-labs/flux.2-pro", output=f"brand_{i}.png")
```

### Pattern B: The Scientific Illustration
Creating diagrams that actually make sense.

```bash
python scripts/generate_image.py "Cross-section of a lithium-sulfur battery showing ion flow, labeled parts, clean scientific style, white background" --model google/gemini-3-pro-image-preview
```

### Pattern C: Screenshot Enhancement
Transforming a 1080p screenshot into a 4K presentation asset.
*See [References: Image Enhancement](./references/image-enhancement.md) for details.*

---

## The "Do Not" List (Anti-Patterns)

### ❌ DO NOT use generic prompts
*Bad*: "A cat."
*Good*: "A hyper-realistic Siberian cat wearing a miniature astronaut suit, floating in a zero-gravity space station, cinematic lighting, 8k."

### ❌ DO NOT ignore Aspect Ratios
Generating a square image for a website banner results in poor composition when cropped.
*Best Practice*: Always specify `--ar 16:9` or `--ar 21:9` for wide assets.

### ❌ DO NOT skip the "Negative Prompt" for SD4
Stable Diffusion 4 still benefits from explicit exclusion of artifacts.
*See [References: Advanced Prompting](./references/advanced-prompting-guide.md).*

### ❌ DO NOT hardcode API Keys
Never commit API keys to the repository. Always use the `.env` loader provided in the scripts.

### ❌ DO NOT use Image Gen for Technical Schematics
While models are better in 2026, for precise electrical or architectural schematics, use the `scientific-schematics` skill which uses SVG/Mermaid.

---

## Advanced Workflows

### 1. Recursive Refinement
Use a vision model to improve your prompts.
1. Generate image.
2. Feed image to `gemini-3-vision`.
3. Ask: "What is missing from this image to make it look like a 1970s film?"
4. Update prompt with the feedback.

### 2. Character Consistency via Multi-Reference (FLUX.2)
FLUX.2 Pro supports multiple reference URLs to lock in a character's face and style.

```bash
# Example command using multiple references
python scripts/generate_image.py "The character [REF1] wearing a medieval armor" --input "ref1.png,ref2.png"
```

---

## Ethical AI & SynthID

In 2026, transparency is mandatory for professional workflows.
- **SynthID**: All images generated via the Google Gemini API are automatically watermarked with SynthID. This watermark is invisible to the human eye but detectable by software.
- **Usage**: When using these assets in public-facing documentation, it is recommended to include a small "AI-Generated" disclaimer in the metadata or caption.

---

## Implementation Patterns

### 1. Next.js 16 Integration (Server Actions)
Use this pattern to generate assets on-the-fly in a modern Next.js environment.

```typescript
// app/actions/generate-asset.ts
'use server'

import { auth } from '@/auth'
import { revalidatePath } from 'next/cache'

export async function generateAsset(formData: FormData) {
  const session = await auth()
  if (!session) throw new Error('Unauthorized')

  const prompt = formData.get('prompt') as string
  const model = formData.get('model') as string || 'black-forest-labs/flux.2-pro'

  // Execute the AI-Pro python script or call OpenRouter API directly
  const response = await fetch('https://openrouter.ai/api/v1/chat/completions', {
    method: 'POST',
    headers: {
      'Authorization': `Bearer ${process.env.OPENROUTER_API_KEY}`,
      'Content-Type': 'application/json'
    },
    body: JSON.stringify({
      model,
      messages: [{ role: 'user', content: prompt }],
      modalities: ['image']
    })
  })

  const data = await response.json()
  // Process and save to storage (e.g., S3, Vercel Blob)
  
  revalidatePath('/gallery')
  return { success: true, url: data.choices[0].message.images[0].url }
}
```

### 2. Python FastAPI Backend
For high-volume background processing of image assets.

```python
# api/image_gen.py
from fastapi import FastAPI, HTTPException, BackgroundTasks
from pydantic import BaseModel
import subprocess

app = FastAPI()

class GenRequest(BaseModel):
    prompt: str
    model: str = "google/gemini-3-pro-image-preview"

@app.post("/generate")
async def create_image(request: GenRequest, background_tasks: BackgroundTasks):
    try:
        # Using the AI-Pro CLI for consistent behavior
        cmd = [
            "python", "scripts/generate_image.py",
            request.prompt,
            "--model", request.model,
            "--output", f"outputs/{hash(request.prompt)}.png"
        ]
        
        # Run as a background task to avoid blocking the API
        background_tasks.add_task(subprocess.run, cmd, check=True)
        
        return {"status": "processing", "message": "Image generation started"}
    except Exception as e:
        raise HTTPException(status_code=500, detail=str(e))
```

---

## Performance Optimization

- **Prompt Caching**: OpenRouter supports prompt caching for long system instructions. If you use the same "Style" prefix for all images, you save 50% on input tokens.
- **Image Formats**: Use `.webp` for web assets to reduce payload size by up to 80% compared to PNG.
- **Tiled Upscaling**: For 8K+ requirements, generate at 2K and use the `image-enhancer` reference workflow for the final pass.
- **Parallel Generation**: Use Python `asyncio` or Node.js `Promise.all` when generating thematic batches.

---

## Security and Privacy

- **Data Minimization**: When using image editing (`--input`), strip EXIF metadata from the input file before uploading to cloud providers to protect user location data.
- **Content Filtering**: All 2026 models have built-in safety filters. If a request is blocked, the script will return a "Safety Filter Triggered" error. Do not attempt to bypass these filters.
- **Storage**: Generated assets should be stored in private buckets with signed URLs if they contain sensitive or proprietary concepts.

---

## Troubleshooting & FAQ

### Q: Why is my image blurry?
**A**: Ensure you are using a Pro model (FLUX.2 Pro or Gemini 3 Pro). Flash models often trade texture detail for speed. Also, check if you need to run the `image-enhancer` on the output.

### Q: The text in my image is gibberish.
**A**: Use **FLUX.2 Pro** or **Ideogram 3**. Gemini 3 is excellent at logic but occasionally hallucinates complex typography in small areas.

### Q: I'm getting a 401 Unauthorized error.
**A**: Check your OpenRouter balance and ensure your API key hasn't expired.

---

## Reference Library

Detailed deep-dives into specific AI-Pro domains:

- [**Advanced Prompting Guide 2026**](./references/advanced-prompting-guide.md): Technical keywords, lighting, and composition.
- [**Model Benchmarks 2026**](./references/model-benchmarks-2026.md): Speed, cost, and quality comparisons.
- [**Image Enhancement Suite**](./references/image-enhancement.md): Upscaling and sharpening workflows.
- [**Output Formats**](./references/output-format.md): Handling Base64, WebP, and PNG exports.

---

## Integration with Squaads Ecosystem

- **scientific-slides**: Automate the generation of slide backgrounds and hero images.
- **next16-expert**: Integrate AI-Pro scripts into Next.js Server Actions for dynamic asset generation.
- **docs-pro**: Automatically enhance screenshots before they are embedded in Markdown documentation.

---

*Updated: January 22, 2026 - 15:18*