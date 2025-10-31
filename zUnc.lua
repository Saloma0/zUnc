--[[
    ╔══════════════════════════════════════════════════════════╗
    ║           ZUNC - Advanced Executor Test Suite            ║
    ║                  Professional Edition                    ║
    ║              Comprehensive UNC Compatibility             ║
    ╚══════════════════════════════════════════════════════════╝
]]
local ZUNC_CONFIG = {
    version = "1.0.0",
    verbose = true,
    stopOnError = false,
    timeout = 5,
    colors = {
        pass = "\27[32m",
        fail = "\27[31m",
        warning = "\27[33m",
        info = "\27[36m",
        reset = "\27[0m"
    }
}

local stats = {
    total = 0,
    passed = 0,
    failed = 0,
    skipped = 0,
    startTime = os.clock(),
    categories = {}
}

local Utils = {}

function Utils.safeCall(func, timeout)
    timeout = timeout or ZUNC_CONFIG.timeout
    local success, result
    local thread = coroutine.create(function()
        success, result = pcall(func)
    end)
    
    local startTime = os.clock()
    coroutine.resume(thread)
    
    while coroutine.status(thread) ~= "dead" do
        if os.clock() - startTime > timeout then
            return false, "Timeout exceeded"
        end
        task.wait()
    end
    
    return success, result
end

function Utils.deepCompare(t1, t2)
    if type(t1) ~= type(t2) then return false end
    if type(t1) ~= "table" then return t1 == t2 end
    
    for k, v in pairs(t1) do
        if not Utils.deepCompare(v, t2[k]) then return false end
    end
    for k in pairs(t2) do
        if t1[k] == nil then return false end
    end
    return true
end

function Utils.formatTime(seconds)
    if seconds < 0.001 then
        return string.format("%.2fμs", seconds * 1000000)
    elseif seconds < 1 then
        return string.format("%.2fms", seconds * 1000)
    else
        return string.format("%.2fs", seconds)
    end
end

function Utils.generateReport()
    local elapsed = os.clock() - stats.startTime
    local percentage = stats.total > 0 and (stats.passed / stats.total * 100) or 0
    
    print("\n" .. string.rep("═", 60))
    print("╔════════════════════════════════════════════════════════╗")
    print("║              ZUNC TEST SUITE - FINAL REPORT            ║")
    print("╚════════════════════════════════════════════════════════╝")
    print(string.rep("═", 60))
    
    print(string.format("\n📊 Total Tests: %d", stats.total))
    print(string.format("✅ Passed: %d (%.1f%%)", stats.passed, percentage))
    print(string.format("❌ Failed: %d (%.1f%%)", stats.failed, (stats.failed / stats.total * 100)))
    print(string.format("⏭️  Skipped: %d", stats.skipped))
    print(string.format("⏱️  Time Elapsed: %s", Utils.formatTime(elapsed)))
    
    print("\n📂 Category Breakdown:")
    for category, data in pairs(stats.categories) do
        local catPercentage = data.total > 0 and (data.passed / data.total * 100) or 0
        print(string.format("  • %s: %d/%d (%.1f%%)", 
            category, data.passed, data.total, catPercentage))
    end
    
    print("\n" .. string.rep("═", 60))
    
    if percentage == 100 then
        print("🌟 PERFECT SCORE! All tests passed! 🌟")
    elseif percentage >= 90 then
        print("🎉 EXCELLENT! Outstanding compatibility! 🎉")
    elseif percentage >= 75 then
        print("✨ GREAT! Good executor support! ✨")
    elseif percentage >= 50 then
        print("⚠️  MODERATE: Some features missing ⚠️")
    else
        print("❗ LIMITED: Many features unsupported ❗")
    end
    
    print(string.rep("═", 60) .. "\n")
end

local TestFramework = {}

function TestFramework.printResult(category, testName, success, message)
    stats.total = stats.total + 1
    
    if not stats.categories[category] then
        stats.categories[category] = {total = 0, passed = 0}
    end
    stats.categories[category].total = stats.categories[category].total + 1
    
    if success then
        stats.passed = stats.passed + 1
        stats.categories[category].passed = stats.categories[category].passed + 1
        if ZUNC_CONFIG.verbose then
            print(string.format("✅ [%s] %s", category, testName))
        end
    else
        stats.failed = stats.failed + 1
        print(string.format("❌ [%s] %s", category, testName))
        if message and ZUNC_CONFIG.verbose then
            print(string.format("   └─ Error: %s", tostring(message)))
        end
        
        if ZUNC_CONFIG.stopOnError then
            error("Test failed: " .. testName)
        end
    end
end

function TestFramework.test(category, testName, testFunc)
    local success, result = Utils.safeCall(testFunc)
    TestFramework.printResult(category, testName, success, result)
    return success
end

