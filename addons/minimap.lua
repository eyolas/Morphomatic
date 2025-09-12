-- Morphomatic — addons/minimap.lua
-- Minimap icon integration using LibDataBroker + LibDBIcon (embedded).

local ADDON, ns = ...
local MM = ns.MM
local Minimap = MM:NewModule("Minimap")

local L = LibStub("AceLocale-3.0"):GetLocale("Morphomatic")
local LDB = LibStub("LibDataBroker-1.1")
local LDI = LibStub("LibDBIcon-1.0")

-- Create DataBroker launcher
local broker = LDB:NewDataObject("Morphomatic", {
  type = "launcher",
  text = L.TITLE,
  icon = "Interface\\AddOns\\Morphomatic\\images\\button.blp",
  OnClick = function(_, button)
    if button == "LeftButton" then
      local S = _G.Settings
      if S and S.OpenToCategory and MM._optionsCategory then
        S.OpenToCategory(MM._optionsCategory.ID or MM._optionsCategory)
      elseif InterfaceOptionsFrame_OpenToCategory and MM._legacyPanel then
        InterfaceOptionsFrame_OpenToCategory(MM._legacyPanel)
        InterfaceOptionsFrame_OpenToCategory(MM._legacyPanel)
      else
        print(L.OPTIONS_NOT_AVAILABLE)
      end
    elseif button == "RightButton" then
      print(L.MINIMAP_RIGHTCLICK)
    end
  end,
  OnTooltipShow = function(tt)
    tt:AddLine(L.TITLE)
    tt:AddLine(L.MINIMAP_TIP_LEFT, 1, 1, 1)
    tt:AddLine(L.MINIMAP_TIP_RIGHT, 0.7, 0.7, 0.7)
  end,
})

-- Register the minimap button
function Minimap:RegisterMinimap()
  local db = MM.DB:Get()
  db.minimap = db.minimap or { hide = false }
  LDI:Register("Morphomatic", broker, db.minimap)
end

function Minimap:ToggleMinimap(show)
  local db = MM.DB:Get()
  local minimap = db.minimap or {}
  db.minimap = minimap
  minimap.hide = not show
  if show then
    LDI:Show("Morphomatic")
  else
    LDI:Hide("Morphomatic")
  end
end
