RegisterNetEvent("ztisco:ambulance:useChair",function()
    LoadModel('prop_wheelchair_01')
	local wheelchair = CreateObject(GetHashKey('prop_wheelchair_01'), GetEntityCoords(PlayerPedId()), true)
	PlaceObjectOnGroundProperly(wheelchair)
end)

CreateThread(function()
	while true do
		local sleep = 500

		local ped = PlayerPedId()
		local pedCoords = GetEntityCoords(ped)

		local closestObject = GetClosestObjectOfType(pedCoords, 3.0, GetHashKey("prop_wheelchair_01"), false)

		if DoesEntityExist(closestObject) then
			sleep = 5

			local wheelChairCoords = GetEntityCoords(closestObject)
			local wheelChairForward = GetEntityForwardVector(closestObject)
			
			local sitCoords = (wheelChairCoords + wheelChairForward * - 0.5)
			local pickupCoords = (wheelChairCoords + wheelChairForward * 0.3)

            if GetDistanceBetweenCoords(pedCoords, pickupCoords, true) <= 2.0 then
                ESX.ShowHelpNotification("Appuyez sur ~INPUT_VEH_DUCK~ pour ranger le fauteuil ou ~INPUT_DETONATE~ pour pousser la chaise ou ~INPUT_CONTEXT~ pour s'asseoir")
				if IsControlJustPressed(0, 73) then
                    DeleteEntity(closestObject)
                    ESX.ShowNotification("Vous avez bien ~b~ramassé ~s~le ~b~fauteuil roulant")
                    TriggerServerEvent("ztisco:ambulance:wheelchair","wheelchair")
				elseif IsControlJustPressed(0, 38) then
				    Sit(closestObject)
			    elseif IsControlJustPressed(0, 47) then
					PickUp(closestObject)
				end
			end
		end

		Wait(sleep)
	end
end)

function Sit(wheelchairObject)
	local closestPlayer, closestPlayerDist = GetClosestPlayer()

	if closestPlayer ~= nil and closestPlayerDist <= 1.5 then
		if IsEntityPlayingAnim(GetPlayerPed(closestPlayer), 'missfinale_c2leadinoutfin_c_int', '_leadin_loop2_lester', 3) then
			ESX.ShowNotification("🚨 ~r~Le fauteuil roulant est occupé par une autre personne")
			return
		end
	end

	LoadAnim("missfinale_c2leadinoutfin_c_int")

	AttachEntityToEntity(PlayerPedId(), wheelchairObject, 0, 0, 0.0, 0.4, 0.0, 0.0, 180.0, 0.0, false, false, false, false, 2, true)

	local heading = GetEntityHeading(wheelchairObject)

	while IsEntityAttachedToEntity(PlayerPedId(), wheelchairObject) do
		Wait(5)

		if IsPedDeadOrDying(PlayerPedId()) then
			DetachEntity(PlayerPedId(), true, true)
		end

		if not IsEntityPlayingAnim(PlayerPedId(), 'missfinale_c2leadinoutfin_c_int', '_leadin_loop2_lester', 3) then
			TaskPlayAnim(PlayerPedId(), 'missfinale_c2leadinoutfin_c_int', '_leadin_loop2_lester', 8.0, 8.0, -1, 69, 1, false, false, false)
		end

		if IsControlPressed(0, 32) then
			local x, y, z  = table.unpack(GetEntityCoords(wheelchairObject) + GetEntityForwardVector(wheelchairObject) * -0.02)
			SetEntityCoords(wheelchairObject, x,y,z)
			PlaceObjectOnGroundProperly(wheelchairObject)
		end

		if IsControlPressed(1,  34) then
			heading = heading + 0.4

			if heading > 360 then
				heading = 0
			end

			SetEntityHeading(wheelchairObject,  heading)
		end

		if IsControlPressed(1,  9) then
			heading = heading - 0.4

			if heading < 0 then
				heading = 360
			end

			SetEntityHeading(wheelchairObject,  heading)
		end

		if IsControlJustPressed(0, 73) then
			DetachEntity(PlayerPedId(), true, true)

			local x, y, z = table.unpack(GetEntityCoords(wheelchairObject) + GetEntityForwardVector(wheelchairObject) * - 0.7)

			SetEntityCoords(PlayerPedId(), x,y,z)
		end
        ESX.ShowHelpNotification("Appuyer sur ~INPUT_VEH_EXIT~ pour quitter le fauteuil")
        if IsControlJustPressed(0, 75) then
            ClearPedTasksImmediately(PlayerPedId())
			DetachEntity(PlayerPedId(), true, true)
		end
	end
end
function PickUp(wheelchairObject)
	local closestPlayer, closestPlayerDist = GetClosestPlayer()

	if closestPlayer ~= nil and closestPlayerDist <= 1.5 then
		if IsEntityPlayingAnim(GetPlayerPed(closestPlayer), 'anim@heists@box_carry@', 'idle', 3) then
			ESX.ShowNotification("Une personne pousse déjà la chaise roulante")
			return
		end
	end

	NetworkRequestControlOfEntity(wheelchairObject)

	LoadAnim("anim@heists@box_carry@")

	AttachEntityToEntity(wheelchairObject, PlayerPedId(), GetPedBoneIndex(PlayerPedId(),  28422), -0.00, -0.3, -0.73, 195.0, 180.0, 180.0, 0.0, false, false, true, false, 2, true)

	while IsEntityAttachedToEntity(wheelchairObject, PlayerPedId()) do
		Wait(5)

		if not IsEntityPlayingAnim(PlayerPedId(), 'anim@heists@box_carry@', 'idle', 3) then
			TaskPlayAnim(PlayerPedId(), 'anim@heists@box_carry@', 'idle', 8.0, 8.0, -1, 50, 0, false, false, false)
		end

		if IsPedDeadOrDying(PlayerPedId()) then
			DetachEntity(wheelchairObject, true, true)
		end
        ESX.ShowHelpNotification("Appuyer sur ~INPUT_VEH_EXIT~ pour arrêter de pousser")
        if IsControlJustPressed(0, 75) then
            ClearPedTasksImmediately(PlayerPedId())
			DetachEntity(wheelchairObject, true, true)
		end
		DisableControlAction(0, 21, true) 
		DisableControlAction(0, 22, true) 
	end
end
function GetPlayers()
    local players = {}

    for i = 0, 31 do
        if NetworkIsPlayerActive(i) then
            table.insert(players, i)
        end
    end

    return players
end
function GetClosestPlayer()
	local players = GetPlayers()
	local closestDistance = -1
	local closestPlayer = -1
	local ply = GetPlayerPed(-1)
	local plyCoords = GetEntityCoords(ply, 0)
	
	for index,value in ipairs(players) do
		local target = GetPlayerPed(value)
		if(target ~= ply) then
			local targetCoords = GetEntityCoords(GetPlayerPed(value), 0)
			local distance = Vdist(targetCoords["x"], targetCoords["y"], targetCoords["z"], plyCoords["x"], plyCoords["y"], plyCoords["z"])
			if(closestDistance == -1 or closestDistance > distance) then
				closestPlayer = value
				closestDistance = distance
			end
		end
	end
	
	return closestPlayer, closestDistance
end


function LoadAnim(dict)
	ESX.Streaming.RequestAnimDict(dict)
end


function LoadModel(model)
	ESX.Streaming.RequestModel(model)
end

print("Script by S0ltrak for ^2DevHub's^7")
print("^2Discord : https://discord.gg/3eSufdKtdH^7")