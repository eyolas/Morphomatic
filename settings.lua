-- Settings UI (Settings API + legacy). Also creates the macro on demand.
MM = MM or {}

-- Create or ensure the macro "MM"
function MM.EnsureMacro()
  local idx  = GetMacroIndexByName("MM")
  local body = [[
#showtooltip
/run if MM and MM.PrepareSecureUse then MM.PrepareSecureUse() end
/click MM_SecureUse
]]
  if idx == 0 then
    local id = CreateMacro("MM", "INV_MISC_QUESTIONMARK", body, true) -- global macro
    if id then print("Morphomatic: macro 'MM' created.") else print("Morphomatic: failed to create macro (quota?).") end
  else
    print("Morphomatic: macro 'MM' already exists.")
  end
end

local function refreshChecklist(container)
  if not container then return end
  local kids = { container:GetChildren() }
  for _, c in ipairs(kids) do c:Hide(); c:SetParent(nil) end

  local db   = MM.DB()
  local list = MM.BuildEligibleIDs()
  table.sort(list, function(a,b) return (GetItemInfo(a) or "") < (GetItemInfo(b) or "") end)

  local y = -4
  local width = container:GetWidth() - 14
  for _, id in ipairs(list) do
    local name, _, _, _, _, _, _, _, _, icon = GetItemInfo(id)
    local cb = CreateFrame("CheckButton", nil, container, "InterfaceOptionsCheckButtonTemplate")
    cb:SetPoint("TOPLEFT", 6, y)
    cb.Text:SetText(("|T%d:16|t %s (%d)"):format(icon or 134414, name or ("Toy "..id), id))
    cb:SetChecked(db.enabledToys[id] ~= false)
    cb:SetScript("OnClick", function(self) db.enabledToys[id] = self:GetChecked() and nil or false end)
    cb:SetWidth(width)
    cb:Show()
    y = y - 24
  end
  container:SetHeight(math.max(1, -y + 8))
end

local function buildCanvas()
  local f = CreateFrame("Frame"); f:Hide()

  local title = f:CreateFontString(nil, "ARTWORK", "GameFontNormalLarge")
  title:SetPoint("TOPLEFT", 16, -16); title:SetText("Morphomatic")

  local desc = f:CreateFontString(nil, "ARTWORK", "GameFontHighlight")
  desc:SetPoint("TOPLEFT", title, "BOTTOMLEFT", 0, -8); desc:SetWidth(560)
  desc:SetText("Check toys to include. Use the 'MM' macro or the optional floating button to trigger a random one.")

  -- Skip cooldown
  local skipcd = CreateFrame("CheckButton", nil, f, "InterfaceOptionsCheckButtonTemplate")
  skipcd:SetPoint("TOPLEFT", desc, "BOTTOMLEFT", 0, -10)
  skipcd.Text:SetText("Skip toys on cooldown")
  skipcd:SetChecked(MM.DB().skipOnCooldown)
  skipcd:SetScript("OnClick", function(self) MM.DB().skipOnCooldown = self:GetChecked() and true or false; MM.OptionsRefresh() end)

  -- Show floating button
  local showBtn = CreateFrame("CheckButton", nil, f, "InterfaceOptionsCheckButtonTemplate")
  showBtn:SetPoint("TOPLEFT", skipcd, "BOTTOMLEFT", 0, -8)
  showBtn.Text:SetText("Show floating button")
  showBtn:SetChecked(MM.DB().showButton ~= false)
  showBtn:SetScript("OnClick", function(self)
    local v = self:GetChecked(); MM.DB().showButton = v and true or false
    if v then MM.ShowButton() else MM.HideButton() end
  end)

  -- Lock / Scale / Reset row
  local lockBtn = CreateFrame("Button", nil, f, "UIPanelButtonTemplate")
  lockBtn:SetSize(150,22); lockBtn:SetPoint("TOPLEFT", showBtn, "BOTTOMLEFT", 0, -8)
  local function refreshLockText() lockBtn:SetText(MM.DB().button.locked and "Unlock button" or "Lock button") end
  lockBtn:SetScript("OnClick", function() MM.DB().button.locked = not MM.DB().button.locked; refreshLockText() end)
  refreshLockText()

  local scale = CreateFrame("Slider", "MM_ScaleSlider", f, "OptionsSliderTemplate")
  scale:SetPoint("LEFT", lockBtn, "RIGHT", 16, 0)
  scale:SetMinMaxValues(0.7, 1.8); scale:SetValueStep(0.05); scale:SetObeyStepOnDrag(true); scale:SetWidth(200)
  scale:SetValue(MM.DB().button.scale or 1)
  _G["MM_ScaleSliderLow"]:SetText("0.7"); _G["MM_ScaleSliderHigh"]:SetText("1.8"); _G["MM_ScaleSliderText"]:SetText("Button scale")
  scale:SetScript("OnValueChanged", function(_, v) MM.UpdateButtonScale(v) end)

  local resetBtn = CreateFrame("Button", nil, f, "UIPanelButtonTemplate")
  resetBtn:SetSize(150,22); resetBtn:SetPoint("LEFT", scale, "RIGHT", 16, 0)
  resetBtn:SetText("Reset position")
  resetBtn:SetScript("OnClick", MM.ResetButtonAnchor)

  -- Macro auto-create
  local auto = CreateFrame("CheckButton", nil, f, "InterfaceOptionsCheckButtonTemplate")
  auto:SetPoint("TOPLEFT", lockBtn, "BOTTOMLEFT", 0, -12)
  auto.Text:SetText("Auto-create 'MM' macro at login")
  auto:SetChecked(MM.DB().autoCreateMacro ~= false)
  auto:SetScript("OnClick", function(self) MM.DB().autoCreateMacro = self:GetChecked() and true or false end)

  -- Create macro now
  local make = CreateFrame("Button", nil, f, "UIPanelButtonTemplate")
  make:SetSize(160,22); make:SetPoint("LEFT", auto, "RIGHT", 16, 0)
  make:SetText("Create macro now"); make:SetScript("OnClick", MM.EnsureMacro)

  -- Checklist label + scroll
  local label = f:CreateFontString(nil, "ARTWORK", "GameFontNormal")
  label:SetPoint("TOPLEFT", auto, "BOTTOMLEFT", 0, -14); label:SetText("Owned cosmetic toys (from your DB):")

  local scroll = CreateFrame("ScrollFrame", "MM_OptionsScroll", f, "UIPanelScrollFrameTemplate")
  scroll:SetPoint("TOPLEFT", label, "BOTTOMLEFT", 0, -6); scroll:SetPoint("BOTTOMRIGHT", f, "BOTTOMRIGHT", -30, 16)

  local container = CreateFrame("Frame", nil, scroll); container:SetPoint("TOPLEFT"); container:SetSize(1,1); scroll:SetScrollChild(container)
  f._listContainer = container

  return f
end

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
  if Settings and Settings.RegisterAddOnCategory then registerSettings() else registerLegacy() end
end

function MM.OptionsRefresh()
  local container = MM._optionsCanvas and MM._optionsCanvas._listContainer or (MM._legacyPanel and MM._legacyPanel._listContainer)
  if container then
    container:SetWidth(((MM._optionsCanvas or MM._legacyPanel):GetWidth() or 600) - 46)
    refreshChecklist(container)
  end
end
