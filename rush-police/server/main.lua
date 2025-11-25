
local platesRan = {}
local offlineCharges = {
    ["Unauthorized Parking"] = true
}

-- Functions

local function isTargetTooFar(src, targetId, maxDistance)
    local playerPed = GetPlayerPed(src)
    local targetPed = GetPlayerPed(targetId)
    local playerCoords = GetEntityCoords(playerPed)
    local targetCoords = GetEntityCoords(targetPed)
    if #(playerCoords - targetCoords) > maxDistance then
        --DropPlayer(src, 'Attempted exploit abuse')
        return true
    end
    return false
end

local function IsVehicleOwned(plate)
    local result = MySQL.scalar.await('SELECT plate FROM player_vehicles WHERE plate = ?', {plate})
    if result then
        return true
    end
    return false
end

-- Global

AddEventHandler('onServerResourceStart', function(resourceName)
	if resourceName == 'ox_inventory' or resourceName == GetCurrentResourceName() then
		exports.ox_inventory:RegisterShop("police_shop", {
            name = 'Police Armory',
            inventory = Config.Items,
        })
	end
end)

-- Events

RegisterNetEvent('brazzers-police:server:cuffPlayer', function(playerId)
    if isTargetTooFar(source, playerId, 10.0) then return end

    local player = QBCore.Functions.GetPlayer(source)
    local cuffedPlayer = QBCore.Functions.GetPlayer(playerId)
    local isPolice = player.PlayerData.job.type == 'leo'

    local result = lib.callback.await('brazzers-police:client:cuffPlayer', cuffedPlayer.PlayerData.source, isPolice)
    cuffedPlayer.Functions.SetMetaData("ishandcuffed", result)

    if result then
        TriggerClientEvent('police:client:GetCuffed', cuffedPlayer.PlayerData.source)
    end
end)

RegisterNetEvent('brazzers-police:server:uncuffPlayer', function(playerId)
    if isTargetTooFar(source, playerId, 10.0) then return end

    local player = QBCore.Functions.GetPlayer(source)
    local cuffedPlayer = QBCore.Functions.GetPlayer(playerId)

    local result = lib.callback.await('brazzers-police:client:uncuffPlayer', cuffedPlayer.PlayerData.source)
    if not result then return end
    cuffedPlayer.Functions.SetMetaData("ishandcuffed", false)
    TriggerClientEvent('escorting:client:player', player.PlayerData.source, false)
    TriggerClientEvent('police:client:GetUnCuffed', cuffedPlayer.PlayerData.source)
end)

RegisterNetEvent('brazzers-police:server:escortPlayer', function(playerId)
    if isTargetTooFar(source, playerId, 10.0) then return end

    local player = QBCore.Functions.GetPlayer(source)
    local escortedPlayer = QBCore.Functions.GetPlayer(playerId)

    if escortedPlayer.PlayerData.metadata.ishandcuffed or escortedPlayer.PlayerData.metadata.isdead then
        local result = lib.callback.await('brazzers-police:client:escortPlayer', escortedPlayer.PlayerData.source, source)
        TriggerClientEvent('escorting:client:player', player.PlayerData.source, result)
    end
end)

RegisterNetEvent('brazzers-police:server:seatInVehicle', function(playerId)
    if isTargetTooFar(source, playerId, 10.0) then return end

    local player = QBCore.Functions.GetPlayer(source)
    local targetPlayer = QBCore.Functions.GetPlayer(playerId)

    if targetPlayer.PlayerData.metadata.ishandcuffed or targetPlayer.PlayerData.metadata.isdead then
        local result = lib.callback.await('brazzers-police:client:seatInVehicle', targetPlayer.PlayerData.source)
        if not result then return end
        TriggerClientEvent('escorting:client:player', player.PlayerData.source, false)
    end
end)

RegisterNetEvent('brazzers-police:server:unseatFromVehicle', function(playerId)
    if isTargetTooFar(source, playerId, 10.0) then return end

    local player = QBCore.Functions.GetPlayer(source)
    local targetPlayer = QBCore.Functions.GetPlayer(playerId)
    local isPolice = player.PlayerData.job.type == 'leo'

    if targetPlayer.PlayerData.metadata.ishandcuffed or targetPlayer.PlayerData.metadata.isdead then
        local result = lib.callback.await('brazzers-police:client:unseatFromVehicle', targetPlayer.PlayerData.source, source, isPolice)
        TriggerClientEvent('escorting:client:player', player.PlayerData.source, result)
    end
end)

