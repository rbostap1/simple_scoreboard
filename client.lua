local scoreboardOpen = false

RegisterCommand("togglescoreboard", function()
    scoreboardOpen = not scoreboardOpen
    SetNuiFocus(scoreboardOpen, scoreboardOpen)
    SendNUIMessage({
        action = "toggle",
        show = scoreboardOpen
    })

    if scoreboardOpen then
        updateScoreboard()
    end
end)

RegisterKeyMapping("togglescoreboard", "Toggle Scoreboard", "keyboard", "F9")

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

-- refresh every second
CreateThread(function()
    while true do
        Wait(1000)
        if scoreboardOpen then
            updateScoreboard()
        end
    end
end)
