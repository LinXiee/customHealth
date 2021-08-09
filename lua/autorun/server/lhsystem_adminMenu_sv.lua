util.AddNetworkString("cH:Admin")
util.AddNetworkString("chAdmin:OpenMenu")
util.AddNetworkString("chAdmin:Give")

net.Receive("cH:Admin", function(len, ply)

    if !ply:IsAdmin() then return end
    net.Start("cHAdmin:OpenMenu")
    net.Send(ply)

end)

net.Receive("chAdmin:Give", function(len, ply)

    if !ply:IsAdmin() then return end
    local med = net.ReadString()
    local receiver = net.ReadEntity()

    print(med)
    ply:AddMedkit(med)
end)