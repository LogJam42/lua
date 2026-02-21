local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local player = Players.LocalPlayer
local playerGui = player:WaitForChild("PlayerGui")
local redeemEvent = ReplicatedStorage:WaitForChild("SecretCodeRedeemEvent", 10)

local existing = playerGui:FindFirstChild("SecretGui")
if existing then
	existing:Destroy()
end

local screenGui = Instance.new("ScreenGui")
screenGui.Name = "SecretGui"
screenGui.ResetOnSpawn = false
screenGui.IgnoreGuiInset = true
screenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
screenGui.Parent = playerGui

local card = Instance.new("Frame")
card.Name = "Frame"
card.AnchorPoint = Vector2.new(0.5, 0.5)
card.Position = UDim2.fromScale(0.5, 0.5)
card.Size = UDim2.fromScale(0.34, 0.32)
card.BackgroundColor3 = Color3.fromRGB(21, 24, 34)
card.BorderSizePixel = 0
card.Visible = false
card.Parent = screenGui

local cardCorner = Instance.new("UICorner")
cardCorner.CornerRadius = UDim.new(0, 16)
cardCorner.Parent = card

local cardStroke = Instance.new("UIStroke")
cardStroke.Color = Color3.fromRGB(86, 103, 255)
cardStroke.Thickness = 2
cardStroke.Parent = card

local gradient = Instance.new("UIGradient")
gradient.Rotation = 35
gradient.Color = ColorSequence.new({
	ColorSequenceKeypoint.new(0, Color3.fromRGB(47, 56, 81)),
	ColorSequenceKeypoint.new(1, Color3.fromRGB(21, 24, 34)),
})
gradient.Parent = card

local padding = Instance.new("UIPadding")
padding.PaddingTop = UDim.new(0, 18)
padding.PaddingBottom = UDim.new(0, 18)
padding.PaddingLeft = UDim.new(0, 18)
padding.PaddingRight = UDim.new(0, 18)
padding.Parent = card

local list = Instance.new("UIListLayout")
list.HorizontalAlignment = Enum.HorizontalAlignment.Left
list.VerticalAlignment = Enum.VerticalAlignment.Top
list.SortOrder = Enum.SortOrder.LayoutOrder
list.Padding = UDim.new(0, 10)
list.Parent = card

local title = Instance.new("TextLabel")
title.Name = "Title"
title.LayoutOrder = 1
title.Size = UDim2.fromScale(1, 0)
title.AutomaticSize = Enum.AutomaticSize.Y
title.BackgroundTransparency = 1
title.Font = Enum.Font.GothamBold
title.Text = "Secret Codes"
title.TextColor3 = Color3.fromRGB(255, 255, 255)
title.TextSize = 28
title.TextXAlignment = Enum.TextXAlignment.Left
title.Parent = card

local codeBox = Instance.new("TextBox")
codeBox.Name = "CodeBox"
codeBox.LayoutOrder = 2
codeBox.Size = UDim2.fromScale(1, 0)
codeBox.AutomaticSize = Enum.AutomaticSize.Y
codeBox.BackgroundColor3 = Color3.fromRGB(33, 37, 50)
codeBox.BorderSizePixel = 0
codeBox.ClearTextOnFocus = false
codeBox.Font = Enum.Font.Gotham
codeBox.PlaceholderText = "Enter code (example: PK9095)"
codeBox.Text = ""
codeBox.TextColor3 = Color3.fromRGB(255, 255, 255)
codeBox.PlaceholderColor3 = Color3.fromRGB(164, 171, 214)
codeBox.TextSize = 16
codeBox.Parent = card

local codeBoxCorner = Instance.new("UICorner")
codeBoxCorner.CornerRadius = UDim.new(0, 10)
codeBoxCorner.Parent = codeBox

local codeBoxPadding = Instance.new("UIPadding")
codeBoxPadding.PaddingTop = UDim.new(0, 10)
codeBoxPadding.PaddingBottom = UDim.new(0, 10)
codeBoxPadding.PaddingLeft = UDim.new(0, 12)
codeBoxPadding.PaddingRight = UDim.new(0, 12)
codeBoxPadding.Parent = codeBox

