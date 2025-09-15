-- SPDX-License-Identifier: MIT
-- Copyright (c) 2025 David Touzet

-- Morphomatic — addons/options.lua
-- Settings canvas with 3 sections:
--   1) Floating Button
--   2) Macro
--   3) Favorites (skip CD at runtime, list filter, bulk actions, checklist)

local ADDON, ns = ...
local MM     = ns.MM
local L      = LibStub('AceLocale-3.0'):GetLocale('Morphomatic')
local Sushi  = LibStub('Sushi-3.2') -- embedded, assumed available
local Blz    = _G.Settings          -- alias vers l’API Blizzard Settings

-- ⚠️ Module renommé (évite le conflit avec _G.Settings)
local Options = MM:NewModule('Options')

----------------------------------------------------------------------
-- UI list sources
----------------------------------------------------------------------
local function buildOwnedList()
  local pool = MM.Helpers:BuildPool()
  local out = {}
  for id in pairs(pool) do
    if MM.Helpers:PlayerHasToy(id) then table.insert(out, id) end
  end
  table.sort(out)
  return out
end

local function buildListForUI()
  local db = MM.DB:Get()
  local owned = buildOwnedList()
  if db.listHideCooldown ~= true then return owned end
  local out = {}
  for _, id in ipairs(owned) do
    if not MM.Helpers:IsOnCooldown(id) then table.insert(out, id) end
  end
  return out
end

----------------------------------------------------------------------
-- Bulk selection helpers
----------------------------------------------------------------------
local function bulkSelectCurrentView(selectAll)
  local db = MM.DB:Get()
  db.enabledToys = db.enabledToys or {}

  local list = buildListForUI()
  for _, id in ipairs(list) do
    db.enabledToys[id] = selectAll and true or false
  end
  Options:OptionsRefresh()
end

function Options:SelectAllToys()
  bulkSelectCurrentView(true)
  MM.Helpers:dprint("Morphomatic: all favorites in the current view selected.")
end

function Options:UnselectAllToys()
  bulkSelectCurrentView(false)
  MM.Helpers:dprint("Morphomatic: all favorites in the current view unselected.")
end

function Options:ResetSelection()
  local db = MM.DB:Get()
  db.enabledToys = db.enabledToys or {}
  wipe(db.enabledToys)
  Options:OptionsRefresh()
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
-- Build Settings canvas (3 sections) — IDENTIQUE à avant, juste renommé
----------------------------------------------------------------------
----------------------------------------------------------------------
-- Build canvases (1 par page)
----------------------------------------------------------------------

local function buildCanvasMain()
  local f = CreateFrame("Frame"); f:Hide()

  local title = f:CreateFontString(nil, "ARTWORK", "GameFontNormalLarge")
  title:SetPoint("TOPLEFT", 16, -16)
  title:SetText(L.TITLE)

  local desc = f:CreateFontString(nil, "ARTWORK", "GameFontHighlight")
  desc:SetPoint("TOPLEFT", title, "BOTTOMLEFT", 0, -8)
  desc:SetWidth(560)
  desc:SetText(L.DESC)

  -- === Section Floating Button (copié depuis ton ancien s1) ===
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
    MM.DB:Get().showButton = v and true or false
    if v then MM.FloatButton:Show() else MM.FloatButton:Hide() end
  end)

  local lockBtn = Sushi.RedButton(s1)
  lockBtn:SetPoint("TOPLEFT", showBtn, "BOTTOMLEFT", 6, -8)
  lockBtn:SetWidth(150); lockBtn:SetHeight(22)
  local function refreshLockText()
    local db = MM.DB:Get(); db.button = db.button or {}
    lockBtn:SetText(db.button.locked and L.UNLOCK_BUTTON or L.LOCK_BUTTON)
  end
  lockBtn:SetScript("OnClick", function()
    local db = MM.DB:Get(); db.button = db.button or {}
    db.button.locked = not db.button.locked
    if MM.FloatButton and MM.FloatButton.RefreshLockVisual then
      MM.FloatButton:RefreshLockVisual()
    end
    refreshLockText()
  end)
  refreshLockText()

  local scale = Sushi.Slider(s1)
  scale:SetPoint("LEFT", lockBtn, "RIGHT", 16, 0)
  scale:SetWidth(200)
  scale:SetLabel(L.BUTTON_SCALE)
  scale:SetRange(0.7, 1.8)
  scale:SetStep(0.05)
  scale:SetValue((MM.DB:Get().button and MM.DB:Get().button.scale) or 1)
  scale:SetScript("OnValueChanged", function(_, v)
    if MM.UpdateButtonScale then MM.UpdateButtonScale(v) end
  end)

  local resetBtn = Sushi.RedButton(s1)
  resetBtn:SetPoint("LEFT", scale, "RIGHT", 16, 0)
  resetBtn:SetWidth(150); resetBtn:SetHeight(22)
  resetBtn:SetText(L.RESET_POSITION)
  resetBtn:SetScript("OnClick", function()
    if MM.ResetButtonAnchor then MM.ResetButtonAnchor() end
  end)

  -- Minimap
  local showMinimap = Sushi.Check()
  showMinimap:SetParent(f)
  showMinimap:SetPoint("TOPLEFT", s1, "BOTTOMLEFT", -6, -10)
  showMinimap:SetLabel(L.SHOW_MINIMAP)
  local isShown = not (MM.DB:Get().minimap and MM.DB:Get().minimap.hide)
  showMinimap:SetValue(isShown)
  showMinimap:SetScript("OnClick", function(self)
    if MM.ToggleMinimap then MM.ToggleMinimap(self:GetValue() and true or false) end
  end)

  return f
