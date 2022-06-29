local waypoint = nil
local mapused = false
local wiring = false

Citizen.CreateThread(function()
  SetupLockpickPrompt()
  SetupBlackoutPrompt()
  while true do
    Citizen.Wait(0)
    if mapused then
      local playerPed = PlayerPedId()
	    local coords = GetEntityCoords(playerPed)
	    local dist1 = #(coords - Config.location1)
      if dist1 <= 1 then
        PromptSetEnabled(LockpickPrompt, true)
		    PromptSetVisible(LockpickPrompt, true)
        SetGpsMultiRouteRender(false)
        RemoveBlip(waypoint)
        waypoint = nil
        if PromptHasStandardModeCompleted(LockpickPrompt) then
          TriggerServerEvent('void_blackout:checkitem', Config.lockpickitem)
        end
      else
        PromptSetEnabled(LockpickPrompt, false)
        PromptSetVisible(LockpickPrompt, false)
      end
    else
      PromptSetEnabled(LockpickPrompt, false)
      PromptSetVisible(LockpickPrompt, false)
    end
    if wiring then
      mapused = false
      local playerPed = PlayerPedId()
	    local coords = GetEntityCoords(playerPed)
	    local dist2 = #(coords - Config.location2)
      if dist2 <= 1 then
        PromptSetEnabled(BlackoutPrompt, true)
        PromptSetVisible(BlackoutPrompt, true)
        SetGpsMultiRouteRender(false)
        RemoveBlip(waypoint)
        waypoint = nil
        if PromptHasStandardModeCompleted(BlackoutPrompt) then
          wiring = false
          PromptSetEnabled(BlackoutPrompt, false)
          PromptSetVisible(BlackoutPrompt, false)
          Animation(playerPed, 'script_rc@gun5@ig@stage_02@ig2_detonator', 'standing_leverpush_john', 1000)
          Citizen.Wait(2000)
          TriggerServerEvent('void_blackout:setupblackout') 
        end
      else
      PromptSetEnabled(BlackoutPrompt, false)
      PromptSetVisible(BlackoutPrompt, false)
      end  
    end
  end
end)

RegisterNetEvent('void_blackout:usepaper')
AddEventHandler('void_blackout:usepaper', function(source)
    local player = PlayerPedId()
    Animation(player, "mech_inspection@mini_map@satchel", "enter")
    Wait(2000)
    local coords = GetEntityCoords(player) 
    local prop = CreateObject(GetHashKey("s_twofoldmap01x_us"), coords.x, coords.y, coords.z, 1, 0, 1)
    SetEntityAsMissionEntity(prop,true,true)
    RequestAnimDict("mech_carry_box")
    while not HasAnimDictLoaded("mech_carry_box") do
      Citizen.Wait(100)
    end
    Citizen.InvokeNative(0xEA47FE3719165B94, player,"mech_carry_box", "idle", 1.0, 8.0, -1, 31, 0, 0, 0, 0)
    Citizen.InvokeNative(0x6B9BBD38AB0796DF, prop,player,GetEntityBoneIndexByName(player,"SKEL_L_Finger12"), 0.20, -0.02, -0.15, 180.0, 190.0, 0.0,true, true, false, true, 1, true)
    
    Citizen.Wait(5000)

    Animation(player, "mech_inspection@two_fold_map@satchel", "exit_satchel")
    ClearPedSecondaryTask(GetPlayerPed(PlayerId()))
    DetachEntity(prop,false,true)
    ClearPedTasks(player)
    DeleteObject(prop)

    Citizen.Wait(1000)

    Destination(Config.location1,960467426,'Doverhill')

    TriggerEvent('vorp:TipBottom', _U('FirstLoc'), 10000)

    mapused = true
end)

RegisterNetEvent('void_blackout:explosion')
AddEventHandler('void_blackout:explosion', function(explosion_coords_x, explosion_coords_y, explosion_coords_z, explosionTag_id, explosion_vfxTag_hash, damageScale, isAudible, isInvisible, cameraShake)
  Citizen.InvokeNative(0x53BA259F3A67A99E, explosion_coords_x, explosion_coords_y, explosion_coords_z, explosionTag_id, explosion_vfxTag_hash, damageScale, isAudible, isInvisible, cameraShake)
end)

