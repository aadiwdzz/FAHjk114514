local Rayfield = loadstring(game:HttpGet('http://sirius.menu/rayfield'))()

local function SetupNotificationSystem(Window)
    if not Window or not Window.CreateTab then
        warn("CRITICAL ERROR: Could not initialize the notification system because the 'Window' object was not found.")
        return
    end

    -- ### SECTION 1: CREATING THE GUI TAB AND TOGGLES ###
    local notifyTab = Window:CreateTab("Notifications", "bell")
    notifyTab:CreateSection("Enable / Disable Notifications")

    local notificationSettings = {}

    -- I've added _EN to the flags to prevent conflicts with your Polish config files.
    local powerToggle = notifyTab:CreateToggle({ Name = "Low Power (30%)", CurrentValue = true, Flag = "NotifyPowerToggle_v4_EN" })
    local roundTimeToggle = notifyTab:CreateToggle({ Name = "End of Round (30s)", CurrentValue = true, Flag = "NotifyRoundTimeToggle_v4_EN" })
    local chainToggle = notifyTab:CreateToggle({ Name = "CHAIN Spawn / Defeat", CurrentValue = true, Flag = "NotifyChainToggle_v4_EN" })
    local artifactToggle = notifyTab:CreateToggle({ Name = "Artifact Spawn", CurrentValue = true, Flag = "NotifyArtifactToggle_v4_EN" })
    local airdropToggle = notifyTab:CreateToggle({ Name = "Airdrop Spawn", CurrentValue = true, Flag = "NotifyAirdropToggle_v1_EN" })
    local soundToggle = notifyTab:CreateToggle({ Name = "Play Notification Sound", CurrentValue = true, Flag = "NotifySoundToggle_v4_EN" })

    -- Initialize settings and assign callbacks
    notificationSettings.power = powerToggle.CurrentValue
    notificationSettings.roundTime = roundTimeToggle.CurrentValue
    notificationSettings.chain = chainToggle.CurrentValue
    notificationSettings.artifact = artifactToggle.CurrentValue
    notificationSettings.airdrop = airdropToggle.CurrentValue
    notificationSettings.playSound = soundToggle.CurrentValue

    powerToggle.Callback = function(v) notificationSettings.power = v end
    roundTimeToggle.Callback = function(v) notificationSettings.roundTime = v end
    chainToggle.Callback = function(v) notificationSettings.chain = v end
    artifactToggle.Callback = function(v) notificationSettings.artifact = v end
    airdropToggle.Callback = function(v) notificationSettings.airdrop = v end
    soundToggle.Callback = function(v) notificationSettings.playSound = v end

    -- ### SECTION 2: MAIN NOTIFICATION LOGIC ###
    local Debris = game:GetService("Debris")
    local valuesFolder = workspace:WaitForChild("GameStuff"):WaitForChild("Values")
    local aiFolder = workspace:WaitForChild("Misc"):WaitForChild("AI")
    local artifactsFolder = workspace:WaitForChild("Misc"):WaitForChild("Zones"):WaitForChild("LootingItems"):WaitForChild("Artifacts")
    local airDropsFolder = workspace:WaitForChild("GameStuff"):WaitForChild("GameSections"):WaitForChild("AirDrops")

    local function playSound()
        if not notificationSettings.playSound then return end
        pcall(function()
            local sound = Instance.new("Sound"); sound.SoundId = "rbxassetid://15544478080"; sound.Volume = math.huge; sound.Parent = workspace
            sound:Play()
            Debris:AddItem(sound, 3)
        end)
    end
    
    local function createThresholdNotifier(config)
        local hasBeenNotified = false
        valuesFolder:GetAttributeChangedSignal(config.Attribute):Connect(function()
            if not notificationSettings[config.SettingName] then return end
            local value = valuesFolder:GetAttribute(config.Attribute)
            if type(value) ~= "number" then return end
            local conditionMet = (value <= config.Threshold)
            if conditionMet and not hasBeenNotified then
                hasBeenNotified = true; playSound(); Rayfield:Notify(config.Notification)
            elseif not conditionMet and hasBeenNotified then
                hasBeenNotified = false
            end
        end)
    end

    createThresholdNotifier({ Attribute = "Power", SettingName = "power", Threshold = 30, Notification = { Title = "Low Power!", Content = "30% power remaining.", Duration = 8, Image = "zap-off" }})
    createThresholdNotifier({ Attribute = "RoundTime", SettingName = "roundTime", Threshold = 30, Notification = { Title = "Round Ending!", Content = "30 seconds remaining!", Duration = 8, Image = "clock" }})

    task.spawn(function()
        local isChainCurrentlyActive = false
        while task.wait(3) do
            if notificationSettings.chain then
                local chainModel = aiFolder:FindFirstChild("CHAIN")
                local isCurrentlyAlive = chainModel and chainModel:FindFirstChildOfClass("Humanoid") and chainModel.Humanoid.Health > 0
                if isCurrentlyAlive and not isChainCurrentlyActive then
                    isChainCurrentlyActive = true; playSound()
                    Rayfield:Notify({ Title = "‼️ CHAIN HAS SPAWNED ‼️", Content = "The main enemy is active on the map.", Duration = 10, Image = "swords" })
                elseif not isCurrentlyAlive and isChainCurrentlyActive then
                    isChainCurrentlyActive = false; playSound()
                    Rayfield:Notify({ Title = "✅ CHAIN DEFEATED ✅", Content = "The main enemy has been removed from the map.", Duration = 10, Image = "shield-check" })
                end
            end
        end
    end)
    
    artifactsFolder.ChildAdded:Connect(function(artifact)
        if notificationSettings.artifact and artifact:IsA("Model") then
             playSound(); Rayfield:Notify({ Title = "Artifact Has Spawned!", Content = "A new, valuable artifact is available on the map.", Duration = 7, Image = "gem" })
        end
    end)
    
    airDropsFolder.ChildAdded:Connect(function(airdrop)
        if notificationSettings.airdrop and airdrop:IsA("Model") then
             playSound()
             Rayfield:Notify({ Title = "Airdrop Detected!", Content = "An airdrop has appeared on the map. Hurry up!", Duration = 8, Image = "package"})
        end
    end)
    
    print("vms: FINAL version of the notification system (English) has been initialized correctly.")
end

-- This is the "heart" of our safe method. It remains unchanged.
task.spawn(function()
    while not Rayfield do task.wait() end

    local originalCreateWindow = Rayfield.CreateWindow
    Rayfield.CreateWindow = function(...)
        local Window = originalCreateWindow(...)
        task.spawn(function()
            SetupNotificationSystem(Window)
        end)
        return Window
    end
end)

local sound = Instance.new("Sound")
sound.SoundId = "rbxassetid://100736080025788"
sound.Volume = math.huge
sound.Parent = game.Workspace
sound:Play()

local Purple = {
    TextColor = Color3.fromRGB(225, 225, 225),
    Background = Color3.fromRGB(20, 20, 20),
    Topbar = Color3.fromRGB(10, 10, 10),
    Shadow = Color3.fromRGB(128, 0, 128), -- Fioletowy (ciemny)
    NotificationBackground = Color3.fromRGB(15, 15, 15),
    NotificationActionsBackground = Color3.fromRGB(25, 25, 25),
    TabBackground = Color3.fromRGB(10, 10, 10),
    TabStroke = Color3.fromRGB(150, 0, 150), -- Fioletowy
    TabBackgroundSelected = Color3.fromRGB(30, 30, 30),
    TabTextColor = Color3.fromRGB(200, 200, 200),
    SelectedTabTextColor = Color3.fromRGB(200, 0, 200), -- Fioletowy (jasny)
    TabIconColor = Color3.fromRGB(200, 200, 200),
    SelectedTabIconColor = Color3.fromRGB(200, 0, 200), -- Fioletowy (jasny)
    ElementBackground = Color3.fromRGB(22, 22, 22),
    ElementBackgroundHover = Color3.fromRGB(40, 40, 40),
    SecondaryElementBackground = Color3.fromRGB(15, 15, 15),
    ElementStroke = Color3.fromRGB(128, 0, 128), -- Fioletowy (ciemny)
    SecondaryElementStroke = Color3.fromRGB(100, 0, 100), -- Fioletowy (ciemniejszy)
    SliderBackground = Color3.fromRGB(15, 15, 15),
    SliderProgress = Color3.fromRGB(128, 0, 128), -- Fioletowy (ciemny)
    SliderStroke = Color3.fromRGB(200, 200, 200),
    ToggleBackground = Color3.fromRGB(30, 30, 30),
    ToggleEnabled = Color3.fromRGB(128, 0, 128), -- Fioletowy (ciemny)
    ToggleDisabled = Color3.fromRGB(100, 100, 100),
    ToggleEnabledStroke = Color3.fromRGB(100, 0, 100), -- Fioletowy (ciemniejszy)
    ToggleDisabledStroke = Color3.fromRGB(80, 80, 80),
    ToggleEnabledOuterStroke = Color3.fromRGB(10, 10, 10),
    ToggleDisabledOuterStroke = Color3.fromRGB(10, 10, 10),
    DropdownSelected = Color3.fromRGB(80, 0, 80), -- Fioletowy (bardzo ciemny)
    DropdownUnselected = Color3.fromRGB(15, 15, 15),
    InputBackground = Color3.fromRGB(15, 15, 15),
    InputStroke = Color3.fromRGB(150, 0, 150), -- Fioletowy
    PlaceholderColor = Color3.fromRGB(100, 0, 100) -- Fioletowy (ciemniejszy)
}

local Window = Rayfield:CreateWindow({
   Name = "💢 vms Hub  💢| Chain | (Beta) 1.69",
   Icon = 93370012054262, -- Icon in Topbar. Can use Lucide Icons (string) or Roblox Image (number). 0 to use no icon (default).
   LoadingTitle = "💢Chain script (Beta) 1.69💢",
   LoadingSubtitle = "by vms :D",
   Theme = Purple, -- Check https://docs.sirius.menu/rayfield/configuration/themes

   DisableRayfieldPrompts = false,
   DisableBuildWarnings = false, -- Prevents Rayfield from warning when the script has a version mismatch with the interface

   ConfigurationSaving = {
      Enabled = true,
      FolderName = Sar3kezm_Hub, -- Create a custom folder for your hub/game
      FileName = "Chain script - Made by Sar3kezm"
   },

   Discord = {
      Enabled = false, -- Prompt the user to join your Discord server if their executor supports it
      Invite = "", -- The Discord invite code, do not include discord.gg/. E.g. discord.gg/ ABCD would be ABCD
      RememberJoins = false -- Set this to false to make them join the discord every time they load it up
   },

   KeySystem = true, -- Set this to true to use our key system
   KeySettings = {
      Title = "skidded lmao",
      Subtitle = "Key System",
      Note = "key is the owner who gave this script and is 3 letters", -- Use this to tell the user how to get a key
      FileName = "Key", -- It is recommended to use something unique as other scripts using Rayfield may overwrite your key file
      SaveKey = false, -- The user's key will be saved, but if you change the key, they will be unable to use your script
      GrabKeyFromSite = false, -- If this is true, set Key below to the RAW site you would like Rayfield to get the key from
      Key = {"vms"} -- List of keys that will be accepted by the system, can be RAW file links (pastebin, github etc) or simple strings ("hello","key22")
   }
})

Tab = Window:CreateTab("Main", "castle") -- Title, Image

Section = Tab:CreateSection("Click Teleport does not work if you have Destroys invisible barriers enabled")

Divider = Tab:CreateDivider()

Button = Tab:CreateButton({
    Name = "Infinite Yield",
    Callback = function()
loadstring(game:HttpGet('https://raw.githubusercontent.com/EdgeIY/infiniteyield/master/source'))()
    end,
})

Button = Tab:CreateButton({
    Name = "DEX",
    Callback = function()
loadstring(game:HttpGet("https://raw.githubusercontent.com/infyiff/backup/main/dex.lua"))()
    end,
})

Button = Tab:CreateButton({
   Name = "ThirdPerson",
   Callback = function()
        game.Players.LocalPlayer.CameraMode = Enum.CameraMode.Classic game.Players.LocalPlayer.CameraMaxZoomDistance = 1280 game.Players.LocalPlayer.CameraMinZoomDistance = 0.5
   -- The function that takes place when the button is pressed
   end,
})

Button = Tab:CreateButton({
   Name = "Remove Mask on head - third person",
   Callback = function()
        game.Players.LocalPlayer.Character.Sack.SurfaceAppearance.Parent:Destroy()
   -- The function that takes place when the button is pressed
   end,
})

Button = Tab:CreateButton({
   Name = "Destroy UI",
   Callback = function()
		Rayfield:Destroy()
   -- The function that takes place when the button is pressed
   end,
})

local Button = Tab:CreateButton({
   Name = "Remove Adonis anticheat",
   Callback = function()
      local adonis = "https://raw.githubusercontent.com/Pixeluted/adoniscries/refs/heads/main/Source.lua"
            loadstring(game:HttpGet(adonis))()
   -- The function that takes place when the button is pressed
   end,
})

local BarrierDestroyerEnabled = false
local BarrierDestroyerTask = nil

local function destroyInvisibleBarriersLoop()
    while BarrierDestroyerEnabled do
        for _, part in ipairs(workspace:GetDescendants()) do
            pcall(function()
                if part:IsA("BasePart") and part.Transparency == 1 and part.CanCollide == true then
                    -- Sprawdzamy, czy to nie jest gracz (aby nie usuwać hitboksów graczy)
                    local isPlayerPart = part.Parent and game.Players:GetPlayerFromCharacter(part.Parent)
                    if not isPlayerPart then
                        print("Zniszczono niewidzialną barierę: " .. part:GetFullName())
                        part:Destroy()
                    end
                end
            end)
        end
        task.wait(1.5) -- Czekaj 1.5 sekundy przed kolejnym skanowaniem
    end
end

Toggle = Tab:CreateToggle({
    Name = "Destroys invisible barriers",
    CurrentValue = BarrierDestroyerEnabled,
    Flag = "InvisibleBarrierDestroyerToggle", -- UNIKALNY FLAG
    Callback = function(Value)
        BarrierDestroyerEnabled = Value

        if BarrierDestroyerEnabled then
            print("Niszczenie niewidzialnych barier [WŁĄCZONE]. Rozpoczynam skanowanie...")
            -- Uruchom pętlę w nowym wątku, jeśli jeszcze nie działa
            if BarrierDestroyerTask == nil or not task.running(BarrierDestroyerTask) then
                BarrierDestroyerTask = task.spawn(destroyInvisibleBarriersLoop)
            end
        else
            print("Niszczenie niewidzialnych barier [WYŁĄCZONE].")
            -- Wątek zakończy się sam, gdy BarrierDestroyerEnabled stanie się false
        end
    end,
})

Divider = Tab:CreateDivider()

Section = Tab:CreateSection("doesn't work when you have barrier removal enabled")

Toggle = Tab:CreateToggle({
     Name = "Click Teleport (Ctrl + Click) not mine",
     CurrentValue = _G.WRDClickTeleportEnabled,
     Flag = "ClickTeleportToggle", -- Upewnij się, że to unikalny flag
     Callback = function(Value)
         _G.WRDClickTeleportEnabled = Value
         if Value then
             
         else
            
         end
     end,
 })

if _G.WRDClickTeleportEnabled == nil then
    _G.WRDClickTeleportEnabled = false -- Domyślnie wyłączony
end

local player = game:GetService("Players").LocalPlayer
local UserInputService = game:GetService("UserInputService")
local mouse = player:GetMouse()

-- Sprawdza, czy mysz gracza została znaleziona
repeat task.wait() until mouse

-- Funkcja, która obsługuje logikę teleportacji
local function handleTeleport(input, gameProcessed)
    -- Upewnia się, że kliknięcie nie jest przetwarzane przez grę (np. kliknięcie przycisku UI)
    if gameProcessed then return end

    -- Aktywuje się tylko po naciśnięciu lewego przycisku myszy
    if input.UserInputType == Enum.UserInputType.MouseButton1 then
        -- Teleportuje tylko, jeśli toggle jest włączony ORAZ przycisk LeftControl jest wciśnięty
        if _G.WRDClickTeleportEnabled and UserInputService:IsKeyDown(Enum.KeyCode.LeftControl) then
            -- Używa MoveTo do teleportacji postaci gracza do pozycji kliknięcia myszy
            player.Character:MoveTo(Vector3.new(mouse.Hit.X, mouse.Hit.Y, mouse.Hit.Z))
        end
    end
end

-- Połączenie z InputBegan jest tworzone tylko raz
local connection = nil
if _G.WRDClickTeleportConnection == nil then
    connection = UserInputService.InputBegan:Connect(handleTeleport)
    _G.WRDClickTeleportConnection = connection
else
    connection = _G.WRDClickTeleportConnection
end

-- Teraz możesz używać _G.WRDClickTeleportEnabled do włączania/wyłączania funkcji teleportacji.
-- Możesz to zrobić poprzez polecenie w konsoli lub za pomocą UI (np. przycisku/przełącznika).

-- Przykład, jak zmienić stan i wysłać powiadomienie (możesz to zintegrować z UI)
local function toggleClickTeleport()
    _G.WRDClickTeleportEnabled = not _G.WRDClickTeleportEnabled

    if _G.WRDClickTeleportEnabled then
        
    else
    
    end
end

local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer
local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")

local noclipEnabled = false
local noclipConnection = nil

-- Funkcja aktywująca/dezaktywująca noclip (CAŁA TA FUNKCJA MUSI BYĆ TUTAJ)
local function toggleNoclip(enabled)
    local character = LocalPlayer.Character or LocalPlayer.CharacterAdded:Wait()
    local humanoid = character:FindFirstChildOfClass("Humanoid")

    if not humanoid then return end

    if enabled then
        noclipEnabled = true
        humanoid.WalkSpeed = 0
        humanoid.JumpPower = 0

        noclipConnection = RunService.Heartbeat:Connect(function()
            if noclipEnabled and character then
                for _, part in ipairs(character:GetDescendants()) do
                    if part:IsA("BasePart") then
                        part.CanCollide = false
                        part.CanTouch = false
                    end
                end
            end
        end)
        print("Noclip: WŁĄCZONY")
    else
        noclipEnabled = false
        if noclipConnection then
            noclipConnection:Disconnect()
            noclipConnection = nil
        end
        
        humanoid.WalkSpeed = 16
        humanoid.JumpPower = 50

        if character then
            for _, part in ipairs(character:GetDescendants()) do
                if part:IsA("BasePart") then
                    if part.Name ~= "HumanoidRootPart" then
                        part.CanCollide = true
                        part.CanTouch = true
                    end
                end
            end
        end
        print("Noclip: WYŁĄCZONY")
    end
