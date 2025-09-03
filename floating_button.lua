-- Morphomatic — floating_button.lua
-- Floating button that can be locked (click to use) or unlocked (drag only).

MM = MM or {}
local L = MM.L or {}

local floatBtn
local function saveAnchor(self)
  local p, _, _, x, y = self:GetPoint()
  local b = MM.DB().button
  b.point, b.x, b.y = p, x, y
end

--- Internal: (re)apply visuals & behavior based on locked state.
function MM.RefreshButtonLockVisual()
  if not MM_Float then return end
  local locked = MM.DB().button.locked and true or false

  -- Border & overlay
  if locked then
    MM_Float:SetBackdropBorderColor(0.8, 0.8, 0.8, 1)
    if MM_Float.dragOverlay then MM_Float.dragOverlay:Hide() end
    if MM_Float.grip then MM_Float.grip:Hide() end
    MM_Float:SetAlpha(1)
  else
    -- Emphasize border and show grip/overlay so it's clearly draggable
    MM_Float:SetBackdropBorderColor(0.2, 0.8, 1.0, 1)
    if MM_Float.dragOverlay then MM_Float.dragOverlay:Show() end
    if MM_Float.grip then MM_Float.grip:Show() end
    MM_Float:SetAlpha(0.95)
  end
end

--- Create the floating button (SecureActionButtonTemplate).
--- When LOCKED: PreClick prepares a random toy on THIS button and click uses it.
--- When UNLOCKED: PreClick exits early; clicks do nothing; you can drag to move.
function MM.CreateFloatingButton()
  if floatBtn then return floatBtn end

  floatBtn =
    CreateFrame("Button", "MM_Float", UIParent, "SecureActionButtonTemplate,BackdropTemplate")
  floatBtn:SetSize(44, 44)
  floatBtn:SetMovable(true)
  floatBtn:EnableMouse(true)
  floatBtn:RegisterForDrag("LeftButton")

  -- Secure: accept both down/up, but behavior is gated by "locked" state.
  floatBtn:RegisterForClicks("AnyDown", "AnyUp")

  floatBtn:SetScript("OnDragStart", function(s)
    if not MM.DB().button.locked then s:StartMoving() end
  end)
  floatBtn:SetScript("OnDragStop", function(s)
    s:StopMovingOrSizing()
    saveAnchor(s)
  end)

  -- Prepare on PreClick ONLY if locked; otherwise ignore click completely.
  floatBtn:SetScript("PreClick", function(self)
    if not MM.DB().button.locked then
      -- Safety: clear attributes so no stale secure action can fire.
      self:SetAttribute("type", nil)
      self:SetAttribute("item", nil)
      self:SetAttribute("macrotext", nil)
      -- Debug (comment if noisy): MM.dprint("MM Float: unlocked, click ignored")
      return
    end
    -- Locked -> prepare this very button to use a random toy
    if MM and MM.PrepareButtonForRandomToy then MM.PrepareButtonForRandomToy(self) end
  end)

  -- Visuals
  floatBtn:SetBackdrop({
    bgFile = "Interface/Buttons/WHITE8x8",
    edgeFile = "Interface/Tooltips/UI-Tooltip-Border",
    edgeSize = 12,
    insets = { left = 2, right = 2, top = 2, bottom = 2 },
  })
  floatBtn:SetBackdropColor(0, 0, 0, 0.45)
  floatBtn:SetBackdropBorderColor(0.8, 0.8, 0.8, 1)

  -- Icon: Orb of Deception by default
  local tex = floatBtn:CreateTexture(nil, "ARTWORK")
  tex:SetAllPoints()
  tex:SetTexture(GetItemIcon(1973) or 134414)
  floatBtn.icon = tex

  -- Drag overlay (subtle diagonal)
  local overlay = floatBtn:CreateTexture(nil, "OVERLAY")
  overlay:SetAllPoints()
  overlay:SetTexture("Interface/Buttons/WHITE8x8")
  overlay:SetVertexColor(0.2, 0.7, 1.0, 0.10) -- light cyan tint
  overlay:Hide()
  floatBtn.dragOverlay = overlay

  -- Grip icon (center)
  local grip = floatBtn:CreateTexture(nil, "OVERLAY")
  grip:SetSize(16, 16)
  grip:SetPoint("CENTER")
  -- Common size-grab icon from chat/im
  grip:SetTexture("Interface/ChatFrame/UI-ChatIM-SizeGrabber-Up")
  grip:SetVertexColor(0.8, 0.95, 1.0, 0.9)
  grip:Hide()
  floatBtn.grip = grip

  -- Tooltip (changes based on lock state)
  local tip = CreateFrame("GameTooltip", "MM_Float_Tooltip", UIParent, "GameTooltipTemplate")
  floatBtn:SetScript("OnEnter", function(self)
    tip:SetOwner(self, "ANCHOR_RIGHT")
    tip:SetText(MM.T("TITLE", "Morphomatic"), 1, 1, 1)
    if MM.DB().button.locked then
      tip:AddLine(
        MM.T("TIP_CLICK", "Click: triggers a random cosmetic toy (from your selection)."),
        0.9,
        0.9,
        0.9,
        true
      )
      tip:AddLine(
        MM.T("TIP_UNLOCK_TO_MOVE", "Unlock in Settings to move the button."),
        0.7,
        0.7,
        0.7
      )
    else
      tip:AddLine(MM.T("TIP_DRAG_TO_MOVE", "Unlocked: drag to move."), 0.9, 0.9, 0.9)
      tip:AddLine(MM.T("TIP_CLICKS_DISABLED", "Clicks are disabled while unlocked."), 0.9, 0.5, 0.5)
      tip:AddLine(MM.T("TIP_LOCK_TO_USE", "Lock it in Settings to use it again."), 0.7, 0.7, 0.7)
    end
    tip:Show()
  end)
  floatBtn:SetScript("OnLeave", function() tip:Hide() end)

  -- Position & scale from saved settings
  local b = MM.DB().button
  floatBtn:SetScale(b.scale or 1)
  floatBtn:ClearAllPoints()
  floatBtn:SetPoint(b.point or "CENTER", UIParent, b.point or "CENTER", b.x or 0, b.y or 0)

  -- Apply initial lock visuals
  MM.RefreshButtonLockVisual()

  return floatBtn
end

--- Show/hide helpers (used by settings)
function MM.ShowButton()
  if not MM_Float then MM.CreateFloatingButton() end
  MM_Float:Show()
  MM.RefreshButtonLockVisual()
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
