
local grizzlySound = Sound("grizzly.wav")
local bandageSound = Sound("bandage.wav")
local splintSound = Sound("splint.wav")
local aiSound = Sound("ai.wav")
local milBandage = Sound("milbandage.wav")

cHealth = cHealth or {}

cHealth.cfg = cHealth.cfg or {}

cHealth.cfg.Bones = {

    [1] = {Amount = 35, isBroken = false, isBleeding = false, isHeavyBleed = false, Name = "Head"}, --Header
    [2] = {Amount = 85, isBroken = false, isBleeding = false, isHeavyBleed = false, Name = "Chest"}, --Chest
    [3] = {Amount = 70, isBroken = false, isBleeding = false, isHeavyBleed = false, Name = "Stomach"}, --Stomach
    [4] = {Amount = 60, isBroken = false, isBleeding = false, isHeavyBleed = false, Name = "Left Arm"}, --LEft arm
    [5] = {Amount = 60, isBroken = false, isBleeding = false, isHeavyBleed = false, Name = "Right Arm"}, -- Right Arm
    [6] = {Amount = 65, isBroken = false, isBleeding = false, isHeavyBleed = false, Name = "Left Leg"}, -- Left Legt
    [7] = {Amount = 65, isBroken = false, isBleeding = false, isHeavyBleed = false, Name = "Right Leg"}, -- Right Leg

}

--[[Parameters:

Name : Item Name
Points : HealingPoints
Heal --
    Maxpoints : Max points being healed at a time
    bone : broken Bones (if set to true)
    lightBleed : lightbleeds (if set to true)
    heavyBleed : Heavy Bleeds (if set to true)
    blackout : Limb at 0 HP (if set to true)
Model : Modelpath
Description : Description underneath the Model and Name shown in "K"-Menu
Sound : Sound to be played when healing a limb
]]
cHealth.cfg.Meds = {
["Grizzly Medbag"] = {Name = "Grizzly Medbag", --Name
            Points = 1800, --Healingpoints
            Heal = {Maxpoints = 100, bone = true, lightBleed = true, heavyBleed = true}, 
            Model = "models/carlsmei/escapefromtarkov/medical/grizzly.mdl", 
            Description = "Fixes broken Bones, Light Bleeds, Heavy Bleeds and heals 100 HP",
            Sound = grizzlySound},

["IFAK Medkit"] = {Name = "IFAK Medkit", 
            Points = 400, 
            Heal = {Maxpoints = 75, lightBleed = true},
            Model = "models/carlsmei/escapefromtarkov/medical/ifak.mdl", 
            Description = "Fixes light Bleeds and heals 75 HP",
            Sound = grizzlySound },

["Salewa Medkit"] = {Name = "Salewa Medkit",
            Points = 800,
            Heal = {Maxpoints = 100, heavyBleed = true},
            Model = "models/carlsmei/escapefromtarkov/medical/salewa.mdl",
            Description = "Fixes light Bleeds, heavy Bleeds and heals 100 HP",
            Sound = grizzlySound},

["AI-2"] = { Name = "AI-2",
            Points = 100,
            Heal = {Maxpoints = 50},
            Model = "models/carlsmei/escapefromtarkov/medical/medkit.mdl",
            Description = "Heals 50 HP",
            Sound = aiSound},
["CAR-Medkit"] = { Name = "CAR-Medkit",
            Points = 250,
            Heal = {Maxpoints = 60, lightBleed = true},
            Model = "models/carlsmei/escapefromtarkov/medical/automedkit.mdl",
            Description = "Fixes light bleeds and heals 60 HP",
            Sound = grizzlySound},
["CMS"] = { Name = "CMS",
            Points = 5,
            Heal = {blackout = true, Maxpoints = 1},
            Model = "models/carlsmei/escapefromtarkov/medical/core_medical_surgical_kit.mdl",
            Description = "Fixes Blackout Limb",
            Sound = ""},
["Splint"] = {Name = "Splint",
            Points = 1,
            Heal = {bone = true, Maxpoints = 0},
            Model = "models/carlsmei/escapefromtarkov/medical/alusplint.mdl",
            Description = "Fixes broken bones",
            Sound = splintSound},
["Bandage"] = { Name = "Bandage",
            Points = 1,
            Heal = {bandageLightBleed = true, Maxpoints = 0},
            Model = "models/carlsmei/escapefromtarkov/medical/bandage_med.mdl",
            Description = "Fixes light bleeds",
            Sound = bandageSound},
["Military Bandage"] = {Name = "Military Bandage",
            Points = 1,
            Heal = {bandageHeavyBleed = true, Maxpoints = 0},
            Model = "models/carlsmei/escapefromtarkov/medical/bandage_army.mdl",
            Description = "Fixes heavy Bleed",
            Sound = milBandage},
["Surv12 Surgical Kit"] = { Name = "Surv12 Surgical Kit",
            Points = 15,
            Heal = {blackout = true, Maxpoints = 1},
            Model = "models/carlsmei/escapefromtarkov/medical/survival_first_aid_rollup_kit.mdl",
            Description = "Fixes Blackout Limb",
            Sound = ""},

}

