# Morphomatic

Morphomatic is a World of Warcraft addon that randomly uses a **cosmetic toy** from a curated database.

- 🔒 **Secure macro** (no taint): the `MM` macro prepares a random toy and triggers it via a hidden SecureActionButton.
- 🖱️ Optional **floating button**: movable, lockable, resizable.
- ⚙️ **Settings UI** (Dragonflight+): check/uncheck toys, skip cooldowns, auto-create macro.
- 🗂️ **DB-first approach**: only toys whitelisted in `toys_db.lua` (plus user-added extras) are considered.

## Usage
1. Copy the `Morphomatic/` folder into `_retail_/Interface/AddOns/`.
2. Log in → macro **“MM”** is auto-created: