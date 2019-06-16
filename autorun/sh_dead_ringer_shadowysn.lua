AddCSLuaFile("client/cl_dead_ringer_shadowysn.lua")
AddCSLuaFile()

include("server/sv_dead_ringer_shadowysn.lua")

local function Shadowysn_DRFootsteps( p, vPos, iFoot, strSoundName, fVolume, pFilter )
	if IsValid(p) and p:Alive() then
		if p:GetNWBool("Shadowysn_DeadRingerCanAttack") != true and p:GetNWBool("Shadowysn_DeadRingerDead") == true then
			if CLIENT then
			return true
			end
		end
	end
end
hook.Add("PlayerFootstep","Shadowysn_DeadRingerFootsteps",Shadowysn_DRFootsteps)