-- Morphomatic — db.lua
-- Centralized SavedVariables, defaults, and accessors.

MM = MM or {}

-- SavedVariables declared in the .toc:
--   MorphomaticDB, MorphomaticCustom
-- Initialize if nil (first run)
MorphomaticDB = MorphomaticDB or {}
MorphomaticCustom = MorphomaticCustom or { extraToys = {}, skipToys = {} }

-- Bump when schema changes (for future migrations)
local SCHEMA_VERSION = 1

-- Defaults applied to MorphomaticDB
local DEFAULTS = {
  __schema = SCHEMA_VERSION,
  enabledToys = {}, -- [itemID] = false => explicitly excluded (implicit = included)
  skipOnCooldown = true, -- runtime: skip toys on cooldown
  autoCreateMacro = true, -- auto-(re)create macro at login
  showButton = true, -- floating button visibility
  debug = false, -- gated debug prints
  button = { point = "CENTER", x = 0, y = 0, scale = 1, locked = true },
}

-- --- internal helpers ---
local function deepcopy(t)
  local r = {}
  for k, v in pairs(t) do
    r[k] = (type(v) == "table") and deepcopy(v) or v
  end
  return r
end

local function applyDefaults(dst, src)
  for k, v in pairs(src) do
    if dst[k] == nil then
      dst[k] = (type(v) == "table") and deepcopy(v) or v
    elseif type(dst[k]) == "table" and type(v) == "table" then
      applyDefaults(dst[k], v)
    end
  end
end

local _defaultsApplied

-- Public: get DB with defaults applied (lazy)
function MM.DB()
  if not _defaultsApplied then
    applyDefaults(MorphomaticDB, DEFAULTS)
    _defaultsApplied = true
  end
  return MorphomaticDB
end

-- Public: get custom user lists (extra/skip toys)
function MM.Custom()
  -- ensure shape in case older versions didn’t create it
  MorphomaticCustom.extraToys = MorphomaticCustom.extraToys or {}
  MorphomaticCustom.skipToys = MorphomaticCustom.skipToys or {}
  return MorphomaticCustom
end

-- Optional: hard reset to defaults (keeps or wipes favorites depending on arg)
function MM.ResetToDefaults(keepFavorites)
  local old = MorphomaticDB
  MorphomaticDB = {}
  applyDefaults(MorphomaticDB, DEFAULTS)
  if keepFavorites and old and old.enabledToys then
    MorphomaticDB.enabledToys = old.enabledToys -- keep user’s selection
  end
  _defaultsApplied = true
end

-- Optional: schema migration hook (no-op for now)
local function migrateIfNeeded()
  local db = MM.DB()
  local current = tonumber(db.__schema) or 0
  if current < SCHEMA_VERSION then db.__schema = SCHEMA_VERSION end
end

-- Light-touch init at PLAYER_LOGIN (safe even if called multiple times)
local f = CreateFrame("Frame")
f:RegisterEvent("PLAYER_LOGIN")
f:SetScript("OnEvent", function()
  -- ensure shapes and defaults, then run migrations
  MM.DB()
  MM.Custom()
  migrateIfNeeded()
end)

-- Debug gate helpers (kept here so any file can call them)
function MM.IsDebug() return MM.DB().debug == true end
function MM.SetDebug(on)
  MM.DB().debug = (on and true) or false
  return MM.DB().debug
end
function MM.dprint(...)
  if MM.DB().debug then print(...) end
end
