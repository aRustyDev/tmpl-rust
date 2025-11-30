Use Context7 for:

- ✅ Learning new libraries
  - Example: "Show me how to set up a basic tokio application"
- ✅ API reference
  - Example: "What are the parameters for tokio::spawn?"
- ✅ Version-specific features
  - Example: "What changed in serde 1.0.200?"
- ✅ Best practices
  - Example: "What's the recommended way to structure async code in tokio?"

Don't need Context7 for:

- ❌ General Rust syntax
- ❌ Standard library
- ❌ Your own code structure
- ❌ Debugging your specific code

How Context7 Works

```asciidoc
  ┌──────────────────────────────────────────────┐
  │ You: "How do I use serde_json?"              │
  └────────────────┬─────────────────────────────┘
                   │
                   ▼
  ┌──────────────────────────────────────────────┐
  │ Claude Code decides: "I need serde_json docs"│
  └────────────────┬─────────────────────────────┘
                   │
                   ▼
  ┌──────────────────────────────────────────────┐
  │ MCP Call: context7.resolve-library-id        │
  │ Input: "serde_json"                          │
  │ Output: "/serde-rs/json"                     │
  └────────────────┬─────────────────────────────┘
                   │
                   ▼
  ┌──────────────────────────────────────────────┐
  │ MCP Call: context7.get-library-docs          │
  │ Input: "/serde-rs/json", topic: "usage"      │
  │ Output: [API docs, examples, types]          │
  └────────────────┬─────────────────────────────┘
                   │
                   ▼
  ┌──────────────────────────────────────────────┐
  │ Claude: "Here's how to use serde_json..."    │
  │ [Includes current examples from docs]        │
  └──────────────────────────────────────────────┘
```

### What Context7 Does

**Context7 is a documentation retrieval service** that provides:

1. **Up-to-date library documentation** - Not from Claude's training cutoff, but live
2. **API references** - Function signatures, types, examples
3. **Code examples** - Real examples from official docs
4. **Best practices** - Official patterns and recommendations

**It's NOT:**

- A general search engine
- Stack Overflow
- A code completion tool

**It IS:**

- Official documentation lookup
- Library-specific API reference
- Version-specific guidance

### Example: Rust Development

Without Context7:
User: "How do I use tokio::spawn?"
Claude: "Based on my training data from 2024..." (might be outdated)

With Context7:
User: "How do I use tokio::spawn?"
Claude: queries Context7 for tokio docs
Claude: "According to the latest tokio documentation..." (current)
