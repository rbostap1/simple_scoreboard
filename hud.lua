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

-- Periodically push HUD updates (ID + Name)
CreateThread(function()
    local lastEnabled = nil

    while true do
        local enabled = hudEnabled()

        if enabled then
            local player = PlayerId()
            local playerCount = #GetActivePlayers()
            SendNUIMessage({
                action = "hudUpdate",
                playerId = GetPlayerServerId(player),
                playerName = GetPlayerName(player) or "Player",
                playerCount = playerCount,
                maxPlayers = Config.MaxPlayers or 32
            })

            if lastEnabled ~= enabled then
                sendHudConfig()
            end

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
