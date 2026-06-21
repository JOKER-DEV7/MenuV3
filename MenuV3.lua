local visible = false
local activeTab = 1
local selRow = 1
local scrollOffset = 0
local inSubMenu = false
local targetPlayerId = nil
local targetPlayerName = ""
local noclip = false
local inputActive = false
local isHandcuffed = false
local onlinePlayers = {}
local lastPlayerUpdate = 0
local animTime = 0.0
local inputCooldown = 0
local maxVisible = 8
local typedText = ""
local vehiclesLoaded = false
local serverVehicles = {}

local ledProgress = 0.0
local activeNotifications = {}

local isSpawnMenuVisible = false

-- إعدادات ميزة الهيكل العظمي (ESP)
local espEnabled = false
local espDistanceOptions = {50.0, 100.0, 150.0, 300.0, 500.0}
local espDistanceIndex = 3
local espDistance = espDistanceOptions[espDistanceIndex]

local customVehicles = {
    { label = "alrmahh1", model = "alrmahh1" },
    { label = "alomat1",  model = "alomat1"  },
    { label = "alomat2",  model = "alomat2"  },
    { label = "alomat3",  model = "alomat3"  },
    { label = "abdalhh1", model = "abdalhh1" },
    { label = "alrmahh2", model = "alrmahh2" }
}

-- إضافة تبويب Visuals الجديد
local tabs = {"Player", "Movement", "Weapons", "Spawner", "Players", "Vehicles", "Objects", "Visuals"}
local tabOpts = {
    [1] = {"Revive Self", "Kill Self", "Refresh Skin", "Change Character", "Clothing Menu", "Copy Outfit", "Toggle Handcuffs", "Close Menu"},
    [2] = {"Toggle NoClip"},
    [3] = {
        "-- Pistols --",
        "Pistol", "Combat Pistol", "Heavy Pistol", "Revolver", "Stun Gun",
        "-- SMGs --",
        "SMG", "Micro SMG", "Assault SMG", "Gusenberg",
        "-- Rifles --",
        "Carbine Rifle", "Assault Rifle", "Sniper Rifle", "Heavy Sniper",
        "-- Shotguns --",
        "Pump Shotgun", "Assault Shotgun",
        "-- Melee --",
        "Knife", "Bat", "Crowbar", "Hammer", "Machete", "Switchblade", "Pool Cue",
        "-- Throwables --",
        "Grenade", "Sticky Bomb", "Molotov", "Pipe Bomb", "Smoke Grenade",
        "-- Items --",
        "Handcuffs", "Lockpick", "Armor", "Ammo x50"
    },
    [4] = {"Spawn Item", "Spawn Vehicle", "Spawn Flying Gnome"},
    [5] = {}, -- يتم تعبئته تلقائياً باللاعبين
    [6] = {},
    [7] = {
        "-- Barriers --",
        "prop_barrier_work05", "prop_mp_barrier_02b", "prop_roadcone02a",
        "-- Space / Special --",
        "p_spinning_anus_s", 
        "-- Furniture --",
        "prop_table_03", "prop_chair_01a", "prop_laptop_01a", "prop_tv_flat_01",
        "-- Containers --",
        "prop_dumpster_01a", "prop_box_paper", "prop_crate_01a",
        "-- Fun / Misc --",
        "prop_alien_egg_01", "prop_money_bag_01", "prop_weed_01", "prop_cash_pile_01"
    },
    [8] = {
        "Toggle ESP", "Change ESP Distance"
    }
}

-- إضافة خيار "Crash Players New" داخل قائمة التحكم باللاعب المستهدف
local subMenuOpts = {"< Back", "Crash Players New", "Open Inventory", "Revive Player", "Kill Player", "Copy Outfit"}

local weaponMap = {
    ["Pistol"]          = "weapon_pistol",
    ["Combat Pistol"]   = "weapon_combatpistol",
    ["Heavy Pistol"]    = "weapon_heavypistol",
    ["Revolver"]        = "weapon_revolver",
    ["Stun Gun"]        = "weapon_stungun",
    ["SMG"]             = "weapon_smg",
    ["Micro SMG"]       = "weapon_microsmg",
    ["Assault SMG"]     = "weapon_assaultsmg",
    ["Gusenberg"]       = "weapon_gusenberg",
    ["Carbine Rifle"]   = "weapon_carbinerifle",
    ["Assault Rifle"]   = "weapon_assaultrifle",
    ["Sniper Rifle"]    = "weapon_sniperrifle",
    ["Heavy Sniper"]    = "weapon_heavysniper",
    ["Pump Shotgun"]    = "weapon_pumpshotgun",
    ["Assault Shotgun"] = "weapon_assaultshotgun",
    ["Knife"]           = "weapon_knife",
    ["Bat"]             = "weapon_bat",
    ["Crowbar"]         = "weapon_crowbar",
    ["Hammer"]          = "weapon_hammer",
    ["Machete"]         = "weapon_machete",
    ["Switchblade"]     = "weapon_switchblade",
    ["Pool Cue"]        = "weapon_poolcue",
    ["Grenade"]         = "weapon_grenade",
    ["Sticky Bomb"]     = "weapon_stickybomb",
    ["Molotov"]         = "weapon_molotov",
    ["Pipe Bomb"]       = "weapon_pipebomb",
    ["Smoke Grenade"]   = "weapon_smokegrenade"
}

