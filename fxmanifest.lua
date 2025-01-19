fx_version "cerulean"
game "gta5"

author "S0ltrak"


shared_scripts {
    "@ox_lib/init.lua",
    "shared/initESX.lua",

    "shared/config.lua",

}



server_scripts {
    "@oxmysql/lib/MySQL.lua",

    "server/sv_ambulance_main.lua",

}



client_scripts {
    "RageUI/RMenu.lua",
    "RageUI/menu/RageUI.lua",
    "RageUI/menu/Menu.lua",
    "RageUI/menu/MenuController.lua",
    "RageUI/components/*.lua",
    "RageUI/menu/elements/*.lua",
    "RageUI/menu/items/*.lua",
    "RageUI/menu/panels/*.lua",
    "RageUI/menu/windows/*.lua",

    "client/cl_ambulance_acceuil.lua",
    "client/cl_ambulance_ascenseur.lua",
    "client/cl_ambulance_bed.lua",
    "client/cl_ambulance_garage.lua",
    "client/cl_ambulance_garagehelico.lua",
    "client/cl_ambulance_main.lua",
    "client/cl_ambulance_menujob.lua",
    "client/cl_ambulance_wheelchair.lua",


}


dependencies {
    "ox_lib",
    "es_extended",
    "ox_target",
    "esx_skin",
}