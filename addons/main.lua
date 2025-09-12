-- Morphomatic — bootstrap_wildaddon.lua
-- Main bootstrap rewritten to use WildAddon (without StaleCheck)

local ADDON, ns = ...
local MM = ns.MM

----------------------------------------------------------------------
-- Utilities (instance methods of WildAddon)
----------------------------------------------------------------------

-- Open the options panel (new Settings API or legacy fallback)
function MM:OpenOptions()
  if Settings and Settings.OpenToCategory and self._optionsCategory then
    Settings:OpenToCategory(self._optionsCategory.ID or self._optionsCategory)
  elseif InterfaceOptionsFrame then
    -- Legacy fallback requires a double call to focus the panel
    InterfaceOptionsFrame_OpenToCategory("Morphomatic")
    InterfaceOptionsFrame_OpenToCategory("Morphomatic")
  end
end

-- Run a function with temporary debug enabled, then restore state
function MM:_WithTempDebug(fn)
  local was = self.Helpers:IsDebug() or false
  self.Helpers:SetDebug(true)
  local ok, err = pcall(fn)
  if not was and self.Helpers.SetDebug then self.Helpers:SetDebug(false) end
  if not ok and err then print(err) end
end

----------------------------------------------------------------------
-- WildAddon lifecycle
-- OnEnable is called when the addon is ready
-- We use WildAddon’s event handling instead of manual frame:SetScript
----------------------------------------------------------------------

function MM:OnLoad()
  self.Helpers:dprint("Morphomatic: OnLoad")
   -- Register events here
  self:RegisterEvent("PLAYER_REGEN_ENABLED", "OnPlayerRegenEnabled")
  self:RegisterEvent("TOYS_UPDATED", "OnToysUpdated")

  -- Setup /mm slash
  self:_SetupSlash()

  -- Init DB and options
  local db = self.DB:Get()
  self.Settings:OptionsRegister()
  self.Settings:OptionsRefresh()
  self.Minimap:RegisterMinimap()

  if IsLoggedIn() then
    self:OnPlayerLogin("PLAYER_LOGIN")
  else
    self:RegisterEvent("PLAYER_LOGIN", function(_, event, ...) self:OnPlayerLogin(event, ...) end)
  end
end

----------------------------------------------------------------------
-- Event handlers
----------------------------------------------------------------------

function MM:OnPlayerLogin()
  self.Helpers:dprint("OnPlayerLogin")
  self.Helpers:SeedRNG()
  self.Helpers:EnsureSecureButton()

  local db = self.DB:Get()
  self.Helpers:dprint(dump(db))
  if db.showButton ~= false then
    MM.FloatButton:Show()
  else
    MM.FloatButton:Hide()
  end
  MM.FloatButton:RefreshLockVisual()
  -- if self.RefreshButtonLockVisual then self:RefreshButtonLockVisual() end

  if db.autoCreateMacro ~= false then
    self.Macro:RecreateMacro()
  end
end

function MM:OnPlayerRegenEnabled()
  self.Helpers:dprint("OnPlayerRegenEnabled")
  -- Out of combat, recreate macro if flagged
  if self._macroNeedsRecreate then
    self._macroNeedsRecreate = nil
    self.Macro:RecreateMacro()
  end
end

function MM:OnToysUpdated()
  self.Helpers:dprint("OnToysUpdated")
  -- Toys updated → refresh options if registered
  self.Settings:OptionsRefresh()
end

----------------------------------------------------------------------
-- Slash commands: /mm <subcommand>
----------------------------------------------------------------------