cHealth.cfg.Armor = {
    ["Killa"] = {Name = "Killa",
            Model = "models/player/armor_6b13_killa/6b13_killa.mdl",
            upOff = -19,
            forOff = 1,
            rightOff = 5,
            scale = 1.03,
            ArmorClass = 6,
            Durability = 60,
            Drain = 2,
            Torso = true,
            Stomach = true,
        },
    ["Press Vest"] = {Name = "Press Vest",
            Model = "models/player/armor_zhuk3/beetle3.mdl",
            upOff = -15,
            forOff = 1,
            rightOff = 3,
            scale = 1.04,
            ArmorClass = 6,
            Durability = 50,
            Drain = 1.5,
            Torso = true,
            Stomach = true,
        },
    ["MF-UNTAR"] = {Name = "MF-UNTAR",
            Model = "models/player/armor_un/un.mdl",
            upOff = -13.5,
            forOff = 1,
            rightOff = 3,
            scale = 1.04,
            ArmorClass = 3,
            Durability = 50,
            Drain = 1.3,
            Torso = true,
            Stomach = true,
        },
    ["Gzhel-K"] = {Name = "Gzhel-K",
            Model = "models/player/armor_gjel/gjel.mdl",
            upOff = -14,
            forOff = 0.6,
            rightOff = 3,
            ArmorClass = 5,
            Durability = 65, 
            Drain = 1.9,
            Torso = true,
            Stomach = true,
        },
    ["6B13"] = {Name = "6B13",
            Model = "models/player/armor_6b13_digital/6b13.mdl",
            upOff = -19,
            forOff = 1.8,
            rightOff = 5,
            scale = 1.01,
            ArmorClass = 4,
            Drain = 1.3,
            Torso = true,
            Stomach = true,
        },
    ["PACA"] = {Name = "PACA",
            Model = "models/player/armor_paca/paca.mdl",
            upOff = -11,
            forOff = 1.2,
            rightOff = 5,
            ArmorClass = 3,
            Drain = 1.1,
            Torso = true,
        },
    ["USEC Trooper"] = {Name = "USEC Trooper",
            Model = "models/player/armor_trooper/trooper.mdl",
            upOff = -12,
            forOff = 0.9,
            rightOff = 5,
            ArmorClass = 4,
            Drain = 1.5,
            Torso = true,
        },
    ["Module 3M"] = {Name = "Module 3M",
            Model = "models/player/armor_module3m/module3m.mdl",
            upOff = -14.5,
            forOff = 0.9,
            rightOff = 3,
            ArmorClass = 2,
            Drain = 1,
            Torso = true,
            Stomach = true,
        },
    ["Zhuk 6a"] = {Name = "Zhuk 6a",
            Model = "models/player/armor_zhuk6a/beetle6a.mdl",
            upOff = -15,
            forOff = 0.9,
            rightOff = 3,
            ArmorClass = 6,
            Drain = 2.2,
            Torso = true,
        },
    ["6B5 Flora"] = {Name = "6B5 Flora",
            Model = "models/player/armor_6b5_flora/6b5.mdl",
            upOff = -18,
            forOff = 1,
            rightOff = 3,
            ArmorClass = 4,
            Drain = 1.25,
            Torso = true,
            Stomach = true,
        },   
}

//cooldown to respawn after the player is fully dead
cHealth.cfg.respawnCooldown = 5

//Time a Player is unconcious
cHealth.cfg.UnconciousCooldown = 40

//If set to false, no Player gets the Deathscreen of this addon
cHealth.cfg.ActivateDeathScreen = false

cHealth.cfg.DrawArmor = true