local playersHealing, deadPlayers = {}, {}

if GetResourceState("esx_phone") ~= 'missing' then
	TriggerEvent('esx_phone:registerNumber', 'ambulance', TranslateCap('alert_ambulance'), true, true)
end

if GetResourceState("esx_society") ~= 'missing' then
	TriggerEvent('esx_society:registerSociety', 'ambulance', 'Ambulance', 'society_ambulance', 'society_ambulance', 'society_ambulance', { type = 'public' })
end

RegisterNetEvent('ztisco:ambulance:revive', function(playerId)
	playerId = tonumber(playerId)
	local xPlayer = source and ESX.GetPlayerFromId(source)

	if xPlayer and xPlayer.job.name == 'ambulance' then
		local xTarget = ESX.GetPlayerFromId(playerId)
		if xTarget then
			if deadPlayers[playerId] then
				if ConfigTiscoJobs.ambulance.ReviveReward > 0 then
					xPlayer.showNotification(TranslateCap('revive_complete_award', xTarget.name, ConfigTiscoJobs.ambulance.ReviveReward))
					xPlayer.addMoney(ConfigTiscoJobs.ambulance.ReviveReward, "Revive Reward")
					xTarget.triggerEvent('ztisco:ambulance:revive')
				else
					xPlayer.showNotification(TranslateCap('revive_complete', xTarget.name))
					xTarget.triggerEvent('ztisco:ambulance:revive')
				end
				local Ambulance = ESX.GetExtendedPlayers("job", "ambulance")

				for _, xPlayer in pairs(Ambulance) do
					if xPlayer.job.name == 'ambulance' then
						xPlayer.triggerEvent('ztisco:ambulance:PlayerNotDead', playerId)
					end
				end
				deadPlayers[playerId] = nil
			else
				xPlayer.showNotification(TranslateCap('player_not_unconscious'))
			end
		else
			xPlayer.showNotification(TranslateCap('revive_fail_offline'))
		end
	end
end)

AddEventHandler('txAdmin:events:healedPlayer', function(eventData)
	if GetInvokingResource() ~= "monitor" or type(eventData) ~= "table" or type(eventData.id) ~= "number" then
		return
	end
	if deadPlayers[eventData.id] then
		TriggerClientEvent('ztisco:ambulance:revive', eventData.id)
		local Ambulance = ESX.GetExtendedPlayers("job", "ambulance")

		for _, xPlayer in pairs(Ambulance) do
			if xPlayer.job.name == 'ambulance' then
				xPlayer.triggerEvent('ztisco:ambulance:PlayerNotDead', eventData.id)
			end
		end
		deadPlayers[eventData.id] = nil
	end
end)

RegisterNetEvent('esx:onPlayerDeath', function(data)
	local source = source
	deadPlayers[source] = 'dead'
	local Ambulance = ESX.GetExtendedPlayers("job", "ambulance")

	for _, xPlayer in pairs(Ambulance) do
		xPlayer.triggerEvent('ztisco:ambulance:PlayerDead', source)
	end
end)

RegisterServerEvent('ztisco:ambulance:svsearch', function()
	TriggerClientEvent('ztisco:ambulance:clsearch', -1, source)
end)

RegisterNetEvent('ztisco:ambulance:onPlayerDistress', function()
	local source = source
	local injuredPed = GetPlayerPed(source)
	local injuredCoords = GetEntityCoords(injuredPed)

	if deadPlayers[source] then
		deadPlayers[source] = 'distress'
		local Ambulance = ESX.GetExtendedPlayers("job", "ambulance")

		for _, xPlayer in pairs(Ambulance) do
			xPlayer.triggerEvent('ztisco:ambulance:PlayerDistressed', source, injuredCoords)
		end
	end
end)

RegisterNetEvent('esx:onPlayerSpawn', function()
	local source = source
	if deadPlayers[source] then
		deadPlayers[source] = nil
		local Ambulance = ESX.GetExtendedPlayers("job", "ambulance")

		for _, xPlayer in pairs(Ambulance) do
			xPlayer.triggerEvent('ztisco:ambulance:PlayerNotDead', source)
		end
	end
end)

