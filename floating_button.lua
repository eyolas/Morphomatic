-- Morphomatic — floating_button.lua
-- Optional floating button that triggers the same secure flow as the "MM" macro.

MM = MM or {}

local floatBtn

local function saveAnchor(self)
  local p, _, _, x, y = self:GetPoint()
  local b = MM.DB().button
  b.point, b.x, b.y = p, x, y
end

--- Create the floating button (SecureActionButtonTemplate) that runs:
--- 1) MM.PrepareSecureUse() to set up the secure button with a random toy
--- 2) /click MM_SecureUse to perform the protected action
function MM.CreateFloatingButton()
  if floatBtn then return floatBtn end

  floatBtn =
    CreateFrame("Button", "MM_Float", UIParent, "SecureActionButtonTemplate,BackdropTemplate")
  floatBtn:SetSize(44, 44)
  floatBtn:SetMovable(true)
  floatBtn:EnableMouse(true)
  floatBtn:RegisterForDrag("LeftButton")
  floatBtn:SetScript("OnDragStart", function(s)
    if not MM.DB().button.locked then s:StartMoving() end
  end)
  floatBtn:SetScript("OnDragStop", function(s)
    s:StopMovingOrSizing()
    saveAnchor(s)
  end)

  floatBtn:SetAttribute("type", "click")
  floatBtn:SetAttribute("clickbutton", MM.EnsureSecureButton())

  -- Visuals
  floatBtn:SetBackdrop({
    bgFile = "Interface/Buttons/WHITE8x8",
    edgeFile = "Interface/Tooltips/UI-Tooltip-Border",
    edgeSize = 12,
    insets = { left = 2, right = 2, top = 2, bottom = 2 },
  })
  floatBtn:SetBackdropColor(0, 0, 0, 0.45)

  local tex = floatBtn:CreateTexture(nil, "ARTWORK")
  tex:SetAllPoints()
  tex:SetTexture(134414) -- generic "toy-like" icon
  floatBtn.icon = tex

  -- Position & scale from saved settings
  local b = MM.DB().button
  floatBtn:SetScale(b.scale or 1)
  floatBtn:ClearAllPoints()
  floatBtn:SetPoint(b.point or "CENTER", UIParent, b.point or "CENTER", b.x or 0, b.y or 0)

  -- Tooltip
  local tip = CreateFrame("GameTooltip", "MM_Float_Tooltip", UIParent, "GameTooltipTemplate")
  floatBtn:SetScript("OnEnter", function(self)
    tip:SetOwner(self, "ANCHOR_RIGHT")
    tip:SetText("Morphomatic", 1, 1, 1)
    tip:AddLine("Click: triggers a random cosmetic toy (from your selection).", 0.9, 0.9, 0.9, true)
    tip:AddLine("Drag to move (when unlocked in settings).", 0.7, 0.7, 0.7)
    tip:Show()
  end)
  floatBtn:SetScript("OnLeave", function() tip:Hide() end)

  return floatBtn
end

--- Show/hide helpers (used by settings)
function MM.ShowButton()
  if not MM_Float then MM.CreateFloatingButton() end
  MM_Float:Show()
end

function MM.HideButton()
  if MM_Float then MM_Float:Hide() end
end

--- Reset position to screen center
function MM.ResetButtonAnchor()
  local b = MM.DB().button
  b.point, b.x, b.y = "CENTER", 0, 0
  if MM_Float then
    MM_Float:ClearAllPoints()
    MM_Float:SetPoint("CENTER", UIParent, "CENTER", 0, 0)
  end
end

--- Apply live scale changes
function MM.UpdateButtonScale(val)
  MM.DB().button.scale = val
  if MM_Float then MM_Float:SetScale(val) end
end
