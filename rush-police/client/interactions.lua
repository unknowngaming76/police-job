
local interactions = {}

local hardCuffed, cuffType, attempts = false, 0, 1
local isHandcuffed, isEscorted = false, false
local busy, escorting = false, false

-- Functions

---Check for closest player within distance or 2.5 units
---@param distance number?
---@return number? playerId
---@return number? playerPed
local function getClosestPlayer(distance)
    local coords = GetEntityCoords(cache.ped)
    local player, playerPed = lib.getClosestPlayer(coords, (distance or 2.5))
    if not player then
        return
    end
    return player, playerPed
end

local function handCuffAnimation()
    lib.requestAnimDict('mp_arrest_paired', 100)
    Wait(100)
    TaskPlayAnim(cache.ped, "mp_arrest_paired", "cop_p2_back_right", 3.0, 3.0, -1, 48, 0, 0, 0, 0)
    TriggerServerEvent('InteractSound_SV:PlayWithinDistance', 5, 'Cuff', 0.2)
    Wait(3500)
    TaskPlayAnim(cache.ped, "mp_arrest_paired", "exit", 3.0, 3.0, -1, 48, 0, 0, 0, 0)
end

local function unhandCuffAnimation()
    lib.requestAnimDict('mp_arresting', 100)
    Wait(100)
    TaskPlayAnim(cache.ped, 'mp_arresting', 'a_uncuff', 8.0, -8, -1, 2, 0, 0, 0, 0)
    TriggerServerEvent('InteractSound_SV:PlayWithinDistance', 5, 'Uncuff', 0.2)
    Wait(3500)
    ClearPedTasks(cache.ped)
end

local function getCuffedAnimation(playerId)
    local cuffer = GetPlayerPed(GetPlayerFromServerId(playerId))
    local heading = GetEntityHeading(cuffer)
    TriggerServerEvent('InteractSound_SV:PlayOnSource', 'Cuff', 0.2)
    lib.requestAnimDict('mp_arrest_paired')
    local offset = GetOffsetFromEntityInWorldCoords(cuffer, 0.0, 0.45, 0.0)
    SetEntityCoords(cache.ped, offset.x, offset.y, offset.z, true, false, false, false)
    Wait(100)
    SetEntityHeading(cache.ped, heading)
    TaskPlayAnim(cache.ped, 'mp_arrest_paired', 'crook_p2_back_right', 3.0, 3.0, -1, 32, 0, false, false, false)
    Wait(2500)
end

local function escortActions()
    DisableAllControlActions(0)
    EnableControlAction(0, 1, true)
    EnableControlAction(0, 2, true)
    EnableControlAction(0, 245, true)
    EnableControlAction(0, 38, true)
    EnableControlAction(0, 322, true)
    EnableControlAction(0, 249, true)
    EnableControlAction(0, 46, true)
end

local function handcuffActions()
    DisableControlAction(0, 24, true) -- Attack
    DisableControlAction(0, 257, true) -- Attack 2
    DisableControlAction(0, 25, true) -- Aim
    DisableControlAction(0, 263, true) -- Melee Attack 1

    DisableControlAction(0, 45, true) -- Reload
    DisableControlAction(0, 22, true) -- Jump
    DisableControlAction(0, 44, true) -- Cover
    DisableControlAction(0, 37, true) -- Select Weapon
    DisableControlAction(0, 23, true) -- Also 'enter'?

    DisableControlAction(0, 288, true) -- Disable phone
    DisableControlAction(0, 289, true) -- Inventory
    DisableControlAction(0, 170, true) -- Animations
    DisableControlAction(0, 167, true) -- Job

    DisableControlAction(0, 26, true) -- Disable looking behind
    DisableControlAction(0, 73, true) -- Disable clearing animation
    DisableControlAction(2, 199, true) -- Disable pause screen

    DisableControlAction(0, 59, true) -- Disable steering in vehicle
    DisableControlAction(0, 71, true) -- Disable driving forward in vehicle
    DisableControlAction(0, 72, true) -- Disable reversing in vehicle

    DisableControlAction(2, 36, true) -- Disable going stealth
    DisableControlAction(0, 21, true) -- Disable running

    DisableControlAction(0, 264, true) -- Disable melee
    DisableControlAction(0, 257, true) -- Disable melee
    DisableControlAction(0, 140, true) -- Disable melee
    DisableControlAction(0, 141, true) -- Disable melee
    DisableControlAction(0, 142, true) -- Disable melee
    DisableControlAction(0, 143, true) -- Disable melee
    DisableControlAction(0, 75, true)  -- Disable exit vehicle
    DisableControlAction(27, 75, true) -- Disable exit vehicle
    EnableControlAction(0, 249, true) -- Added for talking while cuffed
    EnableControlAction(0, 46, true)  -- Added for talking while cuffed
    EnableControlAction(0, 212, true) -- Scoreboard
