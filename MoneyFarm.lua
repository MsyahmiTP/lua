-- Configuration Table
local Config = {
    Tools = {
        Ultimate = "Ultimate Hack Tool",
        Pro = "Pro Hack Tool",
        Basic = "Basic Hack Tool"
    },
    MoneyThresholds = {
        Ultimate = 350,
        Pro = 150,
        Basic = 50
    },
    MovementIncrement = 1,
    TargetSizeThreshold = 0.06
}

-- Constants for Magic Numbers
local Constants = {
    VerticalOffset = vector.create(0, -10, 0)
}

-- Flags for Script Behavior
local Flags = {
    StaminaFarm = true
}

-- Services Initialization
local Services = setmetatable({}, {
    __index = function(self, key)
        local Service = rawget(self, key) or pcall(game.FindService, game, key) and game:GetService(key) or Instance.new(key)
        rawset(self, key, Service)
        return rawget(self, key)
    end
})

local Players = Services.Players
local VirtualInputManager = Services.VirtualInputManager

local Client = Players.LocalPlayer
local PlayerGui = Client:WaitForChild('PlayerGui')

-- Utility Functions
local function GetChar(player)
    return player and player.Character
end

local function GetRoot(char)
    return char and char:FindFirstChild('HumanoidRootPart')
end

local function GetHum(char)
    return char and char:FindFirstChildWhichIsA('Humanoid')
end

local function GetATM()
    local Dist, Closest = math.huge, {}
    local Char = GetChar(Client)
    local Root = GetRoot(Char)

    if Char and Root then
        for _, v in pairs(workspace.Map.Props:GetChildren()) do
            if v.Name ~= 'ATM' or v:GetAttribute('disabled') then continue end
            if v.hacker.Value then continue end

            for _, v2 in pairs(v:GetChildren()) do
                local ProximityPrompt = v2:FindFirstChildWhichIsA('ProximityPrompt')
                if not ProximityPrompt then continue end

                local Magnitude = (v2:GetPivot().Position - Root.Position).Magnitude
                if Magnitude < Dist then
                    Closest = {v, ProximityPrompt}
                    Dist = Magnitude
                end
            end
        end
    end

    if not Closest then
        warn("No valid ATM found.")
        return nil
    end

    return unpack(Closest)
end

local function MoveTo(pos, increment)
    local Char = GetChar(Client)
    local Root = GetRoot(Char)
    if not Char or not Root then return end

    local Increment = increment or Config.MovementIncrement
    local Distance = (pos - Root.Position).Magnitude
    local Direction = (pos - Root.Position).Unit
    local CurrentPos = Root.Position

    while Distance > Increment do
        CurrentPos += Direction * Increment
        Root.CFrame = CFrame.new(CurrentPos)
        Root.AssemblyLinearVelocity = Vector3.zero

        task.wait()
        Distance = (pos - CurrentPos).Magnitude
    end

    Root.CFrame = CFrame.new(pos)
end

local function SmartGet(inst, objPath)
    if not inst then return end

    local Objects = objPath:split('.')
    local Current = inst

    for _, v in ipairs(Objects) do
        if not Current then return end
        Current = Current:FindFirstChild(v)
    end

    return Current
end

local function HasTool(toolName)
    local ItemsScrollingFrame = SmartGet(PlayerGui, 'Items.ItemsHolder.ItemsScrollingFrame')
    if ItemsScrollingFrame then
        for _, v in pairs(ItemsScrollingFrame:GetChildren()) do
            if v:IsA('ImageButton') and v.ItemName.Text == toolName then
                return true
            end
        end
    else
        local InventoryButton = SmartGet(PlayerGui, 'Sidebar.SidebarSlider.SidebarHolder.SidebarHolderSlider.Holder.InventoryButton')
        if InventoryButton then
            for _, connection in pairs(getconnections(InventoryButton.MouseButton1Click)) do
                connection:Function()
            end
        end
    end
end

local function BuyTool(toolType)
    local ConsumableBuyButton = SmartGet(toolType, 'ConsumableBuyButton')
    if ConsumableBuyButton then
        for _, connection in pairs(getconnections(ConsumableBuyButton.MouseButton1Click)) do
            connection:Function()
        end
    end
end

-- Main Loop
shared.afy = not shared.afy
print(shared.afy)

