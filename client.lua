
local invehicle = false
local HudStage = 1
local voice = 0
local PlayerData = ESX.GetPlayerData() -- Just for resource restart (same as event handler)
local get_ped = PlayerPedId() -- current ped
if LocalPlayer.state['proximity'] then
	voice = LocalPlayer.state['proximity'].distance
end

local waiting = (1000 * 60) * 3

local currentValues
currentValues = {
	["health"] = 200,
	["armor"] = 200,
	["hunger"] = 200,
	["thirst"] = 200,
	["oxy"] = 25,
	["stress"] = 100,
	["voice"] = 2,
	["devmode"] = false,
	["devdebug"] = false,
	["is_talking"] = false
}


local val = currentValues


RegisterNetEvent('esx:playerLoaded', function()
	PlayerData = currentValues
    --TriggerEvent('RefreshServer')
    
end)

local lastValues = {}


print(json.encode(currentValues))

function  Restart(hunger, thirst)


    Wait(1000)
	SendNUIMessage({
		type = "updateStatusHud",
		hasParachute = currentValues["parachute"],
		varSetHealth = currentValues["health"],
		varSetArmor = currentValues["armor"],
		varSetHunger = currentValues["hunger"],
		varSetThirst = currentValues["thirst"],
		varSetOxy = currentValues["oxy"],
		varSetStress = currentValues["stress"],
		colorblind = colorblind,
		varSetVoice = LocalPlayer.state['proximity'].distance,
		varDev = currentValues["dev"],
		varDevDebug = currentValues["devdebug"],
		is_talking = currentValues["is_talking"]
	})

end


AddEventHandler('onResourceStart', function(resource)
    if GetCurrentResourceName() == resource then
        PlayerData = ESX.GetPlayerData()
		TriggerServerEvent('hud:SetMeta')
    end
end)

















--IsVehicleSirenSoundOn(vehicle)
--GetIsTaskActive(ped, 122)















function quickmafs(dir)
	local x = 0.0
	local y = 0.0
	local dir = dir
	if dir >= 0.0 and dir <= 90.0 then
		local factor = (dir/9.2) / 10
		x = -1.0 + factor
		y = 0.0 - factor
	end

	if dir > 90.0 and dir <= 180.0 then
		dirp = dir - 90.0
		local factor = (dirp/9.2) / 10
		x = 0.0 + factor
		y = -1.0 + factor
	end

	if dir > 180.0 and dir <= 270.0 then
		dirp = dir - 180.0
		local factor = (dirp/9.2) / 10
		x = 1.0 - factor
		y = 0.0 + factor
	end

	if dir > 270.0 and dir <= 360.0 then
		dirp = dir - 270.0
		local factor = (dirp/9.2) / 10	
		x = 0.0 - factor
		y = 1.0 - factor
	end
	return x,y
end



local cruise = {enabled = false, speed = 0, airTime = 0}



function getVehicleInDirection(coordFrom, coordTo)
	local offset = 0
	local rayHandle
	local vehicle

	for i = 0, 100 do
		rayHandle = CastRayPointToPoint(coordFrom.x, coordFrom.y, coordFrom.z, coordTo.x, coordTo.y, coordTo.z + offset, 10, PlayerPedId(), 0)	
		a, b, c, d, vehicle = GetRaycastResult(rayHandle)
		
		offset = offset - 1

		if vehicle ~= 0 then break end
	end
	
	local distance = Vdist2(coordFrom, GetEntityCoords(vehicle))
	
	if distance > 3000 then vehicle = nil end

    return vehicle ~= nil and vehicle or 0
end

RegisterNetEvent("disableHUD")
AddEventHandler("disableHUD", function(passedinfo)
	HudStage = passedinfo

end)

RegisterNetEvent("np-jobmanager:playerBecameJob")
AddEventHandler("np-jobmanager:playerBecameJob", function(job, name)
	if job ~= "hud" then isCop = false else isCop = true end
end)

speedoON = false
RegisterNetEvent('stopSpeedo')
AddEventHandler('stopSpeedo', function()

	if speedoON then
		speedoON = false

		return
	end

end)



function ShowRadarMessage(message)
	SetNotificationTextEntry("STRING")
	AddTextComponentString(message)
	DrawNotification(0,1)
end

