-- 🔎 Game Data Extractor
local player = game.Players.LocalPlayer

-- GUI
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Parent = game.CoreGui
ScreenGui.ResetOnSpawn = false

local Frame = Instance.new("Frame")
Frame.Parent = ScreenGui
Frame.Size = UDim2.new(0, 400, 0, 500)
Frame.Position = UDim2.new(0.5, -200, 0.5, -250)
Frame.BackgroundColor3 = Color3.fromRGB(25, 25, 25)
Frame.Active = true
Frame.Draggable = true
local fc = Instance.new("UICorner") fc.CornerRadius = UDim.new(0,10) fc.Parent = Frame

local Title = Instance.new("TextLabel")
Title.Parent = Frame
Title.Size = UDim2.new(1, 0, 0, 35)
Title.BackgroundColor3 = Color3.fromRGB(15, 15, 15)
Title.Text = "🔎 Game Data Extractor"
Title.TextColor3 = Color3.fromRGB(100, 200, 255)
Title.Font = Enum.Font.GothamBold
Title.TextScaled = true
local tc = Instance.new("UICorner") tc.CornerRadius = UDim.new(0,10) tc.Parent = Title

-- Buscador
local SearchBox = Instance.new("TextBox")
SearchBox.Parent = Frame
SearchBox.Size = UDim2.new(1, -20, 0, 30)
SearchBox.Position = UDim2.new(0, 10, 0, 45)
SearchBox.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
SearchBox.PlaceholderText = "🔍 Filtrar por nombre (ej: egg, gold, launch...)"
SearchBox.Text = ""
SearchBox.TextColor3 = Color3.fromRGB(255, 255, 255)
SearchBox.PlaceholderColor3 = Color3.fromRGB(150, 150, 150)
SearchBox.Font = Enum.Font.Gotham
SearchBox.TextSize = 13
SearchBox.ClearTextOnFocus = false
local sc = Instance.new("UICorner") sc.CornerRadius = UDim.new(0,6) sc.Parent = SearchBox

-- Botones de filtro
local function makeFilter(text, posX, color)
    local btn = Instance.new("TextButton")
    btn.Parent = Frame
    btn.Size = UDim2.new(0, 90, 0, 25)
    btn.Position = UDim2.new(0, posX, 0, 85)
    btn.BackgroundColor3 = color
    btn.Text = text
    btn.TextColor3 = Color3.fromRGB(255, 255, 255)
    btn.Font = Enum.Font.GothamBold
    btn.TextSize = 11
    local cc = Instance.new("UICorner") cc.CornerRadius = UDim.new(0,4) cc.Parent = btn
    return btn
end

local AllBtn   = makeFilter("Todo",       10,  Color3.fromRGB(80, 80, 80))
local ToolBtn  = makeFilter("Tools",      110, Color3.fromRGB(60, 120, 200))
local ModelBtn = makeFilter("Models",     210, Color3.fromRGB(120, 60, 200))
local CopyBtn  = makeFilter("📋 Copiar",  310, Color3.fromRGB(60, 180, 60))

-- Lista scrollable
local Scroll = Instance.new("ScrollingFrame")
Scroll.Parent = Frame
Scroll.Size = UDim2.new(1, -10, 1, -160)
Scroll.Position = UDim2.new(0, 5, 0, 120)
Scroll.BackgroundColor3 = Color3.fromRGB(15, 15, 15)
Scroll.ScrollBarThickness = 6
Scroll.CanvasSize = UDim2.new(0, 0, 0, 0)
local scc = Instance.new("UICorner") scc.CornerRadius = UDim.new(0,6) scc.Parent = Scroll

local Layout = Instance.new("UIListLayout")
Layout.Parent = Scroll
Layout.Padding = UDim.new(0, 2)
Layout.SortOrder = Enum.SortOrder.LayoutOrder

-- Botón de scan
local ScanBtn = Instance.new("TextButton")
ScanBtn.Parent = Frame
ScanBtn.Size = UDim2.new(1, -20, 0, 30)
ScanBtn.Position = UDim2.new(0, 10, 1, -35)
ScanBtn.BackgroundColor3 = Color3.fromRGB(255, 165, 0)
ScanBtn.Text = "🔄 ESCANEAR JUEGO"
ScanBtn.TextColor3 = Color3.fromRGB(0, 0, 0)
ScanBtn.Font = Enum.Font.GothamBold
ScanBtn.TextScaled = true
local sbc = Instance.new("UICorner") sbc.CornerRadius = UDim.new(0,6) sbc.Parent = ScanBtn