function MM:_SetupSlash()
  SLASH_MORPHOMATIC1 = "/mm"
  SlashCmdList.MORPHOMATIC = function(msg)
    local args = {}
    for w in string.gmatch(msg or "", "%S+") do
      table.insert(args, w)
    end
    local cmd = (args[1] or ""):lower()

    -- Default = help
    if cmd == "" or cmd == "help" then
      print("Morphomatic — commands:")
      print("  /mm options                     : open settings")
      print("  /mm dump [key|all]              : dump saved variables (MorphomaticDB)")
      print("  /mm save                        : force SaveVariables('MorphomaticDB')")
      print("  /mm probe                       : inspect secure button and macro")
      print("  /mm macro recreate              : (re)create the 'MM' macro")
      print("  /mm debug on|off                : enable/disable persistent debug logs")
      return
    end

    -- options / opt
    if cmd == "options" or cmd == "opt" then
      self:OpenOptions()
      return
    end

    -- debug on|off (persistent toggle)
    if cmd == "debug" then
      local arg = (args[2] or ""):lower()
      if (arg == "on" or arg == "off") and self.Helpers.SetDebug and self.Helpers.IsDebug then
        self.Helpers:SetDebug(arg == "on")
        print("Morphomatic: debug =", tostring(self.Helpers:IsDebug()))
      else
        local cur = self.Helpers:IsDebug()
        print("Usage: /mm debug on|off  (current:", tostring(cur), ")")
      end
      return
    end

    -- dump (TEMP debug ON)
    if cmd == "dump" then
      self:_WithTempDebug(function()
        local key = args[2]
        if not MorphomaticDB then
          self.Helpers:dprint("Morphomatic: no saved variables found.")
          return
        end
        if not key or key:lower() == "all" then
          if DevTools_Dump then
            DevTools_Dump(MorphomaticDB)
          else
            self.Helpers:dprint("MorphomaticDB:")
            for k, v in pairs(MorphomaticDB) do
              self.Helpers:dprint(" ", k, "=", type(v) == "table" and "table" or tostring(v))
            end
          end
          return
        end
        if MorphomaticDB[key] ~= nil then
          if DevTools_Dump then
            DevTools_Dump(MorphomaticDB[key])
          else
            self.Helpers:dprint("MorphomaticDB." .. key .. ":")
            if type(MorphomaticDB[key]) == "table" then
              for k2, v2 in pairs(MorphomaticDB[key]) do
                self.Helpers:dprint("   ", k2, "=", tostring(v2))
              end
            else
              self.Helpers:dprint("   ", tostring(MorphomaticDB[key]))
            end
          end
        else
          self.Helpers:dprint("Morphomatic: key not found in DB ->", key)
        end
      end)
      return
    end

    -- save (TEMP debug ON)
    if cmd == "save" then
      self:_WithTempDebug(function()
        SaveVariables("MorphomaticDB")
        self.Helpers:dprint("Morphomatic: variables saved to disk.")
      end)
      return
    end

    -- probe (TEMP debug ON)
    if cmd == "probe" then
      self:_WithTempDebug(function()
        local b = _G.MM_SecureUseButton
        self.Helpers:dprint("MM probe — button:", b and b:GetName() or "nil")
        if b then
          self.Helpers:dprint("  IsObjectType(Button) =", b:IsObjectType("Button"))
          self.Helpers:dprint("  type attr            =", tostring(b:GetAttribute("type")))
          self.Helpers:dprint("  item attr            =", tostring(b:GetAttribute("item")))
          local mt = b:GetAttribute("macrotext")
          self.Helpers:dprint("  macrotext len        =", mt and #mt or 0)
        end

        local idx = self.FindMacroIndex and self:FindMacroIndex() or 0
        self.Helpers:dprint("  Morphomatic macro index =", idx)
        if idx > 0 then
          local body = GetMacroBody(idx) or ""
          self.Helpers:dprint("  macro body first line:", body:match("([^\n\r]*)") or "")
        end
      end)
      return
    end

    -- macro recreate (does NOT change debug state)
    if cmd == "macro" then
      local sub = (args[2] or ""):lower()
      if sub == "recreate" and self.RecreateMacro then
        self:RecreateMacro()
        return
      end
      print("Usage: /mm macro recreate")
      return
    end

    print("Morphomatic: unknown command. Try /mm help")
  end
end
