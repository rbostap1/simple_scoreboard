-- server.lua

RegisterNetEvent("simple_scoreboard:requestPlayers", function()
    local src = source
    local players = {}

    -- Get ALL players on the server
    for _, id in ipairs(GetPlayers()) do
        local name = GetPlayerName(id) or ("Player " .. id)
        local ping = GetPlayerPing(id) or 0

        table.insert(players, {
            id = tonumber(id), -- server IDs are strings, convert to number for display
            name = name,
            ping = ping
        })
    end

    -- Send only to the player who requested it
    TriggerClientEvent("simple_scoreboard:updatePlayers", src, players)
end)