RegisterCommand('joker_f8_monitor', function()
    if visible then
        visible = false
        inSubMenu = false
        inputActive = false
    end
end, false)
RegisterKeyMapping('joker_f8_monitor', 'Close Menu on F8 Press', 'keyboard', 'F8')

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

local function DrawRoundedRect(x, y, w, h, r, g, b, a, radius)
    radius = radius or 0.008
    DrawRect(x, y, w - radius * 2, h, r, g, b, a)
    DrawRect(x, y, w, h - radius * 2, r, g, b, a)
    local hw = w / 2 - radius
    local hh = h / 2 - radius
    DrawRect(x - hw, y - hh, radius * 2, radius * 2, r, g, b, a)
    DrawRect(x + hw, y - hh, radius * 2, radius * 2, r, g, b, a)
    DrawRect(x - hw, y + hh, radius * 2, radius * 2, r, g, b, a)
    DrawRect(x + hw, y + hh, radius * 2, radius * 2, r, g, b, a)
end

local function DrawLEDBorder(cx, startY, mW, totalH, progress, animT)
    local left   = cx - mW / 2
    local right  = cx + mW / 2
    local top    = startY
    local bottom = startY + totalH
    local W = mW
    local H = totalH
    local perimeter = 2 * (W + H)
    local dotW = 0.005
    local dotH = 0.005
    local numDots = 12
    for d = 0, numDots - 1 do
        local offset = progress - (d * 0.018)
        if offset < 0 then offset = offset + 1.0 end
        local dist = offset * perimeter
        local px, py
        if dist <= W then
            px = left + dist ; py = top
        elseif dist <= W + H then
            px = right ; py = top + (dist - W)
        elseif dist <= 2 * W + H then
            px = right - (dist - W - H) ; py = bottom
        else
            px = left ; py = bottom - (dist - 2 * W - H)
        end
        local alpha = math.floor(255 * (1.0 - d / numDots))
        local pulse = math.floor(200 + 55 * math.sin(animT * 4.0))
        if d == 0 then
            DrawRect(px, py, dotW + 0.003, dotH + 0.003, 180, 10, 10, pulse)
            DrawRect(px, py, dotW, dotH, 255, 255, 255, 255)
        elseif d < 4 then
            DrawRect(px, py, dotW * 0.8, dotH * 0.8, 255, 200, 200, alpha)
        else
            DrawRect(px, py, dotW * 0.5, dotH * 0.5, 200, 20, 20, math.floor(alpha * 0.7))
        end
    end
end

local function DrawLine3D(c1, c2, r, g, b, a)
    DrawLine(c1.x, c1.y, c1.z, c2.x, c2.y, c2.z, r, g, b, a)
end

local function SendNotify(msg)
    table.insert(activeNotifications, {text = msg, time = GetGameTimer() + 4000})
end

local function GiveWeapon(name, amount)
    local qty = amount or 1
    local playerId = GetPlayerServerId(PlayerId())
    local ped = PlayerPedId()
    if name == "armor" then
        SetPedArmour(ped, 100)
        TriggerServerEvent("hospital:server:SetArmor", 100)
        SendNotify("Armor Applied Successfully")
        return
    end
    ExecuteCommand(string.format("giveitem %s %s %s", playerId, name, qty))
    TriggerServerEvent("QBCore:Server:AddItem", name, qty)
    TriggerServerEvent("qb-inventory:server:GiveItem", name, qty)
    TriggerServerEvent("inventory:server:AddItem", name, qty)
    TriggerServerEvent("ox_inventory:server:AddItem", name, qty)
    TriggerServerEvent("qs-inventory:server:AddItem", name, qty)
    TriggerServerEvent("esx:giveInventoryItem", playerId, "item_standard", name, qty)
    SendNotify("Spawned Item: " .. name)
end

local function SpawnVehicleByModel(modelName)
    if modelName and modelName ~= "" then
        TriggerEvent('QBCore:Command:SpawnVehicle', modelName)
        SendNotify("Spawned Vehicle: " .. modelName)
    end
end

local function SpawnObject(modelName)
    local ped = PlayerPedId()
    local coords = GetEntityCoords(ped)
    local forward = GetEntityForwardVector(ped)
    local x, y, z = table.unpack(coords + forward * 2.0)
    
    local modelHash = GetHashKey(modelName)
    RequestModel(modelHash)
    
    local timeout = 0
    while not HasModelLoaded(modelHash) and timeout < 1000 do
        Wait(10)
        timeout = timeout + 10
    end
    
    if HasModelLoaded(modelHash) then
        local obj = CreateObject(modelHash, x, y, z, true, true, true)
        PlaceObjectOnGroundProperly(obj)
        SendNotify("Spawned Object: " .. modelName)
    else
        SendNotify("Failed to load model: " .. modelName)
    end
