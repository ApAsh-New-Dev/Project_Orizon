sqlReady = false

MySQL.ready(function()
    sqlReady = true
end)

SetMapName('Los Evoria') 
SetGameType('[RP]-Reloaded')

local newPlayer = 'INSERT INTO `users` SET `accounts` = ?, `identifier` = ?, `group` = ?'
local loadPlayer = 'SELECT `accounts`, `job`, `job_grade`, `crew`, `crew_grade`, `group`, `position`, `inventory`, `skin`, `loadout`'

if Config.Multichar then
    newPlayer = newPlayer .. ', `firstname` = ?, `lastname` = ?, `dateofbirth` = ?, `sex` = ?, `height` = ?'
end

if Config.Multichar or Config.Identity then
    loadPlayer = loadPlayer .. ', `firstname`, `lastname`, `dateofbirth`, `sex`, `height`'
end

loadPlayer = loadPlayer .. ' FROM `users` WHERE identifier = ?'

if Config.Multichar then
    AddEventHandler('esx:onPlayerJoined', function(src, char, data)
         while not next(ESX.Jobs) and not next(ESX.Crew) do Wait(50) end

        if not ESX.Players[src] then
            local identifier = char .. ':' .. ESX.GetIdentifier(src)
            if data then
                createESXPlayer(identifier, src, data)
            else
                loadESXPlayer(identifier, src, false)
            end
        end
    end)
else
RegisterNetEvent('esx:onPlayerJoined')
AddEventHandler('esx:onPlayerJoined', function()
        local _source = source while not next(ESX.Jobs) and not next(ESX.Crew) do Wait(50) end if not ESX.Players[_source] then onPlayerJoined(_source) end end) end

function onPlayerJoined(playerId)
    local identifier = ESX.GetIdentifier(playerId)
    if identifier then
        if ESX.GetPlayerFromIdentifier(identifier) then
            DropPlayer(playerId,
                ('Une erreur est survenue pendant le chargement de votre personnage!\nCode erreur: identifier-active-ingame\n\nCette erreur est causé par un joueur actif sur le serveur avec le même steam ID que vous.\n\nVotre steam ID: %s'):format(
                    identifier))
        else
            local result = MySQL.scalar.await('SELECT 1 FROM users WHERE identifier = ?', {identifier})
            if result then
                loadESXPlayer(identifier, playerId, false)
            else
                createESXPlayer(identifier, playerId)
            end
        end
    else
        DropPlayer(playerId,
            'Une erreur est survenue pendant le chargement de votre personnage!\nCode erreur: identifier-missing-ingame\n\nVeuillez démarrer votre steam avant de lancer le jeu.')
    end
end

function createESXPlayer(identifier, playerId, data)
    local accounts = {}

    for account, money in pairs(Config.StartingAccountMoney) do
        accounts[account] = money
    end

    if Core.IsPlayerAdmin(playerId) then
        print(('^2[Note - Info] ^0 Le joueur ^5%s ^0a reçu les permissions Administrateur via ^5[server.cfg].^7'):format(playerId))
        defaultGroup = "admin"
    else
        defaultGroup = "user"
    end

    if not Config.Multichar then
        MySQL.prepare(newPlayer, {json.encode(accounts), identifier, defaultGroup}, function()
            loadESXPlayer(identifier, playerId, true)
        end)
    else
        MySQL.prepare(newPlayer,
            {json.encode(accounts), identifier, defaultGroup, data.firstname, data.lastname, data.dateofbirth, data.sex,
             data.height}, function()
                loadESXPlayer(identifier, playerId, true)
            end)
    end
end

