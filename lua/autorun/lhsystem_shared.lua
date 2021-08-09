
local grizzlySound = Sound("grizzly.wav")
local bandageSound = Sound("bandage.wav")
local splintSound = Sound("splint.wav")
local aiSound = Sound("ai.wav")
local milBandage = Sound("milbandage.wav")

cHealth = cHealth or {}

cHealth.cfg = {}

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

//cooldown to respawn after the player is fully dead
cHealth.cfg.respawnCooldown = 5

//Time a Player is unconcious
cHealth.cfg.UnconciousCooldown = 40

//If set to false, no Player gets the Deathscreen of this addon
cHealth.cfg.ActivateDeathScreen = false