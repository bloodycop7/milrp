net.Receive("mrpBodygroupView", function()
    vgui.Create("mrpBodygroupView"):Display(net.ReadEntity())
end)