while shared.afy and task.wait() do
    local Char = GetChar(Client)
    if not Char then
        warn("Character not found. Exiting loop.")
        break
    end

    local Hum = GetHum(Char)
    local Root = GetRoot(Char)

    if Hum and Root then
        Hum:SetStateEnabled(Enum.HumanoidStateType.Seated, false)
        Root.AssemblyLinearVelocity = Vector3.new(0, 0.5, 0)

        if Flags.StaminaFarm then
            local ConsumableShopZone = workspace.ConsumableShopZone_Illegal
            local ProximityPrompt = ConsumableShopZone:FindFirstChildOfClass('ProximityPrompt')

            if ProximityPrompt then
                local Distance = (ConsumableShopZone:GetPivot().Position - Root.Position).Magnitude
                if Distance <= ProximityPrompt.MaxActivationDistance then
                    fireproximityprompt(ProximityPrompt)
                else
                    MoveTo(ConsumableShopZone:GetPivot().Position + Constants.VerticalOffset, Config.MovementIncrement)
                    fireproximityprompt(ProximityPrompt)
                end
            else
                warn("Stamina farm zone or proximity prompt not found.")
            end
        end
    end

    -- Handle ATM Interaction
    local ATMInteractionComplete = false
    local ATM, ATM_Prox = GetATM()
    if ATM and ATM_Prox and not ATMInteractionComplete then
        MoveTo(ATM:GetPivot().Position + Constants.VerticalOffset, Config.MovementIncrement)
        fireproximityprompt(ATM_Prox)

        local ATMHolder = SmartGet(PlayerGui, 'ATM.ATMHolder')
        if ATMHolder and ATMHolder.Visible then
            ATMInteractionComplete = true
        end
    elseif ATMInteractionComplete then
        -- Play Minigame
        local function PlayMinigame()
            local SliderMinigameFrame = SmartGet(PlayerGui, 'SliderMinigame.SliderMinigameFrame')
            local Bar = SmartGet(SliderMinigameFrame, 'Bar')
            local Needle = SmartGet(Bar, 'Needle')
            local Target = SmartGet(Bar, 'Target')

            if SliderMinigameFrame and SliderMinigameFrame.Visible and Bar and Needle and Target then
                repeat
                    task.wait()

                    local NeedleX = Needle.Position.X.Scale
                    local TargetX = Target.Position.X.Scale
                    local TargetSize = Target.Size.X.Scale / 2

                    if NeedleX >= (TargetX - TargetSize) and NeedleX <= (TargetX + TargetSize) then
                        VirtualInputManager:SendMouseButtonEvent(0, 0, 0, true, nil, 0)
                        VirtualInputManager:SendMouseButtonEvent(0, 0, 0, false, nil, 0)

                        if TargetSize <= Config.TargetSizeThreshold then
                            task.wait(0.2)
                        end
                    end
                until not SliderMinigameFrame.Visible
            else
                warn("Minigame UI not found or not visible.")
            end
        end

        PlayMinigame()
    end

    -- Handle Tool Purchases
    local PurchasedTools = {}

    local function BuyTool(toolName)
        if PurchasedTools[toolName] then
            warn(toolName .. " already purchased.")
            return
        end

        local MoneyTextLabel = SmartGet(PlayerGui, 'TopRightHud.Holder.Frame.MoneyTextLabel')
        local MoneyText = MoneyTextLabel and MoneyTextLabel.Text
        local MoneyNumber = tonumber(MoneyText:match("%d+"))

        if MoneyNumber and MoneyNumber >= Config.MoneyThresholds[toolName] then
            local ConsumableOptionsScrollingFrame = SmartGet(PlayerGui, 'ConsumableBuy.ConsumableOptionsHolder.ConsumableOptionsScrollingFrame')
            for _, v in pairs(ConsumableOptionsScrollingFrame:GetChildren()) do
                local Options = SmartGet(v, 'Item.Options')
                local ConsumableName = SmartGet(Options, 'ConsumableName')
                local BuyButton = SmartGet(Options, 'ConsumableBuyButton')

                if ConsumableName and ConsumableName.Text == toolName and BuyButton and BuyButton.Visible then
                    for _, connection in pairs(getconnections(BuyButton.MouseButton1Click)) do
                        connection:Function()
                    end

                    PurchasedTools[toolName] = true
                    warn(toolName .. " purchased successfully.")
                    return
                end
            end
        else
            warn("Not enough money to purchase " .. toolName)
        end
    end

    if not (HasTool(Config.Tools.Ultimate) or HasTool(Config.Tools.Pro) or HasTool(Config.Tools.Basic)) then
        BuyTool(Config.Tools.Ultimate)
        BuyTool(Config.Tools.Pro)
        BuyTool(Config.Tools.Basic)
    end
end
