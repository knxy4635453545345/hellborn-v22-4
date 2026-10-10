-- ============================================================
-- HELLBORN v22.5 — FUNCIONAL
-- Insert = abre/fecha menu | Q = auto flick
-- ============================================================

local SV = {
    P=game:GetService("Players"), U=game:GetService("UserInputService"),
    R=game:GetService("RunService"), T=game:GetService("TweenService"),
    L=game:GetService("Lighting"), S=game:GetService("SoundService"),
    H=game:GetService("HttpService"),
}
local LP = SV.P.LocalPlayer
local Cam = workspace.CurrentCamera
local PG = LP:FindFirstChild("PlayerGui") or LP:WaitForChild("PlayerGui", 10)
if not PG then warn("[HB] Sem PlayerGui"); return end

local SID = tostring(math.random(10000000, 99999999))
local GNAME = "cfg_"..SID
local HNAME = "hl_"..SID

local function Create(c, p)
    local i = Instance.new(c); local parent = nil
    for k, v in pairs(p) do
        if k == "Parent" then parent = v else pcall(function() i[k] = v end) end
    end
    if parent then i.Parent = parent end
    return i
end
local tick = tick or os.clock

-- ═══ STATE ═══
local State = {
    AutoFlick = true, AutoFlickKey = Enum.KeyCode.Q,
    TriggerBot = true, TriggerRadius = 40,
    SilentAim = true, AIEnabled = true, KillConfirm = true,
    ESP = false, ESPName = true,
    HitmarkerEnabled = true, KillFeedEnabled = true,
    PingRealtime = true, UI_Sounds = true,
    Kills = 0, Deaths = 0, GUI_Visible = true,
    AntiFling2 = true, AntiRagdoll = true,
}
local Colors = {
    Background=Color3.fromRGB(12,12,12), Sidebar=Color3.fromRGB(22,22,22),
    Accent=Color3.fromRGB(200,20,20), Text=Color3.fromRGB(240,240,240),
    SubText=Color3.fromRGB(140,140,140), ElementBg=Color3.fromRGB(32,32,32),
    ToggleOff=Color3.fromRGB(55,55,55), Success=Color3.fromRGB(0,200,100),
    Warning=Color3.fromRGB(255,180,0), Danger=Color3.fromRGB(255,60,60),
    Border=Color3.fromRGB(80,15,15),
}

-- ═══ PING TRACKER ═══
local Ping = {samples={}, avg=0.05, jitter=0, lastBeat=0}
task.spawn(function()
    while task.wait(0.5) do
        local now = tick()
        if Ping.lastBeat > 0 then
            table.insert(Ping.samples, now - Ping.lastBeat)
            if #Ping.samples > 20 then table.remove(Ping.samples, 1) end
            local sum, mn, mx = 0, math.huge, 0
            for _, v in ipairs(Ping.samples) do sum=sum+v; if v<mn then mn=v end; if v>mx then mx=v end end
            Ping.avg = sum / #Ping.samples; Ping.jitter = mx - mn
        end
        Ping.lastBeat = now
    end
end)

