local Brazzers = exports['brazzers-lib']:getLib()

-- Functions

local function getBoatModel()
    local PlayerData = QBCore.Functions.GetPlayerData()
    local job = PlayerData.job.name
    if job == 'police' or job == 'sasp' or job == 'bcso' then
        return 'rhpdpred'
    elseif job == 'ems' then
        return 'dinghy'
    end
end

local function nearStation()
    local pedCoords = GetEntityCoords(cache.ped)
    for _, v in pairs(Config.Locations["stations"]) do
        local coords = vector3(v.coords.x, v.coords.y, v.coords.z)
        local dist = #(pedCoords - coords)

        if dist <= 70 then
            return true
        end
    end
end

local function openArmory()
    if not isPolice() then return end
    if not exports.ox_inventory:openInventory('shop', {type = 'police_shop'}) then
        local success = lib.callback.await('brazzers-police:server:registerShops', false, 'police_shop')
        if not success then return end
        exports.ox_inventory:openInventory('shop', {type = 'police_shop'})
    end
end

local function openStash()
    local cid, name, slots, weight = exports['brazzers-lib']:getCID(), 'Police Stash', 30, 1000000
    if not exports.ox_inventory:openInventory('stash', 'police_stash_'..cid) then
        local success = lib.callback.await('brazzers-police:server:registerStashes', false, 'police_stash_'..cid, slots, weight, name)
        if not success then return end
        exports.ox_inventory:openInventory('stash', 'police_stash_'..cid)
    end
end

local function openTrash()
    local name, slots, weight = 'Police Trash', 1000, 1000000000
    if not exports.ox_inventory:openInventory('stash', 'police_trash') then
        local success = lib.callback.await('brazzers-police:server:registerStashes', false, 'police_trash', slots, weight, name)
        if not success then return end
        exports.ox_inventory:openInventory('stash', 'police_trash')
    end
end

local function helicopterAction(location)
    local fuel = 100.0
    if Config.Debug then fuel = 25.0 end
   
    if IsPedInAnyHeli(cache.ped, false) then
        local vehicle = GetVehiclePedIsIn(cache.ped)
        TaskLeaveVehicle(cache.ped, vehicle, 0)
        Wait(2500)
        QBCore.Functions.DeleteVehicle(vehicle)
        return
    end

    local coords = location
    if not coords then coords = GetEntityCoords(cache.ped) end
    local job = QBCore.Functions.GetPlayerData().job.name
    
    if IsAnyVehicleNearPoint(coords.x, coords.y, coords.z, 3.0) then
        TriggerEvent('DoLongHudText', 'Something is in the way', 2)
        return
    end

    QBCore.Functions.SpawnVehicle(Config.Helicopter[job].heli, function(veh)
        SetVehicleLivery(veh , Config.Helicopter[job].livery)
        SetVehicleMod(veh, 0, 48)
        SetVehicleNumberPlateText(veh, "ZULU"..tostring(math.random(1000, 9999)))
        SetEntityHeading(veh, coords.w)
        exports['ox_fuel']:SetFuel(veh, fuel)
        TaskWarpPedIntoVehicle(cache.ped, veh, -1)
        local plate = GetVehicleNumberPlateText(veh)
        TriggerEvent('vehiclekeys:client:setOwner', plate)
        SetVehicleEngineOn(veh, true, true)
    end, coords, true)
end

-- Fridge logic 

local function openFridge()
    local name, slots, weight = 'DPS Fridge', 60, 1000000
    for k, v in pairs((Config.Locations["fridges"])) do 
        if not exports.ox_inventory:openInventory('stash', 'dps_fridge_'..k) then 
            local success = lib.callback.await('brazzers-police:server:registerStashes', false, 'dps_fridge_'..k, slots, weight, name)
            if not success then return end 
            exports.ox_inventory:openInventory('stash', 'dps_fridge_'..k)
        end
    end
end

