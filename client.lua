-- client.lua

local scoreboardOpen = false

-- Toggle command
RegisterCommand("togglescoreboard", function()
    scoreboardOpen = not scoreboardOpen

    -- We don't need NUI focus (no mouse interaction), just show/hide
    SetNuiFocus(false, false)

    SendNUIMessage({
        action = "toggle",
        show = scoreboardOpen
    })

    if scoreboardOpen then
        requestScoreboardUpdate()
    end
end)

-- Register key mapping from config
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

-- Ask the server for the current player list
function requestScoreboardUpdate()
    TriggerServerEvent("simple_scoreboard:requestPlayers")
end

-- Receive player list from server and pass it to NUI
RegisterNetEvent("simple_scoreboard:updatePlayers", function(players)
    SendNUIMessage({
        action = "update",
        players = players
    })
end)

-- Refresh every second while open
CreateThread(function()
    while true do
        Wait(1000)
        if scoreboardOpen then
            requestScoreboardUpdate()
        end
    end
end)
