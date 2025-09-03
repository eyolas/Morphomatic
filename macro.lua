-- Morphomatic — macro.lua
-- Handles creation and maintenance of the secure macro that triggers Morphomatic.
-- The macro is identified by a unique signature line in its body.

MM = MM or {}

local MACRO_SIGNATURE = "# Morphomatic macro"
local MACRO_NAME = "Morphomatic" -- user-visible name in the macro UI
local MACRO_ICON = GetItemIcon(1973) or "INV_Misc_QuestionMark" -- Orb of Deception icon

--- Create or update the Morphomatic macro
function MM.RecreateMacro()
  if InCombatLockdown() then
    MM.dprint("Morphomatic: cannot (re)create macro in combat. Will retry after combat.")
    MM._macroNeedsRecreate = true
    return
  end

  -- Build the macro body with the unique signature
  local body = string.format(
    [[
#showtooltip
%s
/run if MM and MM.PrepareSecureUse then MM.PrepareSecureUse() end
/click MM_SecureUse
]],
    MACRO_SIGNATURE
  )

  -- Look for an existing macro with our signature
  local numGlobal, _ = GetNumMacros()
  for i = 1, numGlobal do
    local macroBody = GetMacroBody(i)
    if macroBody and macroBody:find(MACRO_SIGNATURE) then
      EditMacro(i, MACRO_NAME, MACRO_ICON, body, 1, 1)
      MM.dprint("Morphomatic: macro updated.")
      return
    end
  end

  -- If not found, create a new global macro
  local idx = CreateMacro(MACRO_NAME, MACRO_ICON, body, true)
  if idx then
    MM.dprint("Morphomatic: macro created.")
  else
    MM.dprint("Morphomatic: failed to create macro.")
  end
end

--- Find the index of the Morphomatic macro by its signature
---@return number index (0 if not found)
function MM.FindMacroIndex()
  local numGlobal, _ = GetNumMacros()
  for i = 1, numGlobal do
    local macroBody = GetMacroBody(i)
    if macroBody and macroBody:find(MACRO_SIGNATURE) then return i end
  end
  return 0
end

--- Debug helper: dump the macro body if it exists
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
