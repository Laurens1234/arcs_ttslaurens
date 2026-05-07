# ARCS TTS Overlay Server

This folder is intended to be a standalone Node.js project that can be cloned and run by itself.

It accepts POST requests at `/overlay` and broadcasts the latest payload to browser clients via Server-Sent Events at `/events`. The browser page at `/` renders a simple OBS-friendly overlay.

## Clone / Run

```bash
git clone <this-repo-or-standalone-overlay-server-repo>
cd overlay_server
npm install
npm start
```

If you keep it inside the mod repository, just run the same commands from this folder.

## TTS Side

Make sure `src/SheetsSenderOverlay.lua` points `LOCAL_OVERLAY_URL` at your local server, usually:

```lua
http://127.0.0.1:3000/overlay
```

## OBS Side

Add a Browser Source pointing at:

```text
http://localhost:3000/
```

Set the source size as needed and keep the page background transparent if you want only the text overlay.

## What gets sent

Each payload contains a `players` array with:

- `steam_name`
- `color`
- `hand`
- `hand_size`

The TTS sender also prefers card descriptions when a card's name is generic, so cards like `Action Card` can render as their actual printed description.
