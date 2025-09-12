-- SPDX-License-Identifier: MIT
-- Copyright (c) 2025 David Touzet

-- Morphomatic — addons/db.lua
-- DB module (WildAddon): SavedVariables, defaults, accessors + compat shims

local ADDON, ns = ...
local MM = ns.MM
local DB = MM:NewModule("DB") -- <- WildAddon module

-- SavedVariables declared in the .toc:
--   MorphomaticDB, MorphomaticCustom
MorphomaticDB = MorphomaticDB or {}
MorphomaticCustom = MorphomaticCustom or { extraToys = {}, skipToys = {} }

-- Schema bump when structure changes
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

-- ===== Module API =====

function DB:Get()
  if not _defaultsApplied then
    applyDefaults(MorphomaticDB, DEFAULTS)
    _defaultsApplied = true
  end
  return MorphomaticDB
end

function DB:GetCustom()
  -- Ensure shape (for compatibility with older versions)
  local c = MorphomaticCustom
  c.extraToys = c.extraToys or {}
  c.skipToys = c.skipToys or {}
  return c
end

function DB:ResetToDefaults(keepFavorites)
  local old = MorphomaticDB
  MorphomaticDB = {}
  applyDefaults(MorphomaticDB, DEFAULTS)
  if keepFavorites and old and old.enabledToys then
    MorphomaticDB.enabledToys = old.enabledToys -- preserve user selection
  end
  _defaultsApplied = true
end

function DB:migrateIfNeeded()
  local db = self:Get()
  local current = tonumber(db.__schema) or 0
  if current < SCHEMA_VERSION then
    -- put migrations here if needed
    db.__schema = SCHEMA_VERSION
  end
end

-- Lifecycle: WildAddon will call OnLoad for modules
function DB:OnLoad()
  local f = CreateFrame("Frame")
  f:RegisterEvent("PLAYER_LOGIN")
  f:SetScript("OnEvent", function()
    self:Get() -- ensure defaults
    self:GetCustom() -- ensure shape
    self:migrateIfNeeded()
  end)
end