function drawTxt(x,y ,width,height,scale, text, r,g,b,a)
    SetTextFont(4)
    SetTextProportional(0)
    SetTextScale(scale, scale)
    SetTextColour(r, g, b, a)
    SetTextDropShadow(0, 0, 0, 0,255)
    SetTextEdge(2, 0, 0, 0, 255)
    SetTextDropShadow()
    SetTextOutline()
    SetTextEntry("STRING")
    AddTextComponentString(text)
    DrawText(x - width/2, y - height/2 + 0.005)
end

function drawRct(x,y,width,height,r,g,b,a)

	DrawRect(x + width/2, y + height/2, width, height, r, g, b, a)
end

function DrawText3D(x,y,z, text) -- some useful function, use it if you want!
    local onScreen,_x,_y=World3dToScreen2d(x,y,z)
    local px,py,pz=table.unpack(GetGameplayCamCoords())
    local dist = #(vector3(px,py,pz) - vector3(x,y,z))

    local scale = (1/dist)*2
    local fov = (1/GetGameplayCamFov())*100
    local scale = scale*fov
    
    if onScreen then
        SetTextScale(0.3,0.3)
        SetTextFont(0)
        SetTextProportional(1)
        -- SetTextScale(0.0, 0.55)
        SetTextColour(255, 255, 255, 255)
        SetTextDropshadow(0, 0, 0, 0, 55)
        SetTextEdge(2, 0, 0, 0, 150)
        SetTextDropShadow()
        SetTextOutline()
        SetTextEntry("STRING")
        SetTextCentre(1)
        AddTextComponentString(text)
        DrawText(_x,_y)
    end
end












--fuel start

	
--fuel end

function canCruise(get_ped_veh)
	local ped = PlayerPedId()
	if not IsPedSittingInAnyVehicle(ped) then
		return false
	end
	if IsPedInAnyBoat(ped) or IsPedInAnySub(ped) or IsPedInAnyHeli(ped) or IsPedInAnyPlane(ped) or IsPedInFlyingVehicle(ped) then
		return false
	end
	if IsThisModelABicycle(GetEntityModel(get_ped_veh)) then
		return false
	end
	if IsVehicleSirenOn(get_ped_veh) or IsPedJumpingOutOfVehicle(ped) or IsVehicleStopped(ped) then
		return false
	end
	if GetEntitySpeedVector(get_ped_veh, true).y < 1 or GetEntitySpeed(get_ped_veh) * 3.6 < 40 then
		return false
	end

	return true
end

function EnableCruise(get_ped_veh)
	cruise.airTime = 0
	cruise.enabled = true
	cruise.speed = GetEntitySpeed(get_ped_veh)
	TriggerEvent("DoLongHudText",'Cruise Activated',11)
end

function DisableCruise(showMsg)
	cruise.airTime = 0
	cruise.enabled = false
	if showMsg then
		TriggerEvent("DoLongHudText",'Cruise Deactivated',11)	
	end
end


oxyOn = false



RegisterNetEvent("OxyMenu")
AddEventHandler("OxyMenu",function()
	if currentValues["oxy"] > 25.0 then
		--RemoveOxyTank
		TriggerEvent('sendToGui','Remove Oxy Tank','RemoveOxyTank')
	end
end)

RegisterNetEvent("RemoveOxyTank")
AddEventHandler("RemoveOxyTank",function()
	if currentValues["oxy"] > 25.0 then
		currentValues["oxy"] = 25.0
		TriggerEvent('menu:hasOxygenTank', false)
	end
end)

RegisterNetEvent("UseOxygenTank")
AddEventHandler("UseOxygenTank",function()
	currentValues["oxy"] = 100.0
	TriggerEvent('menu:hasOxygenTank', true)
end)
dstamina = 0
-- stress, 10000 is maximum, 0 being lowest.
RegisterNetEvent("client:updateStress")
AddEventHandler("client:updateStress",function(newStress)
	stresslevel = newStress
end)
sitting = false



function RevertToStressMultiplier()

	local factor = (stresslevel / 2) / 10000
	local factor = 1.0 - factor


	if factor > 0.1 then

		SetSwimMultiplierForPlayer(PlayerId(), factor)
		SetRunSprintMultiplierForPlayer(PlayerId(), factor)
	else
		SetRunSprintMultiplierForPlayer(PlayerId(), 1.0)
	end

end






imdead = 0

