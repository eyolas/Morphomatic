-- Events + slashes + auto-macro + floating button visibility
MM = MM or {}

-- Slash: open options
SLASH_MM1 = "/mm"
SlashCmdList.MM = function()
  if Settings and Settings.OpenToCategory and MM._optionsCategory then
    Settings.OpenToCategory(MM._optionsCategory:GetID())
  elseif InterfaceOptionsFrame and MM._legacyPanel then
    InterfaceOptionsFrame:Show()
    InterfaceOptionsFrame_OpenToCategory(MM._legacyPanel)
    InterfaceOptionsFrame_OpenToCategory(MM._legacyPanel)
  end
end

-- Slash: debug
SLASH_MMDEBUG1 = "/mmdebug"
SlashCmdList.MMDEBUG = function()
  if MM.DebugDump then MM.DebugDump() end
end

-- Slash: why
SLASH_MMWHY1 = "/mmwhy"
SlashCmdList.MMWHY = function()
  if MM.DebugWhy then MM.DebugWhy() end
end

-- Events
local f = CreateFrame("Frame")
f:RegisterEvent("ADDON_LOADED")
f:RegisterEvent("PLAYER_LOGIN")
f:RegisterEvent("TOYS_UPDATED")
f:RegisterEvent("PLAYER_REGEN_ENABLED") -- we may retry after combat

f:SetScript("OnEvent", function(_, evt, arg1)
  if evt == "ADDON_LOADED" and arg1 == "Morphomatic" then
    MM.DB()
    MM.OptionsRegister()
    MM.OptionsRefresh()
  elseif evt == "PLAYER_LOGIN" then
    MM.SeedRNG()
    if MM.EnsureSecureButton then MM.EnsureSecureButton() end
    if MM.DB().autoCreateMacro ~= false and MM.RecreateMacro then MM.RecreateMacro() end
    if MM.DB().showButton ~= false then
      MM.ShowButton()
    else
      MM.HideButton()
    end
  elseif evt == "PLAYER_REGEN_ENABLED" then
    -- Retry pending macro creation after combat
    if MM._macroNeedsRecreate and MM.RecreateMacro then
      MM._macroNeedsRecreate = nil
      MM.RecreateMacro()
    end
  elseif evt == "TOYS_UPDATED" then
    MM.OptionsRefresh()
  end
end)
