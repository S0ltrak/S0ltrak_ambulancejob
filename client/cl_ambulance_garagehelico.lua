CreateThread(function()
    while ESX.GetPlayerData().job == nil do
		Wait(10)
    end
    if ESX.IsPlayerLoaded() then

		ESX.PlayerData = ESX.GetPlayerData()

    end
end)

RegisterNetEvent('esx:playerLoaded', function(xPlayer)
	ESX.PlayerData = xPlayer
end)


RegisterNetEvent('esx:setJob', function(job)
	ESX.PlayerData.job = job
end)

-------------

-- Création du menu
MenuGarageHelicoAmbulance = {}
MenuGarageHelicoAmbulance.Toggle = false
function MenuGarageHelicoAmbulanceCreate()
    MenuGarageHelicoAmbulance.Toggle = true
    MainGarageHelicoAmbulance = RageUI.CreateMenu("Ambulance", "GARAGE", nil, nil, nil, nil)
    MainGarageHelicoAmbulance.Closed = function()
        MenuGarageHelicoAmbulance.Toggle = false
    end
end

function OpenGarageHelicoAmbulance()
    MenuGarageHelicoAmbulanceCreate() 
    RageUI.Visible(MainGarageHelicoAmbulance, true) 
    CreateThread(function()
        while true do 
            Wait(2.0)
            if MenuGarageHelicoAmbulance.Toggle then 
                RageUI.IsVisible(MainGarageHelicoAmbulance, function()
                    
                    RageUI.Button('Ranger le véhicule', nil, {RightLabel = ConfigTiscoGlobal.RightLabel}, true, {
                        onSelected = function()

                            local playerPed = PlayerPedId()

                            if IsPedSittingInAnyVehicle(playerPed) then
                                local vehicle = GetVehiclePedIsIn(playerPed, false)
                        
                                if GetPedInVehicleSeat(vehicle, -1) == playerPed then
                                    DoScreenFadeOut(1500)
                                    Wait(1500)
                                    ESX.ShowNotification('Le véhicule a été ~b~rangé ~s~dans le garage')
                                    ESX.Game.DeleteVehicle(vehicle)
                                    DoScreenFadeIn(1500)
                                   
                                else
                                    ESX.ShowNotification('Mettez-vous place conducteur ou sortez de la voiture')
                                end
                            else
                                local vehicle = ESX.Game.GetVehicleInDirection()
                        
                                if DoesEntityExist(vehicle) then
                                    DoScreenFadeOut(1500)
                                    Wait(1500)
                                    ESX.ShowNotification('Le véhicule a été ~b~rangé ~s~dans le garage')
                                    ESX.Game.DeleteVehicle(vehicle)
                                    DoScreenFadeIn(1500)
                        
                                else
                                    ESX.ShowNotification('~r~Aucun véhicule à proximité')
                                end
                            end

                        end
                    })

                    RageUI.Line()

                    for k,v in pairs(ConfigTiscoJobs.ambulance.HelicoAmbulance) do
                        RageUI.Button(v.buttonameheli, nil, {RightLabel = ConfigTiscoGlobal.RightLabel}, true , {
                            onSelected = function()
                                if not ESX.Game.IsSpawnPointClear(vector3(v.spawnzoneheli.x, v.spawnzoneheli.y, v.spawnzoneheli.z), 10.0) then
                                    ESX.ShowNotification("~r~Le point de spawn est bloqué")
                                else
                                    DoScreenFadeOut(1500)
                                    Wait(1500)
                                    local model = GetHashKey(v.spawnnameheli)
                                    RequestModel(model)
                                    while not HasModelLoaded(model) do Wait(10) end
                                    local ambulanceheli = CreateVehicle(model, v.spawnzoneheli.x, v.spawnzoneheli.y, v.spawnzoneheli.z, v.headingspawnheli, true, false)
                                    SetVehicleNumberPlateText(ambulanceheli, "ambulance"..math.random(50, 999))
                                    SetVehicleFixed(ambulanceheli)
                                    TaskWarpPedIntoVehicle(PlayerPedId(),  ambulanceheli,  -1)
                                    SetVehRadioStation(ambulanceheli, 0)
                                    RageUI.CloseAll()
                                    DoScreenFadeIn(1500)
                                end
                            end
                        })
                    end

                end)
            else
                RageUI.Visible(MainGarageHelicoAmbulance, false) 
                if not RageUI.Visible(MainGarageHelicoAmbulance) then
                    MainGarageHelicoAmbulance = RMenu:DeleteType('MainGarageHelicoAmbulance', true) 
                end
                return false 
            end
        end
    end)
end

------------

CreateThread(function()
    while true do
        Wait(1.0)
        local intervale = true 
        local pedCoords = GetEntityCoords(PlayerPedId())
        for i = 1, #ConfigTiscoJobs.ambulance.GarageHelico.pos do
            local distance = #(pedCoords - ConfigTiscoJobs.ambulance.GarageHelico.pos[i])
            if distance < ConfigTiscoJobs.ambulance.Marker.Distance then intervale = false 
                if ESX.PlayerData.job and ESX.PlayerData.job.name == 'ambulance' then
                    if not MenuGarageHelicoAmbulance.Toggle then
                        DrawMarker(ConfigTiscoJobs.ambulance.Marker.Type, (ConfigTiscoJobs.ambulance.GarageHelico.pos[i]), 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, ConfigTiscoJobs.ambulance.Marker.SizeLargeur, ConfigTiscoJobs.ambulance.Marker.SizeEpaisseur, ConfigTiscoJobs.ambulance.Marker.SizeHauteur, ConfigTiscoJobs.ambulance.Marker.ColorR, ConfigTiscoJobs.ambulance.Marker.ColorG, ConfigTiscoJobs.ambulance.Marker.ColorB, ConfigTiscoJobs.ambulance.Marker.Opacite, ConfigTiscoJobs.ambulance.Marker.Saute, false, false, ConfigTiscoJobs.ambulance.Marker.Tourne)
                    end
                    if distance <= 3.0 then
                        if not MenuGarageHelicoAmbulance.Toggle then 
                            ESX.ShowHelpNotification("Appuyer sur ~INPUT_CONTEXT~ pour accéder au garage") 
                            if IsControlJustPressed(1,51) then 
                                OpenGarageHelicoAmbulance() 
                            end
                        end
                    else
                        MenuGarageHelicoAmbulance.Toggle = false 
                    end
                end
            end
        end
        
        if intervale then 
            Wait(500)
        end
    end
end)


print("Script by S0ltrak for ^2DevHub's^7")
print("^2Discord : https://discord.gg/3eSufdKtdH^7")