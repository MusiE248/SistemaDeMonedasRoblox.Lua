local Players = game:GetService("Players")
local DataStoreService = game:GetService("DataStoreService")
local CoinsDataStore = DataStoreService:GetDataStore("PlayerCoins")
local coinFolder = workspace:WaitForChild("Monedas")

local playerCoins = {}
local respawnTime = 5 -- Aparece cada X segundo

local coinValues = {
	Mon_1 = 1,
	Mon_2 = 4,
	Mon_3 = 10,
	Mon_4 = 20,
}

local function saveCoins(player, coins)
	pcall(function()
		CoinsDataStore:SetAsync(player.UserId, coins)
	end)
end

local function loadCoins(player)
	local coins = 0
	local success, result = pcall(function()
		return CoinsDataStore:GetAsync(player.UserId)
	end)
	if success and result then
		coins = result
	end
	return coins
end

Players.PlayerAdded:Connect(function(player)
	local leaderstats = Instance.new("Folder")
	leaderstats.Name = "leaderstats"
	leaderstats.Parent = player

	local coinsValue = Instance.new("IntValue")
	coinsValue.Name = "Coins"
	coinsValue.Value = loadCoins(player)
	coinsValue.Parent = leaderstats

	playerCoins[player.UserId] = coinsValue
end)

Players.PlayerRemoving:Connect(function(player)
	if playerCoins[player.UserId] then
		saveCoins(player, playerCoins[player.UserId].Value)
		playerCoins[player.UserId] = nil
	end
end)

local function setupCoin(coinRoot)
	local debounce = false

	local function onTouch(hit)
		if debounce then return end

		local character = hit.Parent
		local player = Players:GetPlayerFromCharacter(character)
		if not player then return end

		local coinsValue = playerCoins[player.UserId]
		if not coinsValue then return end

		local coinName
		if coinRoot:IsA("Model") then
			coinName = coinRoot.Name
		else
			coinName = coinRoot.Name
		end

		local valueToAdd = coinValues[coinName]
		if not valueToAdd then return end

		debounce = true
		coinsValue.Value = coinsValue.Value + valueToAdd

		if coinRoot:IsA("Model") then
			for _, part in ipairs(coinRoot:GetDescendants()) do
				if part:IsA("BasePart") then
					part.Transparency = 1
					part.CanCollide = false
				end
			end
		else
			if coinRoot:IsA("BasePart") then
				coinRoot.Transparency = 1
				coinRoot.CanCollide = false
			end
		end

		task.delay(respawnTime, function()
			if coinRoot:IsA("Model") then
				for _, part in ipairs(coinRoot:GetDescendants()) do
					if part:IsA("BasePart") then
						part.Transparency = 0
						part.CanCollide = true
					end
				end
			else
				if coinRoot:IsA("BasePart") then
					coinRoot.Transparency = 0
					coinRoot.CanCollide = true
				end
			end
			debounce = false
		end)
	end

	local parts = {}
	if coinRoot:IsA("Model") then
		parts = coinRoot:GetDescendants()
	else
		parts = {coinRoot}
	end

	for _, part in ipairs(parts) do
		if part:IsA("BasePart") then
			part.Touched:Connect(onTouch)
		end
	end
end

for _, item in ipairs(coinFolder:GetChildren()) do
	if item:IsA("Model") or item:IsA("BasePart") then
		setupCoin(item)
	end
end