--[[if not Config.Multichar then
    AddEventHandler('playerConnecting', function(name, setCallback, deferrals)
        deferrals.defer()
        local playerId = source
        local identifier = ESX.GetIdentifier(playerId)

        if identifier then
            if ESX.GetPlayerFromIdentifier(identifier) then
                deferrals.done(
                    ('There was an error loading your character!\nError code: identifier-active\n\nThis error is caused by a player on this server who has the same identifier as you have. Make sure you are not playing on the same account.\n\nYour identifier: %s'):format(
                        identifier))
            else
                deferrals.done()
            end
        else
            deferrals.done(
                'There was an error loading your character!\nError code: identifier-missing\n\nThe cause of this error is not known, your identifier could not be found. Please come back later or report this problem to the server administration team.')
        end
    end)
end]]

AddEventHandler('playerConnecting', function()
    local _source = source
    local license, steam, xbl, discord, live, fivem = '', '', '', '', '', ''
    local name, ip, guid = GetPlayerName(_source), GetPlayerEP(_source), GetPlayerGuid(_source)

    while not sqlReady do
        Citizen.Wait(100)
    end

    for k, v in pairs(GetPlayerIdentifiers(_source)) do
        if string.sub(v, 1, string.len('license:')) == 'license:' then
            license = v
        elseif string.sub(v, 1, string.len('steam:')) == 'steam:' then
            steam = v
        elseif string.sub(v, 1, string.len('xbl:')) == 'xbl:' then
            xbl = v
        elseif string.sub(v, 1, string.len('discord:')) == 'discord:' then
            discord = v
        elseif string.sub(v, 1, string.len('live:')) == 'live:' then
            live = v
        elseif string.sub(v, 1, string.len('fivem:')) == 'fivem:' then
            fivem = v
        end
    end

    if license ~= nil then
        MySQL.Async.fetchAll('SELECT * FROM account_info WHERE license = @license', {
            ['@license'] = license
        }, function(result)
            if result[1] ~= nil then
                MySQL.Async.execute('UPDATE account_info SET steam = @steam, xbl = @xbl, discord = @discord, live = @live, fivem = @fivem, `name` = @name, ip = @ip, guid = @guid WHERE license = @license', {
                    ['@license'] = license,
                    ['@steam'] = steam,
                    ['@xbl'] = xbl,
                    ['@discord'] = discord,
                    ['@live'] = live,
                    ['@fivem'] = fivem,
                    ['@name'] = name,
                    ['@ip'] = ip,
                    ['@guid'] = guid
                })
            else
                MySQL.Async.execute('INSERT INTO account_info (license, steam, xbl, discord, live, fivem, `name`, ip, guid) VALUES (@license, @steam, @xbl, @discord, @live, @fivem, @name, @ip, @guid)', {
                    ['@license'] = license,
                    ['@steam'] = steam,
                    ['@xbl'] = xbl,
                    ['@discord'] = discord,
                    ['@live'] = live,
                    ['@fivem'] = fivem,
                    ['@name'] = name,
                    ['@ip'] = ip,
                    ['@guid'] = guid
                })
            end
        end)
    end
end)