AddEventHandler('esx:playerDropped', function(playerId, reason)
	if deadPlayers[playerId] then
		deadPlayers[playerId] = nil
		local Ambulance = ESX.GetExtendedPlayers("job", "ambulance")

		for _, xPlayer in pairs(Ambulance) do
			if xPlayer.job.name == 'ambulance' then
				xPlayer.triggerEvent('ztisco:ambulance:PlayerNotDead', playerId)
			end
		end
	end
end)

RegisterNetEvent('ztisco:ambulance:heal', function(target, type)
	local xPlayer = ESX.GetPlayerFromId(source)

	if xPlayer.job.name == 'ambulance' then
		TriggerClientEvent('ztisco:ambulance:heal', target, type)
	end
end)

RegisterNetEvent('ztisco:ambulance:putInVehicle', function(target)
	local xPlayer = ESX.GetPlayerFromId(source)

	if xPlayer.job.name == 'ambulance' then
		TriggerClientEvent('ztisco:ambulance:putInVehicle', target)
	end
end)

RegisterNetEvent('ztisco:ambulance:OutVehicle', function(target)
    local xPlayer = ESX.GetPlayerFromId(source)
    if xPlayer and xPlayer.job and xPlayer.job.name == 'ambulance' then
        -- On envoie l'ordre de sortir du véhicule au joueur ciblé
        TriggerClientEvent('ztisco:ambulance:OutVehicle', target)
    else
        print(('[ztisco:ambulance] ^1Le joueur %s n\'a pas le job ambulance^0'):format(source))
    end
end)




ESX.RegisterServerCallback('ztisco:ambulance:removeItemsAfterRPDeath', function(source, cb)
	local xPlayer = ESX.GetPlayerFromId(source)

	if ConfigTiscoJobs.ambulance.OxInventory and ConfigTiscoJobs.ambulance.RemoveItemsAfterRPDeath then
		exports.ox_inventory:ClearInventory(xPlayer.source)
		return cb()
	end

	if ConfigTiscoJobs.ambulance.RemoveCashAfterRPDeath then
		if xPlayer.getMoney() > 0 then
			xPlayer.removeMoney(xPlayer.getMoney(), "Death")
		end

		if xPlayer.getAccount('black_money').money > 0 then
			xPlayer.setAccountMoney('black_money', 0, "Death")
		end
	end

	if ConfigTiscoJobs.ambulance.RemoveItemsAfterRPDeath then
		for i = 1, #xPlayer.inventory, 1 do
			if xPlayer.inventory[i].count > 0 then
				xPlayer.setInventoryItem(xPlayer.inventory[i].name, 0)
			end
		end
	end

	if ConfigTiscoJobs.ambulance.OxInventory then return cb() end

	local playerLoadout = {}
	if ConfigTiscoJobs.ambulance.RemoveWeaponsAfterRPDeath then
		for i = 1, #xPlayer.loadout, 1 do
			xPlayer.removeWeapon(xPlayer.loadout[i].name)
		end
	else -- save weapons & restore em' since spawnmanager removes them
		for i = 1, #xPlayer.loadout, 1 do
			table.insert(playerLoadout, xPlayer.loadout[i])
		end

		-- give back wepaons after a couple of seconds
		CreateThread(function()
			Wait(5000)
			for i = 1, #playerLoadout, 1 do
				if playerLoadout[i].label ~= nil then
					xPlayer.addWeapon(playerLoadout[i].name, playerLoadout[i].ammo)
				end
			end
		end)
	end

	cb()
end)