local function refuelhelicopterAction(helipad)
    local heliDist = -1
    local heli = nil
    local vehicles = GetGamePool('CVehicle')
    helipad = vec3(helipad.x,helipad.y, helipad.z) 
    for i = 1, #vehicles do
        local vehicle = vehicles[i]
        if DoesEntityExist(vehicle) and GetVehicleClass(vehicle) == 15 then
            local vehicleCoords = GetEntityCoords(vehicle)
            local dist = #(helipad - vehicleCoords)
            if heliDist == -1 or dist < heliDist then
                heliDist = dist
                heli = vehicle
            end
        end
    end

    local refueltime = 48000
    if Config.Debug then refueltime = 2000 end
    QBCore.Functions.Progressbar("refuel_heli", 'Refueling Helicopter', refueltime, false, true, {
        disableMovement = true,
        disableCarMovement = true,
        disableMouse = false,
        disableCombat = true,
    }, {}, {}, {}, function()
        ClearPedTasks(cache.ped)
        exports['rush-fuel']:SetFuel(heli, 100.0)
    end, function()
        QBCore.Functions.Notify('Canceled', 'error')
        ClearPedTasks(cache.ped)
    end)
end

local function hangarhelicopterAction(helipad)
    local heliDist = -1
    local heli = nil
    local vehicles = GetGamePool('CVehicle')
    helipad = vec3(helipad.x,helipad.y, helipad.z) 
    for i = 1, #vehicles do
        local vehicle = vehicles[i]
        if DoesEntityExist(vehicle) and GetVehicleClass(vehicle) == 15 then
            local vehicleCoords = GetEntityCoords(vehicle)
            local dist = #(helipad - vehicleCoords)
            if heliDist == -1 or dist < heliDist then
                heliDist = dist
                heli = vehicle
            end
        end
    end
    
    QBCore.Functions.Progressbar("hangar_heli", 'Placing Helicopter in Hangar', 8000, false, true, {
        disableMovement = true,
        disableCarMovement = true,
        disableMouse = false,
        disableCombat = true,
    }, {}, {}, {}, function()
        ClearPedTasks(cache.ped)
        QBCore.Functions.DeleteVehicle(heli)
    end, function()
        QBCore.Functions.Notify('Canceled', 'error')
        ClearPedTasks(cache.ped)
    end)
end

local function openClothing(outfit)
    if outfit then
        TriggerEvent('qb-clothing:client:openOutfitMenu')
        return
    end
    exports['illenium-appearance']:OpenClothingShop(true)
end

local function signIn()
    TriggerServerEvent("QBCore:ToggleDuty")
end

local function pdControls(cb)
    CreateThread(function()
        check = true
        while check do
            if IsControlJustPressed(0, 38) then
                exports['qb-core']:KeyPressed(38)
                cb()
            end
            Wait(0)
        end
    end)
end

function isPolice()
    local PlayerData = QBCore.Functions.GetPlayerData()
    if (PlayerData.job.type == 'leo' and PlayerData.job.onduty) then
        return true
    end
end

function isEMS()
    local PlayerData = QBCore.Functions.GetPlayerData()
    if (PlayerData.job.name == 'ems' and PlayerData.job.onduty) then
        return true
    end
end

--Events

RegisterNetEvent('brazzers-police:client:openEvidence', function(index)
    if not nearStation() then return TriggerEvent('DoLongHudText', 'You\'re not near a police station', 2) end
    local name, slots, weight = 'Evidence #'..index, 500, 4000000
    if not exports.ox_inventory:openInventory('stash', 'evidence_'..index) then
        local success = lib.callback.await('brazzers-police:server:registerStashes', false, 'evidence_'..index, slots, weight, name)
        if not success then return end
        exports.ox_inventory:openInventory('stash', 'evidence_'..index)
    end
end)

RegisterNetEvent("brazzers-police:client:SpawnBoat", function()
	local inWater = IsEntityInWater(cache.ped)
    if not inWater then return TriggerEvent("DoLongHudText", 'You\'re not inside the water!', 2) end

        QBCore.Functions.SpawnVehicle(getBoatModel(), function(veh)
            SetVehicleNumberPlateText(veh, "BOAT"..tostring(math.random(1000, 9999)))
            SetEntityHeading(veh, 109.5)
            exports["rush-fuel"]:SetFuel(veh, 100)
            TaskWarpPedIntoVehicle(ped, veh, -1)
            local plate = GetVehicleNumberPlateText(veh)
            TriggerEvent('brazzers-vehiclekeys:client:setOwner', plate)
            SetVehicleEngineOn(veh, true, true)
        end)
end)