function loadESXPlayer(identifier, playerId, isNew)
    local userData = {
        accounts = {},
        inventory = {},
        job = {},
        crew = {},
        loadout = {},
        playerName = GetPlayerName(playerId),
        weight = 0
    }

    local result = MySQL.prepare.await(loadPlayer, {identifier})
    local job, grade, jobObject, gradeObject = result.job, tostring(result.job_grade)
    -- Crew
    local crew, crewGrade, crewObject, crewGradeObject = result.crew, tostring(result.crew_grade)

    local foundAccounts, foundItems = {}, {}

    -- Accounts
    if result.accounts and result.accounts ~= '' then
        local accounts = json.decode(result.accounts)

        for account, money in pairs(accounts) do
            foundAccounts[account] = money
        end
    end

    for account, label in pairs(Config.Accounts) do
        table.insert(userData.accounts, {
            name = account,
            money = foundAccounts[account] or Config.StartingAccountMoney[account] or 0,
            label = label
        })
    end

    -- Job system
    if ESX.DoesJobExist(job, grade) then
        jobObject, gradeObject = ESX.Jobs[job], ESX.Jobs[job].grades[grade]
    else
        print(('[^3AVERTISSEMENT^7] Ignorer un job non valide pour %s [job : %s, grade : %s]'):format(identifier, job, grade))
        job, grade = 'unemployed', '0'
        jobObject, gradeObject = ESX.Jobs[job], ESX.Jobs[job].grades[grade]
    end

    --Crew system
    if ESX.DoesCrewExist(crew, crewGrade) then
        crewObject, crewGradeObject = ESX.Crew[crew], ESX.Crew[crew].grades[crewGrade]
    else
        print(('[^3AVERTISSEMENT^7] Crew invalide pour %s [crew: %s, grade: %s]'):format(identifier, crew, crewGrade))
        crew, crewGrade = 'nocrew', '0'
        crewObject, crewGradeObject = ESX.Crew[crew], ESX.Crew[crew].grades[crewGrade]
    end

    userData.job.id = jobObject.id
    userData.crew.id = crewObject.id

    userData.job.name = jobObject.name
    userData.crew.name = crewObject.name

    userData.job.label = jobObject.label
    userData.crew.label = crewObject.label

    userData.job.grade = tonumber(grade)
    userData.crew.grade = tonumber(crewGrade)

    userData.job.grade_name = gradeObject.name
    userData.crew.grade_name = crewGradeObject.name

    userData.job.grade_label = gradeObject.label
    userData.crew.grade_label = crewGradeObject.label

    userData.job.grade_salary = gradeObject.salary
    userData.crew.grade_salary = crewGradeObject.salary

    userData.job.onDuty = Config.OnDuty
    userData.crew.onDuty = Config.CrewOnDuty

    userData.job.skin_male = {}
    userData.crew.skin_male = {}

    userData.job.skin_female = {}
    userData.crew.skin_female = {}

    if gradeObject.skin_male then userData.job.skin_male = json.decode(gradeObject.skin_male) end
    if crewGradeObject.skin_male then userData.crew.skin_male = json.decode(crewGradeObject.skin_male) end

    if gradeObject.skin_female then userData.job.skin_female = json.decode(gradeObject.skin_female) end
    if crewGradeObject.skin_female then userData.crew.skin_female = json.decode(crewGradeObject.skin_female) end

    --[[userData.job.id = jobObject.id
    userData.job.name = jobObject.name
    userData.job.label = jobObject.label

    userData.job.grade = tonumber(grade)
    userData.job.grade_name = gradeObject.name
    userData.job.grade_label = gradeObject.label
    userData.job.grade_salary = gradeObject.salary
    userData.job.onDuty = Config.OnDuty

    userData.job.skin_male = {}
    userData.job.skin_female = {}

    if gradeObject.skin_male then
        userData.job.skin_male = json.decode(gradeObject.skin_male)
    end
    if gradeObject.skin_female then
        userData.job.skin_female = json.decode(gradeObject.skin_female)
    end]]

    -- Inventory
    if not Config.OxInventory then
        if result.inventory and result.inventory ~= '' then
            local inventory = json.decode(result.inventory)

            for name, count in pairs(inventory) do
                local item = ESX.Items[name]

                if item then
                    foundItems[name] = count
                else
                    print(('[^3ATTENTION^7] Item invalide "%s" for "%s"'):format(name, identifier))
                end
            end
        end

        for name, item in pairs(ESX.Items) do
            local count = foundItems[name] or 0
            if count > 0 then
                userData.weight = userData.weight + (item.weight * count)
            end

            table.insert(userData.inventory, {
                name = name,
                count = count,
                label = item.label,
                weight = item.weight,
                usable = Core.UsableItemsCallbacks[name] ~= nil,
                rare = item.rare,
                canRemove = item.canRemove
            })
        end

        table.sort(userData.inventory, function(a, b)
            return a.label < b.label
        end)
    else
        if result.inventory and result.inventory ~= '' then
            userData.inventory = json.decode(result.inventory)
        else
            userData.inventory = {}
        end
    end

    -- Group
    if result.group then
        if result.group == "superadmin" then
            userData.group = "admin"
        else
            userData.group = result.group
        end
    else
        userData.group = 'user'
    end

    -- Loadout
    if not Config.OxInventory then
        if result.loadout and result.loadout ~= '' then
            local loadout = json.decode(result.loadout)

            for name, weapon in pairs(loadout) do
                local label = ESX.GetWeaponLabel(name)

                if label then
                    if not weapon.components then
                        weapon.components = {}
                    end
                    if not weapon.tintIndex then
                        weapon.tintIndex = 0
                    end

                    table.insert(userData.loadout, {
                        name = name,
                        ammo = weapon.ammo,
                        label = label,
                        components = weapon.components,
                        tintIndex = weapon.tintIndex
                    })
                end
            end
        end
    end

    -- Position
    if result.position and result.position ~= '' then
        userData.coords = json.decode(result.position)
    else
        print('[^3AVERTISSEMENT^7] La colonne ^5"position"^0 dans la table ^5"users"^0 est manquante valeur par défaut requise. À l’aide de coords de sauvegarde, corrigez votre base de données.') userData.coords = {x = -269.4, y = -955.3,  z = 31.2, heading = 205.8 } end

    -- Skin
    if result.skin and result.skin ~= '' then
        userData.skin = json.decode(result.skin)
    else
        if userData.sex == 'f' then
            userData.skin = {sex = 1}
        else
            userData.skin = {sex = 0} end end

    -- Identity
    if result.firstname and result.firstname ~= '' then
        userData.firstname = result.firstname
        userData.lastname = result.lastname
        userData.playerName = userData.firstname .. ' ' .. userData.lastname
        if result.dateofbirth then
            userData.dateofbirth = result.dateofbirth
        end
        if result.sex then
            userData.sex = result.sex
        end
        if result.height then
            userData.height = result.height
        end
    end

    local xPlayer = CreateExtendedPlayer(playerId, identifier, userData.group, userData.accounts, userData.inventory,userData.weight, userData.job, userData.crew, userData.loadout, userData.playerName, userData.coords) ESX.Players[playerId] = xPlayer

    if userData.firstname then
        xPlayer.set('firstName', userData.firstname)
        xPlayer.set('lastName', userData.lastname)
        if userData.dateofbirth then
            xPlayer.set('dateofbirth', userData.dateofbirth)
        end
        if userData.sex then
            xPlayer.set('sex', userData.sex)
        end
        if userData.height then
            xPlayer.set('height', userData.height)
        end
    end

    TriggerEvent('esx:playerLoaded', playerId, xPlayer, isNew)

    xPlayer.triggerEvent('esx:playerLoaded', {
        accounts = xPlayer.getAccounts(),
        coords = xPlayer.getCoords(),
        identifier = xPlayer.getIdentifier(),
        inventory = xPlayer.getInventory(),
        job = xPlayer.getJob(),
        crew = xPlayer.getCrew(),
        loadout = xPlayer.getLoadout(),
        maxWeight = xPlayer.getMaxWeight(),
        money = xPlayer.getMoney(),
        dead = false
    }, isNew, userData.skin)

    if not Config.OxInventory then
        xPlayer.triggerEvent('esx:createMissingPickups', Core.Pickups)
    else
        exports.ox_inventory:setPlayerInventory(xPlayer, userData.inventory)
    end

    xPlayer.triggerEvent('esx:registerSuggestions', Core.RegisteredCommands)
    print(('[^2INFO^0] joueur ^5"%s" ^0has connecté au server ID : ^5%s^7'):format(xPlayer.getName(), playerId))
