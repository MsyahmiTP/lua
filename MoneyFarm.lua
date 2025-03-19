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

local Constants = {
    VerticalOffset = vector.create(0, -10, 0)
}

local function BuyTool(toolType)
    local ConsumableBuyButton = SmartGet(toolType, 'ConsumableBuyButton')
    if ConsumableBuyButton then
        for _, connection in getconnections(ConsumableBuyButton.MouseButton1Click) do
            connection:Function()
        end
    end
end

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
        Root.AssemblyLinearVelocity = vector.create(0, 0.5, 0)

        if Flags.StaminaFarm then
            fireproximityprompt(workspace.ConsumableShopZone_Illegal.ProximityPrompt)
        end
    end

    local ATM, ATM_Prox = GetATM()
    if ATM and ATM_Prox then
        MoveTo(ATM:GetPivot().Position + Constants.VerticalOffset, Config.MovementIncrement)
        fireproximityprompt(ATM_Prox)
    end
end
