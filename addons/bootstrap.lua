-- bootstrap.lua
local ADDON, ns = ...
ns = ns or {}           -- shared namespace across files
_G[ADDON] = ns          -- optional: expose globally for debugging

-- Create the WildAddon instance and store it in the namespace
local MM = LibStub('WildAddon-1.1'):NewAddon(ADDON, ns)
ns.MM = MM

-- (optional) global alias for convenience in the REPL
_G.MM = MM

MM._modules = {}
function MM:RegisterModule(name, mod) self._modules[name] = mod end
function MM:Module(name) return self._modules[name] end