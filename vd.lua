-- ============================================================
--  PRISMA HUB BYPASS — АВТО-ПОИСК РАБОЧЕГО URL
-- ============================================================

local _httpget = httpget
local _request = request
local _loadstring = loadstring
local _Instance_new = Instance.new

-- ============================================================
--  1. СПИСОК ВОЗМОЖНЫХ URL ДЛЯ ОСНОВНОГО СКРИПТА
-- ============================================================

local possible_urls = {
    "https://raw.githubusercontent.com/lixxWW/ViolenceDistrict/refs/heads/main/ViolenceDistrict.lua",
    "https://raw.githubusercontent.com/lixxWW/ViolenceDistrict/main/ViolenceDistrict.lua",
    "https://raw.githubusercontent.com/lixxWW/ViolenceDistrict/refs/heads/main/Script.lua",
    "https://raw.githubusercontent.com/lixxWW/ViolenceDistrict/master/ViolenceDistrict.lua",
    "https://pastebin.com/raw/abcdef123456", -- если они перешли на pastebin
    "https://rentry.co/raw/xyz",             -- если они перешли на rentry
}

-- ============================================================
--  2. ФУНКЦИЯ HTTP-ЗАПРОСА (С ПЕРЕХВАТОМ)
-- ============================================================

local function httpRequest(url)
    if not url then return nil end
    
    -- Перехват Work.ink
    if url:find("work.ink") then
        return '{"valid": true, "message": "Bypassed"}'
    end
    
    -- Пробуем httpget
    if _httpget then
        local success, result = pcall(_httpget, url)
        if success and result and result ~= "" then
            return result
        end
    end
    
    -- Пробуем request
    if _request then
        local success, result = pcall(function()
            local res = _request({Url = url, Method = "GET"})
            return res and res.Body
        end)
        if success and result and result ~= "" then
            return result
        end
    end
    
    return nil
end

-- ============================================================
--  3. ПОИСК РАБОЧЕГО URL
-- ============================================================

local function findWorkingUrl()
    for _, url in ipairs(possible_urls) do
        local content = httpRequest(url)
        if content and content ~= "" and not content:find("404") and not content:find("Not Found") then
            return url, content
        end
    end
    return nil, nil
end

local found_url, script_code = findWorkingUrl()

if not found_url or not script_code then
    print("[Wave] ❌ Не удалось найти рабочий URL для хаба")
    return
end

print("[Wave] ✅ Найден рабочий URL: " .. found_url)

-- ============================================================
--  4. СОЗДАЁМ ОКРУЖЕНИЕ С ПЕРЕХВАТОМ
-- ============================================================

local env = {
    game = game,
    workspace = workspace,
    Players = game.Players,
    ReplicatedStorage = game:GetService("ReplicatedStorage"),
    HttpService = game:GetService("HttpService"),
    RunService = game:GetService("RunService"),
    TweenService = game:GetService("TweenService"),
    
    -- Перехват httpget
    httpget = function(url)
        if url and url:find("work.ink") then
            return '{"valid": true, "message": "Bypassed"}'
        end
        return _httpget and _httpget(url)
    end,
    
    -- Перехват request
    request = function(opts)
        if opts and opts.Url and opts.Url:find("work.ink") then
            return {Body = '{"valid": true}', Status = 200, Headers = {}}
        end
        return _request and _request(opts)
    end,
    
    -- Перехват Instance.new (блокировка GUI)
    Instance = setmetatable({}, {
        __index = function(_, key)
            if key == "new" then
                return function(cls, parent)
                    if cls == "ScreenGui" and parent and parent.Name == "PlayerGui" then
                        return nil
                    end
                    return _Instance_new(cls, parent)
                end
            end
            return _Instance_new
        end
    }),
    
    -- Стандартные функции
    print = print,
    warn = warn,
    error = error,
    task = task,
    pcall = pcall,
    loadstring = _loadstring,
}

setmetatable(env, {__index = getfenv(0)})

-- ============================================================
--  5. ЗАПУСКАЕМ СКРИПТ
-- ============================================================

local fn, err = _loadstring(script_code)
if fn then
    setfenv(fn, env)
    print("[Wave] 🚀 Загрузка Prisma Hub...")
    pcall(fn)
else
    print("[Wave] ❌ Ошибка загрузки: " .. tostring(err))
end

-- ============================================================
--  6. УБИВАЕМ GUI В ФОНЕ
-- ============================================================

local function killGUI()
    local player = game.Players.LocalPlayer
    if not player then return end
    
    for _, gui in ipairs(player.PlayerGui:GetChildren()) do
        local name = gui.Name or ""
        if name:find("Prisma") or name:find("Key") or name:find("Ultimate") or name:find("Hub") then
            pcall(gui.Destroy, gui)
        end
    end
end

game:GetService("RunService").Heartbeat:Connect(killGUI)

print("[Wave] ✅ Обход завершён")