local Rayfield = loadstring(game:HttpGet('https://sirius.menu/rayfield'))()

local Window = Rayfield:CreateWindow({
	Name = "Death Note :)",
	LoadingTitle = "Rayfield Interface Suite",
	LoadingSubtitle = "by Sirius",
	ConfigurationSaving = {
		Enabled = true,
		FolderName = nil, -- Create a custom folder for your hub/game
		FileName = "Big Hub"
	},
	Discord = {
		Enabled = false,
		Invite = "noinvitelink", -- The Discord invite code, do not include discord.gg/. E.g. discord.gg/ABCD would be ABCD
		RememberJoins = true -- Set this to false to make them join the discord every time they load it up
	},
	KeySystem = false, -- Set this to true to use our key system
	KeySettings = {
		Title = "Untitled",
		Subtitle = "Key System",
		Note = "No method of obtaining the key is provided",
		FileName = "Key", -- It is recommended to use something unique as other scripts using Rayfield may overwrite your key file
		SaveKey = true, -- The user's key will be saved, but if you change the key, they will be unable to use your script
		GrabKeyFromSite = false, -- If this is true, set Key below to the RAW site you would like Rayfield to get the key from
		Key = {"Hello"} -- List of keys that will be accepted by the system, can be RAW file links (pastebin, github etc) or simple strings ("hello","key22")
	}
})

local function VNT()
	-- The function that takes place when the button is pressed
	local place = workspace

	local Players = game:GetService("Players")
	local player = Players.LocalPlayer
	local character = player.Character

	local function playerCloseToPart(part: Part, size: number)
		-- returns a table of players close to the part by size radius
		local closePlayers = {}
		for _, otherPlayer in ipairs(Players:GetPlayers()) do
			local otherCharacter = otherPlayer.Character
			if not otherCharacter then continue end
			local otherRoot = otherCharacter:FindFirstChild("HumanoidRootPart")
			if not otherRoot then continue end
			local distance = (otherRoot.Position - part.Position).Magnitude
			if distance <= size then
				table.insert(closePlayers, otherPlayer)
			end
		end
		return closePlayers
	end

	local function printTablePlayerNames(list, victimName)
		for _, p in ipairs(list) do
			warn(p.DisplayName .. " was close to picked up ID of: " .. victimName)
		end
	end

	local function EspId()
		for _, v in ipairs(place:GetDescendants()) do
			if not v:IsA("SurfaceGui") then continue end
			if not v.Enabled then continue end
			local part = v.Parent
			local box = part:FindFirstChildWhichIsA("SelectionBox")
			if box then
				box:Destroy()
			end

			local frame = v:FindFirstChildWhichIsA("Frame")
			if not frame then continue end

			local nameLabel = frame:FindFirstChild("PlayerName")
			if not nameLabel then continue end
			if not nameLabel:IsA("TextLabel") then continue end

			local prompt = part:FindFirstChildWhichIsA("ProximityPrompt")

			if not prompt then
				continue
			end

			local assignedName = nameLabel.Text

			local ESP = part:FindFirstChild("ESP")

			if ESP then
				ESP:Destroy()
			end

			local ESP = Instance.new("BillboardGui", part)
			ESP.Name = "ESP"
			ESP.Adornee = part
			ESP.Size = UDim2.new(2,0,1,0)
			ESP.AlwaysOnTop = true
			ESP.MaxDistance = math.huge

			local frame = Instance.new("Frame", ESP)
			frame.Size = UDim2.new(1, 0, 1, 0)
			frame.BackgroundTransparency = 1

			local textLabel = Instance.new("TextLabel", frame)
			textLabel.Size = UDim2.new(1, 0, 1, 0)
			textLabel.Text = assignedName

			textLabel.BackgroundColor3 = Color3.new(0, 1, 0)
			if assignedName == player.Name or assignedName == player.DisplayName then
				textLabel.BackgroundColor3 = Color3.new(1, 0, 0)
			end

			prompt.Triggered:Connect(function(plyr: Player)
				Rayfield:Notify({
					Title = "Death Note User",
					Content = assignedName .. " ID has been taken!",
					Duration = 120,
					Image = 4483362458,
					Actions = { -- Notification Buttons
						Ignore = {
							Name = "I understand!",
							Callback = function()
								printTablePlayerNames(playerCloseToPart(part, 5), assignedName)
							end
						},
					},
				})
			end)

			v:GetPropertyChangedSignal("Enabled"):Connect(function(...: any) 
				if not v.Enabled then
					-- printTablePlayerNames(playerCloseToPart(part, 5), assignedName)
					ESP:Destroy()
				end
			end)
		end
	end


	EspId()
end


