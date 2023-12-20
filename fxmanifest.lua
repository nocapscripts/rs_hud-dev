fx_version 'cerulean'
game 'gta5'
lua54 'yes'


shared_scripts {
    '@pma-voice/shared.lua',
    '@es_extended/imports.lua',
    'config.lua'
}

client_scripts {
    'client.lua',
    
}

server_scripts {
    '@oxmysql/lib/MySQL.lua',
    'server.lua'
}



ui_page 'web/index.html'

files {
    'web/*',
    'web/img/*.svg',
    'web/img/*.png',
    'web/index.html',
    'web/css.css',
    'web/app.js',
}