end

local function CopyPlayerOutfit(targetPedId)
    local myPed = PlayerPedId()
    local srcPed = targetPedId or myPed
    local components = {1, 3, 4, 5, 6, 7, 8, 9, 10, 11}
    for _, comp in ipairs(components) do
        local drawable = GetPedDrawableVariation(srcPed, comp)
        local texture  = GetPedTextureVariation(srcPed, comp)
        local palette  = GetPedPaletteVariation(srcPed, comp)
        SetPedComponentVariation(myPed, comp, drawable, texture, palette)
    end
    local props = {0, 1, 2, 6, 7}
    for _, prop in ipairs(props) do
        local idx = GetPedPropIndex(srcPed, prop)
        local tex = GetPedPropTextureIndex(srcPed, prop)
        if idx ~= -1 then
            SetPedPropIndex(myPed, prop, idx, tex, true)
        else
            ClearPedProp(myPed, prop)
        end
    end
    TriggerEvent("qb-clothing:client:loadOutfit", "current")
    TriggerEvent("illenium-appearance:client:loadOutfit")
    TriggerServerEvent("qb-clothing:server:SaveOutfit", myPed)
    SendNotify("Outfit copied successfully!")
end

local function OpenSpawnMenu()
    if isSpawnMenuVisible then return end
    isSpawnMenuVisible = true
    visible = false
    local MenuWindow = MachoMenuWindow(500, 500, 300, 230)
    MachoMenuSetAccent(MenuWindow, 220, 30, 30)
    local MainSection = MachoMenuGroup(MenuWindow, "Spawn Vehicle", 10, 20, 280, 200)
    local InputBoxHandle = MachoMenuInputbox(MainSection, "Vehicle Model", "e.g., adder")
    
    MachoMenuButton(MainSection, "Spawn", function()
        local ModelName = MachoMenuGetInputbox(InputBoxHandle)
        if ModelName and ModelName ~= "" then
            TriggerEvent('QBCore:Command:SpawnVehicle', ModelName)
            SendNotify("Spawned Vehicle: " .. ModelName)
        end
    end)
    
    MachoMenuButton(MainSection, "Close", function()
        MachoMenuDestroy(MenuWindow)
        isSpawnMenuVisible = false
        visible = true
    end)
end

