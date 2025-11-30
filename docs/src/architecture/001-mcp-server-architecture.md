1. MCP Server Architecture: Where Should Things Run?

Recommended: Hybrid Approach

Claude Code on Host + Dev Container

```asciidoc
┌─────────────────────────────────────────────────┐
│ macOS Host                                      │
│ ┌─────────────────────────────────────────┐     │
│ │ Claude Code                             │     │
│ │ - Reads/writes code on host             │     │
│ │ - Uses host MCP servers:                │     │
│ │ • filesystem (fast)                     │     │
│ │ • git (native)                          │     │
│ │ • github                                │     │
│ │ • Context7 (docs)                       │     │
│ └─────────────────────────────────────────┘     │
│                     │                           │
│                     ▼                           │
│ ┌─────────────────────────────────────────┐     │
│ │ Docker Container (rust-dev)             │     │
│ │ - Rust toolchain (cargo, rustc, etc.)   │     │
│ │ - Build dependencies                    │     │
│ │ - Test environment                      │     │
│ │ - Clippy, rustfmt                       │     │
│ │                                         │     │
│ │ Volume Mount:                           │     │
│ │ /Users/.../rust → /workspace            │     │
│ └─────────────────────────────────────────┘     │
└─────────────────────────────────────────────────┘
```

Why This Works Best:

1. Fast File Operations - Claude Code reads/writes directly on host (no container overhead)
2. Git Integration - Native git on macOS (fast, reliable)
3. Consistent Rust Environment - Container ensures same Rust version, dependencies across machines
4. Simple MCP Config - One config file on host for all projects
5. Easy to Use - No special setup needed for Claude Code
