fx_version 'cerulean'

game 'gta5'
author 'TH'
description 'TH - Police Radar'
version '1.10.2'
lua54 'yes'

shared_scripts {
    '@ox_lib/init.lua',
    '@es_extended/imports.lua',
    'config.lua'
}

client_scripts {
    'client.lua'
}

ui_page { 'ui/index.html' }

files { 'ui/index.html', 'ui/index.css', 'ui/index.js','ui/debounce.min.js', 'ui/img/*'}