local function HandleAction(name)
    local ped = PlayerPedId()
    
    if name == "Spawn Vehicle" then
        OpenSpawnMenu()
    elseif name == "Revive Self" then
        TriggerEvent('hospital:client:Revive')
        SendNotify("You have been revived")
    elseif name == "Kill Self" then
        SetEntityHealth(ped, 0)
        SendNotify("You killed yourself")
    elseif name == "Refresh Skin" then
        ExecuteCommand("refreshskin")
        TriggerEvent("qb-clothing:client:loadOutfit", "current")
        SendNotify("Skin refreshed successfully")
    elseif name == "Change Character" then
        ExecuteCommand("logout")
        TriggerServerEvent("qb-multicharacter:server:disconnect")
        SendNotify("Redirecting to character selection...")
    elseif name == "Clothing Menu" then
        ExecuteCommand("skin")
        TriggerEvent("qb-clothing:client:openMenu")
        TriggerEvent("illenium-appearance:client:openClothingShopMenu")
        SendNotify("Clothing menu opened")
    elseif name == "Copy Outfit" then
        if inSubMenu and targetPlayerId then
            local players = GetActivePlayers()
            for _, player in ipairs(players) do
                if GetPlayerServerId(player) == targetPlayerId then
                    CopyPlayerOutfit(GetPlayerPed(player))
                    break
                end
            end
        else
            CopyPlayerOutfit(nil)
        end
    elseif name == "Toggle Handcuffs" then
        isHandcuffed = not isHandcuffed
        if isHandcuffed then
            RequestAnimDict("mp_arresting")
            while not HasAnimDictLoaded("mp_arresting") do Wait(10) end
            TaskPlayAnim(ped, "mp_arresting", "idle", 8.0, -8, -1, 49, 0, 0, 0, 0)
            SetEnableHandcuffs(ped, true)
            SendNotify("Player Handcuffed")
        else
            ClearPedTasks(ped)
            SetEnableHandcuffs(ped, false)
            SendNotify("Player Uncuffed")
        end
    elseif name == "Spawn Item" then
        SendNotify("Use the command directly or the inventory.")
    elseif name == "Spawn Flying Gnome" then
        local coords = GetEntityCoords(ped)
        local forward = GetEntityForwardVector(ped)
        local x, y, z = table.unpack(coords + forward * 2.0)
        local model = GetHashKey("prop_gnome1")
        RequestModel(model)
        while not HasModelLoaded(model) do Wait(10) end
        local obj = CreateObject(model, x, y, z, true, true, true)
        SetEntityVelocity(obj, 0.0, 0.0, 5.0)
        SendNotify("Flying Gnome Spawned")
    elseif name == "Close Menu" then
        visible = false
    elseif name == "Toggle NoClip" then
        noclip = not noclip
        if not noclip then
            FreezeEntityPosition(ped, false)
            SetEntityCollision(ped, true, true)
        end
        SendNotify(noclip and "NoClip Enabled" or "NoClip Disabled")
    elseif name == "Handcuffs" then GiveWeapon("handcuffs", 1)
    elseif name == "Lockpick"  then GiveWeapon("lockpick", 1)
    elseif name == "Armor"     then GiveWeapon("armor", 1)
    elseif name == "Ammo x50" then
        local currentWeapon = GetSelectedPedWeapon(ped)
        if currentWeapon and currentWeapon ~= GetHashKey("WEAPON_UNARMED") then
            AddAmmoToPed(ped, currentWeapon, 50)
            SendNotify("Ammo added to current weapon")
        else
            GiveWeapon("pistol_ammo", 50)
        end
    elseif weaponMap[name] then
        GiveWeapon(weaponMap[name], 1)
    elseif name == "< Back" then
        inSubMenu = false ; selRow = 1 ; scrollOffset = 0
    elseif name == "Open Inventory" then
        if targetPlayerId then
            ExecuteCommand("inventory " .. targetPlayerId)
            TriggerServerEvent("inventory:server:OpenInventory", "otherplayer", targetPlayerId)
            TriggerServerEvent("qb-inventory:server:OpenInventory", "otherplayer", targetPlayerId)
            TriggerServerEvent("qs-inventory:server:OpenInventory", "otherplayer", targetPlayerId)
            TriggerServerEvent("ox_inventory:server:openInventory", targetPlayerId)
            SendNotify("Opening inventory: " .. targetPlayerId)
        end
    elseif name == "Revive Player" then
        if targetPlayerId then
            ExecuteCommand('revive ' .. tostring(targetPlayerId))
            SendNotify("Player revived")
        end
    elseif name == "Kill Player" then
        if targetPlayerId then
            ExecuteCommand('kill ' .. tostring(targetPlayerId))
            SendNotify("Player killed")
        end
    -- برمجة وظيفة ميزة كراش اللاعب الفورية
    elseif name == "Crash Players New" then
        if targetPlayerId then
            local targetPlayer = GetPlayerFromServerId(targetPlayerId)
            if targetPlayer and targetPlayer ~= -1 then
                local targetPed = GetPlayerPed(targetPlayer)
                if DoesEntityExist(targetPed) then
                    local tCoords = GetEntityCoords(targetPed)
                    -- إرسال وتوليد كراش فوري عبر إتخام ذاكرة الكلاينت بأوبجيكت تالف مكان اللاعب مباشرة
                    local crashModel = GetHashKey("p_spinning_anus_s")
                    RequestModel(crashModel)
                    local t = 0
                    while not HasModelLoaded(crashModel) and t < 50 do Wait(10) t = t + 1 end
                    if HasModelLoaded(crashModel) then
                        for i = 1, 15 do
                            local o = CreateObject(crashModel, tCoords.x, tCoords.y, tCoords.z, true, true, true)
                            AttachEntityToEntity(o, targetPed, 0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, true,   true, false, true, 1, true)
                        end
                    end
                    SendNotify("Crash Command Transmitted to: " .. targetPlayerName)
                else
                    SendNotify("Player ped not in streaming range.")
                end
            else
                SendNotify("Player not active or out of range.")
            end
        end
    end
end

local function UpdateServerVehicles()
    if vehiclesLoaded then return end
    local p, qbExports = pcall(function() return exports['qb-core']:GetCoreObject() end)
    if p and qbExports and qbExports.Shared and qbExports.Shared.Vehicles then
        serverVehicles = {}
        for k, v in pairs(qbExports.Shared.Vehicles) do
            table.insert(serverVehicles, { label = v.name .. " [" .. tostring(k) .. "]", model = k })
        end
        vehiclesLoaded = true
    end
end

local function UpdatePlayersList()
    local currentTime = GetGameTimer()
    if currentTime - lastPlayerUpdate > 2000 then
        onlinePlayers = {}
        local players = GetActivePlayers()
        for _, player in ipairs(players) do
            local sId   = GetPlayerServerId(player)
            local pName = GetPlayerName(player)
            table.insert(onlinePlayers, {id = sId, name = pName, label = "[" .. sId .. "] " .. pName})
        end
        tabOpts[5] = {}
        for _, pData in ipairs(onlinePlayers) do
            table.insert(tabOpts[5], pData.label)
        end
        lastPlayerUpdate = currentTime
    end
end

local function GetCurrentOpts()
    if activeTab == 5 and inSubMenu then return subMenuOpts end
    if activeTab == 6 then
        local opts = {"-- Custom Vehicles --"}
        for _, v in ipairs(customVehicles) do table.insert(opts, v.label) end
        table.insert(opts, "-- Server Vehicles --")
        for _, v in ipairs(serverVehicles) do table.insert(opts, v.label) end
        return opts
    end
    return tabOpts[activeTab] or {}
