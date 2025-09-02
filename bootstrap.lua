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

-- /mmprobe: prints state of the secure button and macro
SLASH_MMPROBE1 = "/mmprobe"
SlashCmdList.MMPROBE = function()
  local b = MM_SecureUse
  print("MM probe — button:", b and b:GetName() or "nil")
  if b then
    print("  IsObjectType(Button) =", b:IsObjectType("Button"))
    print("  type attr            =", tostring(b:GetAttribute("type")))
    print("  item attr            =", tostring(b:GetAttribute("item")))
    local mt = b:GetAttribute("macrotext")
    print("  macrotext len        =", mt and #mt or 0)
  end
  local idx = GetMacroIndexByName("MM")
  print("  macro 'MM' index     =", idx)
  if idx > 0 then
    local _, icon, body = GetMacroInfo(idx)
    body = body or ""
    print("  macro body first line:", body:match("([^\n\r]+)") or "")
  end
end

-- Morphomatic — debug slash command

SLASH_MMDEBUGDUMP1 = "/mmdump"
SlashCmdList.MMDEBUGDUMP = function(msg)
  if not MorphomaticDB then
    print("Morphomatic: no saved variables found.")
    return
  end

  -- Default: dump everything
  if msg == "all" or msg == "" then
    if DevTools_Dump then
      DevTools_Dump(MorphomaticDB)
    else
      print("MorphomaticDB:", MorphomaticDB)
      for k, v in pairs(MorphomaticDB) do
        print(" ", k, "=", type(v) == "table" and ("table(" .. tostring(#v) .. ")") or tostring(v))
      end
    end
    return
  end

  -- Dump a specific key, e.g. `/mmdump enabledToys`
  local key = msg:match("^(%S+)")
  if key and MorphomaticDB[key] then
    if DevTools_Dump then
      DevTools_Dump(MorphomaticDB[key])
    else
      print("MorphomaticDB." .. key .. ":", MorphomaticDB[key])
      if type(MorphomaticDB[key]) == "table" then
        for k2, v2 in pairs(MorphomaticDB[key]) do
          print("   ", k2, "=", tostring(v2))
        end
      end
    end
  else
    print("Morphomatic: key not found in DB ->", key)
  end
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
