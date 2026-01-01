# Morphomatic - Project Context

## Project Overview
**Morphomatic** is a World of Warcraft addon that enables players to randomly transform their character using a curated list of cosmetic toys. It provides a secure macro (`/mm`) and a floating UI button to trigger these transformations.

- **Type:** World of Warcraft Addon
- **Language:** Lua 5.1 (WoW API)
- **Frameworks/Libs:** Ace3 (AceLocale), LibStub, CallbackHandler, LibDataBroker, LibDBIcon, Poncho-2.0, Sushi-3.2.

## Architecture

### Entry Point & Loading
- **Metadata:** `Morphomatic.toc` defines the addon metadata, saved variables, and the XML entry point.
- **Loader:** `addons/main.xml` is the technical entry point. It handles the inclusion order:
    1.  `libs/libs.xml` (External libraries)
    2.  `localization/localization.xml` (Localization strings)
    3.  `addons/*.lua` (Core addon logic)

### Namespace & Globals
- The addon uses a global namespace `MM` to share functions and data across files.
- **SavedVariables:**
    - `MorphomaticDB`: Main configuration database.
    - `MorphomaticCustom`: Custom user data.

### Core Logic (`addons/`)
- `main.lua`: Initialization and event handling (`OnInitialize`, `OnEnable`).
- `db.lua`: Database management and defaults.
- `randomizer.lua`: Logic for selecting a random toy.
- `macro.lua`: Management of the secure `/mm` macro.
- `floating_button.lua`: UI logic for the floating button.
- `options.lua`: Settings panel configuration (using Sushi-3.2/AceConfig style).

## Development Workflow

### Requirements
- Lua 5.1 compatible environment.
- **Luacheck:** For static analysis / linting.
- **Stylua:** For code formatting.

### Commands
- **Linting:** Run `luacheck .` to check for syntax errors and undefined globals.
    - Configuration is in `.luacheckrc` (defines valid globals like `MM`, `MorphomaticDB`, and WoW API functions).
- **Formatting:** Configured via `stylua.toml`.

### Build & Release
- **Local Dev:** No build step required. The source code acts as the artifact.
- **Packaging:** GitHub Actions (`.github/workflows/release.yml`) handles packaging for CurseForge/Wago, replacing tokens like `@project-version@` in `Morphomatic.toc`.
- **Packaging Config:** `.pkgmeta` controls which files are included in the release zip (excluding `.git`, `screenshots`, etc.).

## Key Files
- `Morphomatic.toc`: Addon metadata and saved variables definition.
- `addons/main.xml`: Defines the file execution order.
- `addons/main.lua`: Core addon lifecycle management.
- `.luacheckrc`: Linting rules and global variable definitions.
- `.pkgmeta`: Packaging configuration for release.
