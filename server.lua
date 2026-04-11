local activeDepartments = {}
local dutySelections = {}
local departmentCache = {}
local tryGetBadgerRoles
local missingBadgerRoleExportWarned = false
local creatorHasJoined = false
local DEPARTMENT_CACHE_TTL_MILLIS = 5000
local DEFAULT_BADGER_ROLE_RESOURCE = "Badger_Discord_API"
local DEFAULT_BADGER_ACTIVITY_RESOURCE = "Badger_PoliceEMSActivity"

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

local function getDeclaredServerExports(resourceName)
    local declared = {}
    local keys = { "server_export", "export" }

    for _, key in ipairs(keys) do
        local count = GetNumResourceMetadata(resourceName, key) or 0
        for i = 0, count - 1 do
            local exportName = GetResourceMetadata(resourceName, key, i)
            if exportName and exportName ~= "" then
                declared[exportName] = true
            end
        end
    end

    return declared
end

local function callExportSafely(exportsRef, fnName, ...)
    local fn = exportsRef[fnName]
    if not fn then
        return false, nil
    end

    local ok, value = pcall(fn, exportsRef, ...)
    if ok then
        return true, value
    end

    ok, value = pcall(fn, ...)
    if ok then
        return true, value
    end

    return false, nil
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

local function getDepartmentMode()
    local mode = toLower(Config.DepartmentMode)
    if mode == "badger_duty" then
        return "badger_duty"
    end
    return "discord_roles"
end

local function sendPlayerMessage(playerSrc, message)
    TriggerClientEvent("chat:addMessage", playerSrc, {
        args = { "^5Nova Scoreboard^0", message }
    })
end

local function getRoleBasedDepartmentChoices(playerSrc)
    local choices = {}
    local roles = tryGetBadgerRoles(playerSrc)
    if type(roles) ~= "table" then
        return choices
    end

    for _, dept in ipairs(Config.Departments or {}) do
        if type(dept.roles) == "table" then
            for _, roleId in ipairs(dept.roles) do
                if hasRole(roles, roleId) then
                    table.insert(choices, {
                        key = dept.key,
                        label = dept.label or dept.key,
                        shortLabel = dept.shortLabel or dept.label or dept.key
                    })
                    break
                end
            end
        end
    end

    return choices
end

local function playerCanUseDepartment(playerSrc, departmentKey)
    if not departmentKey or departmentKey == "" then
        return false
    end

    local target = toLower(departmentKey)
    for _, choice in ipairs(getRoleBasedDepartmentChoices(playerSrc)) do
        if toLower(choice.key) == target then
            return true
        end
    end

    return false
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

local function hasDepartmentSelectionValue(value)
    return value ~= nil and value ~= false and value ~= ""
end

local function setPlayerActiveDepartment(playerSrc, rawKey)
    local playerId = tonumber(playerSrc)
    if not playerId then
        return false
    end

    if rawKey == nil or rawKey == false or rawKey == "" then
        activeDepartments[playerId] = nil
        departmentCache[playerId] = nil
        return true
    end

    if rawKey == true then
        activeDepartments[playerId] = true
        departmentCache[playerId] = nil
        return true
    end

    if type(rawKey) == "table" then
        local key = rawKey.key or rawKey.departmentKey or rawKey.department or rawKey.name
        local department = findDepartmentByKey(key)
        if department then
            activeDepartments[playerId] = department
            departmentCache[playerId] = nil
            return true
        end
    end

    local department = findDepartmentByKey(rawKey)
    if not department then
        return false
    end

    activeDepartments[playerId] = department
    departmentCache[playerId] = nil
    return true
end

