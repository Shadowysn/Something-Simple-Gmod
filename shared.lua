/////////////////////////
//Dead Ringer Swep///////
///////Update////////////
//by NECROSSIN///////////
//Update again by MUDDY//
/////////////////////////
--Updated: 24 January 2010
--Updated again: April 20, 2017 (Fake death notices work again :D)
--If I ever actually get good with lua I might consider changing the mechanics and making it work
--like modern deadringer, with the speedboost and all, but for now, this'll have to do
--and it also shows up in the spawn list, under Team Fortress 2. Why didn't it before...?

-- Message By Shadowysn
-- I just made some little edits. Mainly the corpse being clientside and small stuff.

----------------------------
--////////////////////////--
local REDUCEDAMAGE = 0.9 
--////////////////////////--
----------------------------

--this SWEP uses models, textures and sounds from TF2, so be sure that you have it if you dont want to see an ERROR instead of swep model and etc...

resource.AddFile( "materials/vgui/entities/weapon_dead_ringer_inf.vmt" )
resource.AddFile( "materials/vgui/entities/weapon_dead_ringer_inf.vtf" )

--------------------------------------------------------------------------
if (SERVER) then

	AddCSLuaFile( "shared.lua" )
	SWEP.Weight				= 5
	SWEP.AutoSwitchTo			= false
	SWEP.AutoSwitchFrom		= false
	
	if !ConVarExists("sv_dead_ringer_corpse_time") then
	CreateConVar( "sv_dead_ringer_corpse_time", 0, FCVAR_LUA_SERVER, 
	"How long a dead ringer corpse will stay after the user's decloak. Maximum is 50. Set to -1 to prevent time-based removal." )
	end
	
	if !ConVarExists("sv_dead_ringer_corpse_serverside") then
	CreateConVar( "sv_dead_ringer_corpse_serverside", 0, FCVAR_LUA_SERVER, 
	"Whether the dropped dead ringer corpse is serverside." )
	end
	
	if !ConVarExists("sv_dead_ringer_death_sound") then
	CreateConVar( "sv_dead_ringer_death_sound", 1, FCVAR_LUA_SERVER, 
	"Should death sounds be played upon feigned deaths?" )
	end
end

--------------------------------------------------------------------------

if ( CLIENT ) then
	SWEP.PrintName			= "Dead Ringer (OP Infinite)"	
	SWEP.Author				= "NECROSSIN (fixed by Niandra Lades and Muddy, inf ver by Shadowysn)"
	SWEP.DrawAmmo 			= false
	SWEP.DrawCrosshair 		= false
	SWEP.ViewModelFOV			= 55
	SWEP.ViewModelFlip		= false
	SWEP.CSMuzzleFlashes		= false
	SWEP.WepSelectIcon = surface.GetTextureID("backpack/weapons/c_models/c_pocket_watch/parts/c_pocket_watch.vtf") -- texture from TF2
	
	SWEP.Slot				= 1 
	SWEP.SlotPos			= 1
	SWEP.IconLetter			= "G"
	
	surface.CreateFont( "DRfont", {
	font = "coolvertica",
	size = 13,
	weight = 500,
	blursize = 0,
	scanlines = 0,
	antialias = true,
	underline = false,
} )
	CreateClientConVar( "cl_dead_ringer_blue_hud", 0, true, false, 
		"Should the charge meter be blue?" )
	CreateClientConVar( "cl_dead_ringer_hud_enable", 1, true, false, 
		"Should the dead ringer hud be visible?" )

function drawdr()
--here goes the new HUD
if LocalPlayer():GetNWBool("DeadRingerStatus") == 1 or LocalPlayer():GetNWBool("DeadRingerStatus") == 3 or LocalPlayer():GetNWBool("DeadRingerStatus") == 4 and LocalPlayer():Alive() and GetConVar( "cl_dead_ringer_hud_enable" ):GetInt() > 0 then
local background = surface.GetTextureID("HUD/misc_ammo_area_red")
local background2 = surface.GetTextureID("HUD/misc_ammo_area_blue")
local w,h = surface.GetTextureSize(surface.GetTextureID("HUD/misc_ammo_area_red"))
	if GetConVar( "cl_dead_ringer_blue_hud" ):GetInt() < 1 then
	surface.SetTexture(background)
	else
	surface.SetTexture(background2)
	end
	surface.SetDrawColor(255,255,255,255)
	surface.DrawTexturedRect(13, ScrH() - h - 200, w*5, h*5 )

local energy = math.max(LocalPlayer():GetNWInt("drcharge"), 0)
if GetConVar( "cl_dead_ringer_blue_hud" ):GetInt() == 0 then
	draw.RoundedBox(2,44, ScrH() - h - 168, (energy / 8) * 77, 15, Color(255,222,255,255))
