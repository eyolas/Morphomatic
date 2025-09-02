# Morphomatic

Morphomatic is a World of Warcraft addon that randomly uses a **cosmetic toy** from a curated database.

- 🔒 **Secure macro** (no taint): the `MM` macro prepares a random toy and triggers it via a hidden SecureActionButton.
- 🖱️ Optional **floating button**: movable, lockable, resizable.
- ⚙️ **Settings UI** (Dragonflight+): check/uncheck toys, skip cooldowns, auto-create macro.
- 🗂️ **DB-first approach**: only toys whitelisted in `toys_db.lua` (plus user-added extras) are considered.

## Usage
1. Copy the `Morphomatic/` folder into `_retail_/Interface/AddOns/`.
2. Log in → macro **“MM”** is auto-created:
```
#showtooltip
/run if MM and MM.PrepareSecureUse then MM.PrepareSecureUse() end
/click MM_SecureUse
```
3. Drag the macro to your action bar, or enable the floating button in settings.
4. `/mm` opens the configuration panel, `/mmdebug` MM.dprints diagnostics.

## File structure
- `toys_db.lua` – curated toy IDs.
- `helpers.lua` – saved vars, defaults, cooldown/usability helpers, secure button.
- `randomizer.lua` – builds the eligible list, prepares secure use.
- `floating_button.lua` – optional secure floating button.
- `settings.lua` – Settings UI (and legacy fallback).
- `bootstrap.lua` – events, slashes, auto-macro on login.

## Notes
- Cannot switch toys **in combat** (secure attribute restrictions).
- Only **owned** toys are considered; unchecked toys are excluded; cooldowns can be skipped.