tryGetBadgerRoles = function(playerSrc)
    if Config.EnableBadgerApi == false then
        return nil
    end

    local resourceName = Config.BadgerResource or DEFAULT_BADGER_ROLE_RESOURCE
    if GetResourceState(resourceName) ~= "started" then
        return nil
    end

    local exportsRef = exports[resourceName]
    if not exportsRef then
        return nil
    end

    local configuredExport = tostring(Config.BadgerRoleExport or "")
    local probes = {}
    if configuredExport ~= "" then
        table.insert(probes, configuredExport)
    end

    local defaults = {
        "GetDiscordRoles",
        "GetDiscordRolesFromSrc",
        "GetRoles",
        "GetDiscordRole"
    }

    for _, fnName in ipairs(defaults) do
        local exists = false
        for _, probe in ipairs(probes) do
            if probe == fnName then
                exists = true
                break
            end
        end
        if not exists then
            table.insert(probes, fnName)
        end
    end

    local declaredExports = getDeclaredServerExports(resourceName)
    local hasAnyDeclaredExports = next(declaredExports) ~= nil
    local attempted = false

    for _, fnName in ipairs(probes) do
        -- Fallback: if resource metadata does not declare exports, probe known names anyway.
        if declaredExports[fnName] or not hasAnyDeclaredExports then
            attempted = true
            local ok, value = callExportSafely(exportsRef, fnName, playerSrc)
            if ok and type(value) == "table" then
                return value
            end
        end
    end

    if not attempted and not missingBadgerRoleExportWarned then
        missingBadgerRoleExportWarned = true
        print(("[Scoreboard] No compatible role export found on '%s'. Update Config.BadgerRoleExport."):format(resourceName))
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
    local resourceName = Config.BadgerActivityResource or DEFAULT_BADGER_ACTIVITY_RESOURCE
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
        local ok, value = callExportSafely(exportsRef, fnName, playerSrc)
        if ok then
            local normalized = normalizeDepartmentValue(value)
            if normalized ~= nil then
                return normalized
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
    local mode = getDepartmentMode()

    if mode == "discord_roles" then
        if Config.RequireActiveDepartment ~= false then
            local activeDepartment = activeDepartments[playerSrc]
            if type(activeDepartment) == "table" then
                if playerCanUseDepartment(playerSrc, activeDepartment.key) then
                    return activeDepartment
                end
                activeDepartments[playerSrc] = nil
                return defaultDept
            end
            if activeDepartment ~= true then
                return defaultDept
            end
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

    if Config.RequireActiveDepartment ~= false then
        return defaultDept
    end

    return resolveDepartmentFromRoles(playerSrc, playerName)
end

RegisterNetEvent("nova_scoreboard:setActiveDepartment", function(rawKey)
    local src = source

    local requested = rawKey
    if type(rawKey) == "table" then
        requested = rawKey.key or rawKey.departmentKey or rawKey.department or rawKey.name
    end

    if hasDepartmentSelectionValue(requested) and requested ~= true and type(requested) ~= "string" then
        print(("[Scoreboard] Rejected invalid active department payload type '%s' from player %s"):format(type(requested), tostring(src)))
        return
    end

    if hasDepartmentSelectionValue(requested) and requested ~= true then
        local requestedDepartment = findDepartmentByKey(requested)
        if not requestedDepartment or not playerCanUseDepartment(src, requestedDepartment.key) then
            print(("[Scoreboard] Unauthorized active department '%s' from player %s"):format(tostring(requested), tostring(src)))
            return
        end
        rawKey = requestedDepartment.key
    elseif requested == true then
        print(("[Scoreboard] Rejected boolean active department from player %s"):format(tostring(src)))
        return
    end

    local ok = setPlayerActiveDepartment(src, rawKey)
    if not ok then
        print(("[Scoreboard] Invalid active department '%s' for player %s"):format(tostring(rawKey), tostring(src)))
    end

    TriggerClientEvent("nova_scoreboard:refreshNow", -1)
end)