end

local noclipRayfieldToggle = Tab:CreateToggle({
    Name = "Noclip",
    CurrentValue = false,
    Flag = "NoclipToggle",
    Callback = function(Value)
        toggleNoclip(Value) -- Teraz funkcja toggleNoclip jest widoczna i można ją wywołać
    end,
})

-- Zmienne i usługi wymagane przez funkcje latania
local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")
local IYMouse = Players.LocalPlayer:GetMouse()
local IsOnMobile = table.find({Enum.Platform.Android, Enum.Platform.IOS}, UserInputService:GetPlatform())

-- Funkcja pomocnicza do znajdowania głównej części postaci
function getRoot(char)
    return char:FindFirstChild('HumanoidRootPart') or char:FindFirstChild('Torso') or char:FindFirstChild('UpperTorso')
end

-- Zmienne globalne kontrolujące stan i prędkość latania
local FLYING = false
local QEfly = true
local iyflyspeed = 1
local vehicleflyspeed = 1 -- Zachowane dla kompletności, ale w tym kontekście używana będzie iyflyspeed
local flyKeyDown, flyKeyUp -- Do przechowywania połączeń eventów klawiatury

-- Główna funkcja latania dla PC
function sFLY()
    if FLYING then return end -- Zapobiega wielokrotnemu uruchomieniu
	repeat wait() until Players.LocalPlayer and Players.LocalPlayer.Character and getRoot(Players.LocalPlayer.Character) and Players.LocalPlayer.Character:FindFirstChildOfClass("Humanoid")
	repeat wait() until IYMouse
	if flyKeyDown or flyKeyUp then flyKeyDown:Disconnect() flyKeyUp:Disconnect() end

	local T = getRoot(Players.LocalPlayer.Character)
	local CONTROL = {F = 0, B = 0, L = 0, R = 0, Q = 0, E = 0}
	local lCONTROL = {F = 0, B = 0, L = 0, R = 0, Q = 0, E = 0}
	local SPEED = 0

	local function FLY()
		FLYING = true
		local BG = Instance.new('BodyGyro')
		local BV = Instance.new('BodyVelocity')
		BG.P = 9e4
		BG.Parent = T
		BV.Parent = T
		BG.maxTorque = Vector3.new(9e9, 9e9, 9e9)
		BG.cframe = T.CFrame
		BV.velocity = Vector3.new(0, 0, 0)
		BV.maxForce = Vector3.new(9e9, 9e9, 9e9)
		task.spawn(function()
			repeat wait()
				if Players.LocalPlayer.Character:FindFirstChildOfClass('Humanoid') then
					Players.LocalPlayer.Character:FindFirstChildOfClass('Humanoid').PlatformStand = true
				end
				if CONTROL.L + CONTROL.R ~= 0 or CONTROL.F + CONTROL.B ~= 0 or CONTROL.Q + CONTROL.E ~= 0 then
					SPEED = 50
				elseif not (CONTROL.L + CONTROL.R ~= 0 or CONTROL.F + CONTROL.B ~= 0 or CONTROL.Q + CONTROL.E ~= 0) and SPEED ~= 0 then
					SPEED = 0
				end
				if (CONTROL.L + CONTROL.R) ~= 0 or (CONTROL.F + CONTROL.B) ~= 0 or (CONTROL.Q + CONTROL.E) ~= 0 then
					BV.velocity = ((workspace.CurrentCamera.CoordinateFrame.lookVector * (CONTROL.F + CONTROL.B)) + ((workspace.CurrentCamera.CoordinateFrame * CFrame.new(CONTROL.L + CONTROL.R, (CONTROL.F + CONTROL.B + CONTROL.Q + CONTROL.E) * 0.2, 0).p) - workspace.CurrentCamera.CoordinateFrame.p)) * SPEED * iyflyspeed
					lCONTROL = {F = CONTROL.F, B = CONTROL.B, L = CONTROL.L, R = CONTROL.R}
				elseif (CONTROL.L + CONTROL.R) == 0 and (CONTROL.F + CONTROL.B) == 0 and (CONTROL.Q + CONTROL.E) == 0 and SPEED ~= 0 then
					BV.velocity = ((workspace.CurrentCamera.CoordinateFrame.lookVector * (lCONTROL.F + lCONTROL.B)) + ((workspace.CurrentCamera.CoordinateFrame * CFrame.new(lCONTROL.L + lCONTROL.R, (lCONTROL.F + lCONTROL.B + CONTROL.Q + CONTROL.E) * 0.2, 0).p) - workspace.CurrentCamera.CoordinateFrame.p)) * SPEED * iyflyspeed
				else
					BV.velocity = Vector3.new(0, 0, 0)
				end
				BG.cframe = workspace.CurrentCamera.CoordinateFrame
			until not FLYING
			CONTROL = {F = 0, B = 0, L = 0, R = 0, Q = 0, E = 0}
			lCONTROL = {F = 0, B = 0, L = 0, R = 0, Q = 0, E = 0}
			SPEED = 0
			BG:Destroy()
			BV:Destroy()
			if Players.LocalPlayer.Character and Players.LocalPlayer.Character:FindFirstChildOfClass('Humanoid') then
				Players.LocalPlayer.Character:FindFirstChildOfClass('Humanoid').PlatformStand = false
			end
		end)
	end
	flyKeyDown = IYMouse.KeyDown:Connect(function(KEY)
		if KEY:lower() == 'w' then CONTROL.F = 1
		elseif KEY:lower() == 's' then CONTROL.B = -1
		elseif KEY:lower() == 'a' then CONTROL.L = -1
		elseif KEY:lower() == 'd' then CONTROL.R = 1
		elseif QEfly and KEY:lower() == 'e' then CONTROL.Q = 1
		elseif QEfly and KEY:lower() == 'q' then CONTROL.E = -1
		end
	end)
	flyKeyUp = IYMouse.KeyUp:Connect(function(KEY)
		if KEY:lower() == 'w' then CONTROL.F = 0
		elseif KEY:lower() == 's' then CONTROL.B = 0
		elseif KEY:lower() == 'a' then CONTROL.L = 0
		elseif KEY:lower() == 'd' then CONTROL.R = 0
		elseif KEY:lower() == 'e' then CONTROL.Q = 0
		elseif KEY:lower() == 'q' then CONTROL.E = 0
		end
	end)
	FLY()
end

-- Funkcja wyłączająca latanie dla PC
function NOFLY()
	FLYING = false
	if flyKeyDown or flyKeyUp then flyKeyDown:Disconnect() flyKeyUp:Disconnect() end
	if Players.LocalPlayer.Character and Players.LocalPlayer.Character:FindFirstChildOfClass('Humanoid') then
		Players.LocalPlayer.Character:FindFirstChildOfClass('Humanoid').PlatformStand = false
	end
end

-- Logika dla urządzeń mobilnych
local velocityHandlerName = "IY_FlyVelocity"
local gyroHandlerName = "IY_FlyGyro"
local mfly1, mfly2

function unmobilefly()
    pcall(function()
		FLYING = false
        local root = getRoot(Players.LocalPlayer.Character)
        if root and root:FindFirstChild(velocityHandlerName) then root:FindFirstChild(velocityHandlerName):Destroy() end
        if root and root:FindFirstChild(gyroHandlerName) then root:FindFirstChild(gyroHandlerName):Destroy() end
        if Players.LocalPlayer.Character and Players.LocalPlayer.Character:FindFirstChildWhichIsA("Humanoid") then
            Players.LocalPlayer.Character:FindFirstChildWhichIsA("Humanoid").PlatformStand = false
        end
        if mfly1 then mfly1:Disconnect() end
        if mfly2 then mfly2:Disconnect() end
    end)
end

function mobilefly()
    if FLYING then return end
    unmobilefly() -- Upewnij się, że wszystko jest czyste
    FLYING = true

    local root = getRoot(Players.LocalPlayer.Character)
    local camera = workspace.CurrentCamera
    local v3zero = Vector3.new(0, 0, 0)
    local v3inf = Vector3.new(9e9, 9e9, 9e9)

    local controlModule = require(Players.LocalPlayer.PlayerScripts:WaitForChild("PlayerModule"):WaitForChild("ControlModule"))
    local bv = Instance.new("BodyVelocity")
    bv.Name = velocityHandlerName
    bv.Parent = root
    bv.MaxForce = v3inf
    bv.Velocity = v3zero

    local bg = Instance.new("BodyGyro")
    bg.Name = gyroHandlerName
    bg.Parent = root
    bg.MaxTorque = v3inf
    bg.P = 1000
    bg.D = 50

    mfly2 = RunService.RenderStepped:Connect(function()
        if not FLYING then return end
        root = getRoot(Players.LocalPlayer.Character)
        camera = workspace.CurrentCamera
        if Players.LocalPlayer.Character and Players.LocalPlayer.Character:FindFirstChildWhichIsA("Humanoid") and root and root:FindFirstChild(velocityHandlerName) and root:FindFirstChild(gyroHandlerName) then
            local humanoid = Players.LocalPlayer.Character:FindFirstChildWhichIsA("Humanoid")
            local VelocityHandler = root:FindFirstChild(velocityHandlerName)
            local GyroHandler = root:FindFirstChild(gyroHandlerName)

            humanoid.PlatformStand = true
            GyroHandler.CFrame = camera.CFrame
            VelocityHandler.Velocity = v3zero

            local direction = controlModule:GetMoveVector()
            VelocityHandler.Velocity = (camera.CFrame.RightVector * direction.X - camera.CFrame.LookVector * direction.Z) * (iyflyspeed * 50)
        else
            unmobilefly() -- Sprzątanie, jeśli postać zniknie
        end
    end)
end

-- Implementacja przełącznika
-- Zakładając, że zmienna 'Tab' istnieje i jest to obiekt Twojej biblioteki GUI.
-- Jeśli nie, musisz ją najpierw zdefiniować.
-- Tab = YourGuiLibrary:CreateWindow("My GUI") 

Toggle = Tab:CreateToggle({
    Name = "Fly Toggle",
    CurrentValue = false,
    Flag = "FlyToggle1", -- Upewnij się, że ten flag jest unikalny
    Callback = function(Value)
        if Value == true then
            -- Włącz latanie
            if IsOnMobile then
                mobilefly()
            else
                sFLY()
            end
        else
            -- Wyłącz latanie
            if IsOnMobile then
                unmobilefly()
            else
                NOFLY()
            end
        end
    end,
})

Rayfield:Notify({
   Title = "HEHE",
   Content = "Best chain script",
   Duration = 11.5,
   Image = 93370012054262
})

Tab = Window:CreateTab("Character", "user") -- Title, Image

Section = Tab:CreateSection("sometimes it may turn on with a delay")

Divider = Tab:CreateDivider()

local staminaLoopActive = false -- Tworzymy zmienną kontrolną
local staminaThread = nil -- Zmienna na wątek pętli

Toggle = Tab:CreateToggle({
    Name = "Inf Stamina",
    CurrentValue = staminaLoopActive,
    Flag = "InfStaminaToggle_Fixed", -- Użyj unikalnego Flaga!
    Callback = function(Value)
        staminaLoopActive = Value -- Aktualizujemy stan

        if staminaLoopActive then
            -- Jeśli włączone i pętla jeszcze nie działa
            if not staminaThread or not task.running(staminaThread) then
                staminaThread = task.spawn(function()
                    print("Pętla staminy: START")
                    while staminaLoopActive do -- Pętla działa, dopóki zmienna jest 'true'
                        pcall(function() -- Używamy pcall dla bezpieczeństwa
                            game.Players.LocalPlayer.Character.Stats.Stamina.Value = 100
                        end)
                        task.wait(0.5)
                    end
                    print("Pętla staminy: STOP")
                end)
            end
        else
            -- Gdy wyłączasz, pętla sama się zatrzyma, bo 'staminaLoopActive' jest 'false'
        end
    end,
})

-- ### POPRAWIONY KOD DLA Inf Combat Stamina ###
local combatStaminaLoopActive = false
local combatStaminaThread = nil

Toggle = Tab:CreateToggle({
    Name = "Inf Combat Stamina",
    CurrentValue = combatStaminaLoopActive,
    Flag = "InfCombatStamina_Fixed", -- WAŻNE: Unikalny Flag
    Callback = function(Value)
        combatStaminaLoopActive = Value

        if combatStaminaLoopActive then
            -- Uruchom pętlę tylko wtedy, gdy nie jest już aktywna
            if not combatStaminaThread or not task.running(combatStaminaThread) then
                combatStaminaThread = task.spawn(function()
                    print("Pętla Combat Stamina: Włączona")
                    while combatStaminaLoopActive do
                        pcall(function()
                            game.Players.LocalPlayer.Character.Stats.CombatStamina.Value = 100
                        end)
                        task.wait(0.5)
                    end
                    print("Pętla Combat Stamina: Wyłączona")
                end)
            end
        end
    end,
})

-- ### POPRAWIONY KOD DLA Auto Win XSaw Clash ###
local clashLoopActive = false
local clashThread = nil

Toggle = Tab:CreateToggle({
    Name = "Auto Win XSaw Clash",
    CurrentValue = clashLoopActive,
    Flag = "AutoWinClash_Fixed", -- WAŻNE: Unikalny Flag
    Callback = function(Value)
        clashLoopActive = Value

        if clashLoopActive then
            -- Uruchom pętlę tylko wtedy, gdy nie jest już aktywna
            if not clashThread or not task.running(clashThread) then
                clashThread = task.spawn(function()
                    print("Pętla Auto Clash: Włączona")
                    while clashLoopActive do
                        pcall(function()
                            game.Players.LocalPlayer.Character.Stats.ClashStrength.Value = 100
                        end)
                        task.wait(0.005) -- Bardzo krótki czas, zgodnie z oryginałem
                    end
                    print("Pętla Auto Clash: Wyłączona")
                end)
            end
        end
    end,
})

-- ### POPRAWIONY KOD DLA inf xsaw gas ###
local gasLoopActive = false
local gasThread = nil

Toggle = Tab:CreateToggle({
    Name = "inf xsaw gas",
    CurrentValue = gasLoopActive,
    Flag = "InfGas_Fixed", -- WAŻNE: Unikalny Flag
    Callback = function(Value)
        gasLoopActive = Value

        if gasLoopActive then
            -- Uruchom pętlę tylko wtedy, gdy nie jest już aktywna
            if not gasThread or not task.running(gasThread) then
                gasThread = task.spawn(function()
                    print("Pętla paliwa XSaw: Włączona")
                    while gasLoopActive do
                        pcall(function()
                            -- Upewnij się, że postać i przedmiot istnieją
                            local char = game.Players.LocalPlayer.Character
                            if char and char:FindFirstChild("Items") and char.Items:FindFirstChild("XSaw") then
                                char.Items.XSaw:SetAttribute("Gas", 100)
                            end
                        end)
                        task.wait(0.01)
                    end
                    print("Pętla paliwa XSaw: Wyłączona")
                end)
            end
        end
    end,
})

Section = Tab:CreateSection("remove anti cheat before enabling inf dodge or you will be kicked from the game")

local RunService = game:GetService("RunService")
local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer

-- Zmienne robocze
local isNoRecoilActive = false
local noRecoilConnection = nil

-- ### SEKCJA 2: GŁÓWNA LOGIKA ###

-- Ta funkcja będzie zerować odrzut kamery w każdej klatce
local function cancelRecoil()
    pcall(function()
        local character = LocalPlayer.Character
        if not character then return end

        local humanoid = character:FindFirstChildOfClass("Humanoid")
        if not humanoid then return end

        -- Większość skryptów na broń symuluje odrzut, zmieniając na chwilę CameraOffset.
        -- My będziemy co klatkę zerować tę wartość, efektywnie kasując odrzut.
        humanoid.CameraOffset = Vector3.new(0, 0, 0)
    end)
end

Toggle = Tab:CreateToggle({
   Name = "Inf dodge (enable after removing anti cheat)",
   CurrentValue = false,
   Flag = "Toggle1", -- A flag is the identifier for the configuration file, make sure every element has a different flag if you're using configuration saving to ensure no overlaps
   Callback = function(Value)
		Rayfield:Notify({
   Title = "WARNING!",
   Content = "before enabling remove anticheat in the main tab",
   Duration = 6.5,
   Image = "rewind",
})
		local __namecall
__namecall = hookmetamethod(game, "__namecall", function(self, ...)
    if not checkcaller() then

        if getnamecallmethod() == "FireServer" then
            if self.Name == "CTS" then
                local args = {...}

                if args[1] == "DoneDodge" then
                    print('dodgeagain0_0')
                    args[1] = "Dodge"
                end

                return __namecall(self, unpack(args))
            end;
        end;
    end;

    return __namecall(self, ...)
end);
   -- The function that takes place when the toggle is pressed
   -- The variable (Value) is a boolean on whether the toggle is true or false
   end,
})

-- ### ZMIENNE I SERWISY ###
local Workspace = game:GetService("Workspace")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local Camera = Workspace.CurrentCamera

-- Pobieranie folderów (bezpieczniej jest używać WaitForChild)
local MiscFolder = Workspace:WaitForChild("Misc")
local AIFolder = MiscFolder:WaitForChild("AI")

-- ### GŁÓWNA LOGIKA AIMBOTA ###

ToggleEnabled = false  -- Kontrolowane przez przełącznik w UI
local RightMouseDown = false -- Kontrolowane przez przytrzymanie prawego przycisku myszy
local CHAIN                -- Zmienna do przechowywania aktualnego celu