end

local function buildCanvasMacro()
  local f = CreateFrame("Frame"); f:Hide()

  local title = f:CreateFontString(nil, "ARTWORK", "GameFontNormalLarge")
  title:SetPoint("TOPLEFT", 16, -16)
  title:SetText(L.MACRO_SECTION)

  local s2 = CreateFrame("Frame", nil, f, "BackdropTemplate")
  s2:SetPoint("TOPLEFT", title, "BOTTOMLEFT", -10, -12)
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

  local auto = Sushi.Check()
  auto:SetParent(s2)
  auto:SetPoint("TOPLEFT", 4, -14)
  auto:SetLabel(L.AUTO_MACRO)
  auto:SetValue(MM.DB:Get().autoCreateMacro ~= false)
  auto:SetScript("OnClick", function(self)
    MM.DB:Get().autoCreateMacro = self:GetValue() and true or false
  end)

  local make = Sushi.RedButton(s2)
  make:SetPoint("TOPLEFT", auto, "BOTTOMLEFT", 6, -8)
  make:SetWidth(180); make:SetHeight(22)
  make:SetText(L.MAKE_MACRO)
  make:SetScript("OnClick", function()
    if MM.Macro and MM.Macro.RecreateMacro then MM.Macro:RecreateMacro() end
  end)

  local macroNote = s2:CreateFontString(nil, "ARTWORK", "GameFontHighlightSmall")
  macroNote:SetPoint("LEFT", make, "RIGHT", 12, 0)
  macroNote:SetText(L.MACRO_NOTE)

  return f
end

local function buildCanvasFavorites()
  local f = CreateFrame("Frame"); f:Hide()

  local title = f:CreateFontString(nil, "ARTWORK", "GameFontNormalLarge")
  title:SetPoint("TOPLEFT", 16, -16)
  title:SetText(L.TOYS_SECTION)

  local s3 = CreateFrame("Frame", nil, f, "BackdropTemplate")
  s3:SetPoint("TOPLEFT", title, "BOTTOMLEFT", -10, -12)
  s3:SetPoint("BOTTOMRIGHT", f, "BOTTOMRIGHT", -16, 16)
  s3:SetBackdrop({
    bgFile = "Interface/Buttons/WHITE8x8",
    edgeFile = "Interface/Tooltips/UI-Tooltip-Border",
    edgeSize = 12,
    insets = { left = 2, right = 2, top = 2, bottom = 2 },
  })
  s3:SetBackdropColor(0, 0, 0, 0.08)
  s3:SetBackdropBorderColor(0.25, 0.6, 1, 0.6)

  local skipcd = Sushi.Check()
  skipcd:SetParent(s3)
  skipcd:SetPoint("TOPLEFT", 4, -14)
  skipcd:SetLabel(L.SKIP_CD)
  skipcd:SetValue(MM.DB:Get().skipOnCooldown)
  skipcd:SetScript("OnClick", function(self)
    MM.DB:Get().skipOnCooldown = self:GetValue() and true or false
  end)

  local hidecd = Sushi.Check()
  hidecd:SetParent(s3)
  hidecd:SetPoint("TOPLEFT", skipcd, "BOTTOMLEFT", 0, -6)
  hidecd:SetLabel(L.HIDE_CD)
  hidecd:SetValue(MM.DB:Get().listHideCooldown == true)
  hidecd:SetScript("OnClick", function(self)
    MM.DB:Get().listHideCooldown = self:GetValue() and true or false
    Options:OptionsRefresh()
  end)

  local row = CreateFrame("Frame", nil, s3)
  row:SetSize(1, 22)
  row:SetPoint("TOPLEFT", hidecd, "BOTTOMLEFT", 0, -10)

  local selectAll = Sushi.RedButton(row)
  selectAll:SetPoint("LEFT", row, "LEFT", 0, 0)
  selectAll:SetWidth(160); selectAll:SetHeight(22)
  selectAll:SetText(L.SELECT_ALL)
  selectAll:SetScript("OnClick", function() Options:SelectAllToys() end)

  local unselectAll = Sushi.RedButton(row)
  unselectAll:SetPoint("LEFT", selectAll, "RIGHT", 10, 0)
  unselectAll:SetWidth(170); unselectAll:SetHeight(22)
  unselectAll:SetText(L.UNSELECT_ALL)
  unselectAll:SetScript("OnClick", function() Options:UnselectAllToys() end)

  local resetSel = Sushi.RedButton(row)
  resetSel:SetPoint("LEFT", unselectAll, "RIGHT", 10, 0)
  resetSel:SetWidth(140); resetSel:SetHeight(22)
  resetSel:SetText(L.RESET_SELECTION)
  resetSel:SetScript("OnClick", function() Options:ResetSelection() end)

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
  f._section = "favorites"

  -- Reflow on resize
  f:SetScript("OnSizeChanged", function() Options:OptionsRefresh() end)

  return f
