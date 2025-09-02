-- Morphomatic — settings.lua
-- Settings panel with 3 sections:
--   1) Floating Button
--   2) Macro
--   3) Toys Management (skip CD at runtime, list filter toggle, checklist + bulk actions)

MM = MM or {}

----------------------------------------------------------------------
-- UI list sources
----------------------------------------------------------------------

-- Stable list of OWNED toys from the curated pool (ignores cooldown)
local function buildOwnedList()
  local pool = MM.BuildPool()
  local out = {}
  for id in pairs(pool) do
    if MM.PlayerHasToy(id) then table.insert(out, id) end
  end
  table.sort(out)
  return out
end

-- List used by the UI depending on the toggle "Hide toys on cooldown in list"
local function buildListForUI()
  local db = MM.DB()
  local owned = buildOwnedList()
  if db.listHideCooldown ~= true then return owned end
  -- Filter out toys currently on cooldown (visual-only; does not affect runtime)
  local out = {}
  for _, id in ipairs(owned) do
    if not MM.IsOnCooldown(id) then table.insert(out, id) end
  end
  return out
end

----------------------------------------------------------------------
-- Bulk selection helpers
-- - Select/Unselect apply to the CURRENT LIST VIEW (matches what the user sees)
-- - Reset selection wipes all explicit exclusions globally
----------------------------------------------------------------------

local function bulkSelectCurrentView(selectAll)
  local db = MM.DB()
  db.enabledToys = db.enabledToys or {}

  local list = buildListForUI()
  for _, id in ipairs(list) do
    if selectAll then
      db.enabledToys[id] = true -- included-by-default
    else
      db.enabledToys[id] = false -- explicitly excluded
    end
  end
  MM.OptionsRefresh()
end

function MM.SelectAllToys()
  bulkSelectCurrentView(true)
  MM.dprint("Morphomatic: all favorites in the current view selected.")
end

function MM.UnselectAllToys()
  bulkSelectCurrentView(false)
  MM.dprint("Morphomatic: all favorites in the current view unselected.")
end

function MM.ResetSelection()
  local db = MM.DB()
  db.enabledToys = db.enabledToys or {}
  wipe(db.enabledToys) -- clear ALL explicit exclusions
  MM.OptionsRefresh()
  MM.dprint("Morphomatic: favorites reset (all toys included by default).")
end

----------------------------------------------------------------------
-- Checklist renderer (checked = included)
----------------------------------------------------------------------

local function refreshChecklist(container)
  if not container then return end

  -- Clear previous row widgets
  local kids = { container:GetChildren() }
  for _, c in ipairs(kids) do
    c:Hide()
    c:SetParent(nil)
  end

  local db = MM.DB()
  local list = buildListForUI()
  table.sort(list, function(a, b) return (GetItemInfo(a) or "") < (GetItemInfo(b) or "") end)

  local width = container:GetWidth() - 14
  local y = -4

  for _, id in ipairs(list) do
    local name, _, _, _, _, _, _, _, _, icon = GetItemInfo(id)

    -- Compact checkbox
    local cb = CreateFrame("CheckButton", nil, container, "InterfaceOptionsCheckButtonTemplate")
    cb:SetPoint("TOPLEFT", 6, y)
    cb:SetSize(20, 20)

    -- Label on the right
    cb.Text:ClearAllPoints()
    cb.Text:SetPoint("LEFT", cb, "RIGHT", 6, 0)
    cb.Text:SetWidth(math.max(120, width - 40))
    cb.Text:SetJustifyH("LEFT")
    cb.Text:SetText(("|T%d:16|t %s (%d)"):format(icon or 134414, name or ("Toy " .. id), id))

    -- Make the whole row clickable without stretching the checkbox
    cb:SetHitRectInsets(0, -(width - 24), 0, 0)

    cb:SetChecked(db.enabledToys[id] ~= false)
    cb:SetScript(
      "OnClick",
      function(self) db.enabledToys[id] = self:GetChecked() and true or false end
    )

    cb:Show()
    y = y - 24
  end

  container:SetHeight(math.max(1, -y + 8))
end

----------------------------------------------------------------------
-- Build Settings canvas (3 sections)
----------------------------------------------------------------------

