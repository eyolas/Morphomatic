-- SPDX-License-Identifier: MIT
-- Copyright (c) 2025 David Touzet

-- Morphomatic — addons/macro.lua
-- Create/update a macro identified by a signature in its body.
-- Searches BOTH global and per-character macro pools to avoid duplicates.
-- The macro body is the proven variant: /click MM_SecureUse LeftButton[ 1].

local ADDON, ns = ...
local MM = ns.MM
local Macro = MM:NewModule("Macro")

local MACRO_SIGNATURE = "# Morphomatic macro"
local MACRO_NAME = "Morphomatic" -- change to "MM" if you prefer the short name
local MACRO_ICON = ( C_Item.GetItemIconByID and  C_Item.GetItemIconByID(1973)) or "INV_Misc_QuestionMark" -- Orb of Deception

--- Find the index of the Morphomatic macro by its body signature.
--- Scans BOTH global and character macro slots.
---@return number idx (0 if not found)
function Macro:FindMacroIndex()
  local g, c = GetNumMacros()
  local total = (g or 0) + (c or 0)
  for i = 1, total do
    local body = GetMacroBody(i)
    if body and body:find(MACRO_SIGNATURE, 1, true) then return i end
  end
  return 0
end

--- Build the working macro body (LeftButton, optionally " 1" if key-down casting)
local function BuildMacroBody()
  local needsDown = (GetCVar("ActionButtonUseKeyDown") == "1")
  return string.format(
    [[
#showtooltip
%s
/click MM_SecureUse LeftButton%s
]],
    MACRO_SIGNATURE,
    needsDown and " 1" or ""
  )
end

--- Create or refresh the Morphomatic macro
function Macro:RecreateMacro()
  if InCombatLockdown() then
    MM.Helpers:dprint("Morphomatic: cannot (re)create macro in combat. Will retry after combat.")
    MM._macroNeedsRecreate = true
    return
  end

  -- Ensure the secure button exists and PreClick prepares the toy
  if not _G.MM_SecureUse and MM.Helpers and MM.Helpers.EnsureSecureButton then
    MM.Helpers:EnsureSecureButton()
  end

  local body = BuildMacroBody()
  local icon = MACRO_ICON

  -- 1) Try to find an existing macro by SIGNATURE across both pools
  local idx = self:FindMacroIndex()
  if idx > 0 then
    EditMacro(idx, MACRO_NAME, icon, body, 1, 1)
    MM.Helpers:dprint("Morphomatic: macro updated (by signature).")
    return
  end

  -- 2) Not found by signature — try by NAME (user may have an older macro)
  local nameIdx = GetMacroIndexByName(MACRO_NAME)
  if nameIdx and nameIdx > 0 then
    EditMacro(nameIdx, MACRO_NAME, icon, body, 1, 1)
    MM.Helpers:dprint("Morphomatic: macro updated (by name, signature injected).")
    return
  end

  -- 3) Create NEW macro — prefer GLOBAL; if full, fallback to per-character
  local created = CreateMacro(MACRO_NAME, icon, body, false) -- false/nil => GLOBAL
  if not created then
    created = CreateMacro(MACRO_NAME, icon, body, true) -- true => per-character
  end

  if created then
    MM.Helpers:dprint("Morphomatic: macro created.")
  else
    MM.Helpers:dprint("Morphomatic: failed to create macro.")
  end
end

--- Debug helper (optional)
function Macro:DumpMacro()
  local idx = self:FindMacroIndex()
  if idx > 0 then
    local body = GetMacroBody(idx) or ""
    MM.Helpers:dprint("Morphomatic macro index =", idx)
    MM.Helpers:dprint("Macro first line:", body:match("([^\n\r]*)") or "")
  else
    MM.Helpers:dprint("Morphomatic macro not found.")
  end
end