RegisterNetEvent('hadtreat')
AddEventHandler('hadtreat', function(arg1,arg2,arg3)
	local model = GetEntityModel(PlayerPedId())
    if model ~= GetHashKey("a_c_chop") then return end

    dstamina = 400
    SetRunSprintMultiplierForPlayer(PlayerId(), 1.25)

    while dstamina > 0 do

        Citizen.Wait(1000)
        RestorePlayerStamina(PlayerId(), 1.0)
        dstamina = dstamina - 1

    end

    dstamina = 0

    if IsPedRunning(PlayerPedId()) then
        SetPedToRagdoll(PlayerPedId(),1000,1000, 3, 0, 0, 0)
    end

    SetRunSprintMultiplierForPlayer(PlayerId(), 1.0)
    RevertToStressMultiplier()

end)

RegisterNetEvent('hadcocaine')
AddEventHandler('hadcocaine', function(arg1,arg2,arg3)
    dstamina = 0

	if math.random(100) > 50 then
		Drugs1()
	else
		Drugs2()
	end

    if stresslevel > 500 then
	   	SetRunSprintMultiplierForPlayer(PlayerId(), 1.08)
	    dstamina = 200
	else
	    SetRunSprintMultiplierForPlayer(PlayerId(), 1.1)
	    dstamina = 200
	end

	TriggerEvent("client:newStress",false,math.random(250))

    while dstamina > 0 do

        Citizen.Wait(1000)
        RestorePlayerStamina(PlayerId(), 1.0)
        dstamina = dstamina - 1

        if IsPedRagdoll(PlayerPedId()) then
            SetPedToRagdoll(PlayerPedId(), math.random(5), math.random(5), 3, 0, 0, 0)
        end

        local armor = GetPedArmour(PlayerPedId())
        if armor < 60 then
            armor = armor + 3
            if armor > 60 then
                armor = 60
            end
            SetPedArmour(PlayerPedId(),armor)
        end

          if math.random(500) < 3 then
              if math.random(100) > 50 then
                  Drugs1()
              else
                  Drugs2()
              end
              Citizen.Wait(math.random(30000))
        end

        if math.random(100) > 91 and IsPedRunning(PlayerPedId()) then
            SetPedToRagdoll(PlayerPedId(), math.random(1000), math.random(1000), 3, 0, 0, 0)
        end
        
    end

    dstamina = 0

    if IsPedRunning(PlayerPedId()) then
        SetPedToRagdoll(PlayerPedId(),1000,1000, 3, 0, 0, 0)
    end

    SetRunSprintMultiplierForPlayer(PlayerId(), 1.0)
    RevertToStressMultiplier()

end)

RegisterNetEvent('hadcrack')
AddEventHandler('hadcrack', function(arg1,arg2,arg3)
    dstamina = 0
    Citizen.Wait(1000)

	if math.random(100) > 50 then
		Drugs1()
	else
		Drugs2()
	end

    if stresslevel > 500 then
	   	SetRunSprintMultiplierForPlayer(PlayerId(), 1.25)
	    dstamina = 30
	else
	    SetRunSprintMultiplierForPlayer(PlayerId(), 1.35)
	    dstamina = 30
	end

	TriggerEvent("client:newStress",true,math.ceil(1250))

    while dstamina > 0 do

        Citizen.Wait(1000)
        RestorePlayerStamina(PlayerId(), 1.0)
        dstamina = dstamina - 1

        if IsPedRagdoll(PlayerPedId()) then
            SetPedToRagdoll(PlayerPedId(), math.random(5), math.random(5), 3, 0, 0, 0)
        end

	  	if math.random(500) < 100 then
	  		if math.random(100) > 50 then
	  			Drugs1()
	  		else
	  			Drugs2()
	  		end
		  	Citizen.Wait(math.random(30000))
		end

        if math.random(100) > 91 and IsPedRunning(PlayerPedId()) then
            SetPedToRagdoll(PlayerPedId(), math.random(1000), math.random(1000), 3, 0, 0, 0)
        end
        
    end

    dstamina = 0

    if IsPedRunning(PlayerPedId()) then
        SetPedToRagdoll(PlayerPedId(),6000,6000, 3, 0, 0, 0)
    end

    SetRunSprintMultiplierForPlayer(PlayerId(), 1.0)
    RevertToStressMultiplier()

end)





