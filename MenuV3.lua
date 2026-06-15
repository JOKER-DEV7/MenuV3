local visible = false
local activeTab = 6
local selRow = 2
local toggles = {["تدمير"] = false, ["تدمير 2"] = false}
local tabs = {"السيرفر", "الاسلحة", "المدمر", "vrp", "Cfw"}
local tabOpts = {
    [1] = {},
    [2] = {"الاسلحة"},
    [3] = {"تدمير", "تدمير 2"},
    [4] = {},
    [5] = {"الشخصيه", "الفلوس", "رسبنه سيارات", "رسبون"}
}

local mW = 0.23
local mH = 0.45
local hH = 0.09
local tH = 0.045
local fH = 0.035
local inputActive = false
local inputLabel = ""

local function DrawTxt(text, x, y, font, scale, r, g, b, a, center, right)
    SetTextFont(font)
    SetTextScale(0.0, scale)
    SetTextColour(r, g, b, a)
    if center then
        SetTextCentre(true)
    elseif right then
        SetTextRightJustify(true)
        SetTextWrap(0.0, x)
    end
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

        if IsControlJustPressed(0, 344) then
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
            cx, cy = 0.15, 0.45
            local hT = cy - mH/2
            local hY = hT + hH/2
            local tY = hT + hH + tH/2
            local cTop = tY + tH/2
            local fY = cy + mH/2 - fH/2
            local tW = mW / #tabs

            ShowCursorThisFrame()
            DisableControlAction(0, 1, true)
            DisableControlAction(0, 2, true)
            DisableControlAction(0, 24, true)
            DisableControlAction(0, 25, true)

            DrawRect(cx, cy, mW + 0.004, mH + 0.004, 230, 60, 30, 200)
            DrawRect(cx, cy, mW, mH, 20, 10, 10, 240)

            DrawRect(cx, hY, mW, hH, 15, 5, 5, 255)
            DrawTxt("IA3X", cx, hY - 0.025, 4, 0.9, 200, 30, 30, 255, true, false)

            for i = 1, #tabs do
                local tx = cx - mW/2 + tW * (i - 1) + tW/2
                
                if i == activeTab then
                    DrawRect(tx, tY, tW, tH, 180, 40, 20, 200)
                    DrawTxt(tabs[i], tx, tY - 0.012, 0, 0.28, 255, 255, 255, 255, true, false)
                else
                    DrawRect(tx, tY, tW, tH, 30, 15, 15, 255)
                    DrawTxt(tabs[i], tx, tY - 0.012, 0, 0.28, 180, 180, 180, 255, true, false)
                end
            end

            local opts = tabOpts[activeTab] or {}
            local oph = 0.045

            for i = 1, #opts do
                local ry = cTop + (i - 1) * oph + oph/2
                local opt = opts[i]
                
                if i == selRow then
                    DrawRect(cx, ry, mW - 0.01, oph - 0.004, 150, 30, 15, 180)
                end

                DrawTxt(">", cx - mW/2 + 0.015, ry - 0.015, 0, 0.35, 255, 255, 255, 255, false, false)
                DrawTxt(opt, cx + mW/2 - 0.015, ry - 0.015, 0, 0.32, 255, 255, 255, 255, false, true)
            end

            DrawRect(cx, fY, mW, fH, 15, 5, 5, 255)
            DrawTxt("(" .. selRow .. "/" .. #opts .. ")", cx - mW/2 + 0.015, fY - 0.01, 0, 0.25, 230, 60, 30, 255, false, false)
            DrawTxt("ia3x 4.6 [Discord.gg/ia3x]", cx + mW/2 - 0.015, fY - 0.01, 0, 0.25, 180, 180, 180, 255, false, true)

            local mx = GetControlNormal(0, 239)
            local my = GetControlNormal(0, 240)

            if mx > 0 and my > 0 then
                for i = 1, #tabs do
                    local tx = cx - mW/2 + tW * (i - 1) + tW/2
                    if mx > tx - tW/2 and mx < tx + tW/2 and my > tY - tH/2 and my < tY + tH/2 then
                        if IsControlJustPressed(0, 237) then
                            activeTab = i
                            selRow = 1
                            Citizen.Wait(150)
                        end
                    end
                end

                for i = 1, #opts do
                    local ry = cTop + (i - 1) * oph + oph/2
                    if mx > cx - mW/2 and mx < cx + mW/2 and my > ry - oph/2 and my < ry + oph/2 then
                        selRow = i
                        if IsControlJustPressed(0, 237) then
                            HandleAction(opts[i])
                            Citizen.Wait(150)
                        end
                    end
                end
            end

            if not inputActive then
                if IsControlJustPressed(0, 172) then
                    selRow = math.max(1, selRow - 1)
                end
                if IsControlJustPressed(0, 173) then
                    selRow = math.min(#opts, selRow + 1)
                end
                if IsControlJustPressed(0, 174) then
                    activeTab = math.max(1, activeTab - 1)
                    selRow = 1
                end
                if IsControlJustPressed(0, 175) then
                    activeTab = math.min(#tabs, activeTab + 1)
                    selRow = 1
                end
                if IsControlJustPressed(0, 191) then
                    if #opts > 0 and opts[selRow] then
                        HandleAction(opts[selRow])
                    end
                end
            end
        end
    end
end)