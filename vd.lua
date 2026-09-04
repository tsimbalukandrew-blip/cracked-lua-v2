local function httpRequest(url)
    if not url then return nil end
    if url:find("work.ink") then return '{"valid":true,"message":"Bypassed"}' end
    
    local methods = {
        function()
            if syn and syn.request then
                local r = syn.request({Url=url, Method="GET"})
                return r and r.Body
            end
        end,
        function()
            if http and http.request then
                local r = http.request({Url=url, Method="GET"})
                return r and r.Body
            end
        end,
        function()
            if request then
                local r = request({Url=url, Method="GET"})
                return r and r.Body
            end
        end,
        function()
            if httpget then
                return httpget(url)
            end
        end,
        function()
            if game and game:GetService("HttpService") then
                return game:GetService("HttpService"):GetAsync(url)
            end
        end,
        function()
            if getcustomasset then
                local f = getcustomasset(url)
                return f and readfile(f)
            end
        end,
        function()
            if loadfile and pcall(loadfile, url) then
                return loadfile(url)()
            end
        end
    }
    
    for _,method in ipairs(methods) do
        local success, result = pcall(method)
        if success and result and type(result)=="string" and #result>50 then
            return result
        end
    end
    return nil
end

local function detectExecutor()
    local env = {
        syn = syn and true or false,
        http = http and true or false,
        request = request and true or false,
        httpget = httpget and true or false,
        getcustomasset = getcustomasset and true or false,
        loadfile = loadfile and true or false,
        getfenv = getfenv and true or false,
        setfenv = setfenv and true or false,
        debug = debug and true or false,
        gethui = gethui and true or false,
        getrawmetatable = getrawmetatable and true or false,
        setreadonly = setreadonly and true or false,
        getgenv = getgenv and true or false,
        getexecutorname = getexecutorname and true or false,
        is_synapse = is_synapse and true or false,
        is_krnl = is_krnl and true or false,
        is_scriptware = is_scriptware and true or false,
        identifyexecutor = identifyexecutor and true or false,
    }
    
    if env.syn and syn then env.name = "Synapse" end
    if env.http and http then env.name = "HTTP" end
    if env.request and not env.syn then env.name = "Request" end
    if env.httpget and not env.syn then env.name = "HTTPGET" end
    if env.getcustomasset then env.name = "CustomAsset" end
    if env.identifyexecutor then 
        local name = identifyexecutor()
        if name then env.name = name end
    end
    if env.getexecutorname then
        local name = getexecutorname()
        if name then env.name = name end
    end
    if not env.name then env.name = "Generic" end
    return env
end

local exec = detectExecutor()

local function createSandbox(scriptCode)
    local sandbox = {
        game = game,
        workspace = workspace,
        Players = game:GetService("Players"),
        ReplicatedStorage = game:GetService("ReplicatedStorage"),
        HttpService = game:GetService("HttpService"),
        RunService = game:GetService("RunService"),
        TweenService = game:GetService("TweenService"),
        Lighting = game:GetService("Lighting"),
        MarketplaceService = game:GetService("MarketplaceService"),
        CoreGui = game:GetService("CoreGui"),
        PlayerGui = game:GetService("Players").LocalPlayer and game:GetService("Players").LocalPlayer.PlayerGui or nil,
        
        print = print,
        warn = warn,
        error = error,
        pcall = pcall,
        task = task,
        loadstring = loadstring,
        type = type,
        typeof = typeof,
        next = next,
        pairs = pairs,
        ipairs = ipairs,
        select = select,
        unpack = unpack or table.unpack,
        table = table,
        string = string,
        math = math,
        os = {clock=os.clock, time=os.time, date=os.date},
        coroutine = coroutine,
        debug = debug,
        
        getfenv = getfenv,
        setfenv = setfenv,
        getrawmetatable = getrawmetatable,
        setreadonly = setreadonly,
        gethui = gethui,
        getgenv = getgenv,
        getexecutorname = getexecutorname,
        identifyexecutor = identifyexecutor,
    }
    
    if exec.syn then
        sandbox.syn = {
            request = function(opts)
                if opts and opts.Url and opts.Url:find("work.ink") then
                    return {Body='{"valid":true}', Status=200}
                end
                return syn.request(opts)
            end
        }
    end
    
    if exec.http then
        sandbox.http = {
            request = function(opts)
                if opts and opts.Url and opts.Url:find("work.ink") then
                    return {Body='{"valid":true}', Status=200}
                end
                return http.request(opts)
            end
        }
    end
    
    if exec.request and not exec.syn and not exec.http then
        sandbox.request = function(opts)
            if opts and opts.Url and opts.Url:find("work.ink") then
                return {Body='{"valid":true}', Status=200}
            end
            return request(opts)
        end
    end
    
    if exec.httpget then
        sandbox.httpget = function(url)
            if url and url:find("work.ink") then
                return '{"valid":true}'
            end
            return httpget(url)
        end
    end
    
    sandbox.Instance = function(className, parent)
        if className == "ScreenGui" then
            local gui = Instance.new("ScreenGui")
            if exec.gethui then
                gui.Parent = gethui()
            elseif sandbox.CoreGui then
                gui.Parent = sandbox.CoreGui
            elseif sandbox.PlayerGui then
                gui.Parent = sandbox.PlayerGui
            else
                gui.Parent = game:GetService("CoreGui")
            end
            return gui
        end
        return Instance.new(className, parent)
    end
    
    setmetatable(sandbox, {
        __index = function(t,k)
            if k=="Instance" then return sandbox.Instance end
            local val = getfenv(0)[k]
            if val ~= nil then return val end
            if exec.getgenv then
                local genv = getgenv()
                if genv and genv[k] ~= nil then return genv[k] end
            end
            return nil
        end,
        __newindex = function(t,k,v)
            if exec.getgenv then
                local genv = getgenv()
                if genv then genv[k] = v end
            end
            getfenv(0)[k] = v
        end
    })
    
    return sandbox
