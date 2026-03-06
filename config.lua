-----------------------------------
--       SIMPLE SCOREBOARD       --
-----------------------------------

Config = {}

-- Your server name (shown at top of scoreboard)
Config.ServerName = "YOUR SERVER NAME HERE"

-- Enable or disable the logo display
Config.EnableLogo = true

-- Logo URL (PNG/JPG). Can be a Discord CDN, Imgur, or your own web host.
-- Only used if EnableLogo is set to true.
Config.LogoURL = "https://example.com/yourlogo.png"

-- Default keybind to open scoreboard (players can still change it in GTA settings)
-- Use keys like: F9, F10, HOME, INSERT, etc.
Config.ToggleKey = "F9"

-- Maximum player capacity for your server
Config.MaxPlayers = 32

-- Highlight current player in scoreboard
Config.HighlightCurrentPlayer = true

-- Color for current player highlight (use hex color code)
Config.HighlightColor = "#E56B1F"

-- Player HUD toggle (bottom-right) to show local player summary
Config.EnablePlayerHud = true

-- HUD colors
Config.HudColors = {
    text = "#FAF6E9",                     -- Main HUD text
    background = "rgba(10, 14, 22, 0.88)", -- HUD card background
    border = "#E56B1F"                    -- Accent color for badges and outlines
}

-- Optional creator join message
Config.EnableCreatorMessage = true
Config.CreatorIdentifier = "license:YOUR_LICENSE_HERE"
Config.CreatorMessageSender = "^5simple_scoreboard^0"
Config.CreatorMessage = "^3The script creator/editor ^2NAME HERE ^3has joined the server!^0"

-----------------------------------
--      BADGER API SETTINGS      --
-----------------------------------

-- Enables department lookup from Badger API role data.
-- This integration is optional and safe to leave enabled.
Config.EnableBadgerApi = true

-- Badger Discord API resource name.
Config.BadgerResource = "Badger_Discord_API"

-- If true, server falls back to identifier matching when Badger is not available.
Config.EnableDepartmentFallback = true

-- Department definitions used for scoreboard and HUD "blips".
-- Put Discord role IDs in roles for each department.
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

-- Default department when no match is found.
Config.DefaultDepartment = {
    key = "unknown",
    label = "Unassigned",
    shortLabel = "N/A",
    color = "#8A8F98",
    icon = "dot"
}

-----------------------------------
--         COLOR SETTINGS        --
-----------------------------------

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
