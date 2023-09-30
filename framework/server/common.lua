ESX = {}
ESX.Players = {}
ESX.Jobs = {}
ESX.Crew = {}
ESX.Items = {}
Core = {}
Core.UsableItemsCallbacks = {}
Core.ServerCallbacks = {}
Core.TimeoutCount = -1
Core.CancelledTimeouts = {}
Core.RegisteredCommands = {}
Core.Pickups = {}
Core.PickupId = 0
Core.PlayerFunctionOverrides = {}

AddEventHandler('esx:getSharedObject', function(cb)
	cb(ESX)
end)

exports('getSharedObject', function()
	return ESX
end)

if GetResourceState('ox_inventory') ~= 'missing' then
	Config.OxInventory = true
	Config.PlayerFunctionOverride = 'OxInventory'
	SetConvarReplicated('inventory:framework', 'esx')
	SetConvarReplicated('inventory:weight', Config.MaxWeight * 1000)
end

local function StartDBSync()
	CreateThread(function()
		while true do
			Wait(10 * 60 * 1000)
			Core.SavePlayers()
		end
	end)
end

MySQL.ready(function()
	if not Config.OxInventory then
		local items = MySQL.query.await('SELECT * FROM items')
		for k, v in ipairs(items) do
			ESX.Items[v.name] = {
				label = v.label,
				weight = v.weight,
				rare = v.rare,
				canRemove = v.can_remove
			}
		end
	else
		TriggerEvent('__cfx_export_ox_inventory_Items', function(ref)
			if ref then
				ESX.Items = ref()
			end
		end)

		AddEventHandler('ox_inventory:itemList', function(items)
			ESX.Items = items
		end)

		while not next(ESX.Items) do Wait(0) end
	end

	local Jobs = {}
	local jobs = MySQL.query.await('SELECT * FROM jobs')

	for _, v in ipairs(jobs) do
		Jobs[v.name] = v
		Jobs[v.name].grades = {}
	end

	local jobGrades = MySQL.query.await('SELECT * FROM job_grades')

	for _, v in ipairs(jobGrades) do
		if Jobs[v.job_name] then
			Jobs[v.job_name].grades[tostring(v.grade)] = v
		else
			print(('[^3ATTENTION^7] Ignorer les notes d/*emploi pour ^5"%s"^0 en raison d/*un emploi manquant'):format(v.job_name))
		end
	end

	for _, v in pairs(Jobs) do
		if ESX.Table.SizeOf(v.grades) == 0 then
			Jobs[v.name] = nil
			print(('[^3ATTENTION^7] Emploi ^5"%s"^0 ignoré car aucune note d/*emploi n/*a été trouvée'):format(v.name))
		end
	end

	if not Jobs then
		-- Fallback data, if no jobs exist
		ESX.Jobs['unemployed'] = {label = 'Unemployed', grades = { ['0'] = { grade = 0, label = 'Unemployed', salary = 200, onDuty = false, skin_male = {}, skin_female = {} }}}
	else
		ESX.Jobs = Jobs
	end

	--Crew system
	local Crew = {}
	local crew = MySQL.query.await('SELECT * FROM crew')

	for _, v in ipairs(crew) do
		Crew[v.name] = v
		Crew[v.name].grades = {}
	end

	local crewGrades = MySQL.query.await('SELECT * FROM crew_grades')

	for _, v in ipairs(crewGrades) do
		if Crew[v.crew_name] then
			Crew[v.crew_name].grades[tostring(v.grade)] = v
		end
	end

	for _, v in pairs(Crew) do
		if ESX.Table.SizeOf(v.grades) == 0 then
			Crew[v.name] = nil
		end
	end

	if not Crew then
		-- Fallback data, if no jobs exist
		ESX.Crew['nocrew'] = { label = 'Aucun crew', grades = { ['0'] = { grade = 0, label = '', salary = 200, skin_male = {}, skin_female = {} }}}
	else
		ESX.Crew = Crew end

	print('[^2Note - Info^7] [^6sFramework^7] ^5Legacy^0 ^1initialiée^7')
	StartDBSync()
	StartPayCheck()
end)

RegisterServerEvent('esx:clientLog')
AddEventHandler('esx:clientLog', function(msg)
	if Config.EnableDebug then
		print(('[^2Note - Info^7] %s^7'):format(msg))
	end
end)

RegisterServerEvent('esx:triggerServerCallback')
AddEventHandler('esx:triggerServerCallback', function(name, requestId, ...)
	local playerId = source

	ESX.TriggerServerCallback(name, requestId, playerId, function(...)
		TriggerClientEvent('esx:serverCallback', playerId, requestId, ...)
	end, ...)
end)
