fx_version 'bodacious'
games { 'gta5' }

author 'ESX-Framework'
description 'Zombie System for ESX Legacy'
lua54 'yes'
version '2.0.0'

shared_script '@es_extended/imports.lua'

client_scripts {
	'config.lua',
	'client/main.lua',
	'client/loot.lua'
}

server_script {
	'server/main.lua'
}