RegisterNetEvent('hadenergy')
AddEventHandler('hadenergy', function(arg1,arg2,arg3)

    dstamina = 0
    Citizen.Wait(1000)

    SetRunSprintMultiplierForPlayer(PlayerId(), 1.005)
    dstamina = 30

    if stresslevel > 1500 then
	    SetRunSprintMultiplierForPlayer(PlayerId(), 1.0005)
	    dstamina = 115
	elseif stresslevel > 5000 then
	    SetRunSprintMultiplierForPlayer(PlayerId(), 1.0)
	    dstamina = 60
	end

	TriggerEvent("client:newStress",true,math.ceil(40))

    while dstamina > 0 do
        Citizen.Wait(1000)
        RestorePlayerStamina(PlayerId(), 1.0)
        dstamina = dstamina - 1
        if IsPedRagdoll(PlayerPedId()) then
            SetPedToRagdoll(PlayerPedId(), math.random(55), math.random(55), 3, 0, 0, 0)
        end
        if math.random(100) > 85 and IsPedRunning(PlayerPedId()) then
            SetPedToRagdoll(PlayerPedId(), math.random(4000), math.random(4000), 3, 0, 0, 0)
        end
    end
    dstamina = 0
    SetRunSprintMultiplierForPlayer(PlayerId(), 1.0)
    if IsPedRunning(PlayerPedId()) then
        SetPedToRagdoll(PlayerPedId(),6000,6000, 3, 0, 0, 0)
    end
    RevertToStressMultiplier()
end)




relaxing = false
RegisterNetEvent("client:stressHandler")
AddEventHandler("client:stressHandler",function(reduction)
	if relaxing then
	 return 
	end
	relaxing = true
	while relaxing do
		Citizen.Wait(30000)
		TriggerServerEvent("server:alterStress",false,reduction)
	end
end)

function GetInWheelChair()
	local ped = PlayerPedId()
	pos = GetEntityCoords(ped)
	head = GetEntityHeading(ped)

	local pos = GetOffsetFromEntityInWorldCoords(PlayerPedId(), 0.0, -0.85, -0.45)

	local chair = CreateObject( `prop_wheelchair_01_s`, pos.x, pos.y, pos.z, true, true, true)

	SetEntityCoords(chair, pos.x, pos.y, pos.z-0.85)
	Citizen.Wait(1000)
	TaskStartScenarioAtPosition(ped, 'PROP_HUMAN_SEAT_BENCH', pos.x, pos.y, pos.z, GetEntityHeading(ped), 0, true, true)
	sitting = true
	while sitting do
		AttachEntityToEntity(chair, ped, 11816, 0.0, 0.0, -0.6, 0.0, 0.0, 180.0, true, true, true, true, 1, true)
		Citizen.Wait(1)
	end
end











-- add stress TriggerEvent("client:newStress",true,10)
-- remove stress TriggerEvent("client:newStress",false,10)


local stressDisabled = false
RegisterNetEvent("client:disableStress")
AddEventHandler("client:disableStress",function(stressNew)
	stressDisabled = stressNew
end)

RegisterNetEvent("client:newStress")
AddEventHandler("client:newStress",function(positive,alteredValue)
	if stressDisabled then
		return
	end
	if positive then
		TriggerEvent("DoShortHudText",'Stress Gained',6)
	else
		TriggerEvent("DoShortHudText",'Stress Relieved',6)
	end
	
	TriggerServerEvent("server:alterStress",positive,alteredValue)
end)


RegisterNetEvent("stress:timed")
AddEventHandler("stress:timed",function(alteredValue,scenario)
	local removedStress = 0
	Wait(1000)

	TriggerEvent("DoShortHudText",'Stress is being relieved',6)
	SetPlayerMaxArmour(PlayerId(), 60 )
	while true do
		removedStress = removedStress + 100
		if removedStress >= alteredValue then
			break
		end
        local armor = GetPedArmour(PlayerPedId())
        SetPedArmour(PlayerPedId(),armor+3)
		if scenario ~= "None" then
			if not IsPedUsingScenario(PlayerPedId(),scenario) then
				TriggerEvent("animation:cancel")
				break
			end
		end
		Citizen.Wait(1000)
	end
	TriggerServerEvent("server:alterStress",false,removedStress)
end)








opacity = 0
fadein = false

stresslevel = 0

local opacityBars = 0 
local Addition = 0.0






function NotificationMessage(message)
	SetNotificationTextEntry("STRING")
	AddTextComponentString(message)
	DrawNotification(0,1)
end