end

local function escortingActions()
    if not IsPedSwimming(cache.ped) then
        DisableControlAction(0, 21, true) -- disable sprint
    end
    DisableControlAction(0, 24, true) -- disable attack
    DisableControlAction(0, 25, true) -- disable aim
    DisableControlAction(0, 47, true) -- disable weapon
    DisableControlAction(0, 58, true) -- disable weapon
    DisableControlAction(0, 71, true) -- veh forward
    DisableControlAction(0, 72, true) -- veh backwards
    DisableControlAction(0, 63, true) -- veh turn left
    DisableControlAction(0, 64, true) -- veh turn right
    DisableControlAction(0, 263, true) -- disable melee
    DisableControlAction(0, 264, true) -- disable melee
    DisableControlAction(0, 257, true) -- disable melee
    DisableControlAction(0, 140, true) -- disable melee
    DisableControlAction(0, 141, true) -- disable melee
    DisableControlAction(0, 142, true) -- disable melee
    DisableControlAction(0, 143, true) -- disable melee
end

local function handcuffedEscorted()
    local sleep = 1000
    local anim = {{dict = 'mp_arresting', anim = 'idle'}, {dict = 'mp_arrest_paired', anim = 'crook_p2_back_right'}}

    --if not IsLoggedIn then return sleep end
    if isEscorted then
        sleep = 0
        escortActions()
    end

    if escorting then
        sleep = 0
        escortingActions()
    end

    if not isHandcuffed then return sleep end

    sleep = 0
    handcuffActions()
    if exports['rush-ems']:IsDead() then return sleep end
    for i = 1, #anim do
        if IsEntityPlayingAnim(cache.ped, anim[i].dict, anim[i].anim, 3) then return 0 end
    end
    lib.requestAnimDict('mp_arresting')
    TaskPlayAnim(cache.ped, 'mp_arresting', 'idle', 8.0, -8, -1, cuffType, 0, false, false, false)

    return sleep
end

local function makeBusy()
    if busy then return end
    busy = true
    SetTimeout(5000, function()
        busy = false
    end)
end

local function playerCheck()
    if isEscorted or isHandcuffed then return end
    if IsPedInAnyVehicle(GetPlayerPed(player), false) then return end
    if exports['rush-ems']:IsKnockedOut() then return end
    if exports['rush-ems']:IsDead() then return end
    return true
end

function interactions.getCuffed()
    exports["lb-phone"]:ToggleOpen(false, true)
    
    if not hardCuffed then
        cuffType = 16
        getCuffedAnimation(playerId)
        hardCuffed = true
    elseif hardCuffed then
        cuffType = 49
        getCuffedAnimation(playerId)
        hardCuffed = false
    end

    isHandcuffed = true
    ClearPedTasksImmediately(ped)
end

