local config = require 'config.client'
local sharedConfig = require 'config.shared'

local function isOnDutyLeo()
    local job = QBX.PlayerData.job
    return job and job.type == 'leo' and job.onduty
end

local function addPlayerTargets()
    if not config.useTarget then return end

    exports.ox_target:addGlobalPlayer({
        label = locale('commands.cuff_player'),
        icon = 'fa-solid fa-user-lock',
        distance = 2.5,
        groups = 'police',
        canInteract = function(entity, distance)
            if not isOnDutyLeo() or entity == cache.ped then return false end
            if distance > 2.5 or cache.vehicle then return false end
            if IsPedInAnyVehicle(entity, false) then return false end
            return exports.ox_inventory:Search('count', config.handcuffItems) > 0
        end,
        onSelect = function(data)
            local target = NetworkGetPlayerIndexFromPed(data.entity)
            if not target or target == -1 then return end
            local targetServerId = GetPlayerServerId(target)
            if targetServerId then
                TriggerEvent('police:client:CuffPlayer', targetServerId)
            end
        end
    })

    exports.ox_target:addGlobalPlayer({
        label = locale('commands.softcuff'),
        icon = 'fa-solid fa-handshake',
        distance = 2.5,
        groups = 'police',
        canInteract = function(entity, distance)
            if not isOnDutyLeo() or entity == cache.ped then return false end
            if distance > 2.5 or cache.vehicle then return false end
            return not IsPedInAnyVehicle(entity, false)
        end,
        onSelect = function(data)
            local target = NetworkGetPlayerIndexFromPed(data.entity)
            if not target or target == -1 then return end
            local targetServerId = GetPlayerServerId(target)
            if targetServerId then
                TriggerEvent('police:client:CuffPlayerSoft', targetServerId)
            end
        end
    })
end

local function addWorldTargets()
    if not config.useTarget then return end

    exports.ox_target:addModel(`P_ld_stinger_s`, {
        {
            label = 'Pickup spike strip',
            icon = 'fa-solid fa-ban',
            groups = 'police',
            distance = 3.5,
            canInteract = function(_, distance)
                return isOnDutyLeo() and not cache.vehicle and distance <= 3.5
            end,
            onSelect = function(data)
                TriggerEvent('police:client:PickupSpikeStrip', NetworkGetNetworkIdFromEntity(data.entity))
            end
        }
    })

    local policeModels = {}
    for _, object in pairs(sharedConfig.objects) do
        policeModels[#policeModels + 1] = object.model
    end

    exports.ox_target:addModel(policeModels, {
        {
            label = 'Remove object',
            icon = 'fa-solid fa-hand',
            groups = 'police',
            distance = 3.5,
            canInteract = function(_, distance)
                return isOnDutyLeo() and not cache.vehicle and distance <= 3.5
            end,
            onSelect = function(data)
                TriggerEvent('police:client:deleteObject', NetworkGetNetworkIdFromEntity(data.entity))
            end
        }
    })
end

local function registerCleanupRadial()
    if not (lib and lib.registerRadial and lib.showRadial) then return end

    lib.registerRadial({
        id = 'police_cleanup',
        items = {
            {
                label = 'Pickup spike strip',
                icon = 'ban',
                onSelect = function()
                    TriggerEvent('police:client:PickupSpikeStrip')
                end
            },
            {
                label = 'Remove object',
                icon = 'hand',
                onSelect = function()
                    TriggerEvent('police:client:deleteObject')
                end
            }
        }
    })

    lib.addKeybind({
        name = 'policeCleanupRadial',
        description = 'Open police clean-up radial',
        defaultKey = 'F7',
        onPressed = function()
            if not isOnDutyLeo() or cache.vehicle then return end
            lib.showRadial('police_cleanup')
        end
    })
end

CreateThread(function()
    registerCleanupRadial()
    addPlayerTargets()
    addWorldTargets()
end)