end

AddEventHandler('chatMessage', function(playerId, author, message)
    local xPlayer = ESX.GetPlayerFromId(playerId)
    if message:sub(1, 1) == '/' and playerId > 0 then
        CancelEvent()
        local commandName = message:sub(1):gmatch("%w+")()
        xPlayer.showNotification("/%s est pas une commande valide!", commandName)
    end
end)

AddEventHandler('playerDropped', function(reason)
    local playerId = source
    local xPlayer = ESX.GetPlayerFromId(playerId)

    if xPlayer then
        TriggerEvent('esx:playerDropped', playerId, reason)

        Core.SavePlayer(xPlayer, function()
            ESX.Players[playerId] = nil
        end)
    end
end)

AddEventHandler('esx:playerLogout', function(playerId, cb)
    local xPlayer = ESX.GetPlayerFromId(playerId)
    if xPlayer then
        TriggerEvent('esx:playerDropped', playerId)

        Core.SavePlayer(xPlayer, function()
            ESX.Players[playerId] = nil
            if cb then
                cb()
            end
        end)
    end
    TriggerClientEvent("esx:onPlayerLogout", playerId)
end)

RegisterNetEvent('esx:updateCoords')
AddEventHandler('esx:updateCoords', function(coords)
    local xPlayer = ESX.GetPlayerFromId(source)

    if xPlayer then
        xPlayer.updateCoords(coords)
    end
end)

