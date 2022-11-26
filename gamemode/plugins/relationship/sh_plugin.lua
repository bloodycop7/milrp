mrp.relationships = mrp.relationships or {}

concommand.Add("mrp_relationship_hate", function(ply, cmd, args)
    local npcclass = args[1]
    
    if ( npcclass ) then
        for k, v in pairs(ents.FindByClass(npcclass)) do
            if ( v:IsNPC() ) then
                v.isOverriden = true
                for a, b in pairs(player.GetAll()) do
                    v:AddEntityRelationship(b, D_HT, 0) 
                end
            end
        end
    end
end)

concommand.Add("mrp_relationship_like", function(ply, cmd, args)
    local npcclass = args[1]
    
    if ( npcclass ) then
        for k, v in pairs(ents.FindByClass(npcclass)) do
            if ( v:IsNPC() ) then
                v.isOverriden = true
                for a, b in pairs(player.GetAll()) do
                    v:AddEntityRelationship(b, D_LI, 0) 
                end
            end
        end
    end
end)