RegisterNetEvent('void_blackout:blackouton')
AddEventHandler('void_blackout:blackouton', function()
  SetArtificialLightsState(true)
end)

RegisterNetEvent('void_blackout:blackoutoff')
AddEventHandler('void_blackout:blackoutoff', function()
  SetArtificialLightsState(false)
end)

RegisterNetEvent('void_blackout:minigame')
AddEventHandler('void_blackout:minigame', function(source)
  local _source = source
  local player = PlayerPedId()
  local minigame = exports["lockpick"]:lockpick()             
  if minigame then
    Citizen.Wait(1000)
    wiring = exports ["mx_fixwiring"]:CircuitGame('50%', '50%', '1.0', '30vmin', '1.ogg')
    if wiring then
    Citizen.Wait(100)
    TriggerEvent('vorp:TipBottom', _U("SecondLoc"), 5000)
    Destination(Config.location2,960467426,_U("TowerBlip"))
    end
  elseif not minigame then
    TriggerServerEvent('void_blackout:removeitem', Config.lockpickitem) 
    TriggerEvent('vorp:TipBottom', _U("BreakLock"), 5000)
  end 

end)

function SetupLockpickPrompt()
		local str = _U("PromptLock")
		LockpickPrompt = PromptRegisterBegin()
		PromptSetControlAction(LockpickPrompt, 0x760A9C6F)
		str = CreateVarString(10, 'LITERAL_STRING', str)
		PromptSetText(LockpickPrompt, str)
		PromptSetEnabled(LockpickPrompt, false)
		PromptSetVisible(LockpickPrompt, false)
		PromptSetStandardMode(LockpickPrompt, true)
		PromptRegisterEnd(LockpickPrompt)
end

function SetupBlackoutPrompt()
  local str = _U("PromptStart")
  BlackoutPrompt = PromptRegisterBegin()
  PromptSetControlAction(BlackoutPrompt, 0x760A9C6F)
  str = CreateVarString(10, 'LITERAL_STRING', str)
  PromptSetText(BlackoutPrompt, str)
  PromptSetEnabled(BlackoutPrompt, false)
  PromptSetVisible(BlackoutPrompt, false)
  PromptSetStandardMode(BlackoutPrompt, true)
  PromptRegisterEnd(BlackoutPrompt)
end

function Animation(ped, dict, name, period)
  if not DoesAnimDictExist(dict) then
    return
  end
  RequestAnimDict(dict)
  while not HasAnimDictLoaded(dict) do
  Citizen.Wait(0)
  end
  TaskPlayAnim(ped, dict, name, -1.0, -0.5, period or 2000, 1, 0, true, 0, false, 0, false)
  RemoveAnimDict(dict)
end

function Destination (location, sprite, name )
  StartGpsMultiRoute(6, true, true)

  AddPointToGpsMultiRoute(location.x, location.y, location.z)

  SetGpsMultiRouteRender(true)
  
  RemoveBlip(waypoint)
  waypoint = N_0x554d9d53f696d002(GetHashKey("BLIP_STYLE_WAYPOINT"), location.x, location.y, location.z)
  SetBlipSprite(waypoint, sprite, 1)

  Citizen.InvokeNative(0x9CB1A1623062F402, waypoint, name)

end


AddEventHandler('onResourceStop', function(resourceName)
	if (GetCurrentResourceName() ~= resourceName) then
		return
	end
  PromptSetEnabled(LockpickPrompt, false)
  PromptSetVisible(LockpickPrompt, false)
  PromptSetEnabled(BlackoutPrompt, false)
  PromptSetVisible(BlackoutPrompt, false)
	SetGpsMultiRouteRender(false)
  RemoveBlip(waypoint)
  waypoint = nil
  wiring = false

	
end )