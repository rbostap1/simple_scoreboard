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
        key = d.key or "civ",
        label = d.label or "Civilian",
        shortLabel = d.shortLabel or "CIV",
        color = d.color or "#B8A168",
        icon = d.icon or "user"
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

    if rawKey == true then
        activeDepartments[playerId] = true
        return true
    end

    if type(rawKey) == "table" then
        local key = rawKey.key or rawKey.departmentKey or rawKey.department or rawKey.name
        local department = findDepartmentByKey(key)
        if department then
            activeDepartments[playerId] = department
            return true
        end
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

local function normalizeDepartmentValue(value)
    if value == nil then
        return nil
    end

    if type(value) == "table" then
        local key = value.key or value.departmentKey or value.department or value.name or value.label
        local department = findDepartmentByKey(key)
        if department then
            return department
        end

        return value.active == true or value.onDuty == true or value.duty == true
    end

    if type(value) == "string" then
        return findDepartmentByKey(value)
    end

    if type(value) == "boolean" then
        return value
    end

    return nil
end

local function tryGetBadgerActivityDepartment(playerSrc)
    local resourceName = Config.BadgerActivityResource or "Badger_PoliceEMSActivity"
    if GetResourceState(resourceName) ~= "started" then
        return nil
    end

    local exportsRef = exports[resourceName]
    if not exportsRef then
        return nil
    end

    local probes = {
        "GetActiveDepartment",
        "GetCurrentDepartment",
        "GetPlayerActiveDepartment",
        "GetPlayerDepartment",
        "GetDepartment",
        "GetDutyDepartment",
        "IsOnDuty",
        "GetOnDuty",
        "GetDuty"
    }

    for _, fnName in ipairs(probes) do
        local fn = exportsRef[fnName]
        if fn then
            local ok, value = pcall(fn, playerSrc)
            if ok then
                local normalized = normalizeDepartmentValue(value)
                if normalized ~= nil then
                    return normalized
                end
            end
        end
    end

    return nil
end

local function resolveDepartmentFromRoles(playerSrc, playerName)
    local defaultDept = buildDefaultDepartment()
    local departments = Config.Departments or {}

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

local function resolveDepartment(playerSrc, playerName)
    local defaultDept = buildDefaultDepartment()

    local activeDepartment = activeDepartments[playerSrc]
    if Config.RequireActiveDepartment ~= false then
        if type(activeDepartment) == "table" then
            return activeDepartment
        end

        if activeDepartment == true then
            local activityDepartment = tryGetBadgerActivityDepartment(playerSrc)
            if type(activityDepartment) == "table" then
                return activityDepartment
            end

            if activityDepartment == true then
                return resolveDepartmentFromRoles(playerSrc, playerName)
            end

            return resolveDepartmentFromRoles(playerSrc, playerName)
        end

        local activityDepartment = tryGetBadgerActivityDepartment(playerSrc)
        if type(activityDepartment) == "table" then
            return activityDepartment
        end

        if activityDepartment == true then
            return resolveDepartmentFromRoles(playerSrc, playerName)
        end

        return defaultDept
    end

    local activityDepartment = tryGetBadgerActivityDepartment(playerSrc)
    if type(activityDepartment) == "table" then
        return activityDepartment
    end

    if activityDepartment == true then
        return resolveDepartmentFromRoles(playerSrc, playerName)
    end

    return resolveDepartmentFromRoles(playerSrc, playerName)
end

RegisterNetEvent("nova_scoreboard:setActiveDepartment", function(rawKey)
    local src = source
    local ok = setPlayerActiveDepartment(src, rawKey)
    if not ok then
        print(("[Scoreboard] Invalid active department '%s' for player %s"):format(tostring(rawKey), tostring(src)))
    end

    TriggerClientEvent("nova_scoreboard:refreshNow", -1)
end)

local function registerDutyBridgeEvent(eventName, isActive)
    RegisterNetEvent(eventName, function(rawValue)
        local src = source
        if isActive then
            if not setPlayerActiveDepartment(src, rawValue == nil and true or rawValue) then
                print(("[Scoreboard] Could not map duty value from '%s' for player %s"):format(eventName, tostring(src)))
            end
        else
            activeDepartments[src] = nil
        end

        TriggerClientEvent("nova_scoreboard:refreshNow", -1)
    end)
end

local dutyBridgeEvents = {
    on = {
        "Badger_PoliceEMSActivity:OnDuty",
        "Badger_PoliceEMSActivity:Client:OnDuty",
        "Badger_PoliceEMSActivity:ToggleDutyOn",
        "Badger_PoliceEMSActivity:SetOnDuty",
        "Badger_PoliceEMSActivity:SetDuty"
    },
    off = {
        "Badger_PoliceEMSActivity:OffDuty",
        "Badger_PoliceEMSActivity:Client:OffDuty",
        "Badger_PoliceEMSActivity:ToggleDutyOff",
        "Badger_PoliceEMSActivity:SetOffDuty",
        "Badger_PoliceEMSActivity:ClearDuty"
    }
}

for _, eventName in ipairs(dutyBridgeEvents.on) do
    registerDutyBridgeEvent(eventName, true)
end

for _, eventName in ipairs(dutyBridgeEvents.off) do
    registerDutyBridgeEvent(eventName, false)
end

exports("SetPlayerActiveDepartment", function(playerSrc, departmentKey)
    local ok = setPlayerActiveDepartment(playerSrc, departmentKey)
    if ok then
        TriggerClientEvent("nova_scoreboard:refreshNow", -1)
    end
    return ok
end)

exports("ClearPlayerActiveDepartment", function(playerSrc)
    local ok = setPlayerActiveDepartment(playerSrc, nil)
    if ok then
        TriggerClientEvent("nova_scoreboard:refreshNow", -1)
    end
    return ok
end)

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

local function buildConfigPayload()
    return {
        serverName = Config.ServerName or "Nova Scoreboard",
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

RegisterNetEvent("nova_scoreboard:requestPlayers", function()
    local src = source
    local playerList = buildPlayerList()
    TriggerClientEvent("nova_scoreboard:updatePlayers", src, playerList)
end)

RegisterNetEvent("nova_scoreboard:requestConfig", function()
    local src = source
    TriggerClientEvent("nova_scoreboard:updateConfig", src, buildConfigPayload())
end)

RegisterNetEvent("nova_scoreboard:requestScoreboardData", function()
    local src = source
    TriggerClientEvent("nova_scoreboard:updateScoreboardData", src, {
        players = buildPlayerList(),
        config = buildConfigPayload()
    })
end)

local creatorHasJoined = false

if Config.EnableCreatorMessage then
    AddEventHandler('playerJoining', function(_)
        local src = source

        SetTimeout(1000, function()
            local identifiers = GetPlayerIdentifiers(src)

            if identifiers then
                for _, id in ipairs(identifiers) do
                    if id == Config.CreatorIdentifier then
                        if not creatorHasJoined then
                            creatorHasJoined = true

                            TriggerClientEvent('chat:addMessage', -1, {
                                args = { Config.CreatorMessageSender or "^5Nova Scoreboard^0", Config.CreatorMessage }
                            })
                        end
                        break
                    end
                end
            end
        end)
    end)
    
    AddEventHandler('playerDropped', function(_)
        local src = source
        activeDepartments[src] = nil
        local identifiers = GetPlayerIdentifiers(src)
        if identifiers then
            for _, id in ipairs(identifiers) do
                if id == Config.CreatorIdentifier then
                    creatorHasJoined = false
                    break
                end
            end
        end
    end)
end
