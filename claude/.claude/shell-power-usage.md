# Shell Power User Tools - AI Agent Usage Guide

This guide explains how to effectively use modern command-line tools for file/folder navigation, search, management, and replacement operations when working as an AI coding agent.

## Decision Tree: Which Tool to Use?

### 1. Code Search & Replace (Structural)
**Use: `ast-grep` (alias: `sg`)**

When working with code and you need to understand the syntax/structure:
- Searching for function definitions, class declarations, or specific code patterns
- Refactoring code based on AST structure (not just text patterns)
- Finding all usages of a particular code construct
- Language-aware search and replace

**Examples:**
```bash
# Find all console.log statements
sg --pattern 'console.log($$$)'

# Find all async functions
sg --pattern 'async function $NAME($$$) { $$$ }'

# Structural replace
sg --pattern 'var $VAR = $INIT' --rewrite 'let $VAR = $INIT'
```

**Why ast-grep first?** It understands code structure, so you won't accidentally match strings, comments, or other false positives that text-based tools would find.

---

### 2. Text/Pattern Search (Content)
**Use: `rg` (ripgrep)**

When searching for text patterns across files:
- Finding text strings, log messages, or configuration values
- Regex-based pattern matching
- Searching non-code files (markdown, logs, config files)
- When you need raw speed for text search

**Examples:**
```bash
# Search for pattern (respects .gitignore by default)
rg "TODO"

# Search everything including ignored/hidden files
rga "API_KEY"

# Case insensitive search
rg -i "error"

# Search specific file types
rg "function" --type js

# Search with context (2 lines before/after)
rg -C 2 "error"

# List only filenames containing matches
rg -l "pattern"
```

**When to use over ast-grep?** Use ripgrep when:
- Searching non-code files
- Looking for simple text patterns
- You need extremely fast text search
- The pattern doesn't require understanding code structure

---

### 3. File Finding (By Name/Path)
**Use: `fd`**

When you need to locate files by name or path:
- Finding files by name pattern
- Listing files of a certain type
- Finding files by extension
- Navigating directory structures

**Examples:**
```bash
# Find files by name
fd config

# Find by extension
fd -e js -e ts

# Find everything including ignored/hidden
fda config

# Find and execute command on results
fd config -x cat

# Find in specific directory
fd config ~/projects

# Find directories only
fd -t d src
```

**When to use over rg?** Use fd when:
- You're searching for filenames, not file contents
- You need to find files by extension or path pattern
- You want to operate on the found files

---

### 4. Directory Listing & Tree View
**Use: `eza`**

When you need to understand directory structure:
- Listing directory contents with better formatting
- Viewing directory trees to understand project structure
- Getting file metadata (sizes, permissions, git status)

**Examples:**
```bash
# Basic listing (use configured aliases)
ls          # eza with directories first
ll          # long format with git status
la          # long format including hidden files
lt          # tree view (2 levels) with git status
lta         # tree view including hidden files

# Custom eza usage
eza --tree --level=3                    # Deeper tree
eza -lh --git --group-directories-first # Detailed listing
```

**When to use?**
- Understanding project structure at a glance
- Checking file sizes and types before operations
- Seeing git status of files in a directory

---

### 5. Text Replacement (Simple)
**Use: `sd` for simple find/replace**

When you need to replace text across files:
- Simple string replacement
- Regex-based substitution
- Safer than sed with better defaults

**Examples:**
```bash
# Simple replace
sd 'old' 'new' file.txt

# Regex replace
sd '\d+' 'NUMBER' file.txt

# Replace across multiple files
sd 'foo' 'bar' *.txt

# Preview changes (doesn't modify files)
sd -p 'old' 'new' file.txt
```

**When to use over ast-grep?**
- Simple text replacement (not code-aware)
- Working with non-code files
- Pattern-based replacement without AST understanding

---

### 6. Fuzzy Finding & Filtering
**Use: `fzf` for piping and filtering**

When you need to filter or select from command output:
- Filtering long lists of files
- Selecting from command output
- Building complex pipelines

**Examples:**
```bash
# Find and select a file (outputs selected path)
fd | fzf

# Preview files while selecting
fd | fzf --preview 'bat --color=always {}'

# Multi-select files
fd | fzf -m

# Filter git branches
git branch | fzf

# Search command history
history | fzf

# Combine with other commands
cat $(fd -e md | fzf)
```

**When to use?**
- When you have a list and need to select specific items
- Building pipelines that need filtering
- When you want to preview results before acting

---

## Workflow Examples

