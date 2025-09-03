-- Morphomatic — minimap.lua
-- Minimap icon integration using LibDataBroker + LibDBIcon (embedded).

MM = MM or {}
local T = MM.T

-- Try to fetch libs (they are embedded and loaded via .toc)
local LDB = LibStub and LibStub:GetLibrary("LibDataBroker-1.1", true)
local LDI = LibStub and LibStub:GetLibrary("LibDBIcon-1.0", true)

-- Helper so other modules (settings) can check availability
function MM.HasMinimapLibs() return (LDB ~= nil and LDI ~= nil) end

if not MM.HasMinimapLibs() then
  MM.dprint("Morphomatic: minimap support not available (LibDataBroker/LibDBIcon missing).")
  return
end

-- Create DataBroker launcher
local broker = LDB:NewDataObject("Morphomatic", {
  type = "launcher",
  text = T("TITLE", "Morphomatic"),
  icon = GetItemIcon(1973) or "Interface\\Icons\\INV_Misc_QuestionMark",
  OnClick = function(_, button)
    if button == "LeftButton" then
      if Settings and Settings.OpenToCategory and MM._optionsCategory then
        Settings.OpenToCategory(MM._optionsCategory.ID or MM._optionsCategory)
      elseif InterfaceOptionsFrame_OpenToCategory and MM._legacyPanel then
        InterfaceOptionsFrame_OpenToCategory(MM._legacyPanel)
        InterfaceOptionsFrame_OpenToCategory(MM._legacyPanel)
      else
        print(T("OPTIONS_NOT_AVAILABLE", "Morphomatic: options not available."))
      end
    elseif button == "RightButton" then
      print(T("MINIMAP_RIGHTCLICK", "Morphomatic: right-click reserved for future features."))
    end
  end,
  OnTooltipShow = function(tt)
    tt:AddLine(T("TITLE", "Morphomatic"))
    tt:AddLine(T("MINIMAP_TIP_LEFT", "Left-click: open options"), 1, 1, 1)
    tt:AddLine(T("MINIMAP_TIP_RIGHT", "Right-click: reserved"), 0.7, 0.7, 0.7)
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