end

local URLS = {
    "https://raw.githubusercontent.com/lixxWW/ViolenceDistrict/refs/heads/main/ViolenceDistrict.lua",
    "https://raw.githubusercontent.com/lixxWW/ViolenceDistrict/main/ViolenceDistrict.lua",
    "https://raw.githubusercontent.com/lixxWW/ViolenceDistrict/refs/heads/main/Script.lua",
    "https://raw.githubusercontent.com/lixxWW/ViolenceDistrict/master/ViolenceDistrict.lua",
    "https://pastebin.com/raw/abcdef123456",
    "https://rentry.co/raw/xyz"
}

local function fetchScript()
    for _,url in ipairs(URLS) do
        local content = httpRequest(url)
        if content and #content > 200 then
            return url, content
        end
    end
    return nil, nil
end

local function killGUI()
    local function destroyChildren(parent)
        if not parent then return end
        for _,child in ipairs(parent:GetChildren()) do
            local name = child.Name or ""
            if name:find("Prisma") or name:find("Key") or name:find("Ultimate") or 
               name:find("Hub") or name:find("Wave") or name:find("Menu") or 
               name:find("GUI") or name:find("Loader") then
                pcall(child.Destroy, child)
            end
        end
    end
    
    local coregui = game:GetService("CoreGui")
    if coregui then destroyChildren(coregui) end
    
    local player = game:GetService("Players").LocalPlayer
    if player and player.PlayerGui then
        destroyChildren(player.PlayerGui)
    end
    
    if exec.gethui then
        local hui = gethui()
        if hui then destroyChildren(hui) end
    end
end

local url, code = fetchScript()
if not url or not code then
    print("[Universal] ❌ Script not found")
    return
end

local sandbox = createSandbox(code)

local func, err = loadstring(code)
if func then
    local success = pcall(function()
        if exec.setfenv then
            setfenv(func, sandbox)
        elseif exec.debug and debug.setupvalue then
            debug.setupvalue(func, 1, sandbox)
        else
            func()
            return
        end
        func()
    end)
    if success then
        print("[Universal] ✅ Loaded from: " .. url)
    else
        print("[Universal] ⚠️ Partial load, attempting fallback")
        local fallbackEnv = {}
        for k,v in pairs(sandbox) do fallbackEnv[k] = v end
        setmetatable(fallbackEnv, {__index = getfenv(0)})
        local fn2, err2 = loadstring(code)
        if fn2 then
            setfenv(fn2, fallbackEnv)
            pcall(fn2)
            print("[Universal] ✅ Fallback success")
        end
    end
else
    print("[Universal] ❌ Compile error: " .. tostring(err))
end

game:GetService("RunService").Heartbeat:Connect(killGUI)

local oldNew = Instance.new
Instance.new = function(className, parent)
    if className == "ScreenGui" then
        local gui = oldNew("ScreenGui")
        if exec.gethui then
            gui.Parent = gethui()
        else
            gui.Parent = game:GetService("CoreGui")
        end
        gui.Enabled = false
        return gui
    end
    return oldNew(className, parent)
end

print("[Universal] ✅ Executor: " .. (exec.name or "Unknown"))
print("[Universal] 🔧 Environment ready")
