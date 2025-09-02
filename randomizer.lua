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

  -- 1) Try to resolve the localized ToyBox name (most reliable for /use item by name)
  local toyName
  if C_ToyBox and C_ToyBox.GetToyInfo then
    -- API signature differs across versions; one returns (name,...), another (itemID, name,...)
    local n1, _, _, _, n2 = C_ToyBox.GetToyInfo(pick)
    toyName = n1 or n2
  end

  -- 2) Fallback: regular item name (if the toy still exists as an item in bags)
  local itemName = GetItemInfo(pick)
  if (not itemName) and C_Item and C_Item.RequestLoadItemDataByID then
    C_Item.RequestLoadItemDataByID(pick)
    itemName = GetItemInfo(pick)
  end

  -- 3) Configure the secure button: type="item", and provide the most reliable identifier
  local btn = MM.EnsureSecureButton()
  btn:SetAttribute("type", "item")
  if toyName and #toyName > 0 then
    btn:SetAttribute("item", toyName)          -- preferred: ToyBox name
  elseif itemName and #itemName > 0 then
    btn:SetAttribute("item", itemName)         -- fallback: item name
  else
    btn:SetAttribute("item", "item:" .. pick)  -- last resort: itemID
  end

  print(("Morphomatic: prepared %s (%d)"):format(toyName or itemName or ("Toy "..pick), pick))
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