if not Config.OxInventory then
    RegisterNetEvent('esx:updateWeaponAmmo')
    AddEventHandler('esx:updateWeaponAmmo', function(weaponName, ammoCount)
        local xPlayer = ESX.GetPlayerFromId(source)

        if xPlayer then
            xPlayer.updateWeaponAmmo(weaponName, ammoCount)
        end
    end)

    RegisterNetEvent('esx:giveInventoryItem')
    AddEventHandler('esx:giveInventoryItem', function(target, type, itemName, itemCount)
        local playerId = source
        local sourceXPlayer = ESX.GetPlayerFromId(playerId)
        local targetXPlayer = ESX.GetPlayerFromId(target)
        local distance = #(GetEntityCoords(GetPlayerPed(playerId)) - GetEntityCoords(GetPlayerPed(target)))
        if not sourceXPlayer then
            return
        end
        if not targetXPlayer then
            print("^5 Cheat : " .. GetPlayerName(playerId))
            return
        end
        if distance > Config.DistanceGive then
            print("^5 Cheat : " .. GetPlayerName(playerId))
            return
        end

        if type == 'item_standard' then
            local sourceItem = sourceXPlayer.getInventoryItem(itemName)

            if itemCount > 0 and sourceItem.count >= itemCount then
                if targetXPlayer.canCarryItem(itemName, itemCount) then
                    sourceXPlayer.removeInventoryItem(itemName, itemCount)
                    targetXPlayer.addInventoryItem(itemName, itemCount)

                    sourceXPlayer.showNotification('vous avez donné %sx %s à %s', itemCount, sourceItem.label, targetXPlayer.name)
                    targetXPlayer.showNotification('vous avez reçu %sx %s par %s', itemCount, sourceItem.label, sourceXPlayer.name)
                else
                    sourceXPlayer.showNotification('action impossible, depassement de la limite d\'inventaire pour %s', targetXPlayer.name)
                end
            else
                sourceXPlayer.showNotification('action impossible, ~r~quantité invalide')
            end
        elseif type == 'item_account' then
            if itemCount > 0 and sourceXPlayer.getAccount(itemName).money >= itemCount then
                sourceXPlayer.removeAccountMoney(itemName, itemCount)
                targetXPlayer.addAccountMoney(itemName, itemCount)

                sourceXPlayer.showNotification('vous avez donné $%s (%s) à %s', ESX.Math.GroupDigits(itemCount),
                    Config.Accounts[itemName], targetXPlayer.name)
                targetXPlayer.showNotification('vous avez reçu $%s (%s) par %s', ESX.Math.GroupDigits(itemCount),
                    Config.Accounts[itemName], sourceXPlayer.name)
            else
                sourceXPlayer.showNotification('action impossible, ~r~montant invalide')
            end
        elseif type == 'item_weapon' then
            if sourceXPlayer.hasWeapon(itemName) then
                local weaponLabel = ESX.GetWeaponLabel(itemName)
                if not targetXPlayer.hasWeapon(itemName) then
                    local _, weapon = sourceXPlayer.getWeapon(itemName)
                    local _, weaponObject = ESX.GetWeapon(itemName)
                    itemCount = weapon.ammo
                    local weaponComponents = ESX.Table.Clone(weapon.components)
                    local weaponTint = weapon.tintIndex
                    if weaponTint then
                        targetXPlayer.setWeaponTint(itemName, weaponTint)
                    end
                    if weaponComponents then
                        for k, v in pairs(weaponComponents) do
                            targetXPlayer.addWeaponComponent(itemName, v)
                        end
                    end
                    sourceXPlayer.removeWeapon(itemName)
                    targetXPlayer.addWeapon(itemName, itemCount)

                    if weaponObject.ammo and itemCount > 0 then
                        local ammoLabel = weaponObject.ammo.label
                        sourceXPlayer.showNotification('vous avez donné 1x %s avec ~o~%sx %s à %s', weaponLabel, itemCount, ammoLabel,targetXPlayer.name)

                        targetXPlayer.showNotification('vous avez reçu 1x %s avec ~o~%sx %s de %s', weaponLabel, itemCount, ammoLabel,sourceXPlayer.name)
                    else
                        sourceXPlayer.showNotification('vous avez donné 1x %s à %s', weaponLabel, targetXPlayer.name)

                        targetXPlayer.showNotification('vous recevez 1x %s de %s', weaponLabel, sourceXPlayer.name)
                    end
                else
                    sourceXPlayer.showNotification('%s a déjà %s', targetXPlayer.name, weaponLabel)

                    targetXPlayer.showNotification('%s a tenté de vous donner %s, mais vous en aviez déjà un exemplaire', sourceXPlayer.name, weaponLabel)
                end
            end
        elseif type == 'item_ammo' then
            if sourceXPlayer.hasWeapon(itemName) then
                local weaponNum, weapon = sourceXPlayer.getWeapon(itemName)

                if targetXPlayer.hasWeapon(itemName) then
                    local _, weaponObject = ESX.GetWeapon(itemName)

                    if weaponObject.ammo then
                        local ammoLabel = weaponObject.ammo.label

                        if weapon.ammo >= itemCount then
                            sourceXPlayer.removeWeaponAmmo(itemName, itemCount)
                            targetXPlayer.addWeaponAmmo(itemName, itemCount)

                            sourceXPlayer.showNotification('vous avez donné ~o~%sx %s pour %s à %s', itemCount, ammoLabel, weapon.label,targetXPlayer.name)

                            targetXPlayer.showNotification('vous avez reçu ~o~%sx %s pour votre %s de %s', itemCount, ammoLabel,weapon.label, sourceXPlayer.name)
                        end
                    end
                else
                    sourceXPlayer.showNotification('%s n\'a pas cette arme', targetXPlayer.name)

                    targetXPlayer.showNotification('%s tente de vous donner des munitions pour %s, mais vous n\'en avez pas', sourceXPlayer.name, weapon.label)
                end
            end
        end
    end)

    RegisterNetEvent('esx:removeInventoryItem')
    AddEventHandler('esx:removeInventoryItem', function(type, itemName, itemCount)
        local playerId = source
        local xPlayer = ESX.GetPlayerFromId(source)

        if type == 'item_standard' then
            if itemCount == nil or itemCount < 1 then
                xPlayer.showNotification('action impossible, ~r~quantité invalide')
            else
                local xItem = xPlayer.getInventoryItem(itemName)

                if (itemCount > xItem.count or xItem.count < 1) then
                    xPlayer.showNotification('action impossible, ~r~quantité invalide')
                else
                    xPlayer.removeInventoryItem(itemName, itemCount)
                    local pickupLabel = ('%s [%s]'):format(xItem.label, itemCount)
                    ESX.CreatePickup('item_standard', itemName, itemCount, pickupLabel, playerId)
                    xPlayer.showNotification('vous avez jeté %sx %s', itemCount, xItem.label)
                end
            end
        elseif type == 'item_account' then
            if itemCount == nil or itemCount < 1 then
                xPlayer.showNotification('action impossible, ~r~montant invalide')
            else
                local account = xPlayer.getAccount(itemName)

                if (itemCount > account.money or account.money < 1) then
                    xPlayer.showNotification('action impossible, ~r~montant invalide')
                else
                    xPlayer.removeAccountMoney(itemName, itemCount)
                    local pickupLabel = ('%s [%s]'):format(account.label, '$%s', ESX.Math.GroupDigits(itemCount))

                    ESX.CreatePickup('item_account', itemName, itemCount, pickupLabel, playerId)

                    xPlayer.showNotification('vous avez jeté $%s %s', ESX.Math.GroupDigits(itemCount),string.lower(account.label))
                end
            end
        elseif type == 'item_weapon' then
            itemName = string.upper(itemName)

            if xPlayer.hasWeapon(itemName) then
                local _, weapon = xPlayer.getWeapon(itemName)
                local _, weaponObject = ESX.GetWeapon(itemName)
                local components, pickupLabel = ESX.Table.Clone(weapon.components)
                xPlayer.removeWeapon(itemName)

                if weaponObject.ammo and weapon.ammo > 0 then
                    local ammoLabel = weaponObject.ammo.label
                    pickupLabel = ('%s [%s %s]'):format(weapon.label, weapon.ammo, ammoLabel)
                    xPlayer.showNotification('vous avez jeté 1x %s avec ~o~%sx %s', weapon.label, weapon.ammo, ammoLabel)
                else
                    pickupLabel = ('%s'):format(weapon.label)
                    xPlayer.showNotification('vous avez jeté 1x %s', weapon.label)
                end

                ESX.CreatePickup('item_weapon', itemName, weapon.ammo, pickupLabel, playerId, components,
                    weapon.tintIndex)
            end
        end
    end)

    RegisterNetEvent('esx:useItem')
    AddEventHandler('esx:useItem', function(itemName)
        local xPlayer = ESX.GetPlayerFromId(source)
        local count = xPlayer.getInventoryItem(itemName).count

        if count > 0 then
            ESX.UseItem(source, itemName)
        else
            xPlayer.showNotification('action impossible')
        end
    end)

    RegisterNetEvent('esx:onPickup')
    AddEventHandler('esx:onPickup', function(pickupId)
        local pickup, xPlayer, success = Core.Pickups[pickupId], ESX.GetPlayerFromId(source)

        if pickup then
            if pickup.type == 'item_standard' then
                if xPlayer.canCarryItem(pickup.name, pickup.count) then
                    xPlayer.addInventoryItem(pickup.name, pickup.count)
                    success = true
                else
                    xPlayer.showNotification('vous ne pouvez pas ramasser ça votre inventaire est plein !')
                end
            elseif pickup.type == 'item_account' then
                success = true
                xPlayer.addAccountMoney(pickup.name, pickup.count)
            elseif pickup.type == 'item_weapon' then
                if xPlayer.hasWeapon(pickup.name) then
                    xPlayer.showNotification('vous portez déjà cette arme')
                else
                    success = true
                    xPlayer.addWeapon(pickup.name, pickup.count)
                    xPlayer.setWeaponTint(pickup.name, pickup.tintIndex)

                    for k, v in ipairs(pickup.components) do
                        xPlayer.addWeaponComponent(pickup.name, v)
                    end
                end
            end

            if success then
                Core.Pickups[pickupId] = nil
                TriggerClientEvent('esx:removePickup', -1, pickupId)
            end
        end
    end)