RegisterNetEvent('brazzers-police:server:unmask', function(playerId)
    if isTargetTooFar(source, playerId, 10.0) then return end

    local player = QBCore.Functions.GetPlayer(source)
    local targetPlayer = QBCore.Functions.GetPlayer(playerId)

    local result = lib.callback.await('brazzers-police:client:unmask', targetPlayer.PlayerData.source, source)
    if not result then return end
end)

RegisterNetEvent('brazzers-police:server:takeoffShoes', function(playerId)
    if isTargetTooFar(source, playerId, 10.0) then return end

    local player = QBCore.Functions.GetPlayer(source)
    local targetPlayer = QBCore.Functions.GetPlayer(playerId)

    local result = lib.callback.await('brazzers-police:client:takeoffShoes', targetPlayer.PlayerData.source, source)
    if not result then return end

    exports.ox_inventory:AddItem(player.PlayerData.source, 'weapon_shoe', 2)
end)

RegisterNetEvent("brazzers-police:server:friskPlayer", function(player)
    local found = false
    local inventory = exports.ox_inventory:GetInventoryItems(player, false)
    for _, v in pairs(inventory) do
        if string.find(v.name, "WEAPON_") then
            found = true
        end
    end

    if found then
        TriggerClientEvent("DoLongHudText", source, 'You felt a firm stiff bulge')
    else
        TriggerClientEvent("DoLongHudText", source, 'You didn\'t feel any type of bulge', 2)
    end
end)

RegisterNetEvent("brazzers-police:server:fingerprintPlayer", function(playerId)
    local Player = QBCore.Functions.GetPlayer(source)
    local OtherPlayer = QBCore.Functions.GetPlayer(playerId)
    local FingerPrintNumber = OtherPlayer.PlayerData.metadata.fingerprint

    if OtherPlayer then
        -- Logs
	    local steamName = GetPlayerName(playerId)
        local cid = OtherPlayer.PlayerData.citizenid
        local charName = OtherPlayer.PlayerData.charinfo.firstname..' '..OtherPlayer.PlayerData.charinfo.lastname

        TriggerClientEvent('chatMessage', source, "MACHINE", "normal", "Name: "..OtherPlayer.PlayerData.charinfo.firstname.. " "..OtherPlayer.PlayerData.charinfo.lastname.. " | "..FingerPrintNumber)
        exports['brazzers-logs']:addLog('police', 'Fingerprint', steamName..' | '..charName..' | ['..cid..'] was fingerprinted', 11342935, source)
    end
end)

RegisterNetEvent('police:server:checkBank', function(playerId)
    local SearchedPlayer = QBCore.Functions.GetPlayer(playerId)
    if not SearchedPlayer then return end
    TriggerClientEvent('chatMessage', source, "SYSTEM", "error", "Person has $"..SearchedPlayer.PlayerData.money.bank.. " in his bank account.")
end)

RegisterNetEvent('police:server:BillPlayer', function(playerId, price)
    local Player = QBCore.Functions.GetPlayer(source)
    local OtherPlayer = QBCore.Functions.GetPlayer(playerId)
    local totalPayout = math.ceil(price * (Config.EmployeeEarnings / 100))
    if not Player or not OtherPlayer then return end

    OtherPlayer.Functions.RemoveMoney("bank", price, "paid-bills")
    TriggerClientEvent('QBCore:Notify', OtherPlayer.PlayerData.source, 'You received a fine of $'..price)

    Player.Functions.AddMoney('bank', totalPayout, 'fine-commission')
    TriggerClientEvent('QBCore:Notify', source, '$'..totalPayout..' was transfered to your account')

    -- Handle Cop Transaction
	local account = Player.PlayerData.charinfo.account local business = 'State Account' local note = 'Government Fine Percentage [10%]'
	exports['brazzers-banking']:handleTransaction(source, account, business, "personal", "N/A", price, "fine", 'Personal Account', note)
    --Handle Criminal Transaction
	local account = OtherPlayer.PlayerData.charinfo.account local business = 'State Account' local note = 'Government Fine By Police'
	exports['brazzers-banking']:handleTransaction(playerId, account, business, "personal", "N/A", '-'..price, "fine", 'Personal Account', note)

    local business = Player.PlayerData.job.name
    if Player.PlayerData.job.name == 'da' then
        business = 'L491-6699'
    elseif Player.PlayerData.job.name == 'doj' then
        business = 'L003-0003'
    end

    -- Transfer to Business & State Account
    local note = 'Government Monetary Penalty: Fine issued' local stateNote = 'Government Monetary Penalty: State Percentage'
    exports['brazzers-banking']:calculateBusinessFund(source, business, price, Config.BusinessEarnings, 'services', note, stateNote)
end)