else
	draw.RoundedBox(2,44, ScrH() - h - 168, (energy / 8) * 77, 15, Color(242,235,225,255))
end
surface.SetDrawColor(255,255,255,255)
surface.DrawOutlinedRect(44, ScrH() - h - 168, 77, 15)
draw.DrawText("FEIGN", "DRfont",68, ScrH() - h - 150, Color(255,255,255,255))
end

end
hook.Add("HUDPaint", "drawdr", drawdr)

local function DRReady(um)
surface.PlaySound( "player/recharged.wav" )
end
usermessage.Hook("DRReady", DRReady)

local function DRBeepHigh(um)
sound.Play( "buttons/blip1.wav", LocalPlayer():GetPos(), 90, 100, 1 )
end
usermessage.Hook("DRBeepHigh", DRBeepHigh)

local function DRBeepLow(um)
sound.Play( "buttons/blip1.wav", LocalPlayer():GetPos(), 75, 73, 1 )
end
usermessage.Hook("DRBeepLow", DRBeepLow)

local function DRSpeedBoostGiveSound(um)
sound.Play( "weapons/discipline_device_power_up.wav", LocalPlayer():GetPos(), 90, 100, 1 )
end
usermessage.Hook("DRSpeedBoostGiveSound", DRSpeedBoostGiveSound)

local function DRSpeedBoostStopSound(um)
sound.Play( "weapons/discipline_device_power_down.wav", LocalPlayer():GetPos(), 90, 100, 1 )
end
usermessage.Hook("DRSpeedBoostStopSound", DRSpeedBoostStopSound)
end 

-------------------------------------------------------------------

SWEP.Category				= "Team Fortress 2"

SWEP.Spawnable				= true
SWEP.AdminSpawnable			= true
SWEP.AdminOnly              = true

SWEP.Purpose        	= "Fake your death!"
SWEP.Author             = "Necrossin, Muddy, Shadowysn"
SWEP.Instructions   	= "Primary - turn on.\nSecondary - turn off or drop cloak."

SWEP.ViewModel 				= "models/weapons/v_models/v_watch_pocket_spy.mdl"
--SWEP.ViewModel 				= "models/weapons/cstrike/c_c4.mdl"
SWEP.WorldModel 			= "" --"models/weapons/c_models/c_pocket_watch/parts/c_pocket_watch.mdl" -- (By Shadowysn)

SWEP.Weight					= 5 
SWEP.AutoSwitchTo				= false
SWEP.AutoSwitchFrom			= false

SWEP.Primary.ClipSize			= -1
SWEP.Primary.DefaultClip		= -1
SWEP.Primary.Ammo				= ""

SWEP.Secondary.ClipSize			= -1
SWEP.Secondary.DefaultClip		= -1
SWEP.Secondary.Ammo			= "none" 
------------------------------------------
--[[NPCs = { -- if you have custom NPC-enemies, you can add them here
"npc_zombie",
"npc_fastzombie",
"npc_zombie_torso",
"npc_poisonzombie",
"npc_antlion",
"npc_antlionguard",
"npc_hunter",
"npc_antlion_worker",
"npc_headcrab_black",
"npc_headcrab",
"npc_headcrab_fast",
"npc_combine_s",
"npc_zombine",
"npc_fastzombie_torso",
"npc_rollermine",
"npc_turret_floor",
"npc_cscanner",
"npc_clawscanner",
"npc_manhack",
"npc_tripmine",
"npc_barnacle",
"npc_strider",
"npc_metropolice",
"npc_sniper",
"monster_alien_grunt",
"monster_alien_slave",
"monster_human_assassin",
"monster_babycrab",
"monster_bullchicken",
"monster_cockroach",
"monster_alien_controller",
"monster_gargantua",
"monster_bigmomma",
"monster_human_grunt",
"monster_headcrab",
"monster_houndeye",
"monster_snark",
"monster_tentacle",
"monster_zombie",
"monster_sentry",
}--]]

-----------------------------------------------------------------------

-- disable dead rnger on spawn
if SERVER then
	local function dringerspawn( p )
if p:GetNWBool("DeadRingerDead") == true then
p:SetNWBool(	"DeadRingerStatus",			0)
p:GetViewModel():SetMaterial("")
p:SetMaterial("")
p:SetColor(255,255,255,255)
end
p:SetNWBool(	"DeadRingerStatus",			0)
p:SetNWBool(	"DeadRingerDead",			false)
p:SetNWBool(	"DeadRingerCanAttack",			true)
p:SetNWInt("drcharge", 8 )

	end
	hook.Add( "PlayerSpawn", "DRingerspawn", dringerspawn );