local statusLabel = Instance.new("TextLabel")
statusLabel.Name = "StatusLabel"
statusLabel.LayoutOrder = 3
statusLabel.Size = UDim2.fromScale(1, 0)
statusLabel.AutomaticSize = Enum.AutomaticSize.Y
statusLabel.BackgroundTransparency = 1
statusLabel.Font = Enum.Font.Gotham
statusLabel.Text = ""
statusLabel.TextColor3 = Color3.fromRGB(208, 214, 255)
statusLabel.TextSize = 14
statusLabel.TextWrapped = true
statusLabel.TextXAlignment = Enum.TextXAlignment.Left
statusLabel.Parent = card

local buttonRow = Instance.new("Frame")
buttonRow.Name = "ButtonRow"
buttonRow.LayoutOrder = 4
buttonRow.Size = UDim2.fromScale(1, 0)
buttonRow.AutomaticSize = Enum.AutomaticSize.Y
buttonRow.BackgroundTransparency = 1
buttonRow.Parent = card

local rowLayout = Instance.new("UIListLayout")
rowLayout.FillDirection = Enum.FillDirection.Horizontal
rowLayout.HorizontalAlignment = Enum.HorizontalAlignment.Left
rowLayout.VerticalAlignment = Enum.VerticalAlignment.Center
rowLayout.Padding = UDim.new(0, 10)
rowLayout.Parent = buttonRow

local redeemButton = Instance.new("TextButton")
redeemButton.Name = "RedeemButton"
redeemButton.Size = UDim2.fromOffset(128, 38)
redeemButton.BackgroundColor3 = Color3.fromRGB(86, 103, 255)
redeemButton.BorderSizePixel = 0
redeemButton.Font = Enum.Font.GothamBold
redeemButton.Text = "Redeem"
redeemButton.TextColor3 = Color3.fromRGB(255, 255, 255)
redeemButton.TextSize = 15
redeemButton.Parent = buttonRow

local redeemCorner = Instance.new("UICorner")
redeemCorner.CornerRadius = UDim.new(0, 10)
redeemCorner.Parent = redeemButton

local closeButton = Instance.new("TextButton")
closeButton.Name = "CloseButton"
closeButton.Size = UDim2.fromOffset(128, 38)
closeButton.BackgroundColor3 = Color3.fromRGB(56, 62, 84)
closeButton.BorderSizePixel = 0
closeButton.Font = Enum.Font.GothamBold
closeButton.Text = "Close"
closeButton.TextColor3 = Color3.fromRGB(255, 255, 255)
closeButton.TextSize = 15
closeButton.Parent = buttonRow

local closeCorner = Instance.new("UICorner")
closeCorner.CornerRadius = UDim.new(0, 10)
closeCorner.Parent = closeButton

local function updateStatus(message, color)
	statusLabel.Text = message
	statusLabel.TextColor3 = color or Color3.fromRGB(208, 214, 255)
end

local function submitCode()
	if not redeemEvent then
		updateStatus("Redeem event not found. Add CodeRedeem.server.lua to ServerScriptService.", Color3.fromRGB(255, 163, 163))
		return
	end

	local code = codeBox.Text:gsub("^%s+", ""):gsub("%s+$", "")
	if code == "" then
		updateStatus("Type a code first.", Color3.fromRGB(255, 212, 128))
		return
	end

	redeemEvent:FireServer(code)
end

if redeemEvent then
	redeemEvent.OnClientEvent:Connect(function(success, message)
		if success then
			updateStatus(message, Color3.fromRGB(154, 255, 154))
			codeBox.Text = ""
		else
			updateStatus(message, Color3.fromRGB(255, 163, 163))
		end
	end)
end

redeemButton.MouseButton1Click:Connect(submitCode)
codeBox.FocusLost:Connect(function(enterPressed)
	if enterPressed then
		submitCode()
	end
end)

closeButton.MouseButton1Click:Connect(function()
	card.Visible = false
end)
