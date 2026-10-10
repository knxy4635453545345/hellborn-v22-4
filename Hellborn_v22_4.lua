-- ============================================================
-- HELLBORN v22.4 — ULTRA COMPACT (MOBILE)
-- Menu 320x420 | IA + Silent + Flick + Trigger
-- ============================================================

local SV = {
    P  = game:GetService("Players"), U = game:GetService("UserInputService"),
    R  = game:GetService("RunService"), T = game:GetService("TweenService"),
    L  = game:GetService("Lighting"), S = game:GetService("SoundService"),
    H  = game:GetService("HttpService"), TP = game:GetService("TeleportService"),
}
local G = {
    SID = tostring(math.random(10000000, 99999999)),
    LP = SV.P.LocalPlayer, Cam = workspace.CurrentCamera, PG = nil, GNAME = nil, HNAME = nil,
}
local function rnd(p)
    local c = "abcdefghijklmnopqrstuvwxyz"; local s = ""
    for i = 1, 8 do local k = math.random(1, #c); s = s..c:sub(k, k) end
    return (p or "x").."_"..s.."_"..G.SID:sub(1, 4)
end
G.GNAME = rnd("cfg"); G.HNAME = rnd("hl")

G.PG = G.LP:FindFirstChild("PlayerGui")
if not G.PG then pcall(function() G.PG = G.LP:WaitForChild("PlayerGui", 15) end) end
if not G.PG then return end

local function SafeRun(fn, ...) local a = {...}; return pcall(function() return fn(table.unpack(a)) end) end
local function Create(c, p)
    local i = Instance.new(c); local parent = nil
    for k, v in pairs(p) do
        if k == "Parent" then parent = v else pcall(function() i[k] = v end) end
    end
    if parent then i.Parent = parent end
    return i
end
local tick = tick or os.clock

-- ═══ DIMENSÕES ULTRA COMPACT ═══
local DIM = {
    MainW = 320, MainH = 420,
    HeaderH = 38, SidebarW = 62,
    TabH = 22, StatusH = 18,
    FsSmall = 8, FsNorm = 9, FsTitle = 11,
    RowH = 24,
}

-- ═══ STATE ═══
local State = {
    AutoFlick = true, AutoFlickKey = Enum.KeyCode.Q,
    TriggerBot = true, TriggerRadius = 40,
    SilentAim = true, AIEnabled = true, KillConfirm = true,
    ESP = false, ESPName = true,
    HitmarkerEnabled = true, KillFeedEnabled = true,
    PingRealtime = true, UI_Sounds = true, AutoSave = true,
    Kills = 0, Deaths = 0, GUI_Visible = true, CompactHUD = false,
    Theme = "Red",
    AntiFling2 = true, AntiRagdoll = true, AntiTP = true, AntiVoid = false,
    _notifHistory = {}, _lastSound = 0,
}
local Themes = {
    Red={Accent=Color3.fromRGB(200,20,20),Border=Color3.fromRGB(80,15,15)},
    Blue={Accent=Color3.fromRGB(30,120,255),Border=Color3.fromRGB(15,40,80)},
    Green={Accent=Color3.fromRGB(30,200,80),Border=Color3.fromRGB(15,80,40)},
    Purple={Accent=Color3.fromRGB(160,30,220),Border=Color3.fromRGB(70,15,100)},
    Cyan={Accent=Color3.fromRGB(30,220,220),Border=Color3.fromRGB(15,80,80)},
}
local Colors = {
    Background=Color3.fromRGB(12,12,12), Sidebar=Color3.fromRGB(22,22,22),
    Accent=Color3.fromRGB(200,20,20), Text=Color3.fromRGB(240,240,240),
    SubText=Color3.fromRGB(140,140,140), ElementBg=Color3.fromRGB(32,32,32),
    ToggleOff=Color3.fromRGB(55,55,55), Success=Color3.fromRGB(0,200,100),
    Warning=Color3.fromRGB(255,180,0), Danger=Color3.fromRGB(255,60,60),
    Border=Color3.fromRGB(80,15,15),
}

-- ═══ PING ═══
local Ping = {samples = {}, avg = 0.05, jitter = 0, lastBeat = 0}
task.spawn(function()
    while task.wait(0.5) do
        local now = tick()
        if Ping.lastBeat > 0 then
            table.insert(Ping.samples, now - Ping.lastBeat)
            if #Ping.samples > 20 then table.remove(Ping.samples, 1) end
            local sum, mn, mx = 0, math.huge, 0
            for _, v in ipairs(Ping.samples) do sum = sum + v; if v < mn then mn = v end; if v > mx then mx = v end end
            Ping.avg = sum / #Ping.samples; Ping.jitter = mx - mn
        end
        Ping.lastBeat = now
    end
end)

-- ═══ PLAYER CACHE ═══
local CACHE = {Characters={}, HeadParts={}, HRPParts={}, PlayersList={}, PlayerSet={}}
local function RebuildPlayerList()
    local t = {}
    for p in pairs(CACHE.PlayerSet) do t[#t+1] = p end
    CACHE.PlayersList = t
end
local function HookCharacter(p)
    p.CharacterAdded:Connect(function(c)
        CACHE.Characters[p] = c; task.wait(0.25)
        CACHE.HeadParts[p] = c:FindFirstChild("Head")
        CACHE.HRPParts[p] = c:FindFirstChild("HumanoidRootPart")
    end)
    if p.Character then
        CACHE.Characters[p] = p.Character
        CACHE.HeadParts[p] = p.Character:FindFirstChild("Head")
        CACHE.HRPParts[p] = p.Character:FindFirstChild("HumanoidRootPart")
    end
end
local function AddPlayer(p) CACHE.PlayerSet[p] = true; HookCharacter(p); RebuildPlayerList() end
local function RemovePlayer(p)
    CACHE.PlayerSet[p] = nil
    CACHE.Characters[p] = nil; CACHE.HeadParts[p] = nil; CACHE.HRPParts[p] = nil
    RebuildPlayerList()
end
for _, p in pairs(SV.P:GetPlayers()) do AddPlayer(p) end
SV.P.PlayerAdded:Connect(AddPlayer); SV.P.PlayerRemoving:Connect(RemovePlayer)
G.LP.CharacterAdded:Connect(function() task.wait(0.5); G.Cam = workspace.CurrentCamera end)

-- ═══ ROLE ═══
local MURDERER_TOOLS = {"Knife", "Cleaver", "Blade"}
local SHERIFF_TOOLS = {"Gun", "Revolver"}
local function containerHasTool(container, names)
    if not container then return false end
    for _, obj in ipairs(container:GetChildren()) do
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

-- ═══ IA ═══
local Histories = {}
local HISTORY_SIZE = 60
local function getHistory(p)
    if not Histories[p] then
        Histories[p] = {samples={}, kalman={x={0,0,0,0,0,0},lastT=0,gain=0.35},
            velocity=Vector3.zero, prevVel=nil, acceleration=Vector3.zero,
            jitter=0, stability=1, lastPos=nil, lastTime=0}
    end
    return Histories[p]
end
local function kalmanUpdate(k, pos, t)
    if k.lastT == 0 then k.lastT = t end
    local dt = math.max(t - k.lastT, 1/120); k.lastT = t
    for i, axis in ipairs({"X", "Y", "Z"}) do
        local m = pos[axis]
        local pred = k.x[i] + k.x[i+3] * dt
        local err = m - pred
        k.x[i] = pred + k.gain * err
        k.x[i+3] = k.x[i+3] + (err / dt) * 0.4
    end
end
local function kalmanPredict(k, dt)
    return Vector3.new(k.x[1]+k.x[4]*dt, k.x[2]+k.x[5]*dt, k.x[3]+k.x[6]*dt)
end
local function updateHistory(p, pos)
    local h = getHistory(p); local now = tick()
    kalmanUpdate(h.kalman, pos, now)
    table.insert(h.samples, {pos=pos, t=now})
    if #h.samples > HISTORY_SIZE then table.remove(h.samples, 1) end
    if h.lastPos and h.lastTime > 0 then
        local dt = now - h.lastTime
        if dt > 0.001 then
            local v = (pos - h.lastPos) / dt
            h.velocity = h.velocity:Lerp(v, 0.4)
            if h.prevVel then h.acceleration = h.acceleration:Lerp((h.velocity - h.prevVel)/dt, 0.25) end
            h.prevVel = h.velocity
        end
    end
    h.lastPos = pos; h.lastTime = now
    local n = #h.samples
    if n >= 5 then
        local sumDiff = 0
        for i = n-4, n do if i > 1 then sumDiff = sumDiff + (h.samples[i].pos - h.samples[i-1].pos).Magnitude end end
        h.jitter = sumDiff / 4; h.stability = math.clamp(1 - h.jitter * 2, 0, 1)
    end
end
local function computePreciseAim(targetPlayer, targetChar, camPos, projectileSpeed)
    if not targetChar or not targetChar.Parent then return nil end
    local head = targetChar:FindFirstChild("Head"); if not head then return nil end
    local h = getHistory(targetPlayer); local posNow = head.Position
    local dist = (posNow - camPos).Magnitude
    local pingComp = G.LP:GetNetworkPing() * 0.5 + Ping.jitter * 0.5
    local renderLatency = 0.010
    local totalTime = dist / projectileSpeed + pingComp + renderLatency
    local predicted
    for iter = 1, 3 do
        local futurePos = posNow + h.velocity * totalTime + h.acceleration * 0.5 * totalTime * totalTime
        if h.stability > 0.4 and #h.samples >= 10 then
            futurePos = kalmanPredict(h.kalman, totalTime):Lerp(futurePos, 0.5 + h.stability * 0.3)
        end
        predicted = futurePos
        local newDist = (predicted - camPos).Magnitude
        if math.abs(newDist - dist) < 0.1 then break end
        dist = newDist; totalTime = dist / projectileSpeed + pingComp + renderLatency
    end
    local n = #h.samples
    if n >= 3 then
        local recent = h.samples[n].pos - h.samples[n-2].pos
        local older = h.samples[n-2].pos - h.samples[math.max(1, n-5)].pos
        if recent.Magnitude > 0.5 and older.Magnitude > 0.5 then
            if recent.Unit:Dot(older.Unit) < 0.5 then predicted = posNow:Lerp(predicted, 0.5) end
        end
    end
    local offset = predicted - posNow
    local maxOffset = dist * 0.35
    if offset.Magnitude > maxOffset then predicted = posNow + offset.Unit * maxOffset end
    return predicted, totalTime, dist
end
task.spawn(function()
    while task.wait(1/60) do
        if not State.AIEnabled then continue end
        local lpHrp = CACHE.HRPParts[G.LP]; if not lpHrp then continue end
        for _, p in ipairs(CACHE.PlayersList) do
            if p == G.LP then continue end
            local hrp = CACHE.HRPParts[p]
            if hrp and (hrp.Position - lpHrp.Position).Magnitude < 500 then updateHistory(p, hrp.Position) end
        end
    end
end)

-- ═══ SILENT ═══
local Silent = {enabled = true, restoreDelay = 0.120, bulletSpeed = 2500}
local _lastFireTime = 0
local function mouseSpoofTo(aimPos)
    if not mousemoverel then return nil end
    local vp, onScreen = G.Cam:WorldToViewportPoint(aimPos)
    if not onScreen then return nil end
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
    local lpChar = G.LP.Character; if not handle or not lpChar then return false end
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
    local delay = Silent.restoreDelay + (G.LP:GetNetworkPing() * 1.5) + 0.10
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
    local s = Instance.new("Sound"); s.SoundId = "rbxassetid://6895079853"; s.Volume = 0.25; s.Parent = SV.S
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
    if tick() - (State._lastSound or 0) < 0.2 then return end
    State._lastSound = tick(); pcall(function() AimbotBeep:Play() end)
end
local function PushNotif(msg, t)
    table.insert(State._notifHistory, 1, {msg=msg, type=t or "info", time=tick()})
    if #State._notifHistory > 50 then table.remove(State._notifHistory) end
end

-- ═══ UI BASE ═══
local UI = {}
function UI.buildSplash()
    local sg = Create("ScreenGui", {Name=G.GNAME.."_s", ResetOnSpawn=false, IgnoreGuiInset=true, Parent=G.PG})
    Create("Frame", {Size=UDim2.new(1,0,1,0), BackgroundColor3=Color3.fromRGB(0,0,0), BorderSizePixel=0, Parent=sg})
    Create("TextLabel", {Text="HB v22.4", Font=Enum.Font.GothamBlack, TextSize=30, TextColor3=Color3.fromRGB(240,240,240), BackgroundTransparency=1, Size=UDim2.new(1,0,0,40), Position=UDim2.new(0,0,0.5,-40), Parent=sg})
    Create("TextLabel", {Text="MOBILE", Font=Enum.Font.Gotham, TextSize=11, TextColor3=Color3.fromRGB(255,50,50), BackgroundTransparency=1, Size=UDim2.new(1,0,0,16), Position=UDim2.new(0,0,0.5,5), Parent=sg})
    task.wait(1); sg:Destroy()
end
UI.buildSplash()

UI.Screen = Create("ScreenGui", {Name=G.GNAME, ResetOnSpawn=false, IgnoreGuiInset=true, Parent=G.PG})
UI.Main = Create("Frame", {
    Size=UDim2.new(0,0,0,0), Position=UDim2.new(0.5,0,0.5,0),
    BackgroundColor3=Colors.Background, BackgroundTransparency=1,
    BorderSizePixel=0, ClipsDescendants=true, Parent=UI.Screen,
})
Create("UICorner", {CornerRadius=UDim.new(0,8), Parent=UI.Main})
Create("UIGradient", {Color=ColorSequence.new({
    ColorSequenceKeypoint.new(0, Color3.fromRGB(20,20,24)),
    ColorSequenceKeypoint.new(0.5, Color3.fromRGB(14,14,18)),
    ColorSequenceKeypoint.new(1, Color3.fromRGB(8,8,10)),
}), Rotation=135, Parent=UI.Main})
Create("Frame", {Size=UDim2.new(1,0,1,0), BackgroundColor3=Color3.fromRGB(255,255,255), BackgroundTransparency=0.96, BorderSizePixel=0, ZIndex=1, Parent=UI.Main})
Create("UICorner", {CornerRadius=UDim.new(0,8), Parent=UI.Main})
local OuterGlow = Create("UIStroke", {Color=Colors.Accent, Thickness=1.5, Transparency=0.85, Parent=UI.Main})
UI.MainStroke = Create("UIStroke", {Color=Colors.Border, Thickness=1, Transparency=0.3, Parent=UI.Main})
UI.Blur = Create("BlurEffect", {Size=0, Parent=SV.L})

task.delay(0.1, function()
    SV.T:Create(UI.Main, TweenInfo.new(0.5, Enum.EasingStyle.Back), {
        Size=UDim2.new(0, DIM.MainW, 0, DIM.MainH),
        Position=UDim2.new(0.5, -DIM.MainW/2, 0.5, -DIM.MainH/2),
        BackgroundTransparency=0.05,
    }):Play()
end)

task.spawn(function()
    while task.wait() do
        if not UI.Main.Parent then break end
        local t = tick() * 1.5
        local pulse = 0.5 + 0.5 * math.sin(t)
        UI.MainStroke.Transparency = 0.3 + pulse * 0.2
        OuterGlow.Transparency = 0.85 - pulse * 0.15
        task.wait(0.016)
    end
end)

-- DRAG touch
local dragging, dragStart, startPos
UI.Main.InputBegan:Connect(function(i)
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

UI.Hide = function()
    SV.T:Create(UI.Main, TweenInfo.new(0.2), {Size=UDim2.new(0, DIM.MainW*0.8, 0, DIM.MainH*0.8), BackgroundTransparency=0.6}):Play()
    task.delay(0.2, function() UI.Main.Visible = false; UI.Blur.Size = 0 end)
    State.GUI_Visible = false
end
UI.Show = function()
    UI.Main.Visible = true; UI.Blur.Size = 10
    UI.Main.Size = UDim2.new(0, DIM.MainW*0.85, 0, DIM.MainH*0.85)
    UI.Main.Position = UDim2.new(0.5, -DIM.MainW*0.42, 0.5, -DIM.MainH*0.42)
    UI.Main.BackgroundTransparency = 0.15
    SV.T:Create(UI.Main, TweenInfo.new(0.3, Enum.EasingStyle.Back), {
        Size=UDim2.new(0, DIM.MainW, 0, DIM.MainH),
        Position=UDim2.new(0.5, -DIM.MainW/2, 0.5, -DIM.MainH/2),
        BackgroundTransparency=0.05,
    }):Play()
    State.GUI_Visible = true
end

-- COMPACT HUD
UI.Compact = Create("Frame", {Size=UDim2.new(0,140,0,46), Position=UDim2.new(0.5,-70,0,8), BackgroundColor3=Color3.fromRGB(20,20,20), BackgroundTransparency=0.1, BorderSizePixel=0, Visible=false, ZIndex=50, Parent=UI.Screen})
Create("UICorner", {CornerRadius=UDim.new(0,6), Parent=UI.Compact})
Create("UIStroke", {Color=Colors.Accent, Thickness=1, Transparency=0.3, Parent=UI.Compact})
UI.CompactText = Create("TextLabel", {Size=UDim2.new(1,-8,1,-6), Position=UDim2.new(0,4,0,3), BackgroundTransparency=1, Text="", Font=Enum.Font.Code, TextSize=9, TextColor3=Colors.Text, TextXAlignment=Enum.TextXAlignment.Left, TextYAlignment=Enum.TextYAlignment.Top, Parent=UI.Compact})

-- TOASTS
UI.Toasts = Create("Frame", {Size=UDim2.new(0,180,0,300), Position=UDim2.new(1,-190,0,15), BackgroundTransparency=1, Parent=UI.Screen})
function UI.toast(msg, type)
    type = type or "info"; PushNotif(msg, type)
    local color = Colors.Accent
    if type == "success" then color = Colors.Success
    elseif type == "warning" then color = Colors.Warning
    elseif type == "danger" then color = Colors.Danger end
    local T = Create("Frame", {Size=UDim2.new(1,0,0,26), Position=UDim2.new(1,190,0,0), BackgroundColor3=Colors.Sidebar, BackgroundTransparency=0.1, BorderSizePixel=0, Parent=UI.Toasts})
    Create("UICorner", {CornerRadius=UDim.new(0,5), Parent=T})
    Create("UIStroke", {Color=color, Thickness=1, Transparency=0.3, Parent=T})
    Create("Frame", {Size=UDim2.new(0,2,1,-6), Position=UDim2.new(0,3,0,3), BackgroundColor3=color, BorderSizePixel=0, Parent=T})
    Create("TextLabel", {Text=msg, Font=Enum.Font.Gotham, TextSize=9, TextColor3=Colors.Text, BackgroundTransparency=1, Size=UDim2.new(1,-16,1,0), Position=UDim2.new(0,9,0,0), TextXAlignment=Enum.TextXAlignment.Left, TextWrapped=true, Parent=T})
    local list = {}
    for _, c in ipairs(UI.Toasts:GetChildren()) do if c:IsA("Frame") and c ~= T then list[#list+1] = c end end
    for i, t in ipairs(list) do t.Position = UDim2.new(1,190,0,i*30) end
    T.Position = UDim2.new(1,190,0,#list*30)
    SV.T:Create(T, TweenInfo.new(0.3), {Position=UDim2.new(0,0,0,#list*30)}):Play()
    task.delay(2.5, function()
        SV.T:Create(T, TweenInfo.new(0.3), {Position=UDim2.new(1,190,0,T.Position.Y.Offset)}):Play()
        task.wait(0.3); T:Destroy()
    end)
end
local ShowToast = UI.toast

-- HITMARKER
local Hitmarker = {frame = nil, lastShow = 0}
function Hitmarker:init()
    self.frame = Create("Frame", {Size=UDim2.new(0,16,0,16), AnchorPoint=Vector2.new(0.5,0.5), BackgroundTransparency=1, BorderSizePixel=0, Visible=false, ZIndex=200, Parent=UI.Screen})
    for _, rot in ipairs({45,-45,135,-135}) do
        Create("Frame", {Size=UDim2.new(0,1,0,7), Position=UDim2.new(0.5,-0.5,0.5,-3.5), BackgroundColor3=Color3.fromRGB(255,60,60), BorderSizePixel=0, Parent=self.frame}).Rotation = rot
    end
end
Hitmarker:init()
function Hitmarker:show()
    if not State.HitmarkerEnabled then return end
    local now = tick()
    if now - self.lastShow < 0.05 then return end
    self.lastShow = now
    local mp = SV.U:GetMouseLocation()
    self.frame.Position = UDim2.new(0, mp.X, 0, mp.Y)
    self.frame.Visible = true
    self.frame.Size = UDim2.new(0,16,0,16)
    SV.T:Create(self.frame, TweenInfo.new(0.15), {Size=UDim2.new(0,26,0,26)}):Play()
    task.delay(0.15, function()
        SV.T:Create(self.frame, TweenInfo.new(0.15), {Size=UDim2.new(0,16,0,16)}):Play()
        task.wait(0.15); self.frame.Visible = false
    end)
end

-- KILLFEED
local KillFeed = {container=nil, entries={}}
function KillFeed:init()
    self.container = Create("Frame", {Size=UDim2.new(0,160,0,200), Position=UDim2.new(1,-170,0,60), BackgroundTransparency=1, Parent=UI.Screen})
end
KillFeed:init()
function KillFeed:add(killer, victim)
    if not State.KillFeedEnabled then return end
    local e = Create("Frame", {Size=UDim2.new(1,0,0,18), Position=UDim2.new(1,160,0,0), BackgroundColor3=Color3.fromRGB(15,15,15), BackgroundTransparency=0.15, BorderSizePixel=0, Parent=self.container})
    Create("UICorner", {CornerRadius=UDim.new(0,4), Parent=e})
    Create("UIStroke", {Color=Colors.Accent, Thickness=1, Transparency=0.5, Parent=e})
    Create("TextLabel", {Text=string.format(" %s ➤ %s", killer:sub(1,6), victim:sub(1,6)), Font=Enum.Font.Code, TextSize=8, TextColor3=Colors.Text, BackgroundTransparency=1, Size=UDim2.new(1,-6,1,0), Position=UDim2.new(0,3,0,0), TextXAlignment=Enum.TextXAlignment.Left, Parent=e})
    table.insert(self.entries, 1, e)
    if #self.entries > 4 then local old = table.remove(self.entries); old:Destroy() end
    SV.T:Create(e, TweenInfo.new(0.25), {Position=UDim2.new(0,0,0,0)}):Play()
    for i, v in ipairs(self.entries) do SV.T:Create(v, TweenInfo.new(0.2), {Position=UDim2.new(0,0,0,(i-1)*20)}):Play() end
    task.delay(6, function()
        SV.T:Create(e, TweenInfo.new(0.3), {Position=UDim2.new(1,160,0,e.Position.Y.Offset)}):Play()
        task.wait(0.35); e:Destroy()
    end)
end

-- ═══ HEADER ═══
local TBBG = Create("Frame", {Size=UDim2.new(1,0,0,DIM.HeaderH), BackgroundColor3=Color3.fromRGB(20,20,20), BackgroundTransparency=0.05, BorderSizePixel=0, ZIndex=2, Parent=UI.Main})
Create("UICorner", {CornerRadius=UDim.new(0,8), Parent=TBBG})
local AvatarFrame = Create("Frame", {Size=UDim2.new(0,26,0,26), Position=UDim2.new(0,6,0.5,-13), BackgroundColor3=Color3.fromRGB(30,30,30), BorderSizePixel=0, ZIndex=3, Parent=TBBG})
Create("UICorner", {CornerRadius=UDim.new(0,13), Parent=AvatarFrame})
Create("UIStroke", {Color=Colors.Accent, Thickness=1, Parent=AvatarFrame})
local avatarImg = Create("ImageLabel", {Size=UDim2.new(1,-2,1,-2), Position=UDim2.new(0,1,0,1), BackgroundTransparency=1, Image="rbxthumb://type=AvatarHeadShot&id="..G.LP.UserId.."&w=100&h=100", ZIndex=4, Parent=AvatarFrame})
Create("UICorner", {CornerRadius=UDim.new(0,12), Parent=avatarImg})
Create("TextLabel", {Text="HB v22.4", Font=Enum.Font.GothamBlack, TextSize=DIM.FsTitle, TextColor3=Colors.Text, BackgroundTransparency=1, Position=UDim2.new(0,36,0,4), Size=UDim2.new(0,100,0,12), TextXAlignment=Enum.TextXAlignment.Left, ZIndex=3, Parent=TBBG})
Create("TextLabel", {Text="MOBILE", Font=Enum.Font.GothamMedium, TextSize=DIM.FsSmall, TextColor3=Colors.Accent, BackgroundTransparency=1, Position=UDim2.new(0,36,0,18), Size=UDim2.new(0,60,0,10), TextXAlignment=Enum.TextXAlignment.Left, ZIndex=3, Parent=TBBG})

local RoleBadge = Create("Frame", {Size=UDim2.new(0,74,0,16), Position=UDim2.new(0,102,0.5,-8), BackgroundColor3=Color3.fromRGB(40,40,40), BorderSizePixel=0, ZIndex=3, Parent=TBBG})
Create("UICorner", {CornerRadius=UDim.new(1,0), Parent=RoleBadge})
UI.RoleText = Create("TextLabel", {Text="Você: Inoc.", Font=Enum.Font.GothamBold, TextSize=DIM.FsSmall, TextColor3=Color3.fromRGB(0,255,100), BackgroundTransparency=1, Size=UDim2.new(1,0,1,0), ZIndex=4, Parent=RoleBadge})
local KDBadge = Create("Frame", {Size=UDim2.new(0,50,0,16), Position=UDim2.new(0,180,0.5,-8), BackgroundColor3=Color3.fromRGB(40,40,40), BorderSizePixel=0, ZIndex=3, Parent=TBBG})
Create("UICorner", {CornerRadius=UDim.new(1,0), Parent=KDBadge})
UI.KDText = Create("TextLabel", {Text="K 0/0", Font=Enum.Font.GothamBold, TextSize=DIM.FsSmall, TextColor3=Colors.Text, BackgroundTransparency=1, Size=UDim2.new(1,0,1,0), ZIndex=4, Parent=KDBadge})
local PingBadge = Create("Frame", {Size=UDim2.new(0,60,0,16), Position=UDim2.new(0,234,0.5,-8), BackgroundColor3=Color3.fromRGB(40,40,40), BorderSizePixel=0, ZIndex=3, Parent=TBBG})
Create("UICorner", {CornerRadius=UDim.new(1,0), Parent=PingBadge})
UI.PingText = Create("TextLabel", {Text="Ping --", Font=Enum.Font.GothamBold, TextSize=DIM.FsSmall, TextColor3=Color3.fromRGB(0,200,100), BackgroundTransparency=1, Size=UDim2.new(1,0,1,0), ZIndex=4, Parent=PingBadge})
local CloseBtn = Create("TextButton", {Text="X", Font=Enum.Font.GothamBold, TextSize=12, TextColor3=Colors.SubText, BackgroundTransparency=1, Size=UDim2.new(0,20,0,20), Position=UDim2.new(1,-24,0.5,-10), ZIndex=3, Parent=TBBG})
CloseBtn.MouseButton1Click:Connect(function() PlayUISound(); UI.Hide() end)

-- ═══ SIDEBAR ═══
UI.Sidebar = Create("Frame", {Size=UDim2.new(0, DIM.SidebarW, 0, DIM.MainH - DIM.HeaderH - DIM.StatusH - 6), Position=UDim2.new(0,3,DIM.HeaderH,3), BackgroundColor3=Colors.Sidebar, BackgroundTransparency=0.15, BorderSizePixel=0, ZIndex=2, Parent=UI.Main})
Create("UICorner", {CornerRadius=UDim.new(0,6), Parent=UI.Sidebar})
UI.ContentArea = Create("Frame", {Size=UDim2.new(1, -DIM.SidebarW - 10, 1, -DIM.HeaderH - DIM.StatusH - 10), Position=UDim2.new(0, DIM.SidebarW + 6, DIM.HeaderH, 3), BackgroundTransparency=1, ZIndex=2, Parent=UI.Main})

UI.TabButtons, UI.TabContents = {}, {}
local TabsList = {{"⚔","Flick"},{"◉","ESP"},{"✦","Vis"},{"▤","Stats"},{"◈","IA"},{"⚙","Cfg"}}
local ScrollingTabs = Create("ScrollingFrame", {Size=UDim2.new(1,-4,1,-4), Position=UDim2.new(0,2,0,2), BackgroundTransparency=1, ScrollBarThickness=2, ScrollBarImageColor3=Colors.Accent, ZIndex=3, Parent=UI.Sidebar})
ScrollingTabs.CanvasSize = UDim2.new(0,0,0,#TabsList*(DIM.TabH+2)+4)
local ActiveBar = Create("Frame", {Size=UDim2.new(0,2,0,DIM.TabH-4), Position=UDim2.new(0,0,0,2), BackgroundColor3=Colors.Accent, BorderSizePixel=0, ZIndex=4, Parent=ScrollingTabs})
Create("UICorner", {CornerRadius=UDim.new(1,0), Parent=ActiveBar})

UI.switchTab = function(name)
    for n, f in pairs(UI.TabContents) do f.Visible = (n == name) end
    for _, b in ipairs(UI.TabButtons) do
        if b:GetAttribute("TabName") == name then
            SV.T:Create(b, TweenInfo.new(0.2), {BackgroundTransparency=0.2, TextColor3=Colors.Accent}):Play()
            SV.T:Create(ActiveBar, TweenInfo.new(0.25), {Position=UDim2.new(0,0,0,b.Position.Y.Offset+2), Size=UDim2.new(0,2,0,b.AbsoluteSize.Y-4)}):Play()
        else
            SV.T:Create(b, TweenInfo.new(0.2), {BackgroundTransparency=0.5, TextColor3=Colors.Text}):Play()
        end
    end
end

for i, tabData in ipairs(TabsList) do
    local icon, tabName = tabData[1], tabData[2]
    local Btn = Create("TextButton", {
        Text = icon.." "..tabName, Font=Enum.Font.GothamMedium, TextSize=DIM.FsSmall, TextColor3=Colors.Text,
        BackgroundColor3=Colors.ElementBg, BackgroundTransparency=0.5,
        Size=UDim2.new(1,-2,0,DIM.TabH), Position=UDim2.new(0,1,0,(i-1)*(DIM.TabH+2)+2),
        TextXAlignment=Enum.TextXAlignment.Left, ZIndex=4, Parent=ScrollingTabs,
    })
    Btn:SetAttribute("TabName", tabName)
    Create("UICorner", {CornerRadius=UDim.new(0,4), Parent=Btn})
    Btn.MouseButton1Click:Connect(function() PlayUISound(); UI.switchTab(tabName) end)
    UI.TabButtons[#UI.TabButtons+1] = Btn
end

local StatusBar = Create("Frame", {Size=UDim2.new(1,-6,0,DIM.StatusH), Position=UDim2.new(0,3,1,-DIM.StatusH-3), BackgroundColor3=Color3.fromRGB(18,18,18), BorderSizePixel=0, ZIndex=2, Parent=UI.Main})
Create("UICorner", {CornerRadius=UDim.new(0,4), Parent=StatusBar})
UI.StatusText = Create("TextLabel", {Text="Ready", Font=Enum.Font.Code, TextSize=DIM.FsSmall, TextColor3=Colors.SubText, BackgroundTransparency=1, Size=UDim2.new(1,-8,1,0), Position=UDim2.new(0,4,0,0), TextXAlignment=Enum.TextXAlignment.Left, ZIndex=3, Parent=StatusBar})

-- ═══ UI HELPERS ═══
local function Section(parent, text, yPos)
    Create("Frame", {Size=UDim2.new(0,2,0,8), Position=UDim2.new(0,0,0,yPos+3), BackgroundColor3=Colors.Accent, BorderSizePixel=0, ZIndex=3, Parent=parent})
    Create("TextLabel", {Text=text, Font=Enum.Font.GothamBold, TextSize=DIM.FsNorm, TextColor3=Colors.Text, BackgroundTransparency=1, Size=UDim2.new(1,0,0,14), Position=UDim2.new(0,6,0,yPos), TextXAlignment=Enum.TextXAlignment.Left, ZIndex=3, Parent=parent})
    Create("Frame", {Size=UDim2.new(1,-4,0,1), Position=UDim2.new(0,0,0,yPos+14), BackgroundColor3=Colors.SubText, BackgroundTransparency=0.7, BorderSizePixel=0, ZIndex=3, Parent=parent})
    return yPos + 19
end

local function Toggle(parent, text, yPos, def, cb)
    local F = Create("Frame", {Size=UDim2.new(1,-3,0,DIM.RowH), Position=UDim2.new(0,0,0,yPos), BackgroundColor3=Colors.ElementBg, BackgroundTransparency=0.4, BorderSizePixel=0, ZIndex=3, Parent=parent})
    Create("UICorner", {CornerRadius=UDim.new(0,4), Parent=F})
    Create("TextLabel", {Text=text, Font=Enum.Font.Gotham, TextSize=DIM.FsNorm, TextColor3=Colors.Text, BackgroundTransparency=1, Size=UDim2.new(1,-36,1,0), Position=UDim2.new(0,6,0,0), TextXAlignment=Enum.TextXAlignment.Left, TextWrapped=true, ZIndex=4, Parent=F})
    local Bg = Create("Frame", {Size=UDim2.new(0,26,0,13), Position=UDim2.new(1,-31,0.5,-6.5), BackgroundColor3=def and Colors.Accent or Colors.ToggleOff, BorderSizePixel=0, ZIndex=4, Parent=F})
    Create("UICorner", {CornerRadius=UDim.new(1,0), Parent=Bg})
    local C = Create("Frame", {Size=UDim2.new(0,9,0,9), Position=def and UDim2.new(1,-11,0.5,-4.5) or UDim2.new(0,2,0.5,-4.5), BackgroundColor3=Color3.fromRGB(255,255,255), BorderSizePixel=0, ZIndex=5, Parent=Bg})
    Create("UICorner", {CornerRadius=UDim.new(1,0), Parent=C})
    local on = def
    F.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            on = not on; PlayUISound(on and 1.3 or 0.9)
            SV.T:Create(Bg, TweenInfo.new(0.15), {BackgroundColor3=on and Colors.Accent or Colors.ToggleOff}):Play()
            SV.T:Create(C, TweenInfo.new(0.15), {Position=on and UDim2.new(1,-11,0.5,-4.5) or UDim2.new(0,2,0.5,-4.5)}):Play()
            if cb then SafeRun(cb, on) end
        end
    end)
    return yPos + DIM.RowH + 3
end

local function Slider(parent, text, mn, mx, def, yPos, cb)
    local F = Create("Frame", {Size=UDim2.new(1,-3,0,DIM.RowH+3), Position=UDim2.new(0,0,0,yPos), BackgroundColor3=Colors.ElementBg, BackgroundTransparency=0.4, BorderSizePixel=0, ZIndex=3, Parent=parent})
    Create("UICorner", {CornerRadius=UDim.new(0,4), Parent=F})
    Create("TextLabel", {Text=text, Font=Enum.Font.Gotham, TextSize=DIM.FsSmall, TextColor3=Colors.Text, BackgroundTransparency=1, Size=UDim2.new(0.55,-8,0.5,0), Position=UDim2.new(0,5,0,3), TextXAlignment=Enum.TextXAlignment.Left, ZIndex=4, Parent=F})
    local VL = Create("TextLabel", {Text=tostring(def), Font=Enum.Font.Code, TextSize=DIM.FsSmall, TextColor3=Colors.Accent, BackgroundTransparency=1, Size=UDim2.new(0,24,0.5,0), Position=UDim2.new(0.55,-3,0,3), TextXAlignment=Enum.TextXAlignment.Center, ZIndex=4, Parent=F})
    local Bg = Create("Frame", {Size=UDim2.new(0.38,-6,0,3), Position=UDim2.new(0.58,3,0.7,0), BackgroundColor3=Colors.ToggleOff, BorderSizePixel=0, ZIndex=4, Parent=F})
    Create("UICorner", {CornerRadius=UDim.new(1,0), Parent=Bg})
    local Fl = Create("Frame", {Size=UDim2.new((def-mn)/(mx-mn),0,1,0), BackgroundColor3=Colors.Accent, BorderSizePixel=0, ZIndex=5, Parent=Bg})
    Create("UICorner", {CornerRadius=UDim.new(1,0), Parent=Fl})
    local H = Create("Frame", {Size=UDim2.new(0,8,0,8), Position=UDim2.new((def-mn)/(mx-mn),-4,0.5,-4), BackgroundColor3=Color3.fromRGB(255,255,255), BorderSizePixel=0, ZIndex=6, Parent=Bg})
    Create("UICorner", {CornerRadius=UDim.new(1,0), Parent=H})
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
            if cb then SafeRun(cb, nv) end
        end
    end)
    return yPos + DIM.RowH + 6
end

local function Button(parent, text, yPos, cb)
    local B = Create("TextButton", {
        Text=" "..text, Font=Enum.Font.Gotham, TextSize=DIM.FsNorm,
        TextColor3=Colors.Text, BackgroundColor3=Colors.ElementBg,
        BackgroundTransparency=0.4, Size=UDim2.new(1,-3,0,DIM.RowH),
        Position=UDim2.new(0,0,0,yPos),
        TextXAlignment=Enum.TextXAlignment.Left, ZIndex=3, Parent=parent,
    })
    Create("UICorner", {CornerRadius=UDim.new(0,4), Parent=B})
    B.MouseButton1Click:Connect(function() PlayUISound(); if cb then SafeRun(cb) end end)
    return yPos + DIM.RowH + 3
end

local function Dropdown(parent, text, opts, def, yPos, cb)
    local F = Create("Frame", {Size=UDim2.new(1,-3,0,DIM.RowH+3), Position=UDim2.new(0,0,0,yPos), BackgroundColor3=Colors.ElementBg, BackgroundTransparency=0.4, BorderSizePixel=0, ZIndex=3, Parent=parent})
    Create("UICorner", {CornerRadius=UDim.new(0,4), Parent=F})
    Create("TextLabel", {Text=text, Font=Enum.Font.Gotham, TextSize=DIM.FsSmall, TextColor3=Colors.Text, BackgroundTransparency=1, Size=UDim2.new(0.5,-6,1,0), Position=UDim2.new(0,5,0,0), TextXAlignment=Enum.TextXAlignment.Left, ZIndex=4, Parent=F})
    local B = Create("TextButton", {
        Text=def, Font=Enum.Font.GothamBold, TextSize=DIM.FsSmall,
        TextColor3=Colors.Accent, BackgroundColor3=Color3.fromRGB(18,18,18),
        BorderSizePixel=0, Size=UDim2.new(0.45,-4,0,18),
        Position=UDim2.new(0.5,3,0.5,-9),
        TextXAlignment=Enum.TextXAlignment.Center, ZIndex=4, Parent=F,
    })
    Create("UICorner", {CornerRadius=UDim.new(0,3), Parent=B})
    local idx = 1
    for i, o in ipairs(opts) do if o == def then idx = i; break end end
    B.MouseButton1Click:Connect(function()
        PlayUISound(1.3); idx = idx + 1
        if idx > #opts then idx = 1 end
        B.Text = opts[idx]
        if cb then SafeRun(cb, opts[idx]) end
    end)
    return yPos + DIM.RowH + 6
end

-- ═══ ESP ═══
local ESPCache = {}
local function destroyESP(p)
    local e = ESPCache[p]; if not e then return end
    for _, k in ipairs({"hl", "nameBg"}) do if e[k] then pcall(function() e[k]:Destroy() end) end end
    ESPCache[p] = nil
end
local function applyESP(p)
    if p == G.LP or not State.ESP then return end
    local char = CACHE.Characters[p]
    if not char or not char.Parent then destroyESP(p); return end
    local hum = char:FindFirstChildOfClass("Humanoid")
    if not hum or hum.Health <= 0 then destroyESP(p); return end
    local role = getRole(p)
    local color = role == "Murderer" and Color3.fromRGB(255,0,0) or (role == "Sheriff" and Color3.fromRGB(0,100,255) or Color3.fromRGB(0,255,0))
    local e = ESPCache[p]; if not e then e = {}; ESPCache[p] = e end
    if not e.hl or e.hl.Parent ~= char then
        if e.hl then pcall(function() e.hl:Destroy() end) end
        local hl = Instance.new("Highlight"); hl.Name = G.HNAME
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
                bg.Name = G.HNAME.."_nm"; bg.Size = UDim2.new(0,120,0,12)
                bg.StudsOffset = Vector3.new(0,2.8,0); bg.AlwaysOnTop = true
                bg.Adornee = head; bg.Parent = head
                local txt = Instance.new("TextLabel", bg)
                txt.Name = "Txt"; txt.Size = UDim2.new(1,0,1,0)
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
    triggeredBy="manual", keyHeld=false, debug=true,
}
local _hitDetectors = {}

local function attachHitDetector(hum)
    if not hum or _hitDetectors[hum] then return end
    _hitDetectors[hum] = true
    local last = hum.Health
    hum.HealthChanged:Connect(function(h)
        if h < last and flick.active and flick.targetHumanoid == hum then
            flick.hitVerified = true; Hitmarker:show()
            if flick.debug then ShowToast(string.format("[HIT] -%d hp", math.floor(last-h)), "success") end
        end
        last = h
    end)
end

local function findWeapon()
    if not G.LP.Character then return nil end
    local eq = G.LP.Character:FindFirstChildOfClass("Tool")
    local bp = G.LP:FindFirstChild("Backpack")
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
    if not tool or not G.LP.Character then return false end
    if tool.Parent == G.LP.Character then return true end
    local hum = G.LP.Character:FindFirstChildOfClass("Humanoid")
    if not hum then return false end
    return pcall(function() hum:EquipTool(tool) end)
end

local function findMurderer()
    local origin = CACHE.HRPParts[G.LP] and CACHE.HRPParts[G.LP].Position or G.Cam.CFrame.Position
    local best, bestD = nil, 500
    for _, p in ipairs(CACHE.PlayersList) do
        if p ~= G.LP and getRole(p) == "Murderer" then
            local char = CACHE.Characters[p]; local hrp = CACHE.HRPParts[p]
            if char and char.Parent and hrp then
                local hum = char:FindFirstChildOfClass("Humanoid")
                if hum and hum.Health > 0 then
                    local d = (hrp.Position - origin).Magnitude
                    if d < bestD then bestD = d; best = {player=p, char=char, hum=hum, dist=d} end
                end
            end
        end
    end
    return best
end

local function startFlick(target, triggeredBy)
    if not flick.originalCameraType then flick.originalCameraType = G.Cam.CameraType end
    if not flick.originalCameraSubject then flick.originalCameraSubject = G.Cam.CameraSubject end
    local startCF = G.Cam.CFrame
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
                    flick.killed = true; flick.hitStreak = flick.hitStreak + 1; flick.missStreak = 0
                    ShowToast(string.format("KILL %s", pl.Name:sub(1,8)), "success")
                    KillFeed:add(G.LP.Name, pl.Name)
                    PlayUISound(1.8); State.Kills = State.Kills + 1
                end
            end)
        end
    end
    G.Cam.CameraType = Enum.CameraType.Scriptable
    G.Cam.CameraSubject = nil
end

local function endFlick()
    if not flick.active then return end
    flick.phase = "return"; flick.returnStartTick = tick()
    flick.returnStartCF = G.Cam.CFrame; flick.returnTargetCF = flick.originCF
end

SV.R:BindToRenderStep("HBAutoFlick", Enum.RenderPriority.Camera.Value + 10, function(dt)
    if not G.Cam or not G.Cam.Parent then G.Cam = workspace.CurrentCamera end
    if not G.Cam then return end

    if flick.phase == "return" and flick.active then
        local elapsed = tick() - flick.returnStartTick
        local t = math.clamp(elapsed / flick.returnDur, 0, 1)
        local eased = 1 - (1 - t)^3
        local pos = flick.returnStartCF.Position:Lerp(flick.returnTargetCF.Position, eased)
        local lookFrom = flick.returnStartCF.Position + flick.returnStartCF.LookVector * 100
        local lookTo = flick.returnTargetCF.Position + flick.returnTargetCF.LookVector * 100
        G.Cam.CameraType = Enum.CameraType.Scriptable; G.Cam.CameraSubject = nil
        G.Cam.CFrame = CFrame.lookAt(pos, lookFrom:Lerp(lookTo, eased))
        if t >= 1 then
            flick.active = false; flick.phase = "idle"
            flick.targetPlayer = nil; flick.targetChar = nil; flick.targetHumanoid = nil
            flick.lastFlickEnd = tick(); flick.retriesLeft = flick.retries
            local hum = G.LP.Character and G.LP.Character:FindFirstChildOfClass("Humanoid")
            if hum then hum.AutoRotate = true end
            if flick.originalCameraType then
                G.Cam.CameraType = flick.originalCameraType
                G.Cam.CameraSubject = flick.originalCameraSubject
                flick.originalCameraType = nil; flick.originalCameraSubject = nil
            end
        end
        return
    end

    if not flick.active then
        if tick() - flick.lastFlickEnd < flick.cooldown then return end
        local manualKey = State.AutoFlick and (flick.keyHeld or SV.U:IsKeyDown(State.AutoFlickKey))
        if manualKey then
            local t = findMurderer()
            if t then flick.lastFlickEnd = tick(); startFlick(t, "manual") end
        elseif State.TriggerBot then
            local mouse = SV.U:GetMouseLocation()
            for _, p in ipairs(CACHE.PlayersList) do
                if p == G.LP or getRole(p) ~= "Murderer" then continue end
                local char = CACHE.Characters[p]; local head = CACHE.HeadParts[p]
                if char and head then
                    local sp, on = G.Cam:WorldToViewportPoint(head.Position)
                    if on and sp.Z > 0 then
                        local d = (Vector2.new(sp.X, sp.Y) - mouse).Magnitude
                        if d < State.TriggerRadius then
                            local hum = char:FindFirstChildOfClass("Humanoid")
                            local hrp = CACHE.HRPParts[p]; local lpHrp = CACHE.HRPParts[G.LP]
                            if hum and hum.Health > 0 and hrp and lpHrp then
                                local dist = (hrp.Position - lpHrp.Position).Magnitude
                                if dist < 500 then
                                    flick.lastFlickEnd = tick()
                                    startFlick({player=p, char=char, hum=hum, dist=dist}, "trigger")
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

    local lpHead = CACHE.HeadParts[G.LP]
    local camPos = lpHead and lpHead.Position or G.Cam.CFrame.Position
    local aimPos, flightT, dist = computePreciseAim(tp, char, camPos, Silent.bulletSpeed)
    if not aimPos then endFlick(); return end
    flick.aimPos = aimPos

    if flick.phase == "snap" then
        local elapsed = tick() - flick.startTick
        local roughDur = flick.snapDur * 0.7; local fineDur = flick.snapDur * 0.3
        if elapsed < roughDur then
            local t = math.clamp(elapsed / roughDur, 0, 1)
            local eased = 1 - (1 - t)^4
            local look = flick.originLookAt:Lerp(aimPos, eased)
            G.Cam.CameraType = Enum.CameraType.Scriptable; G.Cam.CameraSubject = nil
            G.Cam.CFrame = CFrame.lookAt(camPos, look)
        elseif elapsed < roughDur + fineDur then
            local newAim = computePreciseAim(tp, char, camPos, Silent.bulletSpeed)
            G.Cam.CFrame = CFrame.lookAt(camPos, newAim or aimPos)
        else
            flick.phase = "hold"; flick.holdStartTick = tick()
        end
        return
    end

    if flick.phase == "hold" then
        G.Cam.CameraType = Enum.CameraType.Scriptable; G.Cam.CameraSubject = nil
        G.Cam.CFrame = CFrame.lookAt(camPos, aimPos)
        local camLook = G.Cam.CFrame.LookVector
        local targetDir = (aimPos - camPos).Unit
        local angle = math.deg(math.acos(math.clamp(camLook:Dot(targetDir), -1, 1)))
        if flick.shotsFired == 0 and angle <= flick.alignTolerance then
            local weapon = findWeapon()
            if not weapon then endFlick(); return end
            local eq = G.LP.Character:FindFirstChildOfClass("Tool")
            if eq ~= weapon then equip(weapon); task.wait(0.08); eq = G.LP.Character:FindFirstChildOfClass("Tool") end
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

    if flick.phase == "verify" then
        G.Cam.CFrame = CFrame.lookAt(G.Cam.CFrame.Position, aimPos)
        local killed = not hum.Parent or hum.Health <= 0
        if killed then flick.killed = true end
        if flick.hitVerified then endFlick(); return end
        local elapsed = tick() - flick.verifyStart
        if elapsed >= flick.verifyWait then
            local hpNow = hum.Health or 0
            if hpNow < flick.hpBefore then flick.hitVerified = true; endFlick(); return end
            if flick.retriesLeft > 0 and flick.shotsFired > 0 and not flick.killed then
                flick.retriesLeft = flick.retriesLeft - 1
                flick.missStreak = flick.missStreak + 1; flick.hitStreak = 0
                flick.phase = "snap"; flick.startTick = tick()
                flick.shotsFired = 0; flick.hitVerified = false
                flick.hpBefore = hum.Health
                flick.originLookAt = G.Cam.CFrame.Position + G.Cam.CFrame.LookVector * 100
                if Histories[tp] then Histories[tp].samples = {} end
                return
            end
            endFlick()
        end
        return
    end
end)

-- ═══ INPUT ═══
SV.U.InputBegan:Connect(function(input, gp)
    if gp then return end
    if input.UserInputType == Enum.UserInputType.Keyboard and input.KeyCode == State.AutoFlickKey then flick.keyHeld = true end
    if input.KeyCode == Enum.KeyCode.Insert then
        State.GUI_Visible = not State.GUI_Visible
        if State.GUI_Visible then UI.Show() else UI.Hide() end
    end
    if input.KeyCode == Enum.KeyCode.F1 then
        State.AutoFlick = false; State.TriggerBot = false; State.ESP = false
        ShowToast("PANIC", "danger")
    end
end)
SV.U.InputEnded:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.Keyboard and input.KeyCode == State.AutoFlickKey then flick.keyHeld = false end
end)

-- ═══ TABS ═══
local function buildFlickTab()
    local p = Create("ScrollingFrame", {Name="Flick", Size=UDim2.new(1,0,1,0), BackgroundTransparency=1, ScrollBarThickness=2, ScrollBarImageColor3=Colors.Accent, Visible=false, ZIndex=3, Parent=UI.ContentArea})
    UI.TabContents["Flick"] = p
    p.CanvasSize = UDim2.new(0,0,0,500); p.AutomaticCanvasSize = Enum.AutomaticSize.Y
    local y = 2
    y = Section(p, "AUTO FLICK", y)
    y = Toggle(p, "Auto Flick", y, true, function(s) State.AutoFlick = s end)
    y = Toggle(p, "Trigger Bot", y, true, function(s) State.TriggerBot = s end)
    y = Slider(p, "Trigger R", 10, 120, 40, y, function(v) State.TriggerRadius = v end)
    y = Toggle(p, "IA", y, true, function(s) State.AIEnabled = s end)
    y = Toggle(p, "Silent", y, true, function(s) Silent.enabled = s end)
    y = Section(p, "TIMINGS", y)
    y = Slider(p, "Snap ms", 10, 100, 45, y, function(v) flick.snapDur = v/1000 end)
    y = Slider(p, "Hold ms", 50, 400, 150, y, function(v) flick.holdDur = v/1000 end)
    y = Slider(p, "Verify ms", 200, 1000, 500, y, function(v) flick.verifyWait = v/1000 end)
    y = Slider(p, "Return ms", 30, 300, 100, y, function(v) flick.returnDur = v/100 end)
    y = Slider(p, "Cooldown", 50, 500, 150, y, function(v) flick.cooldown = v/100 end)
    y = Section(p, "PRECISAO", y)
    y = Slider(p, "Align °", 1, 15, 4, y, function(v) flick.alignTolerance = math.floor(v) end)
    y = Slider(p, "Retries", 0, 3, 2, y, function(v) flick.retries = math.floor(v) end)
    y = Slider(p, "Restore", 50, 300, 120, y, function(v) Silent.restoreDelay = v/1000 end)
    y = Button(p, "PIPELINE ON", y, function()
        State.AutoFlick = true; State.TriggerBot = true; State.AIEnabled = true; Silent.enabled = true
        flick.alignTolerance = 4; flick.retries = 2; flick.cooldown = 0.15
        ShowToast("Pipeline ON", "success")
    end)
end

local function buildESPTab()
    local p = Create("ScrollingFrame", {Name="ESP", Size=UDim2.new(1,0,1,0), BackgroundTransparency=1, ScrollBarThickness=2, ScrollBarImageColor3=Colors.Accent, Visible=false, ZIndex=3, Parent=UI.ContentArea})
    UI.TabContents["ESP"] = p
    p.CanvasSize = UDim2.new(0,0,0,300)
    local y = 2
    y = Section(p, "ESP", y)
    y = Toggle(p, "ESP", y, false, function(s) State.ESP = s; if not s then for pl in pairs(ESPCache) do destroyESP(pl) end end end)
    y = Toggle(p, "Nome", y, true, function(s) State.ESPName = s end)
end

local function buildVisualTab()
    local p = Create("ScrollingFrame", {Name="Visual", Size=UDim2.new(1,0,1,0), BackgroundTransparency=1, ScrollBarThickness=2, ScrollBarImageColor3=Colors.Accent, Visible=false, ZIndex=3, Parent=UI.ContentArea})
    UI.TabContents["Visual"] = p
    p.CanvasSize = UDim2.new(0,0,0,300)
    local y = 2
    y = Section(p, "VISUAL", y)
    y = Toggle(p, "Fullbright", y, false, function(s)
        if s then SV.L.Ambient = Color3.fromRGB(255,255,255); SV.L.Brightness = 2
        else SV.L.Ambient = Color3.fromRGB(70,70,70); SV.L.Brightness = 1 end
    end)
    y = Section(p, "HUD", y)
    y = Toggle(p, "Hitmarker", y, true, function(s) State.HitmarkerEnabled = s end)
    y = Toggle(p, "Kill Feed", y, true, function(s) State.KillFeedEnabled = s end)
    y = Toggle(p, "Compact", y, false, function(s) State.CompactHUD = s end)
end

local function buildStatsTab()
    local p = Create("ScrollingFrame", {Name="Stats", Size=UDim2.new(1,0,1,0), BackgroundTransparency=1, ScrollBarThickness=2, ScrollBarImageColor3=Colors.Accent, Visible=false, ZIndex=3, Parent=UI.ContentArea})
    UI.TabContents["Stats"] = p
    p.CanvasSize = UDim2.new(0,0,0,400); p.AutomaticCanvasSize = Enum.AutomaticSize.Y
    UI.StatsDisplay = Create("TextLabel", {Size=UDim2.new(1,-8,0,0), Position=UDim2.new(0,4,0,4), AutomaticSize=Enum.AutomaticSize.Y, BackgroundTransparency=1, Text="", Font=Enum.Font.Code, TextSize=9, TextColor3=Colors.Text, TextXAlignment=Enum.TextXAlignment.Left, TextYAlignment=Enum.TextYAlignment.Top, TextWrapped=true, ZIndex=4, Parent=p})
end

local function buildIATab()
    local p = Create("ScrollingFrame", {Name="IA", Size=UDim2.new(1,0,1,0), BackgroundTransparency=1, ScrollBarThickness=2, ScrollBarImageColor3=Colors.Accent, Visible=false, ZIndex=3, Parent=UI.ContentArea})
    UI.TabContents["IA"] = p
    p.CanvasSize = UDim2.new(0,0,0,500); p.AutomaticCanvasSize = Enum.AutomaticSize.Y
    local y = 2
    y = Section(p, "IA LIVE", y)
    local st = Create("TextLabel", {Size=UDim2.new(1,-8,0,180), Position=UDim2.new(0,4,0,y), BackgroundTransparency=1, Text="", Font=Enum.Font.Code, TextSize=8, TextColor3=Colors.Accent, TextXAlignment=Enum.TextXAlignment.Left, TextYAlignment=Enum.TextYAlignment.Top, ZIndex=4, Parent=p})
    task.spawn(function()
        while task.wait(0.2) do
            if not st.Parent then break end
            local lines = {}
            table.insert(lines, "Fase: "..flick.phase)
            table.insert(lines, "Trigger: "..flick.triggeredBy)
            table.insert(lines, "Alvo: "..(flick.targetPlayer and flick.targetPlayer.Name:sub(1,8) or "-"))
            table.insert(lines, "Shots: "..flick.shotsFired.." Retry: "..(flick.retries-(flick.retriesLeft or 0)))
            table.insert(lines, "Hit: "..(flick.hitVerified and "SIM" or "não"))
            table.insert(lines, "")
            for _, pl in ipairs(CACHE.PlayersList) do
                if pl ~= G.LP and getRole(pl) == "Murderer" then
                    local h = Histories[pl]
                    if h then
                        table.insert(lines, pl.Name:sub(1,10).." s:"..#h.samples)
                        table.insert(lines, string.format("v:%.0f a:%.0f", h.velocity.Magnitude, h.acceleration.Magnitude))
                    end
                end
            end
            st.Text = table.concat(lines, "\n")
        end
    end)
end

local function buildConfigTab()
    local p = Create("ScrollingFrame", {Name="Config", Size=UDim2.new(1,0,1,0), BackgroundTransparency=1, ScrollBarThickness=2, ScrollBarImageColor3=Colors.Accent, Visible=false, ZIndex=3, Parent=UI.ContentArea})
    UI.TabContents["Config"] = p
    p.CanvasSize = UDim2.new(0,0,0,400)
    local y = 2
    y = Section(p, "TEMA", y)
    local names = {}
    for k in pairs(Themes) do names[#names+1] = k end
    y = Dropdown(p, "Tema", names, "Red", y, function(o) ApplyTheme(o) end)
    y = Section(p, "CFG", y)
    y = Button(p, "Salvar", y, function() SaveConfig(); ShowToast("Salvo", "success") end)
    y = Button(p, "Carregar", y, function() LoadConfig(); ShowToast("Carregado", "info") end)
    y = Toggle(p, "Sons", y, true, function(s) State.UI_Sounds = s end)
    y = Toggle(p, "AutoSave", y, true, function(s) State.AutoSave = s end)
end

buildFlickTab(); buildESPTab(); buildVisualTab(); buildStatsTab(); buildIATab(); buildConfigTab()
UI.switchTab("Flick")

-- ═══ SAVE/LOAD/THEME ═══
function SaveConfig()
    local data = {}
    for k, v in pairs(State) do
        if type(v) ~= "userdata" and type(v) ~= "function" and type(v) ~= "table" and k:sub(1,1) ~= "_" then
            if k == "AutoFlickKey" then data[k] = v.Name else data[k] = v end
        end
    end
    pcall(function() if writefile then writefile("hb_v224.json", SV.H:JSONEncode(data)) end end)
end
function LoadConfig()
    pcall(function()
        if readfile and isfile and isfile("hb_v224.json") then
            local data = SV.H:JSONDecode(readfile("hb_v224.json"))
            for k, v in pairs(data) do
                if k == "AutoFlickKey" and type(v) == "string" then
                    for _, code in pairs(Enum.KeyCode:GetEnumItems()) do if code.Name == v then State.AutoFlickKey = code; break end end
                elseif State[k] ~= nil then State[k] = v end
            end
        end
    end)
end
LoadConfig()
task.spawn(function() while task.wait(45) do if State.AutoSave then SaveConfig() end end end)

function ApplyTheme(name)
    local t = Themes[name]; if not t then return end
    State.Theme = name; Colors.Accent = t.Accent; Colors.Border = t.Border
    UI.MainStroke.Color = Colors.Border; ActiveBar.BackgroundColor3 = Colors.Accent
end

-- ═══ ANTI-CHEAT ═══
local function makeSlow(fn) task.spawn(function() while task.wait(0.1) do SafeRun(fn) end end) end
makeSlow(function()
    if not State.AntiFling2 then return end
    local hrp = CACHE.HRPParts[G.LP]; if not hrp then return end
    if hrp.AssemblyLinearVelocity.Magnitude > 250 or hrp.AssemblyAngularVelocity.Magnitude > 50 then
        hrp.AssemblyLinearVelocity = Vector3.zero; hrp.AssemblyAngularVelocity = Vector3.zero
    end
end)
makeSlow(function()
    if not State.AntiRagdoll then return end
    if not G.LP.Character then return end
    local hum = G.LP.Character:FindFirstChildOfClass("Humanoid")
    if hum and hum:GetState() == Enum.HumanoidStateType.Physics then hum:ChangeState(Enum.HumanoidStateType.GettingUp) end
end)
makeSlow(function()
    if not State.AntiVoid then return end
    local hrp = CACHE.HRPParts[G.LP]; if not hrp then return end
    if hrp.Position.Y < -50 then local s = workspace:FindFirstChild("SpawnLocation"); if s then hrp.CFrame = s.CFrame + Vector3.new(0,5,0) end end
end)
local lastHRPPos = nil
makeSlow(function()
    if not State.AntiTP then lastHRPPos = nil; return end
    local hrp = CACHE.HRPParts[G.LP]; if not hrp then return end
    if lastHRPPos then
        local d = (hrp.Position - lastHRPPos).Magnitude
        if d > 200 then local s = workspace:FindFirstChild("SpawnLocation"); if s then hrp.CFrame = s.CFrame + Vector3.new(0,3,0) end end
    end
    lastHRPPos = hrp.Position
end)
makeSlow(function()
    if not State.PingRealtime then return end
    local ping = math.floor(G.LP:GetNetworkPing() * 1000)
    UI.PingText.Text = ping.."ms"
    if ping < 80 then UI.PingText.TextColor3 = Color3.fromRGB(0,200,100)
    elseif ping < 150 then UI.PingText.TextColor3 = Color3.fromRGB(255,180,0)
    else UI.PingText.TextColor3 = Color3.fromRGB(255,60,60) end
end)

G.LP.CharacterAdded:Connect(function(char)
    local hum = char:WaitForChild("Humanoid", 5)
    if hum then hum.Died:Connect(function() State.Deaths = State.Deaths + 1 end) end
end)

-- ═══ HUD ═══
local statFrame = 0
SV.R.Heartbeat:Connect(function(dt)
    local r = getRole(G.LP)
    if r == "Murderer" then UI.RoleText.Text = "Você: Murd."; UI.RoleText.TextColor3 = Color3.fromRGB(255,0,0)
    elseif r == "Sheriff" then UI.RoleText.Text = "Você: Xerife"; UI.RoleText.TextColor3 = Color3.fromRGB(0,150,255)
    else UI.RoleText.Text = "Você: Inoc."; UI.RoleText.TextColor3 = Color3.fromRGB(0,255,100) end
    statFrame = statFrame + dt
    if statFrame >= 1 then
        statFrame = 0
        local ping = math.floor(G.LP:GetNetworkPing() * 1000)
        UI.StatusText.Text = string.format("%s | P:%d | H:%d M:%d", flick.phase, ping, flick.hitStreak, flick.missStreak)
        UI.KDText.Text = string.format("K %d/%d", State.Kills, State.Deaths)
    end
    if State.CompactHUD then
        UI.Compact.Visible = true
        UI.CompactText.Text = string.format("v22.4 K:%d\nFase:%s\nHit:%s P:%d",
            State.Kills, flick.phase, flick.hitVerified and "SIM" or "não", math.floor(G.LP:GetNetworkPing()*1000))
    else UI.Compact.Visible = false end
end)

task.spawn(function()
    while task.wait(1) do
        if UI.StatsDisplay then
            local mCount = 0
            for _, p in ipairs(CACHE.PlayersList) do if p ~= G.LP and getRole(p) == "Murderer" then mCount = mCount + 1 end end
            UI.StatsDisplay.Text = string.format(
                "SESSION v22.4 MOBILE\n\nKills: %d\nDeaths: %d\n\nHit: %d\nMiss: %d\n\nMurderers: %d\nPing: %dms\nFase: %s\nRetry: %d/%d\nHit ok: %s",
                State.Kills, State.Deaths, flick.hitStreak, flick.missStreak, mCount,
                math.floor(G.LP:GetNetworkPing()*1000), flick.phase,
                flick.retries - (flick.retriesLeft or 0), flick.retries,
                flick.hitVerified and "SIM" or "não")
        end
    end
end)

G.LP.CharacterAdded:Connect(function(char)
    task.wait(0.5); G.Cam = workspace.CurrentCamera; Histories = {}
end)

task.delay(2, function() ShowToast("HELLBORN v22.4 MOBILE", "success") end)
print("[HB v22.4] MOBILE — "..G.SID)