end
-----------------------------------
function SWEP:Initialize()
	self:SetHoldType("normal")
	--[[sound.Add( {
		name = "deadringer_beep_high",
		channel = CHAN_AUTO,
		volume = 1,
		level = 40,
		pitch = { 100 },
		sound = "buttons/blip1.wav"
	} )
	sound.Add( {
		name = "deadringer_beep_low",
		channel = CHAN_AUTO,
		volume = 1,
		level = 40,
		pitch = { 73 },
		sound = "buttons/blip1.wav"
	} )--]]
end
-----------------------------------
function SWEP:Deploy()
if SERVER then
		
		self.Owner:DrawWorldModel(false) -- (Turn these to false if you dont want worldmodels)

local ent = ents.Create("deadringer")			
ent:SetOwner(self.Owner) 
ent:SetParent(self.Owner)
ent:SetPos(self.Owner:GetPos())
ent:SetColor(self.Owner:GetColor())
ent:SetMaterial(self.Owner:GetMaterial())
ent:Spawn()	
end

self.Weapon:SendWeaponAnim( ACT_VM_DRAW )
--timer.Simple( 0.8, function() self.Weapon:SendWeaponAnim( ACT_VM_IDLE ) end )
self.Weapon:EmitSound(Sound( "weapons/draw_dead_ringer_spy.wav" ), 40, 100, 0.6 )
if !self.Owner:GetNWBool("DeadRingerStatus") == 3 or !self.Owner:GetNWBool("DeadRingerStatus") == 4 or !self.Owner:GetNWBool("DeadRingerStatus") == 1 then
self.Owner:SetNWBool(	"DeadRingerStatus",			2)
end
return true
end
-----------------------------------
function SWEP:Think()
end

if SERVER then
function SWEP:Holster()
	local worldmodel = ents.FindInSphere(self.Owner:GetPos(),0.6)
	for k, v in pairs(worldmodel) do 
if v:GetClass() == "deadringer" and v:GetOwner() == self.Owner then
v:Remove()
end
end
return true
end
end

-----------------------------------
--------View Model material--------
-----------------------------------

if CLIENT then
local function drvm()
if not ( GAMEMODE_NAME == "terrortown" ) then

	if LocalPlayer():GetNWBool("DeadRingerDead") == true then 
	if LocalPlayer():GetViewModel():IsValid() and LocalPlayer():GetViewModel():GetMaterial("") then
		LocalPlayer():GetViewModel():SetMaterial("models/props_c17/fisheyelens")
	end
	if LocalPlayer():GetHands():IsValid() and LocalPlayer():GetHands():GetMaterial("") then
		LocalPlayer():GetHands():SetMaterial("models/props_c17/fisheyelens")
	end
	
	elseif LocalPlayer():GetNWBool("DeadRingerDead") == false then
	if LocalPlayer():GetViewModel():IsValid() and LocalPlayer():GetViewModel():GetMaterial("models/props_c17/fisheyelens") then
		LocalPlayer():GetViewModel():SetMaterial("")
	end
	if LocalPlayer():GetHands():IsValid() and LocalPlayer():GetHands():GetMaterial("models/props_c17/fisheyelens") then
		LocalPlayer():GetHands():SetMaterial("")
	end
	end
	
end

end
hook.Add( "Think", "DRVM", drvm )
end


-----------------------------------------------------------

---------------------------------
---------hooks--------
---------------------------------
if SERVER then

util.AddNetworkString( "PlayerKilled" )
util.AddNetworkString( "PlayerKilledByPlayer" )
util.AddNetworkString( "PlayerKilledSelf" )
function checkifwehaveourdr(ent,dmginfo)
local attacker = dmginfo:GetAttacker()
local getdmg = dmginfo:GetDamage()
local reducedmg = getdmg * REDUCEDAMAGE
	if ent:IsPlayer() then
	local p = ent
	local infl
		if attacker:GetClass() == "func_rotating" or attacker:GetClass() == "func_physbox" then
			if p:GetNWBool("DeadRingerCanAttack") == true and p:GetNWBool("DeadRingerDead") == false and p:GetNWBool("DeadRingerStatus") == 1 then
--			dmginfo:SetDamage(math.random(5,15))
			dmginfo:SetDamage(0)
			p:DRfakedeath()
			net.Start( "PlayerKilled" ) --the deathnotices use net instead of umsg
			net.WriteEntity( p )
			net.WriteString( attacker:GetClass() )
			net.WriteString( attacker:GetClass() )
			net.WriteString( p:GetClass() )
			net.Broadcast()
			MsgAll( p:Nick() .. " was killed by " .. attacker:GetClass() .. "\n" )
			elseif p:GetNWBool("DeadRingerCanAttack") == false and p:GetNWBool("DeadRingerDead") == true and p:GetNWBool("DeadRingerStatus") == 3 then
