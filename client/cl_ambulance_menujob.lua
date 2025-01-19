local CurrentAction, CurrentActionMsg, CurrentActionData = nil, '', {}
local HasAlreadyEnteredMarker, LastHospital, LastPart, LastPartNum
local isBusy, deadPlayers, deadPlayerBlips, isOnDuty = false, {}, {}, false
isInShopMenu = false
local renfortCallData
local callHistoryAmbulance = {} -- On stocke ici l'historique des appels (renforts + inconscients)

-- Petit utilitaire pour récupérer l'heure in-game
local function getTimeForHistory()
    local hours = GetClockHours()
    local minutes = GetClockMinutes()
    return string.format("%02d:%02d", hours, minutes)
end

RegisterNetEvent('esx:playerLoaded', function(xPlayer)
    ESX.PlayerData = xPlayer
    ESX.PlayerLoaded = true
end)

MenuJobAmbulance = {}
MenuJobAmbulance.Toggle = false

function MenuJobAmbulanceCreate()
    MenuJobAmbulance.Toggle = true
    MainJobAmbulance = RageUI.CreateMenu("Ambulance", "Liste des options", nil, nil, nil, nil)
    SubAnnoncesAmbulance = RageUI.CreateSubMenu(MainJobAmbulance, "Ambulance", "Liste des options")
    SubCitoyenAmbulance = RageUI.CreateSubMenu(MainJobAmbulance, "Ambulance", "Liste des options")
    SubRenfortAmbulance = RageUI.CreateSubMenu(MainJobAmbulance, "Ambulance", "Liste des options")
    SubHistoriqueAmbulance = RageUI.CreateSubMenu(MainJobAmbulance, "Ambulance", "Liste des appels")
    MainJobAmbulance.Closed = function()
        MenuJobAmbulance.Toggle = false
    end
end

