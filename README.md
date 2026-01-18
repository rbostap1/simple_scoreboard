# Simple Scoreboard

Lightweight FiveM scoreboard with a **modern card-based UI**, player highlighting, optional logo, and a configurable always-on HUD. Features server-side player list synchronization for accurate player counts and a completely redesigned visual experience.

## Features
- **🎨 Modern Card-Based UI** - Completely redesigned with a grid layout showcasing players in individual cards
- **🌟 Enhanced Glassmorphism Design** - Layered backgrounds, smooth animations, and modern styling
- **📊 Server-side Player List** - Accurate player counts and synchronization across all clients
- **👤 Player Highlighting** - Customizable highlight color with pulsing indicator for your player
- **🖼️ Optional Server Logo** - Display your server logo with animated hover effects
- **📱 Bottom-Right HUD** - Always-on HUD displaying your ID, name, and live player count (relocated from top-left)
- **🎮 Multi-Input Support** - Keyboard and controller support (F9 / D-Pad Up by default)
- **🎨 Full Color Customization** - Extensive color configuration for every UI element
- **💬 Creator Join Message** - Optional customizable message when the creator joins the server
- **🔄 Smooth Animations** - Polished transitions, hover effects, and responsive design

## Quick Install
1) Drop the resource in `resources/`.
2) Add to `server.cfg`:
```
ensure simple_scoreboard
```
3) Edit `config.lua` to match your server (server name, logo, colors, etc.).
4) **Important**: Ensure `server.lua` is enabled in `fxmanifest.lua` for server-side player synchronization.
5) Restart the resource or use `/refresh`.

## What's New in This Version
- **🎨 Complete UI Redesign**: Card-based grid layout replacing the old table view
- **📍 HUD Relocated**: Player HUD moved from top-left to bottom-right corner
- **✨ Enhanced Styling**: Modern glassmorphism with improved shadows, borders, and animations
- **🎯 Better Player Cards**: Individual cards with badges, rank indicators, and smooth hover effects
- **🎪 Logo Animations**: Interactive logo with hover effects and animated borders
- **🔧 Improved Configuration**: New color options including `textSecondary`, `cardBg`, `shadowColor`, and more
- **💬 Creator Messages**: Optional join message system with customizable text and colors
- **🐛 Debug Logging**: Enhanced console logging for better troubleshooting
 - **⏱️ Smarter HUD Refresh**: HUD updates on scoreboard changes, with a 5-minute fallback refresh

## Key Configuration (config.lua)
```lua
-- Basic Settings
Config.ServerName = "YOUR SERVER NAME HERE"
Config.ToggleKey = "F9"       -- Keyboard binding (players can change theirs)
Config.MaxPlayers = 32

-- Logo Settings
Config.EnableLogo = true
Config.LogoURL = "https://example.com/yourlogo.png"

-- Player Highlighting
Config.HighlightCurrentPlayer = true
Config.HighlightColor = "#6495FF"

-- Bottom-Right HUD (ID + name + player count)
Config.EnablePlayerHud = true
Config.HudColors = {
    text = "#FFFFFF",
    border = "#6495FF"  -- Accent color for player count and ID
}

-- Creator Join Message (NEW!)
Config.EnableCreatorMessage = true
Config.CreatorIdentifier = "license:YOUR_LICENSE_HERE"
Config.CreatorMessageSender = "^5simple_scoreboard^0"
Config.CreatorMessage = "^3The script creator/editor ^2NAME HERE ^3has joined the server!^0"
```