function interactions.unseatFromVehicle()
    if IsPedRagdoll(cache.ped) then return end

    local player = getClosestPlayer()
    if not player then return end

    local playerId = GetPlayerServerId(player)
    local vehicle = lib.getClosestVehicle(GetEntityCoords(cache.ped), 5, false)
    if not vehicle then return end

    if isEscorted or isHandcuffed then return end
    if not IsPedInAnyVehicle(GetPlayerPed(player), false) then return end
    if exports['rush-ems']:IsKnockedOut() then return end
    if exports['rush-ems']:IsDead() then return end

    QBCore.Functions.Progressbar("interaction_unseat", "Unseating From Vehicle", 3500, false, true, {
        disableMovement = true,
        disableCarMovement = true,
        disableMouse = false,
        disableCombat = true,
    }, {}, {}, {}, function()
        TriggerServerEvent('brazzers-police:server:unseatFromVehicle', playerId)
    end, function()
        ClearPedTasks(cache.ped)
    end)
end

-- Globals

AddEventHandler('QBCore:Client:OnPlayerLoaded', function()
    isHandcuffed = false
    isEscorted = false
    busy = false
    escorting = false
    TriggerServerEvent("police:server:SetHandcuffStatus", false)
end)

AddEventHandler('QBCore:Client:OnPlayerUnload', function()
    isHandcuffed = false
    isEscorted = false
    busy = false
    escorting = false
    ClearPedTasks(cache.ped)
    DetachEntity(cache.ped, true, false)
    TriggerServerEvent("police:server:SetHandcuffStatus", false)
end)

-- Events

RegisterNetEvent('police:client:CuffPlayerSoft', function()
    if IsPedRagdoll(cache.ped) then return end
    if busy then return end

    local player = getClosestPlayer(1.5)
    if not player then return end
    if exports.ox_inventory:Search('count', 'handcuffs') == 0 then
        QBCore.Functions.Notify('No handcuffs', 'error')
        return
    end

    if isEscorted or isHandcuffed then return end
    if IsPedInAnyVehicle(GetPlayerPed(player), false) or cache.vehicle then return end
    makeBusy()

    local playerId = GetPlayerServerId(player)
    TriggerServerEvent('brazzers-police:server:cuffPlayer', playerId)
    handCuffAnimation()
end)

RegisterNetEvent('police:client:unCuffPlayer', function()
    if IsPedRagdoll(cache.ped) then return end
    if busy then return end

    local player = getClosestPlayer(1.5)
    if not player then return end

    local playerId = GetPlayerServerId(player)
    if isEscorted or isHandcuffed then return end
    if IsPedInAnyVehicle(GetPlayerPed(player), false) or cache.vehicle then return end

    local result = lib.callback.await('brazzers-police:server:handcuffStatus', false, playerId)
    if not result then return end
    
    makeBusy()
    unhandCuffAnimation()
    TriggerServerEvent('brazzers-police:server:uncuffPlayer', playerId)
end)

RegisterNetEvent('police:client:PutPlayerInVehicle', function()
    if IsPedRagdoll(cache.ped) then return end

    local player = getClosestPlayer()
    if not player then return end

    if IsPedInAnyVehicle(GetPlayerPed(player), false) then
        interactions.unseatFromVehicle()
        return
    end

    local playerId = GetPlayerServerId(player)
    local vehicle = lib.getClosestVehicle(GetEntityCoords(cache.ped), 5, false)
    if not vehicle then return end

    if isEscorted or isHandcuffed then return end
    if IsPedInAnyVehicle(GetPlayerPed(player), false) or cache.vehicle then return end
    if exports['rush-ems']:IsKnockedOut() then return end
    if exports['rush-ems']:IsDead() then return end

    QBCore.Functions.Progressbar("interaction_seat", "Seating Inside Vehicle", 3500, false, true, {
        disableMovement = true,
        disableCarMovement = true,
        disableMouse = false,
        disableCombat = true,
    }, {}, {}, {}, function()
        TriggerServerEvent('brazzers-police:server:seatInVehicle', playerId)
    end, function()
        ClearPedTasks(cache.ped)
    end)
end)

