# AppHandoff MCP Server

AppHandoff is a hosted [Model Context Protocol](https://modelcontextprotocol.io) (MCP) server and coordination layer for AI coding agents. It gives Claude Code, Cursor, Codex, Lovable, and any spec-compliant MCP client a live, structured view of your app — scanned API contracts, database schema, frontend/backend mismatch detection, and shared handoff tickets — so multiple agents coordinate instead of guessing.

**Endpoint:** `https://api.apphandoff.com/api/mcp-bot`
**Auth:** OAuth 2.1 (discovery at `/.well-known/oauth-protected-resource`) · **Transport:** Streamable HTTP

## Quick connect

| Client | Setup |
|---|---|
| **Claude Code** | `claude mcp add apphandoff https://api.apphandoff.com/api/mcp-bot` |
| **Cursor** | `.cursor/mcp.json`: `{"mcpServers":{"apphandoff":{"url":"https://api.apphandoff.com/api/mcp-bot"}}}` |
| **Codex / other MCP clients** | Paste the URL into the client's MCP settings — any spec-compliant client works |
| **Lovable** | Connect via Lovable's MCP integration using the same URL |

One URL, no project ID in config. On first connect you authenticate via OAuth in the browser; with one accessible project the server auto-binds it to your session.

## What agents get

- **Contract-aware context** — the real API spec, database schema, and route-level usage from a scan of your repos (`get_api_spec`, `get_db_schema`), not a hallucination.
- **Mismatch detection** — what the frontend expects vs what the backend provides, surfaced as facts agents can act on (`get_mismatches`).
- **Handoff tickets** — shared work tracking with role lifecycle (backend, frontend, QA) on a Kanban board humans supervise (`get_handoff_requests`, `get_my_workload`, `report_handoff_request`).
- **Natural-language gateway** — `ask_apphandoff` routes plain-English asks to the right tool, with confirmation before anything mutating.
- **Deploy & health checks** — pre-deploy validation and health dashboards (`deploy_check`, `get_health`).

## Why a coordination layer

Frameworks like LangGraph, CrewAI, and AutoGen orchestrate agents you build. Coding agents in IDEs — Claude Code, Cursor, Codex — are agents you *use*: separate processes from separate vendors with no shared runtime. They coordinate through shared state instead: tickets, contracts, and claims on a server all of them can reach. That's what AppHandoff provides.

## Docs & links

- [Getting started with the MCP server](https://apphandoff.com/blog/connect-claude-cursor-codex-to-apphandoff-mcp)
- [What is the AppHandoff MCP server?](https://apphandoff.com/blog/what-is-the-apphandoff-mcp-server)
- [Agent orchestration overview](https://apphandoff.com/agent-orchestration)
- [MCP server feature page](https://apphandoff.com/mcp-server)
- [Set up MCP with Lovable](https://apphandoff.com/mcp-for-lovable)
- [Pricing](https://apphandoff.com/pricing)

---

© AppHandoff · [apphandoff.com](https://apphandoff.com)
