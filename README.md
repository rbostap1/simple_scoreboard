# Nova Scoreboard

Nova Scoreboard is a lightweight FiveM scoreboard resource with a modern NUI, department-aware player cards, and optional Badger integrations for role and duty data.

## Please Note
Features in this script are not 100% tested as working.
If you find a bug in this script, please feel free to fork the repo and fix the issue.

## Current Feature Set
- Modern scoreboard UI with animated player cards and responsive layout.
- Department badge on each player card (short label + icon token).
- Department summary pills with live per-department counts.
- Current player highlighting (`Config.HighlightCurrentPlayer`).
- Server/player count display (`online / max`).
- Optional custom logo with fallback badge when no logo is configured.
- Optional creator join announcement message.
- Department resolution modes:
    - `discord_roles` via `Badger_Discord_API` roles.
    - `badger_duty` via `Badger_PoliceEMSActivity` duty exports.
- Optional keyword fallback matching when Badger role data is unavailable.
- Duty-state control via:
    - Resource exports (recommended).
    - Net event bridge (`nova_scoreboard:setActiveDepartment`).
    - Built-in duty chat command (Discord role mode only).

## Installation
1. Place this resource in your server `resources` folder.
2. Ensure the folder name matches what you start in `server.cfg`.
3. Add an ensure line:

```cfg
ensure Nova_Scoreboard
```

4. Configure values in `config.lua`.
5. Restart the resource/server.

## Default Controls
- Toggle scoreboard: `F9` (remappable through GTA keybind settings).

## Core Configuration

### Basic Settings
```lua
Config.ServerName = "Nova Scoreboard"
Config.ToggleKey = "F9"
Config.MaxPlayers = 32

Config.EnableLogo = true
Config.LogoURL = "https://example.com/yourlogo.png"

Config.HighlightCurrentPlayer = true
Config.HighlightColor = "#E56B1F"
```

### Creator Join Message (Optional)
```lua
Config.EnableCreatorMessage = true
Config.CreatorIdentifier = "license:YOUR_LICENSE_HERE"
Config.CreatorMessageSender = "^5Nova Scoreboard^0"
Config.CreatorMessage = "^3The script creator/editor ^2NAME HERE ^3has joined the server!^0"
```

### Department + Badger Settings
```lua
Config.DepartmentMode = "discord_roles" -- or "badger_duty"

Config.EnableBadgerApi = true
Config.BadgerResource = "Badger_Discord_API"
Config.BadgerRoleExport = "GetDiscordRoles"

Config.EnableDepartmentFallback = true
Config.RequireActiveDepartment = true

Config.BadgerActivityResource = "Badger_PoliceEMSActivity"

Config.EnableDutyCommand = true
Config.DutyCommandName = "NSduty"
```

## Department Modes
- `discord_roles`
    - Resolves player departments from Discord roles defined in `Config.Departments[].roles`.
    - If `Config.RequireActiveDepartment = true`, player must be marked active/on-duty to show their matched department.
- `badger_duty`
    - Attempts to resolve duty department directly from `Config.BadgerActivityResource` exports.
    - If duty export returns only boolean duty state, role mapping is used for department identity.

## Duty Command
When enabled, and only in `discord_roles` mode, players can select active duty department by chat command.

Default command:
- `/NSduty`
- `/NSduty <number>`
- `/NSduty off`

Behavior:
- Command with no argument lists eligible departments mapped from player Discord roles.
- Number argument selects one of those listed departments.
- `off`/`clear` removes active duty status.

## Department Definitions
Define your departments and role mappings in `Config.Departments`.

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

Config.DefaultDepartment = {
        key = "civ",
        label = "Civilian",
        shortLabel = "CIV",
        color = "#B8A168",
        icon = "user"
}
```

## Integration API

### Exports
Use from another server resource:

```lua
exports["Nova_Scoreboard"]:SetPlayerActiveDepartment(source, "police")
exports["Nova_Scoreboard"]:ClearPlayerActiveDepartment(source)
```

### Net Event Bridge
Use from client scripts:

```lua
TriggerServerEvent("nova_scoreboard:setActiveDepartment", "police")
TriggerServerEvent("nova_scoreboard:setActiveDepartment", nil)
```

### Badger Duty Bridge Events (Auto-Handled)
This resource listens for common Badger duty events, including:
- `Badger_PoliceEMSActivity:OnDuty`
- `Badger_PoliceEMSActivity:OffDuty`
- `Badger_PoliceEMSActivity:SetOnDuty`
- `Badger_PoliceEMSActivity:SetOffDuty`
- and several related alias events.

## UI Notes
- 12 players per page in the NUI.
- Department summary auto-updates from current server player list.
- Supports color theming via `Config.Colors`.
- Mobile/resolution-responsive card grid (3, 2, then 1 column based on width).

## Troubleshooting
- No departments are showing:
    - Verify `Config.BadgerResource` is correct and started.
    - Verify role IDs in `Config.Departments[].roles`.
- Everyone appears as Civilian:
    - Ensure player is on duty when `Config.RequireActiveDepartment = true`.
    - Confirm Badger role/duty exports return expected data.
- Duty command does nothing:
    - Check `Config.EnableDutyCommand = true`.
    - Check `Config.DepartmentMode = "discord_roles"`.
    - Use configured command name (`Config.DutyCommandName`, default `NSduty`).

## Credits
Created by Ryan Bostaph.