--			dmginfo:SetDamage(math.random(0,1))
			dmginfo:SetDamage(0)
			end
		elseif attacker:IsPlayer() then
			if p:GetNWBool("DeadRingerCanAttack") == true and p:GetNWBool("DeadRingerDead") == false and p:GetNWBool("DeadRingerStatus") == 1 then
--			dmginfo:SetDamage(getdmg - reducedmg )
			dmginfo:SetDamage(0)
			p:DRfakedeath()
			net.Start( "PlayerKilledByPlayer" )
			net.WriteEntity( p )
			net.WriteString( attacker:GetActiveWeapon():GetClass() )
			net.WriteEntity( attacker )
			net.Broadcast()
			if attacker == p then
				MsgAll( p:Nick() .. " suicided!\n" )
			else
				MsgAll( attacker:Nick() .. " killed " .. p:Nick() .. " using " .. attacker:GetActiveWeapon():GetClass() .. "\n" )
			end
			elseif p:GetNWBool("DeadRingerCanAttack") == false and p:GetNWBool("DeadRingerDead") == true and p:GetNWBool("DeadRingerStatus") == 3 then
--			dmginfo:SetDamage(getdmg - reducedmg )
			dmginfo:SetDamage(0)
			end
		elseif attacker:IsNPC() then
			if p:GetNWBool("DeadRingerCanAttack") == true and p:GetNWBool("DeadRingerDead") == false and p:GetNWBool("DeadRingerStatus") == 1 then
--			dmginfo:SetDamage(getdmg - reducedmg )
			dmginfo:SetDamage(0)
			p:DRfakedeath()
			-- if npc has weapon (eg: metrocop with stunstick) then inflictor = npc's weapon
			if IsValid(attacker:GetActiveWeapon()) then
			infl = attacker:GetActiveWeapon():GetClass()
			-- else  (eg: zombie or hunter) then inflictor = attacker
			else
			infl = attacker:GetClass()
			end
			net.Start( "PlayerKilled" )
			net.WriteEntity( p )
			net.WriteString( infl )
			net.WriteString( attacker:GetClass() )
			net.Broadcast()
			MsgAll( p:Nick() .. " was killed by " .. attacker:GetClass() .. "\n" )
			elseif p:GetNWBool("DeadRingerCanAttack") == false and p:GetNWBool("DeadRingerDead") == true and p:GetNWBool("DeadRingerStatus") == 3 then
--			dmginfo:SetDamage(getdmg - reducedmg )
			dmginfo:SetDamage(0)
			end
		else
			if p:GetNWBool("DeadRingerCanAttack") == true and p:GetNWBool("DeadRingerDead") == false and p:GetNWBool("DeadRingerStatus") == 1 then
--			dmginfo:SetDamage(getdmg - reducedmg )
		--[[if attacker:IsValid() then
			if attacker:GetClass() == "trigger_hurt" then
				local triggerhurt_table = attacker:GetKeyValues()
				local th_table_getkeys = table.GetKeys(triggerhurt_table)
				if th_table_getkeys 
					
				end
				dmginfo:SetDamage(0)
				else if attacker:GetClass() == "func_rotating" or attacker:GetClass() == "func_physbox" then
				dmginfo:SetDamage(0)
				end
			end
		end--]]
			dmginfo:SetDamage(0)
			p:DRfakedeath()
			if attacker == p or attacker:GetClass() == "trigger_hurt" then
			net.Start( "PlayerKilledSelf" )
			else
			net.Start( "PlayerKilled" )
			end
			net.WriteEntity( p )
			net.WriteString( attacker:GetClass() )
			net.WriteString( attacker:GetClass() )
			net.Broadcast()
			if attacker == p or attacker:GetClass() == "trigger_hurt" then
				MsgAll( p:Nick() .. " suicided!\n" )
			else
				MsgAll( p:Nick() .. " was killed by " .. attacker:GetClass() .. "\n" )
			end
			elseif p:GetNWBool("DeadRingerCanAttack") == false and p:GetNWBool("DeadRingerDead") == true and p:GetNWBool("DeadRingerStatus") == 3 then
--			dmginfo:SetDamage(getdmg - reducedmg )
			if attacker:GetClass() == "trigger_hurt" or attacker:GetClass() == "func_rotating" or attacker:GetClass() == "func_physbox" then
				dmginfo:SetDamage(0)
				else
				dmginfo:SetDamage(0)
			end
			end
		end
	end
end
hook.Add("EntityTakeDamage", "CheckIfWeHaveDeadRinger", checkifwehaveourdr)
end
if SERVER then
function disablefakecorpseondeath(p, attacker)
if p:IsValid() and p:GetNWBool("DeadRingerCanAttack") == false and p:GetNWBool("DeadRingerDead") == true and p:GetNWBool("DeadRingerStatus") == 3 then
p:DRuncloak()

