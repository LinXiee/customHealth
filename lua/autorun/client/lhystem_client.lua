local color_green = Color(0,190,40, 255)
local color_red = Color(255,0,0, 255)
local color_gray = Color(50,50,50,255)

local healthBar = Material("healthbar.png")

local fracture = Material("fracture.png")
local lightBleed = Material("Bleeding.png")
local heavyBleed = Material("HeavyBleeding.png")

local testSound = Sound("heal.wav")

local menuOpen = false

local keyCooldown = 0

local keyConfig

if file.Exists("cHealth/cHealthKeyConfig.txt", "DATA") then

    local nbmr = file.Read("cHealth/cHealthKeyConfig.txt", "DATA")

    keyConfig = tonumber(nbmr)

else
    file.CreateDir("cHealth")
    file.Write("cHealth/cHealthKeyConfig.txt", "21")
end

local function HealDamage(Medkit, Bone) --Healdamage with MedkitName on Bonenmbr

    net.Start("chHealth:HealLimb")
    net.WriteUInt(Medkit, 5)
    net.WriteUInt(Bone, 3)
    net.SendToServer()

end

local function openSettings()

    local localPly = LocalPlayer()
    local scrw, scrh = ScrW(), ScrH()
    local previusBut = keyConfig

    local Frame = vgui.Create("XeninUI.Frame")
        Frame:SetSize(scrw/4, scrh/4)
        Frame:Center()
        Frame:MakePopup()
        Frame:SetTitle("Settings")

    Frame.OnRemove = function()

        if keyConfig != previusBut then
            local temp = tostring(keyConfig)

            file.Write("cHealth/cHealthKeyConfig.txt", temp)
        end

    end

    local Scroll = vgui.Create("XeninUI.ScrollPanel", Frame)
    Scroll:Dock(FILL)

    local Layout = vgui.Create("DIconLayout", Scroll)
    Layout:Dock(FILL)
    Layout:SetSpaceY(5)

    local bindtext = Layout:Add("XeninUI.Panel")
        bindtext:SetSize(scrw/4, scrh/20)
        bindtext:Center()
        bindtext.Paint = function(self, w, h)
            draw.RoundedBox(10, 0, 0, w, h, XeninUI.Theme.Navbar)
            draw.SimpleText("Open the Health Menu", "DermaDefault", w/4, h/2, color_white, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
        end

    local bind = bindtext:Add("DBinder")
        bind:SetSize(scrw/25, scrh/35)
        bind:Center()
        bind:SetValue(keyConfig)
        bind:AlignRight(50)
        bind:SetTextColor(color_white)
        bind.Paint = function(self, w, h)

            draw.RoundedBox(5, 0, 0, w, h, XeninUI.Theme.Accent)

        end

    bind.OnChange = function(self, iNum) 

        keyConfig = iNum

    end

end

concommand.Add("lhsSettings", function()

    openSettings()

end)

local function OpenMenu(Health, Meds, plyName, mdl, armor) -- Opens Menu

    local localPly = LocalPlayer()
    local mdl = mdl

    net.Start("chMenu:OpenedMenu")
    net.SendToServer()

    local Frame = vgui.Create("XeninUI.Frame") -- Frame
        Frame:SetSize(ScrW()/1.5, ScrH()/1.3)
        Frame:Center()
        Frame:MakePopup()
        Frame:SetTitle(plyName)

    menuOpen = true

        Frame.OnRemove = function()
            net.Start("chMenu:ClosedMenu")
            net.SendToServer()

            menuOpen = false
        end


    local frameW, frameH = Frame:GetSize() -- Getting size for perfect fit

    local modelPanel = vgui.Create("XeninUI.Panel", Frame) --PlayerModelPanel
        modelPanel:SetSize(frameW/2, frameH/1.2 )
        modelPanel:Center()
        modelPanel:AlignLeft()
        
    local showModel = vgui.Create("DModelPanel", modelPanel) --Playermodel itself
        showModel:SetSize(modelPanel:GetSize())
        showModel:Center()
        showModel:SetModel(mdl)
        showModel:SetCamPos(showModel:GetCamPos() - Vector(0, 50, 0))

        function showModel:LayoutEntity( ent ) return  end

    local overridemouse = vgui.Create("XeninUI.Panel", modelPanel) --Overrides the Playermodel, so the mouse doesn't change into making the believe, you can click on it
        overridemouse:SetSize(showModel:GetSize())
        overridemouse:Center()
        overridemouse.Paint = function(self, w, h)
        
        end

    local showModelW, showModelH = showModel:GetSize()

    local headPanel = vgui.Create("XeninUI.Panel", overridemouse)
        headPanel:SetSize(100, 50)
        headPanel:SetPos(showModelW/1.7, showModelH/9)
        headPanel.chCustomIndex = 1
        headPanel.Paint = function(self, w, h)

            draw.RoundedBox(10, 0, 1, w, h/1.9, color_black)
            draw.RoundedBox(10, 0, 2, w, h/1.9, color_gray)
            draw.SimpleText("Head", "DermaDefault", w/2, h/3.5, color_white, TEXT_ALIGN_CENTER, TEXT_ALIGN_BOTTOM)
            draw.SimpleText(Health[1].Amount .. "/" .. cHealth.cfg.Bones[1].Amount, "DermaDefault", w, h/1.3, color_white, TEXT_ALIGN_RIGHT, TEXT_ALIGN_BOTTOM)
            surface.DrawOutlinedRect(0, h/3, w, h/4, 1)
            surface.SetDrawColor(color_white)
            surface.SetMaterial(healthBar)
            surface.DrawTexturedRect(1, h/2.9, (Health[1].Amount*(w/cHealth.cfg.Bones[1].Amount)) - 2, h/5, 1)
            
            if Health[1].isBroken then
            surface.SetMaterial(fracture)
            surface.DrawTexturedRect(2, h/1.7, 20, 20)
            end
            if Health[1].isHeavyBleed then
            surface.SetMaterial(heavyBleed)
            surface.DrawTexturedRect(22, h/1.7, 20, 20)
            end
            if Health[1].isBleeding then
            surface.SetMaterial(lightBleed)
            surface.DrawTexturedRect(42, h/1.7, 20, 20)
            end
        
        end

    headPanel:Receiver("rightlegt", function(self, panels, dropped, menuIndex, x, y) 
            if (dropped) then
                  
              HealDamage(panels[1].Index, self.chCustomIndex)
              surface.PlaySound(Meds[panels[1].Index].Sound)
      
          end    
      end,
      {})

    local torsoPanel = vgui.Create("XeninUI.Panel", overridemouse)
        torsoPanel:SetSize(100, 50)
        torsoPanel:SetPos(showModelW/2.5, showModelH/3.2)
        torsoPanel.chCustomIndex = 2
        torsoPanel.Paint = function(self, w, h)

            draw.RoundedBox(10, 0, 1, w, h/1.9, color_black)
            draw.RoundedBox(10, 0, 2, w, h/1.9, color_gray)
            draw.SimpleText("Torso", "DermaDefault", w/2, h/3.5, color_white, TEXT_ALIGN_CENTER, TEXT_ALIGN_BOTTOM)
            surface.DrawRect(0, h/3, w, h/4, 1)
            surface.SetDrawColor(color_white)
            surface.SetMaterial(healthBar)
            surface.DrawTexturedRect(1, h/2.9, (Health[2].Amount*(w/cHealth.cfg.Bones[2].Amount)) - 2, h/5, 1)
            draw.SimpleText(Health[2].Amount .. "/" .. cHealth.cfg.Bones[2].Amount, "DermaDefault", w, h/1.3, color_white, TEXT_ALIGN_RIGHT, TEXT_ALIGN_BOTTOM)

            if Health[2].isBroken then
            surface.SetMaterial(fracture)
            surface.DrawTexturedRect(2, h/1.7, 20, 20)
            end
            if Health[2].isHeavyBleed then
            surface.SetMaterial(heavyBleed)
            surface.DrawTexturedRect(22, h/1.7, 20, 20)
            end
            if Health[2].isBleeding then
            surface.SetMaterial(lightBleed)
            surface.DrawTexturedRect(42, h/1.7, 20, 20)
            end

        end
        torsoPanel:Receiver("rightlegt", function(self, panels, dropped, menuIndex, x, y) 
            if (dropped) then
                  
              HealDamage(panels[1].Index, self.chCustomIndex)
              surface.PlaySound(Meds[panels[1].Index].Sound)

          end    
      end,
      {})

    local stomachPanel = vgui.Create("XeninUI.Panel", overridemouse)
        stomachPanel:SetSize(100, 50)
        stomachPanel:SetPos(showModelW/2.5, showModelH/2.2)
        stomachPanel.chCustomIndex = 3
        stomachPanel.Paint = function(self, w, h)

            draw.RoundedBox(10, 0, 1, w, h/1.9, color_black)
            draw.RoundedBox(10, 0, 2, w, h/1.9, color_gray)
            draw.SimpleText("Stomach", "DermaDefault", w/2, h/3.5, color_white, TEXT_ALIGN_CENTER, TEXT_ALIGN_BOTTOM)
            draw.SimpleText(Health[3].Amount .. "/" .. cHealth.cfg.Bones[3].Amount, "DermaDefault", w, h/1.3, color_white, TEXT_ALIGN_RIGHT, TEXT_ALIGN_BOTTOM)
            surface.DrawRect(0, h/3, w, h/4, 1)
            surface.SetDrawColor(color_white)
            surface.SetMaterial(healthBar)
            surface.DrawTexturedRect(1, h/2.9, (Health[3].Amount*(w/cHealth.cfg.Bones[3].Amount)) - 2, h/5, 1)

            if Health[3].isBroken then
            surface.SetMaterial(fracture)
            surface.DrawTexturedRect(2, h/1.7, 20, 20)
            end
            if Health[3].isHeavyBleed then
            surface.SetMaterial(heavyBleed)
            surface.DrawTexturedRect(22, h/1.7, 20, 20)
            end
            if Health[3].isBleeding then
            surface.SetMaterial(lightBleed)
            surface.DrawTexturedRect(42, h/1.7, 20, 20)
            end

        end
        stomachPanel:Receiver("rightlegt", function(self, panels, dropped, menuIndex, x, y) 
            if (dropped) then

              HealDamage(panels[1].Index, self.chCustomIndex)
              surface.PlaySound(Meds[panels[1].Index].Sound)
      
          end    
      end,
      {})
    
    local leftArmPanel = vgui.Create("XeninUI.Panel", overridemouse)
        leftArmPanel:SetSize(100, 50)
        leftArmPanel:SetPos(showModelW/1.5, showModelH/2.5)
        leftArmPanel.chCustomIndex = 4
        leftArmPanel.Paint = function(self, w, h)

            draw.RoundedBox(10, 0, 1, w, h/1.9, color_black)
            draw.RoundedBox(10, 0, 2, w, h/1.9, color_gray)
            draw.SimpleText("Left Arm", "DermaDefault", w/2, h/3.5, color_white, TEXT_ALIGN_CENTER, TEXT_ALIGN_BOTTOM)
            draw.SimpleText(Health[4].Amount .. "/" .. cHealth.cfg.Bones[4].Amount, "DermaDefault", w, h/1.3, color_white, TEXT_ALIGN_RIGHT, TEXT_ALIGN_BOTTOM)
            surface.DrawRect(0, h/3, w, h/4, 1)
            surface.SetDrawColor(color_white)
            surface.SetMaterial(healthBar)
            surface.DrawTexturedRect(1, h/2.9, (Health[4].Amount*(w/cHealth.cfg.Bones[4].Amount)) - 2, h/5, 1)

            if Health[4].isBroken then
            surface.SetMaterial(fracture)
            surface.DrawTexturedRect(2, h/1.7, 20, 20)
            end
            if Health[4].isHeavyBleed then
            surface.SetMaterial(heavyBleed)
            surface.DrawTexturedRect(22, h/1.7, 20, 20)
            end
            if Health[4].isBleeding then
            surface.SetMaterial(lightBleed)
            surface.DrawTexturedRect(42, h/1.7, 20, 20)
            end

        end

    leftArmPanel:Receiver("rightlegt", function(self, panels, dropped, menuIndex, x, y) 
          if (dropped) then
                
            HealDamage(panels[1].Index, self.chCustomIndex)
            surface.PlaySound(Meds[panels[1].Index].Sound)
    
        end    
    end,
    {})
    
    local rightArmPanel = vgui.Create("XeninUI.Panel", overridemouse)
    rightArmPanel:SetSize(100, 50)
    rightArmPanel:SetPos(showModelW/7, showModelH/2.5)
    rightArmPanel.chCustomIndex = 5
    rightArmPanel.Paint = function(self, w, h)

        draw.RoundedBox(10, 0, 1, w, h/1.9, color_black)
        draw.RoundedBox(10, 0, 2, w, h/1.9, color_gray)
        draw.SimpleText("Right Arm", "DermaDefault", w/2, h/3.5, color_white, TEXT_ALIGN_CENTER, TEXT_ALIGN_BOTTOM)
        draw.SimpleText(Health[5].Amount .. "/" .. cHealth.cfg.Bones[5].Amount, "DermaDefault", w, h/1.3, color_white, TEXT_ALIGN_RIGHT, TEXT_ALIGN_BOTTOM)
        surface.DrawRect(0, h/3, w, h/4, 1)
        surface.SetDrawColor(color_white)
        surface.SetMaterial(healthBar)
            surface.DrawTexturedRect(1, h/2.9, (Health[5].Amount*(w/cHealth.cfg.Bones[5].Amount)) - 2, h/5, 1)

            if Health[5].isBroken then
            surface.SetMaterial(fracture)
            surface.DrawTexturedRect(2, h/1.7, 20, 20)
            end
            if Health[5].isHeavyBleed then
            surface.SetMaterial(heavyBleed)
            surface.DrawTexturedRect(22, h/1.7, 20, 20)
            end
            if Health[5].isBleeding then
            surface.SetMaterial(lightBleed)
            surface.DrawTexturedRect(42, h/1.7, 20, 20)
            end

    end
    rightArmPanel:Receiver("rightlegt", function(self, panels, dropped, menuIndex, x, y) 
        if (dropped) then
            
            HealDamage(panels[1].Index, self.chCustomIndex)
            surface.PlaySound(Meds[panels[1].Index].Sound)

        end    
    end,
    {})

    local leftLegPanel = vgui.Create("XeninUI.Panel", overridemouse)
    leftLegPanel:SetSize(100, 50)
    leftLegPanel:SetPos(showModelW/1.6, showModelH/1.5)
    leftLegPanel.chCustomIndex = 6
    leftLegPanel.Paint = function(self, w, h)

        draw.RoundedBox(10, 0, 1, w, h/1.9, color_black)
        draw.RoundedBox(10, 0, 2, w, h/1.9, color_gray)
        draw.SimpleText("Left Leg", "DermaDefault", w/2, h/3.5, color_white, TEXT_ALIGN_CENTER, TEXT_ALIGN_BOTTOM)
        draw.SimpleText(Health[6].Amount .. "/" .. cHealth.cfg.Bones[6].Amount, "DermaDefault", w, h/1.3, color_white, TEXT_ALIGN_RIGHT, TEXT_ALIGN_BOTTOM)
        surface.DrawRect(0, h/3, w, h/4, 1)
        surface.SetDrawColor(color_white)
        surface.SetMaterial(healthBar)
            surface.DrawTexturedRect(1, h/2.9, (Health[6].Amount*(w/cHealth.cfg.Bones[6].Amount)) - 2, h/5, 1)
            if Health[6].isBroken then
            surface.SetMaterial(fracture)
            surface.DrawTexturedRect(2, h/1.7, 20, 20)
            end
            if Health[6].isHeavyBleed then
            surface.SetMaterial(heavyBleed)
            surface.DrawTexturedRect(22, h/1.7, 20, 20)
            end
            if Health[6].isBleeding then
            surface.SetMaterial(lightBleed)
            surface.DrawTexturedRect(42, h/1.7, 20, 20)
            end

    end

    leftLegPanel:Receiver("rightlegt", function(self, panels, dropped, menuIndex, x, y) 
        if (dropped) then
            
            HealDamage(panels[1].Index, self.chCustomIndex)
            surface.PlaySound(Meds[panels[1].Index].Sound)

        end    
    end,
    {})

    local rightLegPanel = vgui.Create("XeninUI.Panel", overridemouse)
    rightLegPanel:SetSize(100, 50)
    rightLegPanel:SetPos(showModelW/5, showModelH/1.5)
    rightLegPanel.chCustomIndex = 7
    rightLegPanel.Paint = function(self, w, h)

        draw.RoundedBox(10, 0, 1, w, h/1.9, color_black)
        draw.RoundedBox(10, 0, 2, w, h/1.9, color_gray)
        draw.SimpleText("Right Leg", "DermaDefault", w/2, h/3.5, color_white, TEXT_ALIGN_CENTER, TEXT_ALIGN_BOTTOM)
        draw.SimpleText(Health[7].Amount .. "/" .. cHealth.cfg.Bones[7].Amount, "DermaDefault", w, h/1.3, color_white, TEXT_ALIGN_RIGHT, TEXT_ALIGN_BOTTOM)
        surface.DrawRect(0, h/3, w, h/4, 4)
        surface.SetDrawColor(XeninUI.Theme.Background)
        surface.DrawOutlinedRect(0, h/2.7, w, h/5, 1)
        surface.SetDrawColor(color_white)
        surface.SetMaterial(healthBar)
            surface.DrawTexturedRect(1, h/2.9, (Health[7].Amount*(w/cHealth.cfg.Bones[7].Amount)) - 2, h/5, 1)

            if Health[7].isBroken then
            surface.SetMaterial(fracture)
            surface.DrawTexturedRect(2, h/1.7, 20, 20)
            end
            if Health[7].isHeavyBleed then
            surface.SetMaterial(heavyBleed)
            surface.DrawTexturedRect(22, h/1.7, 20, 20)
            end
            if Health[7].isBleeding then
            surface.SetMaterial(lightBleed)
            surface.DrawTexturedRect(42, h/1.7, 20, 20)
            end

    end

    --Drag'N'Drop Functions

    rightLegPanel:Receiver("rightlegt", function(self, panels, dropped, menuIndex, x, y) 
        if (dropped) then
            
            HealDamage(panels[1].Index, self.chCustomIndex)
            surface.PlaySound(Meds[panels[1].Index].Sound)

        end    
    end,
    {})


--- Medkits

    local medsPanel = vgui.Create("XeninUI.Panel", Frame)
        medsPanel:SetSize(frameW/2, frameH/1.2)
        medsPanel:Center()
        medsPanel:AlignRight()
        medsPanel.Paint = function(self, w, h)

        end

    local medsScroll = vgui.Create("XeninUI.ScrollPanel", medsPanel)
        medsScroll:Dock(FILL)

    local medsList = vgui.Create("DIconLayout", medsScroll)
    medsList:Dock(FILL)
    medsList:SetSpaceY( 5 )

    local medsListHeader = medsList:Add("XeninUI.Panel")
        medsListHeader:SetSize(frameW/2.1, frameH/12)
        medsListHeader.Paint = function(self, w, h)

            draw.SimpleText("Medical-Items", "HeaderFont", w/2, h/2, color_white,TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)

    end

    if Meds then

    for k, v in pairs(Meds) do
        
        local currentMed = k

        local ListItem = medsList:Add("XeninUI.Panel")
        ListItem:SetSize(frameW/2.1, frameH/12)

        function ListItem:OnMousePressed(button)

            if button != MOUSE_RIGHT then return end

            local Menu = DermaMenu()

            for k, v in pairs(Health) do
                
                local Option = Menu:AddOption("Heal ".. Health[k].Name)
                Option:SetTextColor(color_white)
                Option.Index = k
                Option.currentMed = currentMed

            end

            Menu.Paint = function(self, w, h)

                draw.RoundedBox(10, 0, 0, w, h, XeninUI.Theme.Navbar)

            end

            -- Open the menu
            Menu:Open()

            function Menu:OptionSelected(panel, optionText)

                HealDamage(panel.currentMed, panel.Index)

            end

        end

        local modelBackground = vgui.Create("XeninUI.Panel", ListItem)
        modelBackground:SetSize(frameW/16, frameH/12)
        modelBackground.Paint = function(self, w, h)

            draw.RoundedBox(10, 0, 0, w, h, XeninUI.Theme.Navbar)

        end
        
        local ModelItem = vgui.Create("DModelPanel", ListItem)
        ModelItem:SetModel(v.Model)
        ModelItem:SetSize(frameW/16, frameH/12)
        ModelItem:SetCamPos(ModelItem:GetCamPos() + Vector(-30,-50,-50))
        ModelItem:SetLookAt(Vector(0,0,0))
        ModelItem:SetLookAng(ModelItem:GetLookAng())
        ModelItem:AlignLeft()
        ModelItem:Droppable("rightlegt")
        ModelItem.chCustomName = v.Name
        ModelItem.Index = k

        function ModelItem:DoRightClick()
           

        end
        

        ListItem.Paint = function(self, w, h)

            surface.SetDrawColor(XeninUI.Theme.Navbar)
            surface.DrawOutlinedRect(2, 0, w-1, h, 2)
            draw.SimpleText(v.Name, "cHealthFont", w/7, h/3, color_white, TEXT_ALIGN_LEFT, TEXT_ALIGN_CENTER)
            draw.SimpleText(v.Description, "cHealthFont", w/7, h/1.5, color_white, TEXT_ALIGN_LEFT, TEXT_ALIGN_CENTER)
            draw.SimpleText(v.Points.."/"..cHealth.cfg.Meds[v.Name].Points, "cHealthFont", w/1.3, h/3, color_white, TEXT_ALIGN_LEFT,TEXT_ALIGN_CENTER)
            
        end
        
    end

    if !table.IsEmpty(armor) then 
        PrintTable(armor)

        local orgArmor = cHealth.cfg.Armor[armor.Name]

        local armorPanelW, armorPanelH = frameW/5, frameH/3
        local armorPanel = vgui.Create("XeninUI.Panel", Frame)
        armorPanel:SetSize(armorPanelW, armorPanelH)
        armorPanel:AlignTop(40)
        armorPanel:AlignLeft(3)
        armorPanel.Paint = function(self, w, h)
            draw.SimpleText("Durability:", "cHealthFont", armorPanelW/2, 10, color_white,TEXT_ALIGN_LEFT,TEXT_ALIGN_LEFT)
            draw.SimpleText(armor.Durability .. "/" .. orgArmor.Durability, "cHealthFont", armorPanelW/2, 25, color_white, TEXT_ALIGN_LEFT, TEXT_ALIGN_LEFT)

        end

        local armorModelW, armorModelH = armorPanelW/2.5, armorPanelH/2
        local armorModel = vgui.Create("DModelPanel", armorPanel)
            armorModel:SetSize(armorModelW, armorModelH)
            armorModel:SetModel(armor.Model)
            armorModel:SetCamPos(armorModel:GetCamPos() + Vector(-30,-30,-40))
            armorModel:SetLookAt(Vector(0,0,10))
            armorModel:SetLookAng(armorModel:GetLookAng())
    end
end

    net.Receive("chMenu:Refresh", function(len)
        
        local newHealth = util.JSONToTable(util.Decompress(net.ReadData(len)))
        Health = newHealth

    end)

    net.Receive("chMenu:RefreshMeds", function(len)
    
        local newHealth = util.JSONToTable(util.Decompress(net.ReadData(len)))
        Meds = newHealth

        if medsList:ChildCount() > 0 then
            medsList:Clear()
        end

        local medsListHeader = medsList:Add("XeninUI.Panel")
        medsListHeader:SetSize(frameW/2.1, frameH/12)
        medsListHeader.Paint = function(self, w, h)

            draw.SimpleText("Medical-Items", "HeaderFont", w/2, h/2, color_white,TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)

        end

        for k, v in pairs(Meds) do
        
            local currentMed = k
    
            local ListItem = medsList:Add("XeninUI.Panel")
            ListItem:SetSize(frameW/2.1, frameH/12)
    
            function ListItem:OnMousePressed(button)
    
                if button != MOUSE_RIGHT then return end
    
                local Menu = DermaMenu()
    
                for k, v in pairs(Health) do
                    
                    local Option = Menu:AddOption("Heal ".. Health[k].Name)
                    Option:SetTextColor(color_white)
                    Option.Index = k
                    Option.currentMed = currentMed
    
                end
    
                Menu.Paint = function(self, w, h)
    
                    draw.RoundedBox(10, 0, 0, w, h, XeninUI.Theme.Navbar)
    
                end
    
                -- Open the menu
                Menu:Open()
    
                function Menu:OptionSelected(panel, optionText)
    
                    HealDamage(panel.currentMed, panel.Index)
    
                end
    
            end
    
            local modelBackground = vgui.Create("XeninUI.Panel", ListItem)
            modelBackground:SetSize(frameW/16, frameH/12)
            modelBackground.Paint = function(self, w, h)
    
                draw.RoundedBox(10, 0, 0, w, h, XeninUI.Theme.Navbar)
    
            end
            
            local ModelItem = vgui.Create("DModelPanel", ListItem)
            ModelItem:SetModel(v.Model)
            ModelItem:SetSize(frameW/16, frameH/12)
            ModelItem:SetCamPos(ModelItem:GetCamPos() + Vector(-30,-50,-50))
            ModelItem:SetLookAt(Vector(0,0,0))
            ModelItem:SetLookAng(ModelItem:GetLookAng())
            ModelItem:AlignLeft()
            ModelItem:Droppable("rightlegt")
            ModelItem.chCustomName = v.Name
            ModelItem.Index = k
    
            function ModelItem:DoRightClick()

            end
    
            ListItem.Paint = function(self, w, h)
    
                surface.SetDrawColor(XeninUI.Theme.Navbar)
                surface.DrawOutlinedRect(2, 0, w-1, h, 2)
                draw.SimpleText(v.Name, "cHealthFont", w/7, h/3, color_white, TEXT_ALIGN_LEFT, TEXT_ALIGN_CENTER)
                draw.SimpleText(v.Description, "cHealthFont", w/7, h/1.5, color_white, TEXT_ALIGN_LEFT, TEXT_ALIGN_CENTER)
                draw.SimpleText(v.Points.."/"..cHealth.cfg.Meds[v.Name].Points, "cHealthFont", w/1.3, h/3, color_white, TEXT_ALIGN_LEFT,TEXT_ALIGN_CENTER)
                
            end
            
        end
    end)

    net.Receive("chHealth:closeMenu", function() 

        if Frame then
            Frame:Remove()
        end
    
    end)

end

net.Receive("chMenu:OpenMenu", function()

    local healthlen = net.ReadUInt(16)
    local healthdata = util.JSONToTable(util.Decompress(net.ReadData(healthlen)))
    
    local medslen = net.ReadUInt(16)
    local medsdata = util.JSONToTable(util.Decompress(net.ReadData(medslen)))

    local armorlen = net.ReadUInt(16)
    local armordata = util.JSONToTable(util.Decompress(net.ReadData(armorlen)))

    local plyName = net.ReadString()
    local plyModel = net.ReadString()

    OpenMenu(healthdata, medsdata, plyName, plyModel, armordata)

end)

local deathT 
local respawnText 
net.Receive("chHealth:IsDead", function()
    local respawntimer = net.ReadUInt(8)

    deathT = CurTime() + respawntimer
    respawnText = "You Died!"

end)

net.Receive("chHealth:IsRagdolled", function()

    local timer  = net.ReadUInt(8)

    deathT = CurTime() + timer
    respawnText = "You are unconscious. Wait for help!"

end)

net.Receive("chHealth:respawnScreen", function()

    deathT = nil
    
end)

local scrw = ScrW()
local scrh = ScrH()

hook.Add("HUDPaint", "DeathScreen", function()
    local ply = LocalPlayer()

    if !deathT then return end

    local timeleft = math.Round(deathT - CurTime(), 0)
    surface.SetDrawColor(color_black)
    surface.DrawRect(0, 0, scrw, scrh)
    
    draw.RoundedBox(5, scrw/2 - 150, scrh/2 - 50, 300, 100, XeninUI.Theme.Accent)
    draw.SimpleText(respawnText, "LabelFont", scrw/2, scrh/2 - 10, color_white, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)

    if timeleft >= 0 then
       local text = draw.DrawText(timeleft, "LabelFont", ScrW()/2, ScrH()/2, color_white, TEXT_ALIGN_CENTER)
    else
        text = draw.DrawText("Press Spacebar or click a Mousebutton to respawn", "LabelFont", scrw/2, scrh/2, color_white, TEXT_ALIGN_CENTER)
    end
end)


hook.Add("PlayerButtonDown", "openthedamnMenu", function(ply, key)

    if key != keyConfig or !ply:Alive() then return end

    if (keyCooldown or 0) > CurTime() then return end
    keyCooldown = CurTime() + 0.2

    if menuOpen then return end

    net.Start("chMenu:ButDown")
    net.SendToServer()

end)

local plyWithArmor = { 

}

net.Receive("chArmor:AddArmor", function(len) 

    local ply = net.ReadEntity()
    local armorName = net.ReadString()
    ply.chArmorcl = table.Copy(cHealth.cfg.Armor[armorName])
    ply.chArmorModel = ClientsideModel(ply.chArmorcl.Model)

    plyWithArmor[ply:SteamID()] = ply.chArmorModel

end)

hook.Add( "PostPlayerDraw" , "chArmor:Armor" , function( ply )
	if not IsValid(ply) or not ply:Alive() then return end
    if !plyWithArmor[ply:SteamID()] or !ply.chArmorcl then return end
    local model = plyWithArmor[ply:SteamID()]
    model:SetNoDraw(true)

	local attach_id = ply:LookupAttachment('chest')
	if not attach_id then return end
			
	local attach = ply:GetAttachment(attach_id)		
	if not attach then return end

	local pos = attach.Pos
	local ang = attach.Ang
		
	model:SetModelScale((ply.chArmorcl.scale or 1), 0)
	pos = pos + (ang:Up() * (ply.chArmorcl.upOff or 1)) + (ang:Forward() * (ply.chArmorcl.forOff or 1))
	ang:RotateAroundAxis(ang:Right(), (ply.chArmorcl.rightOff or 1 ))
		
	model:SetPos(pos)
	model:SetAngles(ang)

	model:SetRenderOrigin(pos)
	model:SetRenderAngles(ang)
	model:SetupBones()
	model:DrawModel()
	model:SetRenderOrigin()
	model:SetRenderAngles()
    
end)

net.Receive("chArmor:RemovePly", function()

    local dcPly = net.ReadEntity()
    local steamid = dcPly:SteamID()

    if plyWithArmor[steamid] then
        plyWithArmor[steamid] = nil
    end

end)

net.Receive("chSettings:OpenSettings", openSettings)


hook.Add("InitPostEntity", "chArmor:Connect", function() 

    net.Start("chArmor:PlyReady")
    net.SendToServer()

end)

net.Receive("chArmor:PlyConnect", function(len)

    local tbllen = net.ReadUInt(16)
    local receivedTable = util.Decompress(util.JSONToTable(net.ReadData(tbllen)))

    plyWithArmor = receivedTable

end)