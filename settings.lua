-- Morphomatic — settings.lua
-- Settings panel with 3 sections:
--   1) Floating Button
--   2) Macro
--   3) Toys Management (skip CD + checklist)

MM = MM or {}

----------------------------------------------------------------------
-- Toys checklist renderer
----------------------------------------------------------------------
local function refreshChecklist(container)
  if not container then return end

  -- Clear previous row widgets
  local kids = { container:GetChildren() }
  for _, c in ipairs(kids) do c:Hide(); c:SetParent(nil) end

  local db   = MM.DB()
  local list = MM.BuildEligibleIDs()
  table.sort(list, function(a, b)
    return (GetItemInfo(a) or "") < (GetItemInfo(b) or "")
  end)

  local width = container:GetWidth() - 14
  local y = -4

  for _, id in ipairs(list) do
    local name, _, _, _, _, _, _, _, _, icon = GetItemInfo(id)

    local cb = CreateFrame("CheckButton", nil, container, "InterfaceOptionsCheckButtonTemplate")
    cb:SetPoint("TOPLEFT", 6, y)
    cb:SetSize(20, 20)

    cb.Text:ClearAllPoints()
    cb.Text:SetPoint("LEFT", cb, "RIGHT", 6, 0)
    cb.Text:SetWidth(math.max(120, width - 40))
    cb.Text:SetJustifyH("LEFT")
    cb.Text:SetText(("|T%d:16|t %s (%d)"):format(icon or 134414, name or ("Toy "..id), id))

    cb:SetHitRectInsets(0, -(width - 24), 0, 0)

    cb:SetChecked(db.enabledToys[id] ~= false)
    cb:SetScript("OnClick", function(self)
      db.enabledToys[id] = self:GetChecked() and nil or false
    end)

    cb:Show()
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

  local title = f:CreateFontString(nil, "ARTWORK", "GameFontNormalLarge")
  title:SetPoint("TOPLEFT", 16, -16)
  title:SetText("Morphomatic")

  local desc = f:CreateFontString(nil, "ARTWORK", "GameFontHighlight")
  desc:SetPoint("TOPLEFT", title, "BOTTOMLEFT", 0, -8)
  desc:SetWidth(560)
  desc:SetText("Use the 'MM' macro or the floating button to trigger a random cosmetic toy from your curated list.")

  --------------------------------------------------------------------
  -- Section 1: Floating Button
  --------------------------------------------------------------------
  local s1 = f:CreateFontString(nil, "ARTWORK", "GameFontNormalLarge")
  s1:SetPoint("TOPLEFT", desc, "BOTTOMLEFT", 0, -14)
  s1:SetText("Floating Button")

  local showBtn = CreateFrame("CheckButton", nil, f, "InterfaceOptionsCheckButtonTemplate")
  showBtn:SetPoint("TOPLEFT", s1, "BOTTOMLEFT", 0, -8)
  showBtn.Text:SetText("Show floating button")
  showBtn:SetChecked(MM.DB().showButton ~= false)
  showBtn:SetScript("OnClick", function(self)
    local v = self:GetChecked()
    MM.DB().showButton = v and true or false
    if v then MM.ShowButton() else MM.HideButton() end
  end)

  local lockBtn = CreateFrame("Button", nil, f, "UIPanelButtonTemplate")
  lockBtn:SetSize(150, 22)
  lockBtn:SetPoint("TOPLEFT", showBtn, "BOTTOMLEFT", 0, -8)
  local function refreshLockText()
    lockBtn:SetText(MM.DB().button.locked and "Unlock button" or "Lock button")
  end
  lockBtn:SetScript("OnClick", function()
    MM.DB().button.locked = not MM.DB().button.locked
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
  _G["MM_ScaleSliderText"]:SetText("Button scale")
  scale:SetScript("OnValueChanged", function(_, v) MM.UpdateButtonScale(v) end)

  local resetBtn = CreateFrame("Button", nil, f, "UIPanelButtonTemplate")
  resetBtn:SetSize(150, 22)
  resetBtn:SetPoint("LEFT", scale, "RIGHT", 16, 0)
  resetBtn:SetText("Reset position")
  resetBtn:SetScript("OnClick", MM.ResetButtonAnchor)

  --------------------------------------------------------------------
  -- Section 2: Macro
  --------------------------------------------------------------------
  local s2 = f:CreateFontString(nil, "ARTWORK", "GameFontNormalLarge")
  s2:SetPoint("TOPLEFT", lockBtn, "BOTTOMLEFT", 0, -18)
  s2:SetText("Macro")

  local auto = CreateFrame("CheckButton", nil, f, "InterfaceOptionsCheckButtonTemplate")
  auto:SetPoint("TOPLEFT", s2, "BOTTOMLEFT", 0, -8)
  auto.Text:SetText("Auto-(re)create 'MM' macro at login")
  auto:SetChecked(MM.DB().autoCreateMacro ~= false)
  auto:SetScript("OnClick", function(self)
    MM.DB().autoCreateMacro = self:GetChecked() and true or false
  end)

  local make = CreateFrame("Button", nil, f, "UIPanelButtonTemplate")
  make:SetSize(180, 22)
  make:SetPoint("TOPLEFT", auto, "BOTTOMLEFT", 0, -8)
  make:SetText("Create/Refresh macro now")
  make:SetScript("OnClick", MM.RecreateMacro)

  local macroNote = f:CreateFontString(nil, "ARTWORK", "GameFontHighlightSmall")
  macroNote:SetPoint("LEFT", make, "RIGHT", 12, 0)
  macroNote:SetText("Icon is set to Orb of Deception (1973).")

  --------------------------------------------------------------------
  -- Section 3: Toys Management
  --------------------------------------------------------------------
  local s3 = f:CreateFontString(nil, "ARTWORK", "GameFontNormalLarge")
  s3:SetPoint("TOPLEFT", make, "BOTTOMLEFT", 0, -18)
  s3:SetText("Toys Management")

  local skipcd = CreateFrame("CheckButton", nil, f, "InterfaceOptionsCheckButtonTemplate")
  skipcd:SetPoint("TOPLEFT", s3, "BOTTOMLEFT", 0, -8)
  skipcd.Text:SetText("Skip toys on cooldown")
  skipcd:SetChecked(MM.DB().skipOnCooldown)
  skipcd:SetScript("OnClick", function(self)
    MM.DB().skipOnCooldown = self:GetChecked() and true or false
    MM.OptionsRefresh()
  end)

  -- Reset selection: clears explicit exclusions so all toys are included by default again
  local resetSel = CreateFrame("Button", nil, f, "UIPanelButtonTemplate")
  resetSel:SetSize(160, 22)
  resetSel:SetPoint("LEFT", skipcd, "RIGHT", 16, 0)
  resetSel:SetText("Reset selection")
  resetSel:SetScript("OnClick", function()
    if MorphomaticDB and MorphomaticDB.enabledToys then
      wipe(MorphomaticDB.enabledToys)
      print("Morphomatic: selection reset (all toys back to included-by-default).")
      MM.OptionsRefresh()
    end
  end)

  local label = f:CreateFontString(nil, "ARTWORK", "GameFontNormal")
  label:SetPoint("TOPLEFT", skipcd, "BOTTOMLEFT", 0, -14)
  label:SetText("Owned cosmetic toys (from your DB):")

  local scroll = CreateFrame("ScrollFrame", "MM_OptionsScroll", f, "UIPanelScrollFrameTemplate")
  scroll:SetPoint("TOPLEFT", label, "BOTTOMLEFT", 0, -6)
  scroll:SetPoint("BOTTOMRIGHT", f, "BOTTOMRIGHT", -30, 16)

  local container = CreateFrame("Frame", nil, scroll)
  container:SetPoint("TOPLEFT")
  container:SetSize(1, 1)
  scroll:SetScrollChild(container)
  f._listContainer = container

  -- Reflow on resize to keep checklist width correct
  f:SetScript("OnSizeChanged", function()
    MM.OptionsRefresh()
  end)

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
  MM._optionsCanvas   = canvas
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
