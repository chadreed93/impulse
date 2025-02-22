local PANEL = {}

AccessorFunc(PANEL, "m_pMenu", "Menu")
AccessorFunc(PANEL, "m_bChecked", "Checked")
AccessorFunc(PANEL, "m_bCheckable", "IsCheckable")

function PANEL:Init()
    self:SetContentAlignment(4)
    self:SetTextInset(32, 0) -- Room for icon on left
    self:SetChecked(false)
    self:SetTextColor(Color(10, 10, 10))
end

function PANEL:SetSubMenu(menu)
    self.SubMenu = menu
    if not IsValid(self.SubMenuArrow) then
        self.SubMenuArrow = vgui.Create("DPanel", self)
        self.SubMenuArrow.Paint = function(panel, w, h)
            derma.SkinHook("Paint", "MenuRightArrow", panel, w, h)
        end
    end
end

function PANEL:AddSubMenu()
    local SubMenu = DermaMenu(true, self)
    SubMenu:SetVisible(false)
    SubMenu:SetParent(self)
    self:SetSubMenu(SubMenu)
    return SubMenu
end

function PANEL:OnCursorEntered()
    if IsValid(self.ParentMenu) then
        self.ParentMenu:OpenSubMenu(self, self.SubMenu)
        return
    end
    self:GetParent():OpenSubMenu(self, self.SubMenu)
end

function PANEL:OnCursorExited()
end

function PANEL:Paint(w, h)
    -- Ensure that the necessary methods exist before calling them
    if derma.SkinHook and self then
        derma.SkinHook("Paint", "MenuOption", self, w, h)
    end

    -- Draw the button text
    return false
end

function PANEL:OnMousePressed(mousecode)
    self.m_MenuClicking = true
    DButton.OnMousePressed(self, mousecode)
end

function PANEL:OnMouseReleased(mousecode)
    DButton.OnMouseReleased(self, mousecode)
    if self.m_MenuClicking and mousecode == MOUSE_LEFT then
        self.m_MenuClicking = false
        CloseDermaMenus()
    end
end

function PANEL:DoRightClick()
    if self:GetIsCheckable() then
        self:ToggleCheck()
    end
end

function PANEL:DoClickInternal()
    if self:GetIsCheckable() then
        self:ToggleCheck()
    end
    if self.m_pMenu then
        self.m_pMenu:OptionSelectedInternal(self)
    end
end

function PANEL:ToggleCheck()
    self:SetChecked(not self:GetChecked())
    self:OnChecked(self:GetChecked())
end

function PANEL:OnChecked(b)
end

function PANEL:PerformLayout(w, h)
    self:SizeToContents()
    self:SetWide(self:GetWide() + 30)
    local w = math.max(self:GetParent():GetWide(), self:GetWide())
    self:SetSize(w, 22)
    if IsValid(self.SubMenuArrow) then
        self.SubMenuArrow:SetSize(15, 15)
        self.SubMenuArrow:CenterVertical()
        self.SubMenuArrow:AlignRight(4)
    end
    DButton.PerformLayout(self, w, h)
end

function PANEL:GenerateExample()
    -- Do nothing!
end

derma.DefineControl("DMenuOption", "Menu Option Line", PANEL, "DButton")