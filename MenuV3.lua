local visible = false
local activeTab = 4
local selRow = 1
local toggles = {["تدمير"] = false, ["تدمير 2"] = false}
local tabs = {"الشخصية", "السيرفر", "الاسلحة", "المودز", "vrp", "cfw"}
local tabOpts = {
    [1] = {},
    [2] = {},
    [3] = {},
    [4] = {"تدمير", "تدمير 2"},
    [5] = {},
    [6] = {"انعاش"}
}
local mW = 0.28
local mH = 0.38
local hH = 0.07
local tH = 0.04
local fH = 0.03
local inputActive = false
local inputLabel = ""

local function DrawTxt(text, x, y, font, scale, r, g, b, a, center)
    SetTextFont(font)
    SetTextScale(0.0, scale)
    SetTextColour(r, g, b, a)
    SetTextCentre(center)
    BeginTextCommandDisplayText("STRING")
    AddTextComponentSubstringPlayerName(text)
    EndTextCommandDisplayText(x, y)
end

local function ShowInput(title)
    inputActive = true
    inputLabel = title
    DisplayOnscreenKeyboard(1, "FMMC_KEY_TIP8", title, "", "", "", "", 6)
end

local function HandleAction(name)
    if toggles[name] ~= nil then
        toggles[name] = not toggles[name]
        return
    end
    if name == "انعاش" then
        ShowInput("Enter Player ID to revive:")
    end
end

Citizen.CreateThread(function()
    while true do
        Citizen.Wait(0)

        if IsControlJustPressed(0, 212) or IsControlJustPressed(0, 167) then
            visible = not visible
            if not visible then
                inputActive = false
            end
            Citizen.Wait(200)
        end

        if inputActive then
            local status = UpdateOnscreenKeyboard()
            if status == 1 then
                local result = GetOnscreenKeyboardResult()
                if result and tonumber(result) then
                    TriggerServerEvent('hospital:server:RevivePlayer', tonumber(result))
                end
                inputActive = false
            elseif status == 2 then
                inputActive = false
            end
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
            SetTextScale(0.0, 0.28)
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
                if i == activeTab then
                    DrawRect(tx, tY + tH/2 - 0.002, tW - 0.008, 0.004, 0, 0, 0, 255)
                end
            end

            local opts = tabOpts[activeTab] or {}
            local oph = 0.038
            local ch = #opts * oph
            local cY = cTop + ch/2

            for i = 1, #opts do
                local ry = cTop + (i - 1) * oph + oph/2
                local opt = opts[i]
                local isToggle = toggles[opt] ~= nil
                local tgX = cx - mW/2 + 0.055
                local txtX = cx + mW/2 - 0.04

                if i == selRow then
                    DrawRect(cx, ry, mW - 0.01, oph - 0.004, 230, 230, 230, 255)
                end

                if isToggle then
                    SetTextFont(0)
                    SetTextScale(0.0, 0.3)
                    SetTextColour(0, 0, 0, 255)
                    SetTextCentre(true)
                    BeginTextCommandDisplayText("STRING")
                    AddTextComponentSubstringPlayerName(opt)
                    EndTextCommandDisplayText(txtX, ry - 0.01)

                    if toggles[opt] then
                        DrawRect(tgX, ry + 0.002, 0.03, 0.016, 0, 180, 0, 255)
                        DrawRect(tgX + 0.01, ry + 0.002, 0.014, 0.02, 255, 255, 255, 255)
                    else
                        DrawRect(tgX, ry + 0.002, 0.03, 0.016, 160, 160, 160, 255)
                        DrawRect(tgX - 0.01, ry + 0.002, 0.014, 0.02, 210, 210, 210, 255)
                    end
                else
                    SetTextFont(0)
                    SetTextScale(0.0, 0.3)
                    SetTextColour(0, 0, 0, 255)
                    SetTextCentre(true)
                    BeginTextCommandDisplayText("STRING")
                    AddTextComponentSubstringPlayerName(opt)
                    EndTextCommandDisplayText(cx, ry - 0.01)
                end
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

            if not inputActive then
                if IsControlJustPressed(0, 172) then
                    selRow = math.max(1, selRow - 1)
                    Citizen.Wait(180)
                end
                if IsControlJustPressed(0, 173) then
                    selRow = math.min(#opts, selRow + 1)
                    Citizen.Wait(180)
                end
                if IsControlJustPressed(0, 174) then
                    activeTab = math.max(1, activeTab - 1)
                    selRow = 1
                    Citizen.Wait(180)
                end
                if IsControlJustPressed(0, 175) then
                    activeTab = math.min(#tabs, activeTab + 1)
                    selRow = 1
                    Citizen.Wait(180)
                end
                if IsControlJustPressed(0, 191) then
                    if #opts > 0 and opts[selRow] then
                        HandleAction(opts[selRow])
                    end
                    Citizen.Wait(180)
                end
            end

            local mx = GetControlNormal(0, 239)
            local my = GetControlNormal(0, 240)
            if IsControlJustPressed(0, 237) and mx > 0 and my > 0 then
                for i = 1, #tabs do
                    local tx = cx - mW/2 + tW * (i - 1) + tW/2
                    if mx > tx - tW/2 and mx < tx + tW/2 and my > tY - tH/2 and my < tY + tH/2 then
                        activeTab = i
                        selRow = 1
                        Citizen.Wait(180)
                        break
                    end
                end
                for i = 1, #opts do
                    local ry = cTop + (i - 1) * oph + oph/2
                    if mx > cx - mW/2 and mx < cx + mW/2 and my > ry - oph/2 and my < ry + oph/2 then
                        selRow = i
                        if IsControlJustPressed(0, 237) then
                            HandleAction(opts[i])
                        end
                        Citizen.Wait(180)
                        break
                    end
                end
            end
        end
    end
end)
