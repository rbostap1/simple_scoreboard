-- client.lua

local scoreboardOpen = false

-- Open command (triggered on key/button press)
RegisterCommand("+showscoreboard", function()
    if not scoreboardOpen then
        scoreboardOpen = true

        -- No mouse needed, just display
        SetNuiFocus(false, false)

        SendNUIMessage({
            action = "toggle",
            show = true
        })

        updateScoreboard()
    end
end)

-- Close command (triggered on key/button release)
RegisterCommand("-showscoreboard", function()
    if scoreboardOpen then
        scoreboardOpen = false

        SendNUIMessage({
            action = "toggle",
            show = false
        })
    end
end)

-- Register keymapping using the key from config
CreateThread(function()
    Wait(500) -- small delay to ensure Config is loaded

    -- Keyboard binding
    RegisterKeyMapping(
        "+showscoreboard",
        "Show Scoreboard",
        "keyboard",
        Config.ToggleKey or "F9"
    )

    -- Controller binding (D-Pad Up)
    RegisterKeyMapping(
        "+showscoreboard",
        "Show Scoreboard",
        "PAD_DIGITALBUTTON",
        "INPUT_FRONTEND_UP"
    )

    -- Send config data (server name + logo + max players + highlight settings + colors) to NUI once
    SendNUIMessage({
        action = "config",
        serverName = Config.ServerName or "My Server",
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

-- Request server-side player list
function updateScoreboard()
    print("[Scoreboard] Client requesting player list from server")
    TriggerServerEvent("simple_scoreboard:requestPlayers")
end

-- Handle server response with player list
RegisterNetEvent("simple_scoreboard:updatePlayers", function(players)
    print("[Scoreboard] Client received player data from server")
    print("[Scoreboard] Data type: " .. type(players))
    if players and type(players) == "table" then
        print("[Scoreboard] Player count: " .. #players)
        print("[Scoreboard] Player data: " .. json.encode(players))
        local myPlayer = PlayerId()
        local myPlayerId = GetPlayerServerId(myPlayer)
        print("[Scoreboard] Current player ID: " .. myPlayerId)
        
        -- Send list to NUI
        SendNUIMessage({
            action = "update",
            players = players,
            currentPlayerId = myPlayerId
        })
        print("[Scoreboard] Sent player data to NUI")
    else
        print("[Scoreboard] ERROR: Invalid player data received")
    end
end)

-- Force a data refresh when server-side duty/department state changes.
RegisterNetEvent("simple_scoreboard:refreshNow", function()
    if scoreboardOpen then
        updateScoreboard()
    end
end)
