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

    -- Controller binding (DPAD UP)
    RegisterKeyMapping(
        "+showscoreboard",
        "Show Scoreboard",
        "PAD_DIGITALBUTTON",
        "DPAD_UP"
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
        colors = Config.Colors or {}
    })
end)

-- Build the player list (ID + Name only)
function updateScoreboard()
    local players = {}

    -- Always include the local player first
    local myPlayer = PlayerId()
    local myPlayerId = GetPlayerServerId(myPlayer)
    table.insert(players, {
        id = myPlayerId,
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
        players = players,
        currentPlayerId = myPlayerId
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
