local Brazzers = exports['brazzers-lib']:getLib()

cuffing = {}
cuffing.players = {}

-- Functions

function cuffing.getTimeDifference(time)
    local currentServerTime = os.time()
    local timeDiff = currentServerTime - time

    if timeDiff < 60 then
        return math.floor(timeDiff) .. " seconds ago"
    elseif timeDiff < 3600 then
        local minutes = math.floor(timeDiff / 60)
        return minutes .. (minutes == 1 and " minute ago" or " minutes ago")
    elseif timeDiff < 86400 then
        local hours = math.floor(timeDiff / 3600)
        return hours .. (hours == 1 and " hour ago" or " hours ago")
    else
        local days = math.floor(timeDiff / 86400)
        return days .. (days == 1 and " day ago" or " days ago")
    end
end

function cuffing.addUser(source)
    local name = Brazzers.getCharName(source)
    local data = {
        name = name,
        time = os.time(),
    }
    cuffing.players[#cuffing.players + 1] = data

    SetTimeout(60000 * 120, function()
        cuffing.removeUser(source)
    end)

    return true
end

function cuffing.removeUser(source)
    local currentList, name = {}, Brazzers.getCharName(source)
    for k, v in pairs(cuffing.players) do
        if v.name ~= name then
            currentList[#currentList + 1] = cuffing.players[k]
        end
    end
    cuffing.players = currentList
    return true
end

-- Callbacks

lib.callback.register('cuff:addUser', function()
    return cuffing.addUser(source)
end)

lib.callback.register('cuff:removeUser', function()
    return cuffing.removeUser(source)
end)

lib.callback.register('cuff:menuData', function()
    local menu = {}
    for k, v in pairs(cuffing.players) do
        menu[#menu+1] = {
            title = v.name,
            description = cuffing.getTimeDifference(v.time),
            icon = 'fa-solid fa-handcuffs',
        }
    end
    return menu
end)

lib.callback.register('cuff:getData', function()
    return cuffing.players
end)