-- Morphomatic — addons/randomizer.lua
-- Build eligible list and prepare secure use (no protected calls here)

local ADDON, ns = ...
local MM = ns.MM
local Randomizer = MM:NewModule("Randomizer")
MM:RegisterModule("Randomizer", Randomizer)
function dump(o)
  if type(o) == "table" then
    local s = "{ "
    for k, v in pairs(o) do
      if type(k) ~= "number" then k = '"' .. k .. '"' end
      s = s .. "[" .. k .. "] = " .. dump(v) .. ","
    end
    return s .. "} "
  else
    return tostring(o)
  end
end

-- Returns a sorted array of eligible toy itemIDs
function Randomizer:BuildEligibleIDs()
  local db = MM.DB:Get()
  local pool, out = MM.Helpers:BuildPool(), {}
  for id in pairs(pool) do
    if
      MM.Helpers:PlayerHasToy(id)
      and (not db.skipOnCooldown or not MM.Helpers:IsOnCooldown(id))
      and MM.Helpers:IsUsable(id)
    then
      table.insert(out, id)
    end
  end
  table.sort(out)
  return out
end

-- Debug (counts + sample pick)
function Randomizer:DebugDump()
  local all = self:BuildEligibleIDs()
  MM.Helpers:dprint("MM debug — eligible:", #all)
  local db, final = MM.DB:Get(), {}
  for _, id in ipairs(all) do
    if db.enabledToys[id] ~= false then table.insert(final, id) end
  end
  MM.Helpers:dprint("MM debug — after filters:", #final)
  if #final > 0 then
    local pick = final[math.random(#final)]
    local name = GetItemInfo(pick) or ("Toy " .. pick)
    local s, d = MM.Helpers:GetCooldown(pick)
    MM.Helpers:dprint(
      ("MM debug — pick=%d (%s), cd=%s, usable=%s"):format(
        pick,
        name,
        ((s > 0 and d > 0) and "yes" or "no"),
        tostring(MM.Helpers:IsUsable(pick))
      )
    )
    local spell = GetItemSpell(pick)
    MM.Helpers:dprint(
      ("MM debug — item=%s, spell=%s"):format(tostring(GetItemInfo(pick)), tostring(spell))
    )
  else
    MM.Helpers:dprint(
      "MM debug — final list empty (DB empty? all unchecked? cooldown? area restricted?)"
    )
  end
end

-- Why (per-toy reasoning dump)
function Randomizer:DebugWhy()
  local db = MM.DB:Get()
  local pool = MM.Helpers:BuildPool()
  print("MM why — analyzing toys in pool:")
  for id in pairs(pool) do
    local owned = MM.Helpers:PlayerHasToy(id)
    local s, d = MM.Helpers:GetCooldown(id)
    local oncd = (s > 0 and d > 0)
    local kept = (db.enabledToys[id] ~= false)
    local name = GetItemInfo(id) or ("Toy " .. id)
    MM.Helpers:dprint(
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
