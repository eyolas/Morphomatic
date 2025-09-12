-- SPDX-License-Identifier: MIT
-- Copyright (c) 2025 David Touzet

-- Morphomatic — addons/options.lua
-- Options panels (Sushi style) with 3 sections:
--   1) Floating Button
--   2) Macro
--   3) Favorites (skip CD at runtime, list filter, bulk actions, checklist)

local ADDON, ns = ...
local MM        = ns.MM
local Sushi     = LibStub('Sushi-3.2')
local L         = LibStub('AceLocale-3.0'):GetLocale('Morphomatic')

local ICON_PATH = 'Interface/AddOns/Morphomatic/images/morphomatic-small' -- change if you have another asset
local FOOTER    = '© 2025 David Touzet — MIT'

-- Module Options
local Options = MM:NewModule('Options', Sushi.OptionsGroup:NewClass())

----------------------------------------------------------------------
-- Helpers (data)
----------------------------------------------------------------------

-- Curated, owned toys (ignore cooldown)
local function buildOwnedList()
  local pool = MM.Helpers:BuildPool()
  local out = {}
  for id in pairs(pool) do
    if MM.Helpers:PlayerHasToy(id) then
      out[#out+1] = id
    end
  end
  table.sort(out)
  return out
end

-- List shown in UI (optionally hide those on cooldown)
local function buildListForUI()
  local db = MM.DB:Get()
  local owned = buildOwnedList()
  if db.listHideCooldown ~= true then return owned end

  local out = {}
  for _, id in ipairs(owned) do
    if not MM.Helpers:IsOnCooldown(id) then
      out[#out+1] = id
    end
  end
  return out
end

----------------------------------------------------------------------
-- Startup
----------------------------------------------------------------------

function Options:OnLoad()
  if self._loaded then return end
  self._loaded = true

  -- Root category (title with icon)
  local title = ICON_PATH and ('|T' .. ICON_PATH .. ':16:16:2:0|t  Morphomatic') or 'Morphomatic'

  self.Main = self(title)
    :SetSubtitle(L.DESC):SetFooter(FOOTER)
    :SetChildren(self.OnMain)

  self.Macro = self(self.Main, L.MACRO_SECTION)
    :SetSubtitle(L.MACRO_NOTE or '')
    :SetFooter(FOOTER)
    :SetChildren(self.OnMacro)

  self.Favorites = self(self.Main, L.TOYS_SECTION)
    :SetSubtitle(L.FAVORITES_LABEL or '')
    :SetFooter(FOOTER)
    :SetChildren(self.OnFavorites)
end

----------------------------------------------------------------------
-- Panels
----------------------------------------------------------------------

function Options:OnMain()
  local db = MM.DB:Get()
  db.button = db.button or {}

  -- -- Keybinding helper (optionnel)
  -- self:Add('RedButton', SETTINGS_KEYBINDINGS_LABEL)
  --   :SetKeys{top = -5, bottom = 15}
  --   :SetCall('OnClick', function()
  --     if SettingsPanel and SettingsPanel.keybindingsCategory then
  --       SettingsPanel:SelectCategory(SettingsPanel.keybindingsCategory)
  --     end
  --   end)

  self:AddHeader(L.FLOATING_BUTTON)

  -- Show/HIDE floating button
  self:Add('Check', L.SHOW_BUTTON)
    :SetChecked(db.showButton ~= false)
    :SetCall('OnInput', function(_, v)
      db.showButton = v and true or false
      if v then
        MM.FloatButton:Show()
      else
        MM.FloatButton:Hide()
      end
    end)

  -- Lock/Unlock + Scale + Reset sur la même ligne
  local lockBtn = self:Add('RedButton', db.button.locked and L.UNLOCK_BUTTON or L.LOCK_BUTTON)
    :SetWidth(150)
    :SetCall('OnClick', function(btn)
      db.button.locked = not db.button.locked
      MM:SendSignal('REFRESH_BUTTON_VISUAL')
      btn:SetText(db.button.locked and L.UNLOCK_BUTTON or L.LOCK_BUTTON)
    end)

  local s = self:Add('Slider', L.BUTTON_SCALE, db.button.scale or 1, 0.7, 1.8, 0.05)
    s:SetWidth(220)
    s:SetHeight(22)
    s:SetCall('OnInput', function(_, v)
      if not v or v == db.button.scale then return end
      db.button.scale = v
      MM:SendSignal('UPDATE_BUTTON_SCALE', v)
    end)
  -- s.top = -30 
  -- s.left = 180

  local resetBtn = self:Add('RedButton', L.RESET_POSITION)
    :SetWidth(150)
    :SetCall('OnClick', function()
      MM:SendSignal('RESET_BUTTON_ANCHOR')
    end)
  resetBtn.top = 10
  -- resetBtn.top = -26
  -- resetBtn.left = 180 + 220 + 20



  -- Minimap toggle (LibDBIcon)
  local isShown = not (db.minimap and db.minimap.hide)
  self:Add('Check', L.SHOW_MINIMAP)
    :SetChecked(isShown)
    :SetCall('OnInput', function(_, v)
      MM.Minimap:ToggleMinimap(v and true or false)
    end).top = 10
end

function Options:OnMacro()
  local db = MM.DB:Get()

  self:Add('Check', L.AUTO_MACRO)
    :SetChecked(db.autoCreateMacro ~= false)
    :SetCall('OnInput', function(_, v)
      db.autoCreateMacro = v and true or false
    end)

  self:Add('RedButton', L.MAKE_MACRO)
    :SetWidth(180)
    :SetCall('OnClick', function()
      if MM.Macro and MM.Macro.RecreateMacro then MM.Macro:RecreateMacro() end
    end).top = 10

end

function Options:OnFavorites()
  local db = MM.DB:Get()
  db.enabledToys = db.enabledToys or {}

  -- Runtime option: skip toys on cooldown when picking
  self:Add('Check', L.SKIP_CD)
    :SetChecked(db.skipOnCooldown and true or false)
    :SetCall('OnInput', function(_, v)
      db.skipOnCooldown = v and true or false
    end)

  -- Visual-only filter: hide cooldown toys in checklist
  self:Add('Check', L.HIDE_CD)
    :SetChecked(db.listHideCooldown == true)
    :SetCall('OnInput', function(_, v)
      db.listHideCooldown = v and true or false
      Options:RefreshFavoritesList()
    end)

  -- Bulk actions (same group)
  self:Add('RedButton', L.SELECT_ALL)
    :SetWidth(160)
    :SetCall('OnClick', function() Options:SelectAllToys() end).top = 10

  self:Add('RedButton', L.UNSELECT_ALL)
    :SetWidth(170)
    :SetCall('OnClick', function() Options:UnselectAllToys() end).left = 10

  self:Add('RedButton', L.RESET_SELECTION)
    :SetWidth(140)
    :SetCall('OnClick', function() Options:ResetSelection() end).left = 10

  -- Checklist label
  self:AddHeader(L.FAVORITES_LABEL)

  -- Build dynamic checklist (Sushi panel scrolls automatically)
  local list = buildListForUI()
  table.sort(list, function(a, b) return (C_Item.GetItemInfo(a) or '') < (C_Item.GetItemInfo(b) or '') end)

  for _, id in ipairs(list) do
    local name, _, _, _, _, _, _, _, _, icon = C_Item.GetItemInfo(id)
    name = name or ('Toy ' .. id)
    local label = ('|T%d:16|t %s (%d)'):format(icon or 134414, name, id)

    self:Add('Check', label)
      :SetChecked(db.enabledToys[id] ~= false)
      :SetCall('OnInput', function(_, v)
        db.enabledToys[id] = v and true or false
      end)
  end
end


----------------------------------------------------------------------
-- Bulk actions (apply to CURRENT LIST VIEW)
----------------------------------------------------------------------

function Options:SelectAllToys()
  local db = MM.DB:Get()
  db.enabledToys = db.enabledToys or {}
  for _, id in ipairs(buildListForUI()) do
    db.enabledToys[id] = true
  end
  MM.Helpers:dprint('Morphomatic: all favorites in the current view selected.')
  self:RefreshFavoritesList()
end

function Options:UnselectAllToys()
  local db = MM.DB:Get()
  db.enabledToys = db.enabledToys or {}
  for _, id in ipairs(buildListForUI()) do
    db.enabledToys[id] = false
  end
  MM.Helpers:dprint('Morphomatic: all favorites in the current view unselected.')
  self:RefreshFavoritesList()
end

function Options:ResetSelection()
  local db = MM.DB:Get()
  db.enabledToys = db.enabledToys or {}
  wipe(db.enabledToys)
  MM.Helpers:dprint('Morphomatic: favorites reset (all toys included by default).')
  self:RefreshFavoritesList()
end

-- Soft refresh of the Favorites panel (works across Sushi 3.2 variants)
function Options:RefreshFavoritesList()
  if self.Favorites and self.Favorites.Reshow then
    self.Favorites:Reshow()
  elseif self.Favorites and self.Favorites.Update then
    self.Favorites:Update()
  elseif self.Favorites and self.Favorites.SetChildren then
    -- force rebuild next time; immediate visual refresh depends on Sushi version
    self.Favorites:SetChildren(function() self:OnFavorites() end)
  end
end

----------------------------------------------------------------------
-- Small Sushi-style helpers (like Scrap)
----------------------------------------------------------------------

function Options:AddHeader(text)
  self:Add('Header', text, GameFontHighlight, true)
end

function Options:AddCheck(info)
  local db = MM.DB:Get()
  db.enabledToys = db.enabledToys or {}
  local b = self:Add('Check', L[info.text])
  b.left = b.left + (info.parent and 10 or 0)
  b:SetEnabled(not info.parent or db.enabledToys[info.parent])
  b:SetTip(L[info.text], L[info.text .. 'Tip'])
  b:SetChecked(db.enabledToys[info.set] ~= false)
  b:SetSmall(info.parent)
  b:SetCall('OnInput', function(b, v)
    db.enabledToys[info.set] = v and true or false
  end)
end