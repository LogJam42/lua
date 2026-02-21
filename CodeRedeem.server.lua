local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local EVENT_NAME = "SecretCodeRedeemEvent"

-- Customize these codes easily.
-- "PK9095" gives every Tool found in ReplicatedStorage.
-- Other codes can grant specific items by name.
local codeRewards = {
	PK9095 = {
		grantAllTools = true,
	},
	STARTER = {
		itemNames = { "LinkedSword", "Slingshot" },
	},
}

local redeemedByPlayer = {}

local redeemEvent = ReplicatedStorage:FindFirstChild(EVENT_NAME)
if not redeemEvent then
	redeemEvent = Instance.new("RemoteEvent")
	redeemEvent.Name = EVENT_NAME
	redeemEvent.Parent = ReplicatedStorage
end

local function normalizeCode(rawCode)
	if typeof(rawCode) ~= "string" then
		return ""
	end

	local trimmed = rawCode:gsub("^%s+", ""):gsub("%s+$", "")
	return string.upper(trimmed)
end

local function hasTool(player, toolName)
	local backpack = player:FindFirstChildOfClass("Backpack")
	if backpack and backpack:FindFirstChild(toolName) then
		return true
	end

	local starterGear = player:FindFirstChild("StarterGear")
	if starterGear and starterGear:FindFirstChild(toolName) then
		return true
	end

	local character = player.Character
	if character and character:FindFirstChild(toolName) then
		return true
	end

	return false
end

local function grantTool(player, tool)
	if not tool:IsA("Tool") then
		return false
	end

	if hasTool(player, tool.Name) then
		return false
	end

	local backpack = player:FindFirstChildOfClass("Backpack")
	local starterGear = player:FindFirstChild("StarterGear")
	if not backpack or not starterGear then
		return false
	end

	tool:Clone().Parent = backpack
	tool:Clone().Parent = starterGear
	return true
end

local function grantByNames(player, itemNames)
	local granted = 0
	for _, itemName in ipairs(itemNames) do
		local item = ReplicatedStorage:FindFirstChild(itemName, true)
		if item and grantTool(player, item) then
			granted += 1
		end
	end

	return granted
end

local function grantAllTools(player)
	local granted = 0
	for _, item in ipairs(ReplicatedStorage:GetDescendants()) do
		if item:IsA("Tool") and grantTool(player, item) then
			granted += 1
		end
	end

	return granted
end

redeemEvent.OnServerEvent:Connect(function(player, rawCode)
	local code = normalizeCode(rawCode)
	if code == "" then
		redeemEvent:FireClient(player, false, "Please enter a code.")
		return
	end

	redeemedByPlayer[player] = redeemedByPlayer[player] or {}
	if redeemedByPlayer[player][code] then
		redeemEvent:FireClient(player, false, "You already used that code.")
		return
	end

	local reward = codeRewards[code]
	if not reward then
		redeemEvent:FireClient(player, false, "Invalid code.")
		return
	end

	local grantedCount = 0
	if reward.grantAllTools then
		grantedCount = grantAllTools(player)
	elseif reward.itemNames then
		grantedCount = grantByNames(player, reward.itemNames)
	end

	if grantedCount <= 0 then
		redeemEvent:FireClient(player, false, "Code worked, but no new tools were granted.")
		return
	end

	redeemedByPlayer[player][code] = true
	redeemEvent:FireClient(player, true, ("Code redeemed! Granted %d item(s).":format(grantedCount)))
end)

Players.PlayerRemoving:Connect(function(player)
	redeemedByPlayer[player] = nil
end)