if ConfigTiscoJobs.ambulance.EarlyRespawnFine then
	ESX.RegisterServerCallback('ztisco:ambulance:checkBalance', function(source, cb)
		local xPlayer = ESX.GetPlayerFromId(source)
		local bankBalance = xPlayer.getAccount('bank').money

		cb(bankBalance >= ConfigTiscoJobs.ambulance.EarlyRespawnFineAmount)
	end)

	RegisterNetEvent('ztisco:ambulance:payFine', function()
		local xPlayer = ESX.GetPlayerFromId(source)
		local fineAmount = ConfigTiscoJobs.ambulance.EarlyRespawnFineAmount

		xPlayer.showNotification(TranslateCap('respawn_bleedout_fine_msg', ESX.Math.GroupDigits(fineAmount)))
		xPlayer.removeAccountMoney('bank', fineAmount, "Respawn Fine")
	end)
end

ESX.RegisterServerCallback('ztisco:ambulance:getItemAmount', function(source, cb, item)
	local xPlayer = ESX.GetPlayerFromId(source)
	local quantity = xPlayer.getInventoryItem(item).count

	cb(quantity)
end)

ESX.RegisterServerCallback('ztisco:ambulance:buyJobVehicle', function(source, cb, vehicleProps, type)
	local xPlayer = ESX.GetPlayerFromId(source)
	local price = getPriceFromHash(vehicleProps.model, xPlayer.job.grade_name, type)

	-- vehicle model not found
	if price == 0 then
		cb(false)
	else
		if xPlayer.getMoney() >= price then
			xPlayer.removeMoney(price, "Job Vehicle Purchase")

			MySQL.insert('INSERT INTO owned_vehicles (owner, vehicle, plate, type, job, `stored`) VALUES (?, ?, ?, ?, ?, ?)',
				{ xPlayer.identifier, json.encode(vehicleProps), vehicleProps.plate, type, xPlayer.job.name, true },
				function(rowsChanged)
					cb(true)
				end)
		else
			cb(false)
		end
	end
end)

ESX.RegisterServerCallback('ztisco:ambulance:storeNearbyVehicle', function(source, cb, plates)
	local xPlayer = ESX.GetPlayerFromId(source)

	local plate = MySQL.scalar.await('SELECT plate FROM owned_vehicles WHERE owner = ? AND plate IN (?) AND job = ?',
		{ xPlayer.identifier, plates, xPlayer.job.name })

	if plate then
		MySQL.update('UPDATE owned_vehicles SET `stored` = true WHERE owner = ? AND plate = ? AND job = ?',
			{ xPlayer.identifier, plate, xPlayer.job.name },
			function(rowsChanged)
				if rowsChanged == 0 then
					cb(false)
				else
					cb(plate)
				end
			end)
	else
		cb(false)
	end
end)

function getPriceFromHash(vehicleHash, jobGrade, type)
	local vehicles = ConfigTiscoJobs.ambulance.AuthorizedVehicles[type][jobGrade]

	for i = 1, #vehicles do
		local vehicle = vehicles[i]
		if joaat(vehicle.model) == vehicleHash then
			return vehicle.price
		end
	end

	return 0
end

RegisterNetEvent('ztisco:ambulance:removeItem', function(itemName, targetId)
    local xPlayer = ESX.GetPlayerFromId(source) -- source doit être un joueur valide (pas 0, pas -1)

    if xPlayer then
        if xPlayer.job and xPlayer.job.name == 'ambulance' then
            xPlayer.removeInventoryItem(itemName, 1)

            local xTarget = ESX.GetPlayerFromId(targetId)
            if xTarget then
                local amount = 500
                TriggerEvent('esx_billing:sendBill', xTarget.source, 'society_ambulance', 'Ambulance Soins', amount)
            end
        else
            print((">>> [ERROR] Le joueur %s n'a pas le job ambulance."):format(xPlayer.source))
        end
    else
        print((">>> [ERROR] xPlayer is nil for source %s"):format(source))
    end
end)


