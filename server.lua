-- server.lua
-- This file is optional and not currently used by the default implementation.
-- The client builds the player list locally using GetActivePlayers() and GetPlayerName().
-- You can enable this if you prefer server-side player list management.

RegisterNetEvent("simple_scoreboard:requestPlayers", function()
    local src = source
    local players = {}

    for _, id in ipairs(GetPlayers()) do
        local name = GetPlayerName(id) or ("Player " .. id)

        table.insert(players, {
            id = tonumber(id),
            name = name,
            ping = ping
        })
    end

    -- send list back to the requesting client
    TriggerClientEvent("simple_scoreboard:updatePlayers", src, players)
end)
