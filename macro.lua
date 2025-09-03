-- Morphomatic — macro.lua
-- Create/update a macro identified by a signature in its body.
-- Searches BOTH global and per-character macro pools to avoid duplicates.
-- The macro body is the proven variant: /click MM_SecureUse LeftButton[ 1].

MM = MM or {}

local MACRO_SIGNATURE = "# Morphomatic macro"
local MACRO_NAME      = "Morphomatic" -- change to "MM" if you prefer the short name
local MACRO_ICON      = (GetItemIcon and GetItemIcon(1973)) or "INV_Misc_QuestionMark" -- Orb of Deception

--- Return total macro count (global + character)
local function TotalMacroCount()
  local g, c = GetNumMacros()
  return (g or 0) + (c or 0)
end

--- Find the index of the Morphomatic macro by its body signature.
--- Scans BOTH global and character macro slots.
---@return number idx (0 if not found)
function MM.FindMacroIndex()
  local g, c = GetNumMacros()
  local total = (g or 0) + (c or 0)
  for i = 1, total do
    local body = GetMacroBody(i)
    if body and body:find(MACRO_SIGNATURE, 1, true) then
      return i
    end
  end
  return 0
end

--- Build the working macro body (LeftButton, optionally " 1" if key-down casting)
local function BuildMacroBody()
  local needsDown = (GetCVar("ActionButtonUseKeyDown") == "1")
  return string.format([[
#showtooltip
%s
/click MM_SecureUse LeftButton%s
]], MACRO_SIGNATURE, needsDown and " 1" or "")
end

--- Create or refresh the Morphomatic macro
function MM.RecreateMacro()
  if InCombatLockdown() then
    MM.dprint("Morphomatic: cannot (re)create macro in combat. Will retry after combat.")
    MM._macroNeedsRecreate = true
    return
  end

  -- Ensure the secure button exists and PreClick prepares the toy
  if not MM_SecureUse and MM.EnsureSecureButton then MM.EnsureSecureButton() end

  local body = BuildMacroBody()
  local icon = MACRO_ICON

  -- 1) Try to find an existing macro by SIGNATURE across both pools
  local idx = MM.FindMacroIndex()
  if idx > 0 then
    EditMacro(idx, MACRO_NAME, icon, body, 1, 1)
    MM.dprint("Morphomatic: macro updated (by signature).")
    return
  end

  -- 2) Not found by signature — try by NAME (user may have an older macro)
  local nameIdx = GetMacroIndexByName(MACRO_NAME)
  if nameIdx and nameIdx > 0 then
    -- Overwrite in place and inject our signature
    EditMacro(nameIdx, MACRO_NAME, icon, body, 1, 1)
    MM.dprint("Morphomatic: macro updated (by name, signature injected).")
    return
  end

  -- 3) Create NEW macro — prefer GLOBAL; if full, fallback to per-character
  local created = CreateMacro(MACRO_NAME, icon, body, false)  -- false/nil => GLOBAL
  if not created then
    created = CreateMacro(MACRO_NAME, icon, body, true)       -- true => per-character
  end

  if created then
    MM.dprint("Morphomatic: macro created.")
  else
    MM.dprint("Morphomatic: failed to create macro.")
  end
end

--- Debug helper (optional)
function MM.DumpMacro()
  local idx = MM.FindMacroIndex()
  if idx > 0 then
    local body = GetMacroBody(idx) or ""
    MM.dprint("Morphomatic macro index =", idx)
    MM.dprint("Macro first line:", body:match("([^\n\r]*)") or "")
  else
    MM.dprint("Morphomatic macro not found.")
  end
end
