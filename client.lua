-- client.lua

local scoreboardOpen = false

-- Toggle command (players can bind/change in keybinds menu)
RegisterCommand("togglescoreboard", function()
    scoreboardOpen = not scoreboardOpen

    -- No mouse needed, just display
    SetNuiFocus(false, false)

    SendNUIMessage({
        action = "toggle",
        show = scoreboardOpen
    })

    if scoreboardOpen then
        updateScoreboard()
    end
end)

-- Register keymapping using the key from config
CreateThread(function()
    Wait(500) -- small delay to ensure Config is loaded

    RegisterKeyMapping(
        "togglescoreboard",
        "Toggle Scoreboard",
        "keyboard",
        Config.ToggleKey or "F9"
    )

    -- Send config data (server name + logo) to NUI once
    SendNUIMessage({
        action = "config",
        serverName = Config.ServerName or "My Server",
        logo = Config.LogoURL or ""
    })
end)

-- Build the player list (ID + Name only)
function updateScoreboard()
    local players = {}

    -- Always include the local player first
    local myPlayer = PlayerId()
    table.insert(players, {
        id = GetPlayerServerId(myPlayer),
        name = GetPlayerName(myPlayer)
    })

    -- Add any other active/streamed players
    for _, player in ipairs(GetActivePlayers()) do
        if player ~= myPlayer then
            table.insert(players, {
                id = GetPlayerServerId(player),
                name = GetPlayerName(player)
            })
        end
    end

    -- Send list to NUI
    SendNUIMessage({
        action = "update",
        players = players
    })
end

-- Refresh every second while scoreboard is open
CreateThread(function()
    while true do
        Wait(1000)
        if scoreboardOpen then
            updateScoreboard()
        end
    end
end)
