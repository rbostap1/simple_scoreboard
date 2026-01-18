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

-- Function to update HUD display
local function updateHudDisplay()
    local player = PlayerId()
    SendNUIMessage({
        action = "hudUpdate",
        playerId = GetPlayerServerId(player),
        playerName = GetPlayerName(player) or "Player",
        playerCount = latestPlayerCount,
        maxPlayers = Config.MaxPlayers or 32
    })
end

-- Update HUD when scoreboard is refreshed
RegisterNetEvent("simple_scoreboard:updatePlayers", function(players)
    if players and type(players) == "table" then
        latestPlayerCount = #players
        -- Refresh HUD display immediately when scoreboard updates
        if hudEnabled() then
            updateHudDisplay()
        end
    end
end, true) -- Use override to update both events

-- Periodically push HUD updates (ID + Name + Player Count)
-- Refresh every 5 minutes if scoreboard hasn't been updated
CreateThread(function()
    local lastEnabled = nil
    local firstUpdate = true
    local lastHudUpdate = 0
    local HUD_UPDATE_INTERVAL = 300000 -- 5 minutes in milliseconds

    while true do
        local enabled = hudEnabled()
        local currentTime = GetGameTimer()

        if enabled then
            -- On first update, wait a bit for server response
            if firstUpdate then
                Wait(500)
                firstUpdate = false
                lastHudUpdate = GetGameTimer()
            end

            -- Update HUD if 5 minutes have passed since last update
            if (currentTime - lastHudUpdate) >= HUD_UPDATE_INTERVAL then
                TriggerServerEvent("simple_scoreboard:requestPlayers")
                lastHudUpdate = currentTime
            end

            if lastEnabled ~= enabled then
                sendHudConfig()
            end

            Wait(10000) -- Check every 10 seconds if we need to refresh
        else
            if lastEnabled ~= enabled then
                SendNUIMessage({ action = "hudToggle", enabled = false })
            end
            firstUpdate = true
            lastHudUpdate = 0
            Wait(5000)
        end

        lastEnabled = enabled
    end
end)
