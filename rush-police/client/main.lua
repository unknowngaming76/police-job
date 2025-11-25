
-- Events

RegisterNetEvent('police:client:BillCommand', function(playerId, price)
    TriggerServerEvent("police:server:BillPlayer", playerId, tonumber(price))
end)

RegisterNetEvent('police:client:EmergencySound', function()
    PlaySound(-1, "Event_Start_Text", "GTAO_FM_Events_Soundset", 0, 0, 1)
end)

RegisterNetEvent('police:chatMessage', function(data)
    if isPolice() or isEMS() then
        TriggerEvent('chat:addMessage', {
            template =
            '<div class="chat-message server" style="background-color: rgba(52, 67, 235, 0.75);"><b>Dispatch - {0}:</b> {1}</div>',
            args = data
        })
    end
end)

RegisterNetEvent('rush-police:client:chatMessage', function(data, emergency)
    local PlayerData = QBCore.Functions.GetPlayerData()

    if (isPolice() or isEMS()) then
        if emergency then
            TriggerEvent('chat:addMessage', {
                template = '<div class="chat-message server" style="background-color: rgba(158, 12, 2, 0.75);"><b>911r -> {0}:</b> {1}</div>',
                args = data
            })
        else
            TriggerEvent('chat:addMessage', {
                template = '<div class="chat-message server" style="background-color: rgba(201, 128, 0, 0.75);"><b>311r -> {0}:</b> {1}</div>',
                args = data
            })
        end
    end
end)

RegisterNetEvent("brazzers-police:officerDownViolent", function()
    local PlayerData = QBCore.Functions.GetPlayerData()
    local name = PlayerData.charinfo.firstname..' '..PlayerData.charinfo.lastname
    TriggerServerEvent('InteractSound_SV:PlayWithinDistance', 12, 'emergency', 0.3)
    exports['rush-dispatch']:alertPoliceViolent(name)
end)

RegisterNetEvent("brazzers-police:officerDownNonViolent", function()
    local PlayerData = QBCore.Functions.GetPlayerData()
    local name = PlayerData.charinfo.firstname..' '..PlayerData.charinfo.lastname
    TriggerServerEvent('InteractSound_SV:PlayWithinDistance', 12, 'emergency', 0.3)
    exports['rush-dispatch']:alertPoliceNonViolent(name)
end)

RegisterNetEvent("brazzers-police:medicDownNonViolent", function()
    local PlayerData = QBCore.Functions.GetPlayerData()
    local name = PlayerData.charinfo.firstname..' '..PlayerData.charinfo.lastname
    TriggerServerEvent('InteractSound_SV:PlayWithinDistance', 12, 'emergency', 0.3)
    exports['rush-dispatch']:alertMedicNonViolent(name)
end)

RegisterNetEvent("brazzers-police:medicDownViolent", function()
    local PlayerData = QBCore.Functions.GetPlayerData()
    local name = PlayerData.charinfo.firstname..' '..PlayerData.charinfo.lastname
    TriggerServerEvent('InteractSound_SV:PlayWithinDistance', 12, 'emergency', 0.3)
    exports['rush-dispatch']:alertMedicViolent(name)
end)

RegisterNetEvent("brazzers-police:injuredPerson", function()
    local PlayerData = QBCore.Functions.GetPlayerData()
    local name = PlayerData.charinfo.firstname..' '..PlayerData.charinfo.lastname
    exports['rush-dispatch']:alertInjuredPerson(name)
    TriggerEvent('rush-radialmenu:injuredcoolDown')
end)


RegisterNetEvent("brazzers-police:client:setVehicleCallsign", function(number)
    local numbers = {}
    for i = 1, #tostring(number) do
        local num = tonumber(string.sub(tostring(number), i, i))
        table.insert(numbers, num)
    end
    if IsPedInAnyVehicle(cache.ped, false) then
        local ped = cache.ped 
        local vehicle = GetVehiclePedIsIn(ped, false) 
        if GetVehicleClass(vehicle) == 18 then
            SetVehicleMod(vehicle, 8, tonumber(numbers[1]))
            SetVehicleMod(vehicle, 9, tonumber(numbers[2]))
            SetVehicleMod(vehicle, 10, tonumber(numbers[3]))
        else
            TriggerEvent("DoLongHudText", 'You cannot do this to this type of vehicle!', 2)
        end
    else
        TriggerEvent("DoLongHudText", 'Get inside a vehicle moron!', 2)
    end
end)

