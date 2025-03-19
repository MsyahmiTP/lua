shared.afy = not shared.afy
print(shared.afy)

while shared.afy and task.wait() do
    -- Cek apakah slider minigame sedang aktif
    local SliderMinigameFrame = SmartGet(PlayerGui, 'SliderMinigame.SliderMinigameFrame')
    local Bar = SmartGet(SliderMinigameFrame, 'Bar')
    local Needle = SmartGet(Bar, 'Needle')
    local Target = SmartGet(Bar, 'Target')

    if (SliderMinigameFrame and SliderMinigameFrame.Visible and Bar and Needle and Target) then
        -- Dapatkan posisi jarum dan target
        local NeedleX = Needle.Position.X.Scale
        local TargetX = Target.Position.X.Scale
        local TargetSize = Target.Size.X.Scale / 2

        -- Jika jarum berada dalam rentang target, klik untuk menyelesaikan minigame
        if NeedleX >= (TargetX - TargetSize) and NeedleX <= (TargetX + TargetSize) then
            VirtualInputManager:SendMouseButtonEvent(0, 0, 0, true, game, 0)
            VirtualInputManager:SendMouseButtonEvent(0, 0, 0, false, game, 0)

            -- Tunggu sebentar jika target sangat kecil
            if (TargetSize <= 0.06) then
                task.wait(0.2)
            end
        end
    end
end