### Scenario 1: "Understand project structure before making changes"
```bash
# Step 1: Get overview with tree view
lt

# Step 2: Go deeper in specific directories
eza --tree --level=4 src/
```

### Scenario 2: "Find and refactor all React class components to functional components"
```bash
# Step 1: Find all class components (structural search)
sg --pattern 'class $NAME extends React.Component { $$$ }'

# Step 2: Review and plan refactoring
# (ast-grep can also do the replacement with --rewrite)
```

### Scenario 3: "Find all TODO comments in JavaScript files"
```bash
# Option A: If you want code-aware search (inside actual comments)
sg --pattern '// TODO: $$$'

# Option B: If simple text search is enough
rg "TODO" --type js
```

### Scenario 4: "Update all API endpoint URLs from http to https"
```bash
# Step 1: Find all files containing the old URL
rg -l "http://api.example.com"

# Step 2: Replace across all matching files
sd 'http://api.example.com' 'https://api.example.com' $(rg -l "http://api.example.com")
```

### Scenario 5: "Find all TypeScript config files and examine them"
```bash
# Find by name pattern
fd tsconfig

# Or find and filter with fzf
fd tsconfig | fzf
```

### Scenario 6: "List all test files in a project"
```bash
# Using fd
fd test.js -e spec.js

# Or search for files in __tests__ directories
fd -t f __tests__
```

---

## Tool Priority Order

For most tasks, follow this priority:

1. **`ast-grep` (sg)** - If working with code and need structural understanding
2. **`rg` (ripgrep)** - If searching for text patterns/content
3. **`fd`** - If searching for files by name/path
4. **`eza`** - If understanding directory structure/listing files (use aliases: ls, ll, la, lt)
5. **`fzf`** - If filtering lists or building pipelines
6. **`sd`** - If replacing text (simple patterns)

---

## Performance Tips

- **Use .gitignore**: Most tools respect `.gitignore` by default, making searches faster
- **Narrow scope**: Search specific directories or file types when possible
- **Combine tools**: Pipe `fd` output to `grep` or use `fd -x` to execute commands on results
- **Use aliases**: The configured aliases (`grep`, `find`, `ls`) provide consistent behavior
- **List files first**: Use `grep -l` to get filenames, then operate on those files

---

## Common Pitfalls

❌ **Don't use `rg` for finding files**
```bash
# Wrong
rg -r "config.js" .

# Right
fd config.js
```

❌ **Don't use `fd` for searching file contents**
```bash
# Wrong
fd . -x rg "pattern"

# Right
rg "pattern"
```

❌ **Don't use regex for code refactoring**
```bash
# Fragile (can match in strings, comments, etc.)
rg "function.*{" | sd ...

# Robust (understands code structure)
sg --pattern 'function $NAME($$$) { $$$ }'
```

❌ **Don't use basic ls when you need tree structure**
```bash
# Wrong (only shows one level)
/bin/ls -R

# Right (shows tree with depth control)
lt                      # alias for eza tree
eza --tree --level=3    # custom depth
```

---

## Quick Reference Table

| Task | Tool | Command Example |
|------|------|----------------|
| Search code structure | `ast-grep` | `sg --pattern 'class $X { $$$ }'` |
| Search text in files | `rg` (ripgrep) | `rg "pattern"` |
| Find files by name | `fd` | `fd filename` |
| List directory contents | `eza` | `ll` or `la` (aliases) |
| View directory tree | `eza` | `lt` (alias) or `eza --tree --level=N` |
| Filter/select from list | `fzf` | `fd \| fzf` |
| Replace text | `sd` | `sd 'old' 'new' file.txt` |
| Disk usage | `duf` | `duf` |
| Directory sizes | `dust` | `dust` |
| Process list | `procs` | `procs` |
| System monitor | `btm` (bottom) | `btm` |

---

## Combining Tools Effectively

### Pattern: Find → Filter → Act
```bash
# Find TypeScript files, filter by name, then read
fd -e ts | fzf | xargs bat

# Find all JS files, search for pattern, get unique files
fd -e js -x rg -l "import.*react"

# Find recent files and list them
fd --changed-within 1d | xargs eza -l
```

### Pattern: Search → Replace
```bash
# Find files with pattern, then replace
sd 'old' 'new' $(rg -l "old")

# Structural code replace
sg --pattern 'console.log($$$)' --rewrite '// removed console.log'
```

### Pattern: Explore → Navigate → Search
```bash
# 1. Understand structure
lt

# 2. Find specific files
fd component -e tsx

# 3. Search within those files
rg "useState" $(fd component -e tsx)
```