end

ESX.RegisterServerCallback('esx:getPlayerData', function(source, cb)
    local xPlayer = ESX.GetPlayerFromId(source)

    cb({
        identifier = xPlayer.identifier,
        accounts = xPlayer.getAccounts(),
        inventory = xPlayer.getInventory(),
        job = xPlayer.getJob(),
        crew = xPlayer.getCrew(),
        loadout = xPlayer.getLoadout(),
        money = xPlayer.getMoney(),
		position = xPlayer.getCoords(true)
    })
end)

ESX.RegisterServerCallback('esx:isUserAdmin', function(source, cb)
    cb(Core.IsPlayerAdmin(source))
end)

ESX.RegisterServerCallback('esx:getOtherPlayerData', function(source, cb, target)
    local xPlayer = ESX.GetPlayerFromId(target)

    cb({
        identifier = xPlayer.identifier,
        accounts = xPlayer.getAccounts(),
        inventory = xPlayer.getInventory(),
        job = xPlayer.getJob(),
        crew = xPlayer.getCrew(),
        loadout = xPlayer.getLoadout(),
        money = xPlayer.getMoney(),
		position = xPlayer.getCoords(true)
    })
end)

ESX.RegisterServerCallback('esx:getPlayerNames', function(source, cb, players)
    players[source] = nil

    for playerId, v in pairs(players) do
        local xPlayer = ESX.GetPlayerFromId(playerId)

        if xPlayer then
            players[playerId] = xPlayer.getName()
        else
            players[playerId] = nil
        end
    end

    cb(players)
end)

