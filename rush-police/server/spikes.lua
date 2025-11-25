
local spikes = {}
spikes.objects = {}

function spikes.generateId()
    return math.random(1111, 9999)
end

-- Events

RegisterNetEvent('brazzers-police:server:placeSpike', function(data)
    local id, model, coords, zoffset = spikes.generateId(), data.model, data.coords, data.zoffset
    spikes.objects[id] = {id = id, model = model, coords = coords, zoffset = zoffset}
    TriggerClientEvent('brazzers-police:client:placeSpike', -1, {id = id, model = model, coords = coords, zoffset = zoffset})

    SetTimeout(30000, function()
        if not spikes.objects[id] then return end
        spikes.objects[id] = nil
        TriggerClientEvent('brazzers-police:client:removeSpikes', -1, id)
    end)
end)

RegisterNetEvent('brazzers-police:server:removeSpikes', function(id)
    if not spikes.objects[id] then return end
    spikes.objects[id] = nil
    TriggerClientEvent('brazzers-police:client:removeSpikes', -1, id)
end)

-- Callbacks

lib.callback.register('brazzers-police:server:getSpikes', function()
    return spikes.objects
end)