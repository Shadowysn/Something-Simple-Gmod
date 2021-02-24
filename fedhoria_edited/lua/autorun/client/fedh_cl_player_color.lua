local GetRag = {}

net.Receive("Fedhoria_Ragdoll_GetPlayerColor", function() 
	local rag = net.ReadInt(32)
	local ply = net.ReadInt(32)
	local col = net.ReadVector()
	if !col or col == nil then return end
	GetRag = {rag = rag, ply = ply, col = col}
end)

hook.Add("NetworkEntityCreated","Fedhoria_Ragdoll_SetPlayerColor",function(ent)
	if not GetRag.rag then return end
	if GetRag.rag == ent:EntIndex() then
		local getcol = GetRag.col
		local getrag_ply = Entity(GetRag.ply)
		local getrag_rag = Entity(GetRag.rag)
		getrag_rag.GetPlayerColor = function(self) return getcol end
		
		if IsValid(getrag_ply) and getrag_ply:GetModel() == getrag_rag:GetModel() then
			getrag_rag:SnatchModelInstance(getrag_ply)
		end
		
		GetRag = {}
	end
end)