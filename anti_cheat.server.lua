--[[
    Obby Tower anti-cheat (server-side)
    - Allows everyone to join.
    - Bans obvious movement exploiters.
    - Lets trusted developers use admin tools (like fly) without anti-cheat punishment.

    Place this Script in ServerScriptService.
]]

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")

local TRUSTED_USERNAMES = {
    ["loganlacrosse10"] = true,
}

local SETTINGS = {
    MaxWalkSpeed = 36,           -- a little above normal obby movement
    MaxJumpPower = 90,           -- allows jump pads/custom jumps while still blocking extreme hacks
    MaxVerticalVelocity = 160,   -- catches hard fly launches for normal players
    TeleportDistance = 120,      -- studs moved in one check interval
    CheckInterval = 0.15,        -- seconds
    MaxViolations = 6,           -- kick only after repeated suspicious behavior
    ViolationDecayPerSecond = 0.75,
}

local function isTrustedPlayer(player)
    return TRUSTED_USERNAMES[player.Name:lower()] == true
end

local function setupCharacterChecks(player, character)
    local humanoid = character:WaitForChild("Humanoid", 10)
    local root = character:WaitForChild("HumanoidRootPart", 10)

    if not humanoid or not root then
        player:Kick("Character failed to load correctly.")
        return
    end

    local violations = 0
    local lastPosition = root.Position

    local connection
    connection = RunService.Heartbeat:Connect(function(deltaTime)
        if not player.Parent or not character.Parent then
            if connection then connection:Disconnect() end
            return
        end

        local trustedPlayer = isTrustedPlayer(player)

        -- Violation decay so brief lag spikes do not accumulate forever.
        violations = math.max(0, violations - (SETTINGS.ViolationDecayPerSecond * deltaTime))

        -- Enforce sane movement properties for everyone.
        if humanoid.WalkSpeed > SETTINGS.MaxWalkSpeed then
            violations += 1
            humanoid.WalkSpeed = 16
        end

        if humanoid.JumpPower > SETTINGS.MaxJumpPower then
            violations += 1
            humanoid.JumpPower = 50
        end

        -- Trusted developer/admin accounts can use movement tools (fly/teleport).
        if not trustedPlayer then
            local currentPosition = root.Position
            local movedDistance = (currentPosition - lastPosition).Magnitude

            -- Normalize movement checks over time.
            local expectedLimit = SETTINGS.TeleportDistance * math.max(deltaTime / SETTINGS.CheckInterval, 1)
            if movedDistance > expectedLimit then
                violations += 1
                root.CFrame = CFrame.new(lastPosition)
            end

            if math.abs(root.AssemblyLinearVelocity.Y) > SETTINGS.MaxVerticalVelocity then
                violations += 1
                root.AssemblyLinearVelocity = Vector3.new(root.AssemblyLinearVelocity.X, 0, root.AssemblyLinearVelocity.Z)
            end

            -- Basic anti-fly: suspended in air without normal movement states.
            local state = humanoid:GetState()
            if humanoid.FloorMaterial == Enum.Material.Air
                and state ~= Enum.HumanoidStateType.Freefall
                and state ~= Enum.HumanoidStateType.Jumping
                and root.AssemblyLinearVelocity.Magnitude < 2 then
                violations += 1
            end

            lastPosition = root.Position
        else
            -- Keep last position current for trusted users while they fly/teleport.
            lastPosition = root.Position
        end

        if violations >= SETTINGS.MaxViolations then
            player:Kick("Obvious exploit detected by anti-cheat.")
            if connection then connection:Disconnect() end
            return
        end
    end)

    character.AncestryChanged:Connect(function(_, parent)
        if not parent and connection then
            connection:Disconnect()
        end
    end)
end

Players.PlayerAdded:Connect(function(player)
    player.CharacterAdded:Connect(function(character)
        setupCharacterChecks(player, character)
    end)
end)

-- Handle players already present when script starts.
for _, player in Players:GetPlayers() do
    if player.Character then
        setupCharacterChecks(player, player.Character)
    end

    player.CharacterAdded:Connect(function(character)
        setupCharacterChecks(player, character)
    end)
end
