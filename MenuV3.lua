local visible = false
local tab = 4
local toggles = {false, false}
local sel = 0
local tabs = {"الشخصية", "السيرفر", "الاسلحة", "المودز", "vrp", "cfw"}
local mW = 0.28
local mH = 0.35
local hH = 0.07
local tH = 0.04
local fH = 0.03

Citizen.CreateThread(function()
    while true do
        Citizen.Wait(0)

        if IsControlJustPressed(0, 212) or IsControlJustPressed(0, 167) then
            visible = not visible
            Citizen.Wait(200)
        end

        if visible then
            local cx, cy = 0.5, 0.5
            local hT = cy - mH/2
            local hY = hT + hH/2
            local tY = hT + hH + tH/2
            local cTop = tY + tH/2
            local fY = cy + mH/2 - fH/2
            local tW = mW / #tabs

            DrawRect(cx, cy, mW, mH, 255, 255, 255, 255)

            DrawRect(cx, hY, mW, hH, 240, 240, 240, 255)

            for r = 0, 4 do
                for c = 0, 12 do
                    local px = cx - mW/2 + 0.012 + c * 0.028
                    local py = hT + 0.008 + r * 0.013 + math.sin((c + r) * 0.8) * 0.003
                    DrawRect(px + 0.014, py, 0.025, 0.001, 180, 180, 180, 80)
                end
            end

            SetTextFont(7)
            SetTextScale(0.0, 0.45)
            SetTextColour(0, 0, 0, 255)
            SetTextCentre(true)
            BeginTextCommandDisplayText("STRING")
            AddTextComponentSubstringPlayerName("Five")
            EndTextCommandDisplayText(cx - 0.02, hT + 0.012)

            SetTextColour(255, 0, 0, 255)
            BeginTextCommandDisplayText("STRING")
            AddTextComponentSubstringPlayerName("M")
            EndTextCommandDisplayText(cx + 0.024, hT + 0.012)

            DrawRect(cx, hT + 0.048, 0.075, 0.02, 255, 255, 255, 255)
            SetTextScale(0.0, 0.3)
            SetTextColour(0, 0, 0, 255)
            SetTextCentre(true)
            BeginTextCommandDisplayText("STRING")
            AddTextComponentSubstringPlayerName("Scandlas")
            EndTextCommandDisplayText(cx, hT + 0.048)

            for i = 1, #tabs do
                local tx = cx - mW/2 + tW * (i - 1) + tW/2
                DrawRect(tx, tY, tW, tH, 248, 248, 248, 255)
                SetTextFont(0)
                SetTextScale(0.0, 0.26)
                SetTextColour(40, 40, 40, 255)
                SetTextCentre(true)
                BeginTextCommandDisplayText("STRING")
                AddTextComponentSubstringPlayerName(tabs[i])
                EndTextCommandDisplayText(tx, tY - 0.003)
                if i == tab then
                    DrawRect(tx, tY + tH/2 - 0.002, tW - 0.008, 0.004, 0, 0, 0, 255)
                end
            end

            local oy1 = cTop + 0.03
            local tgX = cx - mW/2 + 0.055
            local txtX = cx + mW/2 - 0.04

            SetTextFont(0)
            SetTextScale(0.0, 0.32)
            SetTextColour(0, 0, 0, 255)
            SetTextCentre(true)
            BeginTextCommandDisplayText("STRING")
            AddTextComponentSubstringPlayerName("تدمير")
            EndTextCommandDisplayText(txtX, oy1)

            if toggles[1] then
                DrawRect(tgX, oy1 + 0.008, 0.03, 0.016, 0, 180, 0, 255)
                DrawRect(tgX + 0.01, oy1 + 0.008, 0.014, 0.02, 255, 255, 255, 255)
            else
                DrawRect(tgX, oy1 + 0.008, 0.03, 0.016, 160, 160, 160, 255)
                DrawRect(tgX - 0.01, oy1 + 0.008, 0.014, 0.02, 210, 210, 210, 255)
            end

            local oy2 = oy1 + 0.045

            SetTextFont(0)
            SetTextScale(0.0, 0.32)
            SetTextColour(0, 0, 0, 255)
            SetTextCentre(true)
            BeginTextCommandDisplayText("STRING")
            AddTextComponentSubstringPlayerName("تدمير 2")
            EndTextCommandDisplayText(txtX, oy2)

            if toggles[2] then
                DrawRect(tgX, oy2 + 0.008, 0.03, 0.016, 0, 180, 0, 255)
                DrawRect(tgX + 0.01, oy2 + 0.008, 0.014, 0.02, 255, 255, 255, 255)
            else
                DrawRect(tgX, oy2 + 0.008, 0.03, 0.016, 160, 160, 160, 255)
                DrawRect(tgX - 0.01, oy2 + 0.008, 0.014, 0.02, 210, 210, 210, 255)
            end

            DrawRect(cx, fY, mW, fH, 230, 230, 230, 255)

            SetTextFont(0)
            SetTextScale(0.0, 0.2)
            SetTextColour(0, 0, 0, 180)
            SetTextCentre(false)
            BeginTextCommandDisplayText("STRING")
            AddTextComponentSubstringPlayerName("(1/2)")
            EndTextCommandDisplayText(cx - mW/2 + 0.018, fY - 0.003)

            SetTextCentre(true)
            BeginTextCommandDisplayText("STRING")
            AddTextComponentSubstringPlayerName("FiveM Scandlas v1.0 | Discord.gg/pk8av1eUAS")
            EndTextCommandDisplayText(cx + mW/2 - 0.018, fY - 0.003)

            if IsControlJustPressed(0, 172) then sel = math.max(0, sel - 1); Citizen.Wait(180) end
            if IsControlJustPressed(0, 173) then sel = math.min(1, sel + 1); Citizen.Wait(180) end
            if IsControlJustPressed(0, 174) then tab = math.max(1, tab - 1); Citizen.Wait(180) end
            if IsControlJustPressed(0, 175) then tab = math.min(#tabs, tab + 1); Citizen.Wait(180) end
            if IsControlJustPressed(0, 191) then toggles[sel + 1] = not toggles[sel + 1]; Citizen.Wait(180) end

            local mx = GetControlNormal(0, 239)
            local my = GetControlNormal(0, 240)
            if IsControlJustPressed(0, 237) and mx > 0 and my > 0 then
                for i = 1, #tabs do
                    local tx = cx - mW/2 + tW * (i - 1) + tW/2
                    if mx > tx - tW/2 and mx < tx + tW/2 and my > tY - tH/2 and my < tY + tH/2 then
                        tab = i; Citizen.Wait(180); break
                    end
                end
                if mx > tgX - 0.015 and mx < tgX + 0.015 and my > oy1 + 0.008 - 0.01 and my < oy1 + 0.008 + 0.01 then
                    toggles[1] = not toggles[1]; Citizen.Wait(180)
                end
                if mx > tgX - 0.015 and mx < tgX + 0.015 and my > oy2 + 0.008 - 0.01 and my < oy2 + 0.008 + 0.01 then
                    toggles[2] = not toggles[2]; Citizen.Wait(180)
                end
            end
        end
    end
end)