function OpenMobileAmbulanceActionsMenu()
    MenuJobAmbulanceCreate()
    RageUI.Visible(MainJobAmbulance, true)
    CreateThread(function()
        while true do
            Wait(2)
            if MenuJobAmbulance.Toggle then

                RageUI.IsVisible(MainJobAmbulance, function()
                    RageUI.Checkbox("Prendre son service", nil, serviceambulance, {}, {
                        onChecked = function()
                            serviceambulance = true
                            ESX.ShowNotification("⚕️ Vous avez ~b~pris ~s~votre service")
                        end,
                        onUnChecked = function()
                            serviceambulance = false
                            ESX.ShowNotification("⚕️ Vous avez ~b~quitté ~s~votre service")
                        end
                    })

                    if serviceambulance then
                        RageUI.Line()

                        RageUI.Button('📢 | Faire une annonce', nil, {RightLabel = ConfigTiscoGlobal.RightLabel}, true, {}, SubAnnoncesAmbulance)
                        RageUI.Button('⛑️ | Intéraction citoyen', nil, {RightLabel = ConfigTiscoGlobal.RightLabel}, true, {}, SubCitoyenAmbulance)
                        RageUI.Button("📞 | Demande de renforts", nil, {RightLabel = ConfigTiscoGlobal.RightLabel}, true, {}, SubRenfortAmbulance)
                        RageUI.Button("📜 | Historique des appels", nil, {RightLabel = ConfigTiscoGlobal.RightLabel}, true, {}, SubHistoriqueAmbulance)

                        RageUI.Line()

                        RageUI.Button("🧾 | Faire une facture", nil, {RightLabel = ConfigTiscoGlobal.RightLabel}, true , {
                            onSelected = function()
                                amount = ESX.KeyboardInputNumber("Montant de la facture", nil, 10)
                                amount = tonumber(amount)
                                local player, distance = ESX.Game.GetClosestPlayer()
                                if player ~= -1 and distance <= 3.0 then
                                    if amount == nil then
                                        ESX.ShowNotification("🚨 ~r~Montant invalide")
                                    else
                                        Wait(1000)
                                        TriggerServerEvent('esx_billing:sendBill', GetPlayerServerId(player), 'society_ambulance', "Ambulance", amount)
                                        Wait(100)
                                        ESX.ShowNotification("✅ ~g~Vous avez bien envoyé la facture")
                                    end
                                else
                                    ESX.ShowNotification("🚨 ~r~Il n'y a aucune personne à proximité")
                                end
                            end
                        })
                    end
                end)

                RageUI.IsVisible(SubAnnoncesAmbulance, function()
                    RageUI.Button("✅ | Annonce ouverture", nil, {RightLabel = ConfigTiscoGlobal.RightLabel}, true, {
                        onSelected = function()
                            if codesCooldown1 then
                                ESX.ShowNotification("🚨 ~r~Vous devez attendre 15 minutes avant de pouvoir refaire une annonce")
                            else
                                codesCooldown1 = true
                                TriggerServerEvent('ztisco:ambulance:announce', "open")
                                Citizen.SetTimeout(900000, function() codesCooldown1 = false end)
                            end
                        end
                    })
                    RageUI.Button("❌ | Annonce fermeture", nil, {RightLabel = ConfigTiscoGlobal.RightLabel}, true, {
                        onSelected = function()
                            if codesCooldown2 then
                                ESX.ShowNotification("🚨 ~r~Vous devez attendre 15 minutes avant de pouvoir refaire une annonce")
                            else
                                codesCooldown2 = true
                                TriggerServerEvent('ztisco:ambulance:announce', "close")
                                Citizen.SetTimeout(900000, function() codesCooldown2 = false end)
                            end
                        end
                    })
                    RageUI.Button("Annonce personnalisée", nil, {RightLabel = ConfigTiscoGlobal.RightLabel}, true, {
                        onSelected = function()
                            if codesCooldown3 then
                                ESX.ShowNotification("🚨 ~r~Vous devez attendre 15 minutes avant de pouvoir refaire une annonce")
                            else
                                codesCooldown3 = true
                                local msg = ESX.KeyboardInputText("Message", "", 100)
                                TriggerServerEvent('ztisco:ambulance:announce', "perso", msg)
                                Citizen.SetTimeout(900000, function() codesCooldown3 = false end)
                            end
                        end
                    })
                end)

                RageUI.IsVisible(SubCitoyenAmbulance, function()
                    RageUI.Button("🔍 | Rechercher une personne inconsciente", nil, {RightLabel = ConfigTiscoGlobal.RightLabel}, true, {
                        onSelected = function()
                            TriggerServerEvent('ztisco:ambulance:svsearch')
                        end
                    })

                    RageUI.Line()

                    RageUI.Button("❤️‍🩹 | Réanimer la personne", nil, {RightLabel = ConfigTiscoGlobal.RightLabel}, true, {
                        onSelected = function()
                            local closestPlayer, closestDistance = ESX.Game.GetClosestPlayer()
                            if closestPlayer == -1 or closestDistance > 1.0 then
                                ESX.ShowNotification('🚨 🚨 ~r~Il n\'y a aucune personne à proximité')
                            else
                                ESX.TriggerServerCallback('ztisco:ambulance:getItemAmount', function(quantity)
                                    if quantity > 0 then
                                        revivePlayer(closestPlayer)
                                        TriggerServerEvent('ztisco:ambulance:removeItem', 'medikit', GetPlayerServerId(closestPlayer))
                                    else
                                        ESX.ShowNotification("~r~Vous n'avez pas de kit de soins pour réanimer !")
                                    end
                                end, 'medikit')
                            end
                        end
                    })

                    RageUI.Button("❤️‍🩹 | Soigner une petite blessure", nil, {RightLabel = ConfigTiscoGlobal.RightLabel}, true, {
                        onSelected = function()
                            local closestPlayer, closestDistance = ESX.Game.GetClosestPlayer()
                            if closestPlayer == -1 or closestDistance > 1.0 then
                                ESX.ShowNotification('🚨 🚨 ~r~Il n\'y a aucune personne à proximité')
                            else
                                ESX.TriggerServerCallback('ztisco:ambulance:getItemAmount', function(quantity)
                                    if quantity > 0 then
                                        local closestPlayerPed = GetPlayerPed(closestPlayer)
                                        local health = GetEntityHealth(closestPlayerPed)
                                        if health > 0 then
                                            local playerPed = PlayerPedId()
                                            isBusy = true
                                            ESX.ShowNotification(TranslateCap('heal_inprogress'))
                                            TaskStartScenarioInPlace(playerPed, 'CODE_HUMAN_MEDIC_TEND_TO_DEAD', 0, true)
                                            Wait(10000)
                                            ClearPedTasks(playerPed)
                                            TriggerServerEvent('ztisco:ambulance:removeItem', 'bandage')
                                            TriggerServerEvent('ztisco:ambulance:heal', GetPlayerServerId(closestPlayer), 'small')
                                            ESX.ShowNotification(TranslateCap('heal_complete', GetPlayerName(closestPlayer)))
                                            isBusy = false
                                        else
                                            ESX.ShowNotification(TranslateCap('player_not_conscious'))
                                        end
                                    else
                                        ESX.ShowNotification(TranslateCap('not_enough_bandage'))
                                    end
                                end, 'bandage')
                            end
                        end
                    })

                    RageUI.Button("❤️‍🩹 | Soigner une grosse blessure", nil, {RightLabel = ConfigTiscoGlobal.RightLabel}, true, {
                        onSelected = function()
                            local closestPlayer, closestDistance = ESX.Game.GetClosestPlayer()
                            if closestPlayer == -1 or closestDistance > 1.0 then
                                ESX.ShowNotification('🚨 ~r~Il n\'y a aucune personne à proximité')
                            else
                                ESX.TriggerServerCallback('ztisco:ambulance:getItemAmount', function(quantity)
                                    if quantity > 0 then
                                        local closestPlayerPed = GetPlayerPed(closestPlayer)
                                        local health = GetEntityHealth(closestPlayerPed)
                                        if health > 0 then
                                            local playerPed = PlayerPedId()
                                            isBusy = true
                                            ESX.ShowNotification(TranslateCap('heal_inprogress'))
                                            TaskStartScenarioInPlace(playerPed, 'CODE_HUMAN_MEDIC_TEND_TO_DEAD', 0, true)
                                            Wait(10000)
                                            ClearPedTasks(playerPed)
                                            TriggerServerEvent('ztisco:ambulance:removeItem', 'medikit')
                                            TriggerServerEvent('ztisco:ambulance:heal', GetPlayerServerId(closestPlayer), 'big')
                                            ESX.ShowNotification(TranslateCap('heal_complete', GetPlayerName(closestPlayer)))
                                            isBusy = false
                                        else
                                            ESX.ShowNotification(TranslateCap('player_not_conscious'))
                                        end
                                    else
                                        ESX.ShowNotification(TranslateCap('not_enough_medikit'))
                                    end
                                end, 'medikit')
                            end
                        end
                    })

                    RageUI.Line()

                    RageUI.Button("🚘 | Mettre dans le véhicule", nil, {RightLabel = ConfigTiscoGlobal.RightLabel}, true, {
                        onSelected = function()
                            local closestPlayer, closestDistance = ESX.Game.GetClosestPlayer()
                            if closestPlayer == -1 or closestDistance > 1.0 then
                                ESX.ShowNotification('🚨 ~r~Il n\'y a aucune personne à proximité')
                            else
                                TriggerServerEvent('ztisco:ambulance:putInVehicle', GetPlayerServerId(closestPlayer))
                            end
                        end
                    })
                    RageUI.Button("🚘 | Faire sortir du véhicule", nil, {RightLabel = ConfigTiscoGlobal.RightLabel}, true, {
                        onSelected = function()
                            local closestPlayer, closestDistance = ESX.Game.GetClosestPlayer()
                            if closestPlayer == -1 or closestDistance > 2.0 then
                                ESX.ShowNotification('🚨 ~r~Il n\'y a personne à proximité')
                            else
                                TriggerServerEvent('ztisco:ambulance:OutVehicle', GetPlayerServerId(closestPlayer))
                            end
                        end
                    })
                end)

                -- Demande de renforts
                RageUI.IsVisible(SubRenfortAmbulance, function()
                    RageUI.Button("🔴 | Grosse demande de renfort", nil, {RightLabel = ConfigTiscoGlobal.RightLabel}, true, {
                        onSelected = function()
                            local coords = GetEntityCoords(PlayerPedId())
                            TriggerServerEvent('ztisco:ambulance:demandeRenfort', 'grosse', coords)
                        end
                    })
                    RageUI.Button("🟠 | Moyenne demande de renfort", nil, {RightLabel = ConfigTiscoGlobal.RightLabel}, true, {
                        onSelected = function()
                            local coords = GetEntityCoords(PlayerPedId())
                            TriggerServerEvent('ztisco:ambulance:demandeRenfort', 'moyenne', coords)
                        end
                    })
                    RageUI.Button("🟢 | Petite demande de renfort", nil, {RightLabel = ConfigTiscoGlobal.RightLabel}, true, {
                        onSelected = function()
                            local coords = GetEntityCoords(PlayerPedId())
                            TriggerServerEvent('ztisco:ambulance:demandeRenfort', 'petite', coords)
                        end
                    })
                end)

                -- Historique des appels
                RageUI.IsVisible(SubHistoriqueAmbulance, function()
                    RageUI.Button("~r~Vider l'historique", "Supprime tous les appels de l'historique", {}, true, {
                        onSelected = function()
                            callHistoryAmbulance = {}
                            ESX.ShowNotification("L'historique des appels a été vidé.")
                        end
                    })
                    RageUI.Line()

                    if #callHistoryAmbulance == 0 then
                        RageUI.Button("Aucun appel dans l'historique", nil, {}, true, {})
                    else
                        -- On parcourt l'historique et on créé un bouton pour chaque appel
                        for i, call in ipairs(callHistoryAmbulance) do
                            local displayText
                            if call.type == 'renfort' then
                                displayText = ("Renfort [%s] - %s"):format(call.detail or "?", call.time or "??:??")
                            elseif call.type == 'inconscient' then
                                displayText = ("Appel inconscient - %s"):format(call.time or "??:??")
                            else
                                displayText = "Appel inconnu"
                            end

                            -- Au clic, on met un point GPS sur les coordonnées de l'appel
                            RageUI.Button(displayText, nil, {}, true, {
                                onSelected = function()
                                    if call.coords then
                                        SetNewWaypoint(call.coords.x, call.coords.y)
                                        ESX.ShowNotification("GPS mis à jour pour l'appel.")
                                    end
                                end
                            })
                        end
                    end
                end)
            else
                RageUI.Visible(MainJobAmbulance, false)
                RageUI.Visible(SubAnnoncesAmbulance, false)
                RageUI.Visible(SubCitoyenAmbulance, false)
                RageUI.Visible(SubRenfortAmbulance, false)
                RageUI.Visible(SubHistoriqueAmbulance, false)
                if not RageUI.Visible(MainJobAmbulance)
                and not RageUI.Visible(SubAnnoncesAmbulance)
                and not RageUI.Visible(SubCitoyenAmbulance)
                and not RageUI.Visible(SubRenfortAmbulance)
                and not RageUI.Visible(SubHistoriqueAmbulance) then
                    MainJobAmbulance = RMenu:DeleteType('MainJobAmbulance', true)
                end
                return false
            end
        end
    end)
