-- Build eligible list and prepare secure use (no protected calls here)
MM = MM or {}

-- Returns a sorted array of eligible toy itemIDs
function MM.BuildEligibleIDs()
  local db, pool, out = MM.DB(), MM.BuildPool(), {}
  for id in pairs(pool) do
    if MM.PlayerHasToy(id)
      and (not db.skipOnCooldown or not MM.IsOnCooldown(id))
      and MM.IsUsable(id)
    then table.insert(out, id) end
  end
  table.sort(out)
  return out
end

-- Prepare the hidden secure button with a random eligible toy.
-- The macro or the floating button will then /click MM_SecureUse.
function MM.PrepareSecureUse()
  if InCombatLockdown() then
    print("Morphomatic: cannot change toy during combat.")
    return
  end

  local db = MM.DB()
  local candidates = {}
  for _, id in ipairs(MM.BuildEligibleIDs()) do
    if db.enabledToys[id] ~= false then
      table.insert(candidates, id)
    end
  end

  if #candidates == 0 then
    print("Morphomatic: no eligible toys. Use /mm to configure.")
    return
  end

  local pick = candidates[math.random(#candidates)]

  -- Try to resolve both the item name and its spell name
  local itemName = GetItemInfo(pick)
  if not itemName and C_Item and C_Item.RequestLoadItemDataByID then
    C_Item.RequestLoadItemDataByID(pick)
    itemName = GetItemInfo(pick)
  end

  local spellName = nil
  if GetItemSpell then
    spellName = GetItemSpell(pick) -- returns the spell name triggered by the item/toy
  end

  local btn = MM.EnsureSecureButton()

  -- Preferred: cast the toy's spell directly (some installs are stricter with items)
  if spellName and #spellName > 0 then
    -- Try secure spell cast first
    btn:SetAttribute("type", "spell")
    btn:SetAttribute("spell", spellName)
    print(("Morphomatic: prepared spell '%s' from %s (%d)"):format(
      spellName, itemName or ("Toy "..pick), pick))
    return
  end

  -- Fallbacks via macrotext
  local macrotext
  if itemName and #itemName > 0 then
    -- try spell-cast by name first (if spellName was nil but itemName exists, some UIs still resolve /cast <name>)
    macrotext = "/cast " .. itemName .. "\n"
    macrotext = macrotext .. "/use " .. itemName .. "\n"
  else
    macrotext = string.format("/use item:%d\n", pick)
  end

  btn:SetAttribute("type", "macro")
  btn:SetAttribute("macrotext", macrotext)

  print(("Morphomatic: prepared %s (%d) [macro fallback]"):format(
    itemName or ("Toy "..pick), pick))
end

-- Debug (counts + sample pick)
function MM.DebugDump()
  local all = MM.BuildEligibleIDs()
  print("MM debug — eligible:", #all)
  local db, final = MM.DB(), {}
  for _, id in ipairs(all) do if db.enabledToys[id] ~= false then table.insert(final, id) end end
  print("MM debug — after filters:", #final)
  if #final > 0 then
    local pick = final[math.random(#final)]
    local name = GetItemInfo(pick) or ("Toy "..pick)
    local s,d = MM.GetCooldown(pick)
    print(("MM debug — pick=%d (%s), cd=%s, usable=%s"):format(
      pick, name, ((s>0 and d>0) and "yes" or "no"), tostring(MM.IsUsable(pick))
    ))
    local spell = GetItemSpell(pick)
    print(("MM debug — item=%s, spell=%s"):format(tostring(GetItemInfo(pick)), tostring(spell)))
  else
    print("MM debug — final list empty (DB empty? all unchecked? cooldown? area restricted?)")
  end
end

-- randomizer.lua
function MM.DebugWhy()
  local db = MM.DB()
  local pool = MM.BuildPool()
  print("MM why — analyzing toys in pool:")
  for id in pairs(pool) do
    local owned  = MM.PlayerHasToy(id)
    local s,d    = MM.GetCooldown(id)
    local oncd   = (s>0 and d>0)
    local kept   = (db.enabledToys[id] ~= false)
    local name   = GetItemInfo(id) or ("Toy "..id)
    print(("%d | %s | owned=%s | cd=%s | checked=%s"):format(
      id, name, tostring(owned), tostring(oncd), tostring(kept)
    ))
  end
end
