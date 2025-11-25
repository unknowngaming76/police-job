local ox_inventory = exports.ox_inventory

local spikes = {}
spikes.objects = {}
spikes.wheels = {
    wheel_lf = 0,
    wheel_rf = 1,
    wheel_rr = 5,
    wheel_lr = 4,
}

-- Functions

local function PedFaceCoord(pPed, pCoords)
    TaskTurnPedToFaceCoord(pPed, pCoords.x, pCoords.y, pCoords.z)
    Wait(100)
    while GetScriptTaskStatus(pPed, 0x574bb8f5) == 1 do
        Wait(0)
    end
end

local function createObject(id, coords, offset)
    local model = spikes.objects[id].model
    lib.requestModel(model)

    local spawnedObject = CreateObject(model, coords.x, coords.y, coords.z - offset, 0, 0, 0)
    FreezeEntityPosition(spawnedObject, true)
    SetEntityHeading(spawnedObject, coords.w)
    PlaceObjectOnGroundProperly(spawnedObject)
    return spawnedObject
end

local function removeObject(id)
    if not spikes.objects[id] then return end

    DeleteObject(spikes.objects[id].object)
    spikes.objects[id].rendered = false
    spikes.objects[id].object = nil
end

local function getIDByEntity(entity)
    for _, v in pairs(spikes.objects) do
        if v.object == entity then
            return v, v.id
        end
    end
    return false
end

local function isTouching(coords, spike)
    local min, max = GetModelDimensions(GetEntityModel(spike))
    local size = max - min
    local w, l, h = size.x, size.y, size.z

    local offset1 = GetOffsetFromEntityInWorldCoords(spike, 0.0, l/2, h*-1)
    local offset2 = GetOffsetFromEntityInWorldCoords(spike, 0.0, l/2 * -1, h)

    return IsPointInAngledArea(coords, offset1, offset2, w*2, 0, false)
end

local function handleSpikes(spike)
    local vehicle = cache.vehicle
    if not vehicle then return end

    if IsEntityTouchingEntity(vehicle, spike.object) then
        for name, id in pairs(spikes.wheels) do
            if not IsVehicleTyreBurst(vehicle, id, false) then
                if isTouching(GetWorldPositionOfEntityBone(vehicle, GetEntityBoneIndexByName(vehicle, name)), spike.object) then
                    SetVehicleTyreBurst(vehicle, id, 1, 1148846080)

                    SetTimeout(1500, function()
                        TriggerServerEvent('brazzers-police:server:removeSpikes', spike.id)
                    end)
                end
            end
        end
    end
end

-- Handlers

AddEventHandler('onResourceStop', function(resourceName)
    if GetCurrentResourceName() == resourceName then
        for _, v in pairs(spikes.objects) do
            if v.rendered then
                DeleteObject(v.object)
            end
        end
    end
end)

-- Events

RegisterNetEvent('brazzers-police:client:placeSpike', function(data)
    spikes.objects[data.id] = data
end)

RegisterNetEvent('brazzers-police:client:removeSpikes', function(id)
    removeObject(id)
    spikes.objects[id] = nil
end)

-- Item

exports('spikestrip', function(data, slot)
    local model = `p_ld_stinger_s`
    local text = "[E] Place | [X] Cancel | [SCROLL UP/DOWN] Change Heading"
    local coords, heading = exports['brazzers-objects']:placeObject(model, 10.0, true, text, false)
    if not coords or not heading then return end

    PedFaceCoord(ped, coords)
    lib.requestAnimDict('missexile3', 100)
    TaskPlayAnim(cache.ped, "missexile3", "ex03_dingy_search_case_a_michael", 1.0, 1.0, -1, 1, 0, 0, 0, 0)

    ox_inventory:useItem(data, function(data)
        local newCoords = vector4(coords.x, coords.y, coords.z, heading)
        local data = {model = model, coords = newCoords, zoffset = 0}
        TriggerServerEvent('brazzers-police:server:placeSpike', data)
        ClearPedTasks(cache.ped)
    end)
end)

-- Threads

CreateThread(function()
    local result = lib.callback.await('brazzers-police:server:getSpikes')
    spikes.objects = result
end)

CreateThread(function()
    while true do
        local sleep = 1500
        if not spikes.objects then spikes.objects = {} end
        for _, v in pairs(spikes.objects) do
            local ped = cache.ped
            local pos = GetEntityCoords(ped)
            if #(pos - vector3(v.coords.x, v.coords.y, v.coords.z)) < 100 then
                sleep = 0
                if not v.rendered or not DoesEntityExist(v.object) then
                    local model = createObject(v.id, v.coords, v.zoffset)
                    v.rendered = true
                    v.object = model
                end
                handleSpikes(v)
            end
            if #(pos - vector3(v.coords.x, v.coords.y, v.coords.z)) >= 100 and v.rendered then
                if DoesEntityExist(v.object) then
                    removeObject(v.id)
                end
            end
        end
        Wait(sleep)
    end
end)