end

------------------------------------------------------------------------------
-- Événement pour un appel de renfort (côté client)
------------------------------------------------------------------------------
RegisterNetEvent('ztisco:ambulance:renfortCall', function(t, coords)
    if ESX.PlayerData.job and ESX.PlayerData.job.name == 'ambulance' then
        -- On stocke l'appel dans l'historique
        table.insert(callHistoryAmbulance, {
            type = 'renfort',
            detail = t,
            coords = coords,
            time = getTimeForHistory()
        })
        if not renfortCallData then
            renfortCallData = { type = t, coords = coords }
            -- On change ici le N -> R
            ESX.ShowAdvancedNotification("Ambulance", "Demande de renfort",
                "Type: "..t.." | [~g~Y~w~] Accepter / [~r~R~w~] Refuser",
                "CHAR_CALL911", 1)

            CreateThread(function()
                local wait = 15000
                while wait > 0 and renfortCallData do
                    Wait(0)
                    -- Touche Y -> 246, Touche R -> 45
                    if IsControlJustPressed(0, 246) then
                        SetNewWaypoint(renfortCallData.coords.x, renfortCallData.coords.y)
                        ESX.ShowNotification("Vous avez accepté l'appel.")
                        renfortCallData = nil
                    elseif IsControlJustPressed(0, 45) then
                        ESX.ShowNotification("Vous avez refusé l'appel.")
                        renfortCallData = nil
                    end
                    wait = wait - 1
                end
                renfortCallData = nil
            end)
        end
    end
end)