RegisterNetEvent('police:client:EscortPlayer', function()
    if IsPedRagdoll(cache.ped) then return end

    local player = getClosestPlayer()
    if not player then return end

    local playerId = GetPlayerServerId(player)

    if isEscorted or isHandcuffed then return end
    if IsPedInAnyVehicle(GetPlayerPed(player), false) or cache.vehicle then return end
    if exports['rush-ems']:IsKnockedOut() then return end
    if exports['rush-ems']:IsDead() then return end

    TriggerServerEvent('brazzers-police:server:escortPlayer', playerId)
end)

RegisterNetEvent('brazzers-police:client:friskPlayer', function()
    local player = getClosestPlayer()
    if not player then return end

    local allowed = playerCheck()
    if not allowed then return end

    local playerId = GetPlayerServerId(player)

    TriggerEvent('animations:client:EmoteCommandStart', { "frisk" })
    QBCore.Functions.Progressbar("patting_down", "Patting Down", math.random(5000, 7500), false, true, {
        disableMovement = true,
        disableCarMovement = true,
        disableMouse = false,
        disableCombat = true,
    }, {}, {}, {}, function()
        TriggerEvent('animations:client:EmoteCommandStart', { "c" })
        TriggerServerEvent("brazzers-police:server:friskPlayer", playerId)
    end, function()
        TriggerEvent('animations:client:EmoteCommandStart', { "c" })
    end)
end)

RegisterNetEvent('brazzers-police:client:fingerprintPlayer', function()
    local player = getClosestPlayer()
    if not player then return end

    local allowed = playerCheck()
    if not allowed then return end

    local playerId = GetPlayerServerId(player)
    TriggerEvent('animations:client:EmoteCommandStart', { "texting" })
    QBCore.Functions.Progressbar("patting_down", "Scanning Print", math.random(5000, 7500), false, true, {
        disableMovement = true,
        disableCarMovement = true,
        disableMouse = false,
        disableCombat = true,
    }, {}, {}, {}, function()
        TriggerEvent('animations:client:EmoteCommandStart', { "c" })
        TriggerServerEvent("brazzers-police:server:fingerprintPlayer", playerId)
    end, function()
        TriggerEvent('animations:client:EmoteCommandStart', { "c" })
    end)
end)

RegisterNetEvent('police:client:SearchPlayer', function()
    local player = getClosestPlayer()
    if not player then return end

    local allowed = playerCheck()
    if not allowed then return end

    local playerId = GetPlayerServerId(player)
    exports.ox_inventory:openInventory('player', playerId)
    TriggerServerEvent("police:server:SearchPlayer", playerId)
end)

RegisterNetEvent('police:client:SeizePossessions', function()
    local player = getClosestPlayer()
    if not player then return end

    local allowed = playerCheck()
    if not allowed then return end

    local playerId = GetPlayerServerId(player)
    TriggerServerEvent("police:server:SeizePossessions", playerId)
end)

RegisterNetEvent('police:client:SeizeCash', function()
    local player = getClosestPlayer()
    if not player then return end

    local allowed = playerCheck()
    if not allowed then return end

    local playerId = GetPlayerServerId(player)
    TriggerServerEvent("police:server:SeizeCash", playerId)
end)

RegisterNetEvent('police:client:checkBank', function()
    local player = getClosestPlayer()
    if not player then return end

    local allowed = playerCheck()
    if not allowed then return end

    local playerId = GetPlayerServerId(player)
    TriggerServerEvent("police:server:checkBank", playerId)
end)

RegisterNetEvent('brazzers-police:client:runPlate', function()
    local vehicle = lib.getClosestVehicle(GetEntityCoords(cache.ped), 5, false)
    if not vehicle then return end
    TriggerServerEvent('brazzers-police:server:runPlate', GetVehicleNumberPlateText(vehicle))
end)

RegisterNetEvent('escorting:client:player', function(bool)
    escorting = bool
end)

