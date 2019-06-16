if (CLIENT) then return end

util.AddNetworkString( "Shadowysn_DRReady" )
util.AddNetworkString( "Shadowysn_DRBeepHigh" )
util.AddNetworkString( "Shadowysn_DRBeepLow" )
util.AddNetworkString( "Shadowysn_DRSpeedBoostGiveSound" )
util.AddNetworkString( "Shadowysn_DRSpeedBoostStopSound" )
util.AddNetworkString( "Shadowysn_DRReceiveClientInfo" )
util.AddNetworkString( "PlayerKilled" )
util.AddNetworkString( "PlayerKilledByPlayer" )
util.AddNetworkString( "PlayerKilledSelf" )

local level = 75
local volume = 0.3
death_pitch_table = { 100, 103, 97 }
local pitch = table.Random( death_pitch_table )
sound.Add( {
	name = "death_beep",
	channel = CHAN_AUTO,
	volume = volume,
	level = level,
	pitch = {pitch},
	sound = "hl1/fvox/beep.wav"
} )
sound.Add( {
	name = "death_flatline",
	channel = CHAN_AUTO,
	volume = volume,
	level = level,
	pitch = {pitch},
	sound = "hl1/fvox/flatline.wav"
} )

if !ConVarExists("sv_dead_ringer_corpse_time") then
CreateConVar( "sv_dead_ringer_corpse_time", 0, FCVAR_ARCHIVE, 
"How long a dead ringer corpse will stay after the user's decloak. Maximum is 50. Set to -1 to prevent time-based removal." )
end

if !ConVarExists("sv_dead_ringer_corpse_serverside") then
CreateConVar( "sv_dead_ringer_corpse_serverside", 0, FCVAR_ARCHIVE, 
"Whether the dropped dead ringer corpse is serverside." )
end

if !ConVarExists("sv_dead_ringer_death_sound") then
CreateConVar( "sv_dead_ringer_death_sound", 1, FCVAR_ARCHIVE, 
"Should death sounds be played upon feigned deaths?" )
end

if !ConVarExists("sv_dead_ringer_fake_weapon") then
CreateConVar( "sv_dead_ringer_fake_weapon", 0, FCVAR_ARCHIVE, 
"Should there be a decoy weapon on feigned deaths?" )
end

if !ConVarExists("sv_dead_ringer_fake_weapon_time") then
CreateConVar( "sv_dead_ringer_fake_weapon_time", 5, FCVAR_ARCHIVE, 
"How long decoy weapons last. Maximum is 150. Set to -1 to prevent time-based removal." )
end

hook.Add("PlayerCanPickupWeapon","Shadowysn_DRDisallowCloakingPickupWep",function( ply )
if ply:GetNWBool("Shadowysn_DeadRingerDead") == true and ply:GetNWBool("Shadowysn_DeadRingerStatus") == 3 then
	return false
end
end)

hook.Add("PlayerCanPickupItem","Shadowysn_DRDisallowCloakingPickupItem",function( ply )
if ply:GetNWBool("Shadowysn_DeadRingerDead") == true and ply:GetNWBool("Shadowysn_DeadRingerStatus") == 3 then
	return false
end
end)

local function Shadowysn_DRLeftTheVehicle( ply, vehicle )
	if ply:GetNWBool("Shadowysn_DeadRingerCanAttack") != true and ply:GetNWBool("Shadowysn_DeadRingerDead") == true and ply:GetNWBool("Shadowysn_DeadRingerStatus") == 3 then
		ply:SetNoDraw(true)
	end
end

hook.Add( "PlayerLeaveVehicle", "Shadowysn_DeadRingerVehicleLeave", Shadowysn_DRLeftTheVehicle )

-- disable dead rnger on spawn
local function Shadowysn_dringerspawn( p )
	if p:GetNWBool("Shadowysn_DeadRingerDead") == true then
		p:SetNWBool("Shadowysn_DeadRingerStatus", 0)
		p:GetViewModel():SetMaterial("")
		p:SetMaterial("")
		p:SetColor(255,255,255,255)
	end
	p:SetNWBool("Shadowysn_DeadRingerStatus", 0)
	p:SetNWBool("Shadowysn_DeadRingerDead", false)
	p:SetNWBool("Shadowysn_DeadRingerCanAttack", true)
	p:SetNWInt("Shadowysn_drcharge", 8 )