### Full Color Control
Every UI color lives in `Config.Colors` with expanded customization options:
```lua
Config.Colors = {
    -- Primary colors
    primary = "#6495FF",
    primaryDark = "#4A6FA5",
    
    -- Text colors
    textWhite = "#FFFFFF",
    textAccent = "#A0B5FF",
    textSecondary = "#8B9DC3",  -- NEW: Secondary text elements
    
    -- Background colors (with alpha transparency)
    background = "rgba(18, 18, 35, 0.95)",
    backgroundDark = "rgba(12, 12, 25, 0.98)",
    cardBg = "rgba(25, 25, 45, 0.6)",  -- NEW: Individual card backgrounds
    
    -- Border settings
    border = "#FFFFFF",
    borderOpacity = 0.08,
    headerBorder = "#6495FF",
    headerBorderOpacity = 0.5,
    
    -- Player card styling
    playerRow = "#FFFFFF",
    playerRowLightOpacity = 0.04,
    playerRowDarkOpacity = 0.06,
    
    -- Player count badge
    playerCountBg = "#6495FF",
    playerCountBgOpacity = 0.2,
    playerCountBorder = "#6495FF",
    playerCountBorderOpacity = 0.4,
    
    -- Hover effects
    hoverBg = "#6495FF",
    hoverBgOpacity = 0.2,
    hoverBgDark = "#5078C8",
    hoverBgDarkOpacity = 0.2,
    
    -- Logo effects
    logoGlow = "#6495FF",
    logoGlowOpacity = 0.4,
    logoGlowSize = "25px",
    
    -- Shadow effects (NEW!)
    shadowColor = "rgba(0, 0, 0, 0.3)",
    shadowStrong = "rgba(0, 0, 0, 0.5)",
}
```

## How to Use
- **Keyboard**: Press your configured key (default F9)
- **Controller**: D-Pad Up (INPUT_FRONTEND_UP)
- **Scoreboard Display**: 
  - Modern card-based grid layout (2 columns)
  - Server name/logo in enhanced hero section
  - Live player count badge
  - Individual player cards with ID badges
  - Smooth pagination for more than 12 players
  - Your player card highlighted with pulsing indicator
- **HUD**: Enabled when `Config.EnablePlayerHud` is true
  - Displays in **bottom-right corner** (new location!)
  - Shows your ID, name, and live player count
  - Glassmorphism design with hover effects
  - Auto-refreshes on scoreboard updates; 5-minute fallback refresh

## Server-Side Player List
The scoreboard and HUD use server-side player lists for accurate synchronization:
- `server.lua` is **required** and must be enabled in `fxmanifest.lua`
- Server builds and sends the player list on every request
- Ensures all clients see the same accurate player count
 - HUD refreshes on scoreboard updates; 5-minute fallback refresh
- Player data includes ID and name for each connected player
- Enhanced with debug logging for troubleshooting

### Server Events
The server script registers three main events:
- `simple_scoreboard:requestPlayers` - Returns player list only
- `simple_scoreboard:requestConfig` - Returns config data only  
- `simple_scoreboard:requestScoreboardData` - Returns both players and config

## Creator Join Message System
New optional feature to announce when the script creator/editor joins:
- Enable/disable via `Config.EnableCreatorMessage`
- Set your license identifier in `Config.CreatorIdentifier`
- Customize message sender name and message text with color codes
- Automatically detects creator join/leave
- Only shows message once per session

## Design Highlights
- **Card-Based Layout**: Players displayed in modern, individual cards rather than table rows
- **Enhanced Glassmorphism**: Layered backgrounds with blur effects and gradient overlays
- **Smooth Animations**: Slide-in entrance, hover effects, and pulsing indicators
- **Responsive Design**: Cards scale and animate on hover with smooth transitions
- **Modern Typography**: Mix of Inter, system fonts, and monospace for IDs
- **Advanced Shadows**: Multi-layered shadows for depth and emphasis
- **Interactive Elements**: Logos and buttons with hover animations and state changes

## Tips
- **Visual Design**: Keep text/background contrast high for readability
- **Transparency**: Use RGBA values in `Config.Colors` for subtle transparency effects
- **Logo Hosting**: Host your logo (PNG/JPG) on a reliable URL (Discord CDN/Imgur/self-host)
- **Color Customization**: Experiment with the new `textSecondary`, `cardBg`, and shadow colors
- **Performance**: The card layout is optimized with CSS transforms for smooth animations
- **HUD Positioning**: HUD now appears in bottom-right; adjust CSS if you prefer a different location
- **Creator Message**: Remember to set your actual license identifier in the config

## Troubleshooting
- **No players showing**: Ensure `server.lua` is enabled in `fxmanifest.lua`
- **HUD not appearing**: Check that `Config.EnablePlayerHud = true`
- **Console errors**: Check browser console (F8) for detailed debug messages
- **Creator message not working**: Verify your license identifier format matches exactly

## Credits
Created by Ryan Bostaph.
