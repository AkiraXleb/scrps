-- ⚔️ Universal Weapon Hub | by AkiraXleb
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local player = Players.LocalPlayer

-- 🎨 PERSONALIZACIÓN
local THEME = {
    primary    = Color3.fromRGB(220, 30, 30),    -- Rojo principal
    bg         = Color3.fromRGB(15, 15, 18),     -- Negro de fondo
    bgLight    = Color3.fromRGB(25, 25, 30),     -- Negro claro
    accent     = Color3.fromRGB(255, 60, 60),    -- Rojo accent
    text       = Color3.fromRGB(255, 255, 255),
    textDim    = Color3.fromRGB(180, 180, 180),
}

-- 🖼️ TU LOGO (cambia este ID por el tuyo, ver tutorial abajo)
local LOGO_ID = "rbxassetid://0" -- ← reemplaza el 0 con tu Asset ID

local weaponKeywords = {
    "launcher","gun","rifle","pistol","shotgun","smg","knife","sword",
    "machete","blade","katana","bat","axe","hammer","crowbar","club",
    "grenade","bomb","explosive","tnt","dynamite","revolver","sniper",
    "uzi","ak","ar15","minigun","bow","crossbow","spear","arrow","dagger",
    "rocket","flame","thrower","laser","ray","weapon","firearm",
}

local detectedItems = {}
local selected = {}

-- =====================
--        GUI
-- =====================
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Parent = game.CoreGui
ScreenGui.ResetOnSpawn = false
ScreenGui.IgnoreGuiInset = true

-- Frame principal
local Main = Instance.new("Frame")
Main.Name = "Main"
Main.Parent = ScreenGui
Main.Size = UDim2.new(0, 240, 0, 380)
Main.Position = UDim2.new(0, 20, 0, 80)
Main.BackgroundColor3 = THEME.bg
Main.BorderSizePixel = 0
Main.Active = true
Main.Draggable = true
local fc = Instance.new("UICorner") fc.CornerRadius = UDim.new(0,8) fc.Parent = Main

local Stroke = Instance.new("UIStroke")
Stroke.Parent = Main
Stroke.Color = THEME.primary
Stroke.Thickness = 1.5

-- Barra de título
local TitleBar = Instance.new("Frame")
TitleBar.Parent = Main
TitleBar.Size = UDim2.new(1, 0, 0, 32)
TitleBar.BackgroundColor3 = THEME.bgLight
TitleBar.BorderSizePixel = 0
local tbc = Instance.new("UICorner") tbc.CornerRadius = UDim.new(0,8) tbc.Parent = TitleBar

-- Esconder esquinas inferiores del título
local TitleFix = Instance.new("Frame")
TitleFix.Parent = TitleBar
TitleFix.Size = UDim2.new(1, 0, 0.5, 0)
TitleFix.Position = UDim2.new(0, 0, 0.5, 0)
TitleFix.BackgroundColor3 = THEME.bgLight
TitleFix.BorderSizePixel = 0

-- Logo (ImageLabel)
local Logo = Instance.new("ImageLabel")
Logo.Parent = TitleBar
Logo.Size = UDim2.new(0, 22, 0, 22)
Logo.Position = UDim2.new(0, 6, 0.5, -11)
Logo.BackgroundTransparency = 1
Logo.Image = LOGO_ID
local logoC = Instance.new("UICorner") logoC.CornerRadius = UDim.new(1,0) logoC.Parent = Logo

-- Si no hay logo válido, mostrar emoji de respaldo
local LogoFallback = Instance.new("TextLabel")
LogoFallback.Parent = TitleBar
LogoFallback.Size = UDim2.new(0, 22, 0, 22)
LogoFallback.Position = UDim2.new(0, 6, 0.5, -11)
LogoFallback.BackgroundTransparency = 1
LogoFallback.Text = "⚔️"
LogoFallback.TextColor3 = THEME.accent
LogoFallback.TextSize = 18
LogoFallback.Font = Enum.Font.GothamBold
LogoFallback.Visible = (LOGO_ID == "rbxassetid://0")

-- Título
local Title = Instance.new("TextLabel")
Title.Parent = TitleBar
Title.Size = UDim2.new(1, -90, 1, 0)
Title.Position = UDim2.new(0, 34, 0, 0)
Title.BackgroundTransparency = 1
Title.Text = "AkiraXleb Hub"
Title.TextColor3 = THEME.accent
Title.Font = Enum.Font.GothamBold
Title.TextSize = 14
Title.TextXAlignment = Enum.TextXAlignment.Left

