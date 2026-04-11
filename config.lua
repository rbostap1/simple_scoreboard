--------------------------------------
---  Nova Scoreboard Configuration ---
--------------------------------------

Config = {}

-- Basic settings
Config.ServerName = "Nova Scoreboard"
Config.EnableLogo = true
-- Used only when EnableLogo is true.
Config.LogoURL = "https://example.com/yourlogo.png"
-- Default keybind (players can still remap this in GTA settings).
Config.ToggleKey = "F9"
Config.MaxPlayers = 32
Config.HighlightCurrentPlayer = true
-- Hex color used when HighlightCurrentPlayer is true.
Config.HighlightColor = "#E56B1F"

-- Optional creator join message
-- Set CreatorIdentifier to a real identifier (for example: license:abc123...).
Config.EnableCreatorMessage = true
Config.CreatorIdentifier = "license:YOUR_LICENSE_HERE"
Config.CreatorMessageSender = "^5Nova Scoreboard^0"
Config.CreatorMessage = "^3The script creator/editor ^2NAME HERE ^3has joined the server!^0"

-- Department integration settings

-- Enable role lookup via Badger_Discord_API.
Config.EnableBadgerApi = true
Config.BadgerResource = "Badger_Discord_API"

-- If true, use fallback keyword matching when Badger data is unavailable.
Config.EnableDepartmentFallback = true

-- If true, departments only show when player is marked active/on-duty.
-- Set this from your duty script using:
-- TriggerServerEvent("nova_scoreboard:setActiveDepartment", "police")
-- TriggerServerEvent("nova_scoreboard:setActiveDepartment", nil)
Config.RequireActiveDepartment = true

-- Optional duty-state resource used for automatic active department checks.
Config.BadgerActivityResource = "Badger_PoliceEMSActivity"

-- Department definitions
-- Replace ROLE_ID_* values with your real Discord role IDs.
Config.Departments = {
    {
        key = "police",
        label = "Law Enforcement",
        shortLabel = "LEO",
        color = "#3A86FF",
        icon = "shield",
        roles = { "ROLE_ID_POLICE" },
        fallbackKeywords = { "lspd", "sasp", "bcso", "police", "sheriff", "state" }
    },
    {
        key = "ems",
        label = "Medical",
        shortLabel = "EMS",
        color = "#2EC27E",
        icon = "plus",
        roles = { "ROLE_ID_EMS" },
        fallbackKeywords = { "ems", "medic", "doctor", "ambulance" }
    },
    {
        key = "fire",
        label = "Fire",
        shortLabel = "FIRE",
        color = "#F76C5E",
        icon = "flame",
        roles = { "ROLE_ID_FIRE" },
        fallbackKeywords = { "fire", "fd", "firefighter" }
    },
    {
        key = "civ",
        label = "Civilian",
        shortLabel = "CIV",
        color = "#B8A168",
        icon = "user",
        roles = { "ROLE_ID_CIV" },
        fallbackKeywords = { "civ", "civilian" }
    }
}

-- Default department when no role/keyword/activity match is found.
Config.DefaultDepartment = {
    key = "civ",
    label = "Civilian",
    shortLabel = "CIV",
    color = "#B8A168",
    icon = "user"
}

-- UI colors
Config.Colors = {
    -- Main palette
    primary = "#E56B1F",
    primaryDark = "#A64619",
    secondary = "#1A2E45",

    -- Text colors
    textWhite = "#FAF6E9",
    textAccent = "#FFC88E",
    textSecondary = "#C3B9A8",

    -- Backgrounds
    background = "rgba(9, 13, 20, 0.94)",
    backgroundDark = "rgba(5, 8, 13, 0.98)",
    cardBg = "rgba(18, 24, 35, 0.82)",

    -- Borders
    border = "#F1D3A1",
    borderOpacity = 0.08,
    headerBorder = "#E56B1F",
    headerBorderOpacity = 0.45,

    -- Rows/cards
    playerRow = "#FAF6E9",
    playerRowLightOpacity = 0.03,
    playerRowDarkOpacity = 0.08,

    -- Counter badge
    playerCountBg = "#E56B1F",
    playerCountBgOpacity = 0.22,
    playerCountBorder = "#FFC88E",
    playerCountBorderOpacity = 0.45,

    -- Hover effects
    hoverBg = "#E56B1F",
    hoverBgOpacity = 0.16,
    hoverBgDark = "#A64619",
    hoverBgDarkOpacity = 0.18,

    -- Logo glow
    logoGlow = "#E56B1F",
    logoGlowOpacity = 0.35,
    logoGlowSize = "20px",

    -- Shadows
    shadowColor = "rgba(0, 0, 0, 0.35)",
    shadowStrong = "rgba(0, 0, 0, 0.62)",
}
