-- Shared utilities (namespaced on MM)
MM = MM or {}

-- Saved variables
MorphomaticDB = MorphomaticDB or {}
MorphomaticCustom = MorphomaticCustom or { extraToys = {}, skipToys = {} }

-- Defaults applied to MorphomaticDB
local DEFAULTS = {
  enabledToys = {}, -- [itemID] = false means "explicitly excluded" (default: included)
  skipOnCooldown = true, -- skip toys on cooldown
  autoCreateMacro = true, -- auto-create the macro at login
  showButton = true, -- show the floating button
  debug = false, -- debug MM.dprints
  button = { point = "CENTER", x = 0, y = 0, scale = 1, locked = true },
}

-- utils
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

-- Accessor for SavedVariables with defaults applied
function MM.DB()
  applyDefaults(MorphomaticDB, DEFAULTS)
  return MorphomaticDB
end

-- RNG seeding (safe even if math.randomseed is messed with)
function MM.SeedRNG()
  local seed = (GetServerTime and GetServerTime()) or (time and time()) or 0
  local guid = UnitGUID and UnitGUID("player")
  if guid then seed = seed + (tonumber(string.sub(guid, -6), 16) or 0) end
  if math and type(math.randomseed) == "function" then
    math.randomseed(seed)
    if type(math.random) == "function" then
      math.random()
      math.random()
      math.random()
    end
  end
end

-- Cooldown API (ToyBox preferred; fallback to item API)
function MM.GetCooldown(itemID)
  if C_ToyBox and C_ToyBox.GetToyCooldown then
    local s, d, e = C_ToyBox.GetToyCooldown(itemID)
    return s or 0, d or 0, e
  end
  if GetItemCooldown then
    local s, d, e = GetItemCooldown(itemID)
    return s or 0, d or 0, e
  end
  return 0, 0, 1
end
function MM.IsOnCooldown(itemID)
  local s, d = MM.GetCooldown(itemID)
  if s == 0 or d == 0 then return false end
  return (s + d) > GetTime()
end

-- Usability cross-build
function MM.IsUsable(itemID)
  if C_ToyBox and C_ToyBox.IsToyUsable then return not not C_ToyBox.IsToyUsable(itemID) end
  if IsUsableItem then return not not IsUsableItem(itemID) end
  return true
end

-- Ownership
function MM.PlayerHasToy(itemID) return PlayerHasToy and PlayerHasToy(itemID) or false end

-- Build pool: DB + extras - skips
function MM.BuildPool()
  local pool = {}
  if MM_DB then
    for id in pairs(MM_DB) do
      pool[id] = true
    end
  end
  if MorphomaticCustom and MorphomaticCustom.extraToys then
    for id in pairs(MorphomaticCustom.extraToys) do
      pool[id] = true
    end
  end
  if MorphomaticCustom and MorphomaticCustom.skipToys then
    for id in pairs(MorphomaticCustom.skipToys) do
      pool[id] = nil
    end
  end
  return pool
end

-- Returns a reliable localized toy name suitable for "/use <name>"
function MM.ResolveToyName(itemID)
  -- Best: resolve from ToyBox link
  if C_ToyBox and C_ToyBox.GetToyLink then
    local link = C_ToyBox.GetToyLink(itemID)
    if type(link) == "string" then
      local name = GetItemInfo(link)
      if type(name) == "string" and name ~= "" then return name end
    end
  end
  -- Fallback: direct item info (warm cache if needed)
  local name = GetItemInfo(itemID)
  if type(name) ~= "string" and C_Item and C_Item.RequestLoadItemDataByID then
    C_Item.RequestLoadItemDataByID(itemID)
    name = GetItemInfo(itemID)
  end
  if type(name) == "string" and name ~= "" then return name end
  -- Last resort: pick any string from GetToyInfo variants
  if C_ToyBox and C_ToyBox.GetToyInfo then
    local a, b, _, _, e = C_ToyBox.GetToyInfo(itemID)
    if type(a) == "string" and a ~= "" then return a end
    if type(b) == "string" and b ~= "" then return b end
    if type(e) == "string" and e ~= "" then return e end
  end
  return nil
end

-- Prepare a given SecureActionButton with a random eligible toy.
-- It sets attributes on `btn` so the protected click uses the toy.
function MM.PrepareButtonForRandomToy(btn)
  if InCombatLockdown() then return false end

  local db = MM.DB()
  local eligible = {}
  for _, id in ipairs(MM.BuildEligibleIDs()) do
    if db.enabledToys[id] ~= false then table.insert(eligible, id) end
  end
  if #eligible == 0 then
    MM.dprint("Morphomatic: no eligible toys. Use /mm to configure.")
    -- clear stale attrs
    btn:SetAttribute("type", nil)
    btn:SetAttribute("item", nil)
    btn:SetAttribute("macrotext", nil)
    return false
  end

  local pick = eligible[math.random(#eligible)]
  local toyName = MM.ResolveToyName and MM.ResolveToyName(pick) or nil
  local itemName = GetItemInfo(pick)

  -- Option A: use as item by NAME (best for ToyBox)
  btn:SetAttribute("type", "item")
  if type(toyName) == "string" and toyName ~= "" then
    btn:SetAttribute("item", toyName)
  elseif type(itemName) == "string" and itemName ~= "" then
    btn:SetAttribute("item", itemName)
  else
    -- last resort: raw itemID
    btn:SetAttribute("item", "item:" .. pick)
  end

  MM.dprint(("Morphomatic: prepared %s (%d)"):format(toyName or itemName or ("Toy " .. pick), pick))
  return true
end

-- Secure button that PREPARES (PreClick) and then EXECUTES in the same hardware click
local secureBtn
function MM.EnsureSecureButton()
  if secureBtn and secureBtn:IsObjectType("Button") then return secureBtn end

  secureBtn = CreateFrame("Button", "MM_SecureUse", UIParent, "SecureActionButtonTemplate")
  -- Accept both down/up; macro may simulate key-down depending on CVar
  secureBtn:RegisterForClicks("AnyDown", "AnyUp")
  -- Avoid self/focus cast paths interfering with items
  secureBtn:SetAttribute("checkselfcast", false)
  secureBtn:SetAttribute("checkfocuscast", false)

  secureBtn:SetScript("PreClick", function(self)
    if InCombatLockdown() then return end
    -- Debug: confirm we actually run
    -- Debug to confirm firing
    MM.dprint("MM PreClick: running (MM_SecureUse)")
    MM.PrepareButtonForRandomToy(self)
  end)

  secureBtn:Hide()
  return secureBtn
end

-- Debug helpers
function MM.IsDebug() return MM.DB().debug == true end

function MM.SetDebug(on)
  MM.DB().debug = (on and true) or false
  return MM.DB().debug
end

function MM.dprint(...)
  if MM.DB().debug then print(...) end
end