RegisterNetEvent("brazzers-police:client:RemoveSpawnedBoat", function()
    local ped = cache.ped
    local vehicle = GetVehiclePedIsIn(ped, false) 
    QBCore.Functions.DeleteVehicle(vehicle)
end)

RegisterNetEvent("brazzers-police:client:lockedStorage", function()
    local plate = QBCore.Functions.GetPlate(GetVehiclePedIsIn(cache.ped))
    QBCore.Functions.Progressbar("locked-storage", "Unlocking Storage", 1000, false, false, {
        disableMovement = true,
        disableCarMovement = false,
        disableMouse = false,
        disableCombat = false,
    }, {}, {}, {}, function()
        local name, slots, weight = 'Vehicle Locker #'..plate, 5, 150000
        LocalPlayer.state:set('invBusy', false, false)
        if not exports.ox_inventory:openInventory('stash', 'vehicle_storage_'..plate) then
            local success = lib.callback.await('brazzers-police:server:registerStashes', false, 'vehicle_storage_'..plate, slots, weight, name)
            if not success then return end
            Wait(500)
            exports.ox_inventory:openInventory('stash', 'vehicle_storage_'..plate)
        end
    end)
end)

-- Commands

RegisterCommand("pduty", function(source, args, raw)
    local playerData = QBCore.Functions.GetPlayerData()
    if not playerData or not playerData.job then return end

    local job = playerData.job.name
    local allowedJobs = {
        police = true,
        bcso = true,
        state = true,
        ambulance = true,
        doj = true,
        sasp = true
    }

    if allowedJobs[job] then
        signIn()
    else
        lib.notify({
            title = 'Access Denied',
            description = 'You are not authorized to use this command.',
            type = 'error'
        })
    end
end)


-- Threads