local function buildCanvas()
  local L = MM.L

  local f = CreateFrame("Frame")
  f:Hide()

  -- Title + description
  local title = f:CreateFontString(nil, "ARTWORK", "GameFontNormalLarge")
  title:SetPoint("TOPLEFT", 16, -16)
  title:SetText(L["TITLE"])

  local desc = f:CreateFontString(nil, "ARTWORK", "GameFontHighlight")
  desc:SetPoint("TOPLEFT", title, "BOTTOMLEFT", 0, -8)
  desc:SetWidth(560)
  desc:SetText(L["DESC"])

  --------------------------------------------------------------------
  -- Section 1: Floating Button
  --------------------------------------------------------------------
  local s1 = f:CreateFontString(nil, "ARTWORK", "GameFontNormalLarge")
  s1:SetPoint("TOPLEFT", desc, "BOTTOMLEFT", 0, -14)
  s1:SetText(L["FLOATING_BUTTON"])

  local showBtn = CreateFrame("CheckButton", nil, f, "InterfaceOptionsCheckButtonTemplate")
  showBtn:SetPoint("TOPLEFT", s1, "BOTTOMLEFT", 0, -8)
  showBtn.Text:SetText(L["SHOW_BUTTON"])
  showBtn:SetChecked(MM.DB().showButton ~= false)
  showBtn:SetScript("OnClick", function(self)
    local v = self:GetChecked()
    MM.DB().showButton = v and true or false
    if v then
      MM.ShowButton()
    else
      MM.HideButton()
    end
  end)

  local lockBtn = CreateFrame("Button", nil, f, "UIPanelButtonTemplate")
  lockBtn:SetSize(150, 22)
  lockBtn:SetPoint("TOPLEFT", showBtn, "BOTTOMLEFT", 0, -8)
  local function refreshLockText()
    lockBtn:SetText(MM.DB().button.locked and L["UNLOCK_BUTTON"] or L["LOCK_BUTTON"])
  end
  lockBtn:SetScript("OnClick", function()
    MM.DB().button.locked = not MM.DB().button.locked
    if MM.RefreshButtonLockVisual then MM.RefreshButtonLockVisual() end
    refreshLockText()
  end)
  refreshLockText()

  local scale = CreateFrame("Slider", "MM_ScaleSlider", f, "OptionsSliderTemplate")
  scale:SetPoint("LEFT", lockBtn, "RIGHT", 16, 0)
  scale:SetMinMaxValues(0.7, 1.8)
  scale:SetValueStep(0.05)
  scale:SetObeyStepOnDrag(true)
  scale:SetWidth(200)
  scale:SetValue(MM.DB().button.scale or 1)
  _G["MM_ScaleSliderLow"]:SetText("0.7")
  _G["MM_ScaleSliderHigh"]:SetText("1.8")
  _G["MM_ScaleSliderText"]:SetText(L["BUTTON_SCALE"])
  scale:SetScript("OnValueChanged", function(_, v) MM.UpdateButtonScale(v) end)

  local resetBtn = CreateFrame("Button", nil, f, "UIPanelButtonTemplate")
  resetBtn:SetSize(150, 22)
  resetBtn:SetPoint("LEFT", scale, "RIGHT", 16, 0)
  resetBtn:SetText(L["RESET_POSITION"])
  resetBtn:SetScript("OnClick", MM.ResetButtonAnchor)

  --------------------------------------------------------------------
  -- Section 2: Macro
  --------------------------------------------------------------------
  local s2 = f:CreateFontString(nil, "ARTWORK", "GameFontNormalLarge")
  s2:SetPoint("TOPLEFT", lockBtn, "BOTTOMLEFT", 0, -18)
  s2:SetText(L["MACRO_SECTION"])

  local auto = CreateFrame("CheckButton", nil, f, "InterfaceOptionsCheckButtonTemplate")
  auto:SetPoint("TOPLEFT", s2, "BOTTOMLEFT", 0, -8)
  auto.Text:SetText(L["AUTO_MACRO"])
  auto:SetChecked(MM.DB().autoCreateMacro ~= false)
  auto:SetScript(
    "OnClick",
    function(self) MM.DB().autoCreateMacro = self:GetChecked() and true or false end
  )

  local make = CreateFrame("Button", nil, f, "UIPanelButtonTemplate")
  make:SetSize(180, 22)
  make:SetPoint("TOPLEFT", auto, "BOTTOMLEFT", 0, -8)
  make:SetText(L["MAKE_MACRO"])
  make:SetScript("OnClick", MM.RecreateMacro) -- defined in macro.lua

  local macroNote = f:CreateFontString(nil, "ARTWORK", "GameFontHighlightSmall")
  macroNote:SetPoint("LEFT", make, "RIGHT", 12, 0)
  macroNote:SetText(L["MACRO_NOTE"])

  --------------------------------------------------------------------
  -- Section 3: Toys / Favorites Management
  --------------------------------------------------------------------
  local s3 = f:CreateFontString(nil, "ARTWORK", "GameFontNormalLarge")
  s3:SetPoint("TOPLEFT", make, "BOTTOMLEFT", 0, -24)
  s3:SetText(L["TOYS_SECTION"])

  -- Row 1: runtime option (applies when picking a toy)
  local skipcd = CreateFrame("CheckButton", nil, f, "InterfaceOptionsCheckButtonTemplate")
  skipcd:SetPoint("TOPLEFT", s3, "BOTTOMLEFT", 0, -10)
  skipcd.Text:SetText(L["SKIP_CD"])
  skipcd:SetChecked(MM.DB().skipOnCooldown)
  skipcd:SetScript("OnClick", function(self)
    MM.DB().skipOnCooldown = self:GetChecked() and true or false
    -- runtime only; no need to refresh list
  end)

  -- Row 2: list filter toggle (visual-only)
  local hidecd = CreateFrame("CheckButton", nil, f, "InterfaceOptionsCheckButtonTemplate")
  hidecd:SetPoint("TOPLEFT", skipcd, "BOTTOMLEFT", 0, -6)
  hidecd.Text:SetText(L["HIDE_CD"])
  hidecd:SetChecked(MM.DB().listHideCooldown == true)
  hidecd:SetScript("OnClick", function(self)
    MM.DB().listHideCooldown = self:GetChecked() and true or false
    MM.OptionsRefresh()
  end)

  -- Row 3: bulk action buttons
  local row = CreateFrame("Frame", nil, f)
  row:SetSize(1, 22)
  row:SetPoint("TOPLEFT", hidecd, "BOTTOMLEFT", 0, -10)

  local selectAll = CreateFrame("Button", nil, row, "UIPanelButtonTemplate")
  selectAll:SetSize(160, 22)
  selectAll:SetPoint("TOPLEFT", 0, 0)
  selectAll:SetText(L["SELECT_ALL"])
  selectAll:SetScript("OnClick", MM.SelectAllToys)

  local unselectAll = CreateFrame("Button", nil, row, "UIPanelButtonTemplate")
  unselectAll:SetSize(170, 22)
  unselectAll:SetPoint("LEFT", selectAll, "RIGHT", 10, 0)
  unselectAll:SetText(L["UNSELECT_ALL"])
  unselectAll:SetScript("OnClick", MM.UnselectAllToys)

  local resetSel = CreateFrame("Button", nil, row, "UIPanelButtonTemplate")
  resetSel:SetSize(140, 22)
  resetSel:SetPoint("LEFT", unselectAll, "RIGHT", 10, 0)
  resetSel:SetText(L["RESET_SELECTION"])
  resetSel:SetScript("OnClick", MM.ResetSelection)

  -- Row 4: Label + scroll checklist
  local label = f:CreateFontString(nil, "ARTWORK", "GameFontNormal")
  label:SetPoint("TOPLEFT", row, "BOTTOMLEFT", 0, -14)
  label:SetText(L["FAVORITES_LABEL"])

  local scroll = CreateFrame("ScrollFrame", "MM_OptionsScroll", f, "UIPanelScrollFrameTemplate")
  scroll:SetPoint("TOPLEFT", label, "BOTTOMLEFT", 0, -6)
  scroll:SetPoint("BOTTOMRIGHT", f, "BOTTOMRIGHT", -30, 16)

  local container = CreateFrame("Frame", nil, scroll)
  container:SetPoint("TOPLEFT")
  container:SetSize(1, 1)
  scroll:SetScrollChild(container)
  f._listContainer = container

  -- Reflow on resize to keep checklist width correct
  f:SetScript("OnSizeChanged", function() MM.OptionsRefresh() end)

  return f
end

----------------------------------------------------------------------
-- Register with Settings API (Dragonflight+) or legacy fallback
----------------------------------------------------------------------

local function registerSettings()
  local canvas = buildCanvas()
  local cat = Settings.RegisterCanvasLayoutCategory(canvas, "Morphomatic")
  cat.ID = "MorphomaticCategory"
  Settings.RegisterAddOnCategory(cat)
  MM._optionsCategory = cat
  MM._optionsCanvas = canvas
end

local function registerLegacy()
  local p = buildCanvas()
  p.name = "Morphomatic"
  InterfaceOptions_AddCategory(p)
  MM._legacyPanel = p
end

function MM.OptionsRegister()
  if Settings and Settings.RegisterAddOnCategory then
    registerSettings()
  else
    registerLegacy()
  end
end

----------------------------------------------------------------------
-- External refresh (called from events)
----------------------------------------------------------------------

function MM.OptionsRefresh()
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