RegisterNetEvent('police:server:BillPlayerByCitation', function(stateId, price, citationID, charges)
    local Player = QBCore.Functions.GetPlayer(source)
    local OtherPlayer = QBCore.Functions.GetPlayerByCitizenId(tostring(stateId))
    local totalPayout = math.ceil(price * (Config.EmployeeEarnings / 100))
    if not Player then
        TriggerClientEvent("rush-mdw-cl:WasCiteIssued", source, false)
        return
    end

    if OtherPlayer then
        OtherPlayer.Functions.RemoveMoney("bank", price, "paid-bills")
        TriggerClientEvent('QBCore:Notify', OtherPlayer.PlayerData.source, 'You received a fine of $'..price)

        Player.Functions.AddMoney('bank', totalPayout, 'fine-commission')
        TriggerClientEvent('QBCore:Notify', source, '$'..totalPayout..' was transfered to your account')

        -- Handle Cop Transaction
        local account = Player.PlayerData.charinfo.account local business = 'State Account' local note = 'Government Fine Percentage [10%]'
        exports['brazzers-banking']:handleTransaction(source, account, business, "personal", "N/A", price, "fine", 'Personal Account', note)
        --Handle Criminal Transaction
        local account = OtherPlayer.PlayerData.charinfo.account local business = 'State Account' local note = 'Government Fine By Police'
        exports['brazzers-banking']:handleTransaction(OtherPlayer.PlayerData.source, account, business, "personal", "N/A", '-'..price, "fine", 'Personal Account', note)

        exports.oxmysql:update('UPDATE `mdw_pd_citations` SET `fineissued` = 1 WHERE `id` = ?', {citationID})
    else 
        local onlyHasOfflineCharges = true
        for charge, data in pairs(charges) do
            if not offlineCharges[charge] then
                onlyHasOfflineCharges = false
                TriggerClientEvent("rush-mdw-cl:WasCiteIssued", source, false)
                return
            end
        end
        if onlyHasOfflineCharges then
            local charData = exports.oxmysql:single_async('SELECT `money`, `charinfo` FROM `players` WHERE `citizenid` = ?', {
                tostring(stateId)
            })
            local money = json.decode(charData.money)
            local charinfo = json.decode(charData.charinfo)
            money.bank = money.bank - price
            exports.oxmysql:update('UPDATE `players` SET `money` = ? WHERE `citizenid` = ?', {
                json.encode(money),
                tostring(stateId)
            })
            Player.Functions.AddMoney('bank', totalPayout, 'fine-commission')
            TriggerClientEvent('QBCore:Notify', source, '$'..totalPayout..' was transfered to your account')
            --@todo handle transaction for brazzers banking
            local account = Player.PlayerData.charinfo.account local business = 'State Account' local note = 'Government Fine Percentage [10%]'
            exports['brazzers-banking']:handleTransaction(source, account, business, "personal", "N/A", price, "fine", 'Personal Account', note)

            local account = charinfo.account local business = 'State Account' local note = 'Government Fine By Police'
            exports['brazzers-banking']:handleTransaction(nil, account, business, "personal", "N/A", '-'..price, "fine", 'Personal Account', note)

            exports.oxmysql:update('UPDATE `mdw_pd_citations` SET `fineissued` = 1 WHERE `id` = ?', {citationID})
        end
    end

    local business = Player.PlayerData.job.name
    if Player.PlayerData.job.name == 'da' then
        business = 'L491-6699'
    elseif Player.PlayerData.job.name == 'doj' then
        business = 'L003-0003'
    end

    -- Transfer to Business & State Account
    local note = 'Government Monetary Penalty: Fine issued' local stateNote = 'Government Monetary Penalty: State Percentage'
    exports['brazzers-banking']:calculateBusinessFund(source, business, price, Config.BusinessEarnings, 'services', note, stateNote)
    TriggerClientEvent("rush-mdw-cl:WasCiteIssued", source, true)
end)