end
end
hook.Add("DoPlayerDeath", "RemoveFakeCorpse", disablefakecorpseondeath)

-- here goes the dead ringer charge/regenerating system
function drthink()
	for _, p in pairs(player.GetAll()) do
		if p:IsValid() and p:GetNWBool("DeadRingerDead") == false and p:GetNWBool("DeadRingerStatus") == 4 then
			if p:GetNWInt("drcharge") < 8 then
			p.drtimer = p.drtimer or CurTime() + 2
				if CurTime() > p.drtimer then
				p.drtimer = CurTime() + 2
				p:SetNWInt("drcharge", p:GetNWInt("drcharge") + 1)
				end
			elseif 	p:GetNWInt("drcharge") == 8 then
			p:SetNWBool("DeadRingerStatus", 1)
			--umsg.Start( "DRReady", p ) --this part isn't broken so uh i'm just gonna leave it? -- {annoying sound}
			--umsg.End()
			end
		elseif p:IsValid() and p:GetNWBool("DeadRingerDead") == true and p:GetNWBool("DeadRingerStatus") == 3 then
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
						if npc:GetEnemy() == p then
							npc:ClearEnemyMemory()
						end
						--end
					--end
				end
			end
			p:SetNoTarget( true )
			if p:KeyPressed( IN_ATTACK2 ) then
			p:DRuncloak()
			--p:SetNWInt("drcharge", 7 ) -- {originally 2, prob never need this}
			end
			if p:GetNWInt("drcharge") <= 8 and p:GetNWInt("drcharge") > 0 then
			p.cltimer = p.cltimer or CurTime() + 1
				if CurTime() > p.cltimer then
				--p.cltimer = CurTime() + 1 -- {nope.avi}
				--p:SetNWInt("drcharge", p:GetNWInt("drcharge") - 1) -- {nope.avi}
				end
			elseif p:GetNWInt("drcharge") == 0 then
				p:DRuncloak()
			end
		end
	end
end
hook.Add( "Think", "DR_ENERGY", drthink )



end

function DRFootsteps( p, vPos, iFoot, strSoundName, fVolume, pFilter )
	
	if p:Alive() and p:IsValid() then
		if p:GetNWBool("DeadRingerCanAttack") == false and p:GetNWBool("DeadRingerDead") == true and p:GetNWBool("DeadRingerStatus") == 3 then
			if CLIENT then
				return true
			end
		end
	end
	
end

hook.Add("PlayerFootstep","DeadRingerFootsteps",DRFootsteps)


-------------------------------------------------------------------------------

function SWEP:PrimaryAttack()

if self.Owner:GetNWBool("DeadRingerCanAttack") == true and self.Owner:GetNWBool("DeadRingerDead") == false and self.Owner:GetNWBool("DeadRingerStatus") != 4 then

self.Owner:SetNWBool(	"DeadRingerStatus",			1)

--self.Weapon:EmitSound("deadringer_beep_high")--, 40, 100, 1)
umsg.Start( "DRBeepHigh", self.Owner )
umsg.End()

else
return
end
end

function SWEP:SecondaryAttack()

if self.Owner:GetNWBool("DeadRingerCanAttack") == true and self.Owner:GetNWBool("DeadRingerDead") == false and self.Owner:GetNWBool("DeadRingerStatus") != 4 then

self.Owner:SetNWBool(	"DeadRingerStatus",			2)

--self.Weapon:EmitSound("deadringer_beep_low")--, 40, 73, 1)
umsg.Start( "DRBeepLow", self.Owner )
umsg.End()

else
return
end
end
-------------------------------------------------------------------------------------

local meta = FindMetaTable( "Player" );

function meta:DRfakedeath()

	self:SetNWInt( "walk_speed", self:GetWalkSpeed() )
	self:SetNWInt( "run_speed", self:GetRunSpeed() )
	self:SetNWInt( "walk_speed_boost", self:GetWalkSpeed()+200 )
	self:SetNWInt( "run_speed_boost", self:GetRunSpeed()+200 )
	
function DeadRingerGiveSpeedBoost()
	self:SetWalkSpeed( self:GetNWInt( "walk_speed_boost" ) )
	self:SetRunSpeed( self:GetNWInt( "run_speed_boost" ) )
	
	umsg.Start( "DRSpeedBoostGiveSound", p )
	umsg.End()
	--self:EmitSound(Sound( "weapons/discipline_device_power_up.wav" ), 40, 100, 1)
end