RegisterNetEvent('police:unmask', function()
    local AnimSet, AnimationOn = "mp_missheist_ornatebank", "stand_cash_in_bag_intro"

    local player = getClosestPlayer()
    if not player then return end

    local allowed = playerCheck()
    if not allowed then return end

    local playerId = GetPlayerServerId(player)
    TriggerServerEvent("brazzers-police:server:unmask", playerId)
    lib.requestAnimDict(AnimSet, 100)
    TaskPlayAnim(cache.ped, AnimSet, AnimationOn, 8.0, -8, -1, 49, 0, 0, 0, 0)
    Wait(500)
    ClearPedTasks(cache.ped)
end)

RegisterNetEvent('police:takeoffShoes', function()
    local AnimSet, AnimationOn = "mp_missheist_ornatebank", "stand_cash_in_bag_intro"

    local player = getClosestPlayer()
    if not player then return end

    local allowed = playerCheck()
    if not allowed then return end

    local playerPed = GetPlayerPed(player)
    local playerId = GetPlayerServerId(player)
    local shoeType = GetPedDrawableVariation(playerPed, 6)

    if GetEntityModel(playerPed) == GetHashKey('mp_f_freemode_01') then
        if shoeType == 35 then return end
    end

    if GetEntityModel(playerPed) == GetHashKey('mp_m_freemode_01') then 
        if shoeType == 34 then return end 
    end
 
    TriggerServerEvent('brazzers-police:server:takeoffShoes', playerId)
    lib.requestAnimDict(AnimSet, 100)
    TaskPlayAnim(cache.ped, AnimSet, AnimationOn, 8.0, -8, -1, 49, 0, 0, 0, 0)
    Wait(500)
    ClearPedTasks(cache.ped)
end)

RegisterNetEvent('police:client:RobPlayer', function()
    local player = getClosestPlayer()
    if not player then return end

    local allowed = playerCheck()
    if not allowed then return end

    local playerPed = GetPlayerPed(player)
    local playerId = GetPlayerServerId(player)

    QBCore.Functions.Progressbar("robbing_player", 'Robbing Person...', 12000, false, true, {
        disableMovement = true,
        disableCarMovement = true,
        disableMouse = false,
        disableCombat = true,
    }, {
        animDict = "random@shop_robbery",
        anim = "robbery_action_b",
        flags = 16,
    }, {}, {}, function() -- Done
        local plyCoords = GetEntityCoords(playerPed)
        local pos = GetEntityCoords(cache.ped)

        local allowed = playerCheck()
        if not allowed then return end

        if #(pos - plyCoords) < 2.5 then
            StopAnimTask(ped, "random@shop_robbery", "robbery_action_b", 1.0)
            exports.ox_inventory:openInventory('player', playerId)
        else
            QBCore.Functions.Notify('No one nearby', "error")
        end
    end, function() -- Cancel
        StopAnimTask(cache.ped, "random@shop_robbery", "robbery_action_b", 1.0)
        QBCore.Functions.Notify('Canceled', "error")
    end)
end)

-- Callback

lib.callback.register('brazzers-police:client:cuffPlayer', function(police)
    local retval = false

    if exports['rush-ems']:IsKnockedOut() then interactions.getCuffed() return true end
    if exports['rush-ems']:IsDead() then interactions.getCuffed() return true end
    if isHandcuffed then interactions.getCuffed() return true end

    local difficulty = ((attempts > 3) and 1) or Config.Difficulty[attempts]
    
    exports['unknown_minigame']:StartLockPickCircle(1, difficulty, function(success)
        if success then
            attempts += 1
            retval = false
            DetachEntity(cache.ped, true, false)
            ClearPedTasksImmediately(cache.ped)
        else
            if cache.weapon ~= `WEAPON_UNARMED` then
                SetCurrentPedWeapon(cache.ped, `WEAPON_UNARMED`, true)
            end
            interactions.getCuffed()
            attempts = 1
            retval = true
            if police then
                cuffing.addUser()
            end
        end
    end)

    return retval
end)