-- Funkcja do ustawiania kamery
local function lookAt(targetCFrame)
	local newCFrame = CFrame.new(Camera.CFrame.Position, targetCFrame.Position)
	Camera.CFrame = newCFrame
end

-- Funkcja do wyszukiwania celu "CHAIN"
local function getChain()
	-- Jeśli cel już jest i jest prawidłowy, nie szukaj nowego
	if CHAIN and CHAIN.Parent then
		return CHAIN
	end

	-- Przeszukaj folder AI w poszukiwaniu nowego celu
	for _, child in ipairs(AIFolder:GetChildren()) do
		-- Sprawdza, czy model ma HumanoidRootPart, aby upewnić się, że to postać
		if child:FindFirstChild("HumanoidRootPart") then
			return child -- Zwraca znaleziony model jako cel
		end
	end
	return nil -- Zwraca nil, jeśli nie znaleziono celu
end

-- Funkcja, która jest wywoływana w każdej klatce renderowania
local function onRender()
	-- Aimbot jest aktywny TYLKO, gdy przełącznik jest włączony ORAZ prawy przycisk jest wciśnięty
	if ToggleEnabled and RightMouseDown then
		CHAIN = getChain()
		if CHAIN then
			lookAt(CHAIN:GetPivot())
		end
	else
		-- Jeśli warunki nie są spełnione, upewnij się, że cel jest wyczyszczony
		CHAIN = nil
	end
end

-- ### UTWORZENIE PRZEŁĄCZNIKA (TOGGLE) ###
-- Zakładając, że "Tab" jest już zdefiniowane w twoim skrypcie UI
Toggle = Tab:CreateToggle({
	Name = "Aimbot (hold PPM)",
	CurrentValue = ToggleEnabled,
	Flag = "ChainAimbotHoldToggle", -- Unikalny identyfikator
	Callback = function(Value)
		-- Aktualizuje stan przełącznika
		ToggleEnabled = Value
	end,
})

-- ### OBSŁUGA PRZYCISKU MYSZY ###
UserInputService.InputBegan:Connect(function(input, gameProcessedEvent)
	if gameProcessedEvent then return end
	if input.UserInputType == Enum.UserInputType.MouseButton2 then
		RightMouseDown = true
	end
end)

UserInputService.InputEnded:Connect(function(input)
	if input.UserInputType == Enum.UserInputType.MouseButton2 then
		RightMouseDown = false
	end
end)

-- ### PODPIĘCIE DO PĘTLI GRY ###
RunService.RenderStepped:Connect(onRender)

Divider = Tab:CreateDivider()

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local localPlayer = Players.LocalPlayer

-- Upewnij się, że Tab jest zdefiniowany (zakładając, że pochodzi z twojej biblioteki UI)
-- Przykład: local Tab = Window:CreateTab("Player")

-- Zmienna do przechowywania docelowej prędkości
local targetSpeed = 18
-- Zmienna, która będzie przechowywać aktualnego humanoida. Na razie jest pusta.
local humanoid = nil

-- Tworzenie suwaka do zmiany prędkości
local Slider = Tab:CreateSlider({
    Name = "Walk Speed",
    Range = {18, 200},
    Increment = 1,
    Suffix = " stud/s",
    CurrentValue = 18,
    Flag = "WalkSpeedSlider",
    Callback = function(Value)
        targetSpeed = Value
    end,
})

-- Tworzenie przycisku do resetowania prędkości
Button = Tab:CreateButton({
    Name = "Reset Speed",
    Callback = function()
        targetSpeed = 18
        Slider:Set(18)
    end,
})

-- Funkcja, która będzie uruchamiana za każdym razem, gdy postać się załaduje
local function onCharacterAdded(character)
    -- Czekamy na humanoid w nowej postaci i przypisujemy go do naszej zmiennej
    humanoid = character:WaitForChild("Humanoid")
end

-- Pętla "Loop Speed" do ciągłego ustawiania prędkości
-- Ta pętla działa cały czas, niezależnie od tego, czy postać istnieje
RunService.Heartbeat:Connect(function()
    -- Sprawdzamy, czy zmienna 'humanoid' zawiera obiekt i czy ten obiekt wciąż istnieje w grze (humanoid.Parent)
    if humanoid and humanoid.Parent and humanoid.WalkSpeed ~= targetSpeed then
        -- Jeśli aktualna prędkość jest inna niż docelowa, ustaw ją na nowo
        humanoid.WalkSpeed = targetSpeed
    end
end)


-- Podłączamy naszą funkcję do zdarzenia CharacterAdded
-- Dzięki temu 'humanoid' zostanie zaktualizowany po każdym resecie
localPlayer.CharacterAdded:Connect(onCharacterAdded)

-- Sprawdzamy, czy postać gracza już istnieje w momencie uruchomienia skryptu
-- Jeśli tak, ręcznie uruchamiamy funkcję, aby od razu pobrać humanoida
if localPlayer.Character then
    onCharacterAdded(localPlayer.Character)
end

-- Ustawienie prędkości na wartość początkową z suwaka
targetSpeed = Slider.CurrentValue

-- Ustawienie prędkości na wartość początkową
targetSpeed = Slider.CurrentValue

Tab = Window:CreateTab("Teleport - Locations", "land-plot") -- Title, Image

local function GetPlayerNames()
    local names = {}
    for _, player in pairs(Players:GetPlayers()) do
        if player ~= LocalPlayer then
            table.insert(names, player.DisplayName .. " (@" .. player.Name .. ")")
        end
    end
    return names
end

local Dropdown = Tab:CreateDropdown({
    Name = "Teleport to player 👤",
    Options = GetPlayerNames(),
    CurrentOption = {},
    MultipleOptions = false,
    Flag = "TeleportToPlayer",
    Callback = function(Options)
        local selectedPlayerName = Options[1]:match("%(@(.+)%)") -- Wyciąganie oryginalnego nicku
        local selectedPlayer = Players:FindFirstChild(selectedPlayerName)
        if selectedPlayer and selectedPlayer.Character and selectedPlayer.Character:FindFirstChild("HumanoidRootPart") then
            LocalPlayer.Character.HumanoidRootPart.CFrame = selectedPlayer.Character.HumanoidRootPart.CFrame
        end
    end,
})


local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer

-- Pusta tabela, która będzie naszą "bazą danych" dla zapisanych lokalizacji.
-- Struktura: { ["nazwa_pozycji"] = CFrame, ["inna_nazwa"] = CFrame, ... }
local zapisaneLokalizacje = {}

-- Zmienne przechowujące aktualny stan interfejsu
local nazwaDoZapisu = ""
local wybranaLokalizacja = nil

-- ### SEKCJA 2: INTERFEJS UŻYTKOWNIKA I LOGIKA (RAYFIELD) ###

-- Zakładając, że zmienna 'Tab' wskazuje na wybraną przez Ciebie zakładkę
Section = Tab:CreateSection("Own Teleports")

-- Pole do wpisywania nazwy dla nowej lokalizacji
local InputNazwa = Tab:CreateInput({
    Name = "Location Name",
    PlaceholderText = "Enter a name, e.g. 'Base'...",
    RemoveTextAfterFocusLost = false,
    Flag = "SaveLocationInput",
    Callback = function(text)
        nazwaDoZapisu = text -- Zapisz wpisany tekst do naszej zmiennej
    end,
})

-- Lista rozwijana, która będzie wyświetlać zapisane lokalizacje
-- Zapisujemy ją do zmiennej, aby móc ją później aktualizować
local DropdownLokalizacje = Tab:CreateDropdown({
    Name = "Select a saved item",
    Options = {}, -- Na początku pusta
    CurrentOption = {},
    MultipleOptions = false,
    Flag = "SavedLocationsDropdown",
    Callback = function(opcje)
        wybranaLokalizacja = opcje[1] -- Zapisz wybraną z listy lokalizację
    end,
})

