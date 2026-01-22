---
name: archive-searcher
id: archive-searcher
version: 2.0.0
description: "Professional Git Forensics and Archival Intelligence for deep historical recovery."
---

# 📂 Skill: archive-searcher v2.0.0
> **Optimized for Git 2.48+ and Conductor Track Management (2026 Standards)**

## 📋 Table of Contents
1. [Executive Summary](#executive-summary)
2. [Core Philosophy](#core-philosophy)
3. [Git Forensics: The Pickaxe Strategy](#git-forensics-the-pickaxe-strategy)
4. [Regex-Based Content Tracking (-G)](#regex-based-content-tracking--g)
5. [Reflog: The Ultimate Safety Net](#reflog-the-ultimate-safety-net)
6. [Archival Search: Conductor Tracks](#archival-search-conductor-tracks)
7. [Case Study: The Ghost of a Feature](#case-study-the-ghost-of-a-feature)
8. [Git Internal Object Analysis](#git-internal-object-analysis)
9. [Integrating with AI Analysis](#integrating-with-ai-analysis)
10. [Comparison of Search Tools](#comparison-of-search-tools)
11. [Best Practices for Searchability](#best-practices-for-searchability)
12. [The "Do Not" List (Common Pitfalls)](#the-do-not-list-common-pitfalls)
13. [Step-by-Step Implementation Patterns](#step-by-step-implementation-patterns)
14. [Restoring Deleted Branches & History](#restoring-deleted-branches--history)
15. [Searching for File Renames & Moves](#searching-for-file-renames--moves)
16. [Tooling & Scripts](#tooling--scripts)
17. [Reference Documentation](#reference-documentation)

---

## 🚀 Executive Summary
The `archive-searcher` skill is designed for high-precision historical analysis. It transforms the standard "grep" approach into a multi-layered forensic investigation. Whether you are hunting for a lost configuration from six months ago or tracing the exact commit that introduced a subtle race condition, this skill provides the tactical commands and mental models needed to navigate deep history.

In 2026, where AI-driven code generation and rapid iteration are the norm, the ability to reconstruct *why* a decision was made is more valuable than the code itself. This skill focuses on both the "Git-Way" and the "Conductor-Way" of archiving knowledge.

## 🧠 Core Philosophy
Information is rarely "deleted" in a well-managed project; it is simply "moved to the background." This skill assumes:
- **Persistence**: Git history contains the "Why" behind the "What." Every line of code is a snapshot of a decision.
- **Context over Content**: Finding the code is Step 1; finding the commit message, the author, and the PR context is Step 2.
- **Efficiency**: Use indexed searches (like `git log -S`) before brute-forcing history.
- **Layered Defense**: If it's not in the current branch, check other branches. If it's not in `git log`, check `git reflog`. If it's not in Git, check the `conductor` archives.

---

## 🛠 Git Forensics: The Pickaxe Strategy

### 1. The `-S` (Pickaxe) Search
The Pickaxe is the most efficient way to find when a specific string was introduced or removed. Unlike a standard grep, it only shows commits where the *number of occurrences* of the string changed.

**Why use it?**
- To find when a function was added.
- To find when a specific constant or hardcoded value was deleted.
- To trace the lifecycle of a specific variable name.

```bash
# Find when 'DeprecatedAPI' was added or removed
git log -S "DeprecatedAPI" --patch --oneline
```

**Advanced Usage**: Use it with `--all` to search through every branch, not just the current one.
```bash
git log -S "auth_token_v1" --all --graph --decorate
```

### 2. Regex-Based Content Tracking (-G)
While `-S` looks for changes in count, `-G` looks for changes that *match a regex*. This is much more powerful for finding structural changes.

```bash
# Find commits where lines matching a regex were added/removed
# Example: Finding any change to a port number between 3000-3999
git log -G "port: 3[0-9]{3}" --patch
```

**Scenario**: You suspect someone changed the database connection string format from `db://` to `postgres://`.
```bash
git log -G "(db|postgres)://" --patch
```

---

## 🕰 Reflog: The Ultimate Safety Net
`git reflog` tracks every time the `HEAD` of a branch moves. This includes actions that `git log` doesn't show:
- `git commit --amend` (the original commit is still in reflog).
- `git rebase` (the pre-rebase commits are in reflog).
- `git reset --hard` (the "lost" commits are still there).
- Deleted branches.

**How to recover a "lost" commit**:
1. Run `git reflog`.
2. Identify the hash (e.g., `abc1234`) before the "accident."
3. `git checkout abc1234` or `git reset --hard abc1234`.

```bash
# See local HEAD history for the last 90 days (default expiration)
git reflog --date=relative
```

---

## 📂 Archival Search: Conductor Tracks
In the Squaads ecosystem, we use "Conductor" to manage mission tracks. When a track is completed, it doesn't just vanish; it is archived.

### Archival Hierarchy
- `conductor/archive/`: Legacy tracks and completed specifications.
- `conductor/tracks/<track_id>/archive/`: Internal history of a specific track.
- `conductor/index.md`: The map to all current and past tracks.

### Strategy for Conductor Recovery
1. **Index Search**: Check `conductor/tracks.md` or `conductor/index.md` for the track status.
2. **Deep Grep**: Search within the `archive/` directories.
3. **Metadata Inspection**: Read `metadata.json` in archived tracks to find:
    - `completion_date`
    - `original_objective`
    - `parent_track_id` (for branched missions).

---

## 🕵️‍♂️ Case Study: The Ghost of a Feature
**Problem**: The "Team Collaboration Dashboard" was implemented in early 2025 but is missing in the 2026 build. No one remembers when it was removed.

**Investigation**:
1. **Search for keyword**: `git log --all --grep="Collaboration Dashboard"`
   - *Result*: Found a commit `e5f1b2c` titled "Cleanup legacy UI".
2. **Inspect the cleanup**: `git show e5f1b2c --stat`
   - *Result*: 45 files deleted, including `src/components/Dashboard.tsx`.
3. **Trace the origin**: `git log --diff-filter=A -- src/components/Dashboard.tsx`
   - *Result*: Found the original implementation in commit `a1b2c3d`.
4. **Conclusion**: The feature was removed as "legacy" but parts of the logic are needed for the new "Squaad Hub". The developer uses `git show a1b2c3d:src/components/Dashboard.tsx` to recover the core logic.

---

## 📦 Git Internal Object Analysis
Sometimes the high-level commands aren't enough. You need to look at Git's internal objects.

### Inspecting a Blob
If you have a hash but don't know what it is:
```bash
git cat-file -t <hash>  # Shows type (blob, commit, tree, tag)
git cat-file -p <hash>  # Pretty-prints the content
```

### Searching the Index
To see what files are currently tracked (including staged ones):
```bash
git ls-files --stage
```

---

## 🤖 Integrating with AI Analysis
When using this skill as an AI agent, follow these cognitive patterns:
1. **Broad to Narrow**: Start with `git log --oneline --grep` to find candidate commits.
2. **Contextualize**: Once a commit is found, use `git show --stat` to see the "blast radius" of the change.
3. **Verify Intent**: Read the commit message carefully. "Update stuff" is useless; "Fix memory leak in socket connection" is a gold mine.
4. **Synthesize**: Combine Git history with `conductor` metadata to provide a complete picture: *"This feature was added in Track-45 (Jan 2025) and removed in Track-89 (Dec 2025) due to a pivot in the UI strategy."*

---

## 📊 Comparison of Search Tools

| Tool | Best For | Speed | Deep History? |
| :--- | :--- | :--- | :--- |
| `grep -r` | Current working directory files. | Fast | No |
| `ripgrep (rg)`| Fast search in live code, respects gitignore. | Ultra Fast | No |
| `git grep` | Searching the current index/staged files. | Fast | Optional (`git grep <tree>`) |
| `git log -S` | Finding when a string appeared/disappeared. | Slow | **Yes** |
| `git log -G` | Regex patterns across history. | Very Slow | **Yes** |

---

## ✅ Best Practices for Searchability
To make future archival searches easier, follow these "Search-Oriented Development" rules:
- **Atomic Commits**: One change per commit.
- **Descriptive Messages**: Mention ticket IDs and specific function names.
- **Avoid "The Great Cleanup"**: Don't mix feature additions with massive refactors. It breaks the Pickaxe.
- **Tag Milestones**: Use `git tag -a v1.0.0` to create searchable anchors in time.

---

## 🚫 The "Do Not" List (Common Pitfalls)

| Anti-Pattern | Why it fails | Correct Approach |
| :--- | :--- | :--- |
| **Grep on live only** | Misses deleted files and historical context. | Use `git log -S` or `git grep` on historical commits. |
| **Ignoring Reflog** | Assumes `git log` is the only source of truth. | Check `reflog` for local "accidents" and amended commits. |
| **Search without Context** | Finding the line isn't enough; you need to know *why*. | Use `-p` or `--patch` to see the surrounding code changes. |
| **Full Repo Clone for Search** | Wasteful and slow for large repositories. | Use `git log --all --full-history -- [path]` for surgical search. |
| **Assuming Default Branch** | The history might be buried in a long-lost feature branch. | Always include `--all` when doing a deep forensic search. |
| **Deleting .git directory** | Destroys all forensic evidence permanently. | Never delete `.git` unless you are detaching history intentionally. |

---

## 💡 Step-by-Step Implementation Patterns

### Scenario 1: "Where did that legacy utility go?"
You remember a file `src/utils/legacy-formatter.ts` that was deleted months ago.

```bash
# 1. Find the last commit that touched the file
git log --all --full-history -- src/utils/legacy-formatter.ts

# 2. View the contents of that file at that specific commit
git show <commit_hash>:src/utils/legacy-formatter.ts

# 3. Restore the file to your current working directory
git checkout <commit_hash>^ -- src/utils/legacy-formatter.ts
```

### Scenario 2: "When was this dependency version pinned?"
Useful for debugging "It worked in v0.24 but broke in v0.25" scenarios.

```bash
# Search for changes in package.json affecting 'zod'
git log -L :dependencies:package.json --all
```

---

## 🔄 Restoring Deleted Branches & History
If you accidentally deleted a branch `feature/ai-integration`:
1. Find the last commit hash of that branch in `git reflog`.
2. `git checkout -b feature/ai-integration <hash>`.

---

## 📁 Searching for File Renames & Moves
Git doesn't explicitly track renames; it *infers* them. To search through renames:
```bash
git log --follow -- <new_path>
```
To find when a directory was moved:
```bash
git log --all --name-status --summary | grep "rename"
```

---

## 📜 Tooling & Scripts
The `skills/archive-searcher/scripts/` directory contains helpers:

### 1. `deep-search.sh`
A robust wrapper that combines `git log -S` with multi-branch awareness.
```bash
./skills/archive-searcher/scripts/deep-search.sh "SEARCH_TERM"
```

### 2. `track-forensics.py`
Analyzes `conductor` metadata to reconstruct the timeline of a specific mission.
```bash
python3 skills/archive-searcher/scripts/track-forensics.py --id track-123
```

---

## 📚 Reference Documentation
Detailed guides for specific domains:
- [Git Forensics Deep Dive](./references/git-forensics.md): Advanced Pickaxe, G-regex, and Internal Object Analysis.
- [Conductor Archival Standards](./references/conductor-archives.md): How to read and write to the long-term project memory.

---

## 📝 Troubleshooting
- **No results?**: Ensure you are using `--all`. Many changes live in orphaned branches.
- **Too many results?**: Use `--author` or `--since` to narrow the window.
- **Binary files?**: Git search works best on text. For binaries, use `git log -- [path]` to see metadata changes.

---

### *Updated: January 22, 2026 - 15:18*