RegisterNetEvent("hud:setClientMeta")
AddEventHandler("hud:setClientMeta",function(meta)
	if meta == nil then return end
	print(json.encode(meta))
	if meta.thirst == nil then currentValues["thirst"] = 100 else currentValues["thirst"] = meta.thirst end
	if meta.hunger == nil then currentValues["hunger"] = 100 else currentValues["hunger"] = meta.hunger end
	if meta.health == nil or meta.health < 10.0 then
		SetEntityHealth(PlayerPedId(),10.0)
	else
		SetEntityHealth(PlayerPedId(),meta.health)
	end
	SetPlayerMaxArmour(PlayerPedId(), 60 )
	print(meta.armor)
	SetPedArmour(PlayerPedId(),meta.armor)
	print("Triggered CMeta")
	TriggerClientEvent('DoLongHudText', 'Meta andmed saadud')
end)









-- SetEntityHealth(playerPed, GetPedMaxHealth(playerPed)/2)

--NetworkSetVoiceChannel

local colorblind = false
RegisterNetEvent('option:colorblind')
AddEventHandler('option:colorblind',function()
    colorblind = not colorblind
end)

local lastDamageTrigger = 0

RegisterNetEvent("fire:damageUser")
AddEventHandler("fire:damageUser", function(Reqeuester)
	if not DoesPlayerExist(Reqeuester) then return end

	local attacker = GetPlayerFromServerId(Reqeuester)
	local Attackerped = GetPlayerPed(attacker)

	if IsPedShooting(Attackerped) then
		local name = GetSelectedPedWeapon(Attackerped)
        if name == `WEAPON_FIREEXTINGUISHER` and not exports["isPed"]:isPed("dead") then
        	lastDamageTrigger = GetGameTimer()
        	currentValues["oxy"] = currentValues["oxy"] - 15
        end
	end
end)




Citizen.CreateThread(function()

	while true do
		Wait(1)
		if currentValues["oxy"] > 0 and IsPedSwimmingUnderWater(PlayerPedId()) then
			SetPedDiesInWater(PlayerPedId(), false)
			if currentValues["oxy"] > 25.0 then
				currentValues["oxy"] = currentValues["oxy"] - 0.003125
			else
				currentValues["oxy"] = currentValues["oxy"] - 1
			end
		else
			if IsPedSwimmingUnderWater(PlayerPedId()) then
				currentValues["oxy"] = currentValues["oxy"] - 0.01
				SetPedDiesInWater(PlayerPedId(), true)
			end
		end

		if not IsPedSwimmingUnderWater( PlayerPedId() ) and currentValues["oxy"] < 25.0 then
			if GetGameTimer() - lastDamageTrigger > 3000 then
				currentValues["oxy"] = currentValues["oxy"] + 1
				if currentValues["oxy"] > 25.0 then
					currentValues["oxy"] = 25.0
				end
			else
				if currentValues["oxy"] <= 0 then
					
					if exports["isPed"]:isPed("dead") then
						lastDamageTrigger = -7000
						currentValues["oxy"] = 25.0
					else
						SetEntityHealth(PlayerPedId(), GetEntityHealth(PlayerPedId()) - 20)
					end
				end
			end
		end

		if currentValues["oxy"] > 25.0 and not oxyOn then
			oxyOn = true
			attachProp("p_s_scuba_tank_s", 24818, -0.25, -0.25, 0.0, 180.0, 90.0, 0.0)
			attachProp2("p_s_scuba_mask_s", 12844, 0.0, 0.0, 0.0, 180.0, 90.0, 0.0)
		elseif oxyOn and currentValues["oxy"] <= 25.0 then
			oxyOn = false
			removeAttachedProp()
			removeAttachedProp2()
		end
		if not oxyOn then
			Wait(1000)
    end
    -- currentValues["is_talking"] = NetworkIsPlayerTalking(PlayerId())
	end
end)

Citizen.CreateThread(function ()
	while true do
		local isTalking = NetworkIsPlayerTalking(PlayerId())

		if isTalking and not currentValues["is_talking"] then
			SendNUIMessage({type = "talkingStatus", is_talking = true})
		elseif not isTalking and currentValues["is_talking"] then
			SendNUIMessage({type = "talkingStatus", is_talking = false})
		end

		currentValues["is_talking"] = isTalking

		Citizen.Wait(100)
	end
end)

AddEventHandler("hud:voice:transmitting", function (transmitting)
	SendNUIMessage({type = "transmittingStatus", is_transmitting = transmitting})
end)

function lerp(min, max, amt)
	return (1 - amt) * min + amt * max
end
function rangePercent(min, max, amt)
	return (((amt - min) * 100) / (max - min)) / 100
end



