AddCSLuaFile( "cl_init.lua" ) 
AddCSLuaFile( "shared.lua" )
include('shared.lua')

function ENT:Initialize()

	self:SetModel( "models/player/armor_trooper/trooper.mdl" ) -- Standardmodel
	self:PhysicsInit( SOLID_VPHYSICS )      
	self:SetMoveType( MOVETYPE_VPHYSICS )   
	self:SetSolid(SOLID_VPHYSICS) 
	self:SetUseType(SIMPLE_USE)

	local phys = self:GetPhysicsObject()
	if (phys:IsValid()) then
		phys:Wake()
	end 

end

function ENT:Use(act, call)

    if !cHealth then return end
	if !IsValid(act) and !act:Alive() then return end
	if !table.IsEmpty(act.chArmor) or act.ragdoll then return end

	act:AddArmor("Killa")
	self:Remove()
end