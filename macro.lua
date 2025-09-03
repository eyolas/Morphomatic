-- Morphomatic — macro.lua
-- Creates/updates a macro identified by a signature in its body.
-- The macro just clicks the secure button; MM_SecureUse.PreClick prepares the toy.

MM = MM or {}

local MACRO_SIGNATURE = "# Morphomatic macro"
local MACRO_NAME      = "Morphomatic" -- user-facing macro name
local MACRO_ICON      = GetItemIcon(1973) or "INV_Misc_QuestionMark" -- Orb of Deception icon

--- Find the index of the Morphomatic macro by signature
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

  -- Ensure the secure button exists (and has PreClick wired to PrepareButtonForRandomToy)
  if MM.EnsureSecureButton then MM.EnsureSecureButton() end

  -- Minimal macro body: rely on MM_SecureUse.PreClick for preparation.
  -- IMPORTANT: explicitly pass LeftButton to /click.
  local body = string.format([[
#showtooltip
%s
/click MM_SecureUse LeftButton
]], MACRO_SIGNATURE)

  local idx = MM.FindMacroIndex()
  if idx > 0 then
    EditMacro(idx, MACRO_NAME, MACRO_ICON, body, 1, 1)
    MM.dprint("Morphomatic: macro updated.")
  else
    local created = CreateMacro(MACRO_NAME, MACRO_ICON, body, true)
    if created then
      MM.dprint("Morphomatic: macro created.")
    else
      MM.dprint("Morphomatic: failed to create macro.")
    end
  end
end

--- Debug helper
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