RegisterNetEvent("rush-police-sv:AddWiperDocument", function(netID, documentData)
    local _source = source
    local vehicle = NetworkGetEntityFromNetworkId(netID)
    while not DoesEntityExist(vehicle) do
        Citizen.Wait(100)
        vehicle = NetworkGetEntityFromNetworkId(netID)
    end
    local wiperData = {}
    if Entity(vehicle).state.wiperdata ~= nil then
        wiperData = Entity(vehicle).state.wiperdata
        table.insert(wiperData, documentData)
    else
        table.insert(wiperData, documentData)
    end
    Entity(vehicle).state:set("wiperdata", wiperData, true)
    Entity(vehicle).state.wiperdata = wiperData
    exports.ox_inventory:RemoveItem(_source, documentData[1], 1, nil, documentData[3])
    exports.oxmysql:update('UPDATE player_vehicles SET wiperdata = ? WHERE plate = ?', {
        json.encode(wiperData), 
        GetVehicleNumberPlateText(vehicle)
    }, function(affectedRows)end)
end)

RegisterNetEvent("rush-police-sv:TakeWiperDocument", function(netID, documentNumber)
    local _source = source
    local vehicle = NetworkGetEntityFromNetworkId(netID)
    while not DoesEntityExist(vehicle) do
        Citizen.Wait(100)
        vehicle = NetworkGetEntityFromNetworkId(netID)
    end
    local wiperData = {}
    if Entity(vehicle).state.wiperdata ~= nil and #Entity(vehicle).state.wiperdata > 0 then
        wiperData = Entity(vehicle).state.wiperdata
    else
        return
    end
    --@todo add the item to the players inventory
    exports.ox_inventory:AddItem(_source, wiperData[documentNumber][1], 1, wiperData[documentNumber][4])
    table.remove(wiperData, documentNumber)
    Entity(vehicle).state:set("wiperdata", wiperData, true)
    Entity(vehicle).state.wiperdata = wiperData
    exports.oxmysql:update('UPDATE player_vehicles SET wiperdata = ? WHERE plate = ?', {
        json.encode(wiperData), 
        GetVehicleNumberPlateText(vehicle)
    }, function(affectedRows)end)
end)

RegisterNetEvent('police:server:SetHandcuffStatus', function(bool)
    local Player = QBCore.Functions.GetPlayer(source)
    if not Player then return end
    Player.Functions.SetMetaData("ishandcuffed", bool)
end)

RegisterNetEvent('police:server:SearchPlayer', function(playerId)
    if isTargetTooFar(source, playerId, 10.0) then return end

    local SearchedPlayer = QBCore.Functions.GetPlayer(playerId)
    if not QBCore.Functions.GetPlayer(source) or not SearchedPlayer then return end

    TriggerClientEvent('QBCore:Notify', source, 'Found $'..SearchedPlayer.PlayerData.money.cash..' of cash')
    TriggerClientEvent('QBCore:Notify', SearchedPlayer.PlayerData.source, 'You are being searched')
    --Logs
    local steamName = GetPlayerName(playerId)
    local cid = SearchedPlayer.PlayerData.citizenid
    local charName = SearchedPlayer.PlayerData.charinfo.firstname..' '..SearchedPlayer.PlayerData.charinfo.lastname
    exports['brazzers-logs']:addLog('police', 'Police Search', steamName..' | '..charName..' | ['..cid..'] was searched', 11342935, source)
end)

