std = "lua51+wow"
files["Libs/"] = { ignore = {".*"} } -- ignore bundled libraries
ignore = {
  "MM", -- global addon namespace
  "LibStub",
  "LibDataBroker",
  "LibDBIcon",
  "Settings",
  "InterfaceOptionsFrame_OpenToCategory",
  "InCombatLockdown",
  "GetItemInfo",
  "GetMacroBody",
  "CreateMacro",
  "EditMacro",
  "DeleteMacro",
  "GetMacroIndexByName",
  "GetNumMacros",
  "GetItemIcon",
  "PlayerHasToy",
  "C_ToyBox",
}
