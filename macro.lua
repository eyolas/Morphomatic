-- Morphomatic — macro.lua
-- Logic for creating and refreshing the "MM" macro

MM = MM or {}

--- Create or refresh the "MM" macro with Orb of Deception icon
function MM.RecreateMacro()
  if InCombatLockdown() then
    MM.dprint("Morphomatic: cannot (re)create macro in combat. Will retry after combat.")
    MM._macroNeedsRecreate = true
    return
  end

  -- Ensure the secure button exists before wiring the macro
  if not MM_SecureUse and MM.EnsureSecureButton then MM.EnsureSecureButton() end

  local name = "MM"
  local icon = GetItemIcon and GetItemIcon(1973) or "INV_Misc_QuestionMark" -- Orb of Deception
  local needsDown = (GetCVar("ActionButtonUseKeyDown") == "1")
  local body = "#showtooltip\n/click MM_SecureUse LeftButton" .. (needsDown and " 1" or "")

  local idx = GetMacroIndexByName(name)
  if idx > 0 then
    EditMacro(idx, name, icon, body)
    MM.dprint("Morphomatic: macro 'MM' updated.")
  else
    local id = CreateMacro(name, icon, body, true) or CreateMacro(name, icon, body, false)
    if id then
      MM.dprint("Morphomatic: macro 'MM' created.")
    else
      MM.dprint("Morphomatic: failed to create macro.")
    end
  end
end