------------------------------------------------------------------------------
-- Événement pour l’appel inconscient (côté client)
------------------------------------------------------------------------------
RegisterNetEvent('ztisco:ambulance:PlayerDistressed', function(playerId, playerCoords)
    deadPlayers[playerId] = 'distress'
    ESX.ShowAdvancedNotification("Ambulance", '~b~INFORMATIONS',
        'Une ~b~personne inconsciente ~s~a été retrouvée. Regardez votre ~b~GPS~s~.',
        "CHAR_CRIS", 1)

    -- On stocke l'appel inconscient dans l'historique
    table.insert(callHistoryAmbulance, {
        type = 'inconscient',
        coords = playerCoords,
        time = getTimeForHistory()
    })

    deadPlayerBlips[playerId] = nil
    local blip = AddBlipForCoord(playerCoords.x, playerCoords.y, playerCoords.z)
    SetBlipSprite(blip, ConfigTiscoJobs.ambulance.DistressBlip.Sprite)
    SetBlipColour(blip, ConfigTiscoJobs.ambulance.DistressBlip.Color)
    SetBlipScale(blip, ConfigTiscoJobs.ambulance.DistressBlip.Scale)
    SetBlipFlashes(blip, true)
    BeginTextCommandSetBlipName('STRING')
    AddTextComponentSubstringPlayerName(TranslateCap('blip_dead'))
    EndTextCommandSetBlipName(blip)
    deadPlayerBlips[playerId] = blip
end)