local function registerDutyBridgeEvent(eventName, isActive)
    RegisterNetEvent(eventName, function(rawValue)
        local src = source
        local invokingResource = GetInvokingResource()
        local badgerResource = Config.BadgerActivityResource or DEFAULT_BADGER_ACTIVITY_RESOURCE
        local trustedInvocation = invokingResource == badgerResource
        if isActive then
            local dutyValue = rawValue
            if (dutyValue == nil or dutyValue == true) and not trustedInvocation then
                print(("[Scoreboard] Rejected untrusted duty bridge payload from '%s' for player %s"):format(eventName, tostring(src)))
                return
            end

            local requested = dutyValue
            if type(requested) == "table" then
                requested = requested.key or requested.departmentKey or requested.department or requested.name
            end

            if hasDepartmentSelectionValue(requested) and requested ~= true and type(requested) ~= "string" then
                print(("[Scoreboard] Rejected invalid duty bridge payload type '%s' from '%s' for player %s"):format(type(requested), eventName, tostring(src)))
                return
            end

            if hasDepartmentSelectionValue(requested) and requested ~= true then
                local requestedDepartment = findDepartmentByKey(requested)
                if not requestedDepartment or not playerCanUseDepartment(src, requestedDepartment.key) then
                    print(("[Scoreboard] Rejected unauthorized duty bridge department '%s' from '%s' for player %s"):format(tostring(requested), eventName, tostring(src)))
                    return
                end
                dutyValue = requestedDepartment.key
            end

            if dutyValue == nil and trustedInvocation then
                dutyValue = true
            end

            if not setPlayerActiveDepartment(src, dutyValue) then
                print(("[Scoreboard] Could not map duty value from '%s' for player %s"):format(eventName, tostring(src)))
            end
        else
            activeDepartments[src] = nil
            departmentCache[src] = nil
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

RegisterCommand(Config.DutyCommandName or "duty", function(src, args)
    if src == 0 then
        print("[Scoreboard] Duty command can only be used by players.")
        return
    end

    if Config.EnableDutyCommand == false then
        sendPlayerMessage(src, "^1Duty command is disabled in config.^0")
        return
    end

    if getDepartmentMode() ~= "discord_roles" then
        sendPlayerMessage(src, "^1Duty command is only available when Config.DepartmentMode is set to 'discord_roles'.^0")
        return
    end

    local rawChoice = args and args[1]
    if rawChoice and (toLower(rawChoice) == "off" or toLower(rawChoice) == "clear") then
        setPlayerActiveDepartment(src, nil)
        dutySelections[src] = nil
        TriggerClientEvent("nova_scoreboard:refreshNow", -1)
        sendPlayerMessage(src, "^3You are now off duty.^0")
        return
    end

    local choices = dutySelections[src]
    if type(choices) ~= "table" or #choices == 0 then
        choices = getRoleBasedDepartmentChoices(src)
        dutySelections[src] = choices
    end

    if #choices == 0 then
        sendPlayerMessage(src, "^1No eligible departments found for your Discord roles.^0")
        return
    end

    if not rawChoice or rawChoice == "" then
        sendPlayerMessage(src, "^2Select a department with /" .. (Config.DutyCommandName or "duty") .. " <number>^0")
        for index, dept in ipairs(choices) do
            sendPlayerMessage(src, ("^3[%d]^0 %s (%s)"):format(index, tostring(dept.label), tostring(dept.shortLabel)))
        end
        sendPlayerMessage(src, "^3Type /" .. (Config.DutyCommandName or "duty") .. " off to clear duty.^0")
        return
    end

    local choiceIndex = tonumber(rawChoice)
    if not choiceIndex then
        sendPlayerMessage(src, "^1Invalid option. Use /" .. (Config.DutyCommandName or "duty") .. " to see the numbered list.^0")
        return
    end

    local selected = choices[choiceIndex]
    if not selected then
        sendPlayerMessage(src, "^1That number is not in your department list. Run /" .. (Config.DutyCommandName or "duty") .. " again.^0")
        return
    end

    if not setPlayerActiveDepartment(src, selected.key) then
        sendPlayerMessage(src, "^1Could not set your duty department. Check department keys in config.^0")
        return
    end

    dutySelections[src] = nil
    TriggerClientEvent("nova_scoreboard:refreshNow", -1)
    sendPlayerMessage(src, ("^2Duty set to %s.^0"):format(tostring(selected.label)))
end, false)

AddEventHandler("playerDropped", function(_)
    local src = source
    dutySelections[src] = nil
    activeDepartments[src] = nil
    departmentCache[src] = nil
    if Config.EnableCreatorMessage then
        local creatorIdentifier = Config.CreatorIdentifier
        if not creatorIdentifier or creatorIdentifier == "" then
            return
        end
        local identifiers = GetPlayerIdentifiers(src)
        if identifiers then
            for _, id in ipairs(identifiers) do
                if id == creatorIdentifier then
                    creatorHasJoined = false
                    break
                end
            end
        end
    end
end)

local function getCachedDepartment(playerId, playerName)
    local now = GetGameTimer()
    local cached = departmentCache[playerId]
    if cached and cached.expiresAt > now and cached.playerName == playerName then
        return cached.department
    end

    local department = resolveDepartment(playerId, playerName)
    departmentCache[playerId] = {
        department = department,
        expiresAt = now + DEPARTMENT_CACHE_TTL_MILLIS,
        playerName = playerName
    }

    return department
end

local function buildPlayerList()
    local players = {}

    for _, id in ipairs(GetPlayers()) do
        local playerId = tonumber(id)
        local playerName = GetPlayerName(id) or ("Player " .. playerId)
        table.insert(players, {
            id = playerId,
            name = playerName,
            department = getCachedDepartment(playerId, playerName)
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

if Config.EnableCreatorMessage then
    AddEventHandler('playerJoining', function(_)
        local src = source
        local creatorIdentifier = Config.CreatorIdentifier
        if not creatorIdentifier or creatorIdentifier == "" then
            return
        end

        SetTimeout(1000, function()
            local identifiers = GetPlayerIdentifiers(src)

            if identifiers then
                for _, id in ipairs(identifiers) do
                    if id == creatorIdentifier then
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
    
end
