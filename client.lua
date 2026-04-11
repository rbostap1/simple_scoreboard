local scoreboardOpen = false

RegisterCommand("+showscoreboard", function()
    if not scoreboardOpen then
        scoreboardOpen = true
        SetNuiFocus(false, false)

        SendNUIMessage({
            action = "toggle",
            show = true
        })

        updateScoreboard()
    end
end)

RegisterCommand("-showscoreboard", function()
    if scoreboardOpen then
        scoreboardOpen = false

        SendNUIMessage({
            action = "toggle",
            show = false
        })
    end
end)

CreateThread(function()
    Wait(500)

    RegisterKeyMapping(
        "+showscoreboard",
        "Show Scoreboard",
        "keyboard",
        Config.ToggleKey or "F9"
    )

    RegisterKeyMapping(
        "+showscoreboard",
        "Show Scoreboard",
        "PAD_DIGITALBUTTON",
        "INPUT_FRONTEND_UP"
    )

    SendNUIMessage({
        action = "config",
        serverName = Config.ServerName or "Nova Scoreboard",
        logoEnabled = Config.EnableLogo ~= false,
        logo = (Config.EnableLogo ~= false and Config.LogoURL) or "",
        maxPlayers = Config.MaxPlayers or 32,
        highlightEnabled = Config.HighlightCurrentPlayer ~= false,
        highlightColor = Config.HighlightColor or "#6495FF",
        colors = Config.Colors or {},
        departments = Config.Departments or {},
        defaultDepartment = Config.DefaultDepartment or {
            key = "civ",
            label = "Civilian",
            shortLabel = "CIV",
            color = "#B8A168",
            icon = "user"
        }
    })
end)

function updateScoreboard()
    TriggerServerEvent("nova_scoreboard:requestPlayers")
end

RegisterNetEvent("nova_scoreboard:updatePlayers", function(players)
    if players and type(players) == "table" then
        local myPlayer = PlayerId()
        local myPlayerId = GetPlayerServerId(myPlayer)

        SendNUIMessage({
            action = "update",
            players = players,
            currentPlayerId = myPlayerId
        })
    end
end)

RegisterNetEvent("nova_scoreboard:refreshNow", function()
    if scoreboardOpen then
        updateScoreboard()
    end
end)

CreateThread(function()
    while true do
        if scoreboardOpen then
            updateScoreboard()
            Wait(5000)
        else
            Wait(500)
        end
    end
end)