RegisterNetEvent('ztisco:ambulance:giveItem', function(itemName, amount)
	local xPlayer = ESX.GetPlayerFromId(source)

	if xPlayer.job.name ~= 'ambulance' then
		console.warn(('Player ^5%s^7 Tried Giving Themselves -> ^5' .. itemName .. '^7!'):format(xPlayer.source))
		return
	elseif (itemName ~= 'medikit' and itemName ~= 'bandage') then
		console.warn(('Player ^5%s^7 Tried Giving Themselves -> ^5' .. itemName .. '^7!'):format(xPlayer.source))
		return
	end

	if xPlayer.canCarryItem(itemName, amount) then
		xPlayer.addInventoryItem(itemName, amount)
	else
		xPlayer.showNotification(TranslateCap('max_item'))
	end
end)

ESX.RegisterCommand('revive', 'founder', function(xPlayer, args, showError)
	args.playerId.triggerEvent('ztisco:ambulance:revive')
end, true, { help = TranslateCap('revive_help'), validate = true, arguments = {
	{ name = 'playerId', help = 'The player id', type = 'player' }
} })

ESX.RegisterCommand('reviveall', "founder", function(xPlayer, args, showError)
	TriggerClientEvent('ztisco:ambulance:revive', -1)
end, false)

ESX.RegisterUsableItem('medikit', function(source)
	if not playersHealing[source] then
		local xPlayer = ESX.GetPlayerFromId(source)
		xPlayer.removeInventoryItem('medikit', 1)

		playersHealing[source] = true
		TriggerClientEvent('ztisco:ambulance:useItem', source, 'medikit')

		Wait(10000)
		playersHealing[source] = nil
	end
end)

ESX.RegisterUsableItem('bandage', function(source)
	if not playersHealing[source] then
		local xPlayer = ESX.GetPlayerFromId(source)
		xPlayer.removeInventoryItem('bandage', 1)

		playersHealing[source] = true
		TriggerClientEvent('ztisco:ambulance:useItem', source, 'bandage')

		Wait(10000)
		playersHealing[source] = nil
	end
end)

ESX.RegisterServerCallback('ztisco:ambulance:getDeadPlayers', function(source, cb)
	local xPlayer = ESX.GetPlayerFromId(source)
	if xPlayer.job.name == "ambulance" then
		cb(deadPlayers)
	end
end)

ESX.RegisterServerCallback('ztisco:ambulance:getDeathStatus', function(source, cb)
	local xPlayer = ESX.GetPlayerFromId(source)
	MySQL.scalar('SELECT is_dead FROM users WHERE identifier = ?', { xPlayer.identifier }, function(isDead)
		cb(isDead)
	end)
end)

RegisterNetEvent('ztisco:ambulance:setDeathStatus', function(isDead)
	local xPlayer = ESX.GetPlayerFromId(source)

	if type(isDead) == 'boolean' then
		MySQL.update('UPDATE users SET is_dead = ? WHERE identifier = ?', { isDead, xPlayer.identifier })

		if not isDead then
			local Ambulance = ESX.GetExtendedPlayers("job", "ambulance")
			for _, xPlayer in pairs(Ambulance) do
				xPlayer.triggerEvent('ztisco:ambulance:PlayerNotDead', source)
			end
		end
	end

end)

RegisterServerEvent('ztisco:ambulance:announce', function(type, msg)
	local _source = source
	local xPlayer = ESX.GetPlayerFromId(_source)
	local xPlayers	= ESX.GetPlayers()

	RegisterNetEvent('ztisco:ambulance:announce', function(type, msg)
		local xPlayers = ESX.GetPlayers()
	
		if type == "open" then
			for i=1, #xPlayers, 1 do
				TriggerClientEvent('esx:showAdvancedNotification', xPlayers[i],
					"San Andreas Medical Center", 
					'~b~INFORMATION', 
					"Le San Andreas Medical Center est désormais ~g~ouvert~s~. Notre équipe est prête à vous accueillir pour tous vos besoins médicaux.",
					"CHAR_CRIS", 
					1
				)
			end
		end
	
		if type == "close" then
			for i=1, #xPlayers, 1 do
				TriggerClientEvent('esx:showAdvancedNotification', xPlayers[i],
					"San Andreas Medical Center", 
					'~b~INFORMATION', 
					"Le San Andreas Medical Center a fermé ~r~ses portes~s~. Merci de votre confiance, nous vous accueillerons à nouveau très bientôt.",
					"CHAR_CRIS", 
					1
				)
			end
		end
	end)
	
		if type == "perso" then
			for i=1, #xPlayers, 1 do
				TriggerClientEvent('esx:showAdvancedNotification', xPlayers[i],
					"San Andreas Medical Center",
					'~b~INFORMATION',
					msg,
					"CHAR_CRIS",
					1
				)
			end
		end
	end)
	
