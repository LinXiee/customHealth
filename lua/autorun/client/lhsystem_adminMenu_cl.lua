--

hook.Add("OnPlayerChat", "cH:Admin", function(ply, text, teamChat, isDead)

    if IsDead then return false end 

    if text == "!cHealthAdmin" then
        if !ply:IsAdmin() then return true end 
        net.Start("cH:Admin")
        net.SendToServer()
        return true
    end

    return false
end)

net.Receive("chAdmin:OpenMenu", function() 

    local ScrW, ScrH = ScrW(), ScrH()

    local FrameW, FrameH = ScrW/1.5, ScrH/1.3
    local Frame = vgui.Create("XeninUI.Frame") -- Frame
        Frame:SetSize(FrameW, FrameH)
        Frame:Center()
        Frame:MakePopup()
        Frame:SetTitle("Admin Menu")
    
    local ScrollW, ScrollH = FrameW - 10, FrameH - 50
    local Scroll = vgui.Create("XeninUI.ScrollPanel", Frame)
        Scroll:SetSize(ScrollW, ScrollH)
        Scroll:Center()
        Scroll:AlignBottom(6)

    local IconLayoutW, IconLayoutH = ScrollW - 20, ScrollH
    local IconLayout = vgui.Create("DIconLayout", Scroll)
        IconLayout:SetSize(IconLayoutW, IconLayoutH)
        IconLayout:SetSpaceY(5)
        IconLayout:SetSpaceX(3)
        IconLayout:AlignTop(3)
        IconLayout:AlignLeft(3)
        IconLayout.Paint = function(self, w, h)

        end

    for k,v in pairs(cHealth.cfg.Meds) do
        local ListItemW, ListItemH = IconLayoutW, IconLayoutH/6
        local ListItem = IconLayout:Add("XeninUI.Panel")
        ListItem:SetSize(ListItemW, ListItemH)
        ListItem.Paint = function(self, w, h)

            draw.RoundedBox(5, 0, 0, w, h, XeninUI.Theme.Navbar)
            draw.SimpleText(v.Name, "HeaderFont", ListItemW/6 , ListItemH/10, color_white, TEXT_ALIGN_LEFT,TEXT_ALIGN_LEFT)
            draw.SimpleText(v.Description, "cHealthFont", ListItemW/6, ListItemH/2.8, color_white, TEXT_ALIGN_LEFT, TEXT_ALIGN_LEFT)
            

        end

        local Model = vgui.Create("DModelPanel", ListItem)
        Model:SetSize(IconLayoutW/10, IconLayoutH/6)
        Model:Center()
        Model:AlignLeft(15)
        Model:SetCursor("arrow")
        Model:SetModel(v.Model)
        Model:SetCamPos(Model:GetCamPos() + Vector(-30,-50,-50))
        Model:SetLookAt(Vector(0,0,0))
        Model:SetLookAng(Model:GetLookAng())        

        local buttonGive = vgui.Create("XeninUI.Button", ListItem)
        buttonGive:SetSize(IconLayoutW/7, IconLayoutH/18)
        buttonGive:AlignTop(13)
        buttonGive:AlignRight(15)
        buttonGive.Paint = function(self, w, h)

            draw.RoundedBox(5, 0, 0, w, h, XeninUI.Theme.Purple)
            draw.SimpleText("Give To", "HeaderFont", w/2, h/2, color_white, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)

        end

        local buttonSelf = vgui.Create("XeninUI.Button", ListItem)
        buttonSelf:SetSize(IconLayoutW/7, IconLayoutH/18)
        buttonSelf:AlignBottom(13)
        buttonSelf:AlignRight(15)
        buttonSelf.Paint = function(self, w , h)

            draw.RoundedBox(5, 0, 0, w, h, XeninUI.Theme.Purple)
            draw.SimpleText("Give self", "HeaderFont", w/2, h/2, color_white, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)

        end

        buttonGive.DoClick = function()
            
            local Menu = DermaMenu()
    
                for k, v in ipairs(player.GetAll()) do
                    
                    local Option = Menu:AddOption(v:GetName())
                    Option:SetTextColor(color_white)
                    Option.ply = v
    
                end
    
                Menu.Paint = function(self, w, h)
    
                    draw.RoundedBox(10, 0, 0, w, h, XeninUI.Theme.Navbar)
    
                end
    
                -- Open the menu
                Menu:Open()
    
                function Menu:OptionSelected(panel, optionText)
    
                    net.Start("chAdmin:Give")
                    net.WriteString(k)
                    net.WriteEntity(panel.ply)
                    net.SendToServer()
    
                    if panel.ply == LocalPlayer() then
                        chat.AddText(XeninUI.Theme.Orange,"[cHealth] ", color_white, "Gave yourself ", k)

                    else 
                        chat.AddText(XeninUI.Theme.Orange, "[cHealth] ", color_white, "Gave ", k, " to ", panel.ply:GetName())
                    end

                end

        end 

        buttonSelf.DoClick = function()

            net.Start("chAdmin:Give")
            net.WriteString(k)
            net.WriteEntity(LocalPlayer())
            net.SendToServer()

            chat.AddText(XeninUI.Theme.Orange,"[cHealth] ", color_white, "Gave yourself ", k)

            Frame:Remove()
        end

    end
    
end)

