-- Morphomatic — minimap.lua
-- Minimap icon integration (optional, only if Libs are available)

MM = MM or {}
local T = MM.T

local hasLDB = LibStub and LibStub:GetLibrary("LibDataBroker-1.1", true)
local hasLDI = LibStub and LibStub:GetLibrary("LibDBIcon-1.0", true)

-- Expose a helper so UI can know if minimap is available
function MM.HasMinimapLibs() return (hasLDB and hasLDI) and true or false end

if not MM.HasMinimapLibs() then
  MM.dprint("Morphomatic: minimap support not available (LibDataBroker/LibDBIcon missing).")
  return
end

local LDB = hasLDB
local LDI = hasLDI

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
        print(T("OPTIONS_NOT_AVAILABLE"))
      end
    elseif button == "RightButton" then
      print(T("MINIMAP_RIGHTCLICK"))
    end
  end,
  OnTooltipShow = function(tt)
    tt:AddLine(T("TITLE", "Morphomatic"))
    tt:AddLine(T("MINIMAP_TIP_LEFT"), 1, 1, 1)
    tt:AddLine(T("MINIMAP_TIP_RIGHT"), 0.7, 0.7, 0.7)
  end,
})

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
