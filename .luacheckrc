-- Luacheck configuration for Morphomatic

std = "lua54"

-- Globals provided by WoW API
globals = {
  "MM",
  "MorphomaticDB", "MorphomaticCustom",
  "GetServerTime", "UnitGUID", "GetTime",
  "GetItemInfo", "PlayerHasToy",
  "C_ToyBox", "IsUsableItem", "GetItemCooldown",
  "CreateFrame", "UIParent", "InterfaceOptions_AddCategory",
  "Settings", "InterfaceOptionsFrame", "InterfaceOptionsFrame_OpenToCategory",
  "GameTooltip", "GameFontNormalLarge", "GameFontHighlight", "GameFontNormal",
  "UIPanelButtonTemplate", "OptionsSliderTemplate", "UIPanelScrollFrameTemplate",
  "GameTooltipTemplate", "BackdropTemplate",
  "SlashCmdList", "SLASH_MM1", "SLASH_MMDEBUG1", "SLASH_MMSOURCES1",
  "InCombatLockdown", "SecureActionButtonTemplate"
}

-- Ignore warnings about unused arguments (common for WoW API callbacks)
unused_args = false
allow_defined_top = true

-- Max line length
max_line_length = 120

-- Allow globals defined in the DB file
read_globals = {
  "MM_DB"
}

-- Ignore trailing whitespace in comments
ignore = {
  "212" -- trailing whitespace in comments
}