local function DNC()
	-- The function that takes place when the button is pressed

	local Players = game:GetService("Players")

	for _, v in ipairs(Players:GetPlayers()) do
		local char = v.Character
		local signal = char.ChildAdded:Connect(function(child: Instance)
			if child.Name == "DeathNoteBook" then
				Rayfield:Notify({
					Title = "Death Note User",
					Content = v.DisplayName .. " revealed the death note book!",
					Duration = 120,
					Image = 4483362458,
					Actions = { -- Notification Buttons
						Ignore = {
							Name = "I understand!",
							Callback = function()
								print("The user tapped Okay!")
							end
						},
					},
				})
				warn(v.DisplayName .. " revealed the death note book!")
			end
		end)

		char:FindFirstChildOfClass("Humanoid").Died:Connect(function()
			signal:Disconnect()
		end)
	end
end

local function PB()
	local map = game.Workspace:FindFirstChild("Map", true)
	for _, descendant in pairs(map:GetDescendants()) do
		if descendant:IsA("ProximityPrompt") then
			descendant.HoldDuration = 0
		end
	end
end


local delayer = false
local function tpD()
	-- disabled for now
	return
end

local function MDA()
	local map = game.Workspace:FindFirstChild("Map", true)
	for _, descendant in pairs(map:GetDescendants()) do
		if descendant:IsA("ProximityPrompt") then
			descendant.MaxActivationDistance = 100
			descendant.RequiresLineOfSight = false
		end
	end
end

local isViewingDN = false
local dnClone = nil
local function VDN()
	if isViewingDN and dnClone  then
		isViewingDN = false
		dnClone:Destroy()
		return
	end
	isViewingDN = true
	local player = game.Players.LocalPlayer
	local playergui = player.PlayerGui

	local rs = game.ReplicatedStorage
	local assets = rs.Assets
	local UI = assets.UI
	local DeathNote = UI:FindFirstChild("DeathNote")
	if not DeathNote then
		warn("DN not found")
		return
	end
	dnClone = DeathNote:Clone()

	local frame = dnClone:FindFirstChildWhichIsA("Frame")
	if not frame then
		warn("Frame not found")
		return
	end
	dnClone.Enabled = true
	dnClone.Parent = playergui
	local localScript = frame:FindFirstChildWhichIsA("LocalScript")
	if not localScript then
		warn("LocalScript not found")
		return
	end
	localScript.Enabled = true
end

local function isIn(instance: Instance, item)
	for _, v in ipairs(instance:GetChildren()) do
		if v.Name == item then
			return true
		end
	end
	return false
end

local function LG()
	local rs = game.ReplicatedStorage
	local temp = rs:FindFirstChild("Game")
	if not temp then
		return
	end

	local FolderForNames = temp:FindFirstChild("VoteoutFolder")
	if not FolderForNames then
		return
	end

	local Players = game.Players

	for _, v in ipairs(Players:GetPlayers()) do
		local name = v.Name
		local included = isIn(FolderForNames, name)

		local char = v.Character
		if not char then
			return
		end

		local humanoid = char:FindFirstChildWhichIsA("Humanoid")
		if not humanoid then
			return
		end

		local isSitting = humanoid.Sit

		if not isSitting then
			continue
		end

		if included then
			continue
		end

		Rayfield:Notify({
			Title = "They are it",
			Content = v.DisplayName .. " <".. v.Name .. "> is one of them",
			Duration = 20,
			Image = 4483362458,
			Actions = { -- Notification Buttons
				Ignore = {
					Name = "I understand!",
					Callback = function()
						print("The user tapped Okay!")
					end
				},
			},
		})
	end
end

local function max(a)
	-- returns the max value in table a
	local max = 0
	for _, v in ipairs(a) do
		if v > max then
			max = v
		end
	end
	return max
end

local function getHighestValues(list: {})
	-- returns a table consisting of names with the highest count
	local highVal = max(list)
	local res = {}
	for name, value in pairs(list) do
		if value == highVal then
			res[name] = value
		end
	end
	return res	
end


local function voteNotify()
	local rs = game.ReplicatedStorage
	local temp = rs:FindFirstChild("Game")
	if not temp then
		return
	end

	local FolderForNames = temp:FindFirstChild("VoteoutFolder")
	if not FolderForNames then
		return
	end

	FolderForNames.Destroying:Connect(function()
		local list = {}
		local Players = game:GetService("Players")

		for _, v in ipairs(FolderForNames:GetChildren()) do		
			local success, plr = pcall(function()
				return Players:GetPlayerByUserId(Players:GetUserIdFromNameAsync(v.Name))
			end)

			if not success then
				continue
			end

			if not v:IsA("IntValue") then
				continue
			end

			local voteCount = v.Value
			list[plr.DisplayName] = voteCount
		end
		local highCounts = getHighestValues(list)

		for key, val in pairs(highCounts) do
			Rayfield:Notify({
				Title = "Voted Out",
				Content = key .. " has been voted out with " .. val .. " votes",
				Duration = 20,
				Image = 4483362458,
				Actions = { -- Notification Buttons
					Ignore = {
						Name = "I understand!",
						Callback = function()
							print("The user tapped Okay!")
						end
					},
				},
			})
		end
	end)