-- =====================
--       LÓGICA
-- =====================
local allItems = {}
local currentFilter = "all"

local function clearList()
    for _, child in ipairs(Scroll:GetChildren()) do
        if child:IsA("Frame") then child:Destroy() end
    end
end

local function addEntry(item, index)
    local row = Instance.new("Frame")
    row.Parent = Scroll
    row.Size = UDim2.new(1, -10, 0, 45)
    row.BackgroundColor3 = Color3.fromRGB(35, 35, 35)
    row.LayoutOrder = index
    local rc = Instance.new("UICorner") rc.CornerRadius = UDim.new(0,4) rc.Parent = row

    local name = Instance.new("TextLabel")
    name.Parent = row
    name.Size = UDim2.new(1, -10, 0, 22)
    name.Position = UDim2.new(0, 5, 0, 2)
    name.BackgroundTransparency = 1
    name.Text = "📦 " .. item.Name
    name.TextColor3 = Color3.fromRGB(255, 220, 100)
    name.Font = Enum.Font.GothamBold
    name.TextSize = 14
    name.TextXAlignment = Enum.TextXAlignment.Left

    local info = Instance.new("TextLabel")
    info.Parent = row
    info.Size = UDim2.new(1, -10, 0, 18)
    info.Position = UDim2.new(0, 5, 0, 22)
    info.BackgroundTransparency = 1
    info.Text = item.ClassName .. " | " .. item:GetFullName()
    info.TextColor3 = Color3.fromRGB(180, 180, 180)
    info.Font = Enum.Font.Gotham
    info.TextSize = 11
    info.TextXAlignment = Enum.TextXAlignment.Left
    info.TextTruncate = Enum.TextTruncate.AtEnd
end

local function refresh()
    clearList()
    local filter = SearchBox.Text:lower()
    local shown = 0

    for i, item in ipairs(allItems) do
        local matchFilter = true

        -- Filtro de tipo
        if currentFilter == "tools" and not item:IsA("Tool") then
            matchFilter = false
        elseif currentFilter == "models" and not item:IsA("Model") then
            matchFilter = false
        end

        -- Filtro de texto
        if matchFilter and filter ~= "" then
            if not item.Name:lower():find(filter, 1, true) then
                matchFilter = false
            end
        end

        if matchFilter then
            shown = shown + 1
            addEntry(item, shown)
            if shown >= 200 then break end -- limitar para que no crashee
        end
    end

    Scroll.CanvasSize = UDim2.new(0, 0, 0, shown * 47)
    Title.Text = "🔎 Mostrando: " .. shown .. " items"
end

local function scanGame()
    allItems = {}
    Title.Text = "⏳ Escaneando..."

    -- Lugares donde típicamente hay items
    local locations = {
        workspace,
        game:GetService("ReplicatedStorage"),
        game:GetService("ServerStorage"), -- puede no ser accesible
        player.Backpack,
        player.Character,
    }

    for _, loc in ipairs(locations) do
        pcall(function()
            for _, item in ipairs(loc:GetDescendants()) do
                if item:IsA("Tool") or item:IsA("Model") then
                    table.insert(allItems, item)
                end
            end
        end)
    end

    -- Ordenar alfabéticamente
    table.sort(allItems, function(a, b) return a.Name < b.Name end)

    refresh()
end

-- Eventos
ScanBtn.MouseButton1Click:Connect(scanGame)
SearchBox:GetPropertyChangedSignal("Text"):Connect(refresh)

AllBtn.MouseButton1Click:Connect(function() currentFilter = "all" refresh() end)
ToolBtn.MouseButton1Click:Connect(function() currentFilter = "tools" refresh() end)
ModelBtn.MouseButton1Click:Connect(function() currentFilter = "models" refresh() end)

-- Botón de copiar (usa setclipboard del ejecutor)
CopyBtn.MouseButton1Click:Connect(function()
    local filter = SearchBox.Text:lower()
    local lines = {}
    for _, item in ipairs(allItems) do
        if filter == "" or item.Name:lower():find(filter, 1, true) then
            table.insert(lines, item.Name .. " | " .. item.ClassName .. " | " .. item:GetFullName())
        end
    end
    local text = table.concat(lines, "\n")

    if setclipboard then
        setclipboard(text)
        Title.Text = "📋 Copiado al portapapeles!"
    elseif toclipboard then
        toclipboard(text)
        Title.Text = "📋 Copiado!"
    else
        print(text)
        Title.Text = "📋 Impreso en consola"
    end
end)

-- Scan inicial automático
scanGame()
