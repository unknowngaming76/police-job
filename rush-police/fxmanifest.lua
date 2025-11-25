fx_version 'cerulean'
game 'gta5'

name "Brazzers Police Job"
author "Brazzers Development | MannyOnBrazzers#6826"
version "1.0.0"

lua54 'yes'

client_scripts {
	'client/*.lua',
}

server_scripts {
	'@oxmysql/lib/MySQL.lua',
	'server/*.lua'
}

shared_scripts {
    'config.lua',
	'@ox_lib/init.lua',
}