-- this should just use nui instead of drawrect - it literally ass fucks usage.
Citizen.CreateThread(function()
	Wait(1000)
	local defaultAspectRatio = 1920 / 1080 -- Don't change this.
    local resolutionX, resolutionY = GetActiveScreenResolution()
    local aspectRatio = resolutionX / resolutionY
    local minimapOffset = 0
    if aspectRatio > defaultAspectRatio then
        minimapOffset = ((defaultAspectRatio - aspectRatio) / 3.6) - 0.008
    end
	RequestStreamedTextureDict('squaremap', false)
	if not HasStreamedTextureDictLoaded('squaremap') then
		Wait(150)
	end
	
	TriggerEvent('DoLongHudText','Kaart on laetud')
	
	SetMinimapClipType(0)
	AddReplaceTexture('platform:/textures/graphics', 'radarmasksm', 'squaremap', 'radarmasksm')
	AddReplaceTexture('platform:/textures/graphics', 'radarmask1g', 'squaremap', 'radarmasksm')
	-- 0.0 = nav symbol and icons left
	-- 0.1638 = nav symbol and icons stretched
	-- 0.216 = nav symbol and icons raised up
	SetMinimapComponentPosition('minimap', 'L', 'B', 0.0 + minimapOffset, -0.047, 0.1638, 0.183)

	-- icons within map
	SetMinimapComponentPosition('minimap_mask', 'L', 'B', 0.0 + minimapOffset, 0.0, 0.128, 0.20)

	-- -0.01 = map pulled left
	-- 0.025 = map raised up
	-- 0.262 = map stretched
	-- 0.315 = map shorten
	SetMinimapComponentPosition('minimap_blur', 'L', 'B', -0.01 + minimapOffset, 0.025, 0.262, 0.300)
	SetBlipAlpha(GetNorthRadarBlip(), 0)
	SetRadarBigmapEnabled(true, false)
	SetMinimapClipType(0)
	Wait(50)
	SetRadarBigmapEnabled(false, false)
        



	local counter = 0
	local pdata = ESX.GetPlayerData()
	local get_ped_veh = GetVehiclePedIsIn(get_ped,false) -- Current Vehicle ped is in
	local plate_veh = GetVehicleNumberPlateText(get_ped_veh) -- Vehicle Plate
	local veh_stop = IsVehicleStopped(get_ped_veh) -- Parked or not
	local veh_engine_health = GetVehicleEngineHealth(get_ped_veh) -- Vehicle Engine Damage 
	local veh_body_health = GetVehicleBodyHealth(get_ped_veh)
	local veh_burnout = IsVehicleInBurnout(get_ped_veh) -- Vehicle Burnout
	local thespeed = GetEntitySpeed(get_ped_veh) * 3.6
	currentValues["voice"] = voice
	currentValues["stress"] = 0
	TriggerEvent('esx_status:getStatus', 'hunger', function(status) 
		currentValues["hunger"] = status.val / 10000 
	end)
	TriggerEvent('esx_status:getStatus', 'thirst', function(status) 
		currentValues["thirst"] = status.val / 10000 
	end)
	currentValues["parachute"] = HasPedGotWeapon(get_ped, `gadget_parachute`, false)
	currentValues["health"] = GetEntityHealth(get_ped) - 100
	while true do

		if sleeping then
			if IsControlJustReleased(0,38) then
				sleeping = false
				DetachEntity(PlayerPedId(), 1, true)
			end
		end

		Citizen.Wait(1)
		

		if counter == 0 then
			 -- current ped
			get_ped = PlayerPedId()
			SetPedSuffersCriticalHits(get_ped,false)
			get_ped_veh = GetVehiclePedIsIn(get_ped,false) -- Current Vehicle ped is in
			plate_veh = GetVehicleNumberPlateText(get_ped_veh) -- Vehicle Plate
			veh_stop = IsVehicleStopped(get_ped_veh) -- Parked or not
			veh_engine_health = GetVehicleEngineHealth(get_ped_veh) -- Vehicle Engine Damage 
			veh_body_health = GetVehicleBodyHealth(get_ped_veh)
			veh_burnout = IsVehicleInBurnout(get_ped_veh) -- Vehicle Burnout
			thespeed = GetEntitySpeed(get_ped_veh) * 3.6
			TriggerEvent('esx_status:getStatus', 'hunger', function(status) 
				currentValues["hunger"] = status.val / 10000 
			end)
        	TriggerEvent('esx_status:getStatus', 'thirst', function(status) 
				currentValues["thirst"] = status.val / 10000 
			end)
			currentValues["health"] = GetEntityHealth(get_ped) - 100
			currentValues["armor"] = GetPedArmour(get_ped)
			currentValues["stress"] = 0
			currentValues["parachute"] = HasPedGotWeapon(get_ped, `gadget_parachute`, false)

			

			local valueChanged = false


			for k,v in pairs(currentValues) do
				if lastValues[k] == nil or lastValues[k] ~= v then
					valueChanged = true
					lastValues[k] = v
				end
			end
			
			if valueChanged then
			
				SendNUIMessage({
					type = "updateStatusHud",
					varSetHealth = currentValues["health"],
					varSetArmor = currentValues["armor"],
					varSetHunger = currentValues["hunger"],
					varSetThirst = currentValues["thirst"],
					varSetOxy = currentValues["oxy"],
					varSetStress = currentValues["stress"],
					colorblind = colorblind,
					varSetVoice = LocalPlayer.state['proximity'].distance,
					varDev = currentValues["dev"],
					varDevDebug = currentValues["devdebug"],
					is_talking = currentValues["is_talking"]
				})
			
			end
			Restart(currentValues["hunger"], currentValues["thirst"])
			counter = 25

		end

		counter = counter - 1

		if get_ped_veh ~= 0 then
            local model = GetEntityModel(get_ped_veh)
            local roll = GetEntityRoll(get_ped_veh)
  
            -- if not IsThisModelABoat(model) and not IsThisModelAHeli(model) and not IsThisModelAPlane(model) and IsEntityInAir(get_ped_veh) or (roll < -50 or roll > 50) then
            --     DisableControlAction(0, 59) -- leaning left/right
            --     DisableControlAction(0, 60) -- leaning up/down
            -- end

            if GetPedInVehicleSeat(GetVehiclePedIsIn(get_ped, false), 0) == get_ped then
                if GetIsTaskActive(get_ped, 165) then
                    SetPedIntoVehicle(get_ped, GetVehiclePedIsIn(get_ped, false), 0)
                end
            end

            DisplayRadar(1)
            SetRadarZoom(1000)
        else
            DisplayRadar(0)
        end

        BeginScaleformMovieMethod(minimap, "SETUP_HEALTH_ARMOUR")
        ScaleformMovieMethodAddParamInt(3)
        EndScaleformMovieMethod()
    end
end)

