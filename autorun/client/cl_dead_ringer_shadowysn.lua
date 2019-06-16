if (SERVER) then return end

CreateClientConVar( "cl_dead_ringer_blue_hud", 0, true, false, 
		"Should the charge meter be blue?" )
CreateClientConVar( "cl_dead_ringer_hud_enable", 1, true, false, 
	"Should the dead ringer hud be visible?" )
CreateClientConVar( "cl_dead_ringer_speedboost_sound", 1, true, false, 
	"Should the speed boost sounds play?" )

hook.Add("HUDDrawTargetID","Shadowysn_DRDisallowCloakingIDPopup",function()
local eyetrace = LocalPlayer():GetEyeTrace()
local hulltrace = util.TraceHull( {
	start = eyetrace.StartPos,
	endpos = eyetrace.HitPos
} )
local ply = hulltrace.Entity
local eyeply = eyetrace.Entity

if IsValid(ply) and ply:IsPlayer() and ply:Alive() and ply:GetNWBool("Shadowysn_DeadRingerDead") == true and ply:GetNWBool("Shadowysn_DeadRingerStatus") == 3 then
	return false
end
if IsValid(eyeply) and eyeply:IsPlayer() and eyeply:Alive() and eyeply:GetNWBool("Shadowysn_DeadRingerDead") == true and eyeply:GetNWBool("Shadowysn_DeadRingerStatus") == 3 then
	return false
end

end)

hook.Add("DrawPhysgunBeam","Shadowysn_DRDisallowCloakingPhysgunBeam",function( owner )
	if owner:GetNWBool("Shadowysn_DeadRingerDead") == true and owner:GetNWBool("Shadowysn_DeadRingerStatus") == 3 then
	return false
	end
end)

local function Shadowysn_drawdr()
--here goes the new HUD
if (LocalPlayer():GetNWBool("Shadowysn_DeadRingerStatus") == 1 or LocalPlayer():GetNWBool("Shadowysn_DeadRingerStatus") == 3 or LocalPlayer():GetNWBool("Shadowysn_DeadRingerStatus") == 4) and LocalPlayer():Alive() and GetConVar( "cl_dead_ringer_hud_enable" ):GetInt() >= 1 then
local background = surface.GetTextureID("HUD/misc_ammo_area_red")
local background2 = surface.GetTextureID("HUD/misc_ammo_area_blue")
local w,h = surface.GetTextureSize(surface.GetTextureID("HUD/misc_ammo_area_red"))
	if GetConVar( "cl_dead_ringer_blue_hud" ):GetInt() <= 0 then
	surface.SetTexture(background)
	else
	surface.SetTexture(background2)
	end
	surface.SetDrawColor(255,255,255,255)
	surface.DrawTexturedRect(13, ScrH() - h - 200, w*5, h*5 )

local energy = math.max(LocalPlayer():GetNWInt("Shadowysn_drcharge"), 0)
if GetConVar( "cl_dead_ringer_blue_hud" ):GetInt() <= 0 then
	draw.RoundedBox(2,44, ScrH() - h - 168, (energy / 8) * 77, 15, Color(255,222,255,255))
else
	draw.RoundedBox(2,44, ScrH() - h - 168, (energy / 8) * 77, 15, Color(242,235,225,255))
end
surface.SetDrawColor(255,255,255,255)
surface.DrawOutlinedRect(44, ScrH() - h - 168, 77, 15)
draw.DrawText("FEIGN", "DRfont",68, ScrH() - h - 150, Color(255,255,255,255))
end

end
--[[local function Shadowysn_drawdr()
if LocalPlayer():GetNWBool("Status") == 1 or LocalPlayer():GetNWBool("Status") == 3 or LocalPlayer():GetNWBool("Status") == 4 and LocalPlayer():Alive() then
local background = surface.GetTextureID("HUD/misc_ammo_area_red")
local background2 = surface.GetTextureID("HUD/misc_ammo_area_blue")
local w,h = surface.GetTextureSize(surface.GetTextureID("HUD/misc_ammo_area_red"))
if GetConVar( "cl_dead_ringer_blue_hud" ):GetInt() == 0 then
surface.SetTexture(background)
else
surface.SetTexture(background2)
end
surface.SetDrawColor(255,255,255,255)
surface.DrawTexturedRect(892, ScrH() - h - 140, w*4, h*4 )

local energy = math.max(LocalPlayer():GetNWInt("InsertNameHere_drcharge"), 0)
if GetConVar( "cl_dead_ringer_blue_hud" ):GetInt() == 0 then
draw.RoundedBox(2,920, ScrH() - h - 118, 55, 12, Color(156,141,141))
draw.RoundedBox(2,920, ScrH() - h - 118, (energy / 200) * 55, 12, Color(255,222,255,255))
else
draw.RoundedBox(2,920, ScrH() - h - 118, 55, 12, Color(156,141,141))
draw.RoundedBox(2,920, ScrH() - h - 118, (energy / 200) * 55, 12, Color(255,255,222,255))
end
surface.SetDrawColor(255,255,255,255)
draw.DrawText("F E I G N", "DRfont",934, ScrH() - h - 105, Color(255,255,255,255))
end
end--]]
hook.Add("HUDPaint", "Shadowysn_drawdr", Shadowysn_drawdr)

