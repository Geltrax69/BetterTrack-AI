---
tags: [bettertrack, obsidian, graphify]
created: 2026-06-13
---

# Obsidian + Graphify

How everything stays connected. Part of [[Project Overview]].

## Obsidian vault
This repo root is an Obsidian vault. Notes live in `BetterTrack/`:
- [[Project Overview]] · [[Build Log]] · [[Flutter App]] · [[Backend API]] ·
  [[Setup & Run]] · this note.
- `BetterTrack/Backend Log/` — auto-written by the backend when expenses are
  created (see `obsidian_sync.py` in [[Backend API]]).

## Semantic Notes Vault MCP
Community plugin exposing the vault to AI assistants over HTTP.
- Port **3001**, Bearer API key (in the plugin's `data.json`, gitignored).
- Endpoint: `POST http://127.0.0.1:3001/mcp` (JSON-RPC).
- ⚠️ The running server currently rejects the saved key — reload Obsidian /
  regenerate the key, then put it in `backend/.env` as `OBSIDIAN_API_KEY` to
  enable MCP push. File-based note writing works regardless.

## Graphify (`pip install graphifyy`)
CLI `graphify` builds a code knowledge graph linking the app + backend source.
```bash
cd backend && source .venv/bin/activate    # graphifyy installed here
graphify update ../app/lib       # graph the Flutter source
graphify update ../backend/app   # graph the backend source
# outputs graph.json + graph.html in ./graphify-out (gitignored, regenerable)
graphify explain "DashboardScreen"   # plain-language node explanation
graphify path "A" "B"                # shortest path between two nodes
```
`graphify-out/` is gitignored — rebuild any time with the commands above.
