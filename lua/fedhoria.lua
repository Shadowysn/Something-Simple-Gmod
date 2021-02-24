include("fedhoria/stumbling.lua")

util.AddNetworkString("Fedhoria_Ragdoll_GetPlayerColor")

local enabled 	= CreateConVar("fedhoria_enabled", 1, bit.bor(FCVAR_ARCHIVE, FCVAR_REPLICATED))
local players 	= CreateConVar("fedhoria_players", 1, bit.bor(FCVAR_ARCHIVE, FCVAR_REPLICATED))
local npcs 		= CreateConVar("fedhoria_npcs", 1, bit.bor(FCVAR_ARCHIVE, FCVAR_REPLICATED))

local last_dmgpos = {}

hook.Add("CreateEntityRagdoll", "Fedhoria", function(ent, ragdoll)
	if (!enabled:GetBool() or !npcs:GetBool()) then return end
	timer.Simple(0, function()
		if (!IsValid(ent) or !IsValid(ragdoll)) then return end
		local dmgpos = last_dmgpos[ent]
		Fedh_DoStumblingAnim(ragdoll, dmgpos)
		last_dmgpos[ent] = nil		
	end)
end)

hook.Add("EntityTakeDamage", "Fedhoria", function(ent, dmginfo)
	if (!enabled:GetBool() or !npcs:GetBool()) then return end
	if (!ent:IsNPC() or dmginfo:GetDamage() < ent:Health()) then return end

	last_dmgpos[ent] = dmginfo:GetDamagePosition()
end)

--RagMod support
hook.Add("OnEntityCreated", "Fedhoria", function(ent)
	--If RagMod isn't installed remove this hook
	if !RMA_Ragdolize then
		hook.Remove("OnEntityCreated", "Fedhoria")
		return
	end
	if (!enabled:GetBool() or !players:GetBool() or !ent:IsRagdoll()) then return end
	timer.Simple(0, function()
		if !IsValid(ent) then return end
		for _, ply in ipairs(player.GetAll()) do
			if (ply.RM_IsRagdoll and ply.RM_Ragdoll == ent) then
				Fedh_DoStumblingAnim(ent)
				return
			end
		end
	end)
end)

local PLAYER = FindMetaTable("Player")

local oldCreateRagdoll = PLAYER.CreateRagdoll

local dolls = {}

local function CreateRagdoll(self)
	SafeRemoveEntity(dolls[self])

	local ragdoll = ents.Create("prop_ragdoll")
	ragdoll:SetModel(self:GetModel())
	ragdoll:SetPos(self:GetPos())
	ragdoll:SetAngles(self:GetAngles())
	ragdoll:Spawn()
	ragdoll:Activate()
	
	ragdoll:SetCollisionGroup(COLLISION_GROUP_DEBRIS)

	ragdoll:SetSkin(self:GetSkin())

	for i = 0, self:GetNumBodyGroups() - 1 do
		ragdoll:SetBodygroup(i, self:GetBodygroup(i))
	end

	for i = 0, ragdoll:GetPhysicsObjectCount()-1 do
		local phys = ragdoll:GetPhysicsObjectNum(i)
		local bone = ragdoll:TranslatePhysBoneToBone(i)
		local matrix = self:GetBoneMatrix(bone)
		local pos, ang = matrix:GetTranslation(), matrix:GetAngles()--self:GetBonePosition(bone)
		phys:SetPos(pos)
		phys:SetAngles(ang)
		phys:SetVelocity(self:GetVelocity())
	end

	if !self:Alive() then
		self:SpectateEntity(ragdoll)
		self:Spectate(OBS_MODE_CHASE)
	end
	
	if self:IsPlayer() then
		net.Start("Fedhoria_Ragdoll_GetPlayerColor")
		net.WriteInt(ragdoll:EntIndex(), 32)
		net.WriteInt(self:EntIndex(), 32)
		net.WriteVector(self:GetPlayerColor())
		net.Send(player.GetAll())
	end

	dolls[self] = ragdoll
end

local oldGetRagdollEntity = PLAYER.GetRagdollEntity

local function GetRagdollEntity(self)
	return dolls[self] or NULL
end

if enabled:GetBool() then
	PLAYER.CreateRagdoll = CreateRagdoll
	PLAYER.GetRagdollEntity = GetRagdollEntity
end

cvars.AddChangeCallback("fedhoria_enabled", function(name, old, new)
	if (new == "1") then
		if players:GetBool() then
			PLAYER.CreateRagdoll = CreateRagdoll
			PLAYER.GetRagdollEntity = GetRagdollEntity
		end
	else
		PLAYER.CreateRagdoll = oldCreateRagdoll
		PLAYER.GetRagdollEntity = oldGetRagdollEntity
	end
end)

cvars.AddChangeCallback("fedhoria_players", function(name, old, new)
	if (new == "1") then
		if enabled:GetBool() then
			if (debug.getinfo(PLAYER.CreateRagdoll).short_src == "[C]") then
				PLAYER.CreateRagdoll = CreateRagdoll
				PLAYER.GetRagdollEntity = GetRagdollEntity
			end
		end
	else
		PLAYER.CreateRagdoll = oldCreateRagdoll
		PLAYER.GetRagdollEntity = oldGetRagdollEntity
	end
end)

hook.Add("PostPlayerDeath", "Fedhoria", function(ply)
	if (!enabled:GetBool() or !players:GetBool()) then return end
	timer.Simple(0, function()
		if !IsValid(ply) then return end
		local ragdoll = ply:GetRagdollEntity()
		if (IsValid(ragdoll) and ragdoll:IsRagdoll()) then
			Fedh_DoStumblingAnim(ragdoll)
		end
	end)
end)