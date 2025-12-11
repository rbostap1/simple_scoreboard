# Simple Scoreboard

A lightweight, highly customizable FiveM scoreboard script that displays active players on your server. This script features a modern glassmorphism design with extensive color customization, player highlighting, and pagination support for servers with many players.

## 🎯 Features

- **Modern UI Design** - Sleek glassmorphism style with smooth animations
- **Player List Display** - Shows player IDs and names with pagination support
- **Current Player Highlighting** - Automatically highlights your player's row with customizable colors
- **Logo Support** - Display your server logo with optional enable/disable toggle
- **Complete Color Control** - Customize every color element in the scoreboard
- **Responsive Design** - Adapts to different player counts and screen sizes
- **Keyboard & Controller Support** - Works with both keyboard (F9 default) and controller (D-Pad Up)

## 📋 Configuration

All settings are configured in `config.lua`. Below is a complete guide to all available options.

### Basic Settings

```lua
-- Your server name displayed at the top of the scoreboard
Config.ServerName = "YOUR SERVER NAME HERE"

-- Default keybind to open/close scoreboard
-- Players can change this in their GTA settings
-- Options: F9, F10, HOME, INSERT, etc.
Config.ToggleKey = "F9"

-- Maximum player capacity for your server
Config.MaxPlayers = 32
```

### Logo Configuration

```lua
-- Enable or disable logo display
Config.EnableLogo = true

-- Logo URL (PNG/JPG)
-- Can use Discord CDN, Imgur, or your own web host
-- Only used if EnableLogo is set to true
Config.LogoURL = "https://example.com/yourlogo.png"
```

### Player Highlighting

```lua
-- Enable highlighting for the current player's row
Config.HighlightCurrentPlayer = true

-- Color for the current player highlight (hex color code)
Config.HighlightColor = "#6495FF"
```

### Complete Color Customization

The `Config.Colors` table allows you to customize every color in the scoreboard:

```lua
Config.Colors = {
    -- Primary accent colors
    primary = "#6495FF",           -- Main accent color (blue)
    primaryDark = "#4A6FA5",       -- Darker accent variant
    
    -- Text colors
    textWhite = "#FFFFFF",         -- Main text color
    textAccent = "#A0B5FF",        -- Headers, IDs, and accent text
    
    -- Background colors
    background = "#14142850",      -- Main scoreboard background
    backgroundDark = "#0A0A1950",  -- Darker background layer
    
    -- Border colors
    border = "#FFFFFF",            -- Main border color
    borderOpacity = 0.1,           -- Border transparency (0-1)
    
    -- Header divider
    headerBorder = "#6495FF",      -- Header bottom border color
    headerBorderOpacity = 0.4,     -- Header border transparency (0-1)
    
    -- Player row colors
    playerRow = "#FFFFFF",         -- Player row background
    playerRowLightOpacity = 0.03,  -- Light row opacity (0-1)
    playerRowDarkOpacity = 0.05,   -- Dark row opacity (0-1)
    
    -- Player count display box
    playerCountBg = "#6495FF",     -- Background color
    playerCountBgOpacity = 0.15,   -- Background transparency (0-1)
    playerCountBorder = "#6495FF", -- Border color
    playerCountBorderOpacity = 0.3,-- Border transparency (0-1)
    
    -- Hover effects
    hoverBg = "#6495FF",           -- Hover background color
    hoverBgOpacity = 0.15,         -- Hover transparency (0-1)
    hoverBgDark = "#5078C8",       -- Darker hover color
    hoverBgDarkOpacity = 0.15,     -- Darker hover transparency (0-1)
    
    -- Logo styling
    logoGlow = "#6495FF",          -- Logo glow effect color
    logoGlowOpacity = 0.3,         -- Glow transparency (0-1)
    logoGlowSize = "20px",         -- Glow effect size
}
```

## 🎨 Customization Examples

### Red Theme
```lua
Config.Colors = {
    primary = "#FF6B6B",
    primaryDark = "#CC5555",
    headerBorder = "#FF6B6B",
    playerCountBg = "#FF6B6B",
    playerCountBorder = "#FF6B6B",
    hoverBg = "#FF6B6B",
    hoverBgDark = "#CC5555",
    logoGlow = "#FF6B6B",
    -- Keep other colors as default or customize further
}
```

### Purple Theme
```lua
Config.Colors = {
    primary = "#9D4EDD",
    primaryDark = "#7A3FA3",
    textAccent = "#E0AAFF",
    headerBorder = "#9D4EDD",
    playerCountBg = "#9D4EDD",
    playerCountBorder = "#9D4EDD",
    hoverBg = "#9D4EDD",
    hoverBgDark = "#7A3FA3",
    logoGlow = "#9D4EDD",
}
```

### Green Theme
```lua
Config.Colors = {
    primary = "#2DB87D",
    primaryDark = "#1F8A5F",
    textAccent = "#4DECAC",
    headerBorder = "#2DB87D",
    playerCountBg = "#2DB87D",
    playerCountBorder = "#2DB87D",
    hoverBg = "#2DB87D",
    hoverBgDark = "#1F8A5F",
    logoGlow = "#2DB87D",
}
```

## 🎮 Usage

### Opening the Scoreboard

**Keyboard:** Press `F9` (or your configured key)

**Controller:** Press D-Pad Up

The scoreboard will appear at the top center of your screen showing:
- Your server name with logo (if enabled)
- Current player count and max capacity
- List of active players with their IDs
- Your player row highlighted (if enabled)
- Pagination controls (if more than 12 players)

### Navigation

- **Previous Button** - Go to previous page of players
- **Next Button** - Go to next page of players
- **Page Indicator** - Shows current page number

## 📦 Installation

1. Ensure this resource is in your `resources` folder
2. Add to your `server.cfg`:
   ```
   ensure simple_scoreboard
   ```
3. Customize `config.lua` with your server settings
4. Restart your server or use `/refresh` command

## 🔧 Optional Server File

The `server.lua` file is optional and not used by default. It's included if you prefer server-side player list management in the future. By default, it's commented out in `fxmanifest.lua`.

## 📝 Color Reference

When customizing colors, you can use:
- **Hex colors**: `#RRGGBB` format (e.g., `#FF0000` for red)
- **Opacity**: Values from `0` (transparent) to `1` (opaque)

### Common Hex Colors
- Blue: `#0066FF`, `#6495FF`
- Red: `#FF0000`, `#FF6B6B`
- Green: `#00FF00`, `#2DB87D`
- Purple: `#9D4EDD`, `#7A3FA3`
- Orange: `#FF8C00`, `#FFA500`
- Pink: `#FF1493`, `#FF69B4`

## 🎯 Tips & Tricks

1. **Keep Readability** - Ensure good contrast between text and background colors
2. **Match Your Brand** - Use your server's primary colors throughout
3. **Test Thoroughly** - Preview your color changes in-game before deploying
4. **Opacity Balance** - Use opacity to create layered, professional-looking designs
5. **Logo Sizing** - Keep logo URL accessible and in PNG/JPG format

## 📄 License

This project is provided as-is for use on FiveM servers.

## 👏 Credits

**Script Creator:** Ryan Bostaph
