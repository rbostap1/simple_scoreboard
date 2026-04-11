# Simple Scoreboard

A lightweight FiveM scoreboard with a full visual redesign, optional Badger API integration, and department blips for each player.

## Recent Updates
- Complete scoreboard redesign with a glass-style layout, stronger typography, and modern player cards.
- Player HUD removed from the resource.
- Civilian is now the default fallback department.
- Badger Police/EMS Activity support added for duty-state lookups.

## Features
- New scoreboard visual design with a wider panel, modern cards, and responsive layout.
- Department blips on every player card.
- Department summary strip showing online counts by department.
- Optional Badger API support for role-to-department mapping.
- Safe fallback department matching if Badger is unavailable.
- Server-side player list synchronization.
- Optional creator join message.

## Install
1. Place the resource in your `resources/` folder.
2. Add this to `server.cfg`:

```cfg
ensure simple_scoreboard
```

3. Configure `config.lua`.
4. Restart the resource.

## Key Configuration

### Basic
```lua
Config.ServerName = "YOUR SERVER NAME HERE"
Config.ToggleKey = "F9"
Config.MaxPlayers = 32
Config.EnableLogo = true
Config.LogoURL = "https://example.com/yourlogo.png"
```

### Badger API
```lua
Config.EnableBadgerApi = true
Config.BadgerResource = "Badger_Discord_API"
Config.EnableDepartmentFallback = true
Config.RequireActiveDepartment = true
Config.BadgerActivityResource = "Badger_PoliceEMSActivity"
```

### Departments
Map your Discord role IDs into each department.

```lua
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
    }
}

Config.DefaultDepartment = {
    key = "civ",
    label = "Civilian",
    shortLabel = "CIV",
    color = "#B8A168",
    icon = "user"
}
```

## Badger Integration Notes
- This resource attempts common Badger export names automatically.
- If `Badger_Discord_API` is not started, it falls back to keyword matching (if enabled).
- Role matching is based on the role IDs listed in each department's `roles` array.

## Active Department Mode
When `Config.RequireActiveDepartment = true`, department blips are shown only for players actively set to a department.

If a player is not marked active, they show as your `Config.DefaultDepartment` (by default `Civilian`).

The server also checks `Config.BadgerActivityResource` for duty-state exports before falling back to Badger role mapping.

Use one of these server-side integrations from your duty script:

```lua
-- Export API (preferred)
exports["simple_scoreboard"]:SetPlayerActiveDepartment(source, "police")
exports["simple_scoreboard"]:ClearPlayerActiveDepartment(source)
```

Client -> server bridge option:

```lua
-- from a client duty script
TriggerServerEvent("simple_scoreboard:setActiveDepartment", "police")
TriggerServerEvent("simple_scoreboard:setActiveDepartment", nil)
```

## Department Blips
Department data is attached to each player object from the server:
- `player.department.key`
- `player.department.label`
- `player.department.shortLabel`
- `player.department.color`
- `player.department.icon`

The NUI uses this to render:
- Card blips in the scoreboard list.
- Department total pills in the header strip.

## Troubleshooting
- No departments showing: verify Badger resource name and role IDs in `Config.Departments`.
- Everyone shows `Civilian`: the player is not marked on duty or Badger did not return a matching role.
- No players visible: ensure `server.lua` is included in `fxmanifest.lua`.

## Credits
Created by Ryan Bostaph.
