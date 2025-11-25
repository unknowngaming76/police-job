local enabled = false
local data = {
  [`default`] = 0,
  [`freq_low`] = 0.0,
  [`freq_hi`] = 10000.0,
  [`rm_mod_freq`] = 300.0,
  [`rm_mix`] = 0.2,
  [`fudge`] = 0.0,
  [`o_freq_lo`] = 200.0,
  [`o_freq_hi`] = 5000.0,
}
local filter

local function DisableSubmix()
  TriggerServerEvent('megaphone:applySubmix', false)
end 

local function CheckPlayer()
  local Player = cache.ped
  local getVehiclePedIsIn = GetVehiclePedIsIn(Player, false) > 0 and GetVehiclePedIsIn(Player, false) or
      0 -- Get the vehicle the ped is in, if is > than 0 means the player is in a vehicle
  if getVehiclePedIsIn == 0 then return end
  local vehicleClass = GetVehicleClass(getVehiclePedIsIn) == 18 and true or false --get the class of it
  if not vehicleClass then
    return
  end
  return vehicleClass
end

RegisterCommand('+Megaphone', function()
  if isPolice() then
    if not CheckPlayer() then
      DisableSubmix()
      exports["pma-voice"]:clearProximityOverride()
      return
    end
    
    exports["pma-voice"]:overrideProximityRange(30.0, true)
    TriggerServerEvent('megaphone:applySubmix', true)
    --[[ QBCore.Functions.Notify('Megaphone on', 'success') ]]
  end
end, false)

RegisterCommand('-Megaphone', function()
  if isPolice() then
    DisableSubmix()
    exports["pma-voice"]:clearProximityOverride()
    --[[ QBCore.Functions.Notify('Megaphone off', 'error') ]]
  end
end, false)

RegisterKeyMapping('+Megaphone', '(GOV): Talk on the Megaphone', '', '')

-- Thread

CreateThread(function()
  filter = CreateAudioSubmix("Megaphone")
  SetAudioSubmixOutputVolumes(
  filter,
  1,
  1.00 --[[ frontLeftVolume ]],
  1.00 --[[ frontRightVolume ]],
  0.5 --[[ rearLeftVolume ]],
  0.5 --[[ rearRightVolume ]],
  1.0 --[[ channel5Volume ]],
  1.0 --[[ channel6Volume ]]
)
  SetAudioSubmixEffectRadioFx(filter, 0)
  for hash, value in pairs(data) do
      SetAudioSubmixEffectParamInt(filter, 0, hash, 1)
  end
  AddAudioSubmixOutput(filter, 0)
end)