CreateThread(function()

   -- DUTY TOGGLE (LSPD / BCSO / SASP / EMS)
for k, v in pairs(Config.Locations["duty"]) do
    exports.ox_target:addBoxZone({
        coords = vec3(v.x, v.y, v.z),
        size = vec3(1.5, 1.5, 2),
        rotation = 0,
        debug = Config.Debug,
        options = {
            {
                name = 'duty_toggle_'..k,
                icon = 'fa-solid fa-id-badge',
                label = 'Toggle Duty',
                groups = {'police', 'bcso', 'sasp', 'ems'}, -- only visible for these jobs
                distance = 2.0,
                onSelect = function()
                    local PlayerData = exports.qbx_core:GetPlayerData()
                    if not PlayerData or not PlayerData.job then return end

                    local jobName = PlayerData.job.name
                    local validJobs = { police = true, bcso = true, sasp = true, ems = true }
                    if not validJobs[jobName] then
                        lib.notify({
                            title = "Duty",
                            description = "Access denied — this area is for emergency personnel only.",
                            type = "error"
                        })
                        return
                    end

                    -- Toggle duty
                    TriggerServerEvent('QBCore:ToggleDuty')

                    -- One clean client notification only
                    if PlayerData.job.onduty then
                        lib.notify({
                            title = "Duty",
                            description = "You are now off duty.",
                            type = "error"
                        })
                    else
                        lib.notify({
                            title = "Duty",
                            description = "You are now on duty.",
                            type = "success"
                        })
                    end
                end
            }
        }
    })
end



    -- ARMORY
    for k, v in pairs(Config.Locations["armory"]) do
        exports.ox_target:addBoxZone({
            coords = vec3(v.x, v.y, v.z),
            size = vec3(1.5, 2.5, 2),
            rotation = 0,
            debug = Config.Debug,
            options = {
                {
                    name = 'pd_armory_'..k,
                    icon = 'fa-solid fa-gun',
                    label = 'Open Armory',
                    groups = Config.PoliceGroups,
                    distance = 2.0,
                    onSelect = function()
                        openArmory()
                    end
                },
                {
                    name = 'pd_stash_'..k,
                    icon = 'fa-solid fa-box',
                    label = 'Open Stash',
                    groups = Config.PoliceGroups,
                    distance = 2.0,
                    onSelect = function()
                        openStash()
                    end
                }
            }
        })
    end

    -- CLOTHING
    for k, v in pairs(Config.Locations["clothing"]) do
        exports.ox_target:addBoxZone({
            coords = vec3(v.x, v.y, v.z),
            size = vec3(4, 4, 2),
            rotation = 0,
            debug = Config.Debug,
            options = {
                {
                    name = 'pd_clothing_'..k,
                    icon = 'fa-solid fa-shirt',
                    label = 'Change Clothing',
                    groups = Config.PoliceGroups,
                    distance = 2.0,
                    onSelect = function()
                        openClothing(false)
                    end
                },
                {
                    name = 'pd_outfits_'..k,
                    icon = 'fa-solid fa-user-tie',
                    label = 'Outfits',
                    groups = Config.PoliceGroups,
                    distance = 2.0,
                    onSelect = function()
                        openClothing(true)
                    end
                }
            }
        })
    end

    -- FRIDGES
    for k, v in pairs(Config.Locations["fridges"]) do
        exports.ox_target:addBoxZone({
            coords = vec3(v.x, v.y, v.z),
            size = vec3(1, 1, 2),
            rotation = -20,
            debug = Config.Debug,
            options = {
                {
                    name = 'pd_fridge_'..k,
                    icon = 'fa-solid fa-snowflake',
                    label = 'Access Fridge',
                    groups = Config.PoliceGroups,
                    distance = 2.0,
                    onSelect = function()
                        openFridge()
                    end
                }
            }
        })
    end

    -- TRASH
    for k, v in pairs(Config.Locations["trash"]) do
        exports.ox_target:addBoxZone({
            coords = vec3(v.x, v.y, v.z),
            size = vec3(3, 3, 2),
            rotation = 0,
            debug = Config.Debug,
            options = {
                {
                    name = 'pd_trash_'..k,
                    icon = 'fa-solid fa-trash',
                    label = 'Open Trash',
                    groups = Config.PoliceGroups,
                    distance = 2.0,
                    onSelect = function()
                        openTrash()
                    end
                }
            }
        })
    end

    -- HELICOPTER NPC TARGETS
    for k, v in pairs(Config.Locations["helicopter"]) do
        local ped = Brazzers.addPed({
            model = 's_m_m_pilot_02',
            dist = 300,
            coords = vec3(v.ped.x, v.ped.y, v.ped.z),
            heading = v.ped.w,
            snapToGround = true,
            scenario = false,
            freeze = true,
            invincible = true,
            tempevents = true,
            id = 'police_'..k,
        })

        exports.ox_target:addLocalEntity(ped, {
            {
                icon = "fas fa-helicopter",
                label = "Take out Helicopter",
                groups = Config.PoliceGroups,
                distance = 2.0,
                onSelect = function()
                    helicopterAction(v.spawn)
                end
            },
            {
                icon = "fa-solid fa-gas-pump",
                label = "Fuel Helicopter",
                groups = Config.PoliceGroups,
                distance = 2.0,
                onSelect = function()
                    refuelhelicopterAction(v.spawn)
                end
            },
            {
                icon = "fas fa-parking",
                label = "Hangar Helicopter",
                groups = Config.PoliceGroups,
                distance = 2.0,
                onSelect = function()
                    hangarhelicopterAction(v.spawn)
                end
            }
        })
    end
end)


CreateThread(function()
    exports.ox_inventory:displayMetadata('locker', 'Locker')
    exports.ox_inventory:displayMetadata('evidence', 'Evidence')

    for _, station in pairs(Config.Locations["stations"]) do
        local blip = AddBlipForCoord(station.coords.x, station.coords.y, station.coords.z)
        SetBlipSprite(blip, 60)
        SetBlipAsShortRange(blip, true)
        SetBlipScale(blip, 0.6)
        SetBlipColour(blip, 3)
        BeginTextCommandSetBlipName("STRING")
        AddTextComponentString(station.label)
        EndTextCommandSetBlipName(blip)
    end
end)
