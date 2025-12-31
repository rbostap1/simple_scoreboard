-- server.lua
-- Optional server-side scoreboard provider. The default client script builds the
-- player list locally, but if you uncomment this file in fxmanifest.lua you can
-- serve both player data and the full config directly from the server.

print("[Scoreboard] Server script loading...")

-- Build a fresh player list with id and name for each connected player.
local function buildPlayerList()
    local players = {}

    for _, id in ipairs(GetPlayers()) do
        local playerId = tonumber(id)
        table.insert(players, {
            id = playerId,
            name = GetPlayerName(id) or ("Player " .. playerId)
        })
    end

    return players
end

-- Pack every scoreboard display option so clients don't need to hardcode them.
local function buildConfigPayload()
    return {
        serverName = Config.ServerName or "YOUR SERVER NAME HERE",
        toggleKey = Config.ToggleKey or "F9",
        maxPlayers = Config.MaxPlayers or 32,

        logoEnabled = Config.EnableLogo ~= false,
        logo = (Config.EnableLogo ~= false and Config.LogoURL) or "",

        highlightEnabled = Config.HighlightCurrentPlayer ~= false,
        highlightColor = Config.HighlightColor or "#6495FF",

        colors = Config.Colors or {}
    }
end

-- Return only the player list (client will still use its own config).
RegisterNetEvent("simple_scoreboard:requestPlayers", function()
    local src = source
    local playerList = buildPlayerList()
    print("[Scoreboard] Server received player request from player " .. src)
    print("[Scoreboard] Sending " .. #playerList .. " players to client")
    print("[Scoreboard] Player data: " .. json.encode(playerList))
    TriggerClientEvent("simple_scoreboard:updatePlayers", src, playerList)
end)

-- Return just the config so the UI can mirror server settings.
RegisterNetEvent("simple_scoreboard:requestConfig", function()
    local src = source
    TriggerClientEvent("simple_scoreboard:updateConfig", src, buildConfigPayload())
end)

-- Return both player data and config together for one-stop syncing.
RegisterNetEvent("simple_scoreboard:requestScoreboardData", function()
    local src = source
    TriggerClientEvent("simple_scoreboard:updateScoreboardData", src, {
        players = buildPlayerList(),
        config = buildConfigPayload()
    })
end)

print("[Scoreboard] Server script loaded successfully!")
print("[Scoreboard] Registered event handlers for player list requests")

-- Creator Join Message
if Config.EnableCreatorMessage then
    AddEventHandler('playerConnecting', function()
        local src = source
        
        -- Small delay to ensure player identifiers are loaded
        SetTimeout(1000, function()
            local identifiers = GetPlayerIdentifiers(src)
            
            if identifiers then
                for _, id in ipairs(identifiers) do
                    if id == Config.CreatorIdentifier then
                        -- Broadcast the message to all players
                        TriggerClientEvent('chat:addMessage', -1, {
                            args = { Config.CreatorMessage }
                        })
                        print("[Scoreboard] Creator joined the server!")
                        break
                    end
                end
            end
        end)
    end)
    print("[Scoreboard] Creator join message enabled")
end
