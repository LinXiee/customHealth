util.AddNetworkString("chMenu:OpenMenu")
util.AddNetworkString("chMenu:OpenedMenu")
util.AddNetworkString("chMenu:ClosedMenu")
util.AddNetworkString("chMenu:Refresh")
util.AddNetworkString("chMenu:RefreshMeds")
util.AddNetworkString("chMenu:closeMenu")
util.AddNetworkString("chMenu:ButDown")

util.AddNetworkString("chHealth:HealLimb")
util.AddNetworkString("chHealth:IsDead")
util.AddNetworkString("chHealth:respawnScreen")
util.AddNetworkString("chHealth:IsRagdolled")

util.AddNetworkString("chSettings:OpenSettings")

util.AddNetworkString("chArmor:AddArmor")
util.AddNetworkString("chArmor:RemovePly")
util.AddNetworkString("chArmor:RemoveDeath")
util.AddNetworkString("chArmor:PlyReady")
util.AddNetworkString("chArmor:PlyConnect")

local plyMetaTable = FindMetaTable("Entity")

function plyMetaTable:AddMedkit(Medkit)

    if !self:IsPlayer() then return end

    self.cHealthMeds[#self.cHealthMeds+1] = table.Copy(cHealth.cfg.Meds[Medkit])

end

function plyMetaTable:chFullHeal()

    if !self:IsPlayer() then return end

    self.chCustomHealth = table.Copy(cHealth.cfg.Bones)

end

function plyMetaTable:chKill()

    self:TakeDamage(999, nil, nil)

end

local plyWithArmor = {}

function plyMetaTable:AddArmor(Armor)

    if !self:IsPlayer() or !IsValid(self) then return end
    if !self:Alive() then return end 
    if !cHealth.cfg.Armor[Armor] then return end
    if !table.IsEmpty(self.chArmor) then return end

    self.chArmor = table.Copy(cHealth.cfg.Armor[Armor])

    if cHealth.cfg.DrawArmor then 

        net.Start("chArmor:AddArmor")
        net.WriteEntity(self)
        net.WriteString(self.chArmor.Name)
        net.WriteBool(true)
        net.Broadcast()

        plyWithArmor[self:SteamID()] = self.chArmor.Model

    end

end

local plyWithHelmet = {}

function plyMetaTable:AddHelmet(Helmet)

    if !self:IsPlayer() or !IsValid(self) then return end
    if !self:Alive() then return end
    if !cHealth.cfg.Helmet[Helmet] then return end
    if !table.IsEmpty(self.chHelmet) then return end

    self.chHelmet = table.Copy(cHealth.cfg.Helmet[Helmet])

    if cHealth.cfg.DrawArmor then

        net.Start("chArmor:AddArmor")
        net.WriteEntity(self)
        net.WriteString(self.chHelmet.Name)
        net.WriteBool(false)
        net.Broadcast()

        plyWithHelmet[self:SteamID()] = self.chHelmet.Model

    end

end

local function ragdollPlayer( ply )

    if ply.ragdoll then return end

    if ply:InVehicle() then
        local vehicle = ply:GetParent()
        ply:ExitVehicle()
    end


    local ragdoll = ents.Create("prop_ragdoll")
    ragdoll.ragdolledPly = ply

    ragdoll:SetPos(ply:GetPos())
    local velocity = ply:GetVelocity()
    ragdoll:SetAngles(ply:GetAngles())
    ragdoll:SetModel(ply:GetModel())
    ragdoll:Spawn()
    ragdoll:Activate()
    ply:SetParent(ragdoll)
    local j = 1
    while true do
        local phys_obj = ragdoll:GetPhysicsObjectNum(j)
        if phys_obj then
            phys_obj:SetVelocity(velocity)
            j = j + 1
        else
            break
        end
    end

    ply:Spectate(OBS_MODE_CHASE)
    ply:SpectateEntity(ragdoll)
    ply:StripWeapons()

    if ULib then

        ragdoll:DisallowDeleting( true, function( old, new )
            if ply:IsValid() then ply.ragdoll = new end
        end )

	ply:DisallowSpawning( true )

    end

	ply.ragdoll = ragdoll

    if cHealth.cfg.ActivateDeathscreen then
        net.Start("chHealth:IsRagdolled")
        net.WriteUInt(cHealth.cfg.UnconciousCooldown, 8)
        net.Send(ply)
    end

end

local function unragdollPlayer(v)

    if !v:Alive() then return end

    if ULib then 
        v:DisallowSpawning(false)
    end
    
    v:SetParent()

    v:UnSpectate()

    local ragdoll = v.ragdoll
    v.ragdoll = nil 

    if not ragdoll:IsValid() then -- Something must have removed it, just spawn
		v:Spawn()

	else
		local pos = ragdoll:GetPos()
		pos.z = pos.z + 10 -- So they don't end up in the ground
    
        local ragdolledPlayer = ragdoll.ragdolledPly    
        v.oldStats = {}
        v.oldStats.Health = ragdolledPlayer.chCustomHealth
        v.oldStats.bleedMulti = ragdolledPlayer.BleedMultiplier
        v.oldStats.meds = ragdolledPlayer.cHealthMeds
        v.oldStats.chArmor = ragdolledPlayer.chArmor

		v:Spawn()
        v:SetPos( pos )
		v:SetVelocity( ragdoll:GetVelocity() )
		local yaw = ragdoll:GetAngles().yaw
		v:SetAngles( Angle( 0, yaw, 0 ) )

        if ULib then
		    ragdoll:DisallowDeleting( false )
        end

		ragdoll:Remove()
	end

end

local function respawnPlayer(ply) 

    if ply.ragdoll then
        
    if ULib then
       ply:DisallowSpawning(false)
    end

    ply:SetParent()

    ply:UnSpectate()

    local ragdoll = ply.ragdoll 

    if ULib then
        ragdoll:DisallowDeleting(false)
    end
    end

    ply:Respawn()
end

function plyMetaTable:chRespawn()

    if !IsValid(self) and !self:IsAlive() then return end

    respawnPlayer(self)

end

concommand.Add("ragdoll", function(ply) 

    ragdollPlayer(ply)

end)

concommand.Add("unragdoll", function(ply)

    unragdollPlayer(ply)
    
end)


concommand.Add("chKill", function(ply) 

    ply:chKill()

end)

local function ApplyHeal(ply, Medkit, Limb)

    if !IsValid(ply.openedMenuFor) then ply:ChatPrint("This Player doesn't exist anymore") return end

    local selectedPly = ply.openedMenuFor

    local selectedMeds = ply.cHealthMeds[Medkit]
    local heals = selectedMeds.Heal

    local selectedLimb = ply.openedMenuFor.chCustomHealth[Limb]

    local MaxHealPossibile = cHealth.cfg.Bones[Limb].Amount - selectedLimb.Amount --Missing HP on Bone

    if (selectedMeds.Points < MaxHealPossibile) and selectedMeds.Points > 0 then --If selected Meds has enough Points to Heal
        MaxHealPossibile = selectedMeds.Points -- Set Possible Heal to Points left
    end

    if MaxHealPossible == cHealth.cfg.Bones[Limb].Amount or (selectedLimb.Amount == 0 and !heals.blackout) or selectedLimb.Amount == cHealth.cfg.Bones[Limb].Amount then -- if limb is full or fully to 0, dont heal
        
    elseif heals.blackout and selectedLimb.Amount == 0 then
        
        selectedLimb.Amount = 1
        selectedMeds.Points = selectedMeds.Points - 1
        
    elseif heals.Maxpoints < MaxHealPossibile and selectedLimb.Amount != 0 then 
        
        selectedLimb.Amount = selectedLimb.Amount + heals.Maxpoints
        selectedMeds.Points = math.Round(selectedMeds.Points - heals.Maxpoints, 0)

    elseif heals.Maxpoints > MaxHealPossibile and selectedLimb.Amount != 0 then
        
        selectedLimb.Amount = selectedLimb.Amount + MaxHealPossibile
        selectedMeds.Points = math.Round(selectedMeds.Points - MaxHealPossibile, 0)

    end

    if (selectedLimb.isBroken or selectedLimb.isBleeding or selectedLimb.isHeavyBleed or selectedLimb.Amount == 0) then
    
        if selectedLimb.isBroken then
            if heals.bone and selectedMeds.Points >= 150 then
                selectedLimb.isBroken = false 
                selectedMeds.Points = selectedMeds.Points - 150
            end

            if Limb == 6 or Limb == 7 then
                
                ply:SetRunSpeed(ply:GetRunSpeed() / 0.85)
                ply:SetWalkSpeed(ply:GetWalkSpeed() / 0.85)
                ply:SetSlowWalkSpeed(ply:GetSlowWalkSpeed() / 0.95)

            end

        end

        if selectedLimb.isBleeding then
            if (heals.lightBleed and selectedMeds.Points >= 50) then
                selectedLimb.isBleeding = false 
                selectedMeds.Points = selectedMeds.Points - 50
                ply.openedMenuFor.BleedMultiplier = ply.openedMenuFor.BleedMultiplier / 1.1
            end
            if heals.bandageLightBleed then
                selectedLimb.isBleeding = false 
                selectedMeds.Points = selectedMeds.Points - 1
                ply.openedMenuFor.BleedMultiplier = ply.openedMenuFor.BleedMultiplier / 1.1
            end

        end

        if selectedLimb.isHeavyBleed then
            if heals.heavyBleed and selectedMeds.Points >= 50 then
                selectedLimb.isHeavyBleed = false 
                selectedMeds.Points = selectedMeds.Points - 100
                ply.openedMenuFor.BleedMultiplier = ply.openedMenuFor.BleedMultiplier / 1.3
            end
            if heals.bandageHeavyBleed then
                selectedLimb.isHeavyBleed = false 
                selectedMeds.Points = selectedMeds.Points - 1
                ply.openedMenuFor.BleedMultiplier = ply.openedMenuFor.BleedMultiplier / 1.3
            end
        end

    end

    if selectedPly.ragdoll then
        
        if selectedPly.chCustomHealth[1].Amount == cHealth.cfg.Bones[1].Amount and selectedPly.chCustomHealth[2].Amount == cHealth.cfg.Bones[2].Amount then
            unragdollPlayer(selectedPly)
        end

    end

    if selectedMeds.Points <= 0 then
        table.remove(ply.cHealthMeds, Medkit) 
    end

    net.Start("chMenu:Refresh")

    local healthdata = util.Compress(util.TableToJSON(ply.openedMenuFor.chCustomHealth))

    net.WriteData(healthdata, #healthdata)
    local plyRefresh = {
    }

    if ply.menuOpen then
        plyRefresh[#plyRefresh+1] = ply
    end
    if ply.openedMenuFor.menuOpen then
        plyRefresh[#plyRefresh+1] = ply.openedMenuFor
    end
    net.Send(plyRefresh)

    local medsdata = util.Compress(util.TableToJSON(ply.cHealthMeds))

    net.Start("chMenu:RefreshMeds")
    net.WriteData(medsdata, #medsdata)
    net.Send(ply)

end

local function BleedEffect(ply)
        
        timer.Create(ply:SteamID().."bleedEffect", 4, 1, function() 
        
            if !ply:IsValid() then return end
            if ply.BleedMultiplier <= 1 then return end
            ply:TakeDamage(1 * ply.BleedMultiplier, nil, "Bleed")
            BleedEffect(ply)
        
        end)

end

local function ApplyDamage(ply, dmg, bone)

    if (bone == 2 or bone == 3) and ply.chArmor then 
        local armor = ply.chArmor
        if (bone == 2 and armor.Torso) or (bone == 3 and armor.Stomach) and armor.Durability and armor.Durability > 0 then
            dmg = dmg / (ply.chArmor.ArmorClass / 10 + 1)
            ply.chArmor.Durability = math.Round(ply.chArmor.Durability - (dmg / armor.Drain), 2)
            if armor.Durability <= 0 then 
                armor.Durabliity = 0
                ply.chArmor = {}
                if cHealth.cfg.DrawArmor then 
                    net.Start("chArmor:RemovePly")
                    net.WriteEntity(ply)
                    net.WriteBool(true)
                    net.Broadcast()
                end
            end
        end
    end

    if bone == 1 and ply.chHelmet then 

        local helmet = ply.chHelmet
        if helmet.Durability and helmet.Durability > 0 then
            dmg = dmg / (ply.chHelmet.ArmorClass / 10 + 1)
            ply.chHelmet.Durability = math.Round(ply.chHelmet.Durability - (dmg / helmet.Drain), 2)
            if helmet.Durability <= 0 then
                helmet.Durability = 0
                ply.chHelmet = {}

                if cHealth.cfg.DrawArmor then 
                    net.Start("chArmor:RemovePly")
                    net.WriteEntity(ply)
                    net.WriteBool(false)
                    net.Broadcast()
                end
            end
        end
    end

    ply.chCustomHealth[bone].Amount = math.Round(ply.chCustomHealth[bone].Amount - dmg,0)

    if ply.chCustomHealth[bone].Amount < 0 then 
        ply.chCustomHealth[bone].Amount = 0
    end

    if ply.chCustomHealth[bone].Amount == 0 then
        
        for k,v in ipairs(ply.chCustomHealth) do
            
            if ply.chCustomHealth[k].Amount > 0 then
                ply.chCustomHealth[k].Amount = math.Round(ply.chCustomHealth[k].Amount - dmg/7,0)
            end
        end
    end

    if bone != 1 and bone != 2 and bone !=3 then
        
        local rndmNumber = math.Rand(15,25)

        if dmg > rndmNumber and !ply.chCustomHealth[bone].isBroken then

            ply.chCustomHealth[bone].isBroken = true

            if bone == 6 then
                
                ply:SetRunSpeed(ply:GetRunSpeed() * 0.85)
                ply:SetWalkSpeed(ply:GetWalkSpeed() * 0.85)
                ply:SetSlowWalkSpeed(ply:GetSlowWalkSpeed() * 0.95)

            elseif bone == 7 then
                
                ply:SetRunSpeed(ply:GetRunSpeed() * 0.85)
                ply:SetWalkSpeed(ply:GetWalkSpeed() * 0.85)
                ply:SetSlowWalkSpeed(ply:GetSlowWalkSpeed() * 0.95)

            end

        end

    end

    local randomBleed = math.Rand(14, 25)

    if dmg > randomBleed then
        
        if !ply.chCustomHealth[bone].isBleeding and !ply.chCustomHealth[bone].isHeavyBleed then 
            ply.chCustomHealth[bone].isHeavyBleed = true 
            ply.BleedMultiplier = ply.BleedMultiplier * 1.3
        end
        
    
    elseif dmg > randomBleed/2 then
        
        if !ply.chCustomHealth[bone].isHeavyBleed and !ply.chCustomHealth[bone].isBleeding then  
            ply.chCustomHealth[bone].isBleeding = true
            ply.BleedMultiplier = ply.BleedMultiplier * 1.1
        end
        
    end 

    if ply.chCustomHealth[1].Amount <= 0 or ply.chCustomHealth[2].Amount <= 0 then
        
        if ply:Alive() and !ply.ragdoll and !ply.ragdolledPly then
            ragdollPlayer(ply)
            timer.Create(ply:SteamID() .. "chrespawntimer", cHealth.cfg.UnconciousCooldown, 1, function()
                if ply.ragdoll then
                    ply:Kill()
                end 
            end)
        end

    end
end

local function CheckVars(ent)

    if ent.menuOpen then

        local healthdata = util.Compress(util.TableToJSON(ent.openedMenuFor.chCustomHealth))
        local healthlen = #healthdata
        
        net.Start("chMenu:Refresh")
        net.WriteData(healthdata, #healthdata)
        net.Send(ent)
    end
end

hook.Add("PlayerSpawn", "chSetHealth", function(ply, trans)

    if ply.oldStats then 
        ply.chCustomHealth = table.Copy(ply.oldStats.Health)
        ply.BleedMultiplier = ply.oldStats.bleedMulti
        ply.cHealthMeds = table.Copy(ply.oldStats.meds)
        ply.chArmor = table.Copy(ply.oldStats.chArmor)
        ply.oldStats = nil
    else 
        ply.chCustomHealth = table.Copy(cHealth.cfg.Bones)
        ply.BleedMultiplier = 1
        ply.cHealthMeds = {}
        ply.chRespawnTimer = cHealth.cfg.respawnCooldown
        ply.chArmor = {}
        ply.chHelmet = {}
    end

    if ply.ragdoll then
        ply.ragdoll:Remove()
        ply.ragdoll = nil
    end

    if ply.menuOnply then
        
        net.Start("chMenu:closeMenu")
        net.Send(ply.menuOnply)
        ply.menuOnply:RemoveAllPlayers()

    else 

        ply.menuOnply = RecipientFilter()

    end


    ply.chRespawnTimer = cHealth.cfg.respawnCooldown

    net.Start("chHealth:respawnScreen")
    net.Send(ply)

    if ply.ragdoll then
        unragdollPlayer(ply)
    end

end)


net.Receive("chMenu:ButDown", function(len, ply)

    if ply.openedMenu then return end
    if ply.ragdoll then return end

    local inFront = ply:GetEyeTrace().Entity

    if inFront:IsPlayer() and inFront:GetPos():DistToSqr(ply:GetPos()) < 75^2 then 

        local healthdata = util.Compress(util.TableToJSON(inFront.chCustomHealth))
        local medsdata = util.Compress(util.TableToJSON(ply.cHealthMeds))
        local armorData = util.Compress(util.TableToJSON(ply.chArmor))

        local healthlen = #healthdata
        local medslen = #medsdata
        local armorlen = #armorData

        net.Start("chMenu:OpenMenu")

        net.WriteUInt(healthlen, 16)
        net.WriteData(healthdata, healthlen)
        net.WriteUInt(medslen, 16)
        net.WriteData(medsdata, medslen)
        net.WriteUInt(armorlen, 16)
        net.WriteData(armorData, armorlen)
        net.WriteString(inFront:GetName())
        net.WriteString(inFront:GetModel())
        net.Send(ply)

        ply.openedMenuFor = inFront
        inFront.menuOnply:AddPlayer(ply)

    elseif inFront:IsRagdoll() and inFront:GetPos():DistToSqr(ply:GetPos()) < 75^2 then

        local healthdata = util.Compress(util.TableToJSON(inFront.ragdolledPly.chCustomHealth))
        local medsdata = util.Compress(util.TableToJSON(ply.cHealthMeds))
        local armordata = util.Compress(util.TableToJSON(inFront.ragdolledPly.chArmor))

        local healthlen = #healthdata
        local medslen = #medsdata
        local armorlen = #armordata
        
        net.Start("chMenu:OpenMenu")
        net.WriteUInt(healthlen, 16)
        net.WriteData(healthdata, healthlen)
        net.WriteUInt(medslen, 16)
        net.WriteData(medsdata, medslen)
        net.WriteUInt(armorlen, 16)
        net.WriteData(armordata, armorlen)
        net.WriteString(inFront.ragdolledPly:GetName())
        net.WriteString(inFront:GetModel())
        net.Send(ply)

        ply.openedMenuFor = inFront.ragdolledPly
        ply.openedMenuFor.menuOnply:AddPlayer(ply)

    else

        local healthdata = util.Compress(util.TableToJSON(ply.chCustomHealth))
        local medsdata = util.Compress(util.TableToJSON(ply.cHealthMeds))
        local armordata = util.Compress(util.TableToJSON(ply.chArmor))

        local healthlen = #healthdata
        local medslen = #medsdata
        local armorlen = #armordata

        net.Start("chMenu:OpenMenu")
        net.WriteUInt(healthlen, 16)
        net.WriteData(healthdata, healthlen)
        net.WriteUInt(medslen, 16)
        net.WriteData(medsdata, medslen)
        net.WriteUInt(armorlen, 16)
        net.WriteData(armordata, armorlen)
        net.WriteString(ply:GetName())
        net.WriteString(ply:GetModel())
        net.Send(ply)

        ply.openedMenuFor = ply
        ply.openedMenuFor.menuOnply:AddPlayer(ply)

    end

end)

hook.Add("EntityTakeDamage", "reduceHealthOnDMg", function(ent, dmg)

    if ent:IsPlayer() then
            if ent:HasGodMode() then
            dmg:ScaleDamage(0.000001)
            return end

    elseif ent:IsRagdoll() and ent.ragdolledPly then
        local rightply = ent.ragdolledPly
        ent = rightply
    else
        return
    end

    local boneDmgd = ent:LastHitGroup()
    local dmgAmount = dmg:GetDamage()    
    local dmgType = dmg:GetDamageType()

    if dmgType == DMG_FALL then 

        ApplyDamage(ent, dmgAmount*3, 6)
        ApplyDamage(ent, dmgAmount*3, 7)

    elseif dmgType == DMG_GENERIC then
        
        for k,v in pairs(ent.chCustomHealth) do
            ApplyDamage(ent, dmgAmount, k)
        end

    elseif dmgType == DMG_BLAST then
        
        for k, v in pairs(ent.chCustomHealth) do
            
            ApplyDamage(ent, dmgAmount/7, k)
        end

    elseif (dmgType > 4000 and dmgType < 9000) or DMG_BULLET then
        
        if ent.chCustomHealth[boneDmgd] then
        ApplyDamage(ent, dmgAmount, boneDmgd)
        end
    end

    if ent.BleedMultiplier > 1 and (dmgType != DMG_GENERIC) and !timer.Exists(ent:SteamID().."bleedEffect") then
       
        BleedEffect(ent)

    end

    if ent.menuOnply:GetCount() > 0 then
        
        local plytb = ent.menuOnply:GetPlayers()
        for k,v in pairs(plytb) do
            CheckVars(plytb[k])
        end

    end
    
    dmg:ScaleDamage(0.00001)

end)

hook.Add("PlayerDeath", "blackscreenOnDeath", function(ply, inflict, attack)

    if ply:GetRagdollEntity() then
        ply:GetRagdollEntity():Remove()
    end

    ply:Spectate(OBS_MODE_CHASE)
    ply:SpectateEntity(ply.ragdoll)

    if cHealth.cfg.ActivateDeathScreen then 

        net.Start("chHealth:IsDead")
        net.WriteUInt(ply.chRespawnTimer, 8)
        net.Send(ply)
    end

    timer.Create(ply:SteamID() .. "chrespawntimer", ply.chRespawnTimer, 1, function()
    end)

end)

hook.Add("PlayerDeathThink", "dontRespawn", function(ply)

    if timer.Exists(ply:SteamID().."chrespawntimer") then
        return false 
    else
        return 
        respawnPlayer(ply)
    end

end)

local function ragdollDisconnectedCheck( ply )
	if ply.ragdoll then

        if ULib then
		    ply.ragdoll:DisallowDeleting( false )
        end

		ply.ragdoll:Remove()
	end
end
hook.Add( "PlayerDisconnected", "RagdollDisconnectedCheck", ragdollDisconnectedCheck, HOOK_MONITOR_HIGH )

hook.Add("PlayerSay", "chSettings:Settings", function(sender, text, teamChat) 

    if string.lower(text) == "!lhssettings" then
        
        net.Start("chSettings:OpenSettings")
        net.Send(sender)

        return ""

    end

end)

net.Receive("chMenu:OpenedMenu", function(len, ply)

    ply.menuOpen = true

end)

net.Receive("chMenu:ClosedMenu", function(len, ply)

    ply.menuOpen = false
    ply.openedMenuFor.menuOnply:RemovePlayer(ply) 

end)

net.Receive("chHealth:HealLimb", function(len, ply)

    local MedKit = net.ReadUInt(5)
    local Limb = net.ReadUInt(3)

    ApplyHeal(ply, MedKit, Limb)

end)

hook.Add("PlayerDisconnected", "chArmor:Remove", function(ply)   
    
    net.Start("chArmor:RemovePly")
    net.WriteEntity(ply)
    net.Broadcast()

end)

hook.Add("PlayerDeath", "chArmor:RemoveDeath", function(vic, inf, att)

    net.Start("chArmor:RemoveDeath")
    net.WriteEntity(vic)
    net.Broadcast()

end)

net.Receive("chArmor:PlyReady", function(len, ply)

    if !table.IsEmpty(plyWithArmor) then

        local compressedTable = util.Compress(util.TableToJSON(plyWithArmor))
        
        net.Start("chArmor:PlyConnect")
        net.WriteUInt(#compressedTable, 16)
        net.WriteData(compressedTable, #compressedTable)
        net.WriteBool(true)
        net.Send(ply)

    end

    if !table.IsEmpty(plyWithHelmet) then
        
        local compressedTable = util.Compress(util.TableToJSON(plyWithHelmet))

        net.Start("chArmor:PlyConnect")
        net.WriteUInt(#compressedTable, 16)
        net.WriteData(compressedTable, #compressedTable)
        net.WriteBool(false)
        net.Send(ply)
    end

end)