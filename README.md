# Simple Scoreboard

Lightweight FiveM scoreboard with a modern glass UI, player highlighting, optional logo, and a configurable always-on HUD for your own ID and name.

## Features
- Modern glassmorphism scoreboard with pagination (12 per page)
- Player highlight with custom color
- Optional server logo
- Always-on top-left HUD (ID + name) with configurable colors
- Keyboard and controller support (F9 / D-Pad Up by default)

## Quick Install
1) Drop the resource in `resources/`.
2) Add to `server.cfg`:
```
ensure simple_scoreboard
```
3) Edit `config.lua` to match your server.
4) Restart the resource or use `/refresh`.

## Key Configuration (config.lua)
```lua
-- Basic
Config.ServerName = "YOUR SERVER NAME HERE"
Config.ToggleKey = "F9"       -- Keyboard binding (players can change theirs)
Config.MaxPlayers = 32

-- Logo
Config.EnableLogo = true
Config.LogoURL = "https://example.com/yourlogo.png"

-- Player highlighting
Config.HighlightCurrentPlayer = true
Config.HighlightColor = "#6495FF"

-- Top-left HUD (ID + name)
Config.EnablePlayerHud = true
Config.HudColors = {
    text = "#FFFFFF",
    background = "rgba(20, 20, 40, 0.85)",
    border = "#6495FF"
}
```

### Full Color Control
Every UI color lives in `Config.Colors`:
```lua
Config.Colors = {
    primary = "#6495FF", primaryDark = "#4A6FA5",
    textWhite = "#FFFFFF", textAccent = "#A0B5FF",
    background = "#14142850", backgroundDark = "#0A0A1950",
    border = "#FFFFFF", borderOpacity = 0.1,
    headerBorder = "#6495FF", headerBorderOpacity = 0.4,
    playerRow = "#FFFFFF", playerRowLightOpacity = 0.03, playerRowDarkOpacity = 0.05,
    playerCountBg = "#6495FF", playerCountBgOpacity = 0.15,
    playerCountBorder = "#6495FF", playerCountBorderOpacity = 0.3,
    hoverBg = "#6495FF", hoverBgOpacity = 0.15,
    hoverBgDark = "#5078C8", hoverBgDarkOpacity = 0.15,
    logoGlow = "#6495FF", logoGlowOpacity = 0.3, logoGlowSize = "20px",
}
```

## How to Use
- Keyboard: press your configured key (default F9)
- Controller: D-Pad Up
- Scoreboard shows server name/logo, player count, IDs/names, highlight for you, and pagination if >12 players.
- HUD: enabled when `Config.EnablePlayerHud` is true; displays your ID and name in the top-left.

## Optional Server-Side Lists
`server.lua` can serve player lists/config from the server (disabled by default). Uncomment it in `fxmanifest.lua` and emit the provided events if you want server-driven data.

## Tips
- Keep text/background contrast high for readability.
- Use RGBA values for backgrounds when you want subtle transparency.
- Host your logo (PNG/JPG) on a reliable URL (Discord CDN/Imgur/self-host).

## Credits
Created by Ryan Bostaph.
