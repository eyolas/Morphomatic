-- Morphomatic — macro.lua
-- Create/update a macro identified by a signature in its body.
-- Uses the proven body: /click MM_SecureUse LeftButton[ 1] (where " 1" depends on ActionButtonUseKeyDown).
-- The secure button's PreClick (MM_SecureUse) must prepare the toy (see EnsureSecureButton).

MM = MM or {}

local MACRO_SIGNATURE = "# Morphomatic macro"
local MACRO_NAME      = "Morphomatic" -- user-facing name; set to "MM" if you prefer
local MACRO_ICON      = GetItemIcon and GetItemIcon(1973) or "INV_Misc_QuestionMark" -- Orb of Deception

--- Find the index of the Morphomatic macro by its body signature
---@return number index (0 if not found)
function MM.FindMacroIndex()
  local numGlobal = (select(1, GetNumMacros()))
  for i = 1, numGlobal do
    local macroBody = GetMacroBody(i)
    if macroBody and macroBody:find(MACRO_SIGNATURE, 1, true) then
      return i
    end
  end
  return 0
end

--- Create or refresh the Morphomatic macro
function MM.RecreateMacro()
  if InCombatLockdown() then
    MM.dprint("Morphomatic: cannot (re)create macro in combat. Will retry after combat.")
    MM._macroNeedsRecreate = true
    return
  end

  -- Ensure the secure button exists and has its PreClick wired to PrepareButtonForRandomToy
  if not MM_SecureUse and MM.EnsureSecureButton then MM.EnsureSecureButton() end

  -- Build the exact working body. Keep LeftButton and append " 1" if ActionButtonUseKeyDown=1.
  local needsDown = (GetCVar("ActionButtonUseKeyDown") == "1")
  local body = string.format([[
#showtooltip
%s
/click MM_SecureUse LeftButton%s
]], MACRO_SIGNATURE, needsDown and " 1" or "")

  local idx = MM.FindMacroIndex()
  if idx > 0 then
    EditMacro(idx, MACRO_NAME, MACRO_ICON, body, 1, 1)
    MM.dprint("Morphomatic: macro updated.")
  else
    -- Try create as global; fallback to character if needed
    local created = CreateMacro(MACRO_NAME, MACRO_ICON, body, true) or CreateMacro(MACRO_NAME, MACRO_ICON, body, false)
    if created then
      MM.dprint("Morphomatic: macro created.")
    else
      MM.dprint("Morphomatic: failed to create macro.")
    end
  end
end

--- Debug helper: dump first line of the macro body
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