function TestFramework.category(name)
    print(string.format("\n╔═══ %s %s", name, string.rep("═", 55 - #name)))
end

local function testLuaCore()
    TestFramework.category("LUA CORE")
    
    TestFramework.test("Lua Core", "Print Variadic", function()
        print("ZUNC", 123, true, {}, function() end, nil)
    end)
    
    TestFramework.test("Lua Core", "Warn Function", function()
        warn("[ZUNC]", "Test warning", debug.traceback())
    end)
    
    TestFramework.test("Lua Core", "Type Checking", function()
        assert(type("test") == "string")
        assert(type(123) == "number")
        assert(type(true) == "boolean")
        assert(type({}) == "table")
        assert(type(function() end) == "function")
        assert(type(nil) == "nil")
        assert(type(coroutine.create(function() end)) == "thread")
    end)
    
    TestFramework.test("Lua Core", "Tonumber Advanced", function()
        assert(tonumber("123") == 123)
        assert(tonumber("FF", 16) == 255)
        assert(tonumber("1010", 2) == 10)
        assert(tonumber("3.14e2") == 314)
    end)
    
    TestFramework.test("Lua Core", "LoadString Complex", function()
        local code = [[
            local function fibonacci(n)
                if n <= 1 then return n end
                return fibonacci(n-1) + fibonacci(n-2)
            end
            return fibonacci(...)
        ]]
        local func = loadstring(code)
        assert(func(10) == 55)
    end)
    
    TestFramework.test("Lua Core", "Assert Advanced", function()
        assert(1 + 1 == 2, "Math failure")
        assert(type({}) == "table", "Type check failed")
        local success = pcall(function()
            assert(false, "Expected failure")
        end)
        assert(not success)
    end)
    
    TestFramework.test("Lua Core", "Error Handling Complex", function()
        local errorObj = {code = 500, message = "Server error"}
        local success, err = xpcall(
            function() error(errorObj) end,
            function(e) return {caught = true, original = e} end
        )
        assert(not success and err.caught and err.original.code == 500)
    end)
    
    TestFramework.test("Lua Core", "Coroutine Advanced", function()
        local co = coroutine.create(function()
            local sum = 0
            for i = 1, 5 do
                sum = sum + coroutine.yield(i)
            end
            return sum
        end)
        
        local values = {}
        while coroutine.status(co) ~= "dead" do
            local _, val = coroutine.resume(co, #values > 0 and values[#values] or 0)
            if val then table.insert(values, val) end
        end
        assert(#values == 5)
    end)
    
    TestFramework.test("Lua Core", "Next Iterator", function()
        local t = {a = 1, b = 2, c = 3}
        local count = 0
        for k, v in next, t do
            count = count + 1
        end
        assert(count == 3)
    end)
    
    TestFramework.test("Lua Core", "Pairs/IPairs", function()
        local arr = {10, 20, 30}
        local sum = 0
        for i, v in ipairs(arr) do
            sum = sum + v
        end
        assert(sum == 60)
        
        local dict = {a = 1, b = 2}
        local dictSum = 0
        for k, v in pairs(dict) do
            dictSum = dictSum + v
        end
        assert(dictSum == 3)
    end)
end

local function testTableLibrary()
    TestFramework.category("TABLE LIBRARY")
    
    TestFramework.test("Table", "Insert/Remove", function()
        local t = {1, 2, 3}
        table.insert(t, 4)
        table.insert(t, 2, 1.5)
        assert(#t == 5 and t[2] == 1.5)
        
        local removed = table.remove(t, 2)
        assert(removed == 1.5 and #t == 4)
    end)
    
    TestFramework.test("Table", "Sort Custom", function()
        local t = {{v = 3}, {v = 1}, {v = 2}}
        table.sort(t, function(a, b) return a.v < b.v end)
        assert(t[1].v == 1 and t[3].v == 3)
    end)
    
    TestFramework.test("Table", "Concat Advanced", function()
        local t = {"a", "b", "c", "d"}
        assert(table.concat(t, "-", 2, 3) == "b-c")
        assert(table.concat({1, 2, 3}, "") == "123")
    end)
    
    TestFramework.test("Table", "Pack/Unpack", function()
        local packed = table.pack(1, 2, 3, nil, 5)
        assert(packed.n == 5 and packed[5] == 5)
        
        local a, b, c = table.unpack({10, 20, 30})
        assert(a == 10 and b == 20 and c == 30)
    end)
    
    TestFramework.test("Table", "Move Function", function()
        local t1 = {1, 2, 3, 4, 5}
        local t2 = {10, 20, 30}
        table.move(t1, 2, 4, 1, t2)
        assert(t2[1] == 2 and t2[2] == 3 and t2[3] == 4)
    end)
    
    TestFramework.test("Table", "Clear Function", function()
        local t = {1, 2, 3, a = "b"}
        table.clear(t)
        assert(next(t) == nil)
    end)
    
    TestFramework.test("Table", "Find Function", function()
        local t = {"a", "b", "c", "d"}
        assert(table.find(t, "c") == 3)
        assert(table.find(t, "z") == nil)
    end)
    
    TestFramework.test("Table", "Create Preallocated", function()
        local t = table.create(100, "default")
        assert(#t == 100 and t[50] == "default")
    end)
end

local function testMathLibrary()
    TestFramework.category("MATH LIBRARY")
    
    TestFramework.test("Math", "Basic Operations", function()
        assert(math.abs(-10) == 10)
        assert(math.floor(3.7) == 3)
        assert(math.ceil(3.2) == 4)
        assert(math.sqrt(16) == 4)
        assert(math.pow(2, 8) == 256)
    end)
    
    TestFramework.test("Math", "Trigonometry", function()
        local epsilon = 0.0001
        assert(math.abs(math.sin(math.pi/2) - 1) < epsilon)
        assert(math.abs(math.cos(0) - 1) < epsilon)
        assert(math.abs(math.tan(math.pi/4) - 1) < epsilon)
        assert(math.abs(math.asin(1) - math.pi/2) < epsilon)
    end)
    
    TestFramework.test("Math", "Logarithms", function()
        assert(math.floor(math.log(math.exp(5))) == 5)
        assert(math.log10(1000) == 3)
        assert(math.floor(math.log(1024, 2)) == 10)
    end)
    
    TestFramework.test("Math", "Random Advanced", function()
        math.randomseed(os.time())
        local r1 = math.random()
        assert(r1 >= 0 and r1 < 1)
        
        local r2 = math.random(10, 20)
        assert(r2 >= 10 and r2 <= 20)
    end)
    
    TestFramework.test("Math", "Min/Max", function()
        assert(math.min(5, 2, 8, 1) == 1)
        assert(math.max(5, 2, 8, 1) == 8)
        assert(math.min() == math.huge)
        assert(math.max() == -math.huge)
    end)
    
    TestFramework.test("Math", "Modulo/Fmod", function()
        assert(math.fmod(10, 3) == 1)
        assert(math.fmod(-10, 3) == -1)
        assert(10 % 3 == 1)
    end)
    
    TestFramework.test("Math", "Clamp Function", function()
        assert(math.clamp(5, 1, 10) == 5)
        assert(math.clamp(-5, 1, 10) == 1)
        assert(math.clamp(15, 1, 10) == 10)
    end)
    
    TestFramework.test("Math", "Sign Function", function()
        assert(math.sign(10) == 1)
        assert(math.sign(-10) == -1)
        assert(math.sign(0) == 0)
    end)
    
    TestFramework.test("Math", "Round Function", function()
        assert(math.round(3.5) == 4)
        assert(math.round(3.4) == 3)
        assert(math.round(-3.5) == -4)
    end)
end

local function testStringLibrary()
    TestFramework.category("STRING LIBRARY")
    
    TestFramework.test("String", "Format Advanced", function()
        assert(string.format("%q", "test") == '"test"')
        assert(string.format("%d %x %o", 255, 255, 255) == "255 ff 377")
        assert(string.format("%.2f", math.pi) == "3.14")
        assert(string.format("%10s", "test") == "      test")
    end)
    
    TestFramework.test("String", "Pattern Matching", function()
        assert(string.match("hello world", "^h%w+") == "hello")
        assert(string.match("test123", "%d+") == "123")
        local a, b = string.match("10+20", "(%d+)%+(%d+)")
        assert(a == "10" and b == "20")
    end)
    
    TestFramework.test("String", "Gsub Advanced", function()
        local result = string.gsub("hello world", "(%w+)", "%1!")
        assert(result == "hello! world!")
        
        local count
        result, count = string.gsub("aaa", "a", "b", 2)
        assert(result == "bba" and count == 2)
    end)
    
    TestFramework.test("String", "Find/Sub", function()
        local s, e = string.find("hello world", "world")
        assert(s == 7 and e == 11)
        
        assert(string.sub("hello", 2, 4) == "ell")
        assert(string.sub("hello", -3) == "llo")
    end)
    
    TestFramework.test("String", "Upper/Lower/Reverse", function()
        assert(string.upper("test") == "TEST")
        assert(string.lower("TEST") == "test")
        assert(string.reverse("hello") == "olleh")
    end)
    
    TestFramework.test("String", "Byte/Char", function()
        assert(string.byte("A") == 65)
        assert(string.char(72, 105) == "Hi")
        
        local bytes = {string.byte("ABC", 1, -1)}
        assert(#bytes == 3 and bytes[1] == 65)
    end)
    
    TestFramework.test("String", "Rep/Len", function()
        assert(string.rep("ab", 3) == "ababab")
        assert(string.len("hello") == 5)
        assert(#"world" == 5)
    end)
    
    TestFramework.test("String", "Split Function", function()
        local parts = string.split("a,b,c,d", ",")
        assert(#parts == 4 and parts[2] == "b")
    end)
end

local function testRobloxBasics()
    TestFramework.category("ROBLOX BASICS")
    
    TestFramework.test("Roblox", "Game Hierarchy", function()
        assert(game.Parent == nil)
        assert(game:IsA("DataModel"))
        assert(game.ClassName == "DataModel")
        assert(typeof(game) == "Instance")
    end)
    
    TestFramework.test("Roblox", "Services Access", function()
        local services = {
            "Workspace", "Players", "Lighting", "ReplicatedStorage",
            "ServerStorage", "RunService", "UserInputService"
        }
        
        for _, serviceName in ipairs(services) do
            local service = game:GetService(serviceName)
            assert(service ~= nil, serviceName .. " not found")
        end
    end)
    
    TestFramework.test("Roblox", "Instance Creation", function()
        local part = Instance.new("Part")
        assert(part:IsA("BasePart"))
        assert(part:IsA("Part"))
        assert(part.ClassName == "Part")
        part:Destroy()
    end)
    
    TestFramework.test("Roblox", "Property Manipulation", function()
        local part = Instance.new("Part")
        part.Name = "TestPart"
        part.Size = Vector3.new(5, 10, 15)
        part.Position = Vector3.new(0, 100, 0)
        part.Anchored = true
        part.Material = Enum.Material.Neon
        part.Color = Color3.new(1, 0, 0)
        
        assert(part.Name == "TestPart")
        assert(part.Size == Vector3.new(5, 10, 15))
        part:Destroy()
    end)
    
    TestFramework.test("Roblox", "FindFirstChild/WaitForChild", function()
        local model = Instance.new("Model")
        local part = Instance.new("Part")
        part.Name = "TestPart"
        part.Parent = model
        
        assert(model:FindFirstChild("TestPart") == part)
        assert(model:FindFirstChild("NonExistent") == nil)
        
        local found = model:WaitForChild("TestPart", 1)
        assert(found == part)
    end)
    
    TestFramework.test("Roblox", "GetChildren/GetDescendants", function()
        local model = Instance.new("Model")
        for i = 1, 5 do
            Instance.new("Part").Parent = model
        end
        
        local children = model:GetChildren()
        assert(#children == 5)
        
        local descendants = game:GetDescendants()
        assert(#descendants > 0)
    end)
    
    TestFramework.test("Roblox", "Clone Function", function()
        local original = Instance.new("Part")
        original.Name = "Original"
        original.Size = Vector3.new(1, 2, 3)
        
        local clone = original:Clone()
        assert(clone.Name == "Original")
        assert(clone.Size == original.Size)
        assert(clone ~= original)
    end)
end

local function testRobloxDataTypes()
    TestFramework.category("ROBLOX DATATYPES")
    
    TestFramework.test("DataTypes", "Vector3 Operations", function()
        local v1 = Vector3.new(1, 2, 3)
        local v2 = Vector3.new(4, 5, 6)
        
        assert((v1 + v2) == Vector3.new(5, 7, 9))
        assert((v1 * 2) == Vector3.new(2, 4, 6))
        assert(v1.Magnitude > 0)
        assert(v1.Unit.Magnitude - 1 < 0.001)
        assert(v1:Dot(v2) == 32)
        
        local cross = v1:Cross(v2)
        assert(cross.X == -3 and cross.Y == 6 and cross.Z == -3)
    end)
    
    TestFramework.test("DataTypes", "Vector2 Operations", function()
        local v1 = Vector2.new(3, 4)
        local v2 = Vector2.new(1, 2)
        
        assert(v1.Magnitude == 5)
        assert((v1 + v2) == Vector2.new(4, 6))
        assert(v1:Dot(v2) == 11)
        
        local lerp = v1:Lerp(v2, 0.5)
        assert(lerp == Vector2.new(2, 3))
    end)
    
    TestFramework.test("DataTypes", "CFrame Operations", function()
        local cf1 = CFrame.new(10, 20, 30)
        local cf2 = CFrame.Angles(math.rad(45), 0, 0)
        local combined = cf1 * cf2
        
        assert(cf1.Position == Vector3.new(10, 20, 30))
        assert(cf1:Inverse() * cf1 == CFrame.new())
        
        local lookAt = CFrame.lookAt(Vector3.new(0, 0, 0), Vector3.new(10, 0, 0))
        assert(lookAt.LookVector.X > 0.99)
    end)
    
    TestFramework.test("DataTypes", "Color3 Operations", function()
        local c1 = Color3.new(1, 0, 0)
        local c2 = Color3.fromRGB(0, 255, 0)
        local c3 = Color3.fromHSV(0.5, 1, 1)
        
        local lerp = c1:Lerp(c2, 0.5)
        assert(lerp.R > 0 and lerp.G > 0)
        
        local h, s, v = c3:ToHSV()
        assert(math.abs(h - 0.5) < 0.01)
    end)
    
    TestFramework.test("DataTypes", "UDim2/UDim", function()
        local udim2 = UDim2.new(0.5, 100, 0.5, 50)
        assert(udim2.X.Scale == 0.5 and udim2.X.Offset == 100)
        
        local lerp = udim2:Lerp(UDim2.new(1, 0, 1, 0), 0.5)
        assert(lerp.X.Scale == 0.75)
    end)
    
    TestFramework.test("DataTypes", "Region3", function()
        local region = Region3.new(
            Vector3.new(-10, -10, -10),
            Vector3.new(10, 10, 10)
        )
        
        local parts = workspace:FindPartsInRegion3(region, nil, 100)
        assert(type(parts) == "table")
    end)
    
    TestFramework.test("DataTypes", "Ray/Raycast", function()
        local origin = Vector3.new(0, 100, 0)
        local direction = Vector3.new(0, -200, 0)
        
        local params = RaycastParams.new()
        params.FilterType = Enum.RaycastFilterType.Whitelist
        params.FilterDescendantsInstances = {workspace}
        
        local result = workspace:Raycast(origin, direction, params)
        assert(type(result) == "table" or result == nil)
    end)
    
    TestFramework.test("DataTypes", "NumberSequence/ColorSequence", function()
        local ns = NumberSequence.new({
            NumberSequenceKeypoint.new(0, 0),
            NumberSequenceKeypoint.new(0.5, 1),
            NumberSequenceKeypoint.new(1, 0)
        })
        assert(#ns.Keypoints == 3)
        
        local cs = ColorSequence.new(Color3.new(1, 0, 0), Color3.new(0, 0, 1))
        assert(#cs.Keypoints == 2)
    end)
end

local function testRobloxEvents()
    TestFramework.category("ROBLOX EVENTS")
    
    TestFramework.test("Events", "Changed Event", function()
        local part = Instance.new("Part")
        local fired = false
        
        local conn = part.Changed:Connect(function(prop)
            if prop == "Position" then fired = true end
        end)
        
        part.Position = Vector3.new(10, 10, 10)
        task.wait(0.1)
        
        conn:Disconnect()
        assert(fired)
        part:Destroy()
    end)
    
    TestFramework.test("Events", "ChildAdded/Removed", function()
        local model = Instance.new("Model")
        local added, removed = false, false
        
        model.ChildAdded:Connect(function() added = true end)
        model.ChildRemoved:Connect(function() removed = true end)
        
        local part = Instance.new("Part")
        part.Parent = model
        part.Parent = nil
        
        task.wait(0.1)
        assert(added and removed)
    end)
    
    TestFramework.test("Events", "Custom BindableEvent", function()
        local bindable = Instance.new("BindableEvent")
        local received = nil
        
        bindable.Event:Connect(function(data)
            received = data
        end)
        
        bindable:Fire({test = "data", value = 123})
        task.wait(0.1)
        
        assert(received and received.test == "data")
        bindable:Destroy()
    end)
    
    TestFramework.test("Events", "Multiple Connections", function()
        local part = Instance.new("Part")
        local count = 0
        
        local conns = {}
        for i = 1, 3 do
            table.insert(conns, part.Changed:Connect(function()
                count = count + 1
            end))
        end
        
        part.Anchored = true
        task.wait(0.1)
        
        for _, conn in ipairs(conns) do
            conn:Disconnect()
        end
        
        assert(count == 3)
        part:Destroy()
    end)
end

local function testEnvironmentFunctions()
    TestFramework.category("ENVIRONMENT")
    
    TestFramework.test("Environment", "Getgenv", function()
        local env = getgenv()
        env.ZUNC_TEST = "success"
        assert(env.ZUNC_TEST == "success")
        env.ZUNC_TEST = nil
    end)
    
    TestFramework.test("Environment", "Getrenv", function()
        local renv = getrenv()
        assert(type(renv) == "table")
        assert(renv._G ~= nil)
        assert(renv.game ~= nil)
    end)
    
    TestFramework.test("Environment", "Getsenv", function()
        local senv = getsenv(script)
        assert(type(senv) == "table")
    end)
    
    TestFramework.test("Environment", "Getfenv/Setfenv", function()
        local function testFunc() return _ENV end
        local env = getfenv(testFunc)
        assert(type(env) == "table")
        
        local newEnv = {test = "value"}
        setmetatable(newEnv, {__index = _G})
        setfenv(testFunc, newEnv)
        assert(getfenv(testFunc) == newEnv)
    end)
    
    TestFramework.test("Environment", "Checkcaller", function()
        local result = checkcaller()
        assert(type(result) == "boolean")
    end)
    
    TestFramework.test("Environment", "Islclosure", function()
        local luaFunc = function() end
        local cFunc = print
        assert(islclosure(luaFunc) == true)
    end)
    
    TestFramework.test("Environment", "Newcclosure", function()
        local wrapped = newcclosure(function(x) return x * 2 end)
        assert(wrapped(5) == 10)
        assert(not islclosure(wrapped))
    end)
    
    TestFramework.test("Environment", "GetThreadIdentity", function()
        local identity = getthreadidentity()
        assert(type(identity) == "number")
        assert(identity >= 0)
    end)
    
    TestFramework.test("Environment", "SetThreadIdentity", function()
        local original = getthreadidentity()
        setthreadidentity(2)
        assert(getthreadidentity() == 2)
        setthreadidentity(original)
    end)
end

local function testMetatableFunctions()
    TestFramework.category("METATABLE MANIPULATION")
    
    TestFramework.test("Metatable", "Getrawmetatable", function()
        local mt = getrawmetatable(game)
        assert(type(mt) == "table")
        assert(mt.__index ~= nil)
        assert(mt.__newindex ~= nil)
    end)
    
    TestFramework.test("Metatable", "Setrawmetatable", function()
        local tbl = {}
        local mt = {
            __index = function(t, k) return "hooked_" .. k end,
            __newindex = function(t, k, v) rawset(t, k .. "_modified", v) end
        }
        setrawmetatable(tbl, mt)
        assert(tbl.test == "hooked_test")
        tbl.key = "value"
        assert(rawget(tbl, "key_modified") == "value")
    end)
    
    TestFramework.test("Metatable", "Setreadonly", function()
        local tbl = {test = "value"}
        setreadonly(tbl, true)
        local success = pcall(function()
            tbl.test = "new"
        end)
        assert(not success)
        setreadonly(tbl, false)
        tbl.test = "new"
        assert(tbl.test == "new")
    end)
    
    TestFramework.test("Metatable", "Isreadonly", function()
        local tbl = {}
        assert(isreadonly(tbl) == false)
        setreadonly(tbl, true)
        assert(isreadonly(tbl) == true)
        setreadonly(tbl, false)
    end)
    
    TestFramework.test("Metatable", "Makereadonly/Makewritable", function()
        local tbl = {a = 1}
        makereadonly(tbl)
        assert(isreadonly(tbl))
        makewritable(tbl)
        assert(not isreadonly(tbl))
    end)
end

local function testHookingFunctions()
    TestFramework.category("HOOKING")
    
    TestFramework.test("Hooking", "Hookfunction", function()
        local callCount = 0
        local original = print
        
        local hook = hookfunction(print, function(...)
            callCount = callCount + 1
            return original(...)
        end)
        
        print("test")
        assert(callCount >= 1)
    end)
    
    TestFramework.test("Hooking", "Hookmetamethod", function()
        local part = Instance.new("Part")
        local mt = getrawmetatable(part)
        local oldIndex = mt.__index
        
        hookmetamethod(game, "__index", function(self, key)
            if key == "HookedProperty" then
                return "Hooked!"
            end
            return oldIndex(self, key)
        end)
        
        assert(game.HookedProperty == "Hooked!")
    end)
    
    TestFramework.test("Hooking", "Getnamecallmethod", function()
        local part = Instance.new("Part")
        local method
        
        local mt = getrawmetatable(part)
        local oldNamecall = mt.__namecall
        
        mt.__namecall = newcclosure(function(self, ...)
            method = getnamecallmethod()
            return oldNamecall(self, ...)
        end)
        
        pcall(function() part:IsA("BasePart") end)
        assert(method == "IsA")
    end)
    
    TestFramework.test("Hooking", "Setnamecallmethod", function()
        setnamecallmethod("TestMethod")
        assert(getnamecallmethod() == "TestMethod")
    end)
end

local function testDebugLibrary()
    TestFramework.category("DEBUG LIBRARY")
    
    TestFramework.test("Debug", "Debug.info", function()
        local info = debug.info(print, "slnfa")
        assert(type(info) == "table")
        assert(info.source ~= nil)
    end)
    
    TestFramework.test("Debug", "Debug.traceback", function()
        local trace = debug.traceback("Test message", 1)
        assert(type(trace) == "string")
        assert(trace:find("Test message") ~= nil)
    end)
    
    TestFramework.test("Debug", "Debug.profilebegin/end", function()
        debug.profilebegin("ZUNC_Test")
        for i = 1, 1000 do end
        debug.profileend()
    end)
    
    TestFramework.test("Debug", "Debug.getupvalue", function()
        local x = 10
        local function closure() return x end
        local name, value = debug.getupvalue(closure, 1)
        assert(name == "x" and value == 10)
    end)
    
    TestFramework.test("Debug", "Debug.setupvalue", function()
        local x = 10
        local function closure() return x end
        debug.setupvalue(closure, 1, 20)
        assert(closure() == 20)
    end)
    
    TestFramework.test("Debug", "Debug.getprotos", function()
        local function outer()
            local function inner1() end
            local function inner2() end
        end
        local protos = debug.getprotos(outer)
        assert(type(protos) == "table")
        assert(#protos >= 2)
    end)
    
    TestFramework.test("Debug", "Debug.getstack", function()
        local function level3() return debug.getstack(1) end
        local function level2() return level3() end
        local function level1() return level2() end
        local stack = level1()
        assert(type(stack) == "table")
    end)
    
    TestFramework.test("Debug", "Debug.getconstant", function()
        local function test() return "constant" end
        local constant = debug.getconstant(test, 1)
        assert(constant == "constant")
    end)
    
    TestFramework.test("Debug", "Debug.getconstants", function()
        local function test()
            local a = "test"
            local b = 123
            return a, b
        end
        local constants = debug.getconstants(test)
        assert(type(constants) == "table")
        assert(#constants > 0)
    end)
    
    TestFramework.test("Debug", "Debug.getlocal", function()
        local testVar = "local_value"
        local name, value = debug.getlocal(1, 1)
        assert(name == "testVar" and value == "local_value")
    end)
    
    TestFramework.test("Debug", "Debug.setlocal", function()
        local testVar = "old"
        debug.setlocal(1, 1, "new")
        assert(testVar == "new")
    end)
end

local function testMemoryFunctions()
    TestFramework.category("MEMORY & GC")
    
    TestFramework.test("Memory", "Getgc", function()
        local gc = getgc(true)
        assert(type(gc) == "table")
        assert(#gc > 0)
    end)
    
    TestFramework.test("Memory", "Getreg", function()
        local reg = getreg()
        assert(type(reg) == "table")
        assert(#reg > 0)
    end)
    
    TestFramework.test("Memory", "Getupvalues", function()
        local x, y = 10, 20
        local function closure() return x + y end
        local upvals = getupvalues(closure)
        assert(type(upvals) == "table")
    end)
    
    TestFramework.test("Memory", "Getprotos", function()
        local function parent()
            local function child1() end
            local function child2() end
        end
        local protos = getprotos(parent)
        assert(type(protos) == "table")
    end)
    
    TestFramework.test("Memory", "Getinfo", function()
        local info = getinfo(print)
        assert(type(info) == "table")
        assert(info.what ~= nil)
    end)
    
    TestFramework.test("Memory", "Getconstants", function()
        local function test() return "hello", 123 end
        local constants = getconstants(test)
        assert(type(constants) == "table")
    end)
    
    TestFramework.test("Memory", "Getlocals", function()
        local a, b = 1, 2
        local locals = getlocals(1)
        assert(type(locals) == "table")
    end)
end

local function testInstanceFunctions()
    TestFramework.category("INSTANCE MANIPULATION")
    
    TestFramework.test("Instance", "Getnilinstances", function()
        local part = Instance.new("Part")
        local nilInstances = getnilinstances()
        assert(type(nilInstances) == "table")
        part:Destroy()
    end)
    
    TestFramework.test("Instance", "Getinstances", function()
        local instances = getinstances()
        assert(type(instances) == "table")
        assert(#instances > 0)
    end)
    
    TestFramework.test("Instance", "Getscripts", function()
        local scripts = getscripts()
        assert(type(scripts) == "table")
    end)
    
    TestFramework.test("Instance", "Getloadedmodules", function()
        local modules = getloadedmodules()
        assert(type(modules) == "table")
    end)
    
    TestFramework.test("Instance", "Getconnections", function()
        local part = Instance.new("Part")
        local conn = part.Changed:Connect(function() end)
        local connections = getconnections(part.Changed)
        assert(type(connections) == "table")
        conn:Disconnect()
        part:Destroy()
    end)
    
    TestFramework.test("Instance", "Firesignal", function()
        local event = Instance.new("BindableEvent")
        local fired = false
        event.Event:Connect(function() fired = true end)
        firesignal(event.Event)
        task.wait(0.1)
        assert(fired)
        event:Destroy()
    end)
    
    TestFramework.test("Instance", "Fireclickdetector", function()
        local detector = Instance.new("ClickDetector")
        local clicked = false
        detector.MouseClick:Connect(function() clicked = true end)
        fireclickdetector(detector, 5)
        task.wait(0.1)
        assert(clicked)
        detector:Destroy()
    end)
    
    TestFramework.test("Instance", "Fireproximityprompt", function()
        local prompt = Instance.new("ProximityPrompt")
        local triggered = false
        prompt.Triggered:Connect(function() triggered = true end)
        fireproximityprompt(prompt)
        task.wait(0.1)
        assert(triggered)
        prompt:Destroy()
    end)
    
    TestFramework.test("Instance", "Firetouchinterest", function()
        local part1 = Instance.new("Part")
        local part2 = Instance.new("Part")
        local touched = false
        part1.Touched:Connect(function(hit)
            if hit == part2 then touched = true end
        end)
        firetouchinterest(part1, part2, 0)
        task.wait(0.1)
        firetouchinterest(part1, part2, 1)
        assert(touched)
        part1:Destroy()
        part2:Destroy()
    end)
end

local function testUIFunctions()
    TestFramework.category("UI & INPUT")
    
    TestFramework.test("UI", "Mouse Functions", function()
        mousemoveabs(100, 100)
        task.wait(0.05)
        mousemoverel(10, 10)
        task.wait(0.05)
        mousescroll(5)
    end)
    
    TestFramework.test("UI", "Mouse Clicks", function()
        mouse1click()
        task.wait(0.05)
        mouse2click()
        task.wait(0.05)
        mouse1press()
        task.wait(0.05)
        mouse1release()
        task.wait(0.05)
        mouse2press()
        task.wait(0.05)
        mouse2release()
    end)
    
    TestFramework.test("UI", "Keyboard Input", function()
        keypress(0x41) -- A key
        task.wait(0.05)
        keyrelease(0x41)
        task.wait(0.05)
    end)
    
    TestFramework.test("UI", "Clipboard", function()
        local testData = "ZUNC_Test_" .. os.time()
        setclipboard(testData)
    end)
    
    TestFramework.test("UI", "ScreenGui Creation", function()
        local sg = Instance.new("ScreenGui")
        local frame = Instance.new("Frame")
        frame.Size = UDim2.new(0, 200, 0, 200)
        frame.Position = UDim2.new(0.5, -100, 0.5, -100)
        frame.Parent = sg
        assert(sg:FindFirstChild("Frame") ~= nil)
        sg:Destroy()
    end)
end

local function testDrawingFunctions()
    TestFramework.category("DRAWING LIBRARY")
    
    TestFramework.test("Drawing", "Line Creation", function()
        local line = Drawing.new("Line")
        line.Visible = true
        line.From = Vector2.new(100, 100)
        line.To = Vector2.new(200, 200)
        line.Color = Color3.new(1, 0, 0)
        line.Thickness = 2
        assert(line.From == Vector2.new(100, 100))
        line:Remove()
    end)
    
    TestFramework.test("Drawing", "Circle Creation", function()
        local circle = Drawing.new("Circle")
        circle.Visible = true
        circle.Position = Vector2.new(300, 300)
        circle.Radius = 50
        circle.Color = Color3.new(0, 1, 0)
        circle.Filled = true
        circle.NumSides = 32
        assert(circle.Radius == 50)
        circle:Remove()
    end)
    
    TestFramework.test("Drawing", "Square Creation", function()
        local square = Drawing.new("Square")
        square.Visible = true
        square.Size = Vector2.new(100, 100)
        square.Position = Vector2.new(400, 100)
        square.Color = Color3.new(0, 0, 1)
        square.Filled = true
        assert(square.Size == Vector2.new(100, 100))
        square:Remove()
    end)
    
    TestFramework.test("Drawing", "Text Creation", function()
        local text = Drawing.new("Text")
        text.Visible = true
        text.Text = "ZUNC Test"
        text.Size = 24
        text.Position = Vector2.new(500, 500)
        text.Color = Color3.new(1, 1, 1)
        text.Center = true
        text.Outline = true
        assert(text.Text == "ZUNC Test")
        text:Remove()
    end)
    
    TestFramework.test("Drawing", "Triangle Creation", function()
        local tri = Drawing.new("Triangle")
        tri.Visible = true
        tri.PointA = Vector2.new(100, 100)
        tri.PointB = Vector2.new(200, 200)
        tri.PointC = Vector2.new(100, 200)
        tri.Color = Color3.new(1, 0, 1)
        tri.Filled = true
        assert(tri.PointA == Vector2.new(100, 100))
        tri:Remove()
    end)
    
    TestFramework.test("Drawing", "Quad Creation", function()
        local quad = Drawing.new("Quad")
        quad.Visible = true
        quad.PointA = Vector2.new(300, 100)
        quad.PointB = Vector2.new(400, 100)
        quad.PointC = Vector2.new(400, 200)
        quad.PointD = Vector2.new(300, 200)
        quad.Color = Color3.new(1, 1, 0)
        quad.Filled = true
        assert(quad.PointA == Vector2.new(300, 100))
        quad:Remove()
    end)
end

local function testFileSystemFunctions()
    TestFramework.category("FILESYSTEM")
    
    TestFramework.test("FileSystem", "Folder Operations", function()
        makefolder("ZUNC_Test")
        makefolder("ZUNC_Test/SubFolder")
        assert(isfolder("ZUNC_Test"))
        assert(isfolder("ZUNC_Test/SubFolder"))
        delfolder("ZUNC_Test/SubFolder")
        delfolder("ZUNC_Test")
    end)
    
    TestFramework.test("FileSystem", "File Write/Read", function()
        local testContent = "ZUNC Test Content: " .. os.time()
        writefile("zunc_test.txt", testContent)
        assert(isfile("zunc_test.txt"))
        local content = readfile("zunc_test.txt")
        assert(content == testContent)
        delfile("zunc_test.txt")
    end)
    
    TestFramework.test("FileSystem", "Append File", function()
        writefile("zunc_append.txt", "Line 1\n")
        appendfile("zunc_append.txt", "Line 2\n")
        appendfile("zunc_append.txt", "Line 3\n")
        local content = readfile("zunc_append.txt")
        assert(content:find("Line 1") ~= nil)
        assert(content:find("Line 3") ~= nil)
        delfile("zunc_append.txt")
    end)
    
    TestFramework.test("FileSystem", "List Files", function()
        makefolder("ZUNC_List")
        writefile("ZUNC_List/file1.txt", "test")
        writefile("ZUNC_List/file2.txt", "test")
        local files = listfiles("ZUNC_List")
        assert(#files >= 2)
        delfile("ZUNC_List/file1.txt")
        delfile("ZUNC_List/file2.txt")
        delfolder("ZUNC_List")
    end)
    
    TestFramework.test("FileSystem", "Loadfile", function()
        writefile("zunc_script.lua", "return function(x) return x * 2 end")
        local func = loadfile("zunc_script.lua")()
        assert(func(10) == 20)
        delfile("zunc_script.lua")
    end)
end

local function testNetworkFunctions()
    TestFramework.category("NETWORK")
    
    TestFramework.test("Network", "HttpGet", function()
        local response = game:HttpGet("https://httpbin.org/get")
        assert(type(response) == "string")
        assert(response:find("httpbin") ~= nil)
    end)
    
    TestFramework.test("Network", "HttpPost", function()
        local data = game:GetService("HttpService"):JSONEncode({
            test = "ZUNC",
            timestamp = os.time()
        })
        local response = game:HttpPost("https://httpbin.org/post", data)
        assert(type(response) == "string")
    end)
    
    TestFramework.test("Network", "Request Function", function()
        local response = request({
            Url = "https://httpbin.org/get",
            Method = "GET"
        })
        assert(response.Success == true)
        assert(type(response.Body) == "string")
    end)
    
    TestFramework.test("Network", "HttpService JSONEncode/Decode", function()
        local HttpService = game:GetService("HttpService")
        local data = {
            string = "test",
            number = 123,
            boolean = true,
            table = {nested = "value"}
        }
        local encoded = HttpService:JSONEncode(data)
        local decoded = HttpService:JSONDecode(encoded)
        assert(decoded.string == "test")
        assert(decoded.number == 123)
        assert(decoded.table.nested == "value")
    end)
end

local function testMiscFunctions()
    TestFramework.category("MISCELLANEOUS")
    
    TestFramework.test("Misc", "Identifyexecutor", function()
        local executor = identifyexecutor()
        assert(type(executor) == "string")
    end)

    local nameForTest = tostring(getexecutorname() or "Executor desconhecido")

    TestFramework.test("Misc", nameForTest, function()
        local executor = identifyexecutor()
        assert(type(executor) == "string")
    end)


    TestFramework.test("Misc", "Getexecutorname", function()
        local name = getexecutorname()
        assert(type(name) == "string")
    end)
    
    TestFramework.test("Misc", "Queue_on_teleport", function()
        queue_on_teleport([[
            print("ZUNC: Teleport test")
        ]])
    end)
    
    TestFramework.test("Misc", "Saveinstance", function()
        local part = Instance.new("Part")
        part.Name = "TestPart"
        -- Just test if function exists
        assert(type(saveinstance) == "function")
        part:Destroy()
    end)
    
    TestFramework.test("Misc", "Messagebox", function()
        -- Just verify function exists
        assert(type(messagebox) == "function")
    end)
    
    TestFramework.test("Misc", "Getfpscap", function()
        local cap = getfpscap()
        assert(type(cap) == "number")
    end)
    
    TestFramework.test("Misc", "Setfpscap", function()
        local original = getfpscap()
        setfpscap(60)
        assert(getfpscap() == 60)
        setfpscap(original)
    end)
end

local function testAdvancedFeatures()
    TestFramework.category("ADVANCED FEATURES")
    
    TestFramework.test("Advanced", "Complex Closure", function()
        local function createCounter()
            local count = 0
            return function(increment)
                count = count + (increment or 1)
                return count
            end
        end
        
        local counter = createCounter()
        assert(counter() == 1)
        assert(counter(5) == 6)
        assert(counter() == 7)
    end)
    
    TestFramework.test("Advanced", "Recursive Function", function()
        local function factorial(n)
            if n <= 1 then return 1 end
            return n * factorial(n - 1)
        end
        assert(factorial(5) == 120)
        assert(factorial(10) == 3628800)
    end)
    
    TestFramework.test("Advanced", "Memoization", function()
        local cache = {}
        local function fibonacci(n)
            if cache[n] then return cache[n] end
            if n <= 1 then return n end
            cache[n] = fibonacci(n-1) + fibonacci(n-2)
            return cache[n]
        end
        assert(fibonacci(20) == 6765)
    end)
    
    TestFramework.test("Advanced", "Custom Iterator", function()
        local function range(from, to, step)
            step = step or 1
            return function(_, current)
                current = current + step
                if current <= to then
                    return current
                end
            end, nil, from - step
        end
        
        local sum = 0
        for i in range(1, 10, 2) do
            sum = sum + i
        end
        assert(sum == 25)
    end)
    
    TestFramework.test("Advanced", "Weak Tables", function()
        local weak = setmetatable({}, {__mode = "v"})
        weak.key = {value = "test"}
        assert(weak.key ~= nil)
        collectgarbage()
    end)
    
    TestFramework.test("Advanced", "Bitwise Operations", function()
        assert(bit32.band(0xF0, 0x0F) == 0)
        assert(bit32.bor(0xF0, 0x0F) == 0xFF)
        assert(bit32.bxor(0xFF, 0x0F) == 0xF0)
        assert(bit32.lshift(1, 4) == 16)
        assert(bit32.rshift(16, 4) == 1)
    end)
end

local function runAllTests()
    print([[
╔══════════════════════════════════════════════════════════╗
║                                                          ║
║     ███████╗██╗   ██╗███╗   ██╗ ██████╗                ║
║     ╚══███╔╝██║   ██║████╗  ██║██╔════╝                ║
║       ███╔╝ ██║   ██║██╔██╗ ██║██║                     ║
║      ███╔╝  ██║   ██║██║╚██╗██║██║                     ║
║     ███████╗╚██████╔╝██║ ╚████║╚██████╗                ║
║     ╚══════╝ ╚═════╝ ╚═╝  ╚═══╝ ╚═════╝                ║
║                                                          ║
║          Advanced Executor Test Suite v]] .. ZUNC_CONFIG.version .. [[           ║
║                                                          ║
╚══════════════════════════════════════════════════════════╝
]])
    
    print(string.format("⏰ Test Started: %s\n", os.date("%Y-%m-%d %H:%M:%S")))
    
    testLuaCore()
    testTableLibrary()
    testMathLibrary()
    testStringLibrary()
    testRobloxBasics()
    testRobloxDataTypes()
    testRobloxEvents()
    testEnvironmentFunctions()
    testMetatableFunctions()
    testHookingFunctions()
    testDebugLibrary()
    testMemoryFunctions()
    testInstanceFunctions()
    testUIFunctions()
    testDrawingFunctions()
    testFileSystemFunctions()
    testNetworkFunctions()
    testMiscFunctions()
    testAdvancedFeatures()
    
    Utils.generateReport()
end

-- Execute
runAllTests()
