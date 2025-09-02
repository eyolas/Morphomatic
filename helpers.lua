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
  button = { point = "CENTER", x = 0, y = 0, scale = 1, locked = false },
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

-- Creates (once) the secure button that will both PREPARE and EXECUTE the toy on click.
-- Preparation happens in PreClick (same hardware event), so no /run is needed anywhere.
local secureBtn
function MM.EnsureSecureButton()
  if secureBtn and secureBtn:IsObjectType("Button") then return secureBtn end

  secureBtn = CreateFrame("Button", "MM_SecureUse", UIParent, "SecureActionButtonTemplate")

  -- PreClick: compute the random eligible toy and set secure attributes
  secureBtn:SetScript("PreClick", function(self)
    -- Do not attempt to change attributes in combat
    if InCombatLockdown() then return end

    local db = MM.DB()

    -- Build eligible candidates (ownership + optional cooldown), then apply user filters
    local eligible = {}
    for _, id in ipairs(MM.BuildEligibleIDs()) do
      if db.enabledToys[id] ~= false then table.insert(eligible, id) end
    end
    if #eligible == 0 then
      -- Feedback via UIErrors is often hidden by UIs; print for reliability
      print("Morphomatic: no eligible toys. Use /mm to configure.")
      return
    end

    local pick = eligible[math.random(#eligible)]

    -- Resolve the most reliable name for /use by item name (ToyBox localized name first)
    local toyName = MM.ResolveToyNameFromToyBox and MM.ResolveToyNameFromToyBox(pick) or nil

    local itemName = GetItemInfo(pick)
    if type(itemName) ~= "string" and C_Item and C_Item.RequestLoadItemDataByID then
      C_Item.RequestLoadItemDataByID(pick)
      itemName = GetItemInfo(pick)
    end

    -- Configure this secure button to use the toy by name (best), or fallback to item:ID
    self:SetAttribute("type", "item")
    if type(toyName) == "string" and toyName ~= "" then
      self:SetAttribute("item", toyName)
    elseif type(itemName) == "string" and itemName ~= "" then
      self:SetAttribute("item", itemName)
    else
      self:SetAttribute("item", "item:" .. pick)
    end

    -- Optional debug
    -- print(("Morphomatic: prepared %s (%d)"):format(toyName or itemName or ("Toy "..pick), pick))
  end)

  -- Hidden by default; we only /click it from macro or the floating button proxy
  secureBtn:Hide()
  return secureBtn
end

--- Safely resolve a localized toy name from the ToyBox API.
--- Different builds of WoW return different argument orders, so we pick
--- whichever slot actually contains a string.
---@param itemID number
---@return string|nil
function MM.ResolveToyNameFromToyBox(itemID)
  if not (C_ToyBox and C_ToyBox.GetToyInfo) then return nil end

  local a, b, c, d, e = C_ToyBox.GetToyInfo(itemID)
  -- Look through known slots and return the first string
  if type(a) == "string" then return a end
  if type(b) == "string" then return b end
  if type(e) == "string" then return e end

  return nil
end