end
hook.Add( "PlayerSpawn", "Shadowysn_DRingerspawn", Shadowysn_dringerspawn )

local viewcloaked = nil
local handcloaked = nil

local function Shadowysn_disablefakecorpseondeath(p, attacker)
	if IsValid(p) and p:GetNWBool("Shadowysn_DeadRingerCanAttack") != true and p:GetNWBool("Shadowysn_DeadRingerDead") == true and p:GetNWBool("Shadowysn_DeadRingerStatus") == 3 then
	p:DRuncloak()
	end
end
hook.Add("DoPlayerDeath", "Shadowysn_RemoveFakeCorpse", Shadowysn_disablefakecorpseondeath)

local function Shadowysn_drthink()
	for _, p in pairs(player.GetAll()) do
		if IsValid(p) and p:GetNWBool("Shadowysn_DeadRingerDead") != true and p:GetNWBool("Shadowysn_DeadRingerStatus") == 4 then
			if p:GetNWInt("Shadowysn_drcharge") < 8 then
			p.drtimer = p.drtimer or CurTime() + 2
				if CurTime() > p.drtimer then
				p.drtimer = CurTime() + 2
				p:SetNWInt("Shadowysn_drcharge", p:GetNWInt("Shadowysn_drcharge") + 1)
				end
			elseif 	p:GetNWInt("Shadowysn_drcharge") == 8 then
			p:SetNWBool("Shadowysn_DeadRingerStatus", 1)
			--net.Start( "Shadowysn_DRReady" ) --this part isn't broken so uh i'm just gonna leave it? -- {annoying sound}
			--net.Send(p)
			end
		end
		if IsValid(p) and p:GetNWBool("Shadowysn_DeadRingerDead") == true and p:GetNWBool("Shadowysn_DeadRingerStatus") == 3 then
			for _, v in pairs(p:GetWeapons()) do
			v:SetNextPrimaryFire(CurTime() + 2)
			v:SetNextSecondaryFire(CurTime() + 2)
			end
			p:DrawWorldModel(false)
			for _,npc in pairs(ents.GetAll()) do
				if npc:IsNPC() then 
					--for _,v in pairs(NPCs) do
						--if npc:GetClass() == v then
						--npc:AddEntityRelationship(p,D_NU,99)
					if IsValid(npc) then
						if npc:GetEnemy() == p then
							if npc:HasCondition( 30 ) then
							npc:SetCondition( 30 )
							end
							npc:ClearEnemyMemory()
						end
					end
						--end
					--end
				end
			end
			p:SetNoTarget( true )
			if p:KeyPressed( IN_ATTACK2 ) then
			p:DRuncloak()
			--p:SetNWInt("Shadowysn_drcharge", 7 ) -- {originally 2, prob never need this}
			end
			if p:GetNWInt("Shadowysn_drcharge") <= 8 and p:GetNWInt("Shadowysn_drcharge") > 0 then
			p.cltimer = p.cltimer or CurTime() + 1
				if CurTime() > p.cltimer then
				--p.cltimer = CurTime() + 1 -- {nope.avi}
				--p:SetNWInt("Shadowysn_drcharge", p:GetNWInt("Shadowysn_drcharge") - 1) -- {nope.avi}
				end
			end
			if p:GetNWInt("Shadowysn_drcharge") == 0 then
				p:DRuncloak()
			end
		end
		if IsValid(p) and p:GetNWBool("Shadowysn_DeadRingerStatus") and !IsValid(p.DeadRingerAltViewModel) and p:HasWeapon("weapon_dead_ringer_inf") and 
		IsValid(p:GetActiveWeapon()) and p:GetActiveWeapon():GetClass() != "weapon_dead_ringer_inf" then
			p.DeadRingerAltViewModel = ents.Create("dr_viewmodel_other")
			p.DeadRingerAltViewModel:SetPos(p:GetPos())
			p.DeadRingerAltViewModel:SetAngles(p:GetAngles())
			p.DeadRingerAltViewModel:SetOwner(p)
			p.DeadRingerAltViewModel:Spawn()
			p.DeadRingerAltViewModel:Activate()
		elseif IsValid(p) and IsValid(p.DeadRingerAltViewModel) and 
		(IsValid(p:GetActiveWeapon()) and 
		p:GetActiveWeapon():GetClass() == "weapon_dead_ringer_inf" or !p:HasWeapon("weapon_dead_ringer_inf")) then
			p.DeadRingerAltViewModel:Remove()
		end
	end
	if GetConVar("sv_dead_ringer_fake_weapon"):GetInt() >= 1 then
	for _,fakewpn in pairs(ents.GetAll()) do
		if IsValid(fakewpn) and fakewpn:GetNWBool("dead_ringer_decoy_weapon") == true then
		for _,ply in pairs(ents.FindInSphere( fakewpn:GetPos(), fakewpn:BoundingRadius()*3.5 ) ) do
			if IsValid(ply) and ply:IsPlayer() and ply:Alive() and ply:GetNWBool("Shadowysn_DeadRingerStatus") != 3 and ply:GetNWBool("Shadowysn_DeadRingerDead") != true and ply:GetNWBool("Shadowysn_DeadRingerStatus") != 3 then
				fakewpn:Remove()
			end
		end
		end
	end
	end
