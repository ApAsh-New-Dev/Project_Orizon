Config = {}
Config.Locale = 'fr'

Config.Accounts = {bank = 'banque',black_money = 'argent sale',money = 'espèces'}

Config.StartingAccountMoney 	= {bank = 500000000, black_money = 10000000, money = 1000000}

Config.EnableSocietyPayouts 	= false -- pay from the society account that the player is employed at? Requirement: esx_society
Config.EnableHud            	= false -- enable the default hud? Display current job and accounts (black, bank & cash)
Config.MaxWeight            	= 24   -- the max inventory weight without backpack
Config.PaycheckInterval         = 7 * 60000 -- how often to recieve pay checks in milliseconds
Config.EnableDebug              = false -- Use Debug options?
Config.EnableDefaultInventory   = false -- Display the default Inventory ( F2 )
Config.EnableWantedLevel    	= false -- Use Normal GTA wanted Level?
Config.EnablePVP                = true -- Allow Player to player combat
Config.NativeNotify             = true -- true = old esx notification
Config.DisableHealthRegen       = true

Config.Multichar                = false -- Enable support for esx_multicharacter
Config.Identity                 = false -- Select a characters identity data before they have loaded in (this happens by default with multichar)
Config.DistanceGive 			= 4.0 -- Max distance when giving items, weapons etc.
Config.OnDuty                   = false -- Default state of the on duty system
