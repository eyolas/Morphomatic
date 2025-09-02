-- Morphomatic — bootstrap.lua
-- Event wiring + unified /mm slash commands (minimal version)

MM = MM or {}

----------------------------------------------------------------------
-- Utilities
----------------------------------------------------------------------
local function parseBool(arg)
  arg = arg and arg:lower() or ""
  if arg == "on" or arg == "true" or arg == "1" then return true end
  if arg == "off" or arg == "false" or arg == "0" then return false end
  return nil
end

function MM.OpenOptions()
  if Settings and Settings.OpenToCategory and MM._optionsCategory then
    Settings.OpenToCategory(MM._optionsCategory.ID or MM._optionsCategory)
  elseif InterfaceOptionsFrame then
    InterfaceOptionsFrame_OpenToCategory("Morphomatic")
    InterfaceOptionsFrame_OpenToCategory("Morphomatic")
  end
end

----------------------------------------------------------------------
-- Events
----------------------------------------------------------------------
local f = CreateFrame("Frame")
f:RegisterEvent("ADDON_LOADED")
f:RegisterEvent("PLAYER_LOGIN")
f:RegisterEvent("PLAYER_REGEN_ENABLED")
f:RegisterEvent("TOYS_UPDATED")

f:SetScript("OnEvent", function(_, evt, arg1)
  if evt == "ADDON_LOADED" and arg1 == "Morphomatic" then
    if MM.DB then MM.DB() end
    if MM.OptionsRegister then MM.OptionsRegister() end
    if MM.OptionsRefresh then MM.OptionsRefresh() end

  elseif evt == "PLAYER_LOGIN" then
    if MM.SeedRNG then MM.SeedRNG() end
    if MM.EnsureSecureButton then MM.EnsureSecureButton() end

    if MM.DB().showButton ~= false then
      if MM.ShowButton then MM.ShowButton() end
    else
      if MM.HideButton then MM.HideButton() end
    end
    if MM.RefreshButtonLockVisual then MM.RefreshButtonLockVisual() end

    if MM.DB().autoCreateMacro ~= false and MM.RecreateMacro then
      MM.RecreateMacro()
    end

  elseif evt == "PLAYER_REGEN_ENABLED" then
    if MM._macroNeedsRecreate and MM.RecreateMacro then
      MM._macroNeedsRecreate = nil
      MM.RecreateMacro()
    end

  elseif evt == "TOYS_UPDATED" then
    if MM.OptionsRefresh then MM.OptionsRefresh() end
  end
end)

----------------------------------------------------------------------
-- Unified slash: /mm <subcommand>
----------------------------------------------------------------------
SLASH_MORPHOMATIC1 = "/mm"
SlashCmdList.MORPHOMATIC = function(msg)
  local args = {}
  for w in string.gmatch(msg or "", "%S+") do
    table.insert(args, w)
  end
  local cmd = (args[1] or ""):lower()

  -- Default = help
  if cmd == "" or cmd == "help" then
    print("Morphomatic — commands:")
    print("  /mm options                     : open settings")
    print("  /mm dump [key|all]              : dump saved variables (MorphomaticDB)")
    print("  /mm save                        : force SaveVariables('MorphomaticDB')")
    print("  /mm probe                       : inspect secure button and macro")
    print("  /mm macro recreate              : (re)create the 'MM' macro")
    return
  end

  ------------------------------------------------------------------
  -- options
  ------------------------------------------------------------------
  if cmd == "options" then
    MM.OpenOptions()
    return
  end

  ------------------------------------------------------------------
  -- dump
  ------------------------------------------------------------------
  if cmd == "dump" then
    local key = args[2]
    if not MorphomaticDB then
      print("Morphomatic: no saved variables found.")
      return
    end
    if not key or key:lower() == "all" then
      if DevTools_Dump then
        DevTools_Dump(MorphomaticDB)
      else
        print("MorphomaticDB:")
        for k, v in pairs(MorphomaticDB) do
          print(" ", k, "=", type(v) == "table" and "table" or tostring(v))
        end
      end
      return
    end
    if MorphomaticDB[key] ~= nil then
      if DevTools_Dump then
        DevTools_Dump(MorphomaticDB[key])
      else
        print("MorphomaticDB." .. key .. ":")
        if type(MorphomaticDB[key]) == "table" then
          for k2, v2 in pairs(MorphomaticDB[key]) do
            print("   ", k2, "=", tostring(v2))
          end
        else
          print("   ", tostring(MorphomaticDB[key]))
        end
      end
    else
      print("Morphomatic: key not found in DB ->", key)
    end
    return
  end

  ------------------------------------------------------------------
  -- save
  ------------------------------------------------------------------
  if cmd == "save" then
    SaveVariables("MorphomaticDB")
    print("Morphomatic: variables saved to disk.")
    return
  end

  ------------------------------------------------------------------
  -- probe
  ------------------------------------------------------------------
  if cmd == "probe" then
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
      local body = GetMacroBody(idx) or ""
      print("  macro body first line:", body:match("([^\n\r]*)") or "")
    end
    return
  end

  ------------------------------------------------------------------
  -- macro
  ------------------------------------------------------------------
  if cmd == "macro" then
    local sub = (args[2] or ""):lower()
    if sub == "recreate" and MM.RecreateMacro then
      MM.RecreateMacro()
      return
    end
    print("Usage: /mm macro recreate")
    return
  end

  ------------------------------------------------------------------
  -- Fallback
  ------------------------------------------------------------------
  print("Morphomatic: unknown command. Try /mm help")
end
