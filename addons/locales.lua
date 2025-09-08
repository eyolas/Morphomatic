-- Morphomatic — locales.lua
-- Provides localized strings and a helper function MM.T

MM = MM or {}
MM.L = {}

local L = MM.L
local locale = GetLocale()

----------------------------------------------------------------------
-- Default (enUS)
----------------------------------------------------------------------
L["TITLE"] = "Morphomatic"
L["DESC"] =
  "Use the 'MM' macro or the floating button to trigger a random cosmetic toy from your Favorites."
L["FLOATING_BUTTON"] = "Floating Button"
L["SHOW_BUTTON"] = "Show floating button"
L["LOCK_BUTTON"] = "Lock button"
L["UNLOCK_BUTTON"] = "Unlock button"
L["BUTTON_SCALE"] = "Button scale"
L["RESET_POSITION"] = "Reset position"
L["MACRO_SECTION"] = "Macro"
L["AUTO_MACRO"] = "Auto-(re)create 'MM' macro at login"
L["MAKE_MACRO"] = "Create/Refresh macro now"
L["MACRO_NOTE"] = "Icon is set to Orb of Deception (1973)."
L["TOYS_SECTION"] = "Favorites Management"
L["SKIP_CD"] = "Skip toys on cooldown (runtime)"
L["HIDE_CD"] = "Hide toys on cooldown in list"
L["SELECT_ALL"] = "Select all favorites"
L["UNSELECT_ALL"] = "Unselect all favorites"
L["RESET_SELECTION"] = "Reset favorites"
L["FAVORITES_LABEL"] = "Favorites (from your curated toys):"

-- Tooltip-specific
L["TIP_CLICK"] = "Click: triggers a random cosmetic toy (from your selection)."
L["TIP_UNLOCK_TO_MOVE"] = "Unlock in Settings to move the button."
L["TIP_DRAG_TO_MOVE"] = "Unlocked: drag to move."
L["TIP_CLICKS_DISABLED"] = "Clicks are disabled while unlocked."
L["TIP_LOCK_TO_USE"] = "Lock it in Settings to use it again."

-- Minimap-specific
L["SHOW_MINIMAP"] = "Show minimap button"
L["OPTIONS_NOT_AVAILABLE"] = "Morphomatic: options not available."
L["MINIMAP_RIGHTCLICK"] = "Morphomatic: right-click reserved for future features."
L["MINIMAP_TIP_LEFT"] = "Left-click: open options"
L["MINIMAP_TIP_RIGHT"] = "Right-click: reserved"

----------------------------------------------------------------------
-- French (frFR)
----------------------------------------------------------------------
if locale == "frFR" then
  L["TITLE"] = "Morphomatic"
  L["DESC"] =
    "Utilisez la macro 'MM' ou le bouton flottant pour déclencher un jouet cosmétique aléatoire parmi vos Favoris."
  L["FLOATING_BUTTON"] = "Bouton flottant"
  L["SHOW_BUTTON"] = "Afficher le bouton flottant"
  L["LOCK_BUTTON"] = "Verrouiller le bouton"
  L["UNLOCK_BUTTON"] = "Déverrouiller le bouton"
  L["BUTTON_SCALE"] = "Taille du bouton"
  L["RESET_POSITION"] = "Réinitialiser la position"
  L["MACRO_SECTION"] = "Macro"
  L["AUTO_MACRO"] = "Créer/MàJ la macro 'MM' automatiquement au login"
  L["MAKE_MACRO"] = "Créer/MàJ la macro maintenant"
  L["MACRO_NOTE"] = "L’icône est définie sur l’Orbe de tromperie (1973)."
  L["TOYS_SECTION"] = "Gestion des Favoris"
  L["SKIP_CD"] = "Ignorer les jouets en recharge (en jeu)"
  L["HIDE_CD"] = "Masquer les jouets en recharge dans la liste"
  L["SELECT_ALL"] = "Tout sélectionner"
  L["UNSELECT_ALL"] = "Tout désélectionner"
  L["RESET_SELECTION"] = "Réinitialiser les favoris"
  L["FAVORITES_LABEL"] = "Favoris (parmi vos jouets disponibles) :"

  -- Tooltip-specific
  L["TIP_CLICK"] = "Clic : déclenche un jouet cosmétique aléatoire (parmi vos Favoris)."
  L["TIP_UNLOCK_TO_MOVE"] = "Déverrouillez-le dans les options pour déplacer le bouton."
  L["TIP_DRAG_TO_MOVE"] = "Déverrouillé : faites-le glisser pour le déplacer."
  L["TIP_CLICKS_DISABLED"] = "Les clics sont désactivés tant qu’il est déverrouillé."
  L["TIP_LOCK_TO_USE"] = "Verrouillez-le dans les options pour l’utiliser à nouveau."

  -- Minimap-specific
  L["SHOW_MINIMAP"] = "Afficher le bouton sur la mini-carte"
  L["OPTIONS_NOT_AVAILABLE"] = "Morphomatic : options indisponibles."
  L["MINIMAP_RIGHTCLICK"] = "Morphomatic : clic droit réservé à de futures fonctionnalités."
  L["MINIMAP_TIP_LEFT"] = "Clic gauche : ouvrir les options"
  L["MINIMAP_TIP_RIGHT"] = "Clic droit : réservé"
end

----------------------------------------------------------------------
-- Helper function (fallback to default string if missing)
----------------------------------------------------------------------
function MM.T(key, default) return L[key] or default or key end