AddEventHandler('txAdmin:events:scheduledRestart', function(eventData)
    if eventData.secondsRemaining == 60 then
        CreateThread(function()
            Wait(50000)
            Core.SavePlayers()
        end)
    end
end)

RegisterNetEvent('esx:setDuty')
AddEventHandler('esx:setDuty', function(bool)
    local xPlayer = ESX.GetPlayerFromId(source)
    if xPlayer.job.onDuty == bool then
        return
    end

    if bool then
        xPlayer.setDuty(true)
        xPlayer.triggerEvent('esx:showNotification', 'Vous êtes maintenant en-service.')
    else
        xPlayer.setDuty(false)
        xPlayer.triggerEvent('esx:showNotification', 'Vous êtes maintenant hors-service.')
    end
    TriggerClientEvent('esx:setJob', xPlayer.source, xPlayer.job)
end)


if Citizen and Citizen.CreateThread then
    CreateThread = Citizen.CreateThread
end

Async = {}

function Async.parallel(tasks, cb)
    if #tasks == 0 then
        cb({})
        return
    end

    local remaining = #tasks
    local results = {}

    for i = 1, #tasks, 1 do
        CreateThread(function()
            tasks[i](function(result)
                table.insert(results, result)
                
                remaining = remaining - 1;

                if remaining == 0 then
                    cb(results)
                end
            end)
        end)
    end
end

function Async.parallelLimit(tasks, limit, cb)
    if #tasks == 0 then
        cb({})
        return
    end

    local remaining = #tasks
    local running = 0
    local queue, results = {}, {}

    for i=1, #tasks, 1 do
        table.insert(queue, tasks[i])
    end

    local function processQueue()
        if #queue == 0 then
            return
        end

        while running < limit and #queue > 0 do
            local task = table.remove(queue, 1)
            
            running = running + 1

            task(function(result)
                table.insert(results, result)
                
                remaining = remaining - 1;
                running = running - 1

                if remaining == 0 then
                    cb(results)
                end
            end)
        end

        CreateThread(processQueue)
    end

    processQueue()
end

function Async.series(tasks, cb)
    Async.parallelLimit(tasks, 1, cb)
end