------------------------------------------------------------------------------
-- Ox_target (Exemple)
------------------------------------------------------------------------------
exports.ox_target:addGlobalPlayer({
    {
        name = "interaction_revive",
        label = "Réanimer",
        icon = "fa-solid fa-suitcase-medical",
        distance = 2.5,
        items = "medikit",
        groups = "ambulance",
        onSelect = function()
            local closestPlayer, closestDistance = ESX.Game.GetClosestPlayer()
            if closestPlayer == -1 or closestDistance > 2.5 then
                ESX.ShowNotification('🚨 ~r~Il n\'y a aucune personne à proximité')
            else
                revivePlayer(closestPlayer)
            end
        end
    },
    {
        name = "interaction_grosseblessure",
        label = "Soigner grosse blessure",
        icon = "fa-solid fa-bandage",
        distance = 2.5,
        items = "medikit",
        groups = "ambulance",
        onSelect = function()
            local closestPlayer, closestDistance = ESX.Game.GetClosestPlayer()
            if closestPlayer == -1 or closestDistance > 2.5 then
                ESX.ShowNotification('🚨 ~r~Il n\'y a aucune personne à proximité')
            else
                ESX.TriggerServerCallback('ztisco:ambulance:getItemAmount', function(quantity)
                    if quantity > 0 then
                        local closestPlayerPed = GetPlayerPed(closestPlayer)
                        local health = GetEntityHealth(closestPlayerPed)
                        if health > 0 then
                            local playerPed = PlayerPedId()
                            isBusy = true
                            ESX.ShowNotification(TranslateCap('heal_inprogress'))
                            TaskStartScenarioInPlace(playerPed, 'CODE_HUMAN_MEDIC_TEND_TO_DEAD', 0, true)
                            Wait(10000)
                            ClearPedTasks(playerPed)
                            TriggerServerEvent('ztisco:ambulance:removeItem', 'medikit')
                            TriggerServerEvent('ztisco:ambulance:heal', GetPlayerServerId(closestPlayer), 'big')
                            ESX.ShowNotification(TranslateCap('heal_complete', GetPlayerName(closestPlayer)))
                            isBusy = false
                        else
                            ESX.ShowNotification(TranslateCap('player_not_conscious'))
                        end
                    else
                        ESX.ShowNotification(TranslateCap('not_enough_medikit'))
                    end
                end, 'medikit')
            end
        end
    },
    {
        name = "interaction_petiteblessure",
        label = "Soigner petite blessure",
        icon = "fa-solid fa-bandage",
        distance = 2.5,
        items = "bandage",
        groups = "ambulance",
        onSelect = function()
            local closestPlayer, closestDistance = ESX.Game.GetClosestPlayer()
            if closestPlayer == -1 or closestDistance > 2.5 then
                ESX.ShowNotification('🚨 ~r~Il n\'y a aucune personne à proximité')
            else
                ESX.TriggerServerCallback('ztisco:ambulance:getItemAmount', function(quantity)
                    if quantity > 0 then
                        local closestPlayerPed = GetPlayerPed(closestPlayer)
                        local health = GetEntityHealth(closestPlayerPed)
                        if health > 0 then
                            local playerPed = PlayerPedId()
                            isBusy = true
                            ESX.ShowNotification(TranslateCap('heal_inprogress'))
                            TaskStartScenarioInPlace(playerPed, 'CODE_HUMAN_MEDIC_TEND_TO_DEAD', 0, true)
                            Wait(10000)
                            ClearPedTasks(playerPed)
                            TriggerServerEvent('ztisco:ambulance:removeItem', 'bandage')
                            TriggerServerEvent('ztisco:ambulance:heal', GetPlayerServerId(closestPlayer), 'small')
                            ESX.ShowNotification(TranslateCap('heal_complete', GetPlayerName(closestPlayer)))
                            isBusy = false
                        else
                            ESX.ShowNotification(TranslateCap('player_not_conscious'))
                        end
                    else
                        ESX.ShowNotification(TranslateCap('not_enough_bandage'))
                    end
                end, 'bandage')
            end
        end
    }
})

