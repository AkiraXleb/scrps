-- ⚔️ AkiraXleb Hub v3 | Multi-Tab
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local player = Players.LocalPlayer

-- ===== TEMA NEON =====
local THEME = {
    bg       = Color3.fromRGB(8, 8, 10),
    bgPanel  = Color3.fromRGB(15, 15, 18),
    bgLight  = Color3.fromRGB(25, 25, 30),
    primary  = Color3.fromRGB(255, 20, 40),     -- Rojo neon
    accent   = Color3.fromRGB(255, 60, 80),
    white    = Color3.fromRGB(255, 255, 255),
    text     = Color3.fromRGB(240, 240, 240),
    textDim  = Color3.fromRGB(160, 160, 160),
    success  = Color3.fromRGB(40, 180, 60),
    inactive = Color3.fromRGB(50, 50, 55),
}

-- 🖼️ TU LOGO (cambia el 0 por tu Asset ID cuando lo subas)
-- 🖼️ TU LOGO desde GitHub
local LOGO_ID = "rbxassetid://0"
pcall(function()
    if getcustomasset and writefile then
        local url = "https://raw.githubusercontent.com/AkiraXleb/scrps/main/Logo.png"
        writefile("akiraxleb_logo.png", game:HttpGet(url))
        LOGO_ID = getcustomasset("akiraxleb_logo.png")
    end
end)
-- ===== STATE =====
local weaponKeywords = {
    "launcher","gun","rifle","pistol","shotgun","smg","knife","sword",
    "machete","blade","katana","bat","axe","hammer","crowbar","club",
    "grenade","bomb","explosive","tnt","dynamite","revolver","sniper",
    "uzi","ak","ar15","minigun","bow","crossbow","spear","arrow","dagger",
    "rocket","flame","thrower","laser","ray","weapon","firearm",
}
local detectedItems = {}
local selected = {}
local sticky = false
local autoBring = false
local flying = false
local flySpeed = 50
local noclip = false

-- Helpers
local function getChar() return player.Character end
local function getRoot()
    local c = getChar()
    return c and (c:FindFirstChild("HumanoidRootPart") or c:FindFirstChild("Torso") or c:FindFirstChild("UpperTorso"))
end
local function getHum()
    local c = getChar()
    return c and c:FindFirstChildOfClass("Humanoid")
end

-- ===== GUI BASE =====
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "AkiraXlebHub"
ScreenGui.Parent = game.CoreGui
ScreenGui.ResetOnSpawn = false
ScreenGui.IgnoreGuiInset = true
ScreenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling

local Main = Instance.new("Frame")
Main.Parent = ScreenGui
Main.Size = UDim2.new(0, 280, 0, 440)
Main.Position = UDim2.new(0, 20, 0, 60)
Main.BackgroundColor3 = THEME.bg
Main.BorderSizePixel = 0
Main.Active = true
Main.Draggable = true
Instance.new("UICorner", Main).CornerRadius = UDim.new(0,10)

-- Borde neon
local MainStroke = Instance.new("UIStroke", Main)
MainStroke.Color = THEME.primary
MainStroke.Thickness = 2
MainStroke.Transparency = 0.2

-- Glow exterior (simulado con un frame detrás)
local Glow = Instance.new("Frame", Main)
Glow.Size = UDim2.new(1, 8, 1, 8)
Glow.Position = UDim2.new(0, -4, 0, -4)
Glow.BackgroundColor3 = THEME.primary
Glow.BackgroundTransparency = 0.85
Glow.BorderSizePixel = 0
Glow.ZIndex = 0
Instance.new("UICorner", Glow).CornerRadius = UDim.new(0,12)

-- ===== TITLE BAR =====
local TitleBar = Instance.new("Frame", Main)
TitleBar.Size = UDim2.new(1, 0, 0, 40)
TitleBar.BackgroundColor3 = THEME.bgPanel
TitleBar.BorderSizePixel = 0
Instance.new("UICorner", TitleBar).CornerRadius = UDim.new(0,10)

local TBFix = Instance.new("Frame", TitleBar)
TBFix.Size = UDim2.new(1, 0, 0.5, 0)
TBFix.Position = UDim2.new(0, 0, 0.5, 0)
TBFix.BackgroundColor3 = THEME.bgPanel
TBFix.BorderSizePixel = 0

-- Logo
local Logo = Instance.new("ImageLabel", TitleBar)
Logo.Size = UDim2.new(0, 28, 0, 28)
Logo.Position = UDim2.new(0, 8, 0.5, -14)
Logo.BackgroundTransparency = 1
Logo.Image = LOGO_ID
Instance.new("UICorner", Logo).CornerRadius = UDim.new(0,6)

-- Fallback "A" rojo cuando no hay logo
local LogoFallback = Instance.new("TextLabel", TitleBar)
LogoFallback.Size = UDim2.new(0, 28, 0, 28)
LogoFallback.Position = UDim2.new(0, 8, 0.5, -14)
LogoFallback.BackgroundColor3 = THEME.bg
LogoFallback.BorderSizePixel = 0
LogoFallback.Text = "A"
LogoFallback.TextColor3 = THEME.primary
LogoFallback.Font = Enum.Font.GothamBlack
LogoFallback.TextSize = 22
LogoFallback.Visible = (LOGO_ID == "rbxassetid://0")
Instance.new("UICorner", LogoFallback).CornerRadius = UDim.new(0,6)
local lfStroke = Instance.new("UIStroke", LogoFallback)
lfStroke.Color = THEME.primary
lfStroke.Thickness = 1.5

-- Título
local Title = Instance.new("TextLabel", TitleBar)
Title.Size = UDim2.new(1, -100, 1, 0)
Title.Position = UDim2.new(0, 42, 0, 0)
Title.BackgroundTransparency = 1
Title.Text = "AKIRAXLEB"
Title.TextColor3 = THEME.white
Title.Font = Enum.Font.GothamBlack
Title.TextSize = 15
Title.TextXAlignment = Enum.TextXAlignment.Left

-- Min / Close
local MinBtn = Instance.new("TextButton", TitleBar)
MinBtn.Size = UDim2.new(0, 26, 0, 26)
MinBtn.Position = UDim2.new(1, -58, 0.5, -13)
MinBtn.BackgroundColor3 = THEME.bgLight
MinBtn.Text = "—"
MinBtn.TextColor3 = THEME.white
MinBtn.Font = Enum.Font.GothamBold
MinBtn.TextSize = 14
MinBtn.BorderSizePixel = 0
Instance.new("UICorner", MinBtn).CornerRadius = UDim.new(0,4)

local CloseBtn = Instance.new("TextButton", TitleBar)
CloseBtn.Size = UDim2.new(0, 26, 0, 26)
CloseBtn.Position = UDim2.new(1, -28, 0.5, -13)
CloseBtn.BackgroundColor3 = THEME.primary
CloseBtn.Text = "✕"
CloseBtn.TextColor3 = THEME.white
CloseBtn.Font = Enum.Font.GothamBold
CloseBtn.TextSize = 12
CloseBtn.BorderSizePixel = 0
Instance.new("UICorner", CloseBtn).CornerRadius = UDim.new(0,4)

-- ===== TABS =====
local TabBar = Instance.new("Frame", Main)
TabBar.Size = UDim2.new(1, -16, 0, 32)
TabBar.Position = UDim2.new(0, 8, 0, 48)
TabBar.BackgroundColor3 = THEME.bgPanel
TabBar.BorderSizePixel = 0
Instance.new("UICorner", TabBar).CornerRadius = UDim.new(0,6)

local tabs = {}
local activeTab = nil
local tabContents = {}

local function setActiveTab(tabName)
    activeTab = tabName
    for name, btn in pairs(tabs) do
        if name == tabName then
            btn.BackgroundColor3 = THEME.primary
            btn.TextColor3 = THEME.white
        else
            btn.BackgroundColor3 = THEME.bgPanel
            btn.TextColor3 = THEME.textDim
        end
    end
    for name, content in pairs(tabContents) do
        content.Visible = (name == tabName)
    end
end

local function makeTab(name, label, posX, width)
    local btn = Instance.new("TextButton", TabBar)
    btn.Size = UDim2.new(width, -2, 1, -4)
    btn.Position = UDim2.new(posX, 1, 0, 2)
    btn.BackgroundColor3 = THEME.bgPanel
    btn.Text = label
    btn.TextColor3 = THEME.textDim
    btn.Font = Enum.Font.GothamBold
    btn.TextSize = 11
    btn.BorderSizePixel = 0
    Instance.new("UICorner", btn).CornerRadius = UDim.new(0,4)
    btn.MouseButton1Click:Connect(function() setActiveTab(name) end)
    tabs[name] = btn
    return btn
end

makeTab("bring",   "⚡ BRING",  0,    0.333)
makeTab("move",    "🏃 MOVE",   0.333, 0.333)
makeTab("misc",    "⚙️ MISC",   0.666, 0.334)

-- ===== CONTENT AREA =====
local ContentArea = Instance.new("Frame", Main)
ContentArea.Size = UDim2.new(1, -16, 1, -92)
ContentArea.Position = UDim2.new(0, 8, 0, 84)
ContentArea.BackgroundTransparency = 1

-- Helper para crear contenido de pestaña
local function makeTabContent(name)
    local f = Instance.new("Frame", ContentArea)
    f.Name = name
    f.Size = UDim2.new(1, 0, 1, 0)
    f.BackgroundTransparency = 1
    f.Visible = false
    tabContents[name] = f
    return f
end

-- Helper de botón estándar
local function styledButton(parent, text, size, pos, color)
    local b = Instance.new("TextButton", parent)
    b.Size = size
    b.Position = pos
    b.BackgroundColor3 = color
    b.Text = text
    b.TextColor3 = THEME.white
    b.Font = Enum.Font.GothamBold
    b.TextSize = 11
    b.BorderSizePixel = 0
    Instance.new("UICorner", b).CornerRadius = UDim.new(0,4)
    return b
end

local function styledLabel(parent, text, size, pos, color, textSize)
    local l = Instance.new("TextLabel", parent)
    l.Size = size
    l.Position = pos
    l.BackgroundTransparency = 1
    l.Text = text
    l.TextColor3 = color or THEME.text
    l.Font = Enum.Font.Gotham
    l.TextSize = textSize or 11
    l.TextXAlignment = Enum.TextXAlignment.Left
    return l
end

local function styledInput(parent, placeholder, default, size, pos)
    local i = Instance.new("TextBox", parent)
    i.Size = size
    i.Position = pos
    i.BackgroundColor3 = THEME.bgLight
    i.PlaceholderText = placeholder
    i.Text = default or ""
    i.TextColor3 = THEME.white
    i.PlaceholderColor3 = Color3.fromRGB(100, 100, 100)
    i.Font = Enum.Font.Gotham
    i.TextSize = 12
    i.ClearTextOnFocus = false
    i.BorderSizePixel = 0
    Instance.new("UICorner", i).CornerRadius = UDim.new(0,4)
    local s = Instance.new("UIStroke", i)
    s.Color = THEME.primary
    s.Thickness = 1
    s.Transparency = 0.5
    return i
end

-- =====================
-- TAB 1: BRING
-- =====================
local bringTab = makeTabContent("bring")

local Status = styledLabel(bringTab, "⏳ Detectando...", UDim2.new(1,0,0,16), UDim2.new(0,0,0,0), THEME.textDim, 10)

local SearchBox = styledInput(bringTab, "🔍 Filtrar...", "", UDim2.new(1,0,0,24), UDim2.new(0,0,0,20))

local SelectAllBtn = styledButton(bringTab, "✓ Todas", UDim2.new(0.48,-3,0,22), UDim2.new(0,0,0,50), Color3.fromRGB(40,100,40))
local DeselectBtn  = styledButton(bringTab, "✗ Ninguna", UDim2.new(0.48,-3,0,22), UDim2.new(0.52,3,0,50), Color3.fromRGB(100,40,40))

local Scroll = Instance.new("ScrollingFrame", bringTab)
Scroll.Size = UDim2.new(1, 0, 0, 180)
Scroll.Position = UDim2.new(0, 0, 0, 78)
Scroll.BackgroundColor3 = THEME.bgPanel
Scroll.ScrollBarThickness = 4
Scroll.ScrollBarImageColor3 = THEME.primary
Scroll.CanvasSize = UDim2.new(0, 0, 0, 0)
Scroll.BorderSizePixel = 0
Instance.new("UICorner", Scroll).CornerRadius = UDim.new(0,4)
local Layout = Instance.new("UIListLayout", Scroll)
Layout.Padding = UDim.new(0, 2)
local Padd = Instance.new("UIPadding", Scroll)
Padd.PaddingTop = UDim.new(0, 3)
Padd.PaddingLeft = UDim.new(0, 3)

local ScanBtn   = styledButton(bringTab, "🔍 Re-detectar",   UDim2.new(1,0,0,22), UDim2.new(0,0,0,266), Color3.fromRGB(80,60,140))
local BringBtn  = styledButton(bringTab, "⚡ TRAER AHORA",    UDim2.new(1,0,0,22), UDim2.new(0,0,0,292), THEME.primary)
local StickyBtn = styledButton(bringTab, "🧲 Sticky: OFF",   UDim2.new(0.48,-3,0,22), UDim2.new(0,0,0,318), THEME.inactive)
local AutoBtn   = styledButton(bringTab, "🔄 Auto: OFF",     UDim2.new(0.48,-3,0,22), UDim2.new(0.52,3,0,318), THEME.inactive)

-- =====================
-- TAB 2: MOVIMIENTO
-- =====================
local moveTab = makeTabContent("move")

styledLabel(moveTab, "🏃 VELOCIDAD", UDim2.new(1,0,0,18), UDim2.new(0,0,0,0), THEME.accent, 12)
styledLabel(moveTab, "Velocidad de caminar:", UDim2.new(1,0,0,14), UDim2.new(0,0,0,22), THEME.textDim, 10)
local SpeedInput = styledInput(moveTab, "16", "16", UDim2.new(0.7,-3,0,24), UDim2.new(0,0,0,38))
local SetSpeedBtn = styledButton(moveTab, "Set", UDim2.new(0.3,0,0,24), UDim2.new(0.7,3,0,38), THEME.primary)

styledLabel(moveTab, "Altura de salto:", UDim2.new(1,0,0,14), UDim2.new(0,0,0,70), THEME.textDim, 10)
local JumpInput = styledInput(moveTab, "50", "50", UDim2.new(0.7,-3,0,24), UDim2.new(0,0,0,86))
local SetJumpBtn = styledButton(moveTab, "Set", UDim2.new(0.3,0,0,24), UDim2.new(0.7,3,0,86), THEME.primary)

-- Vuelo
styledLabel(moveTab, "✈️ VUELO", UDim2.new(1,0,0,18), UDim2.new(0,0,0,124), THEME.accent, 12)
styledLabel(moveTab, "Velocidad de vuelo:", UDim2.new(1,0,0,14), UDim2.new(0,0,0,146), THEME.textDim, 10)
local FlySpeedInput = styledInput(moveTab, "50", "50", UDim2.new(1,0,0,24), UDim2.new(0,0,0,162))

local FlyBtn = styledButton(moveTab, "✈️ VOLAR: OFF", UDim2.new(1,0,0,28), UDim2.new(0,0,0,194), THEME.inactive)

styledLabel(moveTab, "WASD = mover | Espacio = subir | Shift = bajar",
    UDim2.new(1,0,0,28), UDim2.new(0,0,0,228), THEME.textDim, 9)

-- Reset
local ResetMoveBtn = styledButton(moveTab, "🔄 Reset valores", UDim2.new(1,0,0,24), UDim2.new(0,0,0,300), Color3.fromRGB(80,80,80))

-- =====================
-- TAB 3: MISC
-- =====================
local miscTab = makeTabContent("misc")

styledLabel(miscTab, "⚙️ EXTRAS", UDim2.new(1,0,0,18), UDim2.new(0,0,0,0), THEME.accent, 12)

local NoclipBtn = styledButton(miscTab, "🚪 Noclip: OFF", UDim2.new(1,0,0,28), UDim2.new(0,0,0,24), THEME.inactive)
local InfFuelBtn = styledButton(miscTab, "🔋 Inf. Fuel: OFF", UDim2.new(1,0,0,28), UDim2.new(0,0,0,58), THEME.inactive)
local InfHungerBtn = styledButton(miscTab, "🍔 Inf. Hambre: OFF", UDim2.new(1,0,0,28), UDim2.new(0,0,0,92), THEME.inactive)

styledLabel(miscTab, "─────────────────", UDim2.new(1,0,0,14), UDim2.new(0,0,0,140), THEME.textDim, 10)
styledLabel(miscTab, "👤 AKIRAXLEB", UDim2.new(1,0,0,16), UDim2.new(0,0,0,160), THEME.accent, 13)
styledLabel(miscTab, "Hub creado para A Dusty Trip", UDim2.new(1,0,0,14), UDim2.new(0,0,0,180), THEME.textDim, 10)
styledLabel(miscTab, "Versión 3.0 | by AkiraXleb", UDim2.new(1,0,0,14), UDim2.new(0,0,0,196), THEME.textDim, 10)

-- ===== MINI ICON =====
local MiniIcon = Instance.new("TextButton", ScreenGui)
MiniIcon.Size = UDim2.new(0, 50, 0, 50)
MiniIcon.Position = UDim2.new(0, 20, 0, 60)
MiniIcon.BackgroundColor3 = THEME.bg
MiniIcon.Text = "A"
MiniIcon.TextColor3 = THEME.primary
MiniIcon.Font = Enum.Font.GothamBlack
MiniIcon.TextSize = 26
MiniIcon.BorderSizePixel = 0
MiniIcon.Visible = false
MiniIcon.Active = true
MiniIcon.Draggable = true
Instance.new("UICorner", MiniIcon).CornerRadius = UDim.new(1,0)
local miStroke = Instance.new("UIStroke", MiniIcon)
miStroke.Color = THEME.primary
miStroke.Thickness = 2

-- =====================
--       LÓGICA
-- =====================

-- ===== BRING LOGIC =====
local function isWeapon(name)
    local lower = name:lower()
    for _, kw in ipairs(weaponKeywords) do
        if lower:find(kw) then return true end
    end
    return false
end

local function detectWeapons()
    detectedItems = {}
    local newSel = {}
    local function scan(folder)
        if not folder then return end
        for _, item in ipairs(folder:GetChildren()) do
            if isWeapon(item.Name) then
                table.insert(detectedItems, {name = item.Name, ref = item})
                newSel[item.Name] = selected[item.Name] or false
            end
        end
    end
    pcall(function()
        local a = ReplicatedStorage:FindFirstChild("Assets")
        if a then
            local i = a:FindFirstChild("Items")
            if i then scan(i) end
        end
    end)
    selected = newSel
    table.sort(detectedItems, function(a,b) return a.name<b.name end)
    Status.Text = "🎯 Detectadas: " .. #detectedItems
end

local function buildList()
    for _, c in ipairs(Scroll:GetChildren()) do
        if c:IsA("TextButton") then c:Destroy() end
    end
    local filter = SearchBox.Text:lower()
    local v = 0
    for _, d in ipairs(detectedItems) do
        if filter == "" or d.name:lower():find(filter, 1, true) then
            v = v + 1
            local btn = Instance.new("TextButton", Scroll)
            btn.Size = UDim2.new(1, -10, 0, 22)
            btn.BackgroundColor3 = selected[d.name] and Color3.fromRGB(50,90,50) or THEME.bgLight
            btn.Text = (selected[d.name] and "✓ " or "  ") .. d.name
            btn.TextColor3 = THEME.text
            btn.Font = Enum.Font.Gotham
            btn.TextSize = 11
            btn.TextXAlignment = Enum.TextXAlignment.Left
            btn.BorderSizePixel = 0
            Instance.new("UICorner", btn).CornerRadius = UDim.new(0,3)
            local pp = Instance.new("UIPadding", btn) pp.PaddingLeft = UDim.new(0,6)
            btn.MouseButton1Click:Connect(function()
                selected[d.name] = not selected[d.name]
                if selected[d.name] then
                    btn.Text = "✓ " .. d.name
                    btn.BackgroundColor3 = Color3.fromRGB(50,90,50)
                else
                    btn.Text = "  " .. d.name
                    btn.BackgroundColor3 = THEME.bgLight
                end
            end)
        end
    end
    Scroll.CanvasSize = UDim2.new(0,0,0,v*24+6)
end

local function findInWorkspace(name)
    local found = {}
    for _, item in ipairs(workspace:GetDescendants()) do
        if item.Name == name and item.Parent and (item:IsA("Model") or item:IsA("BasePart") or item:IsA("Tool")) then
            local inPlayer = false
            local p = item.Parent
            while p do
                if Players:GetPlayerFromCharacter(p) or p:IsA("Backpack") then inPlayer = true break end
                p = p.Parent
            end
            if not inPlayer then table.insert(found, item) end
        end
    end
    return found
end

local function teleportItem(item, cf)
    return pcall(function()
        if item:IsA("Tool") then item.Parent = player.Backpack return end
        local pp
        if item:IsA("Model") then pp = item.PrimaryPart or item:FindFirstChildWhichIsA("BasePart")
        elseif item:IsA("BasePart") then pp = item end
        if not pp then return end
        if pp:IsA("BasePart") then
            pp.AssemblyLinearVelocity = Vector3.zero
            pp.AssemblyAngularVelocity = Vector3.zero
        end
        if item:IsA("Model") then item:PivotTo(cf) else item.CFrame = cf end
        task.delay(0.05, function()
            if pp and pp.Parent then
                pp.AssemblyLinearVelocity = Vector3.zero
                pp.AssemblyAngularVelocity = Vector3.zero
            end
        end)
    end)
end

local function bringSelected()
    local root = getRoot()
    if not root then return 0 end
    local total = 0
    local i = 0
    for name, isSel in pairs(selected) do
        if isSel then
            for _, item in ipairs(findInWorkspace(name)) do
                i = i + 1
                local off = Vector3.new(math.cos(i*0.6)*3, 2+(i%3)*0.5, math.sin(i*0.6)*3)
                if teleportItem(item, root.CFrame * CFrame.new(off)) then total = total+1 end
            end
        end
    end
    return total
end

-- ===== MOVE LOGIC =====
SetSpeedBtn.MouseButton1Click:Connect(function()
    local v = tonumber(SpeedInput.Text)
    local h = getHum()
    if v and h then h.WalkSpeed = v end
end)
SetJumpBtn.MouseButton1Click:Connect(function()
    local v = tonumber(JumpInput.Text)
    local h = getHum()
    if v and h then h.JumpPower = v h.UseJumpPower = true end
end)
ResetMoveBtn.MouseButton1Click:Connect(function()
    local h = getHum()
    if h then
        h.WalkSpeed = 16
        h.JumpPower = 50
    end
    SpeedInput.Text = "16"
    JumpInput.Text = "50"
end)

-- ===== FLY =====
local bv, bg
local function startFly()
    local root = getRoot()
    local h = getHum()
    if not root or not h then return end
    h.PlatformStand = true
    bg = Instance.new("BodyGyro", root)
    bg.MaxTorque = Vector3.new(9e9,9e9,9e9)
    bg.P = 9e9
    bv = Instance.new("BodyVelocity", root)
    bv.MaxForce = Vector3.new(9e9,9e9,9e9)
    bv.Velocity = Vector3.zero
end
local function stopFly()
    local h = getHum()
    if h then h.PlatformStand = false end
    if bv then bv:Destroy() bv = nil end
    if bg then bg:Destroy() bg = nil end
end

FlyBtn.MouseButton1Click:Connect(function()
    flying = not flying
    if flying then
        startFly()
        FlyBtn.Text = "✈️ VOLAR: ON"
        FlyBtn.BackgroundColor3 = THEME.success
    else
        stopFly()
        FlyBtn.Text = "✈️ VOLAR: OFF"
        FlyBtn.BackgroundColor3 = THEME.inactive
    end
end)

FlySpeedInput.FocusLost:Connect(function()
    local v = tonumber(FlySpeedInput.Text)
    if v then flySpeed = v end
end)

RunService.RenderStepped:Connect(function()
    if flying and bv and bg then
        local cam = workspace.CurrentCamera
        bg.CFrame = cam.CFrame
        local move = Vector3.zero
        if UserInputService:IsKeyDown(Enum.KeyCode.W) then move = move + cam.CFrame.LookVector end
        if UserInputService:IsKeyDown(Enum.KeyCode.S) then move = move - cam.CFrame.LookVector end
        if UserInputService:IsKeyDown(Enum.KeyCode.A) then move = move - cam.CFrame.RightVector end
        if UserInputService:IsKeyDown(Enum.KeyCode.D) then move = move + cam.CFrame.RightVector end
        if