RegisterNetEvent('police:server:SeizePossessions', function(playerId)
    local Player = QBCore.Functions.GetPlayer(source)
    local SearchedPlayer = QBCore.Functions.GetPlayer(playerId)
    if not Player or not SearchedPlayer then return end

    local items = exports.ox_inventory:GetInventoryItems(SearchedPlayer.PlayerData.source, false)
    MySQL.insert('INSERT INTO player_possessions (citizenid, items) VALUES (?, ?)', {SearchedPlayer.PlayerData.citizenid, json.encode(items)})
    exports.ox_inventory:ClearInventory(SearchedPlayer.PlayerData.source, false)

    TriggerClientEvent('QBCore:Notify', source, 'All items seized and sent to DOC')
    TriggerClientEvent('QBCore:Notify', SearchedPlayer.PlayerData.source, 'Your possessions were seized and sent to DOC')

    --Logs
    local steamName = GetPlayerName(playerId)
    local cid = SearchedPlayer.PlayerData.citizenid
    local charName = SearchedPlayer.PlayerData.charinfo.firstname..' '..SearchedPlayer.PlayerData.charinfo.lastname
    exports['brazzers-logs']:addLog('police', 'Seized Possessions', steamName..' | '..charName..' | ['..cid..'] possessions was seized', 11342935, source)
end)

RegisterNetEvent('police:server:SeizeCash', function(playerId)
    if isTargetTooFar(source, playerId, 10.0) then return end

    local Player = QBCore.Functions.GetPlayer(source)
    local SearchedPlayer = QBCore.Functions.GetPlayer(playerId)
    if not Player or not SearchedPlayer then return end

    local moneyAmount = SearchedPlayer.PlayerData.money.cash
    SearchedPlayer.Functions.RemoveMoney("cash", moneyAmount, "police-cash-seized")
    Player.Functions.AddMoney("cash", moneyAmount, 'seized cash')
    -- PD Fund Here
    TriggerClientEvent('QBCore:Notify', SearchedPlayer.PlayerData.source, 'Your cash was confiscated')
    --Logs
    local steamName = GetPlayerName(playerId)
    local cid = SearchedPlayer.PlayerData.citizenid
    local charName = SearchedPlayer.PlayerData.charinfo.firstname..' '..SearchedPlayer.PlayerData.charinfo.lastname
    exports['brazzers-logs']:addLog('police', 'Police Seized Cash', steamName..' | '..charName..' | ['..cid..'] cash was seized', 11342935, source)
end)

RegisterNetEvent('police:server:RobPlayer', function(playerId)
    if isTargetTooFar(source, playerId, 10.0) then return end

    local Player = QBCore.Functions.GetPlayer(source)
    local SearchedPlayer = QBCore.Functions.GetPlayer(playerId)
    if not Player or not SearchedPlayer then return end

    local money = SearchedPlayer.PlayerData.money.cash
    Player.Functions.AddMoney("cash", money, "police-player-robbed")
    SearchedPlayer.Functions.RemoveMoney("cash", money, "police-player-robbed")
    TriggerClientEvent('QBCore:Notify', SearchedPlayer.PlayerData.source, 'You have been robbed of $'..money)
    TriggerClientEvent('QBCore:Notify', Player.PlayerData.source, 'You have stolen $'..money)
    --Logs
    local steamName = GetPlayerName(playerId)
    local cid = SearchedPlayer.PlayerData.citizenid
    local charName = SearchedPlayer.PlayerData.charinfo.firstname..' '..SearchedPlayer.PlayerData.charinfo.lastname
    exports['brazzers-logs']:addLog('interactions', 'Person Robbed', steamName..' | '..charName..' | ['..cid..'] was robbed', 11342935, source)
end)