end


-- User Interface Handler
local Initiate = Window:CreateTab("Initiate Game", 4483362458) -- Title, Image

Initiate:CreateSection("Disable Proximity Prompts")
local ProxButton = Initiate:CreateButton({
	Name = "Disable",
	Callback = function()
		PB()
	end,
})

Initiate:CreateSection("Teleport to Deathnote Crates")
local teleportToDeathnote = Initiate:CreateButton({
	Name = "Teleport",
	Callback = function()
		tpD()
	end,
})

print("Created ui handlers")



-- Kira tool set
local Kira = Window:CreateTab("Kira Game", 4483362458) -- Title, Image

Kira:CreateSection("View Nametags")
-- Innocent, kira VNT
local NametagButton = Kira:CreateButton({
	Name = "View",
	Callback = function()
		VNT()
	end
})

Kira:CreateSection("Disable Proximity Prompts")
local ProxButton = Kira:CreateButton({
	Name = "Disable",
	Callback = function()
		PB()
	end,
})

Kira:CreateSection("Max Distance Activation")
local ExpButton = Kira:CreateButton({
	Name = "Activate",
	Callback = function()
		MDA()
	end,
})


-- kira VDN
Kira:CreateSection("View Death Note UI")
local ViewDeathNoteUI = Kira:CreateButton({
	Name = "View",
	Callback = function()
		VDN()
	end,
})

print("created kira toolkit")



-- Innocents
local Inno = Window:CreateTab("Innocent Game", 4483362458) -- Title, Image

Inno:CreateSection("View Nametags")
-- Innocent, kira VNT
local NametagButton = Inno:CreateButton({
	Name = "View",
	Callback = function()
		VNT()
	end
})

-- innocent DNC
Inno:CreateSection("Deathnote User Notifier")
local DeathNoteCaller = Inno:CreateButton({
	Name = "Notify",
	Callback = function()
		DNC()
	end,
})

print("created inno toolkit")



-- L LG
local L = Window:CreateTab("L <Ryuzaki> Game", 4483362458) -- Title, Image
L:CreateSection("Role Notifier")
local LGame = L:CreateButton({
	Name = "View",
	Callback = function()
		LG()
	end,
})

L:CreateSection("Notify who is getting voted")
local voteOut = L:CreateButton({
	Name = "Notify",
	Callback = function() 
		voteNotify()
	end,
})

local UserInputService = game:GetService("UserInputService")

UserInputService.InputBegan:Connect(function(input, processed)
	if processed then return end  -- ignore if typing in chat or textbox

	if input.KeyCode == Enum.KeyCode.B then
		print("You pressed B")
		-- your code here
		VDN()
	end
end)

print("created L toolkit")

local gamefolder = game.ReplicatedStorage.Game
local votes = {}

local function FormatUserTable(data)
	local lines = {}
	table.insert(lines, string.format("%-20s | %s", "Username", "Value"))
	table.insert(lines, string.rep("-", 30))

	for username, value in data do
		local displayName = game.Players:GetPlayerByUserId(game.Players:GetUserIdFromNameAsync(username.Name))
		table.insert(lines, string.format("%-20s [%-20s] | %s", displayName, username, tostring(value)))
	end

	return table.concat(lines, "\n")
end

local VoteoutsTab = Window:CreateTab("Voteouts")
local Paragraph = VoteoutsTab:CreateParagraph({Title = "Voteouts", Content = "Message here"})

local function updatevotes()
	local formatted = FormatUserTable(votes)
	Paragraph:Set({Title = "Voteouts", Content = formatted})
end

gamefolder.ChildAdded:Connect(function(child)
	votes = {}
	if child.Name == "VoteoutFolder" and child:IsA("Folder") then
		for _, v in pairs(child:GetChildren()) do
			local username = v
			print("user added")
			if username:IsA("IntValue") then
				votes[username.Name] = username.Value
				username:GetPropertyChangedSignal("Value"):Connect(function()
					votes[username.Name] = username.Value
					updatevotes()
				end)
				updatevotes()
			end
		end
		child.ChildAdded:Connect(function(username)
			print("user added")
			if username:IsA("IntValue") then
				votes[username.Name] = username.Value
				username:GetPropertyChangedSignal("Value"):Connect(function()
					votes[username.Name] = username.Value
					updatevotes()
				end)
				updatevotes()
			end
		end)
	end
end)

gamefolder.ChildRemoved:Connect(function(child)
	if child.Name == "VoteoutFolder" and child:IsA("Folder") then
		votes = {}
		updatevotes()
	end
end)
print("created voteouts toolkit")
