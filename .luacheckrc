-- Use plain Lua 5.1 rules (WoW runs Lua 5.1)
std = "lua51"

-- Ignore bundled libraries
files["Libs/"] = { ignore = { ".*" } }

-- WoW / addon globals we read from
read_globals = {
  "MM",
  -- WoW API
  "CreateFrame","UIParent","GameTooltip","C_Timer","wipe",
  "InCombatLockdown","SaveVariables","GetCVar","GetLocale",
  "GetItemInfo","GetItemIcon",
  "GetNumMacros","GetMacroBody","GetMacroIndexByName","CreateMacro","EditMacro","DeleteMacro",
  "PlayerHasToy","C_ToyBox",
  "Settings","InterfaceOptions_AddCategory","InterfaceOptionsFrame_OpenToCategory",
  "DevTools_Dump",
  -- Libraries
  "LibStub","LibDataBroker","LibDBIcon",
}

-- Globals defined by this addon at runtime (to avoid “unused global” noise)
globals = {
  "MM_SecureUse", -- secure button
  "MM_Float",     -- floating button
}