-- Botón Minimizar
local MinBtn = Instance.new("TextButton")
MinBtn.Parent = TitleBar
MinBtn.Size = UDim2.new(0, 24, 0, 24)
MinBtn.Position = UDim2.new(1, -54, 0.5, -12)
MinBtn.BackgroundColor3 = Color3.fromRGB(80, 80, 80)
MinBtn.Text = "—"
MinBtn.TextColor3 = THEME.text
MinBtn.Font = Enum.Font.GothamBold
MinBtn.TextSize = 14
local mbc = Instance.new("UICorner") mbc.CornerRadius = UDim.new(0,4) mbc.Parent = MinBtn

-- Botón Cerrar
local CloseBtn = Instance.new("TextButton")
CloseBtn.Parent = TitleBar
CloseBtn.Size = UDim2.new(0, 24, 0, 24)
CloseBtn.Position = UDim2.new(1, -26, 0.5, -12)
CloseBtn.BackgroundColor3 = THEME.primary
CloseBtn.Text = "✕"
CloseBtn.TextColor3 = THEME.text
CloseBtn.Font = Enum.Font.GothamBold
CloseBtn.TextSize = 12
local cbc = Instance.new("UICorner") cbc.CornerRadius = UDim.new(0,4) cbc.Parent = CloseBtn

-- Container del contenido (para poder esconderlo al minimizar)
local Content = Instance.new("Frame")
Content.Parent = Main
Content.Size = UDim2.new(1, 0, 1, -32)
Content.Position = UDim2.new(0, 0, 0, 32)
Content.BackgroundTransparency = 1

-- Status
local Status = Instance.new("TextLabel")
Status.Parent = Content
Status.Size = UDim2.new(1, -12, 0, 18)
Status.Position = UDim2.new(0, 6, 0, 4)
Status.BackgroundTransparency = 1
Status.Text = "⏳ Detectando armas..."
Status.TextColor3 = THEME.textDim
Status.Font = Enum.Font.Gotham
Status.TextSize = 11
Status.TextXAlignment = Enum.TextXAlignment.Left

-- Buscador
local SearchBox = Instance.new("TextBox")
SearchBox.Parent = Content
SearchBox.Size = UDim2.new(1, -12, 0, 24)
SearchBox.Position = UDim2.new(0, 6, 0, 26)
SearchBox.BackgroundColor3 = THEME.bgLight
SearchBox.PlaceholderText = "🔍 Filtrar..."
SearchBox.Text = ""
SearchBox.TextColor3 = THEME.text
SearchBox.PlaceholderColor3 = Color3.fromRGB(110, 110, 110)
SearchBox.Font = Enum.Font.Gotham
SearchBox.TextSize = 11
SearchBox.ClearTextOnFocus = false
SearchBox.BorderSizePixel = 0
local sc = Instance.new("UICorner") sc.CornerRadius = UDim.new(0,4) sc.Parent = SearchBox

-- Select / Deselect
local SelectAllBtn = Instance.new("TextButton")
SelectAllBtn.Parent = Content
SelectAllBtn.Size = UDim2.new(0.47, -3, 0, 22)
SelectAllBtn.Position = UDim2.new(0, 6, 0, 56)
SelectAllBtn.BackgroundColor3 = Color3.fromRGB(40, 100, 40)
SelectAllBtn.Text = "✓ Todas"
SelectAllBtn.TextColor3 = THEME.text
SelectAllBtn.Font = Enum.Font.GothamBold
SelectAllBtn.TextSize = 11
SelectAllBtn.BorderSizePixel = 0
local sac = Instance.new("UICorner") sac.CornerRadius = UDim.new(0,4) sac.Parent = SelectAllBtn

local DeselectBtn = Instance.new("TextButton")
DeselectBtn.Parent = Content
DeselectBtn.Size = UDim2.new(0.47, -3, 0, 22)
DeselectBtn.Position = UDim2.new(0.53, -3, 0, 56)
DeselectBtn.BackgroundColor3 = Color3.fromRGB(100, 40, 40)
DeselectBtn.Text = "✗ Ninguna"
DeselectBtn.TextColor3 = THEME.text
DeselectBtn.Font = Enum.Font.GothamBold
DeselectBtn.TextSize = 11
DeselectBtn.BorderSizePixel = 0
local dc = Instance.new("UICorner") dc.CornerRadius = UDim.new(0,4) dc.Parent = DeselectBtn