RegisterNetEvent('brazzers-police:server:runPlate', function(vehPlate)
    local src = source

    if not IsVehicleOwned(vehPlate) then
        local firstname = Config.Firstname[math.random(1, #Config.Firstname)]
        local lastname = Config.Lastname[math.random(1, #Config.Lastname)]
        local name, number = firstname..' '..lastname, math.random(1111111111, 9999999999)
        
        if not platesRan[vehPlate] then
            platesRan[vehPlate] = {
                plate = vehPlate,
                name = name,
                number = number,
            }
        end

        TriggerClientEvent('chat:addMessage', src, {
            color = { 181, 51, 0},
            multiline = true,
            args = {'DISPATCH: 10-74 (Negative)', 'Name: '..platesRan[vehPlate].name..' | Phone: '..platesRan[vehPlate].number.. ' | Plate: '..platesRan[vehPlate].plate}
        })
        return
    end

    local vehicle = MySQL.query.await('SELECT * FROM player_vehicles WHERE plate = ?', {vehPlate})
    local result = MySQL.query.await('SELECT * FROM players WHERE citizenid = ?', {vehicle[1].citizenid})
    if not result then return end

    local name = ""
    local phone = ""
    if string.find(vehicle[1].citizenid, "STATE") then
        name = "STATE"
        phone = "911"
    else
        local info = json.decode(tostring(result[1].charinfo))
        name = info.firstname..' '..info.lastname
        phone = info.phone
    end

    TriggerClientEvent('chat:addMessage', src, {
        color = { 212, 141, 0},
        multiline = false,
        args = {'DISPATCH: 10-74 (Negative)', 'Name: '..name..' | Phone: '..phone.. ' | Plate: '..vehPlate}
    })
end)

-- Callbacks

lib.callback.register('brazzers-police:server:handcuffStatus', function(source, playerId)
    local player = QBCore.Functions.GetPlayer(playerId)
    return player.PlayerData.metadata.ishandcuffed
end)

lib.callback.register('brazzers-police:server:registerShops', function(source, business)
    if not business then return end
    exports.ox_inventory:RegisterShop(business, {
        name = 'Police Armory',
        inventory = Config.Items,
    })
    return true
end)

lib.callback.register('brazzers-police:server:registerStashes', function(source, id, slots, weight, name)
    exports.ox_inventory:RegisterStash(id, name, slots, weight)
    return true
end)

-- Commands

QBCore.Commands.Add('pdv', 'Delete Vehicle (Police Only)', {}, false, function(source)
    local Player = QBCore.Functions.GetPlayer(source)
    if Player.PlayerData.job.type ~= 'leo' then return end
    TriggerClientEvent('QBCore:Command:DeleteVehicle', source)
end)

QBCore.Commands.Add('chat', 'PD/ EMS Chat', {}, false, function(source, args)
    local Player = QBCore.Functions.GetPlayer(source)

    if not Player.PlayerData.metadata.ishandcuffed and not Player.PlayerData.metadata.isdead then
        if (Player.PlayerData.job.type == 'leo') or (Player.PlayerData.job.name == 'ems') then
            TriggerClientEvent('police:chatMessage', -1, {(Player.PlayerData.charinfo.firstname .. ' ' .. Player.PlayerData.charinfo.lastname .. ' (' .. Player.PlayerData.metadata.callsign .. ')'), table.concat(args, " ")})
        end
    else
        TriggerClientEvent('DoLongHudText', source, "You can\'t do this while in your current state", 2)
    end
end)

QBCore.Commands.Add("fine", "Fine to Player", {{name = "id", help = "Player ID"}, {name = "price", help = "Fine Amount )"}}, true, function(source, args)
	local Player = QBCore.Functions.GetPlayer(source)
    if not Player then return end

    local Victim = QBCore.Functions.GetPlayer(tonumber(args[1]))
    if not Victim then return TriggerClientEvent("DoLongHudText", source, 'State ID does not exists', 2) end

    if Player.PlayerData.job.type ~= 'leo' and not exports['rush-doj']:isJudge(source) then return end

    -- Logs
    local playerId = tonumber(args[1])
	local steamName = GetPlayerName(playerId)
    local cid = Victim.PlayerData.citizenid
    local charName = Victim.PlayerData.charinfo.firstname..' '..Victim.PlayerData.charinfo.lastname

    local price = tonumber(args[2])
    if price < 0 then return TriggerClientEvent('chatMessage', source, "SYSTEM", "error", "Amount must be higher than 0") end

    TriggerClientEvent("police:client:BillCommand", source, playerId, price)
    exports['brazzers-logs']:addLog('police', 'Police Fine', steamName..' | '..charName..' | ['..cid..'] was fined $'..price, 11342935, source)
end)

QBCore.Commands.Add("callsign", 'Give Yourself A Callsign', {{name = "name", help = 'Name of your callsign'}}, false, function(source, args)
    local Player = QBCore.Functions.GetPlayer(source)
    Player.Functions.SetMetaData("callsign", table.concat(args, " "))
end)

QBCore.Commands.Add("vcallsign", "Set Vehicle Callsign", {{name="number", help="### - Callsign"}}, false, function(source, args)
    local Player = QBCore.Functions.GetPlayer(source)
    if not Player then return end
    local number = tonumber(args[1])
    if (Player.PlayerData.job.type == 'leo') then
        TriggerClientEvent("brazzers-police:client:setVehicleCallsign", source, number)
    end
end)

QBCore.Commands.Add('evidence', 'open evidence locker', {{name="Incident #", help="Locate the incident number in your MDT report"}}, false, function(source, args, penis)
    local Player = QBCore.Functions.GetPlayer(source)
    if not Player then return end
    if (Player.PlayerData.job.type == 'leo' and Player.PlayerData.job.onduty) then
        TriggerClientEvent('brazzers-police:client:openEvidence', source, args[1])
    end
end)

QBCore.Commands.Add("911r", "Send a message back to a 911 alert", {{name="id", help="ID of the alert"}, {name="message", help="Message you want to send"}}, true, function(source, args)
    local Player = QBCore.Functions.GetPlayer(source)
    if not Player then return end

    local firstName = Player.PlayerData.charinfo.firstname
    local lastName = Player.PlayerData.charinfo.lastname

    local OtherPlayer = QBCore.Functions.GetPlayer(tonumber(args[1]))
    if not OtherPlayer then return TriggerClientEvent('DoLongHudText', 'Invalid Id', 2) end
    local message = table.concat(args, " ")

    TriggerClientEvent('chatMessage', OtherPlayer.PlayerData.source, "REPLY: "..Player.PlayerData.charinfo.firstname .." " ..Player.PlayerData.charinfo.lastname, "error", message)
    TriggerClientEvent("police:client:EmergencySound", OtherPlayer.PlayerData.source)
    local data = OtherPlayer.PlayerData.source..' | '..firstName..' | '..lastName
    TriggerClientEvent('rush-police:client:chatMessage', -1, {data, message}, true)
end)

QBCore.Commands.Add("311r", "Send a message back to a 311 alert", {{name="id", help="ID of the alert"}, {name="message", help="Message you want to send"}}, true, function(source, args)
    local Player = QBCore.Functions.GetPlayer(source)
    if not Player then return end

    local firstName = Player.PlayerData.charinfo.firstname
    local lastName = Player.PlayerData.charinfo.lastname

    local OtherPlayer = QBCore.Functions.GetPlayer(tonumber(args[1]))
    if not OtherPlayer then return TriggerClientEvent('DoLongHudText', 'Invalid Id', 2) end
    local message = table.concat(args, " ")

    TriggerClientEvent('chatMessage', OtherPlayer.PlayerData.source, "REPLY: "..Player.PlayerData.charinfo.firstname .." " ..Player.PlayerData.charinfo.lastname, "error", message)
    TriggerClientEvent("police:client:EmergencySound", OtherPlayer.PlayerData.source)
    local data = OtherPlayer.PlayerData.source..' | '..firstName..' | '..lastName
    TriggerClientEvent('rush-police:client:chatMessage', -1, {data, message}, false)
end)

QBCore.Commands.Add("raidticket", "Generate a raid ticket", {{name = "Evidence Locker", help = "Full evidence name with number together"}}, true, function(source, args)
	local Player = QBCore.Functions.GetPlayer(source)
    if not Player then return end

    if (Player.PlayerData.job.type ~= 'leo') then return end
    if not Player.PlayerData.job.onduty then return end

    local stash = 'evidence_'..args[1]
    local inventory, items = exports.ox_inventory:GetInventoryItems(stash, false), ''

    for _, v in pairs(inventory) do
        items = items .. v.label..', '
    end

    local info = {}
    info.locker = 'Incident #'..args[1]
    info.evidence = items
    exports.ox_inventory:AddItem(source, 'raidticket', 1, info)
end)

-- Items

QBCore.Functions.CreateUseableItem("detcord", function(source, item)
    local Player = QBCore.Functions.GetPlayer(source)
    if not Player then return end
    TriggerClientEvent("ox_doorlock:client:useDetcord", source)
end)

QBCore.Functions.CreateUseableItem("handcuffkey", function(source, item)
    TriggerClientEvent("police:client:unCuffPlayer", source)
end)

-- Threads

CreateThread(function()
    exports.ox_inventory:ClearInventory('police_trash', false)
end)