RegisterNetEvent('hud:saveCurrentMeta')
AddEventHandler('hud:saveCurrentMeta', function()
	
	
	TriggerServerEvent("hud:setServerMeta", currentValues["health"] , currentValues["armor"] , currentValues["thirst"], currentValues["hunger"], currentValues["stress"])
end)

CreateThread(function()
	while true do
		Wait(1000)
		
		SendNUIMessage({
			type = "timerupdate",
			time = 'V 1.2.5',
		})
	end


end)
RegisterNetEvent('hud:client:UpdateNeeds', function(hunger, thirst) -- Triggered in rs-base
    local hung = hunger
    local thir = thirst
	local health = GetEntityHealth(PlayerPedId())
	local armor = GetPedArmour(PlayerPedId())
	TriggerServerEvent("hud:setServerMeta", health, armor, thir, hung, stress)
end)

Citizen.CreateThread(function()
	local pdata = ESX.GetPlayerData()
	
    while true do
		Wait(1000)
		local waiting = (2000 * 30) * 3
		
    	if currentValues["hunger"] > 0 then
    		currentValues["hunger"] = currentValues["hunger"] - 1
    	end
	    if currentValues["thirst"] > 0 then
    		currentValues["thirst"] = currentValues["thirst"] - 2
    	end
    	TriggerEvent('hud:client:UpdateNeeds', currentValues["hunger"], currentValues["thirst"])
    	TriggerServerEvent("hud:setServerMeta",GetEntityHealth(PlayerPedId()),GetPedArmour(PlayerPedId()),currentValues["thirst"],currentValues["hunger"])
		Citizen.Wait(waiting)

		if currentValues["thirst"] < 20 or currentValues["hunger"] < 20 then


			local newhealth = GetEntityHealth(PlayerPedId()) - math.random(10)
			SetEntityHealth(PlayerPedId(), newhealth)
			
		end
	end
end)







-- Citizen.CreateThread( function()

-- 	while true do 
-- 		local dst = gateCheck()
-- 		if dst < 55.0 then
-- 			rotateGates()
-- 		else
-- 			Citizen.Wait(tonumber(math.ceil(dst)))
-- 		end
-- 		Citizen.Wait(1)
-- 	end
-- end)



