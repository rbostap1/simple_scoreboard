local scoreboardOpen = false

-- Command to toggle scoreboard
RegisterCommand("togglescoreboard", function()
    scoreboardOpen = not scoreboardOpen
    SetNuiFocus(false, false) -- no cursor needed, just show/hide

    SendNUIMessage({
        action = "toggle",
        show = scoreboardOpen
    })

    if scoreboardOpen then
        updateScoreboard()
    end
end)

-- Keymapping using the key from config
CreateThread(function()
    -- small delay to ensure Config is loaded
    Wait(500)

    -- Register keybind with name "togglescoreboard"
    RegisterKeyMapping(
        "togglescoreboard",
        "Toggle Scoreboard",
        "keyboard",
        Config.ToggleKey or "F9"
    )

    -- Send initial config data to NUI
    SendNUIMessage({
        action = "config",
        serverName = Config.ServerName or "My Server",
        logo = Config.LogoURL or ""
    })
end)

-- Function to gather all active players
function updateScoreboard()
    local players = GetActivePlayers()
    local data = {}

    for _, player in ipairs(players) do
        local serverId = GetPlayerServerId(player)
        local name = GetPlayerName(player)
        local ping = GetPlayerPing(player)

        table.insert(data, {
            id = serverId,
            name = name,
            ping = ping
        })
    end

    SendNUIMessage({
        action = "update",
        players = data
    })
end

-- Refresh data every second while scoreboard is open
CreateThread(function()
    while true do
        Wait(1000)
        if scoreboardOpen then
            updateScoreboard()
        end
    end
end)