local function Shadowysn_DRReady()
surface.PlaySound( "player/recharged.wav" )
end
net.Receive("Shadowysn_DRReady", Shadowysn_DRReady)

local function Shadowysn_DRBeepHigh()
sound.Play( "buttons/blip1.wav", LocalPlayer():GetPos(), 90, 100, 1 )
--[[if LocalPlayer():HasWeapon("weapon_dead_ringer") then
	chat.AddText("You have two dead ringer addons!")
end--]]
end
net.Receive("Shadowysn_DRBeepHigh", Shadowysn_DRBeepHigh)

local function Shadowysn_DRBeepLow()
sound.Play( "buttons/blip1.wav", LocalPlayer():GetPos(), 75, 73, 1 )
end
net.Receive("Shadowysn_DRBeepLow", Shadowysn_DRBeepLow)

local function Shadowysn_DRSpeedBoostGiveSound()
if GetConVar("cl_dead_ringer_speedboost_sound"):GetInt() > 0 then
sound.Play( "weapons/discipline_device_power_up.wav", LocalPlayer():GetPos(), 90, 100, 1 )
end
end
net.Receive("Shadowysn_DRSpeedBoostGiveSound", Shadowysn_DRSpeedBoostGiveSound)

local function Shadowysn_DRSpeedBoostStopSound()
if GetConVar("cl_dead_ringer_speedboost_sound"):GetInt() > 0 then
sound.Play( "weapons/discipline_device_power_down.wav", LocalPlayer():GetPos(), 90, 100, 1 )
end
end
net.Receive("Shadowysn_DRSpeedBoostStopSound", Shadowysn_DRSpeedBoostStopSound)

local GetRag = {}

local function Shadowysn_DRSetServerRagdollColor()
	local rag = net.ReadInt(32)
	local ply = net.ReadInt(32)
	local col = net.ReadVector()
	if !ply or ply == nil then return end
	if !col or col == nil then return end
	GetRag = {rag=rag,ply=ply,col=col}
end
net.Receive("Shadowysn_DRReceiveClientInfo",Shadowysn_DRSetServerRagdollColor)

hook.Add("NetworkEntityCreated","Shadowysn_DRSetRagdollPlayerColor",function(ent)
	if not GetRag.rag then return end
	if GetRag.rag==ent:EntIndex() then
		local getcol = GetRag.col
		Entity(GetRag.rag).GetPlayerColor = function(self) return getcol end
		GetRag = {}
	end
end)

local function Shadowysn_drvm()
if not ( GAMEMODE_NAME == "terrortown" ) then

	if LocalPlayer():GetNWBool("Shadowysn_DeadRingerDead") == true then 
	if IsValid(LocalPlayer():GetViewModel()) and viewcloaked != true then
		LocalPlayer():GetViewModel():SetMaterial("models/props_c17/fisheyelens")
		viewcloaked = true
	end
	if IsValid(LocalPlayer():GetHands()) and handcloaked != true then
		LocalPlayer():GetHands():SetMaterial("models/props_c17/fisheyelens")
		handcloaked = true
	end
	end
	
	if LocalPlayer():GetNWBool("Shadowysn_DeadRingerDead") != true then
	if IsValid(LocalPlayer():GetViewModel()) and viewcloaked == true then
		LocalPlayer():GetViewModel():SetMaterial("")
		viewcloaked = nil
	end
	if IsValid(LocalPlayer():GetHands()) and handcloaked == true then
		LocalPlayer():GetHands():SetMaterial("")
		handcloaked = nil
	end
	end
	
end

end
hook.Add( "Think", "Shadowysn_DRVM", Shadowysn_drvm )