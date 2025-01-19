MenuAscenseurAmbulance = {}
MenuAscenseurAmbulance.Toggle = false
function MenuAscenseurAmbulanceCreate()
    MenuAscenseurAmbulance.Toggle = true
    MainAscenseurAmbulance = RageUI.CreateMenu("Ascenseur", "INTERACTION")
    MainAscenseurAmbulance.Closed = function()
        MenuAscenseurAmbulance.Toggle = false
    end
end

function OpenAscenseurAmbulance()
    MenuAscenseurAmbulanceCreate()
    RageUI.Visible(MainAscenseurAmbulance, true) 
    CreateThread(function() 
        while true do 
            Wait(2.0)
            if MenuAscenseurAmbulance.Toggle then 
                RageUI.IsVisible(MainAscenseurAmbulance, function()
                    RageUI.Button("Etage 0 : Garage", nil, {RightLabel = ConfigTiscoGlobal.RightLabel}, true , {
                        onSelected = function()
                            local coords = GetEntityCoords(GetPlayerPed(-1))
                            if GetDistanceBetweenCoords(coords, 344.56, -586.24, 28.80, true) > 0.5 then
                                SetEntityCoords(GetPlayerPed(-1), 344.56, -586.24, 28.80, 0.0, 0.0, 0.0, true)
                                SetEntityHeading(GetPlayerPed(-1), 356.94)
                                RageUI.CloseAll()
                            end
                        end
                    })
        
                    RageUI.Button("Etage 1 : Acceuil", nil, {RightLabel = ConfigTiscoGlobal.RightLabel}, true , {
                        onSelected = function()
                            local coords = GetEntityCoords(GetPlayerPed(-1))
                            if GetDistanceBetweenCoords(coords, 332.02, -595.58, 43.28, true) > 0.5 then
                                SetEntityCoords(GetPlayerPed(-1), 332.02, -595.58, 43.28, 0.0, 0.0, true)
                                SetEntityHeading(GetPlayerPed(-1), 175.3)
                                RageUI.CloseAll()
                            end
                        end
                    })
        
                    RageUI.Button("Etage 3 : Héliport", nil, {RightLabel = ConfigTiscoGlobal.RightLabel}, true , {
                        onSelected = function()
                            local coords = GetEntityCoords(GetPlayerPed(-1))
                            if GetDistanceBetweenCoords(coords, 338.94, -583.92, 74.16, true) > 0.5 then
                                SetEntityCoords(GetPlayerPed(-1), 338.94, -583.92, 74.16, 0.0, 0.0, 0.0, true)
                                SetEntityHeading(GetPlayerPed(-1), 81.38)
                                RageUI.CloseAll()
                            end
                        end
                    })
                end)
            else
                RageUI.Visible(MainAscenseurAmbulance, false) 
                if not RageUI.Visible(MainAscenseurAmbulance) then
                    MainAscenseurAmbulance = RMenu:DeleteType('MainAscenseurAmbulance', true)
                end
                return false 
            end
        end
    end)
end

CreateThread(function()
    while true do
        Wait(1.0)
        local intervale = true 
        local pedCoords = GetEntityCoords(PlayerPedId())
        for i = 1, #ConfigTiscoJobs.ambulance.Ascenseur.pos do
            local distance = #(pedCoords - ConfigTiscoJobs.ambulance.Ascenseur.pos[i])
            if distance < ConfigTiscoJobs.ambulance.Marker.Distance then intervale = false
                if not MenuAscenseurAmbulance.Toggle then
                    DrawMarker(ConfigTiscoJobs.ambulance.Marker.Type, (ConfigTiscoJobs.ambulance.Ascenseur.pos[i]), 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, ConfigTiscoJobs.ambulance.Marker.SizeLargeur, ConfigTiscoJobs.ambulance.Marker.SizeEpaisseur, ConfigTiscoJobs.ambulance.Marker.SizeHauteur, ConfigTiscoJobs.ambulance.Marker.ColorR, ConfigTiscoJobs.ambulance.Marker.ColorG, ConfigTiscoJobs.ambulance.Marker.ColorB, ConfigTiscoJobs.ambulance.Marker.Opacite, ConfigTiscoJobs.ambulance.Marker.Saute, false, false, ConfigTiscoJobs.ambulance.Marker.Tourne)
                end
                if distance <= 1.5 then
                    if not MenuAscenseurAmbulance.Toggle then 
                        ESX.ShowHelpNotification("Appuyez sur ~INPUT_CONTEXT~ pour entrer dans l'ascenseur")
                        if IsControlJustPressed(1,51) then
                            OpenAscenseurAmbulance()
                        end
                    end
                else
                    MenuAscenseurAmbulance.Toggle = false
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