-- ═══ CACHE ═══
local CACHE = {Characters={}, HeadParts={}, HRPParts={}, PlayersList={}, PlayerSet={}}
local function RebuildPlayerList()
    local t = {}
    for p in pairs(CACHE.PlayerSet) do t[#t+1] = p end
    CACHE.PlayersList = t
end
local function HookCharacter(p)
    p.CharacterAdded:Connect(function(c)
        CACHE.Characters[p]=c; task.wait(0.25)
        CACHE.HeadParts[p]=c:FindFirstChild("Head")
        CACHE.HRPParts[p]=c:FindFirstChild("HumanoidRootPart")
    end)
    if p.Character then
        CACHE.Characters[p]=p.Character
        CACHE.HeadParts[p]=p.Character:FindFirstChild("Head")
        CACHE.HRPParts[p]=p.Character:FindFirstChild("HumanoidRootPart")
    end
end
local function AddPlayer(p) CACHE.PlayerSet[p]=true; HookCharacter(p); RebuildPlayerList() end
local function RemovePlayer(p)
    CACHE.PlayerSet[p]=nil; CACHE.Characters[p]=nil; CACHE.HeadParts[p]=nil; CACHE.HRPParts[p]=nil
    RebuildPlayerList()
end
for _, p in pairs(SV.P:GetPlayers()) do AddPlayer(p) end
SV.P.PlayerAdded:Connect(AddPlayer)
SV.P.PlayerRemoving:Connect(RemovePlayer)
LP.CharacterAdded:Connect(function() task.wait(0.5); Cam=workspace.CurrentCamera end)

-- ═══ ROLE ═══
local MURDERER_TOOLS = {"Knife","Cleaver","Blade"}
local SHERIFF_TOOLS = {"Gun","Revolver"}
local function containerHasTool(c, names)
    if not c then return false end
    for _, obj in ipairs(c:GetChildren()) do
        if obj:IsA("Tool") then
            for _, n in ipairs(names) do if obj.Name == n then return true end end
        end
    end
    return false
end
local function playerHasTool(p, names)
    local char = CACHE.Characters[p] or p.Character
    if not char or not char.Parent then return false end
    local hum = char:FindFirstChildOfClass("Humanoid")
    if not hum or hum.Health <= 0 then return false end
    if containerHasTool(char, names) then return true end
    local bp = p:FindFirstChild("Backpack")
    if bp and containerHasTool(bp, names) then return true end
    return false
end
local function detectRole(p)
    if not p then return nil end
    local char = CACHE.Characters[p] or p.Character
    if not char or not char.Parent then return nil end
    local hum = char:FindFirstChildOfClass("Humanoid")
    if not hum or hum.Health <= 0 then return nil end
    local ok, attr = pcall(function() return p:GetAttribute("Role") or p:GetAttribute("role") end)
    if ok and attr then
        local r = tostring(attr):lower()
        if r:find("murder") or r:find("killer") then return "Murderer" end
        if r:find("sheriff") or r:find("cop") then return "Sheriff" end
    end
    if playerHasTool(p, MURDERER_TOOLS) then return "Murderer" end
    if playerHasTool(p, SHERIFF_TOOLS) then return "Sheriff" end
    return "Innocent"
end
local function getRole(p) return p and (detectRole(p) or "Innocent") or "Innocent" end

-- ═══ IA HISTÓRICO ═══
local Histories = {}
local function getHistory(p)
    if not Histories[p] then
        Histories[p] = {
            samples={}, kalman={x={0,0,0,0,0,0}, lastT=0, gain=0.35},
            velocity=Vector3.zero, prevVel=nil, acceleration=Vector3.zero,
            jitter=0, stability=1, lastPos=nil, lastTime=0,
        }
    end
    return Histories[p]
end
local function kalmanUpdate(k, pos, t)
    if k.lastT == 0 then k.lastT = t end
    local dt = math.max(t - k.lastT, 1/120); k.lastT = t
    for i, axis in ipairs({"X","Y","Z"}) do
        local m = pos[axis]
        local pred = k.x[i] + k.x[i+3] * dt
        local err = m - pred
        k.x[i] = pred + k.gain * err
        k.x[i+3] = k.x[i+3] + (err/dt) * 0.4
    end
end
local function kalmanPredict(k, dt)
    return Vector3.new(k.x[1]+k.x[4]*dt, k.x[2]+k.x[5]*dt, k.x[3]+k.x[6]*dt)
end
local function updateHistory(p, pos)
    local h = getHistory(p); local now = tick()
    kalmanUpdate(h.kalman, pos, now)
    table.insert(h.samples, {pos=pos, t=now})
    if #h.samples > 60 then table.remove(h.samples, 1) end
    if h.lastPos and h.lastTime > 0 then
        local dt = now - h.lastTime
        if dt > 0.001 then
            local v = (pos - h.lastPos) / dt
            h.velocity = h.velocity:Lerp(v, 0.4)
            if h.prevVel then h.acceleration = h.acceleration:Lerp((h.velocity-h.prevVel)/dt, 0.25) end
            h.prevVel = h.velocity
        end
    end
    h.lastPos = pos; h.lastTime = now
    local n = #h.samples
    if n >= 5 then
        local sum = 0
        for i = n-4, n do if i > 1 then sum = sum + (h.samples[i].pos - h.samples[i-1].pos).Magnitude end end
        h.jitter = sum/4; h.stability = math.clamp(1 - h.jitter*2, 0, 1)
    end
end
local function computePreciseAim(targetPlayer, targetChar, camPos, speed)
    if not targetChar or not targetChar.Parent then return nil end
    local head = targetChar:FindFirstChild("Head"); if not head then return nil end
    local h = getHistory(targetPlayer); local posNow = head.Position
    local dist = (posNow - camPos).Magnitude
    local pingComp = LP:GetNetworkPing() * 0.5 + Ping.jitter * 0.5
    local totalTime = dist / speed + pingComp + 0.010
    local predicted
    for _ = 1, 3 do
        local futurePos = posNow + h.velocity * totalTime + h.acceleration * 0.5 * totalTime * totalTime
        if h.stability > 0.4 and #h.samples >= 10 then
            futurePos = kalmanPredict(h.kalman, totalTime):Lerp(futurePos, 0.5 + h.stability * 0.3)
        end
        predicted = futurePos
        local nd = (predicted - camPos).Magnitude
        if math.abs(nd - dist) < 0.1 then break end
        dist = nd; totalTime = dist / speed + pingComp + 0.010
    end
    local offset = predicted - posNow
    local maxOff = dist * 0.35
    if offset.Magnitude > maxOff then predicted = posNow + offset.Unit * maxOff end
    return predicted, totalTime, dist
end
task.spawn(function()
    while task.wait(1/60) do
        if not State.AIEnabled then continue end
        local lpHrp = CACHE.HRPParts[LP]; if not lpHrp then continue end
        for _, p in ipairs(CACHE.PlayersList) do
            if p == LP then continue end
            local hrp = CACHE.HRPParts[p]
            if hrp and (hrp.Position - lpHrp.Position).Magnitude < 500 then updateHistory(p, hrp.Position) end
        end
    end
end)

-- ═══ SILENT ═══
local Silent = {enabled=true, restoreDelay=0.120, bulletSpeed=2500}
local _lastFireTime = 0
local function mouseSpoofTo(aimPos)
    if not mousemoverel then return nil end
    local vp, on = Cam:WorldToViewportPoint(aimPos)
    if not on then return nil end
    local cur = SV.U:GetMouseLocation()
    local dx, dy = vp.X - cur.X, vp.Y - cur.Y
    if math.abs(dx) < 0.5 and math.abs(dy) < 0.5 then return nil end
    pcall(mousemoverel, dx, dy)
    return function() pcall(mousemoverel, -dx, -dy) end
end
local function Silent_fire(tool, aimPos)
    if not tool or not aimPos then return false end
    if tick() - _lastFireTime < 0.25 then return false end
    _lastFireTime = tick()
    local handle = tool:FindFirstChild("Handle")
    local lpChar = LP.Character
    if not handle or not lpChar then return false end
    local lpHrp = lpChar:FindFirstChild("HumanoidRootPart")
    local lpHead = lpChar:FindFirstChild("Head")
    local hum = lpChar:FindFirstChildOfClass("Humanoid")
    local sHandle, sHrp, sHead, sAuto = handle.CFrame, lpHrp and lpHrp.CFrame, lpHead and lpHead.CFrame, hum and hum.AutoRotate
    if hum then hum.AutoRotate = false end
    if lpHrp then
        local flat = Vector3.new(aimPos.X, lpHrp.Position.Y, aimPos.Z)
        if (flat - lpHrp.Position).Magnitude > 0.1 then lpHrp.CFrame = CFrame.lookAt(lpHrp.Position, flat) end
    end
    if lpHead then lpHead.CFrame = CFrame.lookAt(lpHead.Position, aimPos) end
    handle.CFrame = CFrame.lookAt(handle.Position, aimPos)
    local restoreMouse = mouseSpoofTo(aimPos)
    local ok = pcall(function() tool:Activate() end)
    local delay = Silent.restoreDelay + (LP:GetNetworkPing() * 1.5) + 0.10
    task.delay(delay, function()
        if restoreMouse then restoreMouse() end
        if handle and handle.Parent then handle.CFrame = sHandle end
        if lpHrp and lpHrp.Parent and sHrp then lpHrp.CFrame = sHrp end
        if lpHead and lpHead.Parent and sHead then lpHead.CFrame = sHead end
        if hum and hum.Parent and sAuto ~= nil then hum.AutoRotate = sAuto end
    end)
    return ok
end

-- ═══ SONS ═══
local UISounds = {}
for i = 1, 6 do
    local s = Instance.new("Sound")
    s.SoundId = "rbxassetid://6895079853"; s.Volume = 0.25; s.Parent = SV.S
    UISounds[i] = s
end
local SIdx = 1
local function PlayUISound(pitch)
    if not State.UI_Sounds then return end
    local s = UISounds[SIdx]; SIdx = SIdx % #UISounds + 1
    s.PlaybackSpeed = pitch or 1; pcall(function() s:Play() end)
end
local AimbotBeep = Instance.new("Sound")
AimbotBeep.SoundId = "rbxassetid://9114375867"; AimbotBeep.Volume = 0.15; AimbotBeep.Parent = SV.S
local function PlayAimBeep()
    if not State.SilentAim then return end
    pcall(function() AimbotBeep:Play() end)
end

-- ═══════════════════════════════════════════════════════════
-- MENU - ABRE DIRETO NO TAMANHO CERTO (não depende de animação)
-- ═══════════════════════════════════════════════════════════
local UI = {}
UI.Screen = Create("ScreenGui", {
    Name = GNAME, ResetOnSpawn = false, IgnoreGuiInset = true, Parent = PG,
})

local MW, MH = 340, 440
UI.Main = Create("Frame", {
    Name = "Main",
    Size = UDim2.new(0, MW, 0, MH),                       -- ⭐ TAMANHO DIRETO
    Position = UDim2.new(0.5, -MW/2, 0.5, -MH/2),          -- ⭐ POSIÇÃO DIRETA
    BackgroundColor3 = Colors.Background,
    BackgroundTransparency = 0.05,
    BorderSizePixel = 0,
    Visible = true,                                        -- ⭐ VISÍVEL POR PADRÃO
    ClipsDescendants = true,
    ZIndex = 1,
    Parent = UI.Screen,
})
Create("UICorner", {CornerRadius = UDim.new(0, 8), Parent = UI.Main})
UI.MainStroke = Create("UIStroke", {Color = Colors.Accent, Thickness = 1.2, Transparency = 0.2, Parent = UI.Main})
UI.Blur = Create("BlurEffect", {Size = 12, Parent = SV.L})

print("[HB] Menu criado — Size:", MW, "x", MH)

-- HEADER (38px)
local TBBG = Create("Frame", {
    Size = UDim2.new(1, 0, 0, 38),
    BackgroundColor3 = Color3.fromRGB(20, 20, 20),
    BackgroundTransparency = 0.1,
    BorderSizePixel = 0, ZIndex = 2, Parent = UI.Main,
})
Create("UICorner", {CornerRadius = UDim.new(0, 8), Parent = TBBG})
Create("TextLabel", {
    Text = "HELLBORN v22.5", Font = Enum.Font.GothamBold, TextSize = 13,
    TextColor3 = Colors.Text, BackgroundTransparency = 1,
    Position = UDim2.new(0, 8, 0, 5), Size = UDim2.new(0, 180, 0, 14),
    TextXAlignment = Enum.TextXAlignment.Left, ZIndex = 3, Parent = TBBG,
})
Create("TextLabel", {
    Text = "Q = Flick | Insert = Menu", Font = Enum.Font.Gotham, TextSize = 9,
    TextColor3 = Colors.Accent, BackgroundTransparency = 1,
    Position = UDim2.new(0, 8, 0, 20), Size = UDim2.new(0, 180, 0, 12),
    TextXAlignment = Enum.TextXAlignment.Left, ZIndex = 3, Parent = TBBG,
})

-- Botão de fechar (X)
local CloseBtn = Create("TextButton", {
    Text = "X", Font = Enum.Font.GothamBold, TextSize = 14,
    TextColor3 = Colors.Text, BackgroundColor3 = Color3.fromRGB(60, 20, 20),
    BorderSizePixel = 0, Size = UDim2.new(0, 22, 0, 22),
    Position = UDim2.new(1, -28, 0, 8),
    ZIndex = 3, Parent = TBBG,
})
Create("UICorner", {CornerRadius = UDim.new(0, 4), Parent = CloseBtn})

-- SIDEBAR + CONTENT
UI.Sidebar = Create("Frame", {
    Size = UDim2.new(0, 70, 1, -38 - 20 - 8),
    Position = UDim2.new(0, 4, 0, 42),
    BackgroundColor3 = Colors.Sidebar, BackgroundTransparency = 0.2,
    BorderSizePixel = 0, ZIndex = 2, Parent = UI.Main,
})
Create("UICorner", {CornerRadius = UDim.new(0, 6), Parent = UI.Sidebar})

UI.ContentArea = Create("Frame", {
    Size = UDim2.new(1, -78, 1, -38 - 20 - 8),
    Position = UDim2.new(0, 74, 0, 42),
    BackgroundTransparency = 1, ZIndex = 2, Parent = UI.Main,
})

-- Abas
UI.TabButtons, UI.TabContents = {}, {}
local TabsList = {{"⚔","Flick"},{"◉","ESP"},{"✦","Vis"},{"⚙","Cfg"}}
local TabScrolling = Create("ScrollingFrame", {
    Size = UDim2.new(1, -4, 1, -4), Position = UDim2.new(0, 2, 0, 2),
    BackgroundTransparency = 1, ScrollBarThickness = 2,
    ScrollBarImageColor3 = Colors.Accent, ZIndex = 3, Parent = UI.Sidebar,
})
TabScrolling.CanvasSize = UDim2.new(0, 0, 0, #TabsList * 26 + 4)

local ActiveBar = Create("Frame", {
    Size = UDim2.new(0, 2, 0, 18), Position = UDim2.new(0, 0, 0, 4),
    BackgroundColor3 = Colors.Accent, BorderSizePixel = 0, ZIndex = 4, Parent = TabScrolling,
})
Create("UICorner", {CornerRadius = UDim.new(1, 0), Parent = ActiveBar})

UI.switchTab = function(name)
    for n, f in pairs(UI.TabContents) do f.Visible = (n == name) end
    for _, b in ipairs(UI.TabButtons) do
        if b:GetAttribute("TabName") == name then
            b.TextColor3 = Colors.Accent
            b.BackgroundTransparency = 0.2
            ActiveBar.Position = UDim2.new(0, 0, 0, b.Position.Y.Offset + 4)
        else
            b.TextColor3 = Colors.Text
            b.BackgroundTransparency = 0.6
        end
    end
end

for i, td in ipairs(TabsList) do
    local icon, tabName = td[1], td[2]
    local Btn = Create("TextButton", {
        Text = icon.." "..tabName, Font = Enum.Font.GothamMedium, TextSize = 9,
        TextColor3 = Colors.Text, BackgroundColor3 = Colors.ElementBg,
        BackgroundTransparency = 0.6, Size = UDim2.new(1, -4, 0, 22),
        Position = UDim2.new(0, 2, 0, (i - 1) * 26 + 2),
        TextXAlignment = Enum.TextXAlignment.Left, ZIndex = 4, Parent = TabScrolling,
    })
    Btn:SetAttribute("TabName", tabName)
    Create("UICorner", {CornerRadius = UDim.new(0, 4), Parent = Btn})
    Btn.MouseButton1Click:Connect(function() PlayUISound(); UI.switchTab(tabName) end)
    UI.TabButtons[#UI.TabButtons + 1] = Btn
end

-- STATUS BAR
local StatusBar = Create("Frame", {
    Size = UDim2.new(1, -8, 0, 18),
    Position = UDim2.new(0, 4, 1, -22),
    BackgroundColor3 = Color3.fromRGB(18, 18, 18),
    BorderSizePixel = 0, ZIndex = 2, Parent = UI.Main,
})
Create("UICorner", {CornerRadius = UDim.new(0, 4), Parent = StatusBar})
UI.StatusText = Create("TextLabel", {
    Text = "Ready", Font = Enum.Font.Code, TextSize = 9,
    TextColor3 = Colors.SubText, BackgroundTransparency = 1,
    Size = UDim2.new(1, -8, 1, 0), Position = UDim2.new(0, 4, 0, 0),
    TextXAlignment = Enum.TextXAlignment.Left, ZIndex = 3, Parent = StatusBar,
})

-- ═══ UI HELPERS ═══
local function Section(parent, text, yPos)
    Create("Frame", {Size = UDim2.new(0, 2, 0, 8), Position = UDim2.new(0, 0, 0, yPos + 3), BackgroundColor3 = Colors.Accent, BorderSizePixel = 0, ZIndex = 3, Parent = parent})
    Create("TextLabel", {Text = text, Font = Enum.Font.GothamBold, TextSize = 10, TextColor3 = Colors.Text, BackgroundTransparency = 1, Size = UDim2.new(1, 0, 0, 14), Position = UDim2.new(0, 6, 0, yPos), TextXAlignment = Enum.TextXAlignment.Left, ZIndex = 3, Parent = parent})
    Create("Frame", {Size = UDim2.new(1, -4, 0, 1), Position = UDim2.new(0, 0, 0, yPos + 14), BackgroundColor3 = Colors.SubText, BackgroundTransparency = 0.7, BorderSizePixel = 0, ZIndex = 3, Parent = parent})
    return yPos + 19
end

local function Toggle(parent, text, yPos, def, cb)
    local F = Create("Frame", {Size = UDim2.new(1, -4, 0, 24), Position = UDim2.new(0, 0, 0, yPos), BackgroundColor3 = Colors.ElementBg, BackgroundTransparency = 0.4, BorderSizePixel = 0, ZIndex = 3, Parent = parent})
    Create("UICorner", {CornerRadius = UDim.new(0, 4), Parent = F})
    Create("TextLabel", {Text = text, Font = Enum.Font.Gotham, TextSize = 9, TextColor3 = Colors.Text, BackgroundTransparency = 1, Size = UDim2.new(1, -40, 1, 0), Position = UDim2.new(0, 6, 0, 0), TextXAlignment = Enum.TextXAlignment.Left, ZIndex = 4, Parent = F})
    local Bg = Create("Frame", {Size = UDim2.new(0, 26, 0, 13), Position = UDim2.new(1, -32, 0.5, -6.5), BackgroundColor3 = def and Colors.Accent or Colors.ToggleOff, BorderSizePixel = 0, ZIndex = 4, Parent = F})
    Create("UICorner", {CornerRadius = UDim.new(1, 0), Parent = Bg})
    local C = Create("Frame", {Size = UDim2.new(0, 9, 0, 9), Position = def and UDim2.new(1, -11, 0.5, -4.5) or UDim2.new(0, 2, 0.5, -4.5), BackgroundColor3 = Color3.fromRGB(255, 255, 255), BorderSizePixel = 0, ZIndex = 5, Parent = Bg})
    Create("UICorner", {CornerRadius = UDim.new(1, 0), Parent = C})
    local on = def
    F.InputBegan:Connect(function(i)
        if i.UserInputType == Enum.UserInputType.MouseButton1 or i.UserInputType == Enum.UserInputType.Touch then
            on = not on
            PlayUISound(on and 1.3 or 0.9)
            Bg.BackgroundColor3 = on and Colors.Accent or Colors.ToggleOff
            C.Position = on and UDim2.new(1, -11, 0.5, -4.5) or UDim2.new(0, 2, 0.5, -4.5)
            if cb then pcall(cb, on) end
        end
    end)
    return yPos + 28
end

local function Slider(parent, text, mn, mx, def, yPos, cb)
    local F = Create("Frame", {Size = UDim2.new(1, -4, 0, 26), Position = UDim2.new(0, 0, 0, yPos), BackgroundColor3 = Colors.ElementBg, BackgroundTransparency = 0.4, BorderSizePixel = 0, ZIndex = 3, Parent = parent})
    Create("UICorner", {CornerRadius = UDim.new(0, 4), Parent = F})
    Create("TextLabel", {Text = text, Font = Enum.Font.Gotham, TextSize = 9, TextColor3 = Colors.Text, BackgroundTransparency = 1, Size = UDim2.new(0.55, -8, 0.5, 0), Position = UDim2.new(0, 5, 0, 3), TextXAlignment = Enum.TextXAlignment.Left, ZIndex = 4, Parent = F})
    local VL = Create("TextLabel", {Text = tostring(def), Font = Enum.Font.Code, TextSize = 9, TextColor3 = Colors.Accent, BackgroundTransparency = 1, Size = UDim2.new(0, 24, 0.5, 0), Position = UDim2.new(0.55, -3, 0, 3), TextXAlignment = Enum.TextXAlignment.Center, ZIndex = 4, Parent = F})
    local Bg = Create("Frame", {Size = UDim2.new(0.38, -6, 0, 3), Position = UDim2.new(0.58, 3, 0.7, 0), BackgroundColor3 = Colors.ToggleOff, BorderSizePixel = 0, ZIndex = 4, Parent = F})
    Create("UICorner", {CornerRadius = UDim.new(1, 0), Parent = Bg})
    local Fl = Create("Frame", {Size = UDim2.new((def - mn) / (mx - mn), 0, 1, 0), BackgroundColor3 = Colors.Accent, BorderSizePixel = 0, ZIndex = 5, Parent = Bg})
    Create("UICorner", {CornerRadius = UDim.new(1, 0), Parent = Fl})
    local H = Create("Frame", {Size = UDim2.new(0, 8, 0, 8), Position = UDim2.new((def - mn) / (mx - mn), -4, 0.5, -4), BackgroundColor3 = Color3.fromRGB(255, 255, 255), BorderSizePixel = 0, ZIndex = 6, Parent = Bg})
    Create("UICorner", {CornerRadius = UDim.new(1, 0), Parent = H})
    local drag = false
    Bg.InputBegan:Connect(function(i) if i.UserInputType == Enum.UserInputType.MouseButton1 or i.UserInputType == Enum.UserInputType.Touch then drag = true end end)
    SV.U.InputEnded:Connect(function(i) if i.UserInputType == Enum.UserInputType.MouseButton1 or i.UserInputType == Enum.UserInputType.Touch then drag = false end end)
    SV.U.InputChanged:Connect(function(i)
        if drag and (i.UserInputType == Enum.UserInputType.MouseMovement or i.UserInputType == Enum.UserInputType.Touch) then
            local pct = math.clamp((i.Position.X - Bg.AbsolutePosition.X) / Bg.AbsoluteSize.X, 0, 1)
            Fl.Size = UDim2.new(pct, 0, 1, 0)
            H.Position = UDim2.new(pct, -4, 0.5, -4)
            local nv = mn + (mx - mn) * pct
            VL.Text = tostring(math.floor(nv))
            if cb then pcall(cb, nv) end
        end
    end)
    return yPos + 30
end

local function Button(parent, text, yPos, cb)
    local B = Create("TextButton", {
        Text = " "..text, Font = Enum.Font.Gotham, TextSize = 9,
        TextColor3 = Colors.Text, BackgroundColor3 = Colors.ElementBg,
        BackgroundTransparency = 0.4, Size = UDim2.new(1, -4, 0, 24),
        Position = UDim2.new(0, 0, 0, yPos),
        TextXAlignment = Enum.TextXAlignment.Left, ZIndex = 3, Parent = parent,
    })
    Create("UICorner", {CornerRadius = UDim.new(0, 4), Parent = B})
    B.MouseButton1Click:Connect(function() PlayUISound(); if cb then pcall(cb) end end)
    return yPos + 28
end

-- ═══ HITMARKER + KILLFEED ═══
local Hitmarker = {frame = nil, lastShow = 0}
Hitmarker.frame = Create("Frame", {
    Size = UDim2.new(0, 16, 0, 16), AnchorPoint = Vector2.new(0.5, 0.5),
    BackgroundTransparency = 1, BorderSizePixel = 0, Visible = false, ZIndex = 200, Parent = UI.Screen,
})
for _, rot in ipairs({45, -45, 135, -135}) do
    Create("Frame", {Size = UDim2.new(0, 1, 0, 7), Position = UDim2.new(0.5, -0.5, 0.5, -3.5), BackgroundColor3 = Color3.fromRGB(255, 60, 60), BorderSizePixel = 0, Parent = Hitmarker.frame}).Rotation = rot
end
function Hitmarker:show()
    if not State.HitmarkerEnabled then return end
    local now = tick()
    if now - self.lastShow < 0.05 then return end
    self.lastShow = now
    local mp = SV.U:GetMouseLocation()
    self.frame.Position = UDim2.new(0, mp.X, 0, mp.Y)
    self.frame.Visible = true
    task.delay(0.2, function() self.frame.Visible = false end)
end

-- ═══ ESP ═══
local ESPCache = {}
local function destroyESP(p)
    local e = ESPCache[p]; if not e then return end
    for _, k in ipairs({"hl", "nameBg"}) do if e[k] then pcall(function() e[k]:Destroy() end) end end
    ESPCache[p] = nil
end
local function applyESP(p)
    if p == LP or not State.ESP then return end
    local char = CACHE.Characters[p]
    if not char or not char.Parent then destroyESP(p); return end
    local hum = char:FindFirstChildOfClass("Humanoid")
    if not hum or hum.Health <= 0 then destroyESP(p); return end
    local role = getRole(p)
    local color = role == "Murderer" and Color3.fromRGB(255, 0, 0) or (role == "Sheriff" and Color3.fromRGB(0, 100, 255) or Color3.fromRGB(0, 255, 0))
    local e = ESPCache[p]; if not e then e = {}; ESPCache[p] = e end
    if not e.hl or e.hl.Parent ~= char then
        if e.hl then pcall(function() e.hl:Destroy() end) end
        local hl = Instance.new("Highlight"); hl.Name = HNAME
        hl.DepthMode = Enum.HighlightDepthMode.AlwaysOnTop
        hl.FillTransparency = 0.5; hl.OutlineTransparency = 0
        hl.Parent = char; e.hl = hl
    end
    e.hl.FillColor = color; e.hl.OutlineColor = color
    if State.ESPName then
        local head = CACHE.HeadParts[p] or char:FindFirstChild("Head")
        if head then
            if not e.nameBg or e.nameBg.Parent ~= head then
                if e.nameBg then pcall(function() e.nameBg:Destroy() end) end
                local bg = Instance.new("BillboardGui")
                bg.Name = HNAME.."_nm"; bg.Size = UDim2.new(0, 120, 0, 12)
                bg.StudsOffset = Vector3.new(0, 2.8, 0); bg.AlwaysOnTop = true
                bg.Adornee = head; bg.Parent = head
                local txt = Instance.new("TextLabel", bg)
                txt.Name = "Txt"; txt.Size = UDim2.new(1, 0, 1, 0)
                txt.BackgroundTransparency = 1; txt.Font = Enum.Font.GothamBold
                txt.TextSize = 9; txt.TextStrokeTransparency = 0.3
                e.nameBg = bg
            end
            local txt = e.nameBg:FindFirstChild("Txt")
            if txt then txt.Text = p.Name; txt.TextColor3 = color end
        end
    end
end
SV.P.PlayerRemoving:Connect(function(p) destroyESP(p) end)
task.spawn(function()
    while task.wait(0.1) do
        if State.ESP then for _, p in ipairs(CACHE.PlayersList) do applyESP(p) end end
    end
end)

-- ═══ FLICK ENGINE ═══
local flick = {
    active=false, phase="idle", startTick=0, holdStartTick=0, returnStartTick=0,
    snapDur=0.045, holdDur=0.15, returnDur=0.10, cooldown=0.15,
    verifyWait=0.50, alignTolerance=4, retries=2,
    targetPlayer=nil, targetChar=nil, targetHumanoid=nil, aimPos=nil,
    originCF=nil, originLookAt=nil, returnStartCF=nil, returnTargetCF=nil,
    originalCameraType=nil, originalCameraSubject=nil,
    shotsFired=0, killed=false, hitVerified=false, hpBefore=100, verifyStart=0,
    retriesLeft=2, hitStreak=0, missStreak=0, lastFlickEnd=0,
    triggeredBy="manual", keyHeld=false,
}
local _hitDetectors = {}

local function attachHitDetector(hum)
    if not hum or _hitDetectors[hum] then return end
    _hitDetectors[hum] = true
    local last = hum.Health
    hum.HealthChanged:Connect(function(h)
        if h < last and flick.active and flick.targetHumanoid == hum then
            flick.hitVerified = true
            Hitmarker:show()
        end
        last = h
    end)
end

local function findWeapon()
    if not LP.Character then return nil end
    local eq = LP.Character:FindFirstChildOfClass("Tool")
    local bp = LP:FindFirstChild("Backpack")
    local gun, knife
    if bp then
        gun = bp:FindFirstChild("Gun"); knife = bp:FindFirstChild("Knife")
        if not gun then for _, t in ipairs(bp:GetChildren()) do if t:IsA("Tool") and t.Name:lower():find("gun") then gun = t; break end end end
    end
    if eq and eq.Name:lower():find("gun") then return eq end
    if gun then return gun end
    if eq and eq.Name == "Knife" then return eq end
    if knife then return knife end
    if eq then return eq end
end

local function equip(tool)
    if not tool or not LP.Character then return false end
    if tool.Parent == LP.Character then return true end
    local hum = LP.Character:FindFirstChildOfClass("Humanoid")
    if not hum then return false end
    return pcall(function() hum:EquipTool(tool) end)
end

local function findMurderer()
    local origin = CACHE.HRPParts[LP] and CACHE.HRPParts[LP].Position or Cam.CFrame.Position
    local best, bestD = nil, 500
    for _, p in ipairs(CACHE.PlayersList) do
        if p ~= LP and getRole(p) == "Murderer" then
            local char = CACHE.Characters[p]; local hrp = CACHE.HRPParts[p]
            if char and char.Parent and hrp then
                local hum = char:FindFirstChildOfClass("Humanoid")
                if hum and hum.Health > 0 then
                    local d = (hrp.Position - origin).Magnitude
                    if d < bestD then bestD = d; best = {player = p, char = char, hum = hum, dist = d} end
                end
            end
        end
    end
    return best
end

local function startFlick(target, triggeredBy)
    if not flick.originalCameraType then flick.originalCameraType = Cam.CameraType end
    if not flick.originalCameraSubject then flick.originalCameraSubject = Cam.CameraSubject end
    local startCF = Cam.CFrame
    flick.targetPlayer = target.player; flick.targetChar = target.char; flick.targetHumanoid = target.hum
    flick.originCF = startCF; flick.originLookAt = startCF.Position + startCF.LookVector * 100
    flick.active = true; flick.phase = "snap"; flick.startTick = tick()
    flick.shotsFired = 0; flick.killed = false; flick.hitVerified = false
    flick.hpBefore = target.hum.Health; flick.retriesLeft = flick.retries
    flick.triggeredBy = triggeredBy or "manual"
    if Histories[target.player] then Histories[target.player].samples = {} end
    attachHitDetector(target.hum)
    if State.KillConfirm then
        local hum = target.hum
        if not hum:GetAttribute("HBKill") then
            hum:SetAttribute("HBKill", true)
            local pl = target.player
            hum.Died:Connect(function()
                if tick() - flick.startTick < 3 then
                    flick.killed = true; flick.hitStreak = flick.hitStreak + 1
                    State.Kills = State.Kills + 1
                end
            end)
        end
    end
    Cam.CameraType = Enum.CameraType.Scriptable
    Cam.CameraSubject = nil
end

local function endFlick()
    if not flick.active then return end
    flick.phase = "return"; flick.returnStartTick = tick()
    flick.returnStartCF = Cam.CFrame; flick.returnTargetCF = flick.originCF
end

Cam = workspace.CurrentCamera
SV.R:BindToRenderStep("HBAutoFlick", Enum.RenderPriority.Camera.Value + 10, function(dt)
    if not Cam or not Cam.Parent then Cam = workspace.CurrentCamera end
    if not Cam then return end

    -- RETURN PHASE
    if flick.phase == "return" and flick.active then
        local elapsed = tick() - flick.returnStartTick
        local t = math.clamp(elapsed / flick.returnDur, 0, 1)
        local eased = 1 - (1 - t)^3
        local pos = flick.returnStartCF.Position:Lerp(flick.returnTargetCF.Position, eased)
        local lookFrom = flick.returnStartCF.Position + flick.returnStartCF.LookVector * 100
        local lookTo = flick.returnTargetCF.Position + flick.returnTargetCF.LookVector * 100
        Cam.CameraType = Enum.CameraType.Scriptable; Cam.CameraSubject = nil
        Cam.CFrame = CFrame.lookAt(pos, lookFrom:Lerp(lookTo, eased))
        if t >= 1 then
            flick.active = false; flick.phase = "idle"
            flick.targetPlayer = nil; flick.targetChar = nil; flick.targetHumanoid = nil
            flick.lastFlickEnd = tick(); flick.retriesLeft = flick.retries
            local hum = LP.Character and LP.Character:FindFirstChildOfClass("Humanoid")
            if hum then hum.AutoRotate = true end
            if flick.originalCameraType then
                Cam.CameraType = flick.originalCameraType
                Cam.CameraSubject = flick.originalCameraSubject
                flick.originalCameraType = nil; flick.originalCameraSubject = nil
            end
        end
        return
    end

    -- NÃO ATIVO: procura trigger
    if not flick.active then
        if tick() - flick.lastFlickEnd < flick.cooldown then return end
        local manualKey = State.AutoFlick and (flick.keyHeld or SV.U:IsKeyDown(State.AutoFlickKey))
        if manualKey then
            local t = findMurderer()
            if t then flick.lastFlickEnd = tick(); startFlick(t, "manual") end
        elseif State.TriggerBot then
            local mouse = SV.U:GetMouseLocation()
            for _, p in ipairs(CACHE.PlayersList) do
                if p == LP or getRole(p) ~= "Murderer" then continue end
                local char = CACHE.Characters[p]; local head = CACHE.HeadParts[p]
                if char and head then
                    local sp, on = Cam:WorldToViewportPoint(head.Position)
                    if on and sp.Z > 0 then
                        local d = (Vector2.new(sp.X, sp.Y) - mouse).Magnitude
                        if d < State.TriggerRadius then
                            local hum = char:FindFirstChildOfClass("Humanoid")
                            local hrp = CACHE.HRPParts[p]; local lpHrp = CACHE.HRPParts[LP]
                            if hum and hum.Health > 0 and hrp and lpHrp then
                                local dist = (hrp.Position - lpHrp.Position).Magnitude
                                if dist < 500 then
                                    flick.lastFlickEnd = tick()
                                    startFlick({player = p, char = char, hum = hum, dist = dist}, "trigger")
                                    break
                                end
                            end
                        end
                    end
                end
            end
        end
        return
    end

    if flick.triggeredBy == "manual" and not (flick.keyHeld or SV.U:IsKeyDown(State.AutoFlickKey)) then
        endFlick(); return
    end

    local tp = flick.targetPlayer; local char = flick.targetChar; local hum = flick.targetHumanoid
    if not tp or not tp.Parent or not char or not char.Parent or not hum or hum.Health <= 0 then
        endFlick(); return
    end

    local lpHead = CACHE.HeadParts[LP]
    local camPos = lpHead and lpHead.Position or Cam.CFrame.Position
    local aimPos, flightT, dist = computePreciseAim(tp, char, camPos, Silent.bulletSpeed)
    if not aimPos then endFlick(); return end
    flick.aimPos = aimPos

    -- SNAP
    if flick.phase == "snap" then
        local elapsed = tick() - flick.startTick
        local roughDur = flick.snapDur * 0.7
        local fineDur = flick.snapDur * 0.3
        if elapsed < roughDur then
            local t = math.clamp(elapsed / roughDur, 0, 1)
            local eased = 1 - (1 - t)^4
            local look = flick.originLookAt:Lerp(aimPos, eased)
            Cam.CameraType = Enum.CameraType.Scriptable; Cam.CameraSubject = nil
            Cam.CFrame = CFrame.lookAt(camPos, look)
        elseif elapsed < roughDur + fineDur then
            local newAim = computePreciseAim(tp, char, camPos, Silent.bulletSpeed)
            Cam.CFrame = CFrame.lookAt(camPos, newAim or aimPos)
        else
            flick.phase = "hold"; flick.holdStartTick = tick()
        end
        return
    end

    -- HOLD
    if flick.phase == "hold" then
        Cam.CameraType = Enum.CameraType.Scriptable; Cam.CameraSubject = nil
        Cam.CFrame = CFrame.lookAt(camPos, aimPos)
        local camLook = Cam.CFrame.LookVector
        local targetDir = (aimPos - camPos).Unit
        local angle = math.deg(math.acos(math.clamp(camLook:Dot(targetDir), -1, 1)))
        if flick.shotsFired == 0 and angle <= flick.alignTolerance then
            local weapon = findWeapon()
            if not weapon then endFlick(); return end
            local eq = LP.Character:FindFirstChildOfClass("Tool")
            if eq ~= weapon then equip(weapon); task.wait(0.08); eq = LP.Character:FindFirstChildOfClass("Tool") end
            if eq then
                flick.shotsFired = 1; flick.hpBefore = hum.Health
                local ok = Silent_fire(eq, aimPos)
                if ok then PlayAimBeep(); flick.phase = "verify"; flick.verifyStart = tick() end
            end
            return
        end
        if tick() - flick.holdStartTick >= flick.holdDur then
            flick.phase = "verify"; flick.verifyStart = tick()
        end
        return
    end

    -- VERIFY
    if flick.phase == "verify" then
        Cam.CFrame = CFrame.lookAt(Cam.CFrame.Position, aimPos)
        if hum.Health <= 0 then flick.killed = true end
        if flick.hitVerified then endFlick(); return end
        if tick() - flick.verifyStart >= flick.verifyWait then
            local hpNow = hum.Health or 0
            if hpNow < flick.hpBefore then flick.hitVerified = true; endFlick(); return end
            if flick.retriesLeft > 0 and flick.shotsFired > 0 and not flick.killed then
                flick.retriesLeft = flick.retriesLeft - 1
                flick.missStreak = flick.missStreak + 1
                flick.phase = "snap"; flick.startTick = tick()
                flick.shotsFired = 0; flick.hitVerified = false
                flick.hpBefore = hum.Health
                flick.originLookAt = Cam.CFrame.Position + Cam.CFrame.LookVector * 100
                return
            end
            endFlick()
        end
        return
    end
end)

-- ═══════════════════════════════════════════════════════════
-- UI ABRIR/FECHAR (INSERT)
-- ═══════════════════════════════════════════════════════════
UI.Hide = function()
    UI.Main.Visible = false
    UI.Blur.Size = 0
    State.GUI_Visible = false
    print("[HB] Menu FECHADO")
end
UI.Show = function()
    UI.Main.Visible = true
    UI.Blur.Size = 12
    State.GUI_Visible = true
    print("[HB] Menu ABERTO")
end

CloseBtn.MouseButton1Click:Connect(function()
    PlayUISound()
    UI.Hide()
end)

-- INPUT GLOBAL
SV.U.InputBegan:Connect(function(input, gp)
    if gp then return end
    -- INSERT = toggle menu
    if input.KeyCode == Enum.KeyCode.Insert then
        if State.GUI_Visible then UI.Hide() else UI.Show() end
    end
    -- Q = auto flick (segurar)
    if input.UserInputType == Enum.UserInputType.Keyboard and input.KeyCode == State.AutoFlickKey then
        flick.keyHeld = true
    end
    -- F1 = panic
    if input.KeyCode == Enum.KeyCode.F1 then
        State.AutoFlick = false; State.TriggerBot = false; State.ESP = false
        for pl in pairs(ESPCache) do destroyESP(pl) end
    end
end)
SV.U.InputEnded:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.Keyboard and input.KeyCode == State.AutoFlickKey then
        flick.keyHeld = false
    end
end)

-- DRAG
local dragging, dragStart, startPos
TBBG.InputBegan:Connect(function(i)
    if i.UserInputType == Enum.UserInputType.MouseButton1 or i.UserInputType == Enum.UserInputType.Touch then
        dragging = true; dragStart = i.Position; startPos = UI.Main.Position
        local conn; conn = i.Changed:Connect(function()
            if i.UserInputState == Enum.UserInputState.End then dragging = false; conn:Disconnect() end
        end)
    end
end)
SV.U.InputChanged:Connect(function(i)
    if (i.UserInputType == Enum.UserInputType.MouseMovement or i.UserInputType == Enum.UserInputType.Touch) and dragging then
        local d = i.Position - dragStart
        UI.Main.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + d.X, startPos.Y.Scale, startPos.Y.Offset + d.Y)
    end
end)

-- ═══ TABS ═══
local function buildFlickTab()
    local p = Create("ScrollingFrame", {Name = "Flick", Size = UDim2.new(1, 0, 1, 0), BackgroundTransparency = 1, ScrollBarThickness = 2, ScrollBarImageColor3 = Colors.Accent, Visible = false, ZIndex = 3, Parent = UI.ContentArea})
    UI.TabContents["Flick"] = p
    p.CanvasSize = UDim2.new(0, 0, 0, 500); p.AutomaticCanvasSize = Enum.AutomaticSize.Y
    local y = 2
    y = Section(p, "AUTO FLICK", y)
    y = Toggle(p, "Auto Flick (Q)", y, true, function(s) State.AutoFlick = s end)
    y = Toggle(p, "Trigger Bot", y, true, function(s) State.TriggerBot = s end)
    y = Slider(p, "Trigger R", 10, 120, 40, y, function(v) State.TriggerRadius = v end)
    y = Toggle(p, "IA Ativa", y, true, function(s) State.AIEnabled = s end)
    y = Toggle(p, "Silent", y, true, function(s) Silent.enabled = s end)
    y = Section(p, "TIMINGS", y)
    y = Slider(p, "Snap ms", 10, 100, 45, y, function(v) flick.snapDur = v / 1000 end)
    y = Slider(p, "Hold ms", 50, 400, 150, y, function(v) flick.holdDur = v / 1000 end)
    y = Slider(p, "Verify ms", 200, 1000, 500, y, function(v) flick.verifyWait = v / 1000 end)
    y = Slider(p, "Return ms", 30, 300, 100, y, function(v) flick.returnDur = v / 100 end)
    y = Slider(p, "Cooldown", 50, 500, 150, y, function(v) flick.cooldown = v / 100 end)
    y = Section(p, "PRECISAO", y)
    y = Slider(p, "Align graus", 1, 15, 4, y, function(v) flick.alignTolerance = math.floor(v) end)
    y = Slider(p, "Retries", 0, 3, 2, y, function(v) flick.retries = math.floor(v) end)
    y = Slider(p, "Restore ms", 50, 300, 120, y, function(v) Silent.restoreDelay = v / 1000 end)
    y = Button(p, "APLICAR PIPELINE", y, function()
        State.AutoFlick = true; State.TriggerBot = true; State.AIEnabled = true; Silent.enabled = true
        flick.alignTolerance = 4; flick.retries = 2; flick.cooldown = 0.15
        ShowToast("Pipeline ON", "success")
    end)
end

local function buildESPTab()
    local p = Create("ScrollingFrame", {Name = "ESP", Size = UDim2.new(1, 0, 1, 0), BackgroundTransparency = 1, ScrollBarThickness = 2, ScrollBarImageColor3 = Colors.Accent, Visible = false, ZIndex = 3, Parent = UI.ContentArea})
    UI.TabContents["ESP"] = p
    p.CanvasSize = UDim2.new(0, 0, 0, 300)
    local y = 2
    y = Section(p, "ESP", y)
    y = Toggle(p, "ESP Ativo", y, false, function(s) State.ESP = s; if not s then for pl in pairs(ESPCache) do destroyESP(pl) end end end)
    y = Toggle(p, "Nome", y, true, function(s) State.ESPName = s end)
end

local function buildVisualTab()
    local p = Create("ScrollingFrame", {Name = "Visual", Size = UDim2.new(1, 0, 1, 0), BackgroundTransparency = 1, ScrollBarThickness = 2, ScrollBarImageColor3 = Colors.Accent, Visible = false, ZIndex = 3, Parent = UI.ContentArea})
    UI.TabContents["Visual"] = p
    p.CanvasSize = UDim2.new(0, 0, 0, 300)
    local y = 2
    y = Section(p, "VISUAL", y)
    y = Toggle(p, "Fullbright", y, false, function(s)
        if s then SV.L.Ambient = Color3.fromRGB(255, 255, 255); SV.L.Brightness = 2
        else SV.L.Ambient = Color3.fromRGB(70, 70, 70); SV.L.Brightness = 1 end
    end)
    y = Section(p, "HUD", y)
    y = Toggle(p, "Hitmarker", y, true, function(s) State.HitmarkerEnabled = s end)
end

local function buildConfigTab()
    local p = Create("ScrollingFrame", {Name = "Config", Size = UDim2.new(1, 0, 1, 0), BackgroundTransparency = 1, ScrollBarThickness = 2, ScrollBarImageColor3 = Colors.Accent, Visible = false, ZIndex = 3, Parent = UI.ContentArea})
    UI.TabContents["Config"] = p
    p.CanvasSize = UDim2.new(0, 0, 0, 300)
    local y = 2
    y = Section(p, "GERAL", y)
    y = Toggle(p, "Sons UI", y, true, function(s) State.UI_Sounds = s end)
    y = Button(p, "Fechar Menu", y, function() UI.Hide() end)
    y = Button(p, "Reabrir (Insert)", y, function() UI.Show() end)
end

buildFlickTab()
buildESPTab()
buildVisualTab()
buildConfigTab()
UI.switchTab("Flick")

-- Toast simples
function ShowToast(msg, type)
    print("[HB TOAST] "..msg)
end

-- ═══ ANTI-CHEAT ═══
task.spawn(function()
    while task.wait(0.1) do
        pcall(function()
            if not State.AntiFling2 then return end
            local hrp = CACHE.HRPParts[LP]; if not hrp then return end
            if hrp.AssemblyLinearVelocity.Magnitude > 250 then
                hrp.AssemblyLinearVelocity = Vector3.zero
                hrp.AssemblyAngularVelocity = Vector3.zero
            end
        end)
    end
end)

-- ═══ HUD HEARTBEAT ═══
local statFrame = 0
SV.R.Heartbeat:Connect(function(dt)
    statFrame = statFrame + dt
    if statFrame >= 1 then
        statFrame = 0
        local ping = math.floor(LP:GetNetworkPing() * 1000)
        UI.StatusText.Text = string.format("%s | P:%d | Q=Flick Insert=Menu", flick.phase, ping)
    end
end)

print("[HELLBORN v22.5] Carregado!")
print("  Insert = Abre/Fecha menu")
print("  Q = Auto Flick")
print("  F1 = Panic")