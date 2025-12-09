-- server.lua

RegisterNetEvent("simple_scoreboard:requestPlayers", function()
    local src = source
    local players = {}

    for _, id in ipairs(GetPlayers()) do
        local name = GetPlayerName(id) or ("Player " .. id)
        local ping = GetPlayerPing(id) or 0

        table.insert(players, {
            id = tonumber(id),
            name = name,
            ping = ping
        })
    end

    -- send list back to the requesting client
    TriggerClientEvent("simple_scoreboard:updatePlayers", src, players)
end)
