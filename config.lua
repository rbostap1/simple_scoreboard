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

-- 👤 Player HUD toggle (bottom-right) to show player's name + ID
-- Note: HUD displays as minimal text elements without background box or borders
Config.EnablePlayerHud = true

-- 🎨 HUD colors (only text colors are used, no background or border)
Config.HudColors = {
    text = "#FFFFFF",                 -- Text color for HUD labels
    border = "#6495FF"                -- Accent color for player count and ID
}

-----------------------------------
--       COLOR SETTINGS          --
-----------------------------------

-- 🎨 Comprehensive color and design customization
Config.Colors = {
    -- Primary colors
    primary = "#6495FF",           -- Primary accent color (buttons, highlights, borders)
    primaryDark = "#4A6FA5",       -- Darker variant for gradients
    
    -- Text colors
    textWhite = "#FFFFFF",         -- Main text color
    textAccent = "#A0B5FF",        -- Accent text (IDs, headers)
    textSecondary = "#8B9DC3",     -- Secondary text elements
    
    -- Background colors
    background = "rgba(18, 18, 35, 0.95)",      -- Main scoreboard background
    backgroundDark = "rgba(12, 12, 25, 0.98)",  -- Darker background gradient
    cardBg = "rgba(25, 25, 45, 0.6)",           -- Card/container backgrounds
    
    -- Border settings
    border = "#FFFFFF",            -- Border color
    borderOpacity = 0.08,          -- Border opacity (0-1)
    
    -- Header styling
    headerBorder = "#6495FF",      -- Header divider color
    headerBorderOpacity = 0.5,     -- Header border opacity (0-1)
    
    -- Player row colors
    playerRow = "#FFFFFF",         -- Player row base color
    playerRowLightOpacity = 0.04,  -- Light row opacity (0-1)
    playerRowDarkOpacity = 0.06,   -- Dark row opacity (0-1)
    
    -- Player count badge
    playerCountBg = "#6495FF",     -- Badge background color
    playerCountBgOpacity = 0.2,    -- Badge background opacity (0-1)
    playerCountBorder = "#6495FF", -- Badge border color
    playerCountBorderOpacity = 0.4,-- Badge border opacity (0-1)
    
    -- Hover effects
    hoverBg = "#6495FF",           -- Hover background color
    hoverBgOpacity = 0.2,          -- Hover opacity (0-1)
    hoverBgDark = "#5078C8",       -- Darker hover gradient
    hoverBgDarkOpacity = 0.2,      -- Darker hover opacity (0-1)
    
    -- Logo effects
    logoGlow = "#6495FF",          -- Logo glow color
    logoGlowOpacity = 0.4,         -- Logo glow opacity (0-1)
    logoGlowSize = "25px",         -- Logo glow spread size
    
    -- Shadow colors
    shadowColor = "rgba(0, 0, 0, 0.3)",      -- Standard shadow
    shadowStrong = "rgba(0, 0, 0, 0.5)",     -- Strong shadow for emphasis
}
