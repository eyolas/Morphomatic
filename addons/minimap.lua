-- Morphomatic — minimap.lua
-- Minimap icon integration using LibDataBroker + LibDBIcon (embedded).

MM = MM or {}
local L = LibStub('AceLocale-3.0'):GetLocale('Morphomatic')

local LDB = LibStub("LibDataBroker-1.1")
local LDI = LibStub("LibDBIcon-1.0")

-- Create DataBroker launcher
local broker = LDB:NewDataObject("Morphomatic", {
  type = "launcher",
  text = L.TITLE,
  icon = "Interface\\AddOns\\Morphomatic\\images\\button.blp",
  OnClick = function(_, button)
    if button == "LeftButton" then
      if Settings and Settings.OpenToCategory and MM._optionsCategory then
        Settings.OpenToCategory(MM._optionsCategory.ID or MM._optionsCategory)
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
function MM.RegisterMinimap()
  MM.DB().minimap = MM.DB().minimap or { hide = false }
  LDI:Register("Morphomatic", broker, MM.DB().minimap)
end

function MM.ToggleMinimap(show)
  local minimap = MM.DB().minimap or {}
  MM.DB().minimap = minimap
  minimap.hide = not show
  if show then
    LDI:Show("Morphomatic")
  else
    LDI:Hide("Morphomatic")
  end
end