function DeadRingerStopSpeedBoost()
	if self:GetWalkSpeed() < ( self:GetNWInt( "walk_speed_boost" ) + 1 ) then
		self:SetWalkSpeed( self:GetNWInt( "walk_speed" ) )
	end
	if self:GetRunSpeed() < ( self:GetNWInt( "run_speed_boost" ) + 1 ) then
		self:SetRunSpeed( self:GetNWInt( "run_speed" ) )
	end
	umsg.Start( "DRSpeedBoostStopSound", p )
	umsg.End()
	--self:EmitSound(Sound( "weapons/discipline_device_power_down.wav" ), 40, 100, 1)
end

function DeadRingerRagRemove()
	local corpse_serverside = GetConVar( "sv_dead_ringer_corpse_serverside" ):GetInt()
	-- (serverside)
		if ( self:Alive() ) then
			for _, ent in pairs(ents.GetAll()) do
				if ent:GetClass() == "prop_ragdoll" and ent:GetOwner() == self and ent.Corpse then
				ent:Remove()
				end
			end
		-- (clientside)
			if self:GetRagdollEntity():IsValid() then
				self:GetRagdollEntity():Remove()
			end
		end
end

function SelfFireExtinguish()
	local corpse_serverside = GetConVar( "sv_dead_ringer_corpse_serverside" ):GetInt()
	if self:IsOnFire() == true then
		self:Extinguish()
		if corpse_serverside > 0 then
			for _, ent in pairs(ents.GetAll()) do
				if ent:GetClass() == "prop_ragdoll" and ent:GetOwner() == self and ent.Corpse then
				ent:Ignite( 30, 0 ) -- serverside
				end
			end
			else
			if self:GetRagdollEntity():IsValid() then
			self:GetRagdollEntity():Ignite( 30, 0 ) -- clientside
			end
		end
	end
end
function DeathSoundReady()
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
end

timer.Remove("DeadRingerGiveSpeedBoostTimer")
timer.Remove("DeadRingerStopSpeedBoostTimer")
timer.Remove("DeadRingerVaporizeDisableTimer")
timer.Remove("DeadRingerRagdollTimer1")
DeadRingerRagRemove()

timer.Remove("DeathBeep1Timer")
timer.Remove("DeathBeep2Timer")
timer.Remove("DeathBeep3Timer")
timer.Remove("DeathBeep4Timer")
timer.Remove("DeathBeep5Timer")

timer.Remove("DeadRingerCloakFadeinTimer")

self:SetNWBool("DeadRingerVaporize", true)
timer.Create( "DeadRingerVaporizeDisableTimer", 0.1, 1, function()
	self:SetNWBool("DeadRingerVaporize", false)
end )
self:SetNWBool("DeadRingerDead", true)
timer.Create( "DeadRingerGiveSpeedBoostTimer", 0.02, 1, function()  -- If you're wondering about this, it delays the speed boost affecting the ragdoll
	DeadRingerGiveSpeedBoost()
end )
timer.Create( "DeadRingerStopSpeedBoostTimer", 3.00, 1, function() 
	DeadRingerStopSpeedBoost()
end )
self:SetNWBool("DeadRingerCanAttack", false)
self:SetNWBool("DeadRingerStatus", 3)
self:SetNoDraw(true)
-- ClientSide Player Ragdoll
if GetConVar( "sv_dead_ringer_corpse_serverside" ):GetInt() < 1 then
	local ragdoll = self:CreateRagdoll()
	local ent = self:GetRagdollEntity()
