-- Morphomatic — addons/Settings:lua
-- Settings panel with 3 sections:
--   1) Floating Button
--   2) Macro
--   3) Favorites (skip CD at runtime, list filter, bulk actions, checklist)

local ADDON, ns = ...
local MM = ns.MM
local Settings = MM:NewModule("Settings")
local L = LibStub("AceLocale-3.0"):GetLocale("Morphomatic")
local Sushi = LibStub("Sushi-3.2") -- embedded, assumed available

----------------------------------------------------------------------
-- UI list sources
----------------------------------------------------------------------
-- Stable list of OWNED toys from the curated pool (ignores cooldown)
local function buildOwnedList()
  local pool = MM.Helpers:BuildPool()
  local out = {}
  for id in pairs(pool) do
    if MM.Helpers:PlayerHasToy(id) then table.insert(out, id) end
  end
  table.sort(out)
  return out
end

-- List used by the UI depending on the toggle "Hide toys on cooldown in list"
local function buildListForUI()
  local db = MM.DB:Get()
  local owned = buildOwnedList()
  if db.listHideCooldown ~= true then return owned end
  -- Filter out toys currently on cooldown (visual-only; does not affect runtime)
  local out = {}
  for _, id in ipairs(owned) do
    if not MM.Helpers:IsOnCooldown(id) then table.insert(out, id) end
  end
  return out
end

----------------------------------------------------------------------
-- Bulk selection helpers
-- - Select/Unselect apply to the CURRENT LIST VIEW (matches what the user sees)
-- - Reset selection wipes all explicit inclusions/exclusions globally
----------------------------------------------------------------------

local function bulkSelectCurrentView(selectAll)
  local db = MM.DB:Get()
  db.enabledToys = db.enabledToys or {}

  local list = buildListForUI()
  for _, id in ipairs(list) do
    if selectAll then
      db.enabledToys[id] = true -- explicitly included
    else
      db.enabledToys[id] = false -- explicitly excluded
    end
  end
  Settings:OptionsRefresh()
end

function Settings:SelectAllToys()
  bulkSelectCurrentView(true)
  MM.Helpers:dprint("Morphomatic: all favorites in the current view selected.")
end

function Settings:UnselectAllToys()
  bulkSelectCurrentView(false)
  MM.Helpers:dprint("Morphomatic: all favorites in the current view unselected.")
end

function Settings:ResetSelection()
  local db = MM.DB:Get()
  db.enabledToys = db.enabledToys or {}
  wipe(db.enabledToys) -- back to implicit "included" for all
  Settings:OptionsRefresh()
  MM.Helpers:dprint("Morphomatic: favorites reset (all toys included by default).")
end

----------------------------------------------------------------------
-- Checklist renderer (checked = included) using Sushi.Check rows
----------------------------------------------------------------------

local function refreshChecklist(container)
  if not container then return end

  -- Clear previous row widgets
  local kids = { container:GetChildren() }
  for _, c in ipairs(kids) do
    c:Hide()
    c:SetParent(nil)
  end

  local db = MM.DB:Get()
  local list = buildListForUI()
  table.sort(list, function(a, b) return (C_Item.GetItemInfo(a) or "") < (C_Item.GetItemInfo(b) or "") end)

  local width = math.max(120, container:GetWidth() - 14)
  local y = -4

  for _, id in ipairs(list) do
    local name, _, _, _, _, _, _, _, _, icon = C_Item.GetItemInfo(id)
    name = name or ("Toy " .. id)

    local row = CreateFrame("Frame", nil, container)
    row:SetPoint("TOPLEFT", 6, y)
    row:SetSize(width, 22)

    local cb = Sushi.Check()
    cb:SetParent(row)
    cb:SetPoint("LEFT", row, "LEFT", 0, 0)
    cb:SetLabel(("|T%d:16|t %s (%d)"):format(icon or 134414, name, id))
    cb:SetWidth(width)
    cb:SetValue(db.enabledToys[id] ~= false)

    cb:SetScript("OnClick", function(self)
      local checked = self:GetValue() and true or false
      db.enabledToys[id] = checked and true or false
    end)

    cb:Show()
    row:Show()

    y = y - 24
  end

  container:SetHeight(math.max(1, -y + 8))
