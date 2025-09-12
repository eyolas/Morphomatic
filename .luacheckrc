-- WoW uses Lua 5.1
std = "lua51"

-- Ignore vendor/externals created during CI
files[".luarocks/"] = { ignore = { ".*" } }
files["libs/"]      = { ignore = { ".*" } }
files[".luacheckrc"] = { ignore = { ".*" } }

ignore = { "ADDON" }

-- This addon DEFINES and MUTATES the global table `MM` across multiple files.
-- Declare writable fields here so "setting undefined field of global MM" goes away.
globals = {
  -- SavedVariables (writable)
  "MorphomaticDB",
  "MorphomaticCustom",

  -- Global frames/symbols created by the addon (writable)
  "MM_SecureUse",
  "MM_Float",
  "MM_DB",

  -- Slash machinery (we write to these)
  "SlashCmdList",
  "SLASH_MORPHOMATIC1",

  -- Addon namespace and fields we assign in various files
  MM = {
    fields = {
      -- localization
      "L", "T",

      -- core & utils
      "DB", "dprint", "IsDebug", "SetDebug", "SeedRNG",

      -- randomizer/helpers API
      "EnsureSecureButton",
      "PrepareButtonForRandomToy",
      "PrepareSecureUse",
      "GetCooldown",
      "IsOnCooldown",
      "IsUsable",
      "PlayerHasToy",
      "BuildPool",
      "ResolveToyName",
      "DebugDump",
      "DebugWhy",

      -- floating button
      "CreateFloatingButton",
      "ShowButton",
      "HideButton",
      "ResetButtonAnchor",
      "UpdateButtonScale",
      "RefreshButtonLockVisual",

      -- macro
      "FindMacroIndex",
      "RecreateMacro",
      "DumpMacro",
      "_macroNeedsRecreate",

      -- minimap
      "HasMinimapLibs",
      "RegisterMinimap",
      "ToggleMinimap",

      -- options
      "OpenOptions",
      "OptionsRegister",
      "OptionsRefresh",
      "_optionsCategory",
      "_optionsCanvas",
      "_legacyPanel",

      -- callbacks (CallbackHandler-1.0)
      "callbacks",
      "Fire",

      -- pool / eligible
      "BuildEligibleIDs",

      -- bulk selection
      "SelectAllToys", "UnselectAllToys", "ResetSelection",
    }
  },
}

-- APIs we only READ (WoW + libs)
read_globals = {
  -- Core WoW API used across files
  "CreateFrame","UIParent","GameTooltip",
  "C_Timer","wipe",
  "InCombatLockdown","SaveVariables","GetCVar","GetLocale",
  "GetItemInfo","GetItemIcon","GetItemSpell","GetTime",
  "GetNumMacros","GetMacroBody","GetMacroIndexByName","CreateMacro","EditMacro","DeleteMacro",
  "GetItemCooldown","IsUsableItem",
  "PlayerHasToy","C_ToyBox","C_Item",
  "Settings","InterfaceOptions_AddCategory","InterfaceOptionsFrame_OpenToCategory","InterfaceOptionsFrame",
  "DevTools_Dump",
  "UnitGUID","GetServerTime","time",

  -- Libraries (read only)
  "LibStub",
}

-- Style/ergonomics
unused_args = false
max_line_length = 140