end
hook.Add( "Think", "Shadowysn_DR_ENERGY", Shadowysn_drthink )

local function Shadowysn_checkifwehaveourdr(ent,dmginfo)
local attacker = dmginfo:GetAttacker()
local inflictor = dmginfo:GetInflictor()
local getdmg = dmginfo:GetDamage()
local reducedmg = getdmg * 0.50
	if ent:IsPlayer() then
	local p = ent
	--local infl
		--[[if attacker:GetClass() == "func_rotating" or attacker:GetClass() == "func_physbox" then
			if p:GetNWBool("Shadowysn_DeadRingerCanAttack") == true and p:GetNWBool("Shadowysn_DeadRingerDead") != true and p:GetNWBool("Shadowysn_DeadRingerStatus") == 1 then
			dmginfo:SetDamage(math.random(5,15))
			--dmginfo:SetDamage(0)
			p:DRfakedeath(dmginfo)
			net.Start( "PlayerKilled" ) --the deathnotices use net instead of umsg
			net.WriteEntity( p )
			net.WriteString( attacker:GetClass() )
			net.WriteString( inflictor:GetClass() )
			net.WriteString( p:GetClass() )
			net.Broadcast()
			MsgAll( p:Nick() .. " was killed by " .. attacker:GetClass() .. "\n" )
			elseif p:GetNWBool("Shadowysn_DeadRingerCanAttack") != true and p:GetNWBool("Shadowysn_DeadRingerDead") == true and p:GetNWBool("Shadowysn_DeadRingerStatus") == 3 then
			dmginfo:SetDamage(math.random(0,1))
			--dmginfo:SetDamage(0)
			end
		elseif attacker:IsPlayer() then
			if p:GetNWBool("Shadowysn_DeadRingerCanAttack") == true and p:GetNWBool("Shadowysn_DeadRingerDead") != true and p:GetNWBool("Shadowysn_DeadRingerStatus") == 1 then
			dmginfo:SetDamage(getdmg - reducedmg )
			--dmginfo:SetDamage(0)
			p:DRfakedeath(dmginfo)
			net.Start( "PlayerKilledByPlayer" )
			net.WriteEntity( p )
			net.WriteString( inflictor:GetClass() )
			net.WriteEntity( attacker )
			net.Broadcast()
			if attacker == p then
				MsgAll( p:Nick() .. " suicided!\n" )
			else
				MsgAll( attacker:Nick() .. " killed " .. p:Nick() .. " using " .. attacker:GetActiveWeapon():GetClass() .. "\n" )
			end
			elseif p:GetNWBool("Shadowysn_DeadRingerCanAttack") != true and p:GetNWBool("Shadowysn_DeadRingerDead") == true and p:GetNWBool("Shadowysn_DeadRingerStatus") == 3 then
			dmginfo:SetDamage(getdmg - reducedmg )
			--dmginfo:SetDamage(0)
			end
		elseif attacker:IsNPC() then
			if p:GetNWBool("Shadowysn_DeadRingerCanAttack") == true and p:GetNWBool("Shadowysn_DeadRingerDead") != true and p:GetNWBool("Shadowysn_DeadRingerStatus") == 1 then
			dmginfo:SetDamage(getdmg - reducedmg )
			--dmginfo:SetDamage(0)
			p:DRfakedeath(dmginfo)
			-- if npc has weapon (eg: metrocop with stunstick) then inflictor = npc's weapon
			if IsValid(inflictor) and inflictor != attacker then
			--print("inflclass", inflictor:GetClass())
			infl = inflictor:GetClass()
			elseif IsValid(attacker:GetActiveWeapon()) then
			--print("weaponclass", attacker:GetActiveWeapon():GetClass())
			infl = attacker:GetActiveWeapon():GetClass()
			else -- (eg: zombie or hunter) then inflictor = attacker
			--print("npcclass", attacker:GetClass())
			infl = attacker:GetClass()
			end
			net.Start( "PlayerKilled" )
			net.WriteEntity( p )
			net.WriteString( infl )
			net.WriteString( attacker:GetClass() )
			net.Broadcast()
			MsgAll( p:Nick() .. " was killed by " .. attacker:GetClass() .. "\n" )
			elseif p:GetNWBool("Shadowysn_DeadRingerCanAttack") != true and p:GetNWBool("Shadowysn_DeadRingerDead") == true and p:GetNWBool("Shadowysn_DeadRingerStatus") == 3 then
			dmginfo:SetDamage(getdmg - reducedmg )
			--dmginfo:SetDamage(0)
			end
		else
			if p:GetNWBool("Shadowysn_DeadRingerCanAttack") == true and p:GetNWBool("Shadowysn_DeadRingerDead") != true and p:GetNWBool("Shadowysn_DeadRingerStatus") == 1 then
			dmginfo:SetDamage(getdmg - reducedmg )
		--if IsValid(attacker) then
		--	if attacker:GetClass() == "trigger_hurt" then
		--		local triggerhurt_table = attacker:GetKeyValues()
		--		local th_table_getkeys = table.GetKeys(triggerhurt_table)
		--		if th_table_getkeys 
		--			
		--		end
		--		dmginfo:SetDamage(0)
		--		else if attacker:GetClass() == "func_rotating" or attacker:GetClass() == "func_physbox" then
		--		dmginfo:SetDamage(0)
		--		end
		--	end
		--end
			--dmginfo:SetDamage(0)
			p:DRfakedeath(dmginfo)
			if attacker == p or attacker:GetClass() == "trigger_hurt" then
			net.Start( "PlayerKilledSelf" )
			else
			net.Start( "PlayerKilled" )
			end
			net.WriteEntity( p )
			net.WriteString( inflictor:GetClass() )
			net.WriteString( attacker:GetClass() )
			net.Broadcast()
			if attacker == p or attacker:GetClass() == "trigger_hurt" then
				MsgAll( p:Nick() .. " suicided!\n" )
			else
				MsgAll( p:Nick() .. " was killed by " .. attacker:GetClass() .. "\n" )
			end
			elseif p:GetNWBool("Shadowysn_DeadRingerCanAttack") != true and p:GetNWBool("Shadowysn_DeadRingerDead") == true and p:GetNWBool("Shadowysn_DeadRingerStatus") == 3 then
			dmginfo:SetDamage(getdmg - reducedmg )
			--if attacker:GetClass() == "trigger_hurt" or attacker:GetClass() == "func_rotating" or attacker:GetClass() == "func_physbox" then
			--	dmginfo:SetDamage(0)
			--	else
			--	dmginfo:SetDamage(0)
			--end
			end
		end--]]