-- ScrollFrame
local Scroll = Instance.new("ScrollingFrame")
Scroll.Parent = Content
Scroll.Size = UDim2.new(1, -12, 0, 200)
Scroll.Position = UDim2.new(0, 6, 0, 84)
Scroll.BackgroundColor3 = THEME.bgLight
Scroll.ScrollBarThickness = 4
Scroll.ScrollBarImageColor3 = THEME.primary
Scroll.CanvasSize = UDim2.new(0, 0, 0, 0)
Scroll.BorderSizePixel = 0
local scrc = Instance.new("UICorner") scrc.CornerRadius = UDim.new(0,4) scrc.Parent = Scroll

local Layout = Instance.new("UIListLayout")
Layout.Parent = Scroll
Layout.Padding = UDim.new(0, 2)
local Padd = Instance.new("UIPadding") Padd.Parent = Scroll
Padd.PaddingTop = UDim.new(0, 3)
Padd.PaddingLeft = UDim.new(0, 3)

-- Botones de acción
local function makeActionBtn(text, posY, color)
    local btn = Instance.new("TextButton")
    btn.Parent = Content
    btn.Size = UDim2.new(1, -12, 0, 22)
    btn.Position = UDim2.new(0, 6, 0, posY)
    btn.BackgroundColor3 = color
    btn.Text = text
    btn.TextColor3 = THEME.text
    btn.Font = Enum.Font.GothamBold
    btn.TextSize = 11
    btn.BorderSizePixel = 0
    local cc = Instance.new("UICorner") cc.CornerRadius = UDim.new(0,4) cc.Parent = btn
    return btn
end

local ScanBtn  = makeActionBtn("🔍 Re-detectar",       290, Color3.fromRGB(80, 60, 140))
local BringBtn = makeActionBtn("⚡ Traer seleccionadas", 316, THEME.primary)
local AutoBtn  = makeActionBtn("🔄 Auto-Bring: OFF",    342, Color3.fromRGB(60, 60, 60))

-- ============== ICONO MINIMIZADO ==============
local MiniIcon = Instance.new("TextButton")
MiniIcon.Name = "MiniIcon"
MiniIcon.Parent = ScreenGui
MiniIcon.Size = UDim2.new(0, 50, 0, 50)
MiniIcon.Position = UDim2.new(0, 20, 0, 80)
MiniIcon.BackgroundColor3 = THEME.bg
MiniIcon.Text = "⚔️"
MiniIcon.TextColor3 = THEME.accent
MiniIcon.Font = Enum.Font.GothamBold
MiniIcon.TextSize = 24
MiniIcon.BorderSizePixel = 0
MiniIcon.Visible = false
MiniIcon.Active = true
MiniIcon.Draggable = true
local mic = Instance.new("UICorner") mic.CornerRadius = UDim.new(1,0) mic.Parent = MiniIcon
local mis = Instance.new("UIStroke") mis.Parent = MiniIcon
mis.Color = THEME.primary
mis.Thickness = 2

-- =====================
--       LÓGICA
-- =====================
local function isWeapon(name)
    local lower = name:lower()
    for _, kw in ipairs(weaponKeywords) do
        if lower:find(kw) then return true end
    end
    return false
end

local function detectWeapons()
    detectedItems = {}
    selected = {}
    local function scanFolder(folder)
        if not folder then return end
        for _, item in ipairs(folder:GetChildren()) do
            if isWeapon(item.Name) then
                table.insert(detectedItems, {name = item.Name, ref = item})
                selected[item.Name] = false
            end
        end
    end
    pcall(function()
        local assets = ReplicatedStorage:FindFirstChild("Assets")
        if assets then
            local items = assets:FindFirstChild("Items")
            if items then scanFolder(items) end
        end
    end)
    table.sort(detectedItems, function(a, b) return a.name < b.name end)
    Status.Text = "🎯 Detectadas: " .. #detectedItems
end

local function buildList()
    for _, child in ipairs(Scroll:GetChildren()) do
        if child:IsA("TextButton") then child:Destroy() end
    end
    local filter = SearchBox.Text:lower()
    local visible = 0
    for _, data in ipairs(detectedItems) do
        if filter == "" or data.name:lower():find(filter, 1, true) then
            visible = visible + 1
            local btn = Instance.new("TextButton")
            btn.Parent = Scroll
            btn.Size = UDim2.new(1, -10, 0, 22)
            btn.BackgroundColor3 = selected[data.name] and Color3.fromRGB(50, 90, 50) or Color3.fromRGB(35, 35, 40)
            btn.Text = (selected[data.name] and "✓ " or "  ") .. data.name
            btn.TextColor3 = THEME.text
            btn.Font = Enum.Font.Gotham
            btn.TextSize = 11
            btn.TextXAlignment = Enum.TextXAlignment.Left
            btn.BorderSizePixel = 0
            local bcc = Instance.new("UICorner") bcc.CornerRadius = UDim.new(0,3) bcc.Parent = btn
            local pp = Instance.new("UIPadding") pp.Parent = btn pp.PaddingLeft = UDim.new(0, 6)
            btn.MouseButton1Click:Connect(function()
                selected[data.name] = not selected[data.name]
                if selected[data.name] then
                    btn.Text = "✓ " .. data.name
                    btn.BackgroundColor3 = Color3.fromRGB(50, 90, 50)
                else
                    btn.Text = "  " .. data.name
                    btn.BackgroundColor3 = Color3.fromRGB(35, 35, 40)
                end
            end)
        end
    end
    Scroll.CanvasSize = UDim2.new(0, 0, 0, visible * 24 + 6)
end

local function findInWorkspace(itemName)
    local found = {}
    for _, item in ipairs(workspace:GetDescendants()) do
        if item.Name == itemName and (item:IsA("Model") or item:IsA("BasePart") or item:IsA("Tool")) then
            table.insert(found, item)
        end
    end
    return found
end

local function bringSelected()
    local char = player.Character
    if not char then return 0 end
    local root = char:FindFirstChild("HumanoidRootPart")
    if not root then return 0 end
    local total = 0
    local i = 0
    for itemName, isSel in pairs(selected) do
        if isSel then
            for _, item in ipairs(findInWorkspace(itemName)) do
                i = i + 1
                local offset = Vector3.new(math.cos(i*0.6)*3, 2 + (i%3), math.sin(i*0.6)*3)
                pcall(function()
                    if item:IsA("Model") then
                        item:PivotTo(root.CFrame * CFrame.new(offset))
                    elseif item:IsA("BasePart") then
                        item.CFrame = root.CFrame * CFrame.new(offset)
                    elseif item:IsA("Tool") then
                        item.Parent = player.Backpack
                    end
                end)
                total = total + 1
            end
        end
    end
    return total
end

-- Eventos
SearchBox:GetPropertyChangedSignal("Text"):Connect(buildList)
SelectAllBtn.MouseButton1Click:Connect(function()
    for _, data in ipairs(detectedItems) do selected[data.name] = true end
    buildList()
end)
DeselectBtn.MouseButton1Click:Connect(function()
    for k in pairs(selected) do selected[k] = false end
    buildList()
end)
ScanBtn.MouseButton1Click:Connect(function()
    detectWeapons()
    buildList()
end)
BringBtn.MouseButton1Click:Connect(function()
    local n = bringSelected()
    Status.Text = "✅ Traídas: " .. n
end)

local auto = false
AutoBtn.MouseButton1Click:Connect(function()
    auto = not auto
    if auto then
        AutoBtn.Text = "🔄 Auto-Bring: ON"
        AutoBtn.BackgroundColor3 = Color3.fromRGB(50, 130, 50)
    else
        AutoBtn.Text = "🔄 Auto-Bring: OFF"
        AutoBtn.BackgroundColor3 = Color3.fromRGB(60, 60, 60)
    end
end)

task.spawn(function()
    while true do
        if auto then
            pcall(function()
                local n = bringSelected()
                if n > 0 then Status.Text = "🔄 Auto: " .. n .. " traídas" end
            end)
        end
        task.wait(2)
    end
end)

-- Minimizar
MinBtn.MouseButton1Click:Connect(function()
    Main.Visible = false
    MiniIcon.Position = Main.Position
    MiniIcon.Visible = true
end)

MiniIcon.MouseButton1Click:Connect(function()
    Main.Position = MiniIcon.Position
    Main.Visible = true
    MiniIcon.Visible = false
end)

-- Cerrar
CloseBtn.MouseButton1Click:Connect(function()
    ScreenGui:Destroy()
end)

-- Inicio
detectWeapons()
buildList()
