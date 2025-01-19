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
MenuAcceuilAmbulance = {}
MenuAcceuilAmbulance.Toggle = false
function MenuAcceuilAmbulanceCreate()
    MenuAcceuilAmbulance.Toggle = true
    MainAcceuilAmbulance = RageUI.CreateMenu("Ambulance", "ACCUEIL", nil, nil, nil, nil)
    SubAcceuilAmbulance = RageUI.CreateSubMenu(MainAcceuilAmbulance, "Ambulance", "RENDEZ-VOUS")
    MainAcceuilAmbulance.Closed = function()
        MenuAcceuilAmbulance.Toggle = false
        nomprenomAmbulance = nil
        numeroAmbulance = nil
        heurerdvAmbulance = nil
        rdvmotifAmbulance = nil
    end
end

function OpenAcceuilAmbulance()
    MenuAcceuilAmbulanceCreate() 
    RageUI.Visible(MainAcceuilAmbulance, true) 
    CreateThread(function()
        while true do 
            Wait(2.0)
            if MenuAcceuilAmbulance.Toggle then 

                RageUI.IsVisible(MainAcceuilAmbulance, function()

                    RageUI.Button("Appeler un EMS a l'accueil", nil, {RightLabel = ConfigTiscoGlobal.RightLabel}, not acceuilCooldown1, {
                        onSelected = function()
                            acceuilCooldown1 = true 
                            TriggerServerEvent('ztisco:ambulance:call')
                            ESX.ShowNotification('Votre message a bien été ~b~envoyé ~s~aux EMS')
                            Citizen.SetTimeout(5000, function() acceuilCooldown1 = false end)
                        end 
                    })

                    RageUI.Button("Prendre un rendez-vous", nil, {RightLabel = ConfigTiscoGlobal.RightLabel}, true, {}, SubAcceuilAmbulance) 

                end)

                RageUI.IsVisible(SubAcceuilAmbulance, function()

                    RageUI.Button("Nom & Prénom", nil, {RightLabel = nomprenomAmbulance}, true , {
                        onSelected = function()
                            DisplayOnscreenKeyboard(1, "FMMC_MPM_NA", "Prénom & Nom", "Prénom & Nom", "", "", "", 20)
                            while (UpdateOnscreenKeyboard() == 0) do
                                DisableAllControlActions(0);
                                Wait(1)
                            end
                            if (GetOnscreenKeyboardResult()) then
                                nomprenomAmbulance = GetOnscreenKeyboardResult() 
                            end
                        end
                    })
        
                    RageUI.Button("Numéro de téléphone", nil, {RightLabel = numeroAmbulance}, true , {
                        onSelected = function()
                            DisplayOnscreenKeyboard(1, "FMMC_MPM_NA", "555-", "555-", "", "", "", 10)
                            while (UpdateOnscreenKeyboard() == 0) do
                                DisableAllControlActions(0);
                                Wait(1)
                            end
                            if (GetOnscreenKeyboardResult()) then
                                numeroAmbulance = GetOnscreenKeyboardResult()  
                            end
                        end
                    })
        
                    RageUI.Button("Heure du rendez-vous", nil, {RightLabel = heurerdvAmbulance}, true , {
                        onSelected = function()
                            DisplayOnscreenKeyboard(1, "FMMC_MPM_NA", "15h40", "15h40", "", "", "", 10)
                            while (UpdateOnscreenKeyboard() == 0) do
                                DisableAllControlActions(0);
                                Wait(1)
                            end
                            if (GetOnscreenKeyboardResult()) then
                                heurerdvAmbulance = GetOnscreenKeyboardResult()  
                            end
                        end
                    })
                    
                    RageUI.Button("Motif du rendez-vous", nil, {RightLabel = ConfigTiscoGlobal.RightLabel}, true , {
                        onSelected = function()
                            DisplayOnscreenKeyboard(1, "FMMC_MPM_NA", "Motif", "Motif", "", "", "", 120)
                            while (UpdateOnscreenKeyboard() == 0) do
                                DisableAllControlActions(0);
                                Wait(1)
                            end
                            if (GetOnscreenKeyboardResult()) then
                                rdvmotifAmbulance = GetOnscreenKeyboardResult()  
                            end
                        end
                    })
        
                    RageUI.Button("Valider la demande", nil, {RightBadge = RageUI.BadgeStyle.Tick, Color = {BackgroundColor = { 76, 175, 80, 100}}}, true, {
                        onSelected = function()
                            if (nomprenomAmbulance == nil or nomprenomAmbulance == '') then
                                ESX.ShowNotification("~r~Vous n'avez pas rempli votre nom/prénom")
                            elseif (numeroAmbulance == nil or numeroAmbulance == '') then
                                ESX.ShowNotification("~r~Vous n'avez pas rempli votre numéro")
                            elseif (heurerdvAmbulance == nil or heurerdvAmbulance == '') then
                                ESX.ShowNotification("~r~Vous n'avez pas rempli l'heure du rendez-vous")
                            elseif (rdvmotifAmbulance == nil or rdvmotifAmbulance == '' or rdvmotifAmbulance == "Motif") then
                                ESX.ShowNotification("~r~Vous n'avez pas rempli le motif du rendez-vous")
                            else
                                TriggerServerEvent("ztisco:ambulance:rdv", nomprenomAmbulance, numeroAmbulance, heurerdvAmbulance, rdvmotifAmbulance)
                                ESX.ShowNotification("Votre demande de rendez-vous a été ~b~envoyé")
                                nomprenomAmbulance = nil
                                numeroAmbulance = nil
                                heurerdvAmbulance = nil
                                rdvmotifAmbulance = nil
                            end
                        end
                    }) 

                end)

            else
                RageUI.Visible(MainAcceuilAmbulance, false) 
                RageUI.Visible(SubAcceuilAmbulance, false)
                if not RageUI.Visible(MainAcceuilAmbulance) and not RageUI.Visible(SubAcceuilAmbulance, false) then
                    MainAcceuilAmbulance = RMenu:DeleteType('MainAcceuilAmbulance', true) 
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
        for i = 1, #ConfigTiscoJobs.ambulance.Acceuil.pos do
            local distance = #(pedCoords - ConfigTiscoJobs.ambulance.Acceuil.pos[i])
            if distance < ConfigTiscoJobs.ambulance.Marker.Distance then intervale = false 
                if not MenuAcceuilAmbulance.Toggle then
                    DrawMarker(ConfigTiscoJobs.ambulance.Marker.Type, (ConfigTiscoJobs.ambulance.Acceuil.pos[i]), 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, ConfigTiscoJobs.ambulance.Marker.SizeLargeur, ConfigTiscoJobs.ambulance.Marker.SizeEpaisseur, ConfigTiscoJobs.ambulance.Marker.SizeHauteur, ConfigTiscoJobs.ambulance.Marker.ColorR, ConfigTiscoJobs.ambulance.Marker.ColorG, ConfigTiscoJobs.ambulance.Marker.ColorB, ConfigTiscoJobs.ambulance.Marker.Opacite, ConfigTiscoJobs.ambulance.Marker.Saute, false, false, ConfigTiscoJobs.ambulance.Marker.Tourne)
                end
                if distance <= 1.5 then
                    if not MenuAcceuilAmbulance.Toggle then 
                        ESX.ShowHelpNotification("Appuyer sur ~INPUT_CONTEXT~ pour prendre rendez-vous") 
                        if IsControlJustPressed(1,51) then 
                            OpenAcceuilAmbulance() 
                        end
                    end
                else
                    MenuAcceuilAmbulance.Toggle = false 
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