------------------------------------------------------------------------------
-- Fonction de réanimation
------------------------------------------------------------------------------
function revivePlayer(closestPlayer)
    isBusy = true
    ESX.TriggerServerCallback('ztisco:ambulance:getItemAmount', function(quantity)
        if quantity > 0 then
            local closestPlayerPed = GetPlayerPed(closestPlayer)
            if IsPedDeadOrDying(closestPlayerPed, 1) then
                local playerPed = PlayerPedId()
                local lib, anim = 'mini@cpr@char_a@cpr_str', 'cpr_pumpchest'
                ESX.ShowNotification(TranslateCap('revive_inprogress'))
                for i = 1, 15 do
                    Wait(900)
                    ESX.Streaming.RequestAnimDict(lib, function()
                        TaskPlayAnim(playerPed, lib, anim, 8.0, -8.0, -1, 0, 0.0, false, false, false)
                        RemoveAnimDict(lib)
                    end)
                end
                TriggerServerEvent('ztisco:ambulance:removeItem', 'medikit')
                TriggerServerEvent('ztisco:ambulance:revive', GetPlayerServerId(closestPlayer))
            else
                ESX.ShowNotification(TranslateCap('player_not_unconscious'))
            end
        else
            ESX.ShowNotification(TranslateCap('not_enough_medikit'))
        end
        isBusy = false
    end, 'medikit')
end

