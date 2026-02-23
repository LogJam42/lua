local Players = game:GetService("Players")
local BadgeService = game:GetService("BadgeService")
local DataStoreService = game:GetService("DataStoreService")

local LEADERBOARD_STORE = DataStoreService:GetOrderedDataStore("BadgeCountLeaderboard")

local CONFIG = {
	-- Add every badge from your game here.
	BADGE_IDS = {
		-- 1234567890,
		-- 9876543210,
	},

	-- Easy-to-edit blacklist. Any badge IDs in this table are ignored.
	BLACKLIST_BADGES = {
		[255682684579576] = true,
		[4439548017971752] = true,
	},

	AUTO_REFRESH_SECONDS = 120,
}

local function isBlacklisted(badgeId: number): boolean
	return CONFIG.BLACKLIST_BADGES[badgeId] == true
end

local function ensureLeaderstats(player: Player): NumberValue
	local leaderstats = player:FindFirstChild("leaderstats")
	if not leaderstats then
		leaderstats = Instance.new("Folder")
		leaderstats.Name = "leaderstats"
		leaderstats.Parent = player
	end

	local badgeCount = leaderstats:FindFirstChild("Badges")
	if not badgeCount then
		badgeCount = Instance.new("NumberValue")
		badgeCount.Name = "Badges"
		badgeCount.Parent = leaderstats
	end

	return badgeCount
end

local function countPlayerBadges(player: Player): number
	local total = 0

	for _, badgeId in ipairs(CONFIG.BADGE_IDS) do
		if not isBlacklisted(badgeId) then
			local ok, ownsBadge = pcall(function()
				return BadgeService:UserHasBadgeAsync(player.UserId, badgeId)
			end)

			if ok and ownsBadge then
				total += 1
			end
		end
	end

	return total
end

local function updatePlayerBadgeCount(player: Player)
	local badgeCountValue = ensureLeaderstats(player)
	local badgeCount = countPlayerBadges(player)

	badgeCountValue.Value = badgeCount

	local ok, err = pcall(function()
		LEADERBOARD_STORE:SetAsync(tostring(player.UserId), badgeCount)
	end)

	if not ok then
		warn(string.format("Failed to save badge count for %s (%d): %s", player.Name, player.UserId, err))
	end
end

local function onPlayerAdded(player: Player)
	updatePlayerBadgeCount(player)

	task.spawn(function()
		while player.Parent == Players do
			task.wait(CONFIG.AUTO_REFRESH_SECONDS)
			updatePlayerBadgeCount(player)
		end
	end)
end

Players.PlayerAdded:Connect(onPlayerAdded)

for _, player in ipairs(Players:GetPlayers()) do
	task.spawn(onPlayerAdded, player)
end
