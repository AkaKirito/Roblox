local Rayfield = loadstring(game:HttpGet('https://sirius.menu/rayfield'))()
local gamefolder = game.ReplicatedStorage.Game

local Window = Rayfield:CreateWindow({
	Name = "Death Note :)",
	LoadingTitle = "Rayfield Interface Suite",
	LoadingSubtitle = "by Sirius",
	ConfigurationSaving = {
		Enabled = true,
		FolderName = nil,
		FileName = "Big Hub"
	},
	Discord = {
		Enabled = false,
		Invite = "noinvitelink",
		RememberJoins = true
	},
	KeySystem = false,
	KeySettings = {
		Title = "Untitled",
		Subtitle = "Key System",
		Note = "No method of obtaining the key is provided",
		FileName = "Key",
		SaveKey = true,
		GrabKeyFromSite = false,
		Key = {"Hello"}
	}
})

local function VNT()
	local place = workspace
	local Players = game:GetService("Players")
	local player = Players.LocalPlayer
	local character = player.Character

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
			if not prompt then continue end

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

			v:GetPropertyChangedSignal("Enabled"):Connect(function(...: any)
				if not v.Enabled then
					ESP:Destroy()
				end
			end)
		end
	end

	EspId()
end

local confirmedKiras = {}

local function DNC()
	local Players = game:GetService("Players")

	for _, v in ipairs(Players:GetPlayers()) do
		local char = v.Character
		local signal = char.ChildAdded:Connect(function(child: Instance)
			if child.Name == "DeathNoteBook" then
				if not table.find(confirmedKiras, v.DisplayName) then
					table.insert(confirmedKiras, v.DisplayName)
				end

				inno_kiraParagraph:Set({
					Title = "Kiras found",
					Content = table.concat(confirmedKiras, ", ")
				})

				Rayfield:Notify({
					Title = "Death Note User",
					Content = v.DisplayName .. " revealed the death note book!",
					Duration = 120,
					Image = 4483362458,
					Actions = {
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
	if isViewingDN and dnClone then
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

local roles = {}

local function LG()
	local rs = game.ReplicatedStorage
	local gameFolder = rs:FindFirstChild("Game")
	if not gameFolder then return end

	local FolderForNames = gameFolder:FindFirstChild("VoteoutFolder")
	if not FolderForNames then return end

	local Players = game.Players
	local temp = {}

	for _, v in ipairs(Players:GetPlayers()) do
		local name = v.Name
		local included = isIn(FolderForNames, name)
		if included then continue end

		local char = v.Character
		if not char then continue end

		local humanoid = char:FindFirstChildWhichIsA("Humanoid")
		if not humanoid then continue end

		local isSitting = humanoid.Sit
		if not isSitting then continue end

		table.insert(temp, v)
	end

	local roleName = gameFolder.GamePhase and gameFolder.GamePhase.Value or "Unknown"
	roles[roleName] = temp
end

local function max(a)
	local max = 0
	for _, v in ipairs(a) do
		if v > max then
			max = v
		end
	end
	return max
end

local function getHighestValues(list: {})
	local highVal = max(list)
	local res = {}
	for name, value in pairs(list) do
		if value == highVal then
			res[name] = value
		end
	end
	return res
end

-- Kira tool set
local Kira = Window:CreateTab("Kira Game", 4483362458)

Kira:CreateSection("Max Distance Activation")
local ExpButton = Kira:CreateButton({
	Name = "Activate",
	Callback = function()
		MDA()
	end,
})

Kira:CreateSection("View Death Note UI")
local ViewDeathNoteUI = Kira:CreateButton({
	Name = "View",
	Callback = function()
		VDN()
	end,
})

print("created kira toolkit")

-- Innocents
local Inno = Window:CreateTab("Innocent Game", 4483362458)

Inno:CreateSection("Deathnote User Notifier")
local DeathNoteCaller = Inno:CreateButton({
	Name = "Notify",
	Callback = function()
		DNC()
	end,
})

local inno_kiraParagraph = Inno:CreateParagraph({Title = "Kiras found", Content = "None yet"})

print("created inno toolkit")

-- L tab
local L = Window:CreateTab("L <Ryuzaki> Game", 4483362458)
L:CreateSection("Role Notifier")

local KiraParagraph = L:CreateParagraph({Title = "Kiras", Content = "Unknown"})
local MelloParagraph = L:CreateParagraph({Title = "Mello", Content = "Unknown"})
local RyuzakiParagraph = L:CreateParagraph({Title = "L", Content = "Unknown"})
local GelusParagraph = L:CreateParagraph({Title = "Gelus", Content = "Unknown"})

local function printablePlayerDisplayNames(playerList: {})
	local names = {}
	for _, player in ipairs(playerList) do
		table.insert(names, player.DisplayName)
	end
	return table.concat(names, ", ")
end

local function clearContents()
	KiraParagraph:Set({Title = "Kiras", Content = "Unknown"})
	MelloParagraph:Set({Title = "Mello", Content = "Unknown"})
	RyuzakiParagraph:Set({Title = "L", Content = "Unknown"})
	GelusParagraph:Set({Title = "Gelus", Content = "Unknown"})
end

gamefolder.GamePhase.Changed:Connect(function()
	LG()
	local roleName = gamefolder.GamePhase.Value
	local players = roles[roleName]

	if roleName == "KiraTurn" and players then
		KiraParagraph:Set({Title = "Kiras", Content = "Kira: " .. printablePlayerDisplayNames(players)})
	end
	if roleName == "MelloTurn" and players then
		MelloParagraph:Set({Title = "Mello", Content = "Mello: " .. printablePlayerDisplayNames(players)})
	end
	if roleName == "LTurn" and players then
		RyuzakiParagraph:Set({Title = "L", Content = "L: " .. printablePlayerDisplayNames(players)})
	end
	if roleName == "GelusTurn" and players then
		GelusParagraph:Set({Title = "Gelus", Content = "Gelus: " .. printablePlayerDisplayNames(players)})
	end

	if roleName == "IdScatter" then
		task.delay(8, function()
			VNT()
			PB()
			MDA()
		end)
	elseif roleName == "Intermission" then
		roles = {}
		confirmedKiras = {}
		inno_kiraParagraph:Set({Title = "Kiras found", Content = "None yet"})
		clearContents()
	end
end)

local UserInputService = game:GetService("UserInputService")

UserInputService.InputBegan:Connect(function(input, processed)
	if processed then return end
	if input.KeyCode == Enum.KeyCode.B then
		print("You pressed B")
		VDN()
	end
end)

print("created L toolkit")

local votes = {}

local function getDisplayNameFromUserName(userName: string)
	for _, player in ipairs(game.Players:GetPlayers()) do
		if player.Name == userName then
			return player.DisplayName
		end
	end
end

local function FormatUserTable(data)
	local lines = {}
	table.insert(lines, string.format("%s | %s | %s", "Name", "Username", "Value"))
	table.insert(lines, string.rep("-", 30))

	for username, value in data do
		username = tostring(username)
		local displayName = getDisplayNameFromUserName(username)
		if displayName then
			table.insert(lines, string.format("%s [%s] | %s", displayName, username, tostring(value)))
		else
			table.insert(lines, string.format("%s | %s", username, tostring(value)))
		end
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
			if v:IsA("IntValue") then
				votes[v.Name] = v.Value
				v:GetPropertyChangedSignal("Value"):Connect(function()
					votes[v.Name] = v.Value
					updatevotes()
				end)
				updatevotes()
			end
		end
		child.ChildAdded:Connect(function(v)
			if v:IsA("IntValue") then
				votes[v.Name] = v.Value
				v:GetPropertyChangedSignal("Value"):Connect(function()
					votes[v.Name] = v.Value
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
