fx_version 'adamant'

game 'gta5'

description 'ES Extended'

lua54 'yes'
version '1.7.5'

shared_scripts {
	'framework/shared/locale.lua',
	'framework/shared/fr.lua',
	'framework/shared/config.lua',
	'framework/shared/config.weapons.lua',
	'framework/common/interval.lua'
}

server_scripts {
	'@oxmysql/lib/MySQL.lua',
	'framework/server/common.lua',
	'framework/server/player.lua',
	--'framework/server/overrides/*.lua',
	'framework/server/functions.lua',
	'framework/server/onesync.lua',
	'framework/server/paycheck.lua',
	'framework/server/main.lua',
	'framework/server/commands.lua',
	'framework/common/math.lua',
	'framework/common/table.lua',
	'framework/common/functions.lua'
}

client_scripts {
	--"rage/ckient/RMenu.lua",
    --"rage/ckient/menu/RageUI.lua",
    --"rage/ckient/menu/Menu.lua",
    --"rage/ckient/menu/MenuController.lua",
    --"rage/ckient/components/*.lua",
    --"rage/ckient/menu/elements/*.lua",
    --"rage/ckient/menu/items/*.lua",
    --"rage/ckient/menu/panels/*.lua",
    --"rage/ckient/menu/windows/*.lua",
	'framework/client/common.lua',
	'framework/client/functions.lua',
	'framework/client/wrapper.lua',
	'framework/client/main.lua',
	'framework/client/death.lua',
	'framework/client/scaleform.lua',
	'framework/client/streaming.lua',
	'framework/common/math.lua',
	'framework/common/table.lua',
	'framework/common/functions.lua',
	'rage/libs/client.lua'
}

ui_page {
	'html/ui.html'
}

files {
	"imports.lua",
}

files {
	--'framework/imports.lua',
	'framework/shared/locale.js',
	'html/ui.html',
	'html/css/app.css',
	'html/js/mustache.min.js',
	'html/js/wrapper.js',
	'html/js/app.js',
	'html/fonts/pdown.ttf',
	'html/fonts/bankgothic.ttf',
	'html/img/accounts/bank.png',
	'html/img/accounts/black_money.png',
	'html/img/accounts/money.png'
}

dependencies {
	'oxmysql',
	--'spawnmanager',
}