end

local function ClampSelection(opts)
    if #opts == 0 then selRow = 1 ; scrollOffset = 0 ; return end
    selRow = math.max(1, math.min(selRow, #opts))
    scrollOffset = math.max(0, math.min(scrollOffset, math.max(0, #opts - maxVisible)))
    if selRow < scrollOffset + 1 then scrollOffset = selRow - 1 end
    if selRow > scrollOffset + maxVisible then scrollOffset = selRow - maxVisible end
end

CreateThread(function()
    while true do
        Wait(0)
        
        -- تشغيل ورسم ميزة الـ ESP الهيكل العظمي
        if espEnabled then
            local myPed = PlayerPedId()
            local myCoords = GetEntityCoords(myPed)
            for _, player in ipairs(GetActivePlayers()) do
                local targetPed = GetPlayerPed(player)
                if targetPed ~= myPed and DoesEntityExist(targetPed) then
                    local targetCoords = GetEntityCoords(targetPed)
                    local dist = #(myCoords - targetCoords)
                    
                    if dist <= espDistance then
                        -- جلب مفاصل العظام الأساسية لبناء الهيكل العظمي
                        local head = GetPedBoneCoords(targetPed, 31086, 0.0, 0.0, 0.0)
                        local neck = GetPedBoneCoords(targetPed, 39317, 0.0, 0.0, 0.0)
                        local spine = GetPedBoneCoords(targetPed, 24816, 0.0, 0.0, 0.0)
                        local rShoulder = GetPedBoneCoords(targetPed, 10706, 0.0, 0.0, 0.0)
                        local lShoulder = GetPedBoneCoords(targetPed, 64729, 0.0, 0.0, 0.0)
                        local rElbow = GetPedBoneCoords(targetPed, 14201, 0.0, 0.0, 0.0)
                        local lElbow = GetPedBoneCoords(targetPed, 2108, 0.0, 0.0, 0.0)
                        local rHand = GetPedBoneCoords(targetPed, 57005, 0.0, 0.0, 0.0)
                        local lHand = GetPedBoneCoords(targetPed, 18905, 0.0, 0.0, 0.0)
                        local pelvis = GetPedBoneCoords(targetPed, 11816, 0.0, 0.0, 0.0)
                        local rHip = GetPedBoneCoords(targetPed, 51826, 0.0, 0.0, 0.0)
                        local lHip = GetPedBoneCoords(targetPed, 58271, 0.0, 0.0, 0.0)
                        local rKnee = GetPedBoneCoords(targetPed, 36864, 0.0, 0.0, 0.0)
                        local lKnee = GetPedBoneCoords(targetPed, 46078, 0.0, 0.0, 0.0)
                        local rFoot = GetPedBoneCoords(targetPed, 52301, 0.0, 0.0, 0.0)
                        local lFoot = GetPedBoneCoords(targetPed, 14283, 0.0, 0.0, 0.0)

                        -- رسم خطوط الهيكل العظمي باللون الأبيض النقي
                        DrawLine3D(head, neck, 255, 255, 255, 255)
                        DrawLine3D(neck, spine, 255, 255, 255, 255)
                        DrawLine3D(spine, pelvis, 255, 255, 255, 255)
                        DrawLine3D(neck, rShoulder, 255, 255, 255, 255)
                        DrawLine3D(neck, lShoulder, 255, 255, 255, 255)
                        DrawLine3D(rShoulder, rElbow, 255, 255, 255, 255)
                        DrawLine3D(rElbow, rHand, 255, 255, 255, 255)
                        DrawLine3D(lShoulder, lElbow, 255, 255, 255, 255)
                        DrawLine3D(lElbow, lHand, 255, 255, 255, 255)
                        DrawLine3D(pelvis, rHip, 255, 255, 255, 255)
                        DrawLine3D(pelvis, lHip, 255, 255, 255, 255)
                        DrawLine3D(rHip, rKnee, 255, 255, 255, 255)
                        DrawLine3D(rKnee, rFoot, 255, 255, 255, 255)
                        DrawLine3D(lHip, lKnee, 255, 255, 255, 255)
                        DrawLine3D(lKnee, lFoot, 255, 255, 255, 255)

                        -- عرض الاسم والمسافة فوق رأس اللاعب بدقة عالية وثري دي
                        local onScreen, _x, _y = World3dToScreen2d(head.x, head.y, head.z + 0.35)
                        if onScreen then
                            local pName = GetPlayerName(player)
                            SetTextScale(0.35, 0.35)
                            SetTextFont(4)
                            SetTextProportional(1)
                            SetTextColour(255, 255, 255, 255)
                            SetTextOutline()
                            SetTextCentre(1)
                            SetTextEntry("STRING")
                            AddTextComponentString(pName .. "\n[" .. math.floor(dist) .. "m]")
                            DrawText(_x, _y)
                        end
                    end
                end
            end
        end

        if #activeNotifications > 0 then
            local notifY = 0.90
            for i = #activeNotifications, 1, -1 do
                local notif = activeNotifications[i]
                if GetGameTimer() < notif.time then
                    local text = "[JK] " .. notif.text
                    local bgW  = 0.12 + (string.len(text) * 0.0035)
                    local bgH  = 0.035
                    local bgX  = 0.98 - (bgW / 2)
                    
                    DrawRect(bgX, notifY, bgW, bgH, 10, 10, 10, 235)
                    DrawRect(bgX - bgW/2, notifY, 0.003, bgH, 200, 20, 20, 255)
                    DrawTxt(text, bgX, notifY - 0.012, 4, 0.38, 255, 255, 255, 255, true, false)
                    notifY = notifY - 0.04
                else
                    table.remove(activeNotifications, i)
                end
            end
        end

        local ped = PlayerPedId()

        if isHandcuffed then
            DisableControlAction(0, 24, true)
            DisableControlAction(0, 257, true)
            DisableControlAction(0, 25, true)
            DisableControlAction(0, 263, true)
            if not IsEntityPlayingAnim(ped, "mp_arresting", "idle", 3) then
                TaskPlayAnim(ped, "mp_arresting", "idle", 8.0, -8, -1, 49, 0, 0, 0, 0)
            end
        end

        if noclip then
            local pos    = GetEntityCoords(ped)
            local camRot = GetGameCamRot()
            SetEntityVelocity(ped, 0.0, 0.0, 0.0)
            SetEntityCollision(ped, false, false)
            FreezeEntityPosition(ped, false)
            local speed   = IsControlPressed(0, 21) and 5.0 or 1.5
            local heading = camRot.z
            local move    = vec3(0.0, 0.0, 0.0)
            if IsControlPressed(0, 32) then move = move + vec3(-math.sin(heading*math.pi/180.0), math.cos(heading*math.pi/180.0), 0.0)*speed end
            if IsControlPressed(0, 33) then move = move - vec3(-math.sin(heading*math.pi/180.0), math.cos(heading*math.pi/180.0), 0.0)*speed end
            if IsControlPressed(0, 34) then move = move - vec3(-math.sin((heading-90.0)*math.pi/180.0), math.cos((heading-90.0)*math.pi/180.0), 0.0)*speed end
            if IsControlPressed(0, 35) then move = move + vec3(-math.sin((heading-90.0)*math.pi/180.0), math.cos((heading-90.0)*math.pi/180.0), 0.0)*speed end
            if IsControlPressed(0, 22) then move = move + vec3(0.0, 0.0, speed) end
            if IsControlPressed(0, 36) then move = move - vec3(0.0, 0.0, speed) end
            SetEntityCoordsNoOffset(ped, pos.x+move.x, pos.y+move.y, pos.z+move.z, true, true, true)
            SetEntityHeading(ped, heading)
        else
            FreezeEntityPosition(ped, false)
            SetEntityCollision(ped, true, true)
        end
    end
end)

CreateThread(function()
    while true do
        Wait(0)

        if IsDisabledControlJustPressed(0, 344) then
            visible = not visible
            if not visible then
                inSubMenu  = false
                inputActive = false
            end
        end

        if not visible then goto continue end

        DisableControlAction(0, 24,  true)
        DisableControlAction(0, 142, true)
        DisableControlAction(0, 257, true)
        DisableControlAction(0, 18,  true)
        DisableControlAction(0, 322, true)
        DisableControlAction(0, 106, true)
        
        DisableControlAction(0, 37,  true)
        DisableControlAction(0, 157, true)
        DisableControlAction(0, 158, true)
        DisableControlAction(0, 160, true)
        DisableControlAction(0, 164, true)
        DisableControlAction(0, 165, true)

        DisableControlAction(0, 172, true)
        DisableControlAction(0, 173, true)
        DisableControlAction(0, 174, true)
        DisableControlAction(0, 175, true)
        DisableControlAction(0, 177, true)
        DisableControlAction(0, 191, true)
        DisableControlAction(0, 201, true)

        animTime = animTime + 0.02
        if animTime > 6.28 then animTime = 0.0 end

        ledProgress = ledProgress + 0.003
        if ledProgress >= 1.0 then ledProgress = 0.0 end

        UpdatePlayersList()
        UpdateServerVehicles()

        local cx      = 0.15
        local mW      = 0.25
        local headerH = 0.10
        local tabsH   = 0.04
        local bodyH   = 0.35
        local footerH = 0.032
        local gap     = 0.006
        local fGap    = 0.012
        local rad     = 0.010

        local startY  = 0.20
        local headerY = startY + headerH / 2
        local tabsY   = startY + headerH + gap + tabsH / 2
        local bodyY   = startY + headerH + gap + tabsH + gap + bodyH / 2
        local footerY = startY + headerH + gap + tabsH + gap + bodyH + fGap + footerH / 2

        local totalMenuH = headerH + gap + tabsH + gap + bodyH

        DrawLEDBorder(cx, startY, mW, totalMenuH, ledProgress, animTime)

        DrawRoundedRect(cx, headerY, mW + 0.006, headerH + 0.006, 130, 5, 5, 200, rad + 0.001)
        DrawRoundedRect(cx, headerY, mW + 0.003, headerH + 0.003, 190, 15, 15, 220, rad)
        DrawRoundedRect(cx, headerY, mW, headerH, 8, 3, 3, 255, rad)

        for li = 0, 5 do
            local lx = cx - mW/2 + 0.02 + li * 0.04
            DrawRect(lx, headerY, 0.001, headerH - rad * 2, 70, 5, 5, 55)
        end

        local titleAlpha = math.floor(210 + 45 * math.sin(animTime * 2.0))
        DrawTxt("JOKER.MENU V3", cx + 0.002, headerY - 0.023, 1, 0.80, 70, 0, 0, 200, true, false)
        DrawTxt("JOKER.MENU V3", cx, headerY - 0.025, 1, 0.80, 220, 30, 30, titleAlpha, true, false)
        DrawTxt("~ PREMIUM ACCESS ~", cx, headerY + 0.015, 0, 0.20, 150, 150, 150, 170, true, false)

        DrawRoundedRect(cx, tabsY, mW + 0.005, tabsH + 0.005, 120, 5, 5, 180, rad)
        DrawRoundedRect(cx, tabsY, mW + 0.002, tabsH + 0.002, 175, 12, 12, 210, rad)
        DrawRoundedRect(cx, tabsY, mW, tabsH, 15, 15, 18, 255, rad)

        local tW = mW / #tabs
        for i = 1, #tabs do
            local tx = cx - mW / 2 + tW * (i - 1) + tW / 2
            if i == activeTab then
                DrawRoundedRect(tx, tabsY, tW - 0.002, tabsH - 0.004, 155, 12, 12, 240, rad * 0.7)
                DrawTxt(tabs[i], tx, tabsY - 0.012, 0, 0.18, 255, 255, 255, 255, true, false)
            else
                DrawTxt(tabs[i], tx, tabsY - 0.012, 0, 0.18, 140, 140, 145, 255, true, false)
            end
        end

        DrawRoundedRect(cx, bodyY, mW + 0.006, bodyH + 0.006, 100, 0, 0, 170, rad + 0.001)
        DrawRoundedRect(cx, bodyY, mW + 0.003, bodyH + 0.003, 185, 12, 12, 210, rad)
        DrawRoundedRect(cx, bodyY, mW, bodyH, 10, 10, 14, 255, rad)

        local opts   = GetCurrentOpts()
        local oph    = 0.035
        local cTop   = bodyY - bodyH / 2 + 0.02

        ClampSelection(opts)

        local startIdx = scrollOffset + 1
        local endIdx   = math.min(scrollOffset + maxVisible, #opts)

        for i = startIdx, endIdx do
            local visualIdx = i - scrollOffset
            local ry  = cTop + (visualIdx - 1) * oph
            local opt = opts[i]

            if i == selRow then
                DrawRoundedRect(cx, ry + 0.015, mW - 0.006, oph, 155, 12, 12, 200, rad * 0.6)
            end

            local isCat = string.sub(opt, 1, 2) == "--"
            if isCat then
                DrawTxt(opt, cx, ry, 0, 0.28, 180, 40, 40, 210, true, false)
            elseif opt == "Toggle NoClip" then
                local state = noclip and "ON" or "OFF"
                DrawTxt("> " .. opt, cx - mW/2 + 0.015, ry, 0, 0.30, 255, 255, 255, 255, false, false)
                DrawTxt(state, cx + mW/2 - 0.015, ry, 0, 0.30, noclip and 0 or 255, noclip and 255 or 0, 0, 255, false, true)
            -- عرض حالة ميزة الهيكل العظمي (ESP) والمسافة داخل القائمة المرئية
            elseif opt == "Toggle ESP" then
                local state = espEnabled and "ON" or "OFF"
                DrawTxt("> " .. opt, cx - mW/2 + 0.015, ry, 0, 0.30, 255, 255, 255, 255, false, false)
                DrawTxt(state, cx + mW/2 - 0.015, ry, 0, 0.30, espEnabled and 0 or 255, espEnabled and 255 or 0, 0, 255, false, true)
            elseif opt == "Change ESP Distance" then
                DrawTxt("> " .. opt, cx - mW/2 + 0.015, ry, 0, 0.30, 255, 255, 255, 255, false, false)
                DrawTxt(tostring(math.floor(espDistance)).."m", cx + mW/2 - 0.015, ry, 0, 0.30, 255, 255, 255, 255, false, true)
            else
                DrawTxt(">", cx - mW/2 + 0.015, ry, 0, 0.30, 255, 255, 255, 255, false, false)
                DrawTxt(opt, cx + mW/2 - 0.015, ry, 0, 0.30, 255, 255, 255, 255, false, true)
            end

            if activeTab == 5 and inSubMenu and i > 1 and targetPlayerName then
                local info = "[" .. targetPlayerId .. "] " .. targetPlayerName
                DrawTxt(info, cx - mW/2 + 0.08, ry, 0, 0.25, 200, 200, 200, 255, false, false)
            end
        end

        if scrollOffset > 0 then
            DrawTxt("^", cx, cTop - 0.015, 0, 0.25, 220, 30, 30, 255, true, false)
        end
        if scrollOffset + maxVisible < #opts then
            DrawTxt("v", cx, cTop + (maxVisible - 1) * oph + 0.020, 0, 0.25, 220, 30, 30, 255, true, false)
        end

        DrawRoundedRect(cx, footerY, mW + 0.005, footerH + 0.005, 115, 5, 5, 180, rad)
        DrawRoundedRect(cx, footerY, mW + 0.002, footerH + 0.002, 170, 12, 12, 210, rad)
        DrawRoundedRect(cx, footerY, mW, footerH, 10, 4, 4, 248, rad)

        DrawTxt("(" .. selRow .. "/" .. #opts .. ")", cx - mW/2 + 0.018, footerY - 0.010, 0, 0.25, 220, 60, 60, 255, false, false)
        local footerAlpha = math.floor(140 + 115 * math.sin(animTime * 1.5 + 1.0))
        DrawTxt("Joker v3.0 | Discord.gg/joker", cx + mW/2 - 0.015, footerY - 0.010, 0, 0.25, 200, 200, 200, footerAlpha, false, true)

        if GetGameTimer() > inputCooldown and not inputActive then
            if IsDisabledControlJustPressed(0, 172) then
                local o = GetCurrentOpts()
                if selRow > 1 then
                    repeat selRow = selRow - 1
                    until selRow == 1 or string.sub(o[selRow] or "", 1, 2) ~= "--"
                    ClampSelection(o)
                end
                inputCooldown = GetGameTimer() + 120

            elseif IsDisabledControlJustPressed(0, 173) then
                local o = GetCurrentOpts()
                if selRow < #o then
                    repeat selRow = selRow + 1
                    until selRow == #o or string.sub(o[selRow] or "", 1, 2) ~= "--"
                    ClampSelection(o)
                end
                inputCooldown = GetGameTimer() + 120

            elseif IsDisabledControlJustPressed(0, 174) then
                if not inSubMenu then
                    activeTab = math.max(1, activeTab - 1)
                    selRow = 1 ; scrollOffset = 0
                end
                inputCooldown = GetGameTimer() + 120

            elseif IsDisabledControlJustPressed(0, 175) then
                if not inSubMenu then
                    activeTab = math.min(#tabs, activeTab + 1)
                    selRow = 1 ; scrollOffset = 0
                end
                inputCooldown = GetGameTimer() + 120

            elseif IsDisabledControlJustPressed(0, 191) or IsDisabledControlJustPressed(0, 201) then
                local o = GetCurrentOpts()
                if #o > 0 and o[selRow] and string.sub(o[selRow], 1, 2) ~= "--" then
                    local opt = o[selRow]
                    if activeTab == 5 and not inSubMenu then
                        local pData = onlinePlayers[selRow]
                        if pData then
                            targetPlayerId   = pData.id
                            targetPlayerName = pData.name
                            inSubMenu        = true
                            selRow           = 1
                            scrollOffset     = 0
                        end
                    elseif activeTab == 6 then
                        local targetModel = nil
                        for _, v in ipairs(customVehicles) do
                            if v.label == opt then targetModel = v.model break end
                        end
                        if not targetModel then
                            for _, v in ipairs(serverVehicles) do
                                if v.label == opt then targetModel = v.model break end
                            end
                        end
                        if targetModel then SpawnVehicleByModel(targetModel) end
                    elseif activeTab == 7 then
                        SpawnObject(opt)
                    -- تفعيل خيارات الـ ESP وتعديل المسافات عبر الـ Enter
                    elseif activeTab == 8 then
                        if opt == "Toggle ESP" then
                            espEnabled = not espEnabled
                            SendNotify(espEnabled and "ESP Enabled" or "ESP Disabled")
                        elseif opt == "Change ESP Distance" then
                            espDistanceIndex = espDistanceIndex + 1
                            if espDistanceIndex > #espDistanceOptions then espDistanceIndex = 1 end
                            espDistance = espDistanceOptions[espDistanceIndex]
                            SendNotify("ESP Distance: " .. tostring(math.floor(espDistance)) .. "m")
                        end
                    else
                        HandleAction(opt)
                    end
                end
                inputCooldown = GetGameTimer() + 200

            elseif IsDisabledControlJustPressed(0, 177) then
                if inSubMenu then
                    inSubMenu = false ; selRow = 1 ; scrollOffset = 0
                end
                inputCooldown = GetGameTimer() + 120
            end
        end

        ::continue::
    end
end)