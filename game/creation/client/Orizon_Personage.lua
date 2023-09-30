---@version 0.0.1 created at [28/09/2023 10:27]-[By ApAsh]-[Creation de Personnage - Orizon]

local Creation = {"--","--","--",}, 
local Main = RageUI.CreateMenu("Orizon", "~b~Création de personnage")
    Main.Closable = false RageUI.Visible(Main, not RageUI.Visible(Main))
    Main.Closed = function() end

    function AMA.Orizon:CreationPerso() 
        if AMA.Orizon then  AMA.Orizon = false RageUI.Visible(Main, false) return else AMA.Orizon = true RageUI.Visible(Main, true)

    CreateThread(function() while AMA.Orizon do RageUI.IsVisible(Main,function()
        RageUI.Line() 
        RageUI.Button('   ~o~>~s~Prénom', "~b~--~s~~o~>~s~[~b~ex~s~]  : ~o~"..Prenom, {RightLabel = LastName }, true, {
            onSelected = function() --[[texte ici]] end,})  
    end, function() end) Wait(0) end end) end end

RegisterCommand('register', function() AMA.Orizon:CreationPerso() end)