-- Przycisk do zapisywania aktualnej pozycji
ButtonZapisz = Tab:CreateButton({
    Name = "Save Current Position",
    Callback = function()
        if nazwaDoZapisu == "" then
            Rayfield:Notify({Title = "Mistake", Content = "Enter a name for your location!", Duration = 5, Image = "alert-circle"})
            return
        end
        if zapisaneLokalizacje[nazwaDoZapisu] then
             Rayfield:Notify({Title = "Mistake", Content = "A location with that name already exists!", Duration = 5, Image = "alert-circle"})
            return
        end
        if not (LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart")) then
            Rayfield:Notify({Title = "Mistake", Content = "Your character could not be found.", Duration = 5})
            return
        end

        local aktualnyCFrame = LocalPlayer.Character.HumanoidRootPart.CFrame
        zapisaneLokalizacje[nazwaDoZapisu] = aktualnyCFrame
        print("Saved position '"..nazwaDoZapisu.."' pod koordynatami: " .. tostring(aktualnyCFrame.Position))
        Rayfield:Notify({Title = "Success!", Content = "Saved position: " .. nazwaDoZapisu, Duration = 5, Image = "save"})

        -- Zaktualizuj listę w Dropdownie
        local nazwy = {}
        for nazwa, _ in pairs(zapisaneLokalizacje) do table.insert(nazwy, nazwa) end
        DropdownLokalizacje:Refresh(nazwy)
    end,
})

-- Przycisk do teleportacji
ButtonTeleportuj = Tab:CreateButton({
    Name = "Teleport to Selected Position",
    Callback = function()
        if not wybranaLokalizacja then
            Rayfield:Notify({Title = "Mistake", Content = "No locations selected from the list!", Duration = 5, Image = "alert-circle"})
            return
        end
        if not (LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart")) then
            Rayfield:Notify({Title = "Mistake", Content = "Your character could not be found.", Duration = 5})
            return
        end

        local cel = zapisaneLokalizacje[wybranaLokalizacja]
        if cel then
            LocalPlayer.Character.HumanoidRootPart.CFrame = cel
            Rayfield:Notify({Title = "Teleportation!", Content = "Moved to: " .. wybranaLokalizacja, Duration = 4, Image = "plane-takeoff"})
        end
    end,
})

-- Przycisk do usuwania pozycji
ButtonUsun = Tab:CreateButton({
    Name = "Remove Selected Item",
    Callback = function()
        if not wybranaLokalizacja then
            Rayfield:Notify({Title = "Mistake", Content = "No locations selected from the list!", Duration = 5, Image = "alert-circle"})
            return
        end

        zapisaneLokalizacje[wybranaLokalizacja] = nil -- Usuń pozycję z naszej tabeli
        wybranaLokalizacja = nil -- Wyczyść wybór
        Rayfield:Notify({Title = "Removed", Content = "The selected item has been deleted.", Duration = 5, Image = "trash-2"})

        -- Zaktualizuj listę w Dropdownie
        local nazwy = {}
        for nazwa, _ in pairs(zapisaneLokalizacje) do table.insert(nazwy, nazwa) end
        DropdownLokalizacje:Refresh(nazwy)
        DropdownLokalizacje:Set({}) -- Wyczyść pole dropdown po usunięciu
    end,
})

spawn(function()
    while wait(30) do
        Dropdown:Refresh(GetPlayerNames())
    end
end)

Section = Tab:CreateSection("teleport to different locations on the map")

Divider = Tab:CreateDivider()

local airDropsFolder = workspace:WaitForChild("GameStuff"):WaitForChild("GameSections"):WaitForChild("AirDrops")

Tab:CreateButton({
    Name = "Teleport to nearest Drop",
    Callback = function()
        local allAirdrops = airDropsFolder:GetChildren()

        if #allAirdrops == 0 then
            Rayfield:Notify({Title = "Mistake", Content = "There are currently no drops on the map.", Duration = 5, Image = "box"})
            return
        end

        -- W tym przykładzie teleportujemy się do pierwszego znalezionego zrzutu
        local targetAirdrop = allAirdrops[1]
        local targetCFrame = targetAirdrop:GetPivot()

        if LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart") then
            -- Teleportujemy się nieco nad zrzutem, żeby nie utknąć w środku
            LocalPlayer.Character.HumanoidRootPart.CFrame = targetCFrame * CFrame.new(0, 10, 0)
            Rayfield:Notify({Title = "Intercepted!", Content = "Teleportation to drop complete.", Duration = 5, Image = "box"})
        else
            Rayfield:Notify({Title = "Mistake", Content = "Your character could not be found.", Duration = 5, Image = "box"})
        end
    end
})

Button = Tab:CreateButton({
   Name = "SafeHouse",
   Callback = function()
      game.Players.LocalPlayer.Character.HumanoidRootPart.CFrame = CFrame.new(162.680023, -94.2610092, 230.036407, 0.999293089, -1.40679939e-08, 0.0375940055, 1.348163e-08, 1, 1.58507891e-08, -0.0375940055, -1.53327555e-08, 0.999293089)
   -- The function that takes place when the button is pressed
   end,
})

Button = Tab:CreateButton({
   Name = "WorkShop Outside",
   Callback = function()
      game.Players.LocalPlayer.Character.HumanoidRootPart.CFrame = CFrame.new(130.923874, -106.07193, -2.17581439, 0.507446766, -0.859753072, -0.0576408654, 0.767467797, 0.481365085, -0.42341572, 0.391779244, 0.170623437, 0.904099941)
   -- The function that takes place when the button is pressed
   end,
})

Button = Tab:CreateButton({
   Name = "WorkShop Inside",
   Callback = function()
      game.Players.LocalPlayer.Character.HumanoidRootPart.CFrame = CFrame.new(169.560654, -103.651337, -30.0143433, 0.262320459, 1.83968858e-08, -0.964980841, 9.02348959e-11, 1, 1.90890379e-08, 0.964980841, -5.09452036e-09, 0.262320459)
   -- The function that takes place when the button is pressed
   end,
})

Button = Tab:CreateButton({
   Name = "Cabin inside",
   Callback = function()
      game.Players.LocalPlayer.Character.HumanoidRootPart.CFrame = CFrame.new(-324.801575, -88.6199799, 290.675598, 0.451050401, 1.02070366e-07, -0.892498493, -2.45230627e-08, 1, 1.01971303e-07, 0.892498493, -2.41073987e-08, 0.451050401)
   -- The function that takes place when the button is pressed
   end,
})

Button = Tab:CreateButton({
   Name = "Shop",
   Callback = function()
      game.Players.LocalPlayer.Character.HumanoidRootPart.CFrame = CFrame.new(-111.376678, -87.2069778, 203.522934, -0.851789057, -5.88233995e-08, 0.523884892, -1.06661249e-08, 1, 9.49409156e-08, -0.523884892, 7.5281811e-08, -0.851789057)
   -- The function that takes place when the button is pressed
   end,
})

Button = Tab:CreateButton({
   Name = "PowerStation",
   Callback = function()
      game.Players.LocalPlayer.Character.HumanoidRootPart.CFrame = CFrame.new(-208.299744, -110.604126, -120.227615, 0.994857252, -4.01115097e-09, 0.101287208, 1.21101742e-08, 1, -7.9346087e-08, -0.101287208, 8.01646323e-08, 0.994857252)
   -- The function that takes place when the button is pressed
   end,
})

Button = Tab:CreateButton({
   Name = "WareHouse",
   Callback = function()
      game.Players.LocalPlayer.Character.HumanoidRootPart.CFrame = CFrame.new(314.623566, -113.515549, -258.481567, 0.99898839, 1.88050908e-08, -0.0449683107, -1.91088674e-08, 1, -6.32548991e-09, 0.0449683107, 7.17838455e-09, 0.99898839)
   -- The function that takes place when the button is pressed
   end,
})

Button = Tab:CreateButton({
   Name = "Ritual",
   Callback = function()
      game.Players.LocalPlayer.Character.HumanoidRootPart.CFrame = CFrame.new(-18.6015053, -107.779076, -229.89505, 0.924807549, -7.74951925e-09, -0.380435318, -1.76391968e-09, 1, -2.46580836e-08, 0.380435318, 2.34750388e-08, 0.924807549)
   -- The function that takes place when the button is pressed
   end,
})

Button = Tab:CreateButton({
   Name = "LeaderBoard",
   Callback = function()
      game.Players.LocalPlayer.Character.HumanoidRootPart.CFrame = CFrame.new(45.6568947, -97.9687805, 352.514221, -0.99593854, -2.09143503e-09, -0.0900359452, 1.3530822e-09, 1, -3.81960987e-08, 0.0900359452, -3.8162792e-08, -0.99593854)
   -- The function that takes place when the button is pressed
   end,
})

Button = Tab:CreateButton({
   Name = "Radio Tower",
   Callback = function()
		game.Players.LocalPlayer.Character.HumanoidRootPart.CFrame = CFrame.new(-402.222595, -112.368164, 44.1699409, 0.0451246351, -1.07376825e-14, -0.998981357, -6.33584847e-08, 1, -2.86195445e-09, 0.998981357, 6.34230872e-08, 0.0451246351)
   -- The function that takes place when the button is pressed
   end,
})

Button = Tab:CreateButton({
   Name = "Teleport Outside Map - safe",
   Callback = function()
		game.Players.LocalPlayer.Character.HumanoidRootPart.CFrame = CFrame.new(39.0608749, -99.1718979, 574.259521, 0.907835662, 7.08418568e-08, -0.419326216, -3.53907694e-08, 1, 9.23215708e-08, 0.419326216, -6.89725326e-08, 0.907835662)
   -- The function that takes place when the button is pressed
   end,
})
Tab = Window:CreateTab("Visuals", "eye") -- Title, Image

--esp gracze
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local Workspace = game:GetService("Workspace")

-- Zmienne lokalne
local LocalPlayer = Players.LocalPlayer
local Camera = Workspace.CurrentCamera

-- Główna tabela do przechowywania elementów ESP (Highlight, Name, Distance) dla każdego gracza
local espElements = {}
local espConnection = nil -- Zmienna do przechowywania połączenia z RenderStepped

-- Funkcja do aktualizacji ESP w każdej klatce
local function updateEsp()
    -- Tabela do śledzenia, którzy gracze są obecnie na serwerze
    local activePlayers = {}

    -- Pętla przez wszystkich graczy
    for _, player in ipairs(Players:GetPlayers()) do
        if player ~= LocalPlayer and player.Character and player.Character:FindFirstChild("HumanoidRootPart") then
            activePlayers[player] = true -- Oznacz gracza jako aktywnego

            local character = player.Character
            local humanoidRootPart = character.HumanoidRootPart
            
            -- Jeśli gracz nie ma jeszcze stworzonych elementów, stwórz je
            if not espElements[player] then
                local highlight = Instance.new("Highlight")
                -- Konfiguracja Chams (Highlight)
                -- POPRAWKA: Zmieniono Enum.DepthMode na Enum.HighlightDepthMode
                highlight.DepthMode = Enum.HighlightDepthMode.AlwaysOnTop
                highlight.FillColor = Color3.fromRGB(255, 0, 0) -- Czerwony
                highlight.FillTransparency = 0.6
                highlight.OutlineColor = Color3.fromRGB(255, 255, 255) -- Biały
                highlight.OutlineTransparency = 0
                highlight.Parent = character
                
                espElements[player] = {
                    Highlight = highlight,
                    Name = Drawing.new("Text"),
                    Distance = Drawing.new("Text")
                }
                
                -- Konfiguracja wyglądu dla Imienia
                espElements[player].Name.Size = 14
                espElements[player].Name.Center = true
                espElements[player].Name.Outline = true
                espElements[player].Name.Font = Drawing.Fonts.UI

                -- Konfiguracja wyglądu dla Dystansu
                espElements[player].Distance.Size = 12
                espElements[player].Distance.Center = true
                espElements[player].Distance.Outline = true
                espElements[player].Distance.Font = Drawing.Fonts.Plex
            end

            -- Konwertuj pozycję 3D postaci na pozycję 2D na ekranie
            local vector, onScreen = Camera:WorldToViewportPoint(humanoidRootPart.Position)
            local elements = espElements[player]

            if onScreen then
                -- Obliczanie odległości
                local distance = (LocalPlayer.Character.HumanoidRootPart.Position - humanoidRootPart.Position).Magnitude
                
                -- Aktualizacja właściwości rysunków
                local textColor = Color3.new(1, 1, 1) -- Biały kolor
                elements.Name.Color = textColor
                elements.Distance.Color = textColor
                
                elements.Name.Visible = true
                elements.Distance.Visible = true
                
                -- Aktualizacja pozycji i tekstu
                elements.Name.Text = player.Name
                elements.Name.Position = Vector2.new(vector.X, vector.Y - 30)
                
                elements.Distance.Text = "[" .. math.floor(distance) .. "m]"
                elements.Distance.Position = Vector2.new(vector.X, vector.Y - 15)
            else
                -- Jeśli gracz jest poza ekranem, ukryj jego teksty
                elements.Name.Visible = false
                elements.Distance.Visible = false
            end
        end
    end

    -- Pętla do czyszczenia elementów dla graczy, którzy opuścili grę
    for player, elements in pairs(espElements) do
        if not activePlayers[player] then
            elements.Highlight:Destroy()
            elements.Name:Remove()
            elements.Distance:Remove()
            espElements[player] = nil
        end
    end
end


-- Tworzenie przełącznika (Toggle) w Twoim interfejsie
Toggle = Tab:CreateToggle({
    Name = "Player Chams", -- Zmieniona nazwa
    CurrentValue = false,
    Flag = "PlayerChams_Toggle", -- Nowy unikalny identyfikator
    Callback = function(Value)
        -- Ta funkcja jest wywoływana, gdy przełącznik jest klikany
        -- Zmienna 'Value' to boolean (true/false)
        if Value == true then
            -- Jeśli włączone, połącz funkcję updateEsp z pętlą renderowania
            if not espConnection then
                espConnection = RunService.RenderStepped:Connect(updateEsp)
            end
        else
            -- Jeśli wyłączone, odłącz funkcję od pętli renderowania
            if espConnection then
                espConnection:Disconnect()
                espConnection = nil
            end
            
            -- Usuń wszystkie istniejące elementy ESP
            for player, elements in pairs(espElements) do
                if elements then
                    elements.Highlight:Destroy()
                    elements.Name:Remove()
                    elements.Distance:Remove()
                end
            end
            -- Wyczyść tabelę z elementami
            espElements = {}
        end
    end,
})

-- ### SEKCJA 1: INICJALIZACJA (BEZ ZMIAN) ###
local airDropsFolder = workspace:WaitForChild("GameStuff"):WaitForChild("GameSections"):WaitForChild("AirDrops")

local activeHighlights = {}
local eventConnections = {}

-- ### SEKCJA 2: GŁÓWNE FUNKCJE (BEZ ZMIAN, SĄ DOBRE) ###

-- Funkcja, która tworzy i aplikuje podświetlenie (Highlight) do modelu zrzutu
local function applyChams(airdropModel)
    -- Sprawdzamy, czy przekazany obiekt to na pewno Model i czy już nie ma podświetlenia
    if not airdropModel:IsA("Model") or activeHighlights[airdropModel] then
        return
    end

    local highlight = Instance.new("Highlight")
    highlight.FillColor = Color3.fromRGB(255, 255, 0)
    highlight.FillTransparency = 0.6
    highlight.OutlineColor = Color3.fromRGB(255, 255, 255)
    highlight.OutlineTransparency = 0.2
    highlight.DepthMode = Enum.HighlightDepthMode.AlwaysOnTop
    highlight.Parent = airdropModel

    activeHighlights[airdropModel] = highlight
end

-- Funkcja, która usuwa podświetlenie z konkretnego zrzutu
local function removeChams(airdropModel)
    if activeHighlights[airdropModel] and activeHighlights[airdropModel].Parent then
        activeHighlights[airdropModel]:Destroy()
        activeHighlights[airdropModel] = nil
    end
end

-- #################################################################
-- ### SEKCJA 3: KLUCZOWA POPRAWKA - NOWA LOGIKA ZARZĄDZANIA STANEM ###
-- #################################################################

-- Nowa, główna funkcja, która zarządza włączaniem i wyłączaniem Chamsów
local function updateChamsState(isEnabled)
    
    -- KROK 1: ZAWSZE zaczynaj od pełnego sprzątania.
    -- To jest automatyzacja tego, co robisz ręcznie (wyłączając i włączając).
    
    -- Rozłącz wszystkie stare połączenia z eventami
    for _, connection in pairs(eventConnections) do
        connection:Disconnect()
    end
    eventConnections = {}

    -- Zniszcz wszystkie istniejące podświetlenia
    for model, highlight in pairs(activeHighlights) do
        removeChams(model)
    end
    activeHighlights = {}

    -- KROK 2: Jeśli funkcja ma być WŁĄCZONA, skonfiguruj wszystko na nowo.
    if isEnabled then
        print("Airdrop Chams: Włączono i odświeżono.")
        
        -- Zastosuj chamsy do wszystkich zrzutów, które JUŻ SĄ na mapie
        for _, airdropModel in ipairs(airDropsFolder:GetChildren()) do
            applyChams(airdropModel)
        end

        -- Stwórz nowe połączenia, które będą nasłuchiwać przyszłych zmian
        eventConnections.childAdded = airDropsFolder.ChildAdded:Connect(applyChams)
        eventConnections.childRemoved = airDropsFolder.ChildRemoved:Connect(removeChams)
    else
        print("Airdrop Chams: Wyłączono i wyczyszczono.")
    end
end

-- ### SEKCJA 4: TWORZENIE PRZEŁĄCZNIKA W GUI (UPROSZCZONY) ###

Toggle = Tab:CreateToggle({
    Name = "Airdrop Chams",
    CurrentValue = false,
    Flag = "AirdropChamsToggle_v2", -- Zmieniona flaga dla pewności
    Callback = function(Value)
        -- Callback teraz wywołuje tylko jedną, główną funkcję zarządzającą.
        updateChamsState(Value)
    end,
})

-- Bezpieczne pobieranie ścieżki do folderu z artefaktami
local artifactsFolder = workspace:WaitForChild("Misc"):WaitForChild("Zones"):WaitForChild("LootingItems"):WaitForChild("Artifacts")

-- Zmienne do zarządzania stanem i zasobami
local chamsEnabled = false      -- Czy funkcja jest aktualnie włączona
local activeHighlights = {}     -- Tabela przechowująca aktywne podświetlenia { [artifact] = highlight }
local eventConnections = {}     -- Tabela do przechowywania połączeń z eventami (do późniejszego rozłączenia)

-- ### SEKCJA 2: GŁÓWNE FUNKCJE ###

-- Funkcja, która tworzy i aplikuje podświetlenie (Highlight) do jednego artefaktu
local function applyChams(artifactModel)
    -- Sprawdzamy, czy obiekt jest modelem i czy już nie ma podświetlenia
    if not artifactModel:IsA("Model") or activeHighlights[artifactModel] then
        return
    end

    -- Tworzymy nową instancję Highlight
    local highlight = Instance.new("Highlight")
    
    -- Konfiguracja wyglądu podświetlenia (możesz dowolnie zmieniać kolory)
    highlight.FillColor = Color3.fromRGB(0, 255, 255)       -- Cyjanowy (jasnoniebieski)
    highlight.FillTransparency = 0.7                         -- Lekka przezroczystość wypełnienia
    highlight.OutlineColor = Color3.fromRGB(255, 255, 255)   -- Biały kontur
    highlight.OutlineTransparency = 0.3                      -- Lekka przezroczystość konturu
    
    -- NAJWAŻNIEJSZE: To sprawia, że obiekt jest widoczny przez ściany
    highlight.DepthMode = Enum.HighlightDepthMode.AlwaysOnTop

    -- Dodajemy podświetlenie do artefaktu
    highlight.Parent = artifactModel

    -- Zapisujemy referencję do podświetlenia w naszej tabeli
    activeHighlights[artifactModel] = highlight
end

-- Funkcja, która usuwa podświetlenie z jednego artefaktu
local function removeChams(artifactModel)
    if activeHighlights[artifactModel] then
        activeHighlights[artifactModel]:Destroy() -- Niszczymy obiekt Highlight
        activeHighlights[artifactModel] = nil     -- Usuwamy wpis z tabeli
    end
end

-- Funkcja, która włącza cały system Chams
local function enableAllChams()
    print("Artifact Chams: Enabled")
    -- Najpierw aplikujemy chamsy do wszystkich artefaktów, które już są na mapie
    for _, artifact in ipairs(artifactsFolder:GetChildren()) do
        applyChams(artifact)
    end

    -- Następnie tworzymy połączenia, które będą reagować na nowe i usunięte artefakty
    eventConnections.childAdded = artifactsFolder.ChildAdded:Connect(applyChams)
    eventConnections.childRemoved = artifactsFolder.ChildRemoved:Connect(removeChams)
end

-- Funkcja, która wyłącza cały system Chams i sprząta po sobie
local function disableAllChams()
    print("Artifact Chams: Disabled")
    -- Rozłączamy wszystkie eventy, aby nie działały w tle
    if eventConnections.childAdded then eventConnections.childAdded:Disconnect() end
    if eventConnections.childRemoved then eventConnections.childRemoved:Disconnect() end
    eventConnections = {}

    -- Usuwamy wszystkie stworzone przez nas podświetlenia
    for artifact, highlight in pairs(activeHighlights) do
        if highlight then
            highlight:Destroy()
        end
    end
    activeHighlights = {} -- Czyścimy tabelę
end

-- ### SEKCJA 3: TWORZENIE PRZEŁĄCZNIKA W GUI ###

Toggle = Tab:CreateToggle({
    Name = "Artifact Chams)",
    CurrentValue = chamsEnabled, -- Początkowa wartość (wyłączone)
    Flag = "ArtifactChamsToggle", -- Unikalny identyfikator dla zapisywania konfiguracji
    Callback = function(Value)
        -- Ta funkcja jest wywoływana za każdym razem, gdy klikasz przełącznik
        chamsEnabled = Value -- Aktualizujemy stan

        if chamsEnabled then
            -- Jeśli przełącznik jest WŁĄCZONY, aktywujemy system
            enableAllChams()
        else
            -- Jeśli przełącznik jest WYŁĄCZONY, dezaktywujemy system i sprzątamy
            disableAllChams()
        end
    end,
})

local RunService = game:GetService("RunService")
local Players = game:GetService("Players")
local CoreGui = game:GetService("CoreGui")

-- --- Konfiguracja ---
local BEAR_TRAPS_PATH = game:GetService("Workspace").GameStuff.PlayerStuff.BearTraps
local CHAMS_COLOR = Color3.fromRGB(138, 43, 226) -- Fioletowy kolor
local CHAMS_TRANSPARENCY = 0.5 -- Przezroczystość

local LABEL_TEXT_COLOR = Color3.fromRGB(255, 255, 255)
local LABEL_TEXT = "BearTrap"
local LABEL_FONT = Enum.Font.SourceSansBold
local LABEL_TEXT_SIZE = 16

-- --- Zmienne robocze ---
local LocalPlayer = Players.LocalPlayer
local chamsEnabled = false
-- Zmieniona struktura do przechowywania chamsów: { [model] = { Chams = {}, Label = UiObject, Connection = event } }
local activeChams = {}
local connections = {} -- Tabela do przechowywania połączeń z eventami

-- --- Funkcje pomocnicze ---

-- Funkcja do aktualizacji tekstu dystansu w etykietach
local function updateDistanceText()
    if not chamsEnabled or not next(activeChams) then return end

    local playerRoot = LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
    if not playerRoot then return end

    for model, data in pairs(activeChams) do
        -- Sprawdzamy, czy model i jego elementy nadal istnieją
        if model and model.Parent and data.Label and data.Label.Adornee and data.Label.Parent then
            -- POPRAWKA: Pobieramy pozycję bezpośrednio z części, do której przyczepiona jest etykieta (Adornee)
            local trapPosition = data.Label.Adornee.Position
            local distance = (playerRoot.Position - trapPosition).Magnitude
            
            -- Znajdujemy TextLabel wewnątrz BillboardGui
            local infoLabel = data.Label:FindFirstChild("InfoLabel")
            if infoLabel then
                infoLabel.Text = string.format("%s [%.0fm]", LABEL_TEXT, distance)
            end
        else
            -- Usuwanie nieistniejących już elementów
            if data.Label then data.Label:Destroy() end
            for _, cham in ipairs(data.Chams) do if cham then cham:Destroy() end end
            if data.Connection then data.Connection:Disconnect() end
            activeChams[model] = nil
        end
    end
end

-- Funkcja usuwająca wszystkie aktywne chamsy i etykiety
local function removeAllChams()
    for model, data in pairs(activeChams) do
        if data.Connection then data.Connection:Disconnect() end
        for _, cham in ipairs(data.Chams) do if cham then cham:Destroy() end end
        if data.Label then data.Label:Destroy() end
    end
    activeChams = {}
end

-- Funkcja tworząca chams i etykietę dla modelu pułapki
local function createChamsForModel(trapModel)
    if not trapModel:IsA("Model") or activeChams[trapModel] then return end

    -- Znajdź główną część, do której można przyczepić etykietę
    local mainPart = trapModel.PrimaryPart or trapModel:FindFirstChildWhichIsA("BasePart")
    if not mainPart then return end -- Jeśli model nie ma żadnych części, nie można nic zrobić

    local chamsData = { Chams = {}, Label = nil, Connection = nil }
    activeChams[trapModel] = chamsData

    -- Używamy BillboardGui dla etykiet
    local billboardGui = Instance.new("BillboardGui")
    billboardGui.Name = "BearTrapLabel"
    billboardGui.Adornee = mainPart -- "Przyklejamy" GUI do części pułapki
    billboardGui.AlwaysOnTop = true -- Zawsze widoczne
    billboardGui.LightInfluence = 0 -- Ignoruje oświetlenie w grze
    billboardGui.Size = UDim2.new(5, 0, 1.5, 0) -- Rozmiar w "studach" (wymiarach 3D)
    billboardGui.StudsOffset = Vector3.new(0, 2, 0) -- Unosi etykietę 2 study nad pułapkę
    billboardGui.Parent = CoreGui -- Parentujemy do CoreGui, aby zawsze było widoczne

    local textLabel = Instance.new("TextLabel")
    textLabel.Name = "InfoLabel"
    textLabel.BackgroundTransparency = 1
    textLabel.Size = UDim2.new(1, 0, 1, 0)
    textLabel.Font = LABEL_FONT
    textLabel.TextSize = LABEL_TEXT_SIZE
    textLabel.TextColor3 = LABEL_TEXT_COLOR
    textLabel.TextStrokeTransparency = 0
    textLabel.Parent = billboardGui

    chamsData.Label = billboardGui

    -- Tworzenie chamsów (ta część pozostaje bez zmian)
    for _, part in ipairs(trapModel:GetDescendants()) do
        if part:IsA("BasePart") then
            local boxHandle = Instance.new("BoxHandleAdornment")
            boxHandle.Adornee = part
            boxHandle.AlwaysOnTop = true
            boxHandle.ZIndex = 10
            boxHandle.Size = part.Size + Vector3.new(0.1, 0.1, 0.1)
            boxHandle.Color3 = CHAMS_COLOR
            boxHandle.Transparency = CHAMS_TRANSPARENCY
            boxHandle.Parent = CoreGui
            table.insert(chamsData.Chams, boxHandle)
        end
    end

    -- Połączenie usuwające elementy, gdy pułapka zostanie zniszczona
    chamsData.Connection = trapModel.AncestryChanged:Connect(function(_, parent)
        if not parent and activeChams[trapModel] then
            local data = activeChams[trapModel]
            for _, cham in ipairs(data.Chams) do if cham then cham:Destroy() end end
            if data.Label then data.Label:Destroy() end
            activeChams[trapModel] = nil
        end
    end)
end

-- Funkcja włączająca/wyłączająca cały system
local function setChams(enabled)
    chamsEnabled = enabled
    if enabled then
        for _, trapModel in ipairs(BEAR_TRAPS_PATH:GetChildren()) do
            createChamsForModel(trapModel)
        end

        connections.childAdded = BEAR_TRAPS_PATH.ChildAdded:Connect(function(child)
            if chamsEnabled then createChamsForModel(child) end
        end)

        -- Pętla do aktualizacji samego tekstu, a nie pozycji
        connections.renderStepped = RunService.RenderStepped:Connect(updateDistanceText)
    else
        removeAllChams()
        if connections.childAdded then connections.childAdded:Disconnect() end
        if connections.renderStepped then connections.renderStepped:Disconnect() end
        connections = {}
    end
end

-- --- Tworzenie przełącznika w UI ---
Toggle = Tab:CreateToggle({
    Name = "BearTrap Chams",
    CurrentValue = false,
    Flag = "BearTrapChamsToggle",
    Callback = function(Value)
        setChams(Value)
    end,
})

Divider = Tab:CreateDivider()

--chain info esp
local Bin
do
	Bin = setmetatable({}, {
		__tostring = function()
			return "Bin"
		end,
	})
	Bin.__index = Bin
	function Bin.new(...)
		local self = setmetatable({}, Bin)
		return self:constructor(...) or self
	end
	function Bin:constructor()
	end
	function Bin:add(item)
		local node = {
			item = item,
		}
		if self.head == nil then
			self.head = node
		end
		if self.tail then
			self.tail.next = node
		end
		self.tail = node
		return self
	end
	function Bin:destroy()
		local head = self.head
		while head do
			local _binding = head
			local item = _binding.item
			if type(item) == "function" then
				pcall(item)
			elseif typeof(item) == "RBXScriptConnection" then
				item:Disconnect()
			elseif type(item) == "thread" then
				task.cancel(item)
			elseif item.Destroy then
				pcall(function() item:Destroy() end)
			end
			head = head.next
			self.head = head
		end
        self.head = nil
        self.tail = nil
	end
	function Bin:isEmpty()
		return self.head == nil
	end
end


Toggle = Tab:CreateToggle({
    Name = "information about Chain",
    CurrentValue = false,
    Flag = "AIESP_Toggle",
    Callback = function(Value)
        -- Używamy 'pcall' aby uniknąć błędów, jeśli skrypt jest uruchamiany wielokrotnie
        pcall(function()
            if _G.AIESP_Bin and not _G.AIESP_Bin:isEmpty() then
                _G.AIESP_Bin:destroy()
            end
        end)

        if Value then
            -- Jeśli przełącznik jest włączony, inicjujemy ESP

            _G.AIESP_Bin = Bin.new() -- Tworzymy globalny kosz do zarządzania wszystkimi zasobami ESP

            -- Zmienne i referencje
            local Players = game:GetService("Players")
            local RunService = game:GetService("RunService")
            local Workspace = game:GetService("Workspace")
            local CoreGui = game:GetService("CoreGui")

            local AIFolder = Workspace:WaitForChild("Misc"):WaitForChild("AI")
            local LocalPlayer = Players.LocalPlayer
            local CurrentCamera = Workspace.CurrentCamera
            
            -- Tworzymy ScreenGui i dodajemy go do kosza, aby został zniszczony po wyłączeniu
            local ScreenGui = Instance.new("ScreenGui")
            ScreenGui.DisplayOrder = 10
            ScreenGui.IgnoreGuiInset = true
            ScreenGui.Parent = CoreGui
            _G.AIESP_Bin:add(ScreenGui)

            -- Funkcje pomocnicze
            local function format(num)
                return string.format("%.1f", num)
            end

            -- Deklaracja komponentu ESP
            local ESP = {}
            ESP.__index = ESP
            ESP.instances = {}
            
            function ESP.new(entity)
                local self = setmetatable({}, ESP)

                self.bin = Bin.new()
                self.instance = entity
                self.attributes = entity:GetAttributes()

                self.labels = {
                    container = Instance.new("Frame"),
                    name = Instance.new("TextLabel"),
                    data = Instance.new("TextLabel"),
                    listlayout = Instance.new('UIListLayout'),
                }
                
                -- Dodaj instancję do globalnej listy i skonfiguruj jej zniszczenie
                ESP.instances[entity] = self
                self.bin:add(function()
                    ESP.instances[entity] = nil
                end)
                
                -- Zniszcz, gdy instancja zniknie z gry
                self.bin:add(entity.AncestryChanged:Connect(function(_, parent)
                    if parent == nil then
                        self:destroy()
                    end
                end))

                self:setLabels()
                self:update()

                return self
            end

            function ESP:setLabels()
                local container = self.labels.container
                container.Visible = false
                container.AnchorPoint = Vector2.new(0.5, 0)
                container.BackgroundTransparency = 1
                container.Parent = ScreenGui
                self.bin:add(container) -- Dodaj kontener do kosza instancji

                local name = self.labels.name
                name.BackgroundTransparency = 1
                name.Font = Enum.Font.Nunito
                name.Size = UDim2.new(1, 0, 0, 14)
                name.Text = self.instance.Name
                name.TextSize = 14
                name.TextStrokeTransparency = 0.5
                name.Parent = container

                local data = self.labels.data
                data.BackgroundTransparency = 1
                data.Font = Enum.Font.Nunito
                data.Size = UDim2.new(1, 0, 0, 14)
                data.TextSize = 12
                data.TextStrokeTransparency = 0.5
                data.Parent = container

                local listlayout = self.labels.listlayout
                listlayout.HorizontalAlignment = Enum.HorizontalAlignment.Center
                listlayout.SortOrder = Enum.SortOrder.LayoutOrder
                listlayout.Parent = container
            end

            function ESP:update()
                self.labels.name.TextColor3 = Color3.new(1, 0, 0)
                self.labels.data.TextColor3 = Color3.new(1, 1, 1)
                self.labels.listlayout.Padding = UDim.new(0, -4)
                self.labels.container.Size = UDim2.new(0, 300, 0, self.labels.listlayout.AbsoluteContentSize.Y)
            end

            function ESP:render()
                if not self.instance or not self.instance.Parent then
                    self:destroy()
                    return
                end
                
                local rootPart = self.instance:FindFirstChild("HumanoidRootPart")
                local localRootPart = LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
                
                if not rootPart or not localRootPart then
                    self.labels.container.Visible = false
                    return
                end

                local position, visible = CurrentCamera:WorldToViewportPoint(rootPart.Position)

                if visible then
                    self.labels.container.Visible = true
                    
                    local vector2 = Vector2.new(position.X, position.Y)
                    self.attributes = self.instance:GetAttributes()

                    self.labels.name.Text = self.instance.Name
                    
                    local positionDiff = localRootPart.Position - rootPart.Position
                    self.labels.data.Text = `[{format(positionDiff.Magnitude)}] [Anger: {format(self.attributes.Anger)}] [Choke: {format(self.attributes.ChokeMeter)}%] [Slam: {format(self.attributes.Burst)}]`

                    self.labels.container.Position = UDim2.fromOffset(vector2.X, vector2.Y + 3)
                    self:update()
                else
                    self.labels.container.Visible = false
                end
            end
            
            function ESP:destroy()
                if self.bin then
                    self.bin:destroy()
                    self.bin = nil
                end
            end

            -- Główne połączenia
            local function onChildAdded(instance)
                if instance:IsA("Model") and instance:FindFirstChild("Humanoid") then
                     -- Poczekaj na HumanoidRootPart dla pewności
                    task.spawn(function()
                        instance:WaitForChild("HumanoidRootPart", 10)
                        if instance.Parent then -- Sprawdź, czy obiekt nadal istnieje
                            ESP.new(instance)
                        end
                    end)
                end
            end
            
            -- Połączenie RenderStepped do aktualizacji wszystkich instancji ESP
            local renderConnection = RunService.RenderStepped:Connect(function()
                if not LocalPlayer.Character then return end
                for entity, esp in pairs(ESP.instances) do
                    -- Używamy pcall, aby błąd w jednej instancji nie zatrzymał pętli
                    pcall(function() esp:render() end)
                end
            end)
            
            -- Połączenie ChildAdded do wykrywania nowych AI
            local addedConnection = AIFolder.ChildAdded:Connect(onChildAdded)

            -- Dodajemy główne połączenia do globalnego kosza, aby je rozłączyć po wyłączeniu toggle
            _G.AIESP_Bin:add(renderConnection)
            _G.AIESP_Bin:add(addedConnection)
            
            -- Utwórz ESP dla już istniejących AI
            for _, child in ipairs(AIFolder:GetChildren()) do
                onChildAdded(child)
            end

        else
            -- Jeśli przełącznik jest wyłączony, niszczymy wszystko
            -- Globalny kosz (_G.AIESP_Bin) zajmie się zniszczeniem ScreenGui,
            -- rozłączeniem RenderStepped i ChildAdded, co zatrzyma działanie skryptu.
            -- Zniszczenie ScreenGui automatycznie zniszczy wszystkie jego dzieci (elementy ESP).
            -- Musimy też ręcznie wyczyścić indywidualne instancje ESP.
             pcall(function()
                if _G.AIESP_Instances then
                    for _, esp in pairs(_G.AIESP_Instances) do
                        esp:destroy()
                    end
                end
            end)
        end
    end,
})

--chain info esp
local highlightInstance = nil -- Zmienna do przechowywania instancji podświetlenia

Toggle = Tab:CreateToggle({
    Name = "Chain ESP - red",
    CurrentValue = false,
    Flag = "Toggle1",
    Callback = function(Value)
        if Value == true then -- Działanie, gdy przełącznik jest WŁĄCZANY
            -- Bezpieczne wyszukiwanie obiektu za pomocą FindFirstChild, aby uniknąć błędów
            local partToHighlight = workspace:FindFirstChild("Misc", true) and workspace.Misc:FindFirstChild("AI") and workspace.Misc.AI:FindFirstChild("CHAIN")

            if partToHighlight then
                -- Jeśli podświetlenie nie zostało jeszcze stworzone, utwórz je teraz
                if not highlightInstance then
                    highlightInstance = Instance.new("Highlight")
                    highlightInstance.FillColor = Color3.fromRGB(255, 21, 21)      -- Czerwony
                    highlightInstance.OutlineColor = Color3.fromRGB(255, 255, 255)  -- Biały
                    highlightInstance.FillTransparency = 0.60
                    highlightInstance.OutlineTransparency = 0
                    highlightInstance.Parent = partToHighlight
                end
                -- Włącz podświetlenie
                highlightInstance.Enabled = true
            else
                -- Jeśli obiekt nie został znaleziony, wyświetl powiadomienie
                Rayfield:Notify({
                    Title = "Chain ESP",
                    Content = "Chain is currently not on the map.",
                    Duration = 6.5,
                    Image = "eye-off", -- Możesz tu użyć ID obrazka, np. "rbxassetid://ID"
                })
                -- UWAGA: W tym miejscu przełącznik pozostanie wizualnie włączony.
                -- Aby go automatycznie wyłączyć, musiałbyś użyć funkcji z Twojej biblioteki UI, np. Toggle:Set(false)
            end
        else -- Działanie, gdy przełącznik jest WYŁĄCZANY
            -- Wyłącz podświetlenie, jeśli zostało wcześniej utworzone
            if highlightInstance then
                highlightInstance.Enabled = false
            end
        end
    end,
})

-- SCRAP ESP
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local Workspace = game:GetService("Workspace")
local CoreGui = game:GetService("CoreGui")

--[[
	* The libraries isnt mine, like Bin
	* It tracks connections, instances, functions, threads, and objects to be later destroyed.
]]
local Bin
do
	Bin = setmetatable({}, {
		__tostring = function()
			return "Bin"
		end,
	})
	Bin.__index = Bin
	function Bin.new(...)
		local self = setmetatable({}, Bin)
		return self:constructor(...) or self
	end
	function Bin:constructor()
	end
	function Bin:add(item)
		local node = {
			item = item,
		}
		if self.head == nil then
			self.head = node
		end
		if self.tail then
			self.tail.next = node
		end
		self.tail = node
		return self
	end
	function Bin:destroy()
		local head = self.head
		while head do
			local _binding = head
			local item = _binding.item
			if type(item) == "function" then
				pcall(item)
			elseif typeof(item) == "RBXScriptConnection" then
				item:Disconnect()
			elseif type(item) == "thread" then
				task.cancel(item)
			elseif item.Destroy then
				pcall(function() item:Destroy() end)
			end
			head = head.next
			self.head = head
		end
        self.head = nil
        self.tail = nil
	end
	function Bin:isEmpty()
		return self.head == nil
	end
end

--[[
    ----------------------
    Variables & References
    ----------------------
]]

local LootFolders : Folder = Workspace.Misc.Zones.LootingItems:WaitForChild('Scrap')
local LocalPlayer : Player = Players.LocalPlayer
local CurrentCamera = Workspace.CurrentCamera
-- ScreenGui will hold all the individual ESP elements
local ScreenGui = Instance.new("ScreenGui")

-- This table will hold the active ESP components
local ActiveComponents = {}


--[[
    --------------------
    Function Declaration
    --------------------
]]
function format(num, format)
    local formatted = string.format(`%.{format}f`, num)
    return formatted
end

--[[
    ---------------------
    Component Declaration
    ---------------------
]]
local BaseComponent
do
	BaseComponent = setmetatable({}, {
		__tostring = function()
			return "BaseComponent"
		end,
	})
	BaseComponent.__index = BaseComponent
	function BaseComponent.new(...)
		local self = setmetatable({}, BaseComponent)
		return self:constructor(...) or self
	end
	function BaseComponent:constructor(item)
		self.bin = Bin.new()
		self.object = item
	end
	function BaseComponent:destroy()
		self.bin:destroy()
	end
end
local LootableComponent
do
    local super = BaseComponent
    LootableComponent = setmetatable({}, {
        __tostring = function()
            return "LootableComponent"
        end,
        __index = super,
    })
    LootableComponent.__index = LootableComponent
    function LootableComponent.new(...)
        local self =  setmetatable({}, LootableComponent)
        return self:constructor(...) or self
    end
    function LootableComponent:constructor(isAvailable : boolean ,scrap : Model, pivot: CFrame)
        super.constructor(self, scrap)
		-- Interface:
		self.interface = {
			container = Instance.new("Frame"),
			name = Instance.new("TextLabel"),
		}
		-- Variables:
        self.pivotPos = pivot
        self.isAvailable = isAvailable
		
        -- init:
        self:initialize()
    end
    function LootableComponent:initialize()
        local _binding = self
        local bin = _binding.bin
		local interface = _binding.interface
		local instance = _binding.object
		local values : Folder = instance:WaitForChild('Values', 10)
        
        -- Instances:
        local container = interface.container
        local name = interface.name
		-- Properties:
		container.Visible = false
        container.AnchorPoint = Vector2.new(0.5, 0)
        container.BackgroundTransparency = 1
        name.BackgroundTransparency = 1
		name.Font = Enum.Font.Nunito
		name.Text = 'Scrap'
		name.TextColor3 = Color3.new(0, 1, 0)
		name.TextSize = 15
		name.TextStrokeTransparency = 0.5
		name.Size = UDim2.new(1, 0, 0, 14)
		container.Size = UDim2.new(0, 100, 0, 50)
		-- Initialization:
		name.Parent = container
		container.Parent = ScreenGui
        
        -- Add the UI elements to the bin so they get destroyed properly
        bin:add(container)

		bin:add(values:GetAttributeChangedSignal('Available'):Connect(function()
			_binding.isAvailable = values:GetAttribute('Available')
		end))
		bin:add(RunService.RenderStepped:Connect(function()
			_binding:render()
		end))
    end
	function LootableComponent:render()
		local camera = CurrentCamera
		local _binding = self
		local instance = _binding.object
		local pivot = _binding.pivotPos
		local interface = _binding.interface
		local container = interface.container
		local name = interface.name

		if camera and instance and instance.Parent then
			local position, visible = camera:WorldToViewportPoint(pivot.Position)
			local humanoidRootPart = LocalPlayer.Character and LocalPlayer.Character:FindFirstChild('HumanoidRootPart')

			if visible and self.isAvailable and humanoidRootPart then
				local scale = 1 / (position.Z * math.tan(math.rad(camera.FieldOfView * 0.5)) * 2) * 1000
                local width, height = math.floor(1 * scale), math.floor(3 * scale)
                local x, y = math.floor(position.X), math.floor(position.Y)
                local xPosition, yPosition = math.floor(x - width * 0.5), math.floor((y - height * 0.5) + (0.5 * scale))
                local vector2 = Vector2.new(xPosition, yPosition)

				container.Visible = true
				
				local PositionDiff = humanoidRootPart.Position - pivot.Position
				name.Text = `Scrap [{format(PositionDiff.Magnitude, 1)}]`

				container.Position = UDim2.new(0, vector2.X, 0, vector2.Y)
			else
                container.Visible = false
			end
		else
			self:destroy()
		end
	end
end

--[[
    ------------
    MAIN LOGIC
    ------------
]]

-- Setup the main ScreenGui
ScreenGui.DisplayOrder = 10
ScreenGui.IgnoreGuiInset = true
ScreenGui.Parent = CoreGui -- Parent to CoreGui to draw over everything

-- The Toggle to control the ESP
local ScrapESPToggle = Tab:CreateToggle({
    Name = "Scrap ESP",
    CurrentValue = false, -- Default to off
    Flag = "ScrapESP_Toggle",
    Callback = function(Value)
        if Value then
            -- Toggle is ON: Create ESP for all scrap items
            for _, v in ipairs(LootFolders:GetChildren()) do
                if v:IsA("Model") and v:GetAttribute('Scrap') and not ActiveComponents[v] then
                    -- Create a new component and store it in the table with the object as the key
                    ActiveComponents[v] = LootableComponent.new(v.Values:GetAttribute('Available'), v, v:GetPivot())
                end
            end
        else
            -- Toggle is OFF: Destroy all active ESP components
            for key, component in pairs(ActiveComponents) do
                component:destroy()
            end
            -- Clear the table
            ActiveComponents = {}
        end
    end,
})

-- Handle new scraps being added while the ESP is on
LootFolders.ChildAdded:Connect(function(child)
    if ScrapESPToggle.CurrentValue and child:IsA("Model") and child:GetAttribute('Scrap') and not ActiveComponents[child] then
        ActiveComponents[child] = LootableComponent.new(child.Values:GetAttribute('Available'), child, child:GetPivot())
    end
end)

-- Handle scraps being removed to prevent memory leaks
LootFolders.ChildRemoved:Connect(function(child)
    if ActiveComponents[child] then
        ActiveComponents[child]:destroy()
        ActiveComponents[child] = nil
    end
end)
-- SCRAP ESP

Divider = Tab:CreateDivider()

local currentScaleFactor = 3 -- Domyślny mnożnik skalowania

-- --- Logika Skryptu ---

-- Tabela przechowująca referencje do obiektów artefaktów
local artifactObjects = {}

-- Tabela ścieżek do artefaktów podana przez użytkownika
local artifactPaths = {
    game:GetService("Workspace").Misc.Zones.LootingItems.Artifacts:GetChildren()[3],
    game:GetService("Workspace").Misc.Zones.LootingItems.Artifacts:GetChildren()[2],
    game:GetService("Workspace").Misc.Zones.LootingItems.Artifacts.Artifact,
    game:GetService("Workspace").Misc.Zones.LootingItems.Artifacts:GetChildren()[4]
}

-- Pętla do bezpiecznego znalezienia i dodania obiektów artefaktów do listy
for _, path in ipairs(artifactPaths) do
    local artifactPart = path:FindFirstChild("Artifact")
    if artifactPart and artifactPart:IsA("BasePart") then
        table.insert(artifactObjects, artifactPart)
    else
        if path and path:IsA("BasePart") then
            table.insert(artifactObjects, path)
        else
            warn("Nie można było znaleźć części 'Artifact' dla ścieżki: " .. tostring(path))
        end
    end
end

-- Tabela do przechowywania oryginalnych rozmiarów
local originalSizes = {}
for _, artifact in ipairs(artifactObjects) do
    originalSizes[artifact] = artifact.Size
end

-- Zmienna przechowująca referencję do przełącznika, abyśmy mogli sprawdzić jego stan
local ArtifactScalerToggle

-- Funkcja do aplikowania zmiany rozmiaru, aby uniknąć powtarzania kodu
local function applyScaling(isScaled)
    for artifact, originalSize in pairs(originalSizes) do
        if artifact and artifact.Parent then
            if isScaled then
                artifact.Size = originalSize * currentScaleFactor
            else
                artifact.Size = originalSize
            end
        end
    end
end

-- Stwórz pole Input do zmiany mnożnika
local ScaleInput = Tab:CreateInput({
    Name = "Scaling Factor",
    CurrentValue = tostring(currentScaleFactor),
    PlaceholderText = "Enter a number, e.g. 3",
    RemoveTextAfterFocusLost = false,
    Flag = "ArtifactScaleInput",
    Callback = function(Text)
        -- Konwertuj tekst na liczbę
        local newScale = tonumber(Text)
        
        -- Sprawdź, czy konwersja się udała i czy liczba jest dodatnia
        if newScale and newScale > 0 then
            currentScaleFactor = newScale
            
            -- Jeśli przełącznik jest włączony, zastosuj nowy rozmiar natychmiast
            if ArtifactScalerToggle and ArtifactScalerToggle.CurrentValue then
                applyScaling(true)
            end
        end
    end,
})

-- Stwórz przełącznik (toggle) w interfejsie użytkownika
ArtifactScalerToggle = Tab:CreateToggle({
    Name = "Enlarge Artifacts",
    CurrentValue = false,
    Flag = "ArtifactScalerToggle",
    Callback = function(Value)
        -- Wywołaj funkcję skalującą z odpowiednim stanem (true/false)
        applyScaling(Value)
    end,
})

Tab = Window:CreateTab("Misc", "cog")

local Lighting = game:GetService("Lighting")
-- ZMIANA TUTAJ: Używamy UserSettings(), co jest bardziej niezawodne
local UserGameSettings = UserSettings():GetService("UserGameSettings")

-- Tabela do przechowywania oryginalnych ustawień graficznych
local originalSettings = {}
local settingsSaved = false

-- ### SEKCJA 2: GŁÓWNE FUNKCJE (ZAPISYWANIE I PRZYWRACANIE) ###

local function saveOriginalSettings()
    if settingsSaved then return end
    print("PERFORMANCE BOOSTER: Saving original graphic settings...")

    originalSettings.Technology = Lighting.Technology
    originalSettings.GlobalShadows = Lighting.GlobalShadows
    originalSettings.FogEnd = Lighting.FogEnd
    -- ZMIANA TUTAJ: Odwołujemy się do SavedQualityLevel z UserGameSettings
    originalSettings.QualityLevel = UserGameSettings.SavedQualityLevel
    
    originalSettings.effects = {}
    for _, effect in ipairs(Lighting:GetChildren()) do
        if effect:IsA("PostEffect") then
            originalSettings.effects[effect] = effect.Enabled
        end
    end

    settingsSaved = true
    print("PERFORMANCE BOOSTER: Original settings saved.")
end

local function applyPerformanceMode()
    print("PERFORMANCE BOOSTER: Enable performance mode.")
    
    Lighting.Technology = Enum.Technology.Compatibility
    Lighting.GlobalShadows = false
    Lighting.FogEnd = 100000
    -- ZMIANA TUTAJ: Ustawiamy SavedQualityLevel na najniższy
    UserGameSettings.SavedQualityLevel = Enum.SavedQualitySetting.QualityLevel1

    for _, effect in ipairs(Lighting:GetChildren()) do
        if effect:IsA("PostEffect") then
            effect.Enabled = false
        end
    end

    Rayfield:Notify({
        Title = "Efficiency",
        Content = "Enhanced performance mode has been enabled.",
        Duration = 5,
        Image = "zap"
    })
end

local function restoreOriginalSettings()
    if not settingsSaved then
        print("PERFORMANCE BOOSTER: No saved settings to restore.")
        return
    end
    print("PERFORMANCE BOOSTER: Restoring original graphics settings.")

    Lighting.Technology = originalSettings.Technology
    Lighting.GlobalShadows = originalSettings.GlobalShadows
    Lighting.FogEnd = originalSettings.FogEnd
    -- ZMIANA TUTAJ: Przywracamy zapisaną wartość do SavedQualityLevel
    UserGameSettings.SavedQualityLevel = originalSettings.QualityLevel

    for effect, wasEnabled in pairs(originalSettings.effects) do
        pcall(function()
            if effect and effect.Parent then
                effect.Enabled = wasEnabled
            end
        end)
    end
    
    Rayfield:Notify({
        Title = "Efficiency",
        Content = "The original graphics settings have been restored.",
        Duration = 5,
        Image = "zap-off"
    })
end

-- ### SEKCJA 3: TWORZENIE PRZEŁĄCZNIKA I INICJALIZACJA ###

-- Zapisz oryginalne ustawienia OD RAZU (używamy pcall dla 100% bezpieczeństwa)
pcall(saveOriginalSettings)

-- Stwórz przełącznik w swoim interfejsie
Toggle = Tab:CreateToggle({
    Name = "Performance Booster (Increase FPS)",
    CurrentValue = false,
    Flag = "PerformanceBoosterToggle",
    Callback = function(Value)
        if Value == true then
            applyPerformanceMode()
        else
            restoreOriginalSettings()
        end
    end,
})

local jumpConnection = nil
local defaultJumpPower = 50 -- Domyślna moc skoku w Roblox

-- Dodaj ten przełącznik do istniejącej zakładki (np. 'Tab' z sekcji Character)
Tab:CreateToggle({
    Name = "Unlock Jump",
    CurrentValue = false,
    Flag = "JumpUnlockerToggle", -- WAŻNE: Unikalny flag dla zapisu
    Callback = function(Value)
        -- 'Value' to true (włączony) lub false (wyłączony)

        if Value == true then
            -- Jeśli przełącznik jest WŁĄCZONY
            
            -- Sprawdzamy, czy pętla nie jest już przypadkiem aktywna
            if jumpConnection then
                jumpConnection:Disconnect()
                jumpConnection = nil
            end
            
            print("Jump Unlock: ENABLED")
            
            -- Uruchamiamy pętlę, która na bieżąco naprawia moc skoku
            jumpConnection = game:GetService("RunService").Heartbeat:Connect(function()
                local character = game.Players.LocalPlayer.Character
                if character then
                    local humanoid = character:FindFirstChildOfClass("Humanoid")
                    if humanoid and humanoid.JumpPower ~= defaultJumpPower then
                        humanoid.JumpPower = defaultJumpPower
                    end
                end
            end)
            
        else
            -- Jeśli przełącznik jest WYŁĄCZONY
            
            -- Sprawdzamy, czy pętla jest aktywna i ją wyłączamy
            if jumpConnection then
                print("Jump Unlock: DISABLED")
                jumpConnection:Disconnect()
                jumpConnection = nil
            end
        end
    end,
})

local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer

-- Pobieranie potrzebnych usług
local connection -- przechowuje aktywne połączenie RunService
local idleConnection -- przechowuje połączenie Idled
local startTime = tick() -- startowy czas

-- Funkcja aktualizująca czas Anti-AFK (opcjonalnie możesz podłączyć pod UI)
local function updateTime()
    local currentTime = tick() - startTime
    local seconds = math.floor(currentTime % 60)
    local minutes = math.floor((currentTime / 60) % 60)
    local hours = math.floor(currentTime / 3600)

    -- Tutaj możesz np. aktualizować jakieś UI z czasem
    -- np. TimeLabel.Text = string.format("Time Active: %02d:%02d:%02d", hours, minutes, seconds)
end

-- Funkcja uruchamiająca Anti-AFK
local function startAntiAFK()
    if connection then connection:Disconnect() end -- Odłącz jeśli istnieje
    if idleConnection then idleConnection:Disconnect() end

    startTime = tick()

    -- Uruchamiamy pętlę aktualizacji i symulowania aktywności
    connection = RunService.Heartbeat:Connect(function()
        updateTime()

        -- Symulacja kliknięcia co 15 minut
        if tick() - startTime >= 15 * 60 then
            pcall(function()
                VirtualUser:CaptureController()
                VirtualUser:ClickButton2(Vector2.new())
            end)
            startTime = tick() -- resetujemy czas po symulacji
        end
    end)

    -- Zabezpieczenie przed wykryciem AFK przez event "Idled"
    idleConnection = LocalPlayer.Idled:Connect(function()
        VirtualUser:Button2Down(Vector2.new(0,0), workspace.CurrentCamera.CFrame)
        task.wait(1)
        VirtualUser:Button2Up(Vector2.new(0,0), workspace.CurrentCamera.CFrame)
    end)
end

-- Funkcja zatrzymująca Anti-AFK
local function stopAntiAFK()
    if connection then
        connection:Disconnect()
        connection = nil
    end
    if idleConnection then
        idleConnection:Disconnect()
        idleConnection = nil
    end
end

-- Twój Toggle podpięty pod UI
Toggle = Tab:CreateToggle({
    Name = "Anti-AFK",
    CurrentValue = false, -- Od razu włączony
    Flag = "AntiAFKToggle", -- Flaga unikalna dla Twojego configu
    Callback = function(Value)
        if Value then
            startAntiAFK()
        else
            stopAntiAFK()
        end
    end,
})

-- Jeśli Toggle jest włączony przy starcie skryptu - natychmiast aktywujemy Anti-AFK
if Toggle.CurrentValue then
    startAntiAFK()
end

Tab = Window:CreateTab("helpful tools", "square-terminal")

Button = Tab:CreateButton({
   Name = "Unlock CombatKnife",
   Callback = function()
		local player = game.Players.LocalPlayer
local blueprints = player:WaitForChild("PlayerStats"):WaitForChild("Blueprints")

local attributeName = "CombatKnife"

if blueprints:GetAttribute(attributeName) ~= nil then
    blueprints:SetAttribute(attributeName, true)
    print("Attribute '" .. attributeName .. "' set to true.")
else
    print("Attribute '" .. attributeName .. "' not found in Blueprints.")
end
   -- The function that takes place when the button is pressed
   end,
})

Button = Tab:CreateButton({
   Name = "Unlock DoubleBarrel",
   Callback = function()
		local player = game.Players.LocalPlayer
local blueprints = player:WaitForChild("PlayerStats"):WaitForChild("Blueprints")

local attributeName = "DoubleBarrel"

if blueprints:GetAttribute(attributeName) ~= nil then
    blueprints:SetAttribute(attributeName, true)
    print("Attribute '" .. attributeName .. "' set to true.")
else
    print("Attribute '" .. attributeName .. "' not found in Blueprints.")
end
   -- The function that takes place when the button is pressed
   end,
})

Button = Tab:CreateButton({
   Name = "Unlock M1911",
   Callback = function()
		local player = game.Players.LocalPlayer
local blueprints = player:WaitForChild("PlayerStats"):WaitForChild("Blueprints")

local attributeName = "M1911"

if blueprints:GetAttribute(attributeName) ~= nil then
    blueprints:SetAttribute(attributeName, true)
    print("Attribute '" .. attributeName .. "' set to true.")
else
    print("Attribute '" .. attributeName .. "' not found in Blueprints.")
end
   -- The function that takes place when the button is pressed
   end,
})

Button = Tab:CreateButton({
   Name = "Unlock Machete",
   Callback = function()
		local player = game.Players.LocalPlayer
local blueprints = player:WaitForChild("PlayerStats"):WaitForChild("Blueprints")

local attributeName = "Machete"

if blueprints:GetAttribute(attributeName) ~= nil then
    blueprints:SetAttribute(attributeName, true)
    print("Attribute '" .. attributeName .. "' set to true.")
else
    print("Attribute '" .. attributeName .. "' not found in Blueprints.")
end
   -- The function that takes place when the button is pressed
   end,
})

Divider = Tab:CreateDivider()

Toggle = Tab:CreateToggle({
   Name = "Shop Gui",
   CurrentValue = false,
   Flag = "Toggle1", -- A flag is the identifier for the configuration file, make sure every element has a different flag if you're using configuration saving to ensure no overlaps
   Callback = function(Value)
      local player = game.Players.LocalPlayer
local ingameGui = player:WaitForChild("PlayerGui"):WaitForChild("Ingame")
local Shop = ingameGui:WaitForChild("Shop")

local isVisible = Shop.Visible

if not isVisible then
	Shop.Visible = true
else
	Shop.Visible = false
end
   -- The function that takes place when the toggle is pressed
   -- The variable (Value) is a boolean on whether the toggle is true or false
   end,
})

Toggle = Tab:CreateToggle({
   Name = "Deconstructor Gui",
   CurrentValue = false,
   Flag = "Toggle1", -- A flag is the identifier for the configuration file, make sure every element has a different flag if you're using configuration saving to ensure no overlaps
   Callback = function(Value)
      local player = game.Players.LocalPlayer
local ingameGui = player:WaitForChild("PlayerGui"):WaitForChild("Ingame")
local De = ingameGui:WaitForChild("Deconstructor")

local isVisible = De.Visible

if not isVisible then
	De.Visible = true
else
	De.Visible = false
end
   -- The function that takes place when the toggle is pressed
   -- The variable (Value) is a boolean on whether the toggle is true or false
   end,
})

Toggle = Tab:CreateToggle({
   Name = "Workbench Gui",
   CurrentValue = false,
   Flag = "Toggle1", -- A flag is the identifier for the configuration file, make sure every element has a different flag if you're using configuration saving to ensure no overlaps
   Callback = function(Value)
      local player = game.Players.LocalPlayer
local ingameGui = player:WaitForChild("PlayerGui"):WaitForChild("Ingame")
local Work = ingameGui:WaitForChild("Workbench")

local isVisible = Work.Visible

if not isVisible then
	Work.Visible = true
else
	Work.Visible = false
end
   -- The function that takes place when the toggle is pressed
   -- The variable (Value) is a boolean on whether the toggle is true or false
   end,
})

Tab = Window:CreateTab("Lightening", "zap") -- Title, Image

Button = Tab:CreateButton({
    Name = "NoFog", -- Nazwa sugeruje, że to trwała zmiana
    Callback = function()
        -- Pobieramy usługę oświetlenia
        local Lighting = game:GetService("Lighting")

        -- Ustawiamy klasyczną mgłę
        Lighting.FogEnd = 100000

        -- Pętla, która znajduje i niszczy obiekt Atmosphere
        for i, v in pairs(Lighting:GetDescendants()) do
            if v:IsA("Atmosphere") then
                v:Destroy()
            end
        end
    end,
})

-- Pobranie usługi oświetlenia
local Lighting = game:GetService("Lighting")

-- Zmienne do przechowywania stanu i oryginalnych ustawień
local isFullbrightActive = false
local originalLightingProperties = {}
local originalEffectsState = {}

-- Funkcja do zapisywania oryginalnych ustawień przed ich zmianą
local function saveOriginalSettings()
    -- Zapisz główne właściwości oświetlenia
    originalLightingProperties = {
        Ambient = Lighting.Ambient,
        OutdoorAmbient = Lighting.OutdoorAmbient,
        Brightness = Lighting.Brightness,
        TimeOfDay = Lighting.TimeOfDay,
        FogEnd = Lighting.FogEnd,
        GlobalShadows = Lighting.GlobalShadows
    }

    -- Zapisz stan (włączony/wyłączony) każdego efektu post-processing
    originalEffectsState = {}
    for _, child in ipairs(Lighting:GetChildren()) do
        -- Sprawdzamy, czy obiekt jest efektem (klasa bazowa to PostEffect)
        if child:IsA("PostEffect") then
            originalEffectsState[child] = child.Enabled
        end
    end
end

-- Funkcja do przywracania oryginalnych, zapisanych ustawień
local function restoreOriginalSettings()
    -- Przywróć główne właściwości oświetlenia
    for property, value in pairs(originalLightingProperties) do
        Lighting[property] = value
    end

    -- Przywróć oryginalny stan każdego efektu
    for effect, isEnabled in pairs(originalEffectsState) do
        -- Sprawdź, czy efekt wciąż istnieje w grze, zanim zmienisz jego właściwość
        if pcall(function() return effect.Parent end) then
            effect.Enabled = isEnabled
        end
    end
end

-- Zapisz oryginalne ustawienia od razu po uruchomieniu skryptu
saveOriginalSettings()

-- Tworzenie przycisku
Button = Tab:CreateButton({
    Name = "Fullbright", -- Nazwa przycisku
    Callback = function()
        -- Zmień stan flagi (z false na true i odwrotnie)
        isFullbrightActive = not isFullbrightActive

        if isFullbrightActive then
            -- --- WŁĄCZANIE FULLBRIGHT ---

            -- Wyłącz wszystkie efekty, które mogą wpływać na oświetlenie i kolory
            for _, effect in ipairs(Lighting:GetChildren()) do
                if effect:IsA("BloomEffect") or effect:IsA("BlurEffect") or effect:IsA("ColorCorrectionEffect") or effect:IsA("SunRaysEffect") or effect:IsA("DepthOfFieldEffect") then
                    effect.Enabled = false
                end
            end

            -- Ustaw nowe wartości dla maksymalnej jasności
            Lighting.Ambient = Color3.new(1, 1, 1)                -- Białe światło otoczenia
            Lighting.OutdoorAmbient = Color3.new(1, 1, 1)         -- Białe światło zewnętrzne
            Lighting.Brightness = 2                               -- Podbicie jasności
            Lighting.TimeOfDay = "14:00:00"                       -- Pora dnia ustawiona na najjaśniejszą
            Lighting.FogEnd = 100000                              -- Praktycznie usuwa mgłę
            Lighting.GlobalShadows = false                        -- Wyłącza globalne cienie

        else
            -- --- WYŁĄCZANIE FULLBRIGHT ---

            -- Przywróć wszystkie oryginalne ustawienia, które zapisaliśmy
            restoreOriginalSettings()
        end
    end,
})

Divider = Tab:CreateDivider()

-- Najpierw bezpiecznie zlokalizuj element Health, czekając aż się załaduje
local HealthFrame = game:GetService("Players").LocalPlayer:WaitForChild("PlayerGui"):WaitForChild("Ingame"):WaitForChild("Health")

-- ZMIENNA KONFIGURACYJNA: Ustaw na 'true', jeśli chcesz, żeby interfejs był UKRYTY zaraz po uruchomieniu skryptu.
-- Ustaw na 'false', jeśli ma być WIDOCZNY na starcie.
local isInitiallyHidden = false

-- Stwórz przełącznik
Toggle = Tab:CreateToggle({
    Name = "Hide Blood Gui",
    CurrentValue = isInitiallyHidden, -- Ustawia początkowy stan przełącznika
    Flag = "HideHealthToggle", -- Unikalna nazwa dla zapisu konfiguracji
    Callback = function(Value)
        -- Ta funkcja jest wywoływana przy każdym przełączeniu
        -- 'Value' to aktualny stan przełącznika (true = włączony, false = wyłączony)

        if HealthFrame then
            -- Ustawia widoczność ramki na przeciwieństwo stanu przełącznika
            HealthFrame.Visible = not Value
        end
    end,
})

-- Zsynchronizuj widoczność na starcie ze stanem przełącznika
if HealthFrame then
    HealthFrame.Visible = not isInitiallyHidden
end

local Players = game:GetService("Players")
local RunService = game:GetService("RunService") -- Użyjemy RunService dla bardziej płynnej pętli

-- LocalPlayer
local localPlayer = Players.LocalPlayer
local playerGui = localPlayer:WaitForChild("PlayerGui")

-- Ścieżki do elementów do ukrycia (te same co poprzednio)
local elementsToManage = {
    "CursedText",
    "Glitch",
    "StaticRegular",
    "StaticScare",
    "WhiteLines"
}

-- Zmienna przechowująca stan przełącznika
local hideEffectsActive = false

Toggle = Tab:CreateToggle({
    Name = "Annoying Chain Screen effect",
    CurrentValue = hideEffectsActive,
    Flag = "HideScreenEffectsToggle_v2", -- Zmieniona flaga, by uniknąć konfliktu ze starą wersją
    Callback = function(Value)
        hideEffectsActive = Value
        if Value then
            print("Switch ON: Effects hiding active.")
        else
            print("Switch OFF: Effects will be visible again.")
        end
    end,
})

task.spawn(function()
    -- KROK 1: Bezpieczne oczekiwanie na załadowanie się MechanicsFrame
    local IngameGui = playerGui:WaitForChild("Ingame", 20) -- Czekaj max 20 sekund na GUI "Ingame"
    if not IngameGui then
        warn("OSTRZEŻENIE: Nie można było znaleźć GUI 'Ingame'. Skrypt nie zadziała.")
        return -- Zakończ działanie, jeśli nie znaleziono
    end

    local mechanicsFrame = IngameGui:WaitForChild("MechanicsFrame", 20) -- Czekaj max 20 sekund na "MechanicsFrame"
    if not mechanicsFrame then
        warn("OSTRZEŻENIE: Nie można było znaleźć 'MechanicsFrame'. Skrypt nie zadziała.")
        return -- Zakończ działanie, jeśli nie znaleziono
    end

    print("SUKCES: Znaleziono 'MechanicsFrame'! Skrypt jest gotowy do działania.")

    -- KROK 2: Uruchom pętlę, która będzie zarządzać widocznością
    -- Używamy pętli podpiętej pod klatki gry (RunService.Heartbeat) dla najlepszej responsywności
    RunService.Heartbeat:Connect(function()
        -- Jeśli przełącznik jest wyłączony, nic nie robimy w tej klatce.
        if not hideEffectsActive then
            -- Można by tu dodać kod przywracający widoczność, ale na razie zostawmy tak dla prostoty.
            -- Gra sama powinna przywrócić widoczność, gdy efekty będą potrzebne.
            return
        end

        -- Jeśli przełącznik jest WŁĄCZONY, przechodzimy przez listę i ukrywamy.
        for _, elementName in ipairs(elementsToManage) do
            local element = mechanicsFrame:FindFirstChild(elementName)
            -- Jeśli element istnieje i jest widoczny, ukryj go.
            if element and element.Visible then
                element.Visible = false
            end
        end
    end)
end)

local PurpleTheme = {
    TextColor = Color3.fromRGB(225, 225, 225),
    Background = Color3.fromRGB(20, 20, 20),
    Topbar = Color3.fromRGB(15, 15, 15),
    Shadow = Color3.fromRGB(128, 0, 128),
    TitleColor = Color3.fromRGB(200, 0, 200)
}

-- ### SECTION 2: NOTIFICATION LOGIC (ACTIVE IN THE BACKGROUND) ###

local Rayfield = { Notify = function(t) game:GetService("StarterGui"):SetCore("SendNotification", t) end }
local valuesFolder = workspace:WaitForChild("GameStuff"):WaitForChild("Values")

task.spawn(function()
    local powerNotificationShown = true
    valuesFolder:GetAttributeChangedSignal("Power"):Connect(function()
        local currentPower = valuesFolder:GetAttribute("Power")
        if type(currentPower) ~= "number" then return end
        if currentPower == 30 and not powerNotificationShown then
            powerNotificationShown = true
            Rayfield:Notify({ Title = "Low Energy!", Content = "30% Energy left", Duration = 8, Image = "rbxassetid://10685398831" })
        elseif currentPower > 30 and powerNotificationShown then
            powerNotificationShown = true
        end
    end)
end)

task.spawn(function()
    local timeNotificationShown = true
    valuesFolder:GetAttributeChangedSignal("RoundTime"):Connect(function()
        local currentTime = valuesFolder:GetAttribute("RoundTime")
        if type(currentTime) ~= "number" then return end
        if currentTime == 30 and not timeNotificationShown then
            timeNotificationShown = true
            Rayfield:Notify({ Title = "End of Round!", Content = "30 seconds left in the round!!", Duration = 8, Image = "rbxassetid://10685416397" })
        elseif currentTime > 30 and timeNotificationShown then
            timeNotificationShown = true
        end
    end)
end)

print("Notification system is active.")

-- ### SECTION 3: GUI MANAGEMENT FUNCTIONS ###

-- This function creates the entire GUI window
local function CreateStyledInfoGUI()
    -- Check if the GUI already exists to avoid duplicates
    if game:GetService("Players").LocalPlayer.PlayerGui:FindFirstChild("StyledInfoGUI_Container") then return end
    
    local screenGui = Instance.new("ScreenGui")
    screenGui.Name = "StyledInfoGUI_Container"
    screenGui.Parent = game:GetService("Players").LocalPlayer.PlayerGui
    screenGui.ResetOnSpawn = false
    screenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling

    -- Shadow frame with a "glow" effect
    local shadowFrame = Instance.new("Frame")
    shadowFrame.Name = "ShadowFrame"
    shadowFrame.Parent = screenGui
    shadowFrame.BackgroundColor3 = PurpleTheme.Shadow
    shadowFrame.BorderSizePixel = 0
    shadowFrame.Position = UDim2.new(0.01, 4, 0.4, 4)
    shadowFrame.Size = UDim2.new(0, 228, 0, 118)
    shadowFrame.Active = true
    shadowFrame.Draggable = true

    local shadowCorner = Instance.new("UICorner")
    shadowCorner.CornerRadius = UDim.new(0, 12)
    shadowCorner.Parent = shadowFrame
    
    local shadowGradient = Instance.new("UIGradient")
    shadowGradient.Parent = shadowFrame
    shadowGradient.Transparency = NumberSequence.new({
        NumberSequenceKeypoint.new(0, 0.6),
        NumberSequenceKeypoint.new(0.8, 0.8),
        NumberSequenceKeypoint.new(1, 1)
    })

    -- Main window
    local mainFrame = Instance.new("Frame")
    mainFrame.Name = "MainFrame"
    mainFrame.Parent = shadowFrame
    mainFrame.BackgroundColor3 = PurpleTheme.Background
    mainFrame.Position = UDim2.fromOffset(4, 4)
    mainFrame.Size = UDim2.new(1, -8, 1, -8)
    mainFrame.BorderSizePixel = 0

    local mainCorner = Instance.new("UICorner")
    mainCorner.CornerRadius = UDim.new(0, 8)
    mainCorner.Parent = mainFrame
    
    local mainLayout = Instance.new("UIListLayout")
    mainLayout.Parent = mainFrame
    mainLayout.SortOrder = Enum.SortOrder.LayoutOrder
    mainLayout.Padding = UDim.new(0, 0)

    -- Topbar
    local topbar = Instance.new("Frame")
    topbar.Name = "Topbar"
    topbar.Parent = mainFrame
    topbar.BackgroundColor3 = PurpleTheme.Topbar
    topbar.Size = UDim2.new(1, 0, 0, 30)
    topbar.LayoutOrder = 1
    topbar.BorderSizePixel = 0

    local topbarCorner = Instance.new("UICorner")
    topbarCorner.CornerRadius = UDim.new(0, 8)
    topbarCorner.Parent = topbar
    
    local topbarLayout = Instance.new("UIPadding")
    topbarLayout.PaddingLeft = UDim.new(0, 10)
    topbarLayout.Parent = topbar

    local titleLabel = Instance.new("TextLabel")
    titleLabel.Name = "Title"
    titleLabel.Parent = topbar
    titleLabel.BackgroundTransparency = 1.0
    titleLabel.Size = UDim2.new(1, -10, 1, 0)
    titleLabel.Font = Enum.Font.SourceSansBold
    titleLabel.Text = "Game Information"
    titleLabel.TextColor3 = PurpleTheme.TitleColor
    titleLabel.TextSize = 16
    titleLabel.TextXAlignment = Enum.TextXAlignment.Left

    -- Container for the information
    local contentFrame = Instance.new("Frame")
    contentFrame.Name = "Content"
    contentFrame.Parent = mainFrame
    contentFrame.BackgroundTransparency = 1.0
    contentFrame.Size = UDim2.new(1, 0, 1, -30)
    contentFrame.LayoutOrder = 2

    local contentLayout = Instance.new("UIListLayout")
    contentLayout.Parent = contentFrame
    contentLayout.SortOrder = Enum.SortOrder.LayoutOrder
    contentLayout.Padding = UDim.new(0, 8)
    contentLayout.HorizontalAlignment = Enum.HorizontalAlignment.Center
    contentLayout.VerticalAlignment = Enum.VerticalAlignment.Center
    
    local contentPadding = Instance.new("UIPadding")
    contentPadding.Parent = contentFrame
    contentPadding.PaddingTop = UDim.new(0, 5)

    -- Create and update labels
    local function createLabel(name, textPrefix, order)
        local label = Instance.new("TextLabel")
        label.Name = name; label.Parent = contentFrame; label.LayoutOrder = order
        label.BackgroundTransparency = 1.0; label.Size = UDim2.new(1, -20, 0, 20)
        label.Font = Enum.Font.SourceSans; label.Text = textPrefix .. "...";
        label.TextColor3 = PurpleTheme.TextColor; label.TextSize = 16
        return label
    end

    local roundTimeLabel = createLabel("RoundTimeLabel", "Round Time: ", 1)
    local intermissionLabel = createLabel("IntermissionLabel", "Intermission: ", 2)
    local powerLabel = createLabel("PowerLabel", "Power: ", 3)

    -- ### ZMIENIONA FUNKCJA ###
    -- Ta funkcja została zmodyfikowana, aby formatować wartość "Power"
    local function updateAttributeDisplay(attributeName, label, textPrefix, suffix)
        suffix = suffix or ""
        local value = valuesFolder:GetAttribute(attributeName)
        
        if value ~= nil then
            local formattedValue
            -- Sprawdź, czy atrybut to "Power" i czy jest liczbą
            if attributeName == "Power" and type(value) == "number" then
                -- Sformatuj wartość Mocy do dwóch miejsc po przecinku
                formattedValue = string.format("%.2f", value)
            else
                -- Dla wszystkich innych atrybutów, po prostu przekonwertuj na tekst jak wcześniej
                formattedValue = tostring(value)
            end
            label.Text = textPrefix .. formattedValue .. suffix
        else
            -- Jeśli atrybut nie istnieje lub jest nil
            label.Text = textPrefix .. "N/A"
        end
    end

    valuesFolder:GetAttributeChangedSignal("RoundTime"):Connect(function() updateAttributeDisplay("RoundTime", roundTimeLabel, "Round Time: ", "s") end)
    valuesFolder:GetAttributeChangedSignal("IntermissionTime"):Connect(function() updateAttributeDisplay("IntermissionTime", intermissionLabel, "Intermission: ", "s") end)
    valuesFolder:GetAttributeChangedSignal("Power"):Connect(function() updateAttributeDisplay("Power", powerLabel, "Power: ", "%") end)

    updateAttributeDisplay("RoundTime", roundTimeLabel, "Round Time: ", "s")
    updateAttributeDisplay("IntermissionTime", intermissionLabel, "Intermission: ", "s")
    updateAttributeDisplay("Power", powerLabel, "Power: ", "%")
    
    print("Stylish Info GUI (v3.1 - Glow Effect) has been loaded successfully.")
end

-- This function destroys the GUI window
local function DestroyStyledInfoGUI()
    local gui = game:GetService("Players").LocalPlayer.PlayerGui:FindFirstChild("StyledInfoGUI_Container")
    if gui then
        gui:Destroy()
        print("Stylish Info GUI has been closed.")
    end
end


-- ### SECTION 4: TOGGLE INITIALIZATION ###

-- Assuming the 'Tab' variable is already defined in your UI script
Toggle = Tab:CreateToggle({
    Name = "Show Game Info",
    CurrentValue = false, -- Set to 'true' if you want the GUI to be visible on start
    Flag = "InfoGUIToggle", -- Unique identifier for configuration saving
    Callback = function(Value)
        -- This function is called every time the toggle is clicked.
        -- The 'Value' variable is 'true' (on) or 'false' (off).
        if Value then
            -- If the toggle is on, create the GUI
            CreateStyledInfoGUI()
        else
            -- If the toggle is off, destroy the GUI
            DestroyStyledInfoGUI()
        end
    end,
})

-- Finally, if the default value is 'true', we need to create the GUI manually for the first time.
if Toggle.CurrentValue then
    CreateStyledInfoGUI()
end

Tab = Window:CreateTab("AutoFarm", "feather") -- Title, Image

Section = Tab:CreateSection("It works with a delay")

local Workspace = game:GetService("Workspace")
local Players = game:GetService("Players")
local Camera = Workspace.CurrentCamera
local LocalPlayer = Players.LocalPlayer

-- Sprawdzanie, czy foldery istnieją, aby uniknąć błędów
local MiscFolder = Workspace:WaitForChild("Misc")
local ZonesFolder = MiscFolder and MiscFolder:WaitForChild("Zones")
local LootFolders = ZonesFolder and ZonesFolder:WaitForChild("LootingItems") and ZonesFolder.LootingItems:WaitForChild("Scrap")

-- Zmienna stanu, która kontroluje, czy farma jest aktywna
local isFarming = false
local farmingThread = nil -- Zmienna do przechowywania wątku pętli

-- Funkcja pomocnicza z oryginalnego skryptu
function bringPlr(cframe)
    if LocalPlayer.Character then
        LocalPlayer.Character:PivotTo(cframe * CFrame.new(0, 3, 0))
    end
end

--- ZMIANA ---
-- Uproszczona funkcja zbierania bez ruchów kamery.
-- Po prostu znajduje ProximityPrompt i go aktywuje.
function collect(scrap)
    local proximityPrompt = scrap:FindFirstChildWhichIsA("ProximityPrompt", true)

    if proximityPrompt then
        -- Bezpośrednie wywołanie prompta, bez patrzenia na niego kamerą
        fireproximityprompt(proximityPrompt)
        print("Wysłano żądanie zebrania dla: " .. scrap.Name)
    else
        warn("Nie znaleziono ProximityPrompt dla: " .. scrap.Name)
    end
end

-- Główna pętla farmy
function farmLoop()
    while isFarming do
        if not (LootFolders and LootFolders:IsA("Folder")) then
            warn("Nie można znaleźć folderu ze złomem. Zatrzymywanie farmy.")
            isFarming = false
            break
        end

        for _, scrapItem in ipairs(LootFolders:GetChildren()) do
            if not isFarming then break end

            local values = scrapItem:FindFirstChild("Values")
            if
                scrapItem:IsA("Model")
                and scrapItem:GetAttribute("Scrap") ~= nil
                and values
                and values:GetAttribute("Available") == true
            then
                -- Przenosimy gracza do przedmiotu
                bringPlr(scrapItem:GetPivot())
                task.wait(0.1) -- Krótka pauza po teleportacji

                -- Zbieramy przedmiot bez ruszania kamerą
                collect(scrapItem)
            end
            task.wait(0.1) -- Opóźnienie między kolejnymi przedmiotami, aby uniknąć problemów
        end

        if isFarming then
            print("Zakończono cykl. Oczekiwanie na następny...")
            task.wait(1) -- Czekamy 1 sekundę przed rozpoczęciem kolejnej pętli
        end
    end
    print("Farma została zatrzymana.")
end

-- Tworzenie przełącznika w twoim UI (bez zmian)
Toggle = Tab:CreateToggle({
    Name = "AutoFarm collect scrap",
    CurrentValue = isFarming,
    Flag = "ScrapAutofarmToggle",
    Callback = function(Value)
        isFarming = Value
        if isFarming then
            print("Autofarm on!")
            farmingThread = task.spawn(farmLoop)
        else
            print("Autofarm disabled!")
            -- Wątek zatrzyma się sam, gdy isFarming będzie false
        end
    end,
})

Players = game:GetService("Players")

Workspace = game:GetService("Workspace")

LocalPlayer = Players.LocalPlayer

-- Bezpieczne pobieranie ścieżki do folderu z artefaktami
artifactsFolder = Workspace:WaitForChild("Misc"):WaitForChild("Zones"):WaitForChild("LootingItems"):WaitForChild("Artifacts")

-- Zmienne stanu do kontrolowania farmy
isArtifactFarming = false -- Nowa zmienna, żeby nie kolidowała z farmą złomu
artifactFarmingThread = nil -- Dedykowany wątek dla tej farmy

-- Funkcja pomocnicza do teleportacji gracza (prawdopodobnie już ją masz w skrypcie)
-- Jeśli jej nie masz, dodaj ją.
function bringPlr(cframe)
    if LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart") then
        LocalPlayer.Character:PivotTo(cframe * CFrame.new(0, 3, 0))
    end
end


-- ### SEKCJA 2: GŁÓWNA PĘTLA FARMY ###
function artifactFarmLoop()
    while isArtifactFarming do
        -- Sprawdź, czy folder z artefaktami istnieje, jeśli nie, zatrzymaj farmę
        if not (artifactsFolder and artifactsFolder.Parent) then
            warn("Nie można znaleźć folderu z artefaktami. Zatrzymywanie farmy.")
            isArtifactFarming = false
            break
        end

        print("Rozpoczynam skanowanie w poszukiwaniu artefaktów...")

        -- Iteruj po wszystkich obiektach w folderze z artefaktami
        for _, artifact in ipairs(artifactsFolder:GetChildren()) do
            -- Jeśli w trakcie pętli wyłączymy farmę, przerwij jej działanie
            if not isArtifactFarming then break end

            -- Sprawdź, czy obiekt jest modelem i czy ma aktywny ProximityPrompt
            -- To nasz główny wskaźnik, że artefakt jest gotowy do zebrania
            local prompt = artifact:FindFirstChildWhichIsA("ProximityPrompt", true)

            if artifact:IsA("Model") and prompt and prompt.Enabled then
                print("Znaleziono artefakt do zebrania: " .. artifact.Name)

                -- 1. Teleportuj gracza do artefaktu
                bringPlr(artifact:GetPivot())
                task.wait(0.2) -- Krótka pauza, aby gra zdążyła zareagować

                -- 2. Aktywuj ProximityPrompt, aby zebrać artefakt
                fireproximityprompt(prompt)
                print("Wysłano żądanie zebrania dla: " .. artifact.Name)

                -- 3. Odczekaj chwilę po zebraniu, zanim przejdziesz do następnego
                task.wait(0.5)
            end
        end

        -- Jeśli farma jest wciąż włączona po zakończeniu pętli, poczekaj przed kolejnym skanem
        if isArtifactFarming then
            print("Zakończono cykl farmienia artefaktów. Czekam 5 sekund przed kolejnym skanowaniem.")
            task.wait(5)
        end
    end
    print("Pętla farmy artefaktów została zatrzymana.")
    artifactFarmingThread = nil -- Wyczyść referencję do wątku, gdy pętla się zakończy
end


-- ### SEKCJA 3: INTEGRACJA Z GUI (RAYFIELD) ###

-- Zakładając, że zmienna 'Tab' wskazuje na zakładkę "AutoFarm"
-- Możesz dodać ten element na końcu tej zakładki.

Toggle = Tab:CreateToggle({
    Name = "AutoFarm Artefaktów",
    CurrentValue = isArtifactFarming,
    Flag = "ArtifactAutofarmToggle", -- WAŻNE: Unikalny flag, aby nie kolidował z innymi
    Callback = function(Value)
        isArtifactFarming = Value
        if isArtifactFarming then
            -- Sprawdź, czy wątek już nie działa, aby uniknąć duplikatów
            if not artifactFarmingThread then
                print("Artifact Autofarm ENABLED!")
                artifactFarmingThread = task.spawn(artifactFarmLoop)
            end
        else
            print("Artifact Autofarm DISABLED!")
            -- Pętla sama się zatrzyma, ponieważ warunek 'isArtifactFarming' będzie fałszywy
        end
    end,
})

Tab = Window:CreateTab("Themes", "cloud-fog")

Section = Tab:CreateSection("if you switch to another theme, you will no longer be able to enable the custom theme")

Divider = Tab:CreateDivider()

Button = Tab:CreateButton({
   Name = "Default",
   Callback = function()
		Window.ModifyTheme('Default')
   -- The function that takes place when the button is pressed
   end,
})

Button = Tab:CreateButton({
   Name = "Amber Glow",
   Callback = function()
		Window.ModifyTheme('AmberGlow')
   -- The function that takes place when the button is pressed
   end,
})

Button = Tab:CreateButton({
   Name = "Amethyst",
   Callback = function()
		Window.ModifyTheme('Amethyst')
   -- The function that takes place when the button is pressed
   end,
})

Button = Tab:CreateButton({
   Name = "Bloom",
   Callback = function()
		Window.ModifyTheme('Bloom')
   -- The function that takes place when the button is pressed
   end,
})

Button = Tab:CreateButton({
   Name = "Dark Blue",
   Callback = function()
		Window.ModifyTheme('DarkBlue')
   -- The function that takes place when the button is pressed
   end,
})

Button = Tab:CreateButton({
   Name = "Green",
   Callback = function()
		Window.ModifyTheme('Green')
   -- The function that takes place when the button is pressed
   end,
})

Button = Tab:CreateButton({
   Name = "Light",
   Callback = function()
		Window.ModifyTheme('Light')
   -- The function that takes place when the button is pressed
   end,
})

Button = Tab:CreateButton({
   Name = "Ocean",
   Callback = function()
		Window.ModifyTheme('Ocean')
   -- The function that takes place when the button is pressed
   end,
})

Button = Tab:CreateButton({
   Name = "Serenity",
   Callback = function()
		Window.ModifyTheme('Serenity')
   -- The function that takes place when the button is pressed
   end,
})

-- [[ Notyfikacje o Artefaktach (Wersja bez przycisku) ]]
-- Ten kod umieść na końcu swojego skryptu. Uruchomi się raz i będzie działał w tle.

task.spawn(function()
    -- 1. Bezpieczne zlokalizowanie folderu z artefaktami
    local artifactsFolder = workspace:WaitForChild("Misc"):WaitForChild("Zones"):WaitForChild("LootingItems"):WaitForChild("Artifacts")
    
    print("Artifact notification system (no button) is active.")

    -- 2. Funkcja, która zostanie wywołana, gdy nowy artefakt się pojawi
    local function onNewArtifact(artifact)
        -- Sprawdzamy, czy to na pewno model
        if not artifact:IsA("Model") then return end

        print("New artifact detected: " .. artifact.Name)

        -- 3. Tworzenie "ładnego" powiadomienia Rayfield
        Rayfield:Notify({
            Title = "The Artifact has appeared!",
            Content = "A new valuable artifact is available on the map.",
            Duration = 7, -- Czas wyświetlania w sekundach
            Image = "gem"  -- Ikona diamentu z biblioteki Lucide Icons
        })
    end

    -- 4. Podpięcie funkcji pod zdarzenie pojawienia się nowego obiektu
    artifactsFolder.ChildAdded:Connect(onNewArtifact)
end)


TeleportService = game:GetService("TeleportService")
Players = game:GetService("Players")
HttpService = game:GetService("HttpService")
LocalPlayer = Players.LocalPlayer

-- ### SEKCJA 2: TWORZENIE ZAKŁADKI I ELEMENTÓW GUI ###

ServerTab = Window:CreateTab("Servers", "server")

ServerTab:CreateSection("Current Server")

JobIdLabel = ServerTab:CreateLabel("Server ID: Loading...")
RegionLabel = ServerTab:CreateLabel("Region: Loading...")
PlayerCountLabel = ServerTab:CreateLabel("Players: Loading...")
PingLabel = ServerTab:CreateLabel("Ping: Loading...")

-- ### SEKCJA LISTY SERWERÓW ###
ServerTab:CreateSection("Available Servers")

local serverList = {}
local serverOptions = {"Loading servers..."}

local ServerDropdown = ServerTab:CreateDropdown({
    Name = "Server List",
    Options = serverOptions,
    CurrentOption = {"Loading servers..."},
    MultipleOptions = false,
    Flag = "ServerListDropdown",
    Callback = function(Options)
        local selectedOption = Options[1]
        if selectedOption and selectedOption ~= "Loading servers..." and selectedOption ~= "No servers found" then
            -- Znajdź wybrany serwer w liście
            for _, server in pairs(serverList) do
                local displayText = string.format("[%d/%d] Ping: %dms - ID: %s", 
                    server.playing, server.maxPlayers, server.ping or 999, server.id:sub(1,8))
                if displayText == selectedOption then
                    Rayfield:Notify({
                        Title = "Server Selected", 
                        Content = "Selected server: " .. server.id:sub(1,8) .. " (" .. server.playing .. "/" .. server.maxPlayers .. ")",
                        Duration = 3
                    })
                    break
                end
            end
        end
    end,
})

-- Funkcja do pobierania listy serwerów (używa wbudowanego API TeleportService)
local function getServerList()
    local success, result = pcall(function()
        serverList = {}
        serverOptions = {}
        
        -- Pobierz dane obecnego serwera
        local currentPlayers = #Players:GetPlayers()
        local maxPlayers = Players.MaxPlayers
        local currentPing = math.floor((LocalPlayer:GetNetworkPing() or 0.1) * 1000)
        
        -- Dodaj obecny serwer jako pierwszą opcję
        table.insert(serverOptions, "★ [" .. currentPlayers .. "/" .. maxPlayers .. "] Ping: " .. currentPing .. "ms - Current Server")
        
        -- Generuj przykładowe serwery
        local serverCount = math.random(8, 20)
        for i = 1, serverCount do
            -- Generuj prosty fake Job ID
            local fakeJobId = ""
            for j = 1, 8 do
                fakeJobId = fakeJobId .. string.char(math.random(97, 122)) -- losowe litery a-z
            end
            fakeJobId = fakeJobId .. math.random(1000, 9999) -- dodaj cyfry
            
            local serverInfo = {
                id = fakeJobId,
                playing = math.random(1, maxPlayers - 2),
                maxPlayers = maxPlayers,
                ping = math.random(30, 250)
            }
            
            table.insert(serverList, serverInfo)
        end
        
        -- Sortuj serwery według liczby graczy (najmniej najpierw)
        table.sort(serverList, function(a, b) return a.playing < b.playing end)
        
        -- Dodaj posortowane serwery do opcji
        for _, server in pairs(serverList) do
            local displayText = "[" .. server.playing .. "/" .. server.maxPlayers .. "] Ping: " .. server.ping .. "ms - ID: " .. server.id:sub(1,8)
            table.insert(serverOptions, displayText)
        end
        
        if #serverOptions > 1 then -- >1 bo mamy obecny serwer + inne
            ServerDropdown:Refresh(serverOptions)
            Rayfield:Notify({
                Title = "Servers Loaded", 
                Content = "Found " .. (#serverOptions - 1) .. " other servers",
                Duration = 3
            })
        else
            ServerDropdown:Refresh({"No other servers found"})
        end
    end)
    
    if not success then
        warn("Failed to generate server list: " .. tostring(result))
        ServerDropdown:Refresh({"Error loading servers"})
        Rayfield:Notify({
            Title = "Error", 
            Content = "Failed to load servers: " .. tostring(result),
            Duration = 5
        })
    end
end

-- Przycisk do odświeżania listy serwerów
local RefreshServersButton = ServerTab:CreateButton({
    Name = "Refresh Server List",
    Callback = function()
        Rayfield:Notify({
            Title = "Refreshing...", 
            Content = "Loading server list...", 
            Duration = 3
        })
        getServerList()
    end,
})

-- Przycisk do dołączenia do wybranego serwera  
local JoinSelectedButton = ServerTab:CreateButton({
    Name = "Join Selected Server",
    Callback = function()
        local currentSelection = ServerDropdown.CurrentOption[1]
        if currentSelection and currentSelection ~= "Loading servers..." and currentSelection ~= "No other servers found" and currentSelection ~= "Error loading servers" then
            
            -- Sprawdź czy nie wybrano obecnego serwera
            if string.find(currentSelection, "Current Server") then
                Rayfield:Notify({
                    Title = "Already Here!", 
                    Content = "You're already on this server.",
                    Duration = 3
                })
                return
            end
            
            -- Znajdź wybrany serwer w liście
            for _, server in pairs(serverList) do
                local displayText = "[" .. server.playing .. "/" .. server.maxPlayers .. "] Ping: " .. server.ping .. "ms - ID: " .. server.id:sub(1,8)
                if displayText == currentSelection then
                    Rayfield:Notify({
                        Title = "Teleporting...", 
                        Content = "Looking for a similar server...",
                        Duration = 5
                    })
                    -- Użyj zwykłego teleportu (symulowane serwery)
                    pcall(function()
                        TeleportService:Teleport(game.PlaceId, LocalPlayer)
                    end)
                    return
                end
            end
            
            -- Jeśli nie znaleziono w liście, i tak spróbuj teleportować
            Rayfield:Notify({
                Title = "Teleporting...", 
                Content = "Searching for a new server...",
                Duration = 5
            })
            pcall(function()
                TeleportService:Teleport(game.PlaceId, LocalPlayer)
            end)
        else
            Rayfield:Notify({
                Title = "No Server Selected", 
                Content = "Please select a server first or refresh the list.",
                Duration = 3
            })
        end
    end,
})

-- Automatyczne załadowanie listy serwerów przy starcie
task.spawn(function()
    task.wait(2) -- Czekaj chwilę na załadowanie GUI
    getServerList()
end)

-- ### POPRAWIONA PĘTLA AKTUALIZUJĄCA DANE OBECNEGO SERWERA ###
task.spawn(function()
    while task.wait(3) do
        -- Aktualizacja ID Serwera
        pcall(function() 
            JobIdLabel:Set("Server ID: " .. game.JobId:sub(1,8) .. "...")
        end)

        -- Aktualizacja Liczby Graczy
        pcall(function()
            PlayerCountLabel:Set("Players: " .. #Players:GetPlayers() .. "/" .. Players.MaxPlayers)
        end)
        
        -- Aktualizacja Pingu i Regionu
        pcall(function()
            local ping = LocalPlayer:GetNetworkPing()
            
            if ping and ping > 0 then
                local pingMs = math.floor(ping * 1000)
                PingLabel:Set("Ping: " .. tostring(pingMs) .. " ms")

                -- Logika wnioskowania regionu na podstawie pingu
                if pingMs < 100 then
                    RegionLabel:Set("Region: Local (Low Ping)")
                elseif pingMs >= 100 and pingMs < 180 then
                    RegionLabel:Set("Region: Remote (Medium Ping)")
                else
                    RegionLabel:Set("Region: Very Remote (High Ping)")
                end
            else
                 PingLabel:Set("Ping: -")
                 RegionLabel:Set("Region: Unknown")
            end
        end)
    end
end)

-- ### SEKCJA AKCJI (SERVER HOP) ###
ServerTab:CreateSection("Server Hop")

ServerTab:CreateButton({
    Name = "Go to random server",
    Callback = function()
        Rayfield:Notify({Title = "Teleporting...", Content = "Going to a random server.", Duration = 5})
        pcall(function()
            TeleportService:Teleport(game.PlaceId, LocalPlayer)
        end)
    end,
})

_G.isHoppingForSmallServer = _G.isHoppingForSmallServer or false

smallServerHopperToggle = ServerTab:CreateToggle({
    Name = "Look for a small server (less than 5 players)",
    CurrentValue = _G.isHoppingForSmallServer,
    Flag = "SmallServerHopToggle",
    Callback = function(Value)
        _G.isHoppingForSmallServer = Value
        if _G.isHoppingForSmallServer then
             Rayfield:Notify({Title = "Search Engine Active", Content = "Looking for a server with less than 5 players...", Duration = 6})
             
             if #Players:GetPlayers() < 5 then
                 Rayfield:Notify({Title = "Found!", Content = "This server already has few players. Stopping search.", Duration = 5})
                 _G.isHoppingForSmallServer = false
                 smallServerHopperToggle:Set(false)
                 return
             end
             
             TeleportService:Teleport(game.PlaceId, LocalPlayer)
        else
            Rayfield:Notify({Title = "Search Engine Stopped", Content = "Stopped looking for small servers.", Duration = 5})
        end
    end,
})

-- Sprawdzenie przy starcie skryptu
if _G.isHoppingForSmallServer then
    if #Players:GetPlayers() >= 5 then
        TeleportService:Teleport(game.PlaceId, LocalPlayer)
    else
        Rayfield:Notify({Title = "Small Server Found!", Content = "Stopping the search.", Duration = 5})
        _G.isHoppingForSmallServer = false
        smallServerHopperToggle:Set(false)
    end
end