RegisterServerEvent("ztisco:ambulance:rdv", function(nomprenom, numero, heurerdv, rdvmotif)
	local _source = source
    local xPlayer = ESX.GetPlayerFromId(_source)
    local ident = xPlayer.getIdentifier()
	local date = os.date('*t')

	if date.day < 10 then date.day = '' .. tostring(date.day) end
	if date.month < 10 then date.month = '' .. tostring(date.month) end
	if date.hour < 10 then date.hour = '' .. tostring(date.hour) end
	if date.min < 10 then date.min = '' .. tostring(date.min) end
	if date.sec < 10 then date.sec = '' .. tostring(date.sec) end
end)

RegisterServerEvent('ztisco:ambulance:call', function()
    
	local xPlayers = ESX.GetPlayers()
	for i = 1, #xPlayers, 1 do
		local thePlayer = ESX.GetPlayerFromId(xPlayers[i])
		if thePlayer.job.name == 'ambulance' then
		TriggerClientEvent('esx:showAdvancedNotification', xPlayers[i], 'Ambulance', '~b~Accueil', 'Un EMS est appelé à l\'accueil !', "CHAR_CRIS", 1)
        end
    end
end)

---------------------------

RegisterNetEvent('ztisco:ambulance:wheelchair', function(item_name)
	local xPlayer = ESX.GetPlayerFromId(source)
	if xPlayer.canCarryItem("wheelchair", 1) then
		local itemchair = xPlayer.getInventoryItem("wheelchair").count
		if itemchair == 0 then
			xPlayer.addInventoryItem("wheelchair", 1)
		end
	else
		TriggerClientEvent("esx:showNotification",source,"~r~Vous ne pouvez pas prendre ça sur vous.")
	end
end)

RegisterNetEvent("ztisco:ambulance:bedSystem", function(action)
	local xPlayer = ESX.GetPlayerFromId(source)
	if action == "bed" and xPlayer then 
		xPlayer.addInventoryItem("bed", 1)
	end
end)

ESX.RegisterServerCallback("ztisco:ambulance:canSpawnBed", function(source, cb)
	local xPlayer = ESX.GetPlayerFromId(source)
	if xPlayer and xPlayer.getInventoryItem("bed").count > 0 then
		cb(true)
	else
		cb(false)
	end
end)



RegisterNetEvent('ztisco:ambulance:demandeRenfort', function(t, coords)
    local xPlayer = ESX.GetPlayerFromId(source)
    if xPlayer and xPlayer.job and xPlayer.job.name == 'ambulance' then
        for _, playerId in pairs(ESX.GetPlayers()) do
            local xTarget = ESX.GetPlayerFromId(playerId)
            if xTarget and xTarget.job and xTarget.job.name == 'ambulance' then
                TriggerClientEvent('ztisco:ambulance:renfortCall', playerId, t, coords)
            end
        end
    end
end)




ESX.RegisterUsableItem('wheelchair', function(source)
	local _source = source
	local xPlayer = ESX.GetPlayerFromId(_source)
	xPlayer.removeInventoryItem("wheelchair", 1)
	TriggerClientEvent('ztisco:ambulance:useChair', _source)
end)

ESX.RegisterUsableItem('bed', function(source)
	local _source = source
	local xPlayer = ESX.GetPlayerFromId(_source)
	xPlayer.removeInventoryItem("bed", 1)
	TriggerClientEvent('ztisco:ambulance:useBed', _source)
end)


print("Script by S0ltrak for ^2DevHub's^7")
print("^2Discord : https://discord.gg/3eSufdKtdH^7")