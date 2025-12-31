-- hud.lua
-- Lightweight HUD to display the local player's ID and name in the top-left corner.

local function hudEnabled()
    return Config.EnablePlayerHud ~= false
end

local function hudColors()
    local colors = Config.HudColors or {}
    return {
        text = colors.text or "#FFFFFF",
        background = colors.background or "rgba(20, 20, 40, 0.85)",
        border = colors.border or "#6495FF"
    }
end

local function sendHudConfig()
    if not hudEnabled() then
        SendNUIMessage({ action = "hudToggle", enabled = false })
        return
    end

    local c = hudColors()
    SendNUIMessage({
        action = "hudConfig",
        hud = {
            enabled = true,
            textColor = c.text,
            backgroundColor = c.background,
            borderColor = c.border
        }
    })
end

-- Send initial HUD config once UI is ready
CreateThread(function()
    Wait(750)
    sendHudConfig()
end)

-- Store the latest player count from server
local latestPlayerCount = 0

-- Handle server response with player list
RegisterNetEvent("simple_scoreboard:updatePlayers", function(players)
    if players and type(players) == "table" then
        latestPlayerCount = #players
    end
end)

-- Periodically push HUD updates (ID + Name + Player Count)
CreateThread(function()
    local lastEnabled = nil

    while true do
        local enabled = hudEnabled()

        if enabled then
            local player = PlayerId()
            SendNUIMessage({
                action = "hudUpdate",
                playerId = GetPlayerServerId(player),
                playerName = GetPlayerName(player) or "Player",
                playerCount = latestPlayerCount,
                maxPlayers = Config.MaxPlayers or 32
            })

            if lastEnabled ~= enabled then
                sendHudConfig()
            end

            -- Request server-side player list for accurate count
            TriggerServerEvent("simple_scoreboard:requestPlayers")

            Wait(2000)
        else
            if lastEnabled ~= enabled then
                SendNUIMessage({ action = "hudToggle", enabled = false })
            end
            Wait(5000)
        end

        lastEnabled = enabled
    end
end)