end
local sound_owner = self
sound_owner:StopSound("player.death")
sound_owner:StopSound("death_beep")
sound_owner:StopSound("death_flatline")
--timer.Simple( 0.05, function () self:SetMaterial("null") end ) -- (Must put SetMaterial on a timer, else client ragdoll will be invisible) [kind of pointless when there's SetNoDraw]
self:DrawShadow(false)
self:AddDeaths( 1 )
self:AddFrags( -1 )
timer.Create( "FireImmuneTimer", 0.1, 4, function() SelfFireExtinguish() end )

random_sound = { 1, 2, 3 }
local sound_math = table.Random( random_sound )
local death_sound_enable = GetConVar( "sv_dead_ringer_death_sound" ):GetInt()
if death_sound_enable > 0 then
	if sound_math == 1 then
	sound_owner:EmitSound("player.death")
	else if sound_math >= 2 then
		DeathSoundReady()
	
	sound_owner:EmitSound("death_beep")
	timer.Create( "DeathBeep1Timer", 0.20, 1, function() 
	
		sound_owner:EmitSound("death_beep") 	
	
		timer.Create( "DeathBeep2Timer", 0.52, 1, function() 
	
			sound_owner:EmitSound("death_beep") 
			
			timer.Create( "DeathBeep3Timer", 0.20, 1, function() 
	
				sound_owner:EmitSound("death_beep") 
	
				timer.Create( "DeathBeep4Timer", 0.48, 1, function() 
				
					sound_owner:EmitSound("death_beep") 
					
					if sound_math == 2 then
					timer.Create( "DeathBeep5Timer", 0.50, 1, function() 
					
						sound_owner:EmitSound("death_beep") 
					
						timer.Simple( 0.50, function() 
						
							sound_owner:EmitSound("death_flatline", level, pitch, volume) 
						
						end )
						
					end )
					else
						timer.Simple( 0.50, function() 
					
							sound_owner:EmitSound("death_flatline", level, pitch, volume) 
					
						end )
					end
					
				end )
	
			end )
	
		end )
	
	end )
	
	end
end
end

function LeftTheVehicle( ply, vehicle )
	if ply:GetNWBool("DeadRingerCanAttack") == false and ply:GetNWBool("DeadRingerDead") == true and ply:GetNWBool("DeadRingerStatus") == 3 then
		self:SetNoDraw(true)
	end
end

hook.Add( "PlayerLeaveVehicle", "DeadRingerVehicleLeave", LeftTheVehicle )

---------------------------
--------"corpse"-------
---------------------------
-- this is time to make our corpse (serverside)
if GetConVar( "sv_dead_ringer_corpse_serverside" ):GetInt() > 0 then
	local pos = self:GetPos()
	local ang = self:GetAngles()
	local mdl = self:GetModel()
	local skn = self:GetSkin()
	local bdg = self:GetBodyGroups()
	local col = self:GetColor()
	local mat = self:GetMaterial()
	local plycol = self:GetPlayerColor()
	
-- create the ragdoll
local ent = ents.Create("prop_ragdoll")

	ent:SetPos(pos)
	ent:SetAngles(ang - Angle(ang.p,0,0))
	ent:SetModel(mdl)
	ent:SetSkin(skn)
	for k,v in pairs(bdg) do
		ent:SetBodygroup(v.id,self:GetBodygroup(v.id))
	end
	ent:SetMaterial("")
	ent:SetOwner(self)
	ent:SetColor(col)
	ent:Spawn()	
	ent:SetCollisionGroup(COLLISION_GROUP_WEAPON or COLLISION_GROUP_NONE)
	ent.Corpse = true
	ent.sid = self:SteamID()
	
 local vel = self:GetVelocity()
 
	for i = 1, ent:GetPhysicsObjectCount() do
		local bone = ent:GetPhysicsObjectNum(i)
	
		if bone and bone.IsValid and bone:IsValid() then
			local bonepos, boneang = self:GetBonePosition(ent:TranslatePhysBoneToBone(i))
			
			bone:SetPos(bonepos)
			bone:SetAngles(boneang)
			
			ent:GetPhysicsObject():AddVelocity(vel/12)
			bone:AddVelocity(vel*1.2) -- (originally 2)
		end
	end
end

function DeadRingerRagdollForce(ent,dmginfo)
--print("Hook called!")
	if ent:IsPlayer() then
		--print("Player detected!")
		if ent:IsValid() and ent:GetNWBool("DeadRingerDead") == true and ent:GetNWBool("DeadRingerStatus") == 3 then
			--print("Invisibility validated!")
			-- Vaporize Check
			if ent:GetNWBool("DeadRingerVaporize", true) and dmginfo:IsDamageType(DMG_DISSOLVE) then
				--print("Damage found as dissolve!")
				local dissolve = ents.Create("env_entity_dissolver")
				dissolve:SetKeyValue("magnitude",0)
				dissolve:SetKeyValue("dissolvetype",0)
				dissolve:SetKeyValue("target","dead_ringer_ragdoll_to_dissolve")
				dissolve:SetPos(ent:GetPos())
				dissolve:Spawn()
				-- Actual Vaporization
				if GetConVar( "sv_dead_ringer_corpse_serverside" ):GetInt() > 0 then
					for _, entr in pairs(ents.GetAll()) do
						if entr:GetClass() == "prop_ragdoll" and entr:GetOwner() == ent and entr.Corpse then
							entr:SetName("dead_ringer_ragdoll_to_dissolve")
							--[[for j = 1, entr:GetPhysicsObjectCount() do
								local bone = entr:GetPhysicsObjectNum(j)
								if bone and bone.IsValid and bone:IsValid() then
									bone:EnableGravity( false )
									entr:GetPhysicsObject():EnableGravity( false )
									bone:SetVelocity( ent:GetVelocity()/5 )
								end
							end--]]
							--print("Serverside ragdoll dissolve called!")
						end
					end -- serverside
				else if GetConVar( "sv_dead_ringer_corpse_serverside" ):GetInt() < 1 then
					local client_ragdoll = ent:GetRagdollEntity()
					if client_ragdoll:IsValid() then
						client_ragdoll:SetName("dead_ringer_ragdoll_to_dissolve")
						--print("Clientside ragdoll dissolve called!")
					end -- clientside
				end
				end
				dissolve:Fire("Dissolve","",0)
				dissolve:Fire("kill","",0.1)
				for _, obj in pairs(ents.GetAll()) do
					if obj:GetName() == "dead_ringer_ragdoll_to_dissolve" then
						obj:SetName("dead_ringer_ragdoll_to_dissolve")
					end
				end
			end
			-- Ignition Check
			--[[if dmginfo:IsDamageType(DMG_BURN) then -- Almost functional, except the part this applies to every entityflame
				function NoDamage()
					dmginfo:SetDamage( 0 )
					dmginfo:SetDamageType( DMG_GENERIC )
					dmginfo:SetDamageForce( Vector( 0, 0, 0 ) )
				end
				if GetConVar( "sv_dead_ringer_corpse_serverside" ):GetInt() > 0 then
					for _, entr in pairs(ents.GetAll()) do
						if entr:GetClass() == "prop_ragdoll" and entr:GetOwner() == ent and entr.Corpse then
							for _, flame in pairs(ents.GetAll()) do
								if flame:GetClass() == "entityflame" and flame:GetParent() == entr then
									NoDamage()
								end
							end
						end
					end
					else if GetConVar( "sv_dead_ringer_corpse_serverside" ):GetInt() < 1 then
						local client_ragdoll = ent:GetRagdollEntity()
						if client_ragdoll:IsValid() then
							for _, flame in pairs(ents.GetAll()) do
								if flame:GetClass() == "entityflame" and flame:GetParent() == client_ragdoll then
									NoDamage()
								end
							end
						end
					end
				end
			end--]]
		end
	end
end
	
	hook.Add("EntityTakeDamage", "DeadRingerCheckDamage", DeadRingerRagdollForce)
	
end

-- here goes the uncloak function
function meta:DRuncloak()
	
	if self:Alive() then
		local corpse_time = GetConVar( "sv_dead_ringer_corpse_time" ):GetInt()
		if corpse_time > 50 then
			corpse_time = 50
		end
		if corpse_time > -1 then
		timer.Create( "DeadRingerRagdollTimer1", corpse_time, 1, function() DeadRingerRagRemove() end ) -- (original time when timer-cvar wasn't added was 15)
		end
	end
	
	--[[for _,npc in pairs(ents.GetAll()) do 
		if npc:IsNPC() then 
			for k,v in pairs(NPCs) do 
				if npc:GetClass() == v then
				npc:AddEntityRelationship(self,D_HT,99) 
				end
			end
		end
	end--]]
	self:SetNoTarget( false )
	
	self:SetNWBool("DeadRingerVaporize", false)
	self:SetNWBool(	"DeadRingerDead",			false)
	if ( timer.Exists( "DeadRingerStopSpeedBoostTimer" ) ) then
	timer.Remove("DeadRingerStopSpeedBoostTimer")
	DeadRingerStopSpeedBoost()
	end
	timer.Remove("DeadRingerGiveSpeedBoostTimer")
	timer.Remove("DeadRingerVaporizeDisableTimer")
	timer.Remove("DeadRingerCloakFadeinTimer")
	self:SetNWBool(	"DeadRingerCanAttack",			true)
	self:SetNWBool(	"DeadRingerStatus",			4)
	self:GetViewModel():SetMaterial("")
	self:SetMaterial("")
	self:RemoveAllDecals()
	self:SetColor(Color(255,255,255,255))
	self:SetNoDraw(false)
	self:DrawShadow(true)
	self:AddDeaths( -1 )
	self:AddFrags( 1 )
	self:RemoveAllDecals()
	
	if !self:InVehicle() then
	self:DrawWorldModel(true)
	else
	self:DrawWorldModel(false)
	end
	
	self:SetMaterial("")

	self:EmitSound(Sound( "player/spy_uncloak.wav"), 75, 100, 0.5 ) -- (originally spy_uncloak_feigndeath)
function SomethingFunny()
	self:EmitSound(Sound( "player/spy_uncloak_feigndeath.wav"), 75, 100, 0.3 )
end
function SomethingFunnytoInitiate()
SomethingFunny()
SomethingFunny()
SomethingFunny()
SomethingFunny()
SomethingFunny()
SomethingFunny()
SomethingFunny()
SomethingFunny()
SomethingFunny()
SomethingFunny()
SomethingFunny()
SomethingFunny()
SomethingFunny()
SomethingFunny()
SomethingFunny()
end
--SomethingFunnytoInitiate()

	local effectdata = EffectData()
	effectdata:SetOrigin( self:GetPos() )
	effectdata:SetEntity( self )
	util.Effect( "uncloak", effectdata )
end