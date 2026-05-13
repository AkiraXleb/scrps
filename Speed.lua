-- GUI de velocidad
local ScreenGui = Instance.new("ScreenGui")
local Frame = Instance.new("Frame")
local Label = Instance.new("TextLabel")
local Input = Instance.new("TextBox")

-- Configurar la GUI
ScreenGui.Parent = game.CoreGui

Frame.Parent = ScreenGui
Frame.Size = UDim2.new(0, 200, 0, 80)
Frame.Position = UDim2.new(0.5, -100, 0.5, -40)
Frame.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
Frame.BorderSizePixel = 0

-- Esquinas redondeadas
local Corner = Instance.new("UICorner")
Corner.CornerRadius = UDim.new(0, 8)
Corner.Parent = Frame

-- Etiqueta
Label.Parent = Frame
Label.Size = UDim2.new(1, 0, 0.4, 0)
Label.BackgroundTransparency = 1
Label.Text = "Introducir Velocidad"
Label.TextColor3 = Color3.fromRGB(255, 255, 255)
Label.Font = Enum.Font.GothamBold
Label.TextScaled = true

-- Caja de texto
Input.Parent = Frame
Input.Size = UDim2.new(0.9, 0, 0.4, 0)
Input.Position = UDim2.new(0.05, 0, 0.55, 0)
Input.BackgroundColor3 = Color3.fromRGB(60, 60, 60)
Input.TextColor3 = Color3.fromRGB(255, 255, 255)
Input.PlaceholderText = "Ej: 50"
Input.Font = Enum.Font.Gotham
Input.TextScaled = true
Input.ClearTextOnFocus = false
Input.Text = ""

local InputCorner = Instance.new("UICorner")
InputCorner.CornerRadius = UDim.new(0, 6)
InputCorner.Parent = Input

-- Lógica al presionar Enter
Input.FocusLost:Connect(function(enterPressed)
    if enterPressed then
        local speed = tonumber(Input.Text)
        if speed then
            local char = game.Players.LocalPlayer.Character
            if char then
                char.Humanoid.WalkSpeed = speed
            end
        else
            Input.Text = ""
            Input.PlaceholderText = "Número inválido!"
        end
    end
end)
