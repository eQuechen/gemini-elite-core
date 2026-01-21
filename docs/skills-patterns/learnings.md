# Skill Design Patterns & Learnings

This document tracks the evolution of skill patterns in the Gemini Elite ecosystem, incorporating learnings from advanced modular skills.

## 1. Modular Architecture (Tool-Heavy Pattern)

Modern skills should move beyond simple text instructions toward **Searchable Databases** and **Automated Scripts**.

### Patterns identified:
- **Searchable Database**: Use `.csv` files in a `data/` folder to store structured knowledge (UX guidelines, styles, patterns, code snippets).
- **Python CLI Orchestrator**: A `scripts/search.py` (or similar) tool that allows the LLM to query the database dynamically instead of reading the entire manual.
- **Persistence Mechanism**: Skills that can generate a "Source of Truth" (like `design-system/MASTER.md`) and support hierarchical overrides (`design-system/pages/dashboard.md`).

## 2. Standardized Skill Structure (SKILL.md)

Every `SKILL.md` should follow this hierarchical structure for maximum clarity:

1.  **YAML Metadata**: `name`, `description` (optimized for LLM selection).
2.  **When to Apply**: Clear context for activation.
3.  **Rule Categories by Priority**: Use a table to define `CRITICAL`, `HIGH`, `MEDIUM`, `LOW` priorities.
4.  **Quick Reference**: Bullet points of most frequent rules.
5.  **How to Use (Workflow)**: Step-by-step instructions on how the LLM should interact with the skill tools.
6.  **Detailed Implementation Examples**: Real code blocks showing the pattern in action.
7.  **Tech Stack & Stacks Guidelines**: Specific best practices for different frameworks (React, Vue, Next.js, etc.).
8.  **Checklists**: Pre-delivery validation.

## 3. Reference-Oriented Design

Instead of bloating the main `SKILL.md`, move detailed documentation to a `references/` folder.
- `references/patterns.md`
- `references/implementation_guide.md`
- `references/troubleshooting.md`

## 4. Design Intelligence (UI/UX)

- **Master + Overrides Pattern**: Use a global master configuration for the whole project and specific override files for individual pages/components.
- **Reasoning Rules**: Use a reasoning CSV to help the model decide between different styles based on product type and industry.
- **Anti-Patterns Validation**: Explicitly list things to AVOID (e.g., "No emoji icons", "No layout shifts on hover").

## 5. Security & Auditing

- **Automation over Manual Check**: Provide scripts that perform automated scans (`scripts/security_auditor.py`).
- **Threat Modeling**: Automated scaffolding for security assessments.

## 6. Project Integration

- **setup.sh**: The setup script should be the entry point to initialize all skills and verify dependencies (like Python).
- **GEMINI.md**: Must reference this `learnings.md` file to ensure the model stays updated with the latest patterns.

## 7. Migration Success: 40+ Skills Integration

The recent migration of 41 new skills into the `-pro` suite serves as a benchmark for this architecture:

- **UI/UX Pro**: Merged 3 specialized skills into a unified design intelligence engine with searchable CSV databases.
- **Auditor Pro**: Integrated senior security tools with automated Python auditing scripts.
- **Architect Pro**: Standardized Clean Architecture and DDD patterns as core instructions.
- **Utility Pro**: Consolidated 11 development utilities (bug finding, code review, translations) into a single versatile toolkit.
- **Mobile Pro**: Integrated React Native architecture and design patterns for cross-platform excellence.
- **Docs Pro**: Unified 5 documentation skills into a comprehensive review and sync system.