end

----------------------------------------------------------------------
-- Build Settings canvas (3 sections)
----------------------------------------------------------------------

local function buildCanvas()
  local f = CreateFrame("Frame")
  f:Hide()

  -- Title + description
  local title = f:CreateFontString(nil, "ARTWORK", "GameFontNormalLarge")
  title:SetPoint("TOPLEFT", 16, -16)
  title:SetText(L.TITLE)

  local desc = f:CreateFontString(nil, "ARTWORK", "GameFontHighlight")
  desc:SetPoint("TOPLEFT", title, "BOTTOMLEFT", 0, -8)
  desc:SetWidth(560)
  desc:SetText(L.DESC)

  --------------------------------------------------------------------
  -- Section 1: Floating Button
  --------------------------------------------------------------------
  local s1 = CreateFrame("Frame", nil, f, "BackdropTemplate")
  s1:SetPoint("TOPLEFT", desc, "BOTTOMLEFT", 0, -12)
  s1:SetPoint("RIGHT", f, "RIGHT", -16, 0)
  s1:SetHeight(110)
  s1:SetBackdrop({
    bgFile = "Interface/Buttons/WHITE8x8",
    edgeFile = "Interface/Tooltips/UI-Tooltip-Border",
    edgeSize = 12,
    insets = { left = 2, right = 2, top = 2, bottom = 2 },
  })
  s1:SetBackdropColor(0, 0, 0, 0.10)
  s1:SetBackdropBorderColor(0.25, 0.6, 1, 0.6)

  local s1t = s1:CreateFontString(nil, "ARTWORK", "GameFontNormalLarge")
  s1t:SetPoint("TOPLEFT", 10, -10)
  s1t:SetText(L.FLOATING_BUTTON)

  local showBtn = Sushi.Check()
  showBtn:SetParent(s1)
  showBtn:SetPoint("TOPLEFT", s1t, "BOTTOMLEFT", -6, -10)
  showBtn:SetLabel(L.SHOW_BUTTON)
  showBtn:SetValue(MM.DB:Get().showButton ~= false)
  showBtn:SetScript("OnClick", function(self)
    local v = self:GetValue() and true or false
    print("showBtn clicked, new value:", MM.DB:Get().showButton, "->", v)
    print(dump(MM.DB:Get()))
    MM.DB:Get().showButton = v and true or false
    if v then
      MM.FloatButton:Show()
    else
      MM.FloatButton:Hide()
    end
  end)

  local lockBtn = Sushi.RedButton(s1)
  lockBtn:SetPoint("TOPLEFT", showBtn, "BOTTOMLEFT", 6, -8)
  lockBtn:SetWidth(150)
  lockBtn:SetHeight(22)
  local function refreshLockText()
    lockBtn:SetText(MM.DB:Get().button.locked and L.UNLOCK_BUTTON or L.LOCK_BUTTON)
  end
  lockBtn:SetScript("OnClick", function()
    MM.DB:Get().button.locked = not MM.DB:Get().button.locked
    MM.FloatButton:RefreshLockVisual()
    refreshLockText()
  end)
  refreshLockText()

  local scale = Sushi.Slider(s1)
  scale:SetPoint("LEFT", lockBtn, "RIGHT", 16, 0)
  scale:SetWidth(200)
  scale:SetLabel(L.BUTTON_SCALE)
  scale:SetRange(0.7, 1.8)
  scale:SetStep(0.05)
  scale:SetValue(MM.DB:Get().button.scale or 1)
  scale:SetScript("OnValueChanged", function(_, v)
    if MM.UpdateButtonScale then MM.UpdateButtonScale(v) end
  end)

  local resetBtn = Sushi.RedButton(s1)
  resetBtn:SetPoint("LEFT", scale, "RIGHT", 16, 0)
  resetBtn:SetWidth(150)
  resetBtn:SetHeight(22)
  resetBtn:SetText(L.RESET_POSITION)
  resetBtn:SetScript("OnClick", function()
    if MM.ResetButtonAnchor then MM.ResetButtonAnchor() end
  end)

  -- Minimap toggle (embedded libs => always available)
  local showMinimap = Sushi.Check()
  showMinimap:SetParent(f)
  showMinimap:SetPoint("TOPLEFT", s1, "BOTTOMLEFT", -6, -10)
  showMinimap:SetLabel(L.SHOW_MINIMAP)
  local isShown = not (MM.DB:Get().minimap and MM.DB:Get().minimap.hide)
  showMinimap:SetValue(isShown)
  showMinimap:SetScript("OnClick", function(self)
    if MM.ToggleMinimap then MM.ToggleMinimap(self:GetValue() and true or false) end
  end)

  --------------------------------------------------------------------
  -- Section 2: Macro
  --------------------------------------------------------------------
  local s2 = CreateFrame("Frame", nil, f, "BackdropTemplate")
  s2:SetPoint("TOPLEFT", showMinimap, "BOTTOMLEFT", 6, -12)
  s2:SetPoint("RIGHT", f, "RIGHT", -16, 0)
  s2:SetHeight(100)
  s2:SetBackdrop({
    bgFile = "Interface/Buttons/WHITE8x8",
    edgeFile = "Interface/Tooltips/UI-Tooltip-Border",
    edgeSize = 12,
    insets = { left = 2, right = 2, top = 2, bottom = 2 },
  })
  s2:SetBackdropColor(0, 0, 0, 0.10)
  s2:SetBackdropBorderColor(0.25, 0.6, 1, 0.6)

  local s2t = s2:CreateFontString(nil, "ARTWORK", "GameFontNormalLarge")
  s2t:SetPoint("TOPLEFT", 10, -10)
  s2t:SetText(L.MACRO_SECTION)

  local auto = Sushi.Check()
  auto:SetParent(s2)
  auto:SetPoint("TOPLEFT", s2t, "BOTTOMLEFT", -6, -10)
  auto:SetLabel(L.AUTO_MACRO)
  auto:SetValue(MM.DB:Get().autoCreateMacro ~= false)
  auto:SetScript(
    "OnClick",
    function(self) MM.DB:Get().autoCreateMacro = self:GetValue() and true or false end
  )

  local make = Sushi.RedButton(s2)
  make:SetPoint("TOPLEFT", auto, "BOTTOMLEFT", 6, -8)
  make:SetWidth(180)
  make:SetHeight(22)
  make:SetText(L.MAKE_MACRO)
  make:SetScript("OnClick", function() MM.Macro:RecreateMacro() end)

  local macroNote = s2:CreateFontString(nil, "ARTWORK", "GameFontHighlightSmall")
  macroNote:SetPoint("LEFT", make, "RIGHT", 12, 0)
  macroNote:SetText(L.MACRO_NOTE)

  --------------------------------------------------------------------
  -- Section 3: Favorites / Toys Management
  --------------------------------------------------------------------
  local s3 = CreateFrame("Frame", nil, f, "BackdropTemplate")
  s3:SetPoint("TOPLEFT", s2, "BOTTOMLEFT", 0, -12)
  s3:SetPoint("BOTTOMRIGHT", f, "BOTTOMRIGHT", -16, 16)
  s3:SetBackdrop({
    bgFile = "Interface/Buttons/WHITE8x8",
    edgeFile = "Interface/Tooltips/UI-Tooltip-Border",
    edgeSize = 12,
    insets = { left = 2, right = 2, top = 2, bottom = 2 },
  })
  s3:SetBackdropColor(0, 0, 0, 0.08)
  s3:SetBackdropBorderColor(0.25, 0.6, 1, 0.6)

  local s3t = s3:CreateFontString(nil, "ARTWORK", "GameFontNormalLarge")
  s3t:SetPoint("TOPLEFT", 10, -10)
  s3t:SetText(L.TOYS_SECTION)

  -- Row 1: runtime option (applies when picking a toy)
  local skipcd = Sushi.Check()
  skipcd:SetParent(s3)
  skipcd:SetPoint("TOPLEFT", s3t, "BOTTOMLEFT", -6, -10)
  skipcd:SetLabel(L.SKIP_CD)
  skipcd:SetValue(MM.DB:Get().skipOnCooldown)
  skipcd:SetScript(
    "OnClick",
    function(self) MM.DB:Get().skipOnCooldown = self:GetValue() and true or false end
  )

  -- Row 2: list filter toggle (visual-only)
  local hidecd = Sushi.Check()
  hidecd:SetParent(s3)
  hidecd:SetPoint("TOPLEFT", skipcd, "BOTTOMLEFT", 0, -6)
  hidecd:SetLabel(L.HIDE_CD)
  hidecd:SetValue(MM.DB:Get().listHideCooldown == true)
  hidecd:SetScript("OnClick", function(self)
    MM.DB:Get().listHideCooldown = self:GetValue() and true or false
    Settings:OptionsRefresh()
  end)

  -- Row 3: bulk action buttons
  local row = CreateFrame("Frame", nil, s3)
  row:SetSize(1, 22)
  row:SetPoint("TOPLEFT", hidecd, "BOTTOMLEFT", 0, -10)

  local selectAll = Sushi.RedButton(row)
  selectAll:SetPoint("LEFT", row, "LEFT", 0, 0)
  selectAll:SetWidth(160)
  selectAll:SetHeight(22)
  selectAll:SetText(L.SELECT_ALL)
  selectAll:SetScript("OnClick", function() Settings:SelectAllToys() end)

  local unselectAll = Sushi.RedButton(row)
  unselectAll:SetPoint("LEFT", selectAll, "RIGHT", 10, 0)
  unselectAll:SetWidth(170)
  unselectAll:SetHeight(22)
  unselectAll:SetText(L.UNSELECT_ALL)
  unselectAll:SetScript("OnClick", function() Settings:UnselectAllToys() end)

  local resetSel = Sushi.RedButton(row)
  resetSel:SetPoint("LEFT", unselectAll, "RIGHT", 10, 0)
  resetSel:SetWidth(140)
  resetSel:SetHeight(22)
  resetSel:SetText(L.RESET_SELECTION)
  resetSel:SetScript("OnClick", function() Settings:ResetSelection() end)

  -- Row 4: Label + scroll checklist
  local label = s3:CreateFontString(nil, "ARTWORK", "GameFontNormal")
  label:SetPoint("TOPLEFT", row, "BOTTOMLEFT", 0, -14)
  label:SetText(L.FAVORITES_LABEL)

  local scroll = CreateFrame("ScrollFrame", "MM_OptionsScroll", s3, "UIPanelScrollFrameTemplate")
  scroll:SetPoint("TOPLEFT", label, "BOTTOMLEFT", 0, -6)
  scroll:SetPoint("BOTTOMRIGHT", s3, "BOTTOMRIGHT", -30, 24)

  local container = CreateFrame("Frame", nil, scroll)
  container:SetPoint("TOPLEFT")
  container:SetSize(1, 1)
  scroll:SetScrollChild(container)
  f._listContainer = container

  -- Reflow on resize to keep checklist width correct
  f:SetScript("OnSizeChanged", function() Settings:OptionsRefresh() end)

  return f
