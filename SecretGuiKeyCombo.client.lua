local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")

local REQUIRED_PRESSES = 5
local TIME_LIMIT_SECONDS = 3
local GUI_NAME = "SecretGui"
local FRAME_NAME = "Frame"

local player = Players.LocalPlayer
local playerGui = player:WaitForChild("PlayerGui")

-- Wait for GUI replication from StarterGui. A timeout prevents endless hanging.
local gui = playerGui:WaitForChild(GUI_NAME, 10)
if not gui then
	warn(("%s was not found in PlayerGui after waiting 10 seconds."):format(GUI_NAME))
	return
end

local frame = gui:WaitForChild(FRAME_NAME, 10)
if not frame then
	warn(("%s was not found in %s after waiting 10 seconds."):format(FRAME_NAME, GUI_NAME))
	return
end

frame.Visible = false

local pressCount = 0
local firstPressTime = 0

UserInputService.InputBegan:Connect(function(input, gameProcessed)
	if gameProcessed then
		return
	end

	if input.KeyCode ~= Enum.KeyCode.K then
		return
	end

	local now = tick()

	if pressCount == 0 or (now - firstPressTime > TIME_LIMIT_SECONDS) then
		pressCount = 1
		firstPressTime = now
	else
		pressCount += 1
	end

	if pressCount >= REQUIRED_PRESSES then
		frame.Visible = true
		pressCount = 0
	end
end)
