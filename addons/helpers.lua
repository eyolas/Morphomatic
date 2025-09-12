-- Morphomatic — addons/Helpers:lua
-- Shared utilities (no SavedVariables or defaults here).

local ADDON, ns = ...
local MM = ns.MM
local Helpers = MM:NewModule("Helpers")
MM:RegisterModule("Helpers", Helpers)
-- RNG seeding (safe even if math.randomseed is messed with)
function Helpers:SeedRNG()
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
function Helpers:GetCooldown(itemID)
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

function Helpers:IsOnCooldown(itemID)
  local s, d = self:GetCooldown(itemID)
  if s == 0 or d == 0 then return false end
  return (s + d) > GetTime()
end

-- Usability (cross-build)
function Helpers:IsUsable(itemID)
  if C_ToyBox and C_ToyBox.IsToyUsable then return not not C_ToyBox.IsToyUsable(itemID) end
  if IsUsableItem then return not not IsUsableItem(itemID) end
  return true
end

-- Ownership
function Helpers:PlayerHasToy(itemID)
  if type(itemID) ~= "number" then return false end
  return PlayerHasToy and PlayerHasToy(itemID) or false
end

function Helpers:BuildPool()
  local function add(pool, k, v, src)
    local id = (type(k) == "number") and k or v -- handle set vs array
    id = (type(id) == "number") and id or tonumber(id)
    if id then
      pool[id] = true
    else
      print("BuildPool: bad id from", src, "->", tostring(k), tostring(v))
    end
  end

  local pool = {}

  if MM_DB then
    for k, v in pairs(MM_DB) do
      add(pool, k, v, "MM_DB")
    end
  end

  local custom = MM.DB and MM.DB.GetCustom and MM.DB:GetCustom() or nil
  if custom and custom.extraToys then
    for k, v in pairs(custom.extraToys) do
      add(pool, k, v, "extraToys")
    end
  end
  if custom and custom.skipToys then
    for k, v in pairs(custom.skipToys) do
      local id = (type(k) == "number") and v or k
      id = (type(id) == "number") and id or tonumber(id)
      if id then pool[id] = nil end
    end
  end

  return pool
end

-- Returns a reliable localized toy name suitable for "/use <name>"
function Helpers:ResolveToyName(itemID)
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
function Helpers:PrepareButtonForRandomToy(btn)
  if InCombatLockdown() then return false end

  local db = MM.DB:Get()
  local eligible = {}
  for _, id in ipairs(MM.Randomizer:BuildEligibleIDs()) do
    if db.enabledToys[id] ~= false then table.insert(eligible, id) end
  end
  if #eligible == 0 then
    self:dprint("Morphomatic: no eligible toys. Use /mm to configure.")
    -- clear stale attrs
    btn:SetAttribute("type", nil)
    btn:SetAttribute("item", nil)
    btn:SetAttribute("macrotext", nil)
    return false
  end

  local pick = eligible[math.random(#eligible)]
  local toyName = self:ResolveToyName(pick)
  local itemName = GetItemInfo(pick)

  -- Use the item by name (best with ToyBox); fallback to itemID
  btn:SetAttribute("type", "item")
  if type(toyName) == "string" and toyName ~= "" then
    btn:SetAttribute("item", toyName)
  elseif type(itemName) == "string" and itemName ~= "" then
    btn:SetAttribute("item", itemName)
  else
    btn:SetAttribute("item", "item:" .. pick)
  end

  self:dprint(
    ("Morphomatic: prepared %s (%d)"):format(toyName or itemName or ("Toy " .. pick), pick)
  )
  return true
end

-- Secure button that PREPARES (PreClick) and then EXECUTES in the same hardware click
local secureBtn
function Helpers:EnsureSecureButton()
  self:dprint("Morphomatic: ensuring secure button")
  if secureBtn and secureBtn:IsObjectType("Button") then return secureBtn end

  secureBtn = CreateFrame("Button", "MM_SecureUse", UIParent, "SecureActionButtonTemplate")
  secureBtn:RegisterForClicks("AnyDown", "AnyUp")
  secureBtn:SetAttribute("checkselfcast", false)
  secureBtn:SetAttribute("checkfocuscast", false)

  secureBtn:SetScript("PreClick", function(self)
    if InCombatLockdown() then return end
    Helpers:dprint("MM PreClick: running (MM_SecureUse)")
    Helpers:PrepareButtonForRandomToy(self)
  end)

  secureBtn:Hide()
  return secureBtn
end

function Helpers:IsDebug() return MM.DB:Get().debug == true end
function Helpers:SetDebug(on)
  MM.DB:Get().debug = (on and true) or false
  return MM.DB:Get().debug
end
function Helpers:dprint(...)
  if MM.DB:Get().debug then print(...) end
end
