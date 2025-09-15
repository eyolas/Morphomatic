-- SPDX-License-Identifier: MIT
-- Copyright (c) 2025 David Touzet
--
-- Morphomatic — addons/options.lua
-- Blizzard Settings canvases with 3 pages:
--   1) Main  (Floating Button + Minimap)
--   2) Macro
--   3) Favorites (cooldown filter, bulk select, checklist)

local ADDON, ns = ...
local MM     = ns.MM
local L      = LibStub('AceLocale-3.0'):GetLocale('Morphomatic')
local Sushi  = LibStub('Sushi-3.2')          -- embedded, assumed available
local Blz    = _G.Settings                   -- Blizzard Settings (DF+)

-- Use a module name that does NOT clash with _G.Settings
local Options = MM:NewModule('Options')

----------------------------------------------------------------------
--                          PRIVATE
-- Helpers, renderers, canvas builders, and session memory.
----------------------------------------------------------------------

-- Build the stable list of owned toys from the curated pool (ignores cooldown).
local function buildOwnedList()
  local pool = MM.Helpers:BuildPool()
  local out = {}
  for id in pairs(pool) do
    if MM.Helpers:PlayerHasToy(id) then out[#out+1] = id end
  end
  table.sort(out)
  return out
end

-- Build the list used for the UI (optionally hides toys currently on cooldown).
-- Build the list used for the UI (optionally hides cooldown AND applies a text filter).
local function buildListForUI(filter)
  local db = MM.DB:Get()
  local owned = buildOwnedList()

  -- Visual cooldown filter
  local base = owned
  if db.listHideCooldown == true then
    base = {}
    for _, id in ipairs(owned) do
      if not MM.Helpers:IsOnCooldown(id) then base[#base+1] = id end
    end
  end

  -- Text filter (case-insensitive; matches name or numeric id)
  if not filter or filter == '' then
    return base
  end

  local needle = string.lower(filter)
  local out = {}
  for _, id in ipairs(base) do
    local name = C_Item.GetItemInfo(id) or ('Toy ' .. id)
    local hay  = string.lower(name)
    if string.find(hay, needle, 1, true) or string.find(tostring(id), needle, 1, true) then
      out[#out+1] = id
    end
  end
  return out
end

local function bulkSelectCurrentView(selectAll)
  local db = MM.DB:Get()
  db.enabledToys = db.enabledToys or {}
  for _, id in ipairs(buildListForUI(Options._searchQuery)) do
    db.enabledToys[id] = selectAll and true or false
  end
  Options:RefreshFavorites()
end


-- Render the Favorites checklist (Sushi.Check rows) inside a scroll container.
local function renderChecklist(container)
  if not container then return end

  -- Clear previous rows
  for _, c in ipairs({ container:GetChildren() }) do
    c:Hide(); c:SetParent(nil)
  end

  local db   = MM.DB:Get()
  local list = buildListForUI(Options._searchQuery)  -- ← use current search
  table.sort(list, function(a, b)
    return (C_Item.GetItemInfo(a) or '') < (C_Item.GetItemInfo(b) or '')
  end)

  local width = math.max(120, container:GetWidth() - 14)
  local y = -4

  for _, id in ipairs(list) do
    local name, _, _, _, _, _, _, _, _, icon = C_Item.GetItemInfo(id)
    name = name or ('Toy ' .. id)

    local row = CreateFrame('Frame', nil, container)
    row:SetPoint('TOPLEFT', 6, y)
    row:SetSize(width, 22)

    local cb = Sushi.Check()
    cb:SetParent(row)
    cb:SetPoint('LEFT', row, 'LEFT', 0, 0)
    cb:SetLabel(('|T%d:16|t %s (%d)'):format(icon or 134414, name, id))
    cb:SetWidth(width)
    cb:SetValue(db.enabledToys[id] ~= false)
    cb:SetScript('OnClick', function(selfBtn)
      db.enabledToys[id] = (selfBtn:GetValue() and true) or false
    end)

    cb:Show()
    row:Show()
    y = y - 24
  end

  container:SetHeight(math.max(1, -y + 8))
end

-- Canvas: Main page (Floating Button + Minimap).
-- === Main page (no framed section) ===
local function buildCanvasMain()
  local f = CreateFrame('Frame'); f:Hide()

  local title = f:CreateFontString(nil, 'ARTWORK', 'GameFontNormalLarge')
  title:SetPoint('TOPLEFT', 16, -16)
  title:SetText(L.TITLE)

  local desc = f:CreateFontString(nil, 'ARTWORK', 'GameFontHighlight')
  desc:SetPoint('TOPLEFT', title, 'BOTTOMLEFT', 0, -8)
  desc:SetWidth(560)
  desc:SetText(L.DESC)

  -- Header
  local header = f:CreateFontString(nil, 'ARTWORK', 'GameFontNormalLarge')
  header:SetPoint('TOPLEFT', desc, 'BOTTOMLEFT', 0, -14)
  header:SetText(L.FLOATING_BUTTON)

  -- Show / hide floating button
  local showBtn = Sushi.Check()
  showBtn:SetParent(f)
  showBtn:SetPoint('TOPLEFT', header, 'BOTTOMLEFT', -6, -10)
  showBtn:SetLabel(L.SHOW_BUTTON)
  showBtn:SetValue(MM.DB:Get().showButton ~= false)
  showBtn:SetScript('OnClick', function(selfBtn)
    local v = selfBtn:GetValue() and true or false
    MM.DB:Get().showButton = v and true or false
    if v then MM.FloatButton:Show() else MM.FloatButton:Hide() end
  end)

  -- Lock / Unlock
  local lockBtn = Sushi.RedButton(f)
  lockBtn:SetPoint('TOPLEFT', showBtn, 'BOTTOMLEFT', 6, -8)
  lockBtn:SetWidth(150); lockBtn:SetHeight(22)
  local function refreshLockText()
    local db = MM.DB:Get(); db.button = db.button or {}
    lockBtn:SetText(db.button.locked and L.UNLOCK_BUTTON or L.LOCK_BUTTON)
  end
  lockBtn:SetScript('OnClick', function()
    local db = MM.DB:Get(); db.button = db.button or {}
    db.button.locked = not db.button.locked
    if MM.FloatButton and MM.FloatButton.RefreshLockVisual then
      MM.FloatButton:RefreshLockVisual()
    end
    refreshLockText()
  end)
  refreshLockText()

  -- Scale slider (on same row, to the right)
  local scale = Sushi.Slider(f)
  scale:SetPoint('LEFT', lockBtn, 'RIGHT', 16, 0)
  scale:SetWidth(200)
  scale:SetLabel(L.BUTTON_SCALE)
  scale:SetRange(0.7, 1.8)
  scale:SetStep(0.05)
  scale:SetValue((MM.DB:Get().button and MM.DB:Get().button.scale) or 1)
  scale:SetScript('OnValueChanged', function(_, v)
    if MM.UpdateButtonScale then MM.UpdateButtonScale(v) end
  end)

  -- Reset position (same row, to the right)
  local resetBtn = Sushi.RedButton(f)
  resetBtn:SetPoint('LEFT', scale, 'RIGHT', 16, 0)
  resetBtn:SetWidth(150); resetBtn:SetHeight(22)
  resetBtn:SetText(L.RESET_POSITION)
  resetBtn:SetScript('OnClick', function()
    if MM.ResetButtonAnchor then MM.ResetButtonAnchor() end
  end)

  -- Minimap toggle (below the row)
  local showMinimap = Sushi.Check()
  showMinimap:SetParent(f)
  showMinimap:SetPoint('TOPLEFT', lockBtn, 'BOTTOMLEFT', -6, -12)
  showMinimap:SetLabel(L.SHOW_MINIMAP)
  local isShown = not (MM.DB:Get().minimap and MM.DB:Get().minimap.hide)
  showMinimap:SetValue(isShown)
  showMinimap:SetScript('OnClick', function(selfBtn)
    if MM.ToggleMinimap then MM.ToggleMinimap(selfBtn:GetValue() and true or false) end
  end)

  return f
end

-- === Macro page (no framed section) ===
local function buildCanvasMacro()
  local f = CreateFrame('Frame'); f:Hide()

  local title = f:CreateFontString(nil, 'ARTWORK', 'GameFontNormalLarge')
  title:SetPoint('TOPLEFT', 16, -16)
  title:SetText(L.MACRO_SECTION)

  local auto = Sushi.Check()
  auto:SetParent(f)
  auto:SetPoint('TOPLEFT', title, 'BOTTOMLEFT', -6, -12)
  auto:SetLabel(L.AUTO_MACRO)
  auto:SetValue(MM.DB:Get().autoCreateMacro ~= false)
  auto:SetScript('OnClick', function(selfBtn)
    MM.DB:Get().autoCreateMacro = selfBtn:GetValue() and true or false
  end)

  local make = Sushi.RedButton(f)
  make:SetPoint('TOPLEFT', auto, 'BOTTOMLEFT', 6, -8)
  make:SetWidth(180); make:SetHeight(22)
  make:SetText(L.MAKE_MACRO)
  make:SetScript('OnClick', function()
    if MM.Macro and MM.Macro.RecreateMacro then MM.Macro:RecreateMacro() end
  end)

  local macroNote = f:CreateFontString(nil, 'ARTWORK', 'GameFontHighlightSmall')
  macroNote:SetPoint('LEFT', make, 'RIGHT', 12, 0)
  macroNote:SetText(L.MACRO_NOTE)

  return f
end

-- === Favorites page (no framed section) ===
local function buildCanvasFavorites()
  local f = CreateFrame('Frame'); f:Hide()

  local title = f:CreateFontString(nil, 'ARTWORK', 'GameFontNormalLarge')
  title:SetPoint('TOPLEFT', 16, -16)
  title:SetText(L.TOYS_SECTION)

  -- Runtime toggle
  local skipcd = Sushi.Check()
  skipcd:SetParent(f)
  skipcd:SetPoint('TOPLEFT', title, 'BOTTOMLEFT', -6, -12)
  skipcd:SetLabel(L.SKIP_CD)
  skipcd:SetValue(MM.DB:Get().skipOnCooldown)
  skipcd:SetScript('OnClick', function(selfBtn)
    MM.DB:Get().skipOnCooldown = selfBtn:GetValue() and true or false
  end)

  -- Visual-only filter
  local hidecd = Sushi.Check()
  hidecd:SetParent(f)
  hidecd:SetPoint('TOPLEFT', skipcd, 'BOTTOMLEFT', 0, -6)
  hidecd:SetLabel(L.HIDE_CD)
  hidecd:SetValue(MM.DB:Get().listHideCooldown == true)
  hidecd:SetScript('OnClick', function(selfBtn)
    MM.DB:Get().listHideCooldown = selfBtn:GetValue() and true or false
    Options:RefreshFavorites()
  end)

  -- Bulk actions row
  local row = CreateFrame('Frame', nil, f)
  row:SetSize(1, 22)
  row:SetPoint('TOPLEFT', hidecd, 'BOTTOMLEFT', 0, -10)

  local selectAll = Sushi.RedButton(row)
  selectAll:SetPoint('LEFT', row, 'LEFT', 0, 0)
  selectAll:SetWidth(160); selectAll:SetHeight(22)
  selectAll:SetText(L.SELECT_ALL)
  selectAll:SetScript('OnClick', function() Options:SelectAllToys() end)

  local unselectAll = Sushi.RedButton(row)
  unselectAll:SetPoint('LEFT', selectAll, 'RIGHT', 10, 0)
  unselectAll:SetWidth(170); unselectAll:SetHeight(22)
  unselectAll:SetText(L.UNSELECT_ALL)
  unselectAll:SetScript('OnClick', function() Options:UnselectAllToys() end)

  local resetSel = Sushi.RedButton(row)
  resetSel:SetPoint('LEFT', unselectAll, 'RIGHT', 10, 0)
  resetSel:SetWidth(140); resetSel:SetHeight(22)
  resetSel:SetText(L.RESET_SELECTION)
  resetSel:SetScript('OnClick', function() Options:ResetSelection() end)

   -- Quick search (filters visible list by name or id)
  local search = CreateFrame('EditBox', nil, f, 'SearchBoxTemplate')
  search:SetSize(240, 20)
  search:SetPoint('TOPLEFT', row, 'BOTTOMLEFT', -6, -10)
  search:SetAutoFocus(false)
  if search.Instructions then
    search.Instructions:SetText(SEARCH or 'Search')
  end

  -- keep current text if we already have one in this session
  if type(Options._searchQuery) == 'string' then
    search:SetText(Options._searchQuery)
    SearchBoxTemplate_OnTextChanged(search)
  end

  search:SetScript('OnTextChanged', function(self)
    SearchBoxTemplate_OnTextChanged(self)
    Options._searchQuery = (self:GetText() or ''):match('^%s*(.-)%s*$'):lower()
    Options:RefreshFavorites()
  end)
  search:SetScript('OnEnterPressed', function(self) self:ClearFocus() end)
  search:SetScript('OnEscapePressed', function(self)
    self:SetText('')
    SearchBoxTemplate_OnTextChanged(self)
    Options._searchQuery = ''
    Options:RefreshFavorites()
    self:ClearFocus()
  end)

  -- Checklist label
  local label = f:CreateFontString(nil, 'ARTWORK', 'GameFontNormal')
  label:SetPoint('TOPLEFT', search, 'BOTTOMLEFT', 0, -14)
  label:SetText(L.FAVORITES_LABEL)

  -- Scrollable checklist directly on the page canvas
  local scroll = CreateFrame('ScrollFrame', 'MM_OptionsScroll', f, 'UIPanelScrollFrameTemplate')
  scroll:SetPoint('TOPLEFT',     label, 'BOTTOMLEFT', 0, -6)
  scroll:SetPoint('BOTTOMRIGHT', f,     'BOTTOMRIGHT', -30, 24)  -- leave room for scrollbar

  local container = CreateFrame('Frame', nil, scroll)
  container:SetPoint('TOPLEFT')
  container:SetSize(1, 1)
  scroll:SetScrollChild(container)

  f._listContainer = container
  f:SetScript('OnShow',        function() Options:RefreshFavorites() end)
  f:SetScript('OnSizeChanged', function() Options:RefreshFavorites() end)

  return f
end


-- Session-only memory of the last opened page (no SavedVariables).
local function RememberCategory(which)        -- 'main' | 'macro' | 'favorites'
  Options._lastOptionsCat = which
end

local function GetLastCategory()
  return Options._lastOptionsCat or 'main'
end

local function GetCatId(which)
  local cat = (which == 'favorites' and Options._catFav)
           or (which == 'macro'     and Options._catMacro)
           or Options._catMain
  return cat and (cat.ID or cat)
end

----------------------------------------------------------------------
--                         PUBLIC API
-- Actions, refreshers, registration, open/toggle.
----------------------------------------------------------------------

-- Select/unselect helpers operate on the current UI view (cooldown filter applied).
function Options:SelectAllToys()
  local db = MM.DB:Get()
  db.enabledToys = db.enabledToys or {}
  for _, id in ipairs(buildListForUI(self._searchQuery)) do
    db.enabledToys[id] = true
  end
  MM.Helpers:dprint('Morphomatic: all favorites in the current view selected.')
  self:RefreshFavorites()
end

function Options:UnselectAllToys()
  local db = MM.DB:Get()
  db.enabledToys = db.enabledToys or {}
  for _, id in ipairs(buildListForUI(self._searchQuery)) do
    db.enabledToys[id] = false
  end
  MM.Helpers:dprint('Morphomatic: all favorites in the current view unselected.')
  self:RefreshFavorites()
end

function Options:ResetSelection()
  local db = MM.DB:Get()
  db.enabledToys = db.enabledToys or {}
  wipe(db.enabledToys)
  MM.Helpers:dprint('Morphomatic: favorites reset (all toys included by default).')
  self:RefreshFavorites()
end

-- Rebuilds the Favorites checklist if the page is visible.
function Options:RefreshFavorites()
  local f = self._canvasFav
  local container = f and f._listContainer
  if not (f and container and f:IsVisible()) then return end
  container:SetWidth((f:GetWidth() or 600) - 46)
  renderChecklist(container)
end

-- Register pages in Blizzard Settings (root + subcategories).
function Options:RegisterCategory()
  if not (Blz and Blz.RegisterCanvasLayoutCategory) then return end

  -- Root page
  local canvasMain = buildCanvasMain()
  local catMain = Blz.RegisterCanvasLayoutCategory(canvasMain, 'Morphomatic')
  catMain.ID = 'MorphomaticCategory'

  -- Sub-pages
  local canvasMacro = buildCanvasMacro()
  local catMacro = Blz.RegisterCanvasLayoutSubcategory(catMain, canvasMacro, L.MACRO_SECTION)
  catMacro.ID = 'MorphomaticMacro'

  local canvasFav = buildCanvasFavorites()
  local catFav = Blz.RegisterCanvasLayoutSubcategory(catMain, canvasFav, L.TOYS_SECTION)
  catFav.ID = 'MorphomaticFavorites'

  Blz.RegisterAddOnCategory(catMain)

  -- Keep BOTH: category objects (for opening) and canvas frames (for rendering).
  self._catMain   = catMain
  self._catMacro  = catMacro
  self._catFav    = catFav
  self._canvasFav = canvasFav

  -- Remember current page (session-only)
  canvasMain:SetScript('OnShow', function() RememberCategory('main') end)
  canvasMacro:SetScript('OnShow', function() RememberCategory('macro') end)
  canvasFav:SetScript('OnShow',  function()
    RememberCategory('favorites')
    self:RefreshFavorites()
  end)
end

-- Open Settings to a specific page (defaults to last used page in session).
function Options:Open(which)  -- public
  local id = GetCatId(which or GetLastCategory())
  if Blz and Blz.OpenToCategory and id then
    Blz.OpenToCategory(id)
  end
end

-- Toggle Settings: close if open, otherwise open to last used (or requested) page.
function Options:Toggle(which)  -- public
  if _G.SettingsPanel and SettingsPanel:IsShown() then
    SettingsPanel:Close(true)
  else
    self:Open(which)
  end
end

----------------------------------------------------------------------
--                             OnLoad
----------------------------------------------------------------------
function Options:OnLoad()
  self:RegisterCategory()
  -- Allow other modules (e.g., Minimap) to toggle the panel.
  self:RegisterSignal('MM_TOGGLE_OPTIONS', 'Toggle')
end