--[[		if p:GetNWBool("Shadowysn_DeadRingerDead") == true and p:GetNWBool("Shadowysn_DeadRingerStatus") == 3 then
		if dmginfo:IsDamageType(DMG_DISSOLVE) then
			p:SetNWBool("DeadRingerVaporize", true)
			timer.Create( "DeadRingerVaporizeDisableTimer", 0.1, 1, function()
				if IsValid(self) and self:GetNWBool("DeadRingerVaporize") != false then
				self:SetNWBool("DeadRingerVaporize", false)
				end
			end )
		end
		end--]]
		if p:GetNWBool("Shadowysn_DeadRingerCanAttack") == true and p:GetNWBool("Shadowysn_DeadRingerDead") != true and p:GetNWBool("Shadowysn_DeadRingerStatus") == 1 then
			if attacker:GetClass() == "func_rotating" or attacker:GetClass() == "func_physbox" then
			dmginfo:SetDamage(math.random(5,15))
			else
			--print(dmginfo:GetDamage())
			dmginfo:SetDamage(getdmg - reducedmg)
			--print("oof1")
			--print(dmginfo:GetDamage())
			--dmginfo:SetDamage(0)
			end
			p:DRfakedeath(dmginfo)
			if ( IsValid( attacker ) && attacker:GetClass() == "trigger_hurt" ) then attacker = p end
			if ( IsValid( attacker ) && attacker:IsVehicle() && IsValid( attacker:GetDriver() ) ) then
				attacker = attacker:GetDriver()
			end
			if ( !IsValid( inflictor ) && IsValid( attacker ) ) then
				inflictor = attacker
			end
			if ( IsValid( inflictor ) && inflictor == attacker && ( inflictor:IsPlayer() || inflictor:IsNPC() ) ) then
			inflictor = inflictor:GetActiveWeapon()
			if ( !IsValid( inflictor ) ) then inflictor = attacker end
			end
			
			if ( attacker == p ) then
			net.Start( "PlayerKilledSelf" )
			net.WriteEntity( p )
			net.Broadcast()
			MsgAll( attacker:Nick() .. " suicided!\n" )
			return end
			
			if ( attacker:IsPlayer() ) then
			net.Start( "PlayerKilledByPlayer" )
			net.WriteEntity( p )
			net.WriteString( inflictor:GetClass() )
			net.WriteEntity( attacker )
			net.Broadcast()
			MsgAll( attacker:Nick() .. " killed " .. p:Nick() .. " using " .. inflictor:GetClass() .. "\n" )
			return end
			
			net.Start( "PlayerKilled" )
			net.WriteEntity( p )
			--if IsValid(inflictor) and inflictor != attacker then
			net.WriteString( inflictor:GetClass() )
			--[[print("e")
			elseif attacker:IsNPC() and IsValid(attacker:GetActiveWeapon()) then
			net.WriteString( attacker:GetActiveWeapon():GetClass() )
			print("2e")
			else -- (eg: zombie or hunter) then inflictor = attacker
			net.WriteString( attacker:GetClass() )
			print("3e")
			end--]]
			--net.WriteString( inflictor:GetClass() )
			net.WriteString( attacker:GetClass() )
			net.Broadcast()
			MsgAll( p:Nick() .. " was killed by " .. attacker:GetClass() .. "\n" )
			
		elseif p:GetNWBool("Shadowysn_DeadRingerCanAttack") != true and p:GetNWBool("Shadowysn_DeadRingerDead") == true and p:GetNWBool("Shadowysn_DeadRingerStatus") == 3 then
			if attacker:GetClass() == "trigger_hurt" or attacker:GetClass() == "func_rotating" or attacker:GetClass() == "func_physbox" then
			dmginfo:SetDamage(math.random(0,1))
			else
			--print(dmginfo:GetDamage())
			dmginfo:SetDamage(getdmg - reducedmg)
			--print("oof2")
			--print(dmginfo:GetDamage())
			end
			--dmginfo:SetDamage(0)
		end
	end
end
hook.Add("EntityTakeDamage", "Shadowysn_CheckIfWeHaveDeadRinger", Shadowysn_checkifwehaveourdr)