end

----------------------------------------------------------------------
-- Register with Settings API (Dragonflight+) or legacy fallback
----------------------------------------------------------------------

local function registerSettings()
  local S = _G.Settings
  local canvas = buildCanvas()
  local cat = S.RegisterCanvasLayoutCategory(canvas, "Morphomatic")
  cat.ID = "MorphomaticCategory"
  S.RegisterAddOnCategory(cat)
  MM._optionsCategory = cat
  MM._optionsCanvas = canvas
end

local function registerLegacy()
  local p = buildCanvas()
  p.name = "Morphomatic"
  InterfaceOptions_AddCategory(p)
  MM._legacyPanel = p
end

function Settings:OptionsRegister()
  local S = _G.Settings
  if S and S.RegisterAddOnCategory then
    registerSettings()
  else
    registerLegacy()
  end
end

----------------------------------------------------------------------
-- External refresh (called from events)
----------------------------------------------------------------------

function Settings:OptionsRefresh()
  local container
  if MM._optionsCanvas and MM._optionsCanvas._listContainer then
    container = MM._optionsCanvas._listContainer
  elseif MM._legacyPanel and MM._legacyPanel._listContainer then
    container = MM._legacyPanel._listContainer
  end
  if container then
    local parent = MM._optionsCanvas or MM._legacyPanel
    container:SetWidth(((parent and parent:GetWidth()) or 600) - 46)
    refreshChecklist(container)
  end
end
