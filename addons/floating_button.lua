-- Morphomatic — addons/floating_button.lua
-- Floating button that can be locked (click to use) or unlocked (drag only).

local ADDON, ns = ...
local MM = ns.MM
local FloatButton = MM:NewModule("FloatButton")
MM:RegisterModule("FloatButton", FloatButton)
local L = LibStub("AceLocale-3.0"):GetLocale("Morphomatic")

-- === Icon config ===
local ICON_PATH = "Interface\\AddOns\\Morphomatic\\images\\button.blp"
local function GetFallbackIcon()
  -- Orb of Deception (1973) or question mark if missing
  return GetItemIcon and GetItemIcon(1973) or 134400 -- INV_Misc_QuestionMark
end

local function saveAnchor(frame)
  local p, _, _, x, y = frame:GetPoint()
  local b = MM.DB:Get().button
  b.point, b.x, b.y = p, x, y
end

--- Internal: (re)apply visuals & behavior based on locked state.
function FloatButton:RefreshLockVisual()
  local btn = self.frame
  if not btn then return end
  local locked = MM.DB:Get().button.locked and true or false

  if locked then
    -- Neutral grey border, normal dark background
    btn:SetBackdropBorderColor(0.8, 0.8, 0.8, 1)
    btn:SetBackdropColor(0, 0, 0, 0.45)
    if btn.dragOverlay then btn.dragOverlay:Hide() end
    if btn.grip then btn.grip:Hide() end
    btn:SetAlpha(1)
  else
    -- ElvUI-style: red border + red translucent background
    btn:SetBackdropBorderColor(1.0, 0.1, 0.1, 1)
    btn:SetBackdropColor(0.8, 0, 0, 0.35)
    if btn.dragOverlay then btn.dragOverlay:Show() end
    if btn.grip then btn.grip:Show() end
    btn:SetAlpha(0.95)
  end
end

--- Create the floating button (SecureActionButtonTemplate).
function FloatButton:Create()
  if self.frame then return self.frame end

  local btn =
    CreateFrame("Button", "MM_Float", UIParent, "SecureActionButtonTemplate,BackdropTemplate")
  btn:SetSize(44, 44)
  btn:SetMovable(true)
  btn:EnableMouse(true)
  btn:RegisterForDrag("LeftButton")
  btn:RegisterForClicks("AnyDown", "AnyUp")

  btn:SetScript("OnDragStart", function(s)
    if not MM.DB:Get().button.locked then s:StartMoving() end
  end)
  btn:SetScript("OnDragStop", function(s)
    s:StopMovingOrSizing()
    saveAnchor(s)
  end)

  btn:SetScript("PreClick", function(s)
    if not MM.DB:Get().button.locked then
      -- Clear attributes to avoid firing stale secure actions
      s:SetAttribute("type", nil)
      s:SetAttribute("item", nil)
      s:SetAttribute("macrotext", nil)
      return
    end
    if MM and MM.Helpers.PrepareButtonForRandomToy then MM.Helpers:PrepareButtonForRandomToy(s) end
  end)

  -- Frame visuals
  btn:SetBackdrop({
    bgFile = "Interface/Buttons/WHITE8x8",
    edgeFile = "Interface/Tooltips/UI-Tooltip-Border",
    edgeSize = 12,
    insets = { left = 2, right = 2, top = 2, bottom = 2 },
  })
  btn:SetBackdropColor(0, 0, 0, 0.45)
  btn:SetBackdropBorderColor(0.8, 0.8, 0.8, 1)

  -- Icon
  local tex = btn:CreateTexture(nil, "ARTWORK")
  tex:SetAllPoints()
  local ok = tex:SetTexture(ICON_PATH)
  if not ok then tex:SetTexture(GetFallbackIcon()) end
  local mask = btn:CreateMaskTexture(nil, "ARTWORK")
  mask:SetAllPoints()
  mask:SetTexture("Interface\\CharacterFrame\\TempPortraitAlphaMask")
  tex:AddMaskTexture(mask)
  btn.icon = tex

  -- Drag overlay
  local overlay = btn:CreateTexture(nil, "OVERLAY")
  overlay:SetAllPoints()
  overlay:SetTexture("Interface/Buttons/WHITE8x8")
  overlay:SetVertexColor(0.2, 0.7, 1.0, 0.10)
  overlay:Hide()
  btn.dragOverlay = overlay

  -- Grip icon
  local grip = btn:CreateTexture(nil, "OVERLAY")
  grip:SetSize(16, 16)
  grip:SetPoint("CENTER")
  grip:SetTexture("Interface/ChatFrame/UI-ChatIM-SizeGrabber-Up")
  grip:SetVertexColor(0.8, 0.95, 1.0, 0.9)
  grip:Hide()
  btn.grip = grip

  -- Tooltip
  local tip = CreateFrame("GameTooltip", "MM_Float_Tooltip", UIParent, "GameTooltipTemplate")
  btn:SetScript("OnEnter", function(self)
    tip:SetOwner(self, "ANCHOR_RIGHT")
    tip:SetText(L["TITLE"], 1, 1, 1)
    if MM.DB:Get().button.locked then
      tip:AddLine(L["TIP_CLICK"], 0.9, 0.9, 0.9, true)
      tip:AddLine(L["TIP_UNLOCK_TO_MOVE"], 0.7, 0.7, 0.7)
    else
      tip:AddLine(L["TIP_DRAG_TO_MOVE"], 0.9, 0.9, 0.9)
      tip:AddLine(L["TIP_CLICKS_DISABLED"], 0.9, 0.5, 0.5)
      tip:AddLine(L["TIP_LOCK_TO_USE"], 0.7, 0.7, 0.7)
    end
    tip:Show()
  end)
  btn:SetScript("OnLeave", function() tip:Hide() end)

  -- Position & scale
  local b = MM.DB:Get().button
  btn:SetScale(b.scale or 1)
  btn:ClearAllPoints()
  local point = b.point or "CENTER"
  btn:SetPoint(point, UIParent, point, b.x or 0, b.y or 0)

  self.frame = btn
  self:RefreshLockVisual()
  return btn
end

--- Show/hide helpers
function FloatButton:Show()
  MM.Helpers:dprint("FloatButton:Show")
  local btn = self.frame or self:Create()
  btn:Show()
  self:RefreshLockVisual()
end

function FloatButton:Hide()
  MM.Helpers:dprint("FloatButton:Hide")
  if self.frame then self.frame:Hide() end
end

--- Reset position
function FloatButton:ResetAnchor()
  local b = MM.DB:Get().button
  b.point, b.x, b.y = "CENTER", 0, 0
  local btn = self.frame
  if btn then
    btn:ClearAllPoints()
    btn:SetPoint("CENTER", UIParent, "CENTER", 0, 0)
  end
end

--- Apply live scale changes
function FloatButton:UpdateScale(val)
  MM.DB:Get().button.scale = val
  if self.frame then self.frame:SetScale(val) end
end

function FloatButton:OnLoad()
  -- Optionally auto-create on login
  -- self:Create()
end
