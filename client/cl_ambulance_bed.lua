local bedHash = joaat("v_med_bed2")

RegisterNetEvent("ztisco:ambulance:useBed", function()
    ESX.TriggerServerCallback("ztisco:ambulance:canSpawnBed", function(canSpawn)
        if canSpawn then
            ESX.Streaming.RequestModel(bedHash)
            local bed = CreateObject(bedHash, GetEntityCoords(PlayerPedId()), true, false, false)
            PlaceObjectOnGroundProperly(bed)
            exports.ox_target:addLocalEntity(bed, {
                {
                    name = "ztisco_bed_pickup",
                    label = "Ranger le lit",
                    icon = "fa-solid fa-bed",
                    canInteract = function(entity, distance)
                        return distance <= 2.0
                    end,
                    onSelect = function(data)
                        ESX.Game.DeleteObject(data.entity)
                        ESX.ShowNotification("Vous avez replié le lit")
                        TriggerServerEvent("ztisco:ambulance:bedSystem", "bed")
                    end
                },
                {
                    name = "ztisco_bed_push",
                    label = "Pousser le lit",
                    icon = "fa-solid fa-people-carry",
                    canInteract = function(entity, distance)
                        return distance <= 2.0
                    end,
                    onSelect = function(data)
                        PushBed(data.entity)
                    end
                },
                {
                    name = "ztisco_bed_lay",
                    label = "S'allonger",
                    icon = "fa-solid fa-bed-pulse",
                    canInteract = function(entity, distance)
                        return distance <= 2.0
                    end,
                    onSelect = function(data)
                        SitBedanimation(data.entity)
                    end
                },
            })
        else
            ESX.ShowNotification("🚨 ~r~Vous n'avez pas de lit disponible")
        end
    end)
end)

function SitBedanimation(bedObject)
    local ped = PlayerPedId()
    local closestPlayer, dist = ESX.Game.GetClosestPlayer()
    if closestPlayer ~= -1 and dist <= 1.5 then
        local targetPed = GetPlayerPed(closestPlayer)
        if IsEntityPlayingAnim(targetPed, "missfbi5ig_0", "lyinginpain_loop_steve", 3)
        or IsEntityPlayingAnim(targetPed, "ko_front", "anim@gangops@morgue@table@", 3) then
            ESX.ShowNotification("🚨 ~r~Une personne est déjà allongée sur le lit")
            return
        end
    end
    local dict, anim = "anim@gangops@morgue@table@", "ko_front"
    ESX.Streaming.RequestAnimDict(dict)
    AttachEntityToEntity(ped, bedObject, 0, 0, 0.0, 1.3, 0, 0, 180, 0, false, false, false, false, 2, true)
    while IsEntityAttachedToEntity(ped, bedObject) do
        Wait(0)
        if IsPedDeadOrDying(ped) then
            DetachEntity(ped, true, true)
        end
        if not IsEntityPlayingAnim(ped, dict, anim, 1) then
            TaskPlayAnim(ped, dict, anim, 8.0, 8.0, -1, 69, 1, false, false, false)
        end
        if IsControlJustPressed(0, 75) then
            ClearPedTasksImmediately(ped)
            DetachEntity(ped, true, true)
        end
    end
end

function PushBed(bedObject)
    local ped = PlayerPedId()
    local closestPlayer, dist = ESX.Game.GetClosestPlayer()
    if closestPlayer ~= -1 and dist <= 1.5 then
        local targetPed = GetPlayerPed(closestPlayer)
        if IsEntityPlayingAnim(targetPed, "amb@prop_human_bum_shopping_cart@male@idle_a", "idle_a", 3) then
            ESX.ShowNotification("🚨 ~r~Une personne est déjà en train de pousser le lit.")
            return
        end
    end
    NetworkRequestControlOfEntity(bedObject)
    local dict, anim = "amb@prop_human_bum_shopping_cart@male@idle_a", "idle_a"
    ESX.Streaming.RequestAnimDict(dict)
    AttachEntityToEntity(bedObject, ped, GetPedBoneIndex(ped, 28422), 0.0, 1.3, -1.0, 0.0, 0.0, 180.0, false, false, true, false, 2, true)
    while IsEntityAttachedToEntity(bedObject, ped) do
        Wait(0)
        if not IsEntityPlayingAnim(ped, dict, anim, 3) then
            TaskPlayAnim(ped, dict, anim, 2.0, 2.0, -1, 50, 0, false, false, false)
        end
        if IsControlJustPressed(0, 75) or IsControlJustPressed(0, 73) or IsPedDeadOrDying(ped) then
            ClearPedTasksImmediately(ped)
            DetachEntity(bedObject, true, true)
        end
        DisableControlAction(0, 21, true)
        DisableControlAction(0, 22, true)
    end
end

RegisterCommand("testbed", function()
    TriggerEvent("ztisco:ambulance:useBed")
end)


print("Script by S0ltrak for ^2DevHub's^7")
print("^2Discord : https://discord.gg/3eSufdKtdH^7")