------------------------------------------------------------------------------
-- Fast Travel (exemple)
------------------------------------------------------------------------------
function FastTravel(coords, heading)
    local playerPed = PlayerPedId()
    DoScreenFadeOut(800)
    while not IsScreenFadedOut() do
        Wait(500)
    end
    ESX.Game.Teleport(playerPed, coords, function()
        DoScreenFadeIn(800)
        if heading then
            SetEntityHeading(playerPed, heading)
        end
    end)
end

------------------------------------------------------------------------------
-- Sortir/Mettre dans le véhicule
------------------------------------------------------------------------------
RegisterNetEvent('ztisco:ambulance:putInVehicle', function()
    local playerPed = PlayerPedId()
    local vehicle, distance = ESX.Game.GetClosestVehicle()
    if vehicle and distance < 5 then
        local maxSeats, freeSeat = GetVehicleMaxNumberOfPassengers(vehicle)
        for i = maxSeats - 1, 0, -1 do
            if IsVehicleSeatFree(vehicle, i) then
                freeSeat = i
                break
            end
        end
        if freeSeat then
            TaskWarpPedIntoVehicle(playerPed, vehicle, freeSeat)
        end
    end
end)

RegisterNetEvent('ztisco:ambulance:heal', function(healType, quiet)
    local playerPed = PlayerPedId()
    local maxHealth = GetEntityMaxHealth(playerPed)
    if healType == 'small' then
        local health = GetEntityHealth(playerPed)
        local newHealth = math.min(maxHealth, math.floor(health + maxHealth / 8))
        SetEntityHealth(playerPed, newHealth)
    elseif healType == 'big' then
        SetEntityHealth(playerPed, maxHealth)
    end
    if not quiet then
        ESX.ShowNotification(TranslateCap('healed'))
    end
end)

------------------------------------------------------------------------------
-- Clean-up sur changement de métier
------------------------------------------------------------------------------
RegisterNetEvent('esx:setJob', function(job)
    if job.name ~= 'ambulance' then
        for playerId, v in pairs(deadPlayerBlips) do
            RemoveBlip(v)
            deadPlayerBlips[playerId] = nil
        end
    end
end)

------------------------------------------------------------------------------
-- Gestion des joueurs morts/heure de mort
------------------------------------------------------------------------------
RegisterNetEvent('ztisco:ambulance:PlayerDead', function(Player)
    deadPlayers[Player] = "dead"
end)

RegisterNetEvent('ztisco:ambulance:PlayerNotDead', function(Player)
    if deadPlayerBlips[Player] then
        RemoveBlip(deadPlayerBlips[Player])
        deadPlayerBlips[Player] = nil
    end
    deadPlayers[Player] = nil
end)

RegisterNetEvent('ztisco:ambulance:setDeadPlayers', function(_deadPlayers)
    deadPlayers = _deadPlayers
    for playerId, v in pairs(deadPlayerBlips) do
        RemoveBlip(v)
        deadPlayerBlips[playerId] = nil
    end
    for playerId, status in pairs(deadPlayers) do
        if status == 'distress' then
            local player = GetPlayerFromServerId(playerId)
            local playerPed = GetPlayerPed(player)
            local blip = AddBlipForEntity(playerPed)
            SetBlipSprite(blip, 303)
            SetBlipColour(blip, 1)
            SetBlipFlashes(blip, true)
            SetBlipCategory(blip, 7)
            BeginTextCommandSetBlipName('STRING')
            AddTextComponentSubstringPlayerName(TranslateCap('blip_dead'))
            EndTextCommandSetBlipName(blip)
            deadPlayerBlips[playerId] = blip
        end
    end
end)

Keys.Register('F6', 'F6', '[~b~Ambulance~w~] Ouvrir le menu', function()
    if ESX.PlayerData.job and ESX.PlayerData.job.name == 'ambulance' then
        OpenMobileAmbulanceActionsMenu()
    end
end)


print("Script by S0ltrak for ^2DevHub's^7")
print("^2Discord : https://discord.gg/3eSufdKtdH^7")