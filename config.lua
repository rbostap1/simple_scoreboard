-----------------------------------
--       SIMPLE SCOREBOARD       --
-----------------------------------

Config = {}

-- 🏷 Your server name (shown at top of scoreboard)
Config.ServerName = "YOUR SERVER NAME HERE"

-- 🖼 Enable or disable the logo display
Config.EnableLogo = true

-- 🖼 Logo URL (PNG/JPG). Can be a Discord CDN, Imgur, or your own web host.
-- Only used if EnableLogo is set to true.
Config.LogoURL = "https://example.com/yourlogo.png"

-- ⌨️ Default keybind to open scoreboard (players can still change it in GTA settings)
-- Use keys like: F9, F10, HOME, INSERT, etc.
Config.ToggleKey = "F9"

-- 👥 Maximum player capacity for your server
Config.MaxPlayers = 32

-- 🏄 Highlight current player in scoreboard
Config.HighlightCurrentPlayer = true

-- 🎨 Color for current player highlight (use hex color code)
Config.HighlightColor = "#6495FF"

-----------------------------------
--       COLOR SETTINGS          --
-----------------------------------

-- 🎨 Primary accent color (used for borders, highlights, glows)
Config.Colors = {
    primary = "#6495FF",           -- Primary blue accent color
    primaryDark = "#4A6FA5",       -- Darker variant of primary
    
    textWhite = "#FFFFFF",         -- Main text color
    textAccent = "#A0B5FF",        -- Accent text color (ID, headers)
    
    background = "#14142850",      -- Main scoreboard background (dark blue/purple)
    backgroundDark = "#0A0A1950",  -- Darker background layer
    
    border = "#FFFFFF",            -- Border color
    borderOpacity = 0.1,           -- Border opacity (0-1)
    
    headerBorder = "#6495FF",      -- Header bottom border color
    headerBorderOpacity = 0.4,     -- Header border opacity (0-1)
    
    playerRow = "#FFFFFF",         -- Player row background color
    playerRowLightOpacity = 0.03,  -- Light player row opacity (0-1)
    playerRowDarkOpacity = 0.05,   -- Dark player row opacity (0-1)
    
    playerCountBg = "#6495FF",     -- Player count background
    playerCountBgOpacity = 0.15,   -- Player count background opacity (0-1)
    playerCountBorder = "#6495FF", -- Player count border
    playerCountBorderOpacity = 0.3,-- Player count border opacity (0-1)
    
    hoverBg = "#6495FF",           -- Hover background color
    hoverBgOpacity = 0.15,         -- Hover background opacity (0-1)
    hoverBgDark = "#5078C8",       -- Darker hover color
    hoverBgDarkOpacity = 0.15,     -- Darker hover opacity (0-1)
    
    logoGlow = "#6495FF",          -- Logo glow effect color
    logoGlowOpacity = 0.3,         -- Logo glow opacity (0-1)
    logoGlowSize = "20px",         -- Logo glow size
}
