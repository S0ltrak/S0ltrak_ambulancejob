ConfigTiscoJobs = {
    ambulance = {
        DrawDistance               = 10.0,
        ReviveReward               = 700,  
        SaveDeathStatus            = true, 
        LoadIpl                    = false,

        DistressBlip = {
            Sprite = 310,
            Color = 48,
            Scale = 1.0
        },

        EarlyRespawnTimer          = 60000 * 10,  -- time til respawn is available
        BleedoutTimer              = 60000 * 10, -- time til the player bleeds out

        EnablePlayerManagement     = false, -- Enable society managing (If you are using esx_society).

        ActiverTargetInteraction   = false, -- Permet de pouvoir réanimer et soigner des blessures via le target eye (phase de test!!!)

        RemoveWeaponsAfterRPDeath  = true,
        RemoveCashAfterRPDeath     = true,
        RemoveItemsAfterRPDeath    = true,

        -- Let the player pay for respawning early, only if he can afford it.
        EarlyRespawnFine           = false,
        EarlyRespawnFineAmount     = 5000,

        RespawnPoints = {
            {coords = vector3(316.25, -584.26, 42.38), heading = 352.36}, -- Central Los Santos
            {coords = vector3(1836.03, 3670.99, 34.28), heading = 296.06} -- Sandy Shores
        },

        Hospitals = {

            CentralLosSantos = {

                Blip = {
                    coords = vector3(294.07, -582.94, 43.18),
                    sprite = 61,
                    scale  = 0.6,
                    color  = 2
                },

                FastTravels = {
                    {
                        From = vector3(294.7, -1448.1, 29.0),
                        To = {coords = vector3(272.8, -1358.8, 23.5), heading = 0.0},
                        Marker = {type = 1, x = 2.0, y = 2.0, z = 0.5, r = 102, g = 0, b = 102, a = 100, rotate = false}
                    },

                    {
                        From = vector3(275.3, -1361, 23.5),
                        To = {coords = vector3(295.8, -1446.5, 28.9), heading = 0.0},
                        Marker = {type = 1, x = 2.0, y = 2.0, z = 0.5, r = 102, g = 0, b = 102, a = 100, rotate = false}
                    },

                    {
                        From = vector3(247.3, -1371.5, 23.5),
                        To = {coords = vector3(333.1, -1434.9, 45.5), heading = 138.6},
                        Marker = {type = 1, x = 1.5, y = 1.5, z = 0.5, r = 102, g = 0, b = 102, a = 100, rotate = false}
                    },

                    {
                        From = vector3(335.5, -1432.0, 45.50),
                        To = {coords = vector3(249.1, -1369.6, 23.5), heading = 0.0},
                        Marker = {type = 1, x = 2.0, y = 2.0, z = 0.5, r = 102, g = 0, b = 102, a = 100, rotate = false}
                    },

                    {
                        From = vector3(234.5, -1373.7, 20.9),
                        To = {coords = vector3(320.9, -1478.6, 28.8), heading = 0.0},
                        Marker = {type = 1, x = 1.5, y = 1.5, z = 1.0, r = 102, g = 0, b = 102, a = 100, rotate = false}
                    },

                    {
                        From = vector3(317.9, -1476.1, 28.9),
                        To = {coords = vector3(238.6, -1368.4, 23.5), heading = 0.0},
                        Marker = {type = 1, x = 1.5, y = 1.5, z = 1.0, r = 102, g = 0, b = 102, a = 100, rotate = false}
                    }
                },

                FastTravelsPrompt = {
                    {
                        From = vector3(237.4, -1373.8, 26.0),
                        To = {coords = vector3(251.9, -1363.3, 38.5), heading = 0.0},
                        Marker = {type = 1, x = 1.5, y = 1.5, z = 0.5, r = 102, g = 0, b = 102, a = 100, rotate = false},
                        Prompt = TranslateCap('fast_travel')
                    },

                    {
                        From = vector3(256.5, -1357.7, 36.0),
                        To = {coords = vector3(235.4, -1372.8, 26.3), heading = 0.0},
                        Marker = {type = 1, x = 1.5, y = 1.5, z = 0.5, r = 102, g = 0, b = 102, a = 100, rotate = false},
                        Prompt = TranslateCap('fast_travel')
                    }
                }

            }
        },

        Marker = {
            Distance = 9.0,
            Type = 25,
            SizeLargeur = 0.5,
            SizeEpaisseur = 0.5,
            SizeHauteur = 0.5,
            ColorR = 255, 
            ColorG = 255,
            ColorB = 255,
            Opacite = 175,
            Saute = false,
            Tourne = false,
        },

        Blip = vector3(294.07, -582.94, 43.18),

        Garage = {
            pos = {
                vector3(333.46, -588.77, 28.80-0.98)
            }
        },

        GarageHelico = {
            pos = {
                vector3(351.0, -587.92, 74.16-0.98)
            }
        },

        Vestiaire = {
            pos = {
                vector3(299.28, -597.75, 43.28-0.98)
            }
        },

        Acceuil = {
            pos = {
                vector3(312.16, -592.68, 43.28-0.98)
            }
        },

        Ascenseur = {
            pos = {
                vector3(344.56, -586.24, 28.80-0.98), -- Etage 0 [Accueil]
                vector3(332.02, -595.58, 43.28-0.98), -- Etage 1 [Direction]
                vector3(338.94, -583.92, 74.16-0.98), -- Etage 2 [Héliport] 
            }
        },

        VehiculesAmbulance = {
            {buttoname = "Ambulance", rightlabel = "→→→", spawnname = "ambulance", spawnzone = vector3(334.04, -573.5, 28.80), headingspawn = 335.36},
        },

        HelicoAmbulance = {
            {buttonameheli = "Hélicoptère", rightlabel = "→→→", spawnnameheli = "supervolito", spawnzoneheli = vector3(351.0, -587.92, 74.16), headingspawnheli = 22.00},
        },
    }
}