-- Build eligible list and prepare secure use (no protected calls here)
MM = MM or {}

-- Returns a sorted array of eligible toy itemIDs
function MM.BuildEligibleIDs()
  local db, pool, out = MM.DB(), MM.BuildPool(), {}
  for id in pairs(pool) do
    if
      MM.PlayerHasToy(id)
      and (not db.skipOnCooldown or not MM.IsOnCooldown(id))
      and MM.IsUsable(id)
    then
      table.insert(out, id)
    end
  end
  table.sort(out)
  return out
end

-- Debug (counts + sample pick)
function MM.DebugDump()
  local all = MM.BuildEligibleIDs()
  MM.dprint("MM debug — eligible:", #all)
  local db, final = MM.DB(), {}
  for _, id in ipairs(all) do
    if db.enabledToys[id] ~= false then table.insert(final, id) end
  end
  MM.dprint("MM debug — after filters:", #final)
  if #final > 0 then
    local pick = final[math.random(#final)]
    local name = GetItemInfo(pick) or ("Toy " .. pick)
    local s, d = MM.GetCooldown(pick)
    MM.dprint(
      ("MM debug — pick=%d (%s), cd=%s, usable=%s"):format(
        pick,
        name,
        ((s > 0 and d > 0) and "yes" or "no"),
        tostring(MM.IsUsable(pick))
      )
    )
    local spell = GetItemSpell(pick)
    MM.dprint(
      ("MM debug — item=%s, spell=%s"):format(tostring(GetItemInfo(pick)), tostring(spell))
    )
  else
    MM.dprint("MM debug — final list empty (DB empty? all unchecked? cooldown? area restricted?)")
  end
end

-- randomizer.lua
function MM.DebugWhy()
  local db = MM.DB()
  local pool = MM.BuildPool()
  MM.dprint("MM why — analyzing toys in pool:")
  for id in pairs(pool) do
    local owned = MM.PlayerHasToy(id)
    local s, d = MM.GetCooldown(id)
    local oncd = (s > 0 and d > 0)
    local kept = (db.enabledToys[id] ~= false)
    local name = GetItemInfo(id) or ("Toy " .. id)
    MM.dprint(
      ("%d | %s | owned=%s | cd=%s | checked=%s"):format(
        id,
        name,
        tostring(owned),
        tostring(oncd),
        tostring(kept)
      )
    )
  end
end
