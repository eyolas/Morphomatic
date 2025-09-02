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
  if InCombatLockdown() then print("Morphomatic: cannot change toy during combat."); return end
  local db, candidates = MM.DB(), {}
  for _, id in ipairs(MM.BuildEligibleIDs()) do
    if db.enabledToys[id] ~= false then table.insert(candidates, id) end
  end
  if #candidates == 0 then print("Morphomatic: no eligible toys. Use /mm to configure."); return end
  local pick = candidates[math.random(#candidates)]
  local btn  = MM.EnsureSecureButton()
  btn:SetAttribute("type", "item")
  btn:SetAttribute("item", "item:" .. pick)
  local name = GetItemInfo(pick) or ("Toy "..pick)
  print(("Morphomatic: prepared %s (%d)"):format(name, pick))
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
  else
    print("MM debug — final list empty (DB empty? all unchecked? cooldown? area restricted?)")
  end
end
