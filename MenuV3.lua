local visible = false
local activeTab = 1
local selRow = 1
local toggles = {["Troll 1"] = false, ["Troll 2"] = false}
local tabs = {"Server", "Weapons", "Troll", "Cfw", "Players"}
local tabOpts = {
    [1] = {"Server Info", "Restart UI"},
    [2] = {"Give Ammo", "Clear Weapons"},
    [3] = {"Troll 1", "Troll 2"},
    [4] = {"Player Info", "Give Money", "Spawn Car", "Respawn", "Revive"},
    [5] = {} 
}

local mW = 0.23
local mH = 0.45
local hH = 0.09
local tH = 0.045
local fH = 0.035
local inputActive = false
local inputLabel = ""
local nextActionTime = 0
local onlinePlayers = {}
local lastPlayerUpdate = 0

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
    if name == "Revive" then
        ShowInput("Enter Player ID:")
    end
end

local function UpdatePlayersList()
    local currentTime = GetGameTimer()
    if currentTime - lastPlayerUpdate > 2000 then 
        onlinePlayers = {}
        local players = GetActivePlayers()
        for _, player in ipairs(players) do
            local sId = GetPlayerServerId(player)
            local pName = GetPlayerName(player)
            table.insert(onlinePlayers, "[" .. sId .. "] " .. pName)
        end
        tabOpts[5] = onlinePlayers
        lastPlayerUpdate = currentTime
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
            UpdatePlayersList()

            local cx, cy = 0.15, 0.45
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
            DisableControlAction(0, 140, true)
            DisableControlAction(0, 141, true)
            DisableControlAction(0, 142, true)

            if not HasStreamedTextureDictLoaded("joker_textures") then
                RequestStreamedTextureDict("joker_textures", true)
                DrawRect(cx, cy, mW + 0.004, mH + 0.004, 0, 200, 255, 200)
                DrawRect(cx, cy, mW, mH, 10, 15, 20, 240)
                DrawRect(cx, hY, mW, hH, 5, 10, 15, 255)
                DrawTxt("JOKER MENU V3", cx, hY - 0.02, 4, 0.75, 0, 200, 255, 255, true, false)
            else
                DrawSprite("joker_textures", "menu_bg", cx, cy, mW + 0.01, mH + 0.01, 0.0, 255, 255, 255, 255)
                DrawSprite("joker_textures", "header_banner", cx, hY, mW, hH, 0.0, 255, 255, 255, 255)
            end

            for i = 1, #tabs do
                local tx = cx - mW/2 + tW * (i - 1) + tW/2
                
                if i == activeTab then
                    DrawRect(tx, tY, tW, tH, 0, 150, 200, 200)
                    DrawTxt(tabs[i], tx, tY - 0.012, 0, 0.24, 255, 255, 255, 255, true, false)
                else
                    DrawRect(tx, tY, tW, tH, 15, 20, 25, 255)
                    DrawTxt(tabs[i], tx, tY - 0.012, 0, 0.24, 150, 150, 150, 255, true, false)
                end
            end

            local opts = tabOpts[activeTab] or {}
            local oph = 0.045

            for i = 1, #opts do
                local ry = cTop + (i - 1) * oph + oph/2
                local opt = opts[i]
                
                if i == selRow then
                    DrawRect(cx, ry, mW - 0.01, oph - 0.004, 0, 100, 150, 180)
                end

                DrawTxt(">", cx - mW/2 + 0.015, ry - 0.015, 0, 0.35, 255, 255, 255, 255, false, false)
                DrawTxt(opt, cx + mW/2 - 0.015, ry - 0.015, 0, 0.30, 255, 255, 255, 255, false, true)
            end

            DrawRect(cx, fY, mW, fH, 5, 10, 15, 255)
            DrawTxt("(" .. selRow .. "/" .. #opts .. ")", cx - mW/2 + 0.015, fY - 0.01, 0, 0.25, 0, 200, 255, 255, false, false)
            DrawTxt("Joker v3.0 | Discord.gg/joker", cx + mW/2 - 0.015, fY - 0.01, 0, 0.25, 150, 150, 150, 255, false, true)

            local mx = GetControlNormal(0, 239)
            local my = GetControlNormal(0, 240)

            if GetGameTimer() > nextActionTime then
                if mx > 0 and my > 0 then
                    for i = 1, #tabs do
                        local tx = cx - mW/2 + tW * (i - 1) + tW/2
                        if mx > tx - tW/2 and mx < tx + tW/2 and my > tY - tH/2 and my < tY + tH/2 then
                            if IsDisabledControlJustPressed(0, 237) then
                                activeTab = i
                                selRow = 1
                                nextActionTime = GetGameTimer() + 200
                            end
                        end
                    end

                    for i = 1, #opts do
                        local ry = cTop + (i - 1) * oph + oph/2
                        if mx > cx - mW/2 and mx < cx + mW/2 and my > ry - oph/2 and my < ry + oph/2 then
                            selRow = i
                            if IsDisabledControlJustPressed(0, 237) then
                                HandleAction(opts[i])
                                nextActionTime = GetGameTimer() + 200
                            end
                        end
                    end
                end

                if not inputActive then
                    if IsDisabledControlJustPressed(0, 172) then
                        selRow = math.max(1, selRow - 1)
                        nextActionTime = GetGameTimer() + 150
                    elseif IsDisabledControlJustPressed(0, 173) then
                        selRow = math.min(#opts, selRow + 1)
                        nextActionTime = GetGameTimer() + 150
                    elseif IsDisabledControlJustPressed(0, 174) then
                        activeTab = math.max(1, activeTab - 1)
                        selRow = 1
                        nextActionTime = GetGameTimer() + 150
                    elseif IsDisabledControlJustPressed(0, 175) then
                        activeTab = math.min(#tabs, activeTab + 1)
                        selRow = 1
                        nextActionTime = GetGameTimer() + 150
                    elseif IsDisabledControlJustPressed(0, 191) then
                        if #opts > 0 and opts[selRow] then
                            HandleAction(opts[selRow])
                        end
                        nextActionTime = GetGameTimer() + 200
                    end
                end
            end
        end
    end
end)