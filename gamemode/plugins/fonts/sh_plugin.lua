PLUGIN.name = "Fonts"
PLUGIN.author = "Apsys"
PLUGIN.desc = "Font Library inspired by 'Minerva SCP RP'"

mrp.Config.Font = "Arial"

mrp.font = mrp.font or {}
mrp.font.Stored = mrp.font.Stored or {}

if ( CLIENT ) then
    function mrp.font.Define(font, data)
        surface.CreateFont(font, data)
        
        mrp.font.Stored[font] = data
    end
    
    for i = 3, 250 do
        mrp.font.Define("mrp-Font"..tostring(i), {
            font = mrp.Config.Font,
            size = i,
            antialias = true,
            shadow = true,
            outline = true
        })
        
        mrp.font.Define("mrp-Font"..tostring(i).."-Shadow", {
            font = mrp.Config.Font,
            size = i,
            antialias = true,
            shadow = true,
            outline = true
        })
    end
end