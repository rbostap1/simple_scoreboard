-- server.lua
-- Optional server-side scoreboard provider. The default client script builds the
-- player list locally, but if you uncomment this file in fxmanifest.lua you can
-- serve both player data and the full config directly from the server.

print("[Scoreboard] Server script loading...")

local activeDepartments = {}

local function toLower(value)
    if value == nil then
        return ""
    end
    return string.lower(tostring(value))
end

local function getPlayerIdentifierList(playerSrc)
    local identifiers = GetPlayerIdentifiers(playerSrc)
    if identifiers and type(identifiers) == "table" then
        return identifiers
    end
    return {}
end

local function hasRole(roleList, roleId)
    if type(roleList) ~= "table" or not roleId then
        return false
    end

    local target = tostring(roleId)
    for _, role in pairs(roleList) do
        if tostring(role) == target then
            return true
        end
    end

    return false
end

local function buildDefaultDepartment()
    local d = Config.DefaultDepartment or {}
    return {
        key = d.key or "unknown",
        label = d.label or "Unassigned",
        shortLabel = d.shortLabel or "N/A",
        color = d.color or "#8A8F98",
        icon = d.icon or "dot"
    }
end

local function findDepartmentByKey(rawKey)
    if rawKey == nil then
        return nil
    end

    local target = toLower(rawKey)
    local departments = Config.Departments or {}
    for _, dept in ipairs(departments) do
        if toLower(dept.key) == target then
            return {
                key = dept.key,
                label = dept.label,
                shortLabel = dept.shortLabel or dept.label,
                color = dept.color,
                icon = dept.icon
            }
        end
    end

    return nil
end

local function setPlayerActiveDepartment(playerSrc, rawKey)
    local playerId = tonumber(playerSrc)
    if not playerId then
        return false
    end

    if rawKey == nil or rawKey == false or rawKey == "" then
        activeDepartments[playerId] = nil
        return true
    end

    local department = findDepartmentByKey(rawKey)
    if not department then
        return false
    end

    activeDepartments[playerId] = department
    return true
end

local function tryGetBadgerRoles(playerSrc)
    if Config.EnableBadgerApi == false then
        return nil
    end

    local resourceName = Config.BadgerResource or "Badger_Discord_API"
    if GetResourceState(resourceName) ~= "started" then
        return nil
    end

    local exportsRef = exports[resourceName]
    if not exportsRef then
        return nil
    end

    -- Badger versions can expose different function names; probe common ones.
    local probes = {
        "GetDiscordRoles",
        "GetDiscordRolesFromSrc",
        "GetRoles",
        "GetDiscordRole"
    }

    for _, fnName in ipairs(probes) do
        local fn = exportsRef[fnName]
        if fn then
            local ok, value = pcall(fn, playerSrc)
            if ok and type(value) == "table" then
                return value
            end
        end
    end

    return nil
end

local function resolveDepartment(playerSrc, playerName)
    local defaultDept = buildDefaultDepartment()

    -- Active-only mode: show a department blip only if explicitly set by a duty script.
    if Config.RequireActiveDepartment ~= false then
        return activeDepartments[playerSrc] or defaultDept
    end

    local departments = Config.Departments or {}

    if type(departments) ~= "table" or #departments == 0 then
        return defaultDept
    end

    local roles = tryGetBadgerRoles(playerSrc)
    if roles then
        for _, dept in ipairs(departments) do
            if type(dept.roles) == "table" and #dept.roles > 0 then
                for _, roleId in ipairs(dept.roles) do
                    if hasRole(roles, roleId) then
                        return {
                            key = dept.key or defaultDept.key,
                            label = dept.label or defaultDept.label,
                            shortLabel = dept.shortLabel or dept.label or defaultDept.shortLabel,
                            color = dept.color or defaultDept.color,
                            icon = dept.icon or defaultDept.icon
                        }
                    end
                end
            end
        end
    end

    if Config.EnableDepartmentFallback == false then
        return defaultDept
    end

    local normalizedName = toLower(playerName)
    local identifiers = getPlayerIdentifierList(playerSrc)
    local searchable = normalizedName
    for _, identifier in ipairs(identifiers) do
        searchable = searchable .. " " .. toLower(identifier)
    end

    for _, dept in ipairs(departments) do
        local keywords = dept.fallbackKeywords
        if type(keywords) == "table" then
            for _, keyword in ipairs(keywords) do
                local token = toLower(keyword)
                if token ~= "" and string.find(searchable, token, 1, true) then
                    return {
                        key = dept.key or defaultDept.key,
                        label = dept.label or defaultDept.label,
                        shortLabel = dept.shortLabel or dept.label or defaultDept.shortLabel,
                        color = dept.color or defaultDept.color,
                        icon = dept.icon or defaultDept.icon
                    }
                end
            end
        end
    end

    return defaultDept
end

RegisterNetEvent("simple_scoreboard:setActiveDepartment", function(rawKey)
    local src = source
    local ok = setPlayerActiveDepartment(src, rawKey)
    if not ok then
        print(("[Scoreboard] Invalid active department '%s' for player %s"):format(tostring(rawKey), tostring(src)))
    end

    -- Prompt clients to request a fresh player list so HUD/scoreboard updates quickly.
    TriggerClientEvent("simple_scoreboard:refreshNow", -1)
end)

exports("SetPlayerActiveDepartment", function(playerSrc, departmentKey)
    local ok = setPlayerActiveDepartment(playerSrc, departmentKey)
    if ok then
        TriggerClientEvent("simple_scoreboard:refreshNow", -1)
    end
    return ok
end)

exports("ClearPlayerActiveDepartment", function(playerSrc)
    local ok = setPlayerActiveDepartment(playerSrc, nil)
    if ok then
        TriggerClientEvent("simple_scoreboard:refreshNow", -1)
    end
    return ok
end)

-- Build a fresh player list with id and name for each connected player.
local function buildPlayerList()
    local players = {}

    for _, id in ipairs(GetPlayers()) do
        local playerId = tonumber(id)
        local playerName = GetPlayerName(id) or ("Player " .. playerId)
        table.insert(players, {
            id = playerId,
            name = playerName,
            department = resolveDepartment(playerId, playerName)
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

        colors = Config.Colors or {},
        departments = Config.Departments or {},
        defaultDepartment = buildDefaultDepartment()
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
local creatorHasJoined = false

if Config.EnableCreatorMessage then
    AddEventHandler('playerJoining', function(oldId)
        local src = source
        
        -- Wait a bit for identifiers to be fully loaded
        SetTimeout(1000, function()
            local identifiers = GetPlayerIdentifiers(src)
            
            if identifiers then
                for _, id in ipairs(identifiers) do
                    if id == Config.CreatorIdentifier then
                        if not creatorHasJoined then
                            creatorHasJoined = true
                            
                            -- Broadcast the message to all players
                            TriggerClientEvent('chat:addMessage', -1, {
                                args = { Config.CreatorMessageSender or "^5simple_scoreboard^0", Config.CreatorMessage }
                            })
                            
                            print("[Scoreboard] Creator joined the server!")
                        end
                        break
                    end
                end
            end
        end)
    end)
    
    AddEventHandler('playerDropped', function(reason)
        local src = source
        activeDepartments[src] = nil
        local identifiers = GetPlayerIdentifiers(src)
        if identifiers then
            for _, id in ipairs(identifiers) do
                if id == Config.CreatorIdentifier then
                    creatorHasJoined = false
                    print("[Scoreboard] Creator left the server")
                    break
                end
            end
        end
    end)
    
    print("[Scoreboard] Creator join message enabled")
end