RegisterNetEvent("brazzers-police:client:depotVehicle", function(data)
    local vehicle = QBCore.Functions.GetClosestVehicle()
    local plate = QBCore.Functions.GetPlate(vehicle)
    local vehname = GetDisplayNameFromVehicleModel(GetEntityModel(vehicle)):lower()
    local input

    if data.points and data.points >= 1 then
        input = lib.inputDialog('Incident Report', {
            {type = 'number', label = 'Incident #', description = 'Input an incident # associated with this impound'},
        })
        if not input or not input[1] then return end
    end

    TriggerEvent('animations:client:EmoteCommandStart', {"phonecall"})
    QBCore.Functions.Progressbar("searching-points", "Calling Tow", 6500, false, false, {
        disableMovement = true,
        disableCarMovement = false,
        disableMouse = false,
        disableCombat = true,
    }, {}, {}, {}, function()
        TriggerEvent('animations:client:EmoteCommandStart', {"c"})

        local data = {vehicle = vehname, plate = plate, points = data.points, reason = data.reason, report = input and input[1] or 'N/A'}
        TriggerServerEvent('brazzers-garages:server:pointVehicle', data)
        -- Check for Tow availability

        if data.reason == 'Vehicle Scuff' then
            exports['brazzers-garages']:updateVehicleState(vehicle, plate, true)
            TriggerServerEvent('brazzers-garages:server:depotVehicle', NetworkGetNetworkIdFromEntity(vehicle), plate)
            TriggerEvent('DoLongHudText', 'Vehicle towed')
            return
        end

        --[[local amount = lib.callback.await('brazzers-tow:isEnoughTow')
        if amount < 1 then
            TriggerServerEvent('brazzers-garages:server:depotVehicle', NetworkGetNetworkIdFromEntity(vehicle), plate)
            TriggerEvent('DoLongHudText', 'Vehicle towed')
            return
        end--]]

        TriggerServerEvent("brazzers-tow:server:markForTow", NetworkGetNetworkIdFromEntity(vehicle), vehname, plate)
        TriggerEvent('DoLongHudText', 'A tow driver has been pinged!')

    end, function() -- Cancel
        TriggerEvent('animations:client:EmoteCommandStart', {"c"})
    end)
end)

RegisterNetEvent('brazzers-police:client:depotMenu', function()
    local menu = {}

    for _, v in pairs(Config.Points) do
        menu[#menu+1] = {
            title = v.title,
            description = v.description,
            onSelect = function()
                local data = {points = v.points, reason = v.title}
                if v.depot then
                    TriggerEvent('brazzers-police:client:depotVehicle', data)
                else
                    TriggerEvent('brazzers-police:client:depotOptions', data)
                end
            end,
        }
    end

    lib.registerContext({
        id = 'police_menu_1',
        icon = 'fa-solid fa-handcuffs',
        title = 'Impound Options',
        options = menu
    })
    lib.showContext('police_menu_1')
end)

RegisterNetEvent('brazzers-police:client:depotOptions', function(data)
    local menu = {
        {
            title = "Back",
            icon = 'fa-solid fa-left-long',
            onSelect = function()
                TriggerEvent('brazzers-police:client:depotMenu')
            end,
        },
        {
            title = "Owner was present/ aware of the crime",
            onSelect = function()
                local data = {points = (data.points + 1), reason = data.reason}
                TriggerEvent('brazzers-police:client:depotVehicle', data)
            end,
        },
        {
            title = "Vehicle was tampered with, Owner not present",
            description = "Only 1 strike point can be issued",
            onSelect = function()
                local data = {points = 1, reason = data.reason}
                TriggerEvent('brazzers-police:client:depotVehicle', data)
            end,
        },
        {
            title = "Vehicle was not tampered with, Owner not present",
            description = "Only 1 strike point can be issued",
            onSelect = function()
                local data = {points = 1, reason = data.reason}
                TriggerEvent('brazzers-police:client:depotVehicle', data)
            end,
        },
    }

    lib.registerContext({
        id = 'police_menu_2',
        icon = 'fa-solid fa-handcuffs',
        title = 'Impound Options',
        options = menu
    })
    lib.showContext('police_menu_2')
end)