end

----------------------------------------------------------------------
-- Register with Settings API (root + sous-pages)
----------------------------------------------------------------------

function Options:RegisterCategory()
  local S = _G.Settings
  if not S or not S.RegisterCanvasLayoutCategory then return end

  -- Catégorie racine = page "Floating Button"
  local canvasMain = buildCanvasMain()
  local catMain = S.RegisterCanvasLayoutCategory(canvasMain, "Morphomatic")
  catMain.ID = "MorphomaticCategory"

  local canvasMacro = buildCanvasMacro()
  local subMacro = S.RegisterCanvasLayoutSubcategory(catMain, canvasMacro, L.MACRO_SECTION)
  subMacro.ID = "MorphomaticMacro"

  local canvasFav = buildCanvasFavorites()
  local subFav = S.RegisterCanvasLayoutSubcategory(catMain, canvasFav, L.TOYS_SECTION)
  subFav.ID = "MorphomaticFavorites"

  S.RegisterAddOnCategory(catMain)

  -- stock pour refresh (favorites)
  self._category = catMain
  self._canvasFav = subFav
  self._canvasMacro = subMacro

  canvasMain:SetScript('OnShow', function() Options:_RememberCategory('main') end)
  canvasMacro:SetScript('OnShow', function() Options:_RememberCategory('macro') end)
  canvasFav:SetScript('OnShow', function()
    Options:_RememberCategory('favorites')
  end)
end


----------------------------------------------------------------------
-- External refresh (Favorites page)
----------------------------------------------------------------------

function Options:OptionsRefresh()
  local f = self._canvasFav
  local container = f and f._listContainer
  if container and f and f:IsVisible() then
    container:SetWidth(((f:GetWidth()) or 600) - 46)
    -- réutilise ta renderer existante
    local kids = { container:GetChildren() }
    for _, c in ipairs(kids) do c:Hide(); c:SetParent(nil) end
    -- appelle la même logique qu’avant
    local function refreshChecklist(container2)
      local db = MM.DB:Get()
      local list = (function()
        local owned = {}
        local pool = MM.Helpers:BuildPool()
        for id in pairs(pool) do if MM.Helpers:PlayerHasToy(id) then table.insert(owned, id) end end
        table.sort(owned)
        if db.listHideCooldown ~= true then return owned end
        local out = {}
        for _, id in ipairs(owned) do if not MM.Helpers:IsOnCooldown(id) then table.insert(out, id) end end
        return out
      end)()
      table.sort(list, function(a,b) return (C_Item.GetItemInfo(a) or "") < (C_Item.GetItemInfo(b) or "") end)
      local width = math.max(120, container2:GetWidth() - 14)
      local y = -4
      for _, id in ipairs(list) do
        local name, _, _, _, _, _, _, _, _, icon = C_Item.GetItemInfo(id)
        name = name or ("Toy " .. id)
        local row = CreateFrame("Frame", nil, container2)
        row:SetPoint("TOPLEFT", 6, y)
        row:SetSize(width, 22)
        local cb = Sushi.Check()
        cb:SetParent(row)
        cb:SetPoint("LEFT", row, "LEFT", 0, 0)
        cb:SetLabel(("|T%d:16|t %s (%d)"):format(icon or 134414, name, id))
        cb:SetWidth(width)
        cb:SetValue(MM.DB:Get().enabledToys[id] ~= false)
        cb:SetScript("OnClick", function(self)
          MM.DB:Get().enabledToys[id] = (self:GetValue() and true) or false
        end)
        cb:Show(); row:Show()
        y = y - 24
      end
      container2:SetHeight(math.max(1, -y + 8))
    end
    refreshChecklist(container)
  end
end


function Options:_RememberCategory(which)           -- 'main' | 'macro' | 'favorites'
  self._lastOptionsCat = which
end

function Options:_GetLastCategory()
  return self._lastOptionsCat or 'main'
end

function Options:_GetCatId(which)
  local cat = (which == 'favorites' and self._canvasFav)
           or (which == 'macro'     and self._canvasMacro)
           or self._category
  return cat and (cat.ID or cat)
end

function Options:Open(which)
  local target = which or self:_GetLastCategory()
  local id = self:_GetCatId(target)
  Blz.OpenToCategory(id)
end

function Options:Toggle(which)
  if _G.SettingsPanel and SettingsPanel:IsShown() then
    SettingsPanel:Close(true); return
  end
  self:Open(which)
end

function Options:OnLoad()
  self:RegisterCategory()
  self:OptionsRefresh()
  self:RegisterSignal('MM_TOGGLE_OPTIONS', 'Toggle')
end