Citizen.CreateThread( function()

	local resetcounter = 0
	local jumpDisabled = false
  	
  	while true do 
    Citizen.Wait(100)

  --  if IsRecording() then
  --      StopRecordingAndDiscardClip()
  --  end     

		if jumpDisabled and resetcounter > 0 and IsPedJumping(PlayerPedId()) then
			
			SetPedToRagdoll(PlayerPedId(), 1000, 1000, 3, 0, 0, 0)

			resetcounter = 0
		end

		if not jumpDisabled and IsPedJumping(PlayerPedId()) then

			jumpDisabled = true
			resetcounter = 10
			Citizen.Wait(1200)
		end

		if resetcounter > 0 then
			resetcounter = resetcounter - 1
		else
			if jumpDisabled then
				resetcounter = 0
				jumpDisabled = false
			end
		end
	end
end)






Citizen.CreateThread( function()

	
	while true do 

		 if IsPedArmed(PlayerPedId(), 6) then
		 	Citizen.Wait(1)
		 else
		 	Citizen.Wait(1500)
		 end  

	    if IsPedShooting(PlayerPedId()) then
	    	local ply = PlayerPedId()
	    	local GamePlayCam = GetFollowPedCamViewMode()
	    	local Vehicled = IsPedInAnyVehicle(ply, false)
	    	local MovementSpeed = math.ceil(GetEntitySpeed(ply))

	    	if MovementSpeed > 69 then
	    		MovementSpeed = 69
	    	end

	        local _,wep = GetCurrentPedWeapon(ply)

	        local group = GetWeapontypeGroup(wep)

	        local p = GetGameplayCamRelativePitch()

	        local cameraDistance = #(GetGameplayCamCoord() - GetEntityCoords(ply))

	        local recoil = math.random(130,140+(math.ceil(MovementSpeed*1.5)))/100
	        local rifle = false


          	if group == 970310034 or group == 1159398588 then
          		rifle = true
          	end


          	if cameraDistance < 5.3 then
          		cameraDistance = 1.5
          	else
          		if cameraDistance < 8.0 then
          			cameraDistance = 4.0
          		else
          			cameraDistance = 7.0
          		end
          	end


	        if Vehicled then
	        	recoil = recoil + (recoil * cameraDistance)
	        else
	        	recoil = recoil * 0.3
	        end

	        if GamePlayCam == 4 then

	        	recoil = recoil * 0.7
		        if rifle then
		        	recoil = recoil * 0.1
		        end

	        end

	        if rifle then
	        	recoil = recoil * 0.1
	        end

	        local rightleft = math.random(4)
	        local h = GetGameplayCamRelativeHeading()
	        local hf = math.random(10,40+MovementSpeed)/100

	        if Vehicled then
	        	hf = hf * 2.0
	        end

	        if rightleft == 1 then
	        	SetGameplayCamRelativeHeading(h+hf)
	        elseif rightleft == 2 then
	        	SetGameplayCamRelativeHeading(h-hf)
	        end 
        
	        local set = p+recoil

	       	SetGameplayCamRelativePitch(set,0.8)    	       	

	       	
	      -- 	print(GetGameplayCamRelativePitch())

	    end
	end

end)

function GetClosestPlayer()
    local players = GetPlayers()
    local closestDistance = -1
    local closestPlayer = -1
    local ply = PlayerPedId()
    local plyCoords = GetEntityCoords(ply, 0)
    
    for index,value in ipairs(players) do
        local target = GetPlayerPed(value)
        if(target ~= ply) then
            local targetCoords = GetEntityCoords(GetPlayerPed(value), 0)
            local distance = #(vector3(targetCoords["x"], targetCoords["y"], targetCoords["z"]) - vector3(plyCoords["x"], plyCoords["y"], plyCoords["z"]))
            if(closestDistance == -1 or closestDistance > distance) then
                closestPlayer = value
                closestDistance = distance
            end
        end
    end
    
    return closestPlayer
end


function GetPlayers()
    local players = {}

    for i = 0, 255 do
        if NetworkIsPlayerActive(i) then
            players[#players+1]= i
        end
    end

    return players
end


/*RegisterNetEvent("client:newStress")
AddEventHandler("client:newStress",function(positive, alteredValue, notify)
	if stressDisabled then
		return
	end
	if notify then
		if positive then
			TriggerEvent("DoShortHudText",'Stress Gained',6)
		else
			TriggerEvent("DoShortHudText",'Stress Relieved',6)
		end
	end
	
	TriggerServerEvent("server:alterStress",positive,alteredValue)
end)*/