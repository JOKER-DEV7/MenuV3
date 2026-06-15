-- تعريف منيو جديد
local myMenu = {
 title = "مناو ماتشو تشيت",
 items = {
 { name = "خيار 1", action = function() print("تم اختيار خيار 1") end },
 { name = "خيار 2", action = function() print("تم اختيار خيار 2") end },
 { name = "خيار 3", action = function() print("تم اختيار خيار 3") end },
 { name = "مغادرة", action = function() print("شكرًا لك على استخدام ماتشو تشيت!") end }
 }
}

-- دالة لعرض منيو
local function displayMenu(menu)
 print(menu.title)
 print("-----------------")
 for i, item in ipairs(menu.items) do
 print(i .. ". " .. item.name)
 end
end

-- دالةincipal لبرنامج ماتشو تشيت
local function main()
 while true do
 displayMenu(myMenu)
 local choice = io.read():match("^%d+$")
 if choice then
 local item = myMenu.items[tonumber(choice)]
 if item then
 item.action()
 else
 print("الخيار غير صالح، يرجى المحاولة مرة أخرى.")
 end
 else
 print("الرجاء إدخال رقم صالح.")
 end
 end
end

-- تشغيل البرنامج
main()