lib.callback.register('brazzers-police:client:uncuffPlayer', function()
    if not isHandcuffed then return end

    hardCuffed = false
    isHandcuffed = false
    isEscorted = false
    attempts = 1
    DetachEntity(cache.ped, true, false)
    ClearPedTasksImmediately(cache.ped)

    if cache.weapon ~= `WEAPON_UNARMED` then
        SetCurrentPedWeapon(cache.ped, `WEAPON_UNARMED`, true)
    end

    return true
end)

lib.callback.register('brazzers-police:client:escortPlayer', function(playerId)
    if not isEscorted then
        isEscorted = true
        local dragger = GetPlayerPed(GetPlayerFromServerId(playerId))
        SetEntityCoords(cache.ped, GetOffsetFromEntityInWorldCoords(dragger, 0.0, 0.45, 0.0))
        AttachEntityToEntity(cache.ped, dragger, 11816, 0.45, 0.45, 0.0, 0.0, 0.0, 0.0, false, false, false, false, 2, true)
    else
        isEscorted = false
        DetachEntity(cache.ped, true, false)
    end

    TriggerEvent('hospital:client:isEscorted', isEscorted)

    return isEscorted
end)

lib.callback.register('brazzers-police:client:seatInVehicle', function()
    if not isHandcuffed and not isEscorted then return end

    local coords = GetEntityCoords(cache.ped)
    local vehicle = lib.getClosestVehicle(coords)
    if not DoesEntityExist(vehicle) then return end

    for i = GetVehicleMaxNumberOfPassengers(vehicle), 0, -1 do
        if IsVehicleSeatFree(vehicle, i) then
            isEscorted = false
            TriggerEvent('hospital:client:isEscorted', isEscorted)
            ClearPedTasks(cache.ped)
            DetachEntity(cache.ped, true, false)
            Wait(100)
            SetPedIntoVehicle(cache.ped, vehicle, i)
            return true
        end
    end
end)

lib.callback.register('brazzers-police:client:unseatFromVehicle', function(playerId, cop)
    if not exports['rush-ems']:IsKnockedOut() and not exports['rush-ems']:IsDead() and not isHandcuffed then return end
    if not cache.vehicle then return end
    TaskLeaveVehicle(cache.ped, cache.vehicle, 16)

    if not cop then return false end

    if not isEscorted then
        isEscorted = true
        local dragger = GetPlayerPed(GetPlayerFromServerId(playerId))
        SetEntityCoords(cache.ped, GetOffsetFromEntityInWorldCoords(dragger, 0.0, 0.45, 0.0))
        AttachEntityToEntity(cache.ped, dragger, 11816, 0.45, 0.45, 0.0, 0.0, 0.0, 0.0, false, false, false, false, 2, true)
    else
        isEscorted = false
        DetachEntity(cache.ped, true, false)
    end

    TriggerEvent('hospital:client:isEscorted', isEscorted)

    return isEscorted
end)

lib.callback.register('brazzers-police:client:unmask', function(playerId)
    lib.requestAnimDict('missheist_agency2ahelmet', 100)
    TaskPlayAnim(cache.ped, "missheist_agency2ahelmet", "take_off_helmet_stand", 4.0, 3.0, -1, 49, 1.0, 0, 0, 0)
    Wait(800)
    SetPedComponentVariation(cache.ped, 1, -1, -1, -1) -- Mask
    SetPedComponentVariation(cache.ped, 3, 15, 0, 0) -- Glasses
    ClearPedProp(cache.ped, 0)
    ClearPedProp(cache.ped, 1)
    ClearPedTasks(cache.ped)
    return true
end)

lib.callback.register('brazzers-police:client:takeoffShoes', function(playerId)
    if not IsEntityPlayingAnim(cache.ped, "missminuteman_1ig_2", "handsup_base", 3) and not IsEntityPlayingAnim(cache.ped, "mp_arresting", "idle", 3) and not IsEntityPlayingAnim(cache.ped, "switch@trevor@annoys_sunbathers", "trev_annoys_sunbathers_loop_guy", 3) and not exports['rush-ems']:IsDead() and not exports['rush-ems']:IsKnockedOut() then return end
    
    lib.requestAnimDict('missheist_agency2ahelmet', 100)
    TaskPlayAnim(cache.ped, "missheist_agency2ahelmet", "take_off_helmet_stand", 4.0, 3.0, -1, 49, 1.0, 0, 0, 0)
    Wait(800)
    if GetEntityModel(cache.ped) == GetHashKey('mp_f_freemode_01') then
        SetPedComponentVariation(cache.ped, Config.PedComponentVariationMap["shoes"].componentId, Config.PedComponentVariationMap["shoes"]["barefoot"]["female"], 0, 2) -- Set Female Player Barefooted
    else
        SetPedComponentVariation(cache.ped, Config.PedComponentVariationMap["shoes"].componentId, Config.PedComponentVariationMap["shoes"]["barefoot"]["male"], 0, 2) -- Set Male Player Barefooted
    end
    ClearPedProp(cache.ped, 0)
    ClearPedTasks(cache.ped)

    return true
end)

-- Commands

RegisterCommand('+seat', function()
    if isPolice() or isEMS() then
        TriggerEvent("police:client:PutPlayerInVehicle")
    end
end)
RegisterKeyMapping("+seat", "(GOV): Seat/Unseat Person", "keyboard", "K")

RegisterCommand('+cuff', function()
    if isPolice() or isEMS() then
        TriggerEvent("police:client:CuffPlayerSoft")
    end
end)
RegisterKeyMapping("+cuff", "(GOV): Handcuff Person", "keyboard", "O")

RegisterCommand('+uncuff', function()
    if isPolice() or isEMS() then
        TriggerEvent("police:client:unCuffPlayer")
    end
end)
RegisterKeyMapping("+uncuff", "(GOV): Un-Handcuff Person", "keyboard", "I")

RegisterCommand('+escorting', function()
    if isPolice() or isEMS() then
        TriggerEvent("police:client:EscortPlayer")
    end
end)
RegisterKeyMapping("+escorting", "(GOV): Escort Person", "keyboard", "L")

-- Threads

CreateThread(function()
    while true do
        Wait(handcuffedEscorted())
    end
end)

CreateThread(function()
    exports.ox_target:addGlobalVehicle({
        {
            name = 'interactions:runplate',
            icon = 'fa-solid fa-closed-captioning',
            label = 'Run Plate',
            bones = {'boot', 'platelight', 'numberplate', 'bumper_f', 'bumper_r', 'exhaust'},
            canInteract = function()
                if not isPolice() then return end
                return true
            end,
            onSelect = function()
                TriggerEvent('brazzers-police:client:runPlate')
            end
        },
        {
            name = 'interactions:seat',
            icon = 'fa-solid fa-chair',
            label = 'Seat In Vehicle',
            canInteract = function()
                local player = getClosestPlayer()
                if not player then return end
                if IsPedInAnyVehicle(GetPlayerPed(player), false) then return end
                if not escorting then return end
                return true
            end,
            onSelect = function()
                TriggerEvent('police:client:PutPlayerInVehicle')
            end
        },
        {
            name = 'interactions:unseat',
            icon = 'fa-solid fa-chair',
            label = 'Unseat From Vehicle',
            canInteract = function()
                local player = getClosestPlayer()
                if not player then return end
                if not IsPedInAnyVehicle(GetPlayerPed(player), false) then return end
                return true
            end,
            onSelect = function()
                interactions.unseatFromVehicle()
            end
        },
    })
end)

CreateThread(function()
    isHandcuffed = false
    isEscorted = false
    busy = false
    escorting = false
    TriggerServerEvent("police:server:SetHandcuffStatus", false)
end)

-- Exports

exports('IsHandcuffed', function() return isHandcuffed end)
exports('IsEscortingPlayer', function() return escorting end)