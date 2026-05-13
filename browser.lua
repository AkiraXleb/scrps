-- ⚔️ Dusty Trip Universal Weapon Hub
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local player = Players.LocalPlayer

-- Palabras clave que identifican armas
local weaponKeywords = {
    "launcher", "gun", "rifle", "pistol", "shotgun", "smg",
    "knife", "sword", "machete", "blade", "katana",
    "bat", "axe", "hammer", "crowbar", "club",
    "grenade", "bomb", "explosive", "tnt", "dynamite",
    "revolver", "sniper", "uzi", "ak", "ar15", "minigun",
    "bow", "crossbow", "spear", "arrow", "dagger",
    "rocket", "flame", "thrower", "laser", "ray",
    "weapon", "firearm",
}

local detectedItems = {}  -- {name = string, item = Instance}
local selected = {}       -- {[name] = bool}

-- =====================
--        GUI
-- =====================
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Parent = game.CoreGui
ScreenGui.ResetOnSpawn = false

local Frame = Instance.new("Frame")
Frame.Parent = ScreenGui
Frame.Size = UDim2.new(0, 320, 0, 520)
Frame.Position = UDim2.new(0, 20, 0.05, 0)
Frame.BackgroundColor3 = Color3.fromRGB(20, 20, 25)
Frame.Active = true
Frame.Draggable = true
local fc = Instance.new("UICorner") fc.CornerRadius = UDim.new(0,12) fc.Parent = Frame

local Stroke = Instance.new("UIStroke")
Stroke.Parent = Frame
Stroke.Color = Color3.fromRGB(255, 80, 80)
Stroke.Thickness = 2

local Title = Instance.new("TextLabel")
Title.Parent = Frame
Title.Size = UDim2.new(1, 0, 0, 40)
Title.BackgroundColor3 = Color3.fromRGB(10, 10, 15)
Title.Text = "⚔️ Universal Weapon Hub"
Title.TextColor3 = Color3.fromRGB(255, 80, 80)
Title.Font = Enum.Font.GothamBold
Title.TextScaled = true
local tc = Instance.new("UICorner") tc.CornerRadius = UDim.new(0,12) tc.Parent = Title

local Status = Instance.new("TextLabel")
Status.Parent = Frame
Status.Size = UDim2.new(0.9, 0, 0, 22)
Status.Position = UDim2.new(0.05, 0, 0, 45)
Status.BackgroundTransparency = 1
Status.Text = "⏳ Detectando armas..."
Status.TextColor3 = Color3.fromRGB(200, 200, 200)
Status.Font = Enum.Font.Gotham
Status.TextScaled = true

-- Buscador
local SearchBox = Instance.new("TextBox")
SearchBox.Parent = Frame
SearchBox.Size = UDim2.new(0.9, 0, 0, 28)
SearchBox.Position = UDim2.new(0.05, 0, 0, 72)
SearchBox.BackgroundColor3 = Color3.fromRGB(40, 40, 45)
SearchBox.PlaceholderText = "🔍 Filtrar armas..."
SearchBox.Text = ""
SearchBox.TextColor3 = Color3.fromRGB(255, 255, 255)
SearchBox.PlaceholderColor3 = Color3.fromRGB(140, 140, 140)
SearchBox.Font = Enum.Font.Gotham
SearchBox.TextSize = 13
SearchBox.ClearTextOnFocus = false
local sc = Instance.new("UICorner") sc.CornerRadius = UDim.new(0,6) sc.Parent = SearchBox

-- Quick action buttons (Select All / None)
local SelectAllBtn = Instance.new("TextButton")
SelectAllBtn.Parent = Frame
SelectAllBtn.Size = UDim2.new(0.43, 0, 0, 25)
SelectAllBtn.Position = UDim2.new(0.05, 0, 0, 108)
SelectAllBtn.BackgroundColor3 = Color3.fromRGB(60, 120, 60)
SelectAllBtn.Text = "✅ Seleccionar todo"
SelectAllBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
SelectAllBtn.Font = Enum.Font.GothamBold
SelectAllBtn.TextSize = 11
local sac = Instance.new("UICorner") sac.CornerRadius = UDim.new(0,4) sac.Parent = SelectAllBtn

local DeselectBtn = Instance.new("TextButton")
DeselectBtn.Parent = Frame
DeselectBtn.Size = UDim2.new(0.43, 0, 0, 25)
DeselectBtn.Position = UDim2.new(0.52, 0, 0, 108)
DeselectBtn.BackgroundColor3 = Color3.fromRGB(120, 60, 60)
DeselectBtn.Text = "❌ Deseleccionar"
DeselectBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
DeselectBtn.Font = Enum.Font.GothamBold
DeselectBtn.TextSize = 11
local dc = Instance.new("UICorner") dc.CornerRadius = UDim.new(0,4) dc.Parent = DeselectBtn

-- ScrollFrame
local Scroll = Instance.new("ScrollingFrame")
Scroll.Parent = Frame
Scroll.Size = UDim2.new(1, -20, 0, 250)
Scroll.Position = UDim2.new(0, 10, 0, 140)
Scroll.BackgroundColor3 = Color3.fromRGB(12, 12, 15)
Scroll.ScrollBarThickness = 5
Scroll.CanvasSize = UDim2.new(0, 0, 0, 0)
local scrc = Instance.new("UICorner") scrc.CornerRadius = UDim.new(0,6) scrc.Parent = Scroll

local Layout = Instance.new("UIListLayout")
Layout.Parent = Scroll
Layout.Padding = UDim.new(0, 2)

local Padd = Instance.new("UIPadding")
Padd.Parent = Scroll
Padd.PaddingTop = UDim.new(0, 4)
Padd.PaddingLeft = UDim.new(0, 4)

-- Botones de acción
local function makeBtn(text, posY, color)
    local btn = Instance.new("TextButton")
    btn.Parent = Frame
    btn.Size = UDim2.new(0.9, 0, 0, 30)
    btn.Position = UDim2.new(0.05, 0, 0, posY)
    btn.BackgroundColor3 = color
    btn.Text = text
    btn.TextColor3 = Color3.fromRGB(255, 255, 255)
    btn.Font = Enum.Font.GothamBold
    btn.TextScaled = true
    local cc = Instance.new("UICorner") cc.CornerRadius = UDim.new(0,6) cc.Parent = btn
    return btn
end

local ScanBtn  = makeBtn("🔍 Re-detectar armas",   400, Color3.fromRGB(120, 100, 200))
local BringBtn = makeBtn("⚡ Traer seleccionadas", 435, Color3.fromRGB(255, 140, 0))
local AutoBtn  = makeBtn("🔄 Auto-Bring: OFF",     470, Color3.fromRGB(200, 60, 60))

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

    -- Escanear ReplicatedStorage.Assets.Items (donde sabemos que están)
    pcall(function()
        local assets = ReplicatedStorage:FindFirstChild("Assets")
        if assets then
            local items = assets:FindFirstChild("Items")
            if items then scanFolder(items) end
        end
    end)

    -- Por si acaso, escanear otras carpetas comunes
    pcall(function()
        for _, child in ipairs(ReplicatedStorage:GetDescendants()) do
            if child:IsA("Folder") and (child.Name == "Weapons" or child.Name == "Tools") then
                scanFolder(child)
            end
        end
    end)

    -- Ordenar alfabéticamente
    table.sort(detectedItems, function(a, b) return a.name < b.name end)

    Status.Text = "🎯 Armas detectadas: " .. #detectedItems
end

local function buildList()
    -- Limpiar lista actual
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
            btn.Size = UDim2.new(1, -15, 0, 28)
            btn.BackgroundColor3 = selected[data.name] and Color3.fromRGB(50, 100, 50) or Color3.fromRGB(40, 40, 45)
            btn.Text = (selected[data.name] and "✅ " or "⬜ ") .. data.name
            btn.TextColor3 = Color3.fromRGB(255, 255, 255)
            btn.Font = Enum.Font.Gotham
            btn.TextSize = 12
            btn.TextXAlignment = Enum.TextXAlignment.Left
            local bcc = Instance.new("UICorner") bcc.CornerRadius = UDim.new(0,4) bcc.Parent = btn
            local pp = Instance.new("UIPadding") pp.Parent = btn pp.PaddingLeft = UDim.new(0, 8)

            btn.MouseButton1Click:Connect(function()
                selected[data.name] = not selected[data.name]
                if selected[data.name] then
                    btn.Text = "✅ " .. data.name
                    btn.BackgroundColor3 = Color3.fromRGB(50, 100, 50)
                else
                    btn.Text = "⬜ " .. data.name
                    btn.BackgroundColor3 = Color3.fromRGB(40, 40, 45)
                end
            end)
        end
    end

    Scroll.CanvasSize = UDim2.new(0, 0, 0, visible * 30 + 10)
end

-- Buscar en workspace
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
    for _, data in ipairs(detectedItems) do
        selected[data.name] = true
    end
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
        AutoBtn.BackgroundColor3 = Color3.fromRGB(60, 180, 60)
    else
        AutoBtn.Text = "🔄 Auto-Bring: OFF"
        AutoBtn.BackgroundColor3 = Color3.fromRGB(200, 60, 60)
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

-- Inicio automático
detectWeapons()
buildList()
