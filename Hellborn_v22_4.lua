-- [KILLSWITCH]
if _G.HB and _G.HB.CONNECTIONS then
    for i = 1, #_G.HB.CONNECTIONS do
        pcall(function() _G.HB.CONNECTIONS[i]:Disconnect() end)
    end
end
_G.HB = nil
_G.HB_ALIVE = nil
_G.HB_KILL = nil
for _, g in ipairs(game:GetService("Players").LocalPlayer.PlayerGui:GetChildren()) do
    if g:IsA("ScreenGui") and (g.Name:find("HB_") or g.Name:find("HELLBORN")) then
        pcall(function() g:Destroy() end)
    end
end
for _, o in ipairs(game:GetService("Lighting"):GetChildren()) do
    if o.Name:find("HB_") then pcall(function() o:Destroy() end) end
end
for _, o in ipairs(workspace:GetChildren()) do
    if o.Name:find("HB_") then pcall(function() o:Destroy() end) end
end
pcall(function() game:GetService("UserInputService").MouseIconEnabled = true end)
print("[HB] Killswitch OK")
--==============================================================
-- HELLBORN v10.0 — BLOCO 1/2 CORE
-- ULTRA PRECISION · ONE SHOT · SHARINGAN · SCREEN STRETCH
--==============================================================

if _G.HB_ALIVE then warn("[HELLBORN] Instância já rodando!"); return end
_G.HB_ALIVE = true

local tick = os.clock
local wait, spawn, delay = task.wait, task.spawn, task.delay
local floor, sqrt, exp, log, cos, sin, atan2, tanh, noise =
    math.floor, math.sqrt, math.exp, math.log, math.cos, math.sin, math.atan2, math.tanh, math.noise
local abs, min, max, clamp, random, pi = math.abs, math.min, math.max, math.clamp, math.random, math.pi
local newV3, newV2, newUD2, newCF, lookAt = Vector3.new, Vector2.new, UDim2.new, CFrame.new, CFrame.lookAt
local udim, c3 = UDim.new, Color3.fromRGB
local v3zero = Vector3.zero
local tinsert, tremove, tsort = table.insert, table.remove, table.sort
local sformat, ssub, slower, sfind = string.format, string.sub, string.lower, string.find
local pairs_, ipairs_, next_ = pairs, ipairs, next
local type, typeof, tostring, tonumber, setmetatable = type, typeof, tostring, tonumber, setmetatable
local Instance_new = Instance.new

local E_GOTHAM, E_GOTHAM_MED = Enum.Font.Gotham, Enum.Font.GothamMedium
local E_GOTHAM_BOLD, E_GOTHAM_BLACK = Enum.Font.GothamBold, Enum.Font.GothamBlack
local E_CODE = Enum.Font.Code
local E_TXT_LEFT, E_TXT_RIGHT, E_TXT_CENTER =
    Enum.TextXAlignment.Left, Enum.TextXAlignment.Right, Enum.TextXAlignment.Center
local E_TXT_TOP = Enum.TextYAlignment.Top
local E_MOUSE1, E_MOUSEMOVE = Enum.UserInputType.MouseButton1, Enum.UserInputType.MouseMovement
local E_KEYBOARD = Enum.UserInputType.Keyboard
local E_CAM_SCRIPT, E_CAM_CUSTOM = Enum.CameraType.Scriptable, Enum.CameraType.Custom
local E_AUTO_X, E_AUTO_Y = Enum.AutomaticSize.X, Enum.AutomaticSize.Y
local E_BACK, E_LINEAR = Enum.EasingStyle.Back, Enum.EasingStyle.Linear
local E_RFT_EXCLUDE, E_RFT_INCLUDE = Enum.RaycastFilterType.Exclude, Enum.RaycastFilterType.Include
local E_HL_AOT = Enum.HighlightDepthMode.AlwaysOnTop
local E_MAT_NEON = Enum.Material.Neon
local E_PART_BALL = Enum.PartType.Ball
local E_SCROLL_Y, E_SCROLL_X = Enum.ScrollingDirection.Y, Enum.ScrollingDirection.X
local E_FILL_V, E_FILL_H = Enum.FillDirection.Vertical, Enum.FillDirection.Horizontal
local E_LAYOUT = Enum.SortOrder.LayoutOrder
local E_ALIGN_CTR, E_ALIGN_VC = Enum.HorizontalAlignment.Center, Enum.VerticalAlignment.Center
local E_TRUNC_END = Enum.TextTruncate.AtEnd
local E_HS_GETTING = Enum.HumanoidStateType.GettingUp

local Players = game:GetService("Players")
local UIS = game:GetService("UserInputService")
local RS = game:GetService("RunService")
local TweenService = game:GetService("TweenService")
local Lighting = game:GetService("Lighting")
local SoundService = game:GetService("SoundService")

local LP = Players.LocalPlayer
local PG = LP:WaitForChild("PlayerGui")
local Camera = workspace.CurrentCamera
local Mouse = LP:GetMouse()
local RS_Heartbeat, RS_Render = RS.Heartbeat, RS.RenderStepped
local UIS_InputBegan, UIS_InputEnded, UIS_InputChanged = UIS.InputBegan, UIS.InputEnded, UIS.InputChanged

local HB_CONNS = {}
_G.HB = _G.HB or {}
_G.HB.CONNECTIONS = HB_CONNS
local HB_G = _G.HB
HB_G.DEBUG = HB_G.DEBUG or {murders=0, sheriffs=0, innocents=0, lastQueue=0,
    lastHitReason="none", errors={}, firedCount=0, voidRescues=0,
    roleRefreshes=0, hitAttempts=0, hitSuccess=0, lastHitType="none"}
local HB_DBG = HB_G.DEBUG

local HB_SERIAL = tostring(random(10000000, 99999999))
local HB_X = "HB_" .. random(10000, 99999) .. "_"
local HB_HIST_SZ = 60
local KILLLOG_SZ = 100

for _, g in ipairs_(PG:GetChildren()) do
    if g:IsA("ScreenGui") and (sfind(g.Name, "HB_") or sfind(g.Name, "HELLBORN")) then g:Destroy() end
end
for _, o in ipairs_(Lighting:GetChildren()) do
    if sfind(o.Name, "HB_") or o:IsA("BlurEffect") then o:Destroy() end
end

function HB_Create(cls, props, children)
    local i = Instance_new(cls)
    local par
    if props then
        for k, v in next_, props, nil do
            if k == "Parent" then par = v
            else pcall(function() i[k] = v end) end
        end
    end
    if children then
        if typeof(children) == "Instance" then i.Parent = children
        else for j = 1, #children do children[j].Parent = i end end
    end
    if par then i.Parent = par end
    return i
end
function HB_Corner(p, r) return HB_Create("UICorner", {CornerRadius = udim(0, r or 8), Parent = p}) end
function HB_Stroke(p, c, t, tr) return HB_Create("UIStroke", {Color = c or c3(40,40,48), Thickness = t or 1, Transparency = tr or 0, Parent = p}) end
function HB_EaseS(t) return t * t * (3 - 2 * t) end
function HB_EaseBezier(t, p1, p2) local u = 1 - t; return 3*u*u*t*p1 + 3*u*t*t*p2 + t*t*t end
function HB_PointIn(pos, obj)
    if not obj or not obj.Parent then return false end
    local ap, sz = obj.AbsolutePosition, obj.AbsoluteSize
    return pos.X >= ap.X and pos.X <= ap.X + sz.X and pos.Y >= ap.Y and pos.Y <= ap.Y + sz.Y
end
function HB_ProSnapCurve(t) return t * t * t * (t * (t * 6 - 15) + 10) end
function HB_ProOvershootCurve(t, op)
    if t < 0.5 then return HB_ProSnapCurve(t/0.5) * (1.0 + op)
    else return (1.0 + op) + HB_ProSnapCurve((t-0.5)/0.5) * (-op) end
end
function HB_MicroJitter(bp, tp, int, ph)
    if int <= 0 then return tp end
    if (tp - bp).Magnitude < 0.01 then return tp end
    return tp + newV3(noise(ph,0,0)*2-1, noise(0,ph,0)*2-1, noise(0,0,ph)*2-1) * int
end

Palette = {
    Base=c3(10,10,12), Surface=c3(18,18,22), Elevated=c3(26,26,32),
    Elevated2=c3(34,34,42), Border=c3(40,40,50),
    TextHigh=c3(245,245,250), TextMid=c3(160,160,175), TextLow=c3(100,100,115),
    Accent=c3(220,40,40), Success=c3(0,210,120), Warning=c3(255,180,0), Danger=c3(255,60,60),
}
Themes = {Red=c3(220,40,40), Blue=c3(50,130,255), Green=c3(30,200,90),
    Purple=c3(170,60,230), Cyan=c3(30,210,220), Neon=c3(0,255,180),
    Matrix=c3(0,230,70), Blood=c3(140,0,0)}

S = S or {}
S.AutoFlick=true S.FlickKey=Enum.KeyCode.Q S.SilentOn=true S.AIOn=true
S.PullSlot1=true S.AlignTol=1 S.Retries=0 S.AimSmooth=0
S.TrigOn=false S.TrigRad=60 S.TrigCD=0.35
S.ESP=true S.ESPName=true S.ESP_LOD=true S.Chams=true
S.ESPArrows=false S.ESPSkeleton=false S.Radar=true S.TimelinePredictor=true
S.Hitmark=true S.KillFeed=true S.Cross=false S.CrossStyle="Sharingan" S.CrossSize=24 S.CrossFollowMouse=true
S.ESPThick=2 S.AutoSave=true S.Theme="Red" S.Humanize=true
S.RateLimit=false S.RandomAim=true S.FakeMiss=false S.ChatCommands=true
S.Kills=0 S.Deaths=0 S.Hits=0 S.Misses=0 S.Streak=0 S.BestStreak=0
S.SessionStart=tick()
S.FPSAdaptive=true S.FPSAdaptiveMinFPS=45 S.HitscanOpt=true
S.WeaponCooldownCheck=true S.AntiFlickBlock=false S.AntiFlickBackoff=2
S.PostKillDelay=false S.PostKillDelayMs=400 S.ThreatTrajectory=false
S.SmartTarget=true S.NNRate=0.01 S.PreAim=true S.StickyAim=true
S.StickyAimStrength=1.0 S.ProgressiveFlick=true S.RSIEnabled=true
S.RetryMiss=false
S.WallCheck=false S.FlickMaxDist=5000 S.CycleEnabled=false S.MaxCycles=1
S.CycleReturnMs=50 S.FlickCameraMode="Off"
S.ReShadeOn=true S.ReShadePreset="Tryhard" S.TracerOn=true S.KillFXOn=true
S.AntiVoid=true S.AntiVoidYThresh=-50 S.AntiVoidLift=8
S.MovingTargetPredict=true S.KalmanPredictV2=true S.KalmanPredTime=0.15
S.JukeCounter=true S.VelocityMatch=false S.BackstabSnap=true
S.VerticalPriority=false S.ClosestToCrosshair=false
S.HeadOnlyLock=true S.NeckShot=false
S.Sub1msSnap=true S.DynamicSnapSpeed=true S.AdaptiveSnapDist=true
S.ProgressiveReturn=true S.ZeroReturnTeleport=true S.MultiSnapSteps=true
S.RageBurstMode=true S.SlowMoFlick=false
S.HoldToFlick=false S.TapToFlick=false S.TapMaxTime=0.15
S.ShowCooldownVisual=false
S.Adv_BezierSnap=false S.Adv_BezierP1=0.25 S.Adv_BezierP2=0.75
S.Adv_SplineFlick=false S.Adv_BallisticArc=false
S.Adv_MicroJitterRet=false S.Adv_MicroJitterAmt=0.5
S.Adv_TrailingKill=false S.Adv_FocusZoom=false
S.Adv_PrioritySwitch=true S.Adv_PerfectReturn=true
S.Adv_CancelWindow=false S.Adv_CancelMs=3 S.Adv_AdaptiveCurve=false
S.MM2_KnifeAutoFlick=true S.MM2_GunAutoFlick=true S.MM2_RoundStartFlick=true
S.MM2_AfterKillReset=true S.MM2_SheriffProtect=false S.MM2_DeathFlick=true
S.ESPBox=true S.ESPDist=true S.ESPTracer=true S.ESPHealth=true
S.ESPWeapon=false S.ESPFill=false S.ESPFillTransparency=0.8
S.ESPShowSheriff=true S.ESPShowInnocents=true
S.FB_FlickTrail=true S.FB_TargetMarker=true S.FB_ImpactFlash=true
S.FB_SnapSound=true S.FB_KillConfirmSound=true S.FB_FlickCounter=true
S.GunDropESP=true S.GunDropESPText=true S.GunDropESPTracer=false
S.GunDropESPColor=c3(255,210,40) S.GunDropESPOutline=c3(255,255,255)
S.GunDropESPFill=0.5 S.GunDropESPOutlineT=0.3
S.GunDropESPTextColor=c3(255,210,40) S.GunDropESPDistance=true
S.BombJump=false S.BombJumpKey=Enum.KeyCode.B
S.BombJumpDelay=0.45 S.BombJumpPractice=false S.BombJumpCooldown=0.5
S.WallHop=false S.WallHopKey=Enum.KeyCode.V
S.WallHopPower=55 S.WallHopCooldown=0.35 S.WallHopAutoDetect=true
-- [ULTRA PRECISION]
S.OneShotPerfect = true
S.OneShotLead    = true
S.OneShotGravity = true
S.OneShotAdaptive = true
S.OneShotIterations = 4
S.OneShotConverge = true
-- [SCREEN STRETCH]
S.ScreenStretch = false
S.ScreenStretchPreset = "Normal"
S.ScreenStretchFOV = 70

S.REV_AI = {meta=false,nas=false,cloning=false,selfPlay=false,worldModel=false,
    activeInf=false,transformer=false,moe=false,uncert=false,causal=false,
    counterfact=false,adversarial=false,transfer=false,federated=false,lifelong=false,
    selfPlayEpochs=100,uncertThreshold=0.7}
S.REV_HUMAN = {persona="aggressive",personaStrength=0.0,warmup=false,warmupMin=2,
    cooldown=false,emotion=false,cognitive=false,cogMultiMax=4,fatigue=false,
    fatiguePerHour=0.05,squad=false,squadRadius=30,reputation=false,
    altDetect=false,altThreshold=0.8}
S.REV_PHYS = {ballistic=false,rayTrace=false,ik=false,animMirror=false,
    gameStateRecon=false,serverMirror=false,latency2=false,uploadMs=30,jitterBuf=false}
S.REV_SOCIAL = {antiAttr=false,misdirect=false,misdirectRate=0.15,bait=false,
    antiReport=false,antiReportRate=0.10,skillCurve=false,skillCurveHours=2}
S.REV_ARCH = {rollback=false,snapshotFrames=30,diffSync=false}
S.REV_FEAT = {whatIf=false,forecast=false,director=false,directorClips=10,wager=false,blockchain=false}
S.REV_GAME = {multiRound=false,multiRoundDepth=5,metaGame=false,roleRot=false,legendary=false,legendaryThreshold=20}
S.REV_STEALTH = {advExamples=false,advEpsilon=0.05,jitterDist=false,jitterMean=0.23,
    jitterStd=0.08,antiAntiCheat=false,aacDelay=30,adaptiveRate=false,rateWindow=10,plausible=false}
S.REV_MAD = {neuroSym=false,quantum=false,quantumTemp=100,evolutionary=false,swarm=false,
    genetic=false,antColony=false,digitalTwin=false,sleepWake=false,sleepIdleThreshold=300,
    curriculum=false,currStage=1,dreamState=false,recursive=false,recursiveInterval=1000}

Cache = {Chars={}, Heads={}, HRPs={}, List={}, Set={}}
Hst = {}
Sil = {enabled=true, bspd=2500, lastFire=0, fail=0}
KillLog = {head=0, count=0, slots={}}
for i = 1, KILLLOG_SZ do KillLog.slots[i] = {time=0, victim=nil, dist=0, miss=false, hs=false} end
Acc = {shots={}}
Err = {count=0, last=0}
Weapon = {learnedSpeeds={}, lastFireTime={}}
IdleSince = tick()
AntiFlickGuard = {fails=0, backoffUntil=0}
PostKillTimer = {until_=0}
FPS = {cur=60, lastT=tick()}
LastSafeCF = nil
RevAI = {metaHistory={}, cloneBuffer={}, selfPlayGames={}, worldState={},
    adversarialCycles=0, lifelongMem={}, epochs=0}
RevHuman = {squads={}, reputa={}, emotion=0, cogLoad=0, fatigue=0}
RevPhys = {reconState={}}
RevSocial = {attributionTrail={}, misdirectCount=0}
RevArch = {snapshots={}}
RevFeat = {chain={}}
RevGame = {roundPlan={}, roleHistory={}, legendary={}}
RevStealth = {rateBuf={}, plausible={}, aac=0}
RevMad = {twin={}, recursive={gens=0}}
NNReal = {inputN=8, hiddenN=6, outputN=3, W1={}, b1={}, W2={}, b2={}, lr=0.01, trained=0}
OneShotMem = setmetatable({}, {__mode = "k"})
PingTracker = {samples={}, smoothed=0, lastSample=0, maxSamples=8}

-- ============================================================
-- [SCREEN STRETCH]
-- ============================================================
HB_ScreenPresets = {
    ["Normal"]         = 70,
    ["4:3 Stretch"]    = 52,
    ["5:4 Stretch"]    = 58,
    ["16:10 Stretch"]  = 63,
    ["21:9 Wide"]      = 95,
    ["Rage Zoom"]      = 42,
    ["Ultra Rage"]     = 32,
    ["Custom"]         = nil,
}
function HB_ApplyScreenStretch()
    if not S.ScreenStretch then
        pcall(function() Camera.FieldOfView = 70 end); return
    end
    local preset = S.ScreenStretchPreset or "Normal"
    local fov = HB_ScreenPresets[preset]
    if preset == "Custom" then fov = S.ScreenStretchFOV end
    if fov then pcall(function() Camera.FieldOfView = fov end) end
end
function HB_ResetScreenStretch()
    S.ScreenStretch = false S.ScreenStretchPreset = "Normal" S.ScreenStretchFOV = 70
    pcall(function() Camera.FieldOfView = 70 end)
end
function HB_GetScreenPresetFOV()
    local preset = S.ScreenStretchPreset or "Normal"
    if preset == "Custom" then return S.ScreenStretchFOV or 70 end
    return HB_ScreenPresets[preset] or 70
end
HB_CONNS[#HB_CONNS+1] = RS_Heartbeat:Connect(function()
    if not S.ScreenStretch then return end
    local target = HB_GetScreenPresetFOV()
    if target and abs(Camera.FieldOfView - target) > 1 then
        pcall(function() Camera.FieldOfView = target end)
    end
end)

-- [PRECISION PING SMOOTHER]
function HB_GetSmoothedPing()
    local now = tick()
    if now - PingTracker.lastSample > 0.5 then
        PingTracker.lastSample = now
        local p = LP:GetNetworkPing()
        local s = PingTracker.samples
        s[#s+1] = p
        if #s > PingTracker.maxSamples then tremove(s, 1) end
        if #s == 0 then PingTracker.smoothed = p; return p end
        local sum = 0
        for i = 1, #s do sum = sum + s[i] end
        local raw = sum / #s
        PingTracker.smoothed = PingTracker.smoothed == 0 and raw or (PingTracker.smoothed * 0.7 + raw * 0.3)
    end
    return PingTracker.smoothed > 0 and PingTracker.smoothed or LP:GetNetworkPing()
end

function HB_GetH(p)
    local h = Hst[p]
    if not h then
        h = {spX={},spY={},spZ={},spT={},spHead=0,spCount=0,
            kalman={x={0,0,0,0,0,0},lastT=0,gain=0.45},
            vel=v3zero,prevVel=nil,acc=v3zero,jit=0,stab=1,lastPos=nil,lastT=0,
            dCh=0,lastDir=nil,chase=false,chaseFr=0,tpIgn=0,weapon="unknown",
            isJumping=false,isCrouch=false,strafeAmount=0,dirChanges=0,lastDirChangeT=0}
        for i = 1, HB_HIST_SZ do h.spX[i]=0 h.spY[i]=0 h.spZ[i]=0 h.spT[i]=0 end
        Hst[p] = h
    end
    return h
end
function HB_KalmanPred(k, dt) local x = k.x; return newV3(x[1]+x[4]*dt, x[2]+x[5]*dt, x[3]+x[6]*dt) end

function HB_NNInit()
    NNReal.W1={} NNReal.b1={} NNReal.W2={} NNReal.b2={}
    for i = 1, NNReal.hiddenN do
        local row = {}
        for j = 1, NNReal.inputN do row[j] = (random()-0.5)*0.5 end
        NNReal.W1[i]=row; NNReal.b1[i]=0
    end
    for i = 1, NNReal.outputN do
        local row = {}
        for j = 1, NNReal.hiddenN do row[j] = (random()-0.5)*0.5 end
        NNReal.W2[i]=row; NNReal.b2[i]=0
    end
end
HB_NNInit()
function HB_NNForward(input)
    local hidden = {}
    for i = 1, NNReal.hiddenN do
        local s = NNReal.b1[i]; local row = NNReal.W1[i]
        for j = 1, NNReal.inputN do s = s + input[j] * row[j] end
        hidden[i] = tanh(s)
    end
    local out = {}
    for i = 1, NNReal.outputN do
        local s = NNReal.b2[i]; local row = NNReal.W2[i]
        for j = 1, NNReal.hiddenN do s = s + hidden[j] * row[j] end
        out[i] = s
    end
    return out, hidden
end
function HB_NNTrain(input, target)
    local out, hidden = HB_NNForward(input)
    local err = {}
    for i = 1, NNReal.outputN do err[i] = target[i] - out[i] end
    local lr = S.NNRate
    for i = 1, NNReal.outputN do
        local row = NNReal.W2[i]; local e = err[i]
        for j = 1, NNReal.hiddenN do row[j] = row[j] + lr * e * hidden[j] end
        NNReal.b2[i] = NNReal.b2[i] + lr * e
    end
    for j = 1, NNReal.hiddenN do
        local dh = 0
        for i = 1, NNReal.outputN do dh = dh + err[i] * NNReal.W2[i][j] end
        dh = dh * (1 - hidden[j] * hidden[j])
        for k = 1, NNReal.inputN do NNReal.W1[j][k] = NNReal.W1[j][k] + lr * dh * input[k] end
        NNReal.b1[j] = NNReal.b1[j] + lr * dh
    end
    NNReal.trained = NNReal.trained + 1
end

function HB_Toast(msg, kind)
    kind = kind or "info"
    if not UI or not UI.Screen or not UI.Screen.Parent then print("[HB]", msg); return end
    if not UI.ToastHolder then
        UI.ToastHolder = HB_Create("Frame", {Size=newUD2(0,300,0,500), Position=newUD2(1,-320,0,20), BackgroundTransparency=1, Parent=UI.Screen})
    end
    local color = Palette.Accent
    if kind=="success" then color=Palette.Success
    elseif kind=="warning" then color=Palette.Warning
    elseif kind=="danger" then color=Palette.Danger end
    local t = HB_Create("Frame", {Size=newUD2(1,0,0,42), Position=newUD2(1,320,0,0), BackgroundColor3=Palette.Surface, BackgroundTransparency=0.05, BorderSizePixel=0, Parent=UI.ToastHolder})
    HB_Corner(t, 8); HB_Stroke(t, color, 1.5, 0.3)
    HB_Create("Frame", {Size=newUD2(0,3,1,-12), Position=newUD2(0,6,0,6), BackgroundColor3=color, BorderSizePixel=0, Parent=t})
    HB_Create("TextLabel", {Size=newUD2(1,-20,1,0), Position=newUD2(0,14,0,0), BackgroundTransparency=1, Text=msg, Font=E_GOTHAM, TextSize=12, TextColor3=Palette.TextHigh, TextXAlignment=E_TXT_LEFT, TextWrapped=true, Parent=t})
    local ex = {}
    for _, c in ipairs_(UI.ToastHolder:GetChildren()) do if c:IsA("Frame") and c ~= t then ex[#ex+1] = c end end
    for i = 1, #ex do TweenService:Create(ex[i], TweenInfo.new(0.2), {Position = newUD2(0,0,0,(i-1)*48)}):Play() end
    TweenService:Create(t, TweenInfo.new(0.3), {Position = newUD2(0,0,0,#ex*48)}):Play()
    delay(3, function() if t and t.Parent then t:Destroy() end end)
end
HBToast = HB_Toast

function HB_RebuildList()
    local t = {}
    for p in next_, Cache.Set, nil do t[#t+1] = p end
    Cache.List = t
end
function HB_HookChar(p)
    local function onChar(c)
        Cache.Chars[p] = c
        wait(0.25)
        Cache.Heads[p] = c:FindFirstChild("Head")
        Cache.HRPs[p] = c:FindFirstChild("HumanoidRootPart")
    end
    p.CharacterAdded:Connect(onChar)
    if p.Character then onChar(p.Character) end
end
function HB_AddPlayer(p) Cache.Set[p] = true; HB_HookChar(p); HB_RebuildList() end
function HB_RemovePlayer(p)
    Cache.Set[p]=nil Cache.Chars[p]=nil Cache.Heads[p]=nil Cache.HRPs[p]=nil
    Hst[p]=nil OneShotMem[p]=nil HB_RebuildList()
end
for _, p in ipairs_(Players:GetPlayers()) do HB_AddPlayer(p) end
Players.PlayerAdded:Connect(HB_AddPlayer)
Players.PlayerRemoving:Connect(HB_RemovePlayer)

local MURD_LOWER = {"knife","cleaver","blade","sword","dagger","machete"}
local GUN_LOWER = {"gun","revolver","pistol","sheriff","firearm","taser"}

function FindSlot1Tool()
    if not LP.Character then return nil end
    local bp = LP:FindFirstChild("Backpack") or LP:FindFirstChildOfClass("Backpack")
    local cands = {}
    if bp then
        for _, t in ipairs_(bp:GetChildren()) do
            if t:IsA("Tool") then cands[#cands+1] = t end
        end
    end
    if #cands > 1 then tsort(cands, function(a, b) return a.Name < b.Name end) end
    if cands[1] then return cands[1] end
    return LP.Character:FindFirstChildOfClass("Tool")
end
function FindWeapon()
    if not LP.Character then return nil end
    if S.PullSlot1 then local s1 = FindSlot1Tool(); if s1 then return s1 end end
    return LP.Character:FindFirstChildOfClass("Tool")
end
function HB_EquipAndWait(tool, timeout)
    if not tool or not LP.Character then return nil end
    local myChar = LP.Character
    local hum = myChar:FindFirstChildOfClass("Humanoid")
    if not hum then return nil end
    if tool.Parent == myChar then return tool end
    pcall(function() hum:EquipTool(tool) end)
    timeout = timeout or 0.5
    local t0 = tick()
    repeat
        local eq = myChar:FindFirstChildOfClass("Tool")
        if eq == tool then return tool end
        wait()
    until tick() - t0 > timeout
    return myChar:FindFirstChildOfClass("Tool")
end
function PullSlot1()
    if not S.PullSlot1 then return nil end
    local myChar = LP.Character; if not myChar then return nil end
    local s1 = FindSlot1Tool(); if not s1 then return nil end
    local eq = myChar:FindFirstChildOfClass("Tool")
    if eq == s1 then return eq end
    local hum = myChar:FindFirstChildOfClass("Humanoid")
    if not hum then return s1 end
    pcall(function() hum:EquipTool(s1) end)
    return s1
end

local RoleCache = setmetatable({}, {__mode="k"})
local RoleCacheTime = 0
local ROLE_TTL = 0.25
local ROLE_ATTRS = {"Role","role","Team","team","Class","class","RoleName","PlayerRole","TeamName","CharacterType"}

local function IdentifyToolRole(tool)
    if not tool or not tool:IsA("Tool") then return nil end
    local n = slower(tool.Name)
    for i = 1, #MURD_LOWER do if sfind(n, MURD_LOWER[i], 1, true) then return "Murderer" end end
    for i = 1, #GUN_LOWER do if sfind(n, GUN_LOWER[i], 1, true) then return "Sheriff" end end
    return nil
end

function GetRole(p)
    if not p then return "Innocent" end
    local now = tick()
    if now - RoleCacheTime > ROLE_TTL then
        RoleCache = setmetatable({}, {__mode="k"}); RoleCacheTime = now
    end
    local cached = RoleCache[p]; if cached then return cached end
    local role = nil
    local ch = Cache.Chars[p] or p.Character
    if ch and ch.Parent then
        local eqTool = ch:FindFirstChildOfClass("Tool")
        if eqTool then role = IdentifyToolRole(eqTool) end
        if not role then
            local bag = p:FindFirstChild("Backpack") or p:FindFirstChildOfClass("Backpack")
            if bag then
                for _, t in ipairs_(bag:GetChildren()) do
                    if t:IsA("Tool") then
                        local r = IdentifyToolRole(t)
                        if r == "Sheriff" then role = "Sheriff"; break end
                        if r == "Murderer" and not role then role = "Murderer" end
                    end
                end
            end
        end
        if not role and ch then
            if ch:FindFirstChild("Gun") or ch:FindFirstChild("Revolver") then role = "Sheriff" end
        end
        if not role then
            for i = 1, #ROLE_ATTRS do
                local ok, val = pcall(p.GetAttribute, p, ROLE_ATTRS[i])
                if ok and val then
                    local v = slower(tostring(val))
                    if sfind(v,"murder",1,true) or sfind(v,"killer",1,true) or sfind(v,"assassin",1,true) then role = "Murderer"; break
                    elseif sfind(v,"sheriff",1,true) or sfind(v,"cop",1,true) or sfind(v,"deputy",1,true) or sfind(v,"hero",1,true) then role = "Sheriff"; break
                    elseif sfind(v,"inno",1,true) or sfind(v,"civil",1,true) then role = "Innocent"; break end
                end
            end
        end
    end
    role = role or "Innocent"
    RoleCache[p] = role
    return role
end

function HB_UpdateH(p, pos, hum)
    local h = HB_GetH(p)
    local now = tick()
    local lastPos = h.lastPos
    if lastPos and (now - h.lastT) < 0.1 then
        local dx, dy, dz = pos.X-lastPos.X, pos.Y-lastPos.Y, pos.Z-lastPos.Z
        if (dx*dx + dy*dy + dz*dz) > 2500 then h.tpIgn = now; return end
    end
    if now - h.tpIgn < 0.5 then return end
    local k = h.kalman
    if k.lastT == 0 then k.lastT = now end
    local dt = now - k.lastT; if dt < 1/120 then dt = 1/120 end
    k.lastT = now
    local x = k.x; local gain = k.gain
    local pr, e
    pr = x[1]+x[4]*dt; e = pos.X-pr; x[1]=pr+gain*e; x[4]=x[4]+(e/dt)*0.5
    pr = x[2]+x[5]*dt; e = pos.Y-pr; x[2]=pr+gain*e; x[5]=x[5]+(e/dt)*0.5
    pr = x[3]+x[6]*dt; e = pos.Z-pr; x[3]=pr+gain*e; x[6]=x[6]+(e/dt)*0.5
    local idx = h.spHead + 1
    if idx > HB_HIST_SZ then idx = 1 end
    h.spHead = idx
    h.spX[idx]=pos.X; h.spY[idx]=pos.Y; h.spZ[idx]=pos.Z; h.spT[idx]=now
    if h.spCount < HB_HIST_SZ then h.spCount = h.spCount + 1 end
    if lastPos and h.lastT > 0 then
        local dt2 = now - h.lastT
        if dt2 > 0.001 then
            local invdt2 = 1 / dt2
            h.vel = h.vel:Lerp(newV3((pos.X-lastPos.X)*invdt2, (pos.Y-lastPos.Y)*invdt2, (pos.Z-lastPos.Z)*invdt2), 0.5)
            if h.prevVel then h.acc = h.acc:Lerp((h.vel - h.prevVel) * invdt2, 0.3) end
            h.prevVel = h.vel
            local vMag = h.vel.Magnitude
            if vMag > 1 then
                local inv = 1/vMag
                local dx, dy, dz = h.vel.X*inv, h.vel.Y*inv, h.vel.Z*inv
                if h.lastDir and (dx*h.lastDir.X+dy*h.lastDir.Y+dz*h.lastDir.Z) < 0.3 then
                    h.dCh = h.dCh + 1; h.dirChanges = h.dirChanges + 1; h.lastDirChangeT = now
                end
                h.lastDir = newV3(dx, dy, dz)
            end
            if h.vel.Y > 15 then h.isJumping = true elseif h.vel.Y < -5 then h.isJumping = false end
            local lateral = abs(h.vel.X) + abs(h.vel.Z)
            local forward = abs(h.vel.Y)
            h.strafeAmount = lateral / (lateral + forward + 0.001)
        end
    end
    if hum and Cache.Heads[p] then h.isCrouch = (Cache.Heads[p].Position.Y - pos.Y) < 2.2 end
    h.lastPos = pos; h.lastT = now
    if h.spCount >= 5 then
        local sd = 0; local head = h.spHead
        for i = 1, 4 do
            local cur = head-i+1; if cur < 1 then cur = cur + HB_HIST_SZ end
            local prev = cur-1; if prev < 1 then prev = prev + HB_HIST_SZ end
            local ddx = h.spX[cur]-h.spX[prev]
            local ddy = h.spY[cur]-h.spY[prev]
            local ddz = h.spZ[cur]-h.spZ[prev]
            sd = sd + sqrt(ddx*ddx + ddy*ddy + ddz*ddz)
        end
        h.jit = sd / 4
        h.stab = clamp(1 - h.jit * 2, 0, 1)
    end
end

local _fpsFrameCount = 0
local TrackAccum = 0
HB_CONNS[#HB_CONNS+1] = RS_Render:Connect(function()
    _fpsFrameCount = _fpsFrameCount + 1
    local now = tick()
    if now - FPS.lastT >= 0.5 then
        FPS.cur = _fpsFrameCount / (now - FPS.lastT)
        _fpsFrameCount = 0; FPS.lastT = now
    end
end)
HB_CONNS[#HB_CONNS+1] = RS_Heartbeat:Connect(function(dt)
    TrackAccum = TrackAccum + dt
    if TrackAccum < 0.02 then return end
    TrackAccum = 0
    local lpHrp = Cache.HRPs[LP]; if not lpHrp then return end
    local lpP = lpHrp.Position
    local lx, ly, lz = lpP.X, lpP.Y, lpP.Z
    local list = Cache.List
    for i = 1, #list do
        local p = list[i]
        if p ~= LP then
            local hrp = Cache.HRPs[p]
            if hrp then
                local pos = hrp.Position
                local dx, dy, dz = pos.X-lx, pos.Y-ly, pos.Z-lz
                if (dx*dx + dy*dy + dz*dz) < 250000 then
                    local ch = Cache.Chars[p]
                    HB_UpdateH(p, pos, ch and ch:FindFirstChildOfClass("Humanoid"))
                end
            end
        end
    end
end)

function GetWeaponSpeed(tool)
    if not tool then return Sil.bspd end
    local n = slower(tool.Name)
    if sfind(n,"knife") or sfind(n,"cleaver") then return 1200 end
    if sfind(n,"revolver") or sfind(n,"pistol") then return 2800 end
    if sfind(n,"gun") then return 3000 end
    return Sil.bspd
end
function IsHitscan(tool)
    if not tool then return false end
    local n = slower(tool.Name)
    return sfind(n,"knife") ~= nil or sfind(n,"cleaver") ~= nil or sfind(n,"sword") ~= nil or sfind(n,"blade") ~= nil
end
function IsWeaponOnCooldown(tool)
    if not S.WeaponCooldownCheck or not tool then return false end
    local last = Weapon.lastFireTime[tool]
    return last ~= nil and (tick() - last) < 0.3
end
function HB_HasLineOfSight(targetChar, extraIgnore)
    if not targetChar or not targetChar.Parent then return false end
    local lpChar = LP.Character; if not lpChar then return false end
    local head = lpChar:FindFirstChild("Head")
    local tHead = targetChar:FindFirstChild("Head")
    local tHRP = targetChar:FindFirstChild("HumanoidRootPart")
    if not head or (not tHead and not tHRP) then return false end
    local targetPos = (tHead or tHRP).Position
    local ignore = {lpChar, targetChar}
    if extraIgnore then
        if typeof(extraIgnore) == "Instance" then ignore[#ignore+1] = extraIgnore
        elseif typeof(extraIgnore) == "table" then for i = 1, #extraIgnore do ignore[#ignore+1] = extraIgnore[i] end end
    end
    local params = RaycastParams.new()
    params.FilterType = E_RFT_EXCLUDE
    params.FilterDescendantsInstances = ignore
    params.IgnoreWater = true; params.RespectCanCollide = false
    return workspace:Raycast(head.Position, targetPos - head.Position, params) == nil
end

HB_Tracer = {enabled=true, ignoreHitscan=true, lifetime=0.40, thickness=0.25,
    colorMain=c3(255,240,80), colorTip=c3(255,80,30),
    glowColor=c3(255,180,60), glowBright=6, glowRange=20, sparkCount=16, maxConcurrent=40}
HB_TracerActive = 0
function HB_SpawnTracer(fromPos, toPos, overrideColor)
    if not HB_Tracer.enabled or not fromPos or not toPos then return end
    if typeof(fromPos) ~= "Vector3" or typeof(toPos) ~= "Vector3" then return end
    if HB_TracerActive >= HB_Tracer.maxConcurrent then return end
    local dist = (toPos - fromPos).Magnitude
    if dist < 1.5 then return end
    HB_TracerActive = HB_TracerActive + 1
    local beam = Instance_new("Part")
    beam.Name = "HB_Tracer"; beam.Anchored = true; beam.CanCollide = false
    beam.CanQuery = false; beam.CanTouch = false; beam.CastShadow = false
    beam.Material = E_MAT_NEON
    beam.Color = overrideColor or HB_Tracer.colorMain
    beam.Size = newV3(HB_Tracer.thickness, HB_Tracer.thickness, dist)
    beam.CFrame = lookAt((fromPos + toPos) * 0.5, toPos)
    beam.Parent = workspace
    local tip = Instance_new("Part")
    tip.Name = "HB_TracerTip"; tip.Anchored = true; tip.CanCollide = false
    tip.CanQuery = false; tip.CanTouch = false; tip.CastShadow = false
    tip.Shape = E_PART_BALL; tip.Material = E_MAT_NEON
    tip.Color = HB_Tracer.colorTip; tip.Size = newV3(0.7, 0.7, 0.7)
    tip.CFrame = newCF(toPos); tip.Parent = workspace
    local light = Instance_new("PointLight")
    light.Color = HB_Tracer.glowColor; light.Brightness = HB_Tracer.glowBright
    light.Range = HB_Tracer.glowRange; light.Parent = tip
    local att = Instance_new("Attachment", tip)
    local spark = Instance_new("ParticleEmitter")
    spark.Texture = "rbxasset://textures/particles/sparkles_main.dds"
    spark.Rate = 0; spark.Lifetime = NumberRange.new(0.15, 0.30)
    spark.Speed = NumberRange.new(20, 40)
    spark.SpreadAngle = newV2(180, 180)
    spark.Size = NumberSequence.new({NumberSequenceKeypoint.new(0, 0.4), NumberSequenceKeypoint.new(1, 0.02)})
    spark.Transparency = NumberSequence.new({NumberSequenceKeypoint.new(0, 0), NumberSequenceKeypoint.new(1, 1)})
    spark.LightEmission = 1; spark.LightInfluence = 0
    spark.Color = ColorSequence.new(HB_Tracer.colorTip, HB_Tracer.colorMain)
    spark.Acceleration = newV3(0, -30, 0); spark.Drag = 4; spark.Parent = att
    pcall(function() spark:Emit(HB_Tracer.sparkCount) end)
    local info = TweenInfo.new(HB_Tracer.lifetime, E_LINEAR)
    pcall(function()
        TweenService:Create(beam, info, {Transparency = 1}):Play()
        TweenService:Create(tip, info, {Transparency = 1}):Play()
        TweenService:Create(light, TweenInfo.new(HB_Tracer.lifetime), {Brightness = 0}):Play()
    end)
    delay(HB_Tracer.lifetime + 0.05, function()
        if beam and beam.Parent then beam:Destroy() end
        if tip and tip.Parent then tip:Destroy() end
        if light and light.Parent then light:Destroy() end
        if att and att.Parent then att:Destroy() end
        HB_TracerActive = max(0, HB_TracerActive - 1)
    end)
end

HB_KillEffects = {enabled=true, burstCount=70,
    colors = {c3(255,60,60), c3(255,200,60), c3(60,255,120), c3(60,150,255), c3(200,80,255), c3(255,255,255)},
    heightOffset=2.5, explosionY=25, lifetime=2.8}
function HB_SpawnKillEffect(victimChar)
    if not HB_KillEffects.enabled or not victimChar or not victimChar.Parent then return end
    local anchor = victimChar:FindFirstChild("HumanoidRootPart") or victimChar:FindFirstChild("UpperTorso")
                or victimChar:FindFirstChild("Torso") or victimChar:FindFirstChild("Head")
    if not anchor then return end
    local origin = Instance_new("Part")
    origin.Name = "HB_KillFX"; origin.Anchored = true
    origin.CanCollide = false; origin.CanQuery = false; origin.CanTouch = false
    origin.CastShadow = false; origin.Transparency = 1
    origin.Size = newV3(1, 1, 1)
    origin.CFrame = newCF(anchor.Position + newV3(0, HB_KillEffects.heightOffset, 0))
    origin.Parent = workspace
    local perColor = floor(HB_KillEffects.burstCount / #HB_KillEffects.colors)
    for _, color in ipairs_(HB_KillEffects.colors) do
        local pe = Instance_new("ParticleEmitter")
        pe.Name = "HB_Confetti"
        pe.Texture = "rbxasset://textures/particles/sparkles_main.dds"
        pe.Rate = 0; pe.Lifetime = NumberRange.new(1.0, 1.9)
        pe.Speed = NumberRange.new(18, 38); pe.SpreadAngle = newV2(180, 180)
        pe.Rotation = NumberRange.new(0, 360); pe.RotSpeed = NumberRange.new(-220, 220)
        pe.Size = NumberSequence.new({NumberSequenceKeypoint.new(0, 0.40), NumberSequenceKeypoint.new(0.5, 0.35), NumberSequenceKeypoint.new(1, 0.05)})
        pe.Transparency = NumberSequence.new({NumberSequenceKeypoint.new(0, 0), NumberSequenceKeypoint.new(0.75, 0.10), NumberSequenceKeypoint.new(1, 1)})
        pe.LightEmission = 1; pe.LightInfluence = 0
        pe.Color = ColorSequence.new(color)
        pe.Acceleration = newV3(0, -HB_KillEffects.explosionY, 0)
        pe.Drag = 3; pe.Parent = origin
        pcall(function() pe:Emit(perColor) end)
    end
    local light = Instance_new("PointLight")
    light.Color = c3(255, 220, 140); light.Range = 24
    light.Brightness = 6; light.Parent = origin
    spawn(function()
        wait(0.1)
        pcall(function() TweenService:Create(light, TweenInfo.new(0.9), {Brightness = 0}):Play() end)
        wait(HB_KillEffects.lifetime)
        if origin and origin.Parent then origin:Destroy() end
    end)
end

function SilentFire(tool, aimPos, bypassCooldown)
    if not tool or not aimPos or not tool.Parent then return false end
    local lpCh = LP.Character; if not lpCh then return false end
    if tool.Parent ~= lpCh then
        local eq = HB_EquipAndWait(tool, 0.5)
        if not eq or eq ~= tool then
            local s1 = FindSlot1Tool()
            if s1 then eq = HB_EquipAndWait(s1, 0.5) end
            if not eq then return false end
            tool = eq
        end
    end
    if S.RateLimit then
        local rb = RevStealth.rateBuf; local now = tick()
        for i = #rb, 1, -1 do if now - rb[i] > 1 then tremove(rb, i) end end
        if #rb >= 15 then return false end
        rb[#rb+1] = now
    end
    local now = tick()
    if S.AntiFlickBlock and now < AntiFlickGuard.backoffUntil then return false end
    if not bypassCooldown and now - Sil.lastFire < 0.03 then return false end
    Sil.lastFire = now
    if S.FakeMiss and random() < 0.01 then
        aimPos = aimPos + newV3((random()-0.5)*4, (random()-0.5)*4, (random()-0.5)*4)
    end
    local hum = lpCh:FindFirstChildOfClass("Humanoid")
    if not hum or hum.Health <= 0 then return false end
    local head = lpCh:FindFirstChild("Head")
    local handle = tool:FindFirstChild("Handle")
    local fireFromPos = (handle and handle.Position) or (head and head.Position) or Camera.CFrame.Position
    local oldAuto = hum.AutoRotate
    local oldHeadCF = head and head.CFrame
    local oldHandleCF = handle and handle.CFrame
    hum.AutoRotate = false
    if handle then pcall(function() handle.CFrame = lookAt(handle.CFrame.Position, aimPos) end) end
    if head then pcall(function() head.CFrame = lookAt(head.CFrame.Position, aimPos) end) end
    local fakePart
    if Mouse then
        pcall(function()
            fakePart = Instance_new("Part")
            fakePart.Size = newV3(0.1, 0.1, 0.1); fakePart.Transparency = 1
            fakePart.CanCollide = false; fakePart.Anchored = true
            fakePart.CFrame = newCF(aimPos); fakePart.Parent = workspace
            Mouse.Target = fakePart
        end)
    end
    local ok = pcall(function() tool:Activate() end)
    if handle and oldHandleCF then handle.CFrame = oldHandleCF end
    if head and oldHeadCF then pcall(function() head.CFrame = oldHeadCF end) end
    hum.AutoRotate = oldAuto
    if fireFromPos and HB_Tracer.enabled then
        if (not IsHitscan(tool)) or HB_Tracer.ignoreHitscan then
            spawn(HB_SpawnTracer, fireFromPos, aimPos)
        end
    end
    if fakePart then delay(0.05, function() if fakePart then fakePart:Destroy() end end) end
    if ok then
        Weapon.lastFireTime[tool] = now
        AntiFlickGuard.fails = 0
    else
        AntiFlickGuard.fails = AntiFlickGuard.fails + 1
        if S.AntiFlickBlock and AntiFlickGuard.fails >= 3 then
            AntiFlickGuard.backoffUntil = now + S.AntiFlickBackoff
            AntiFlickGuard.fails = 0
        end
    end
    return ok
end

-- ============================================================
-- [ULTRA PRECISION AIM ENGINE — 4 PASS ITERATIVE]
-- ============================================================
function HB_CalcLeadPosIterative(tp, ch, camPos, tool)
    if not ch or not ch.Parent then return nil end
    local head = ch:FindFirstChild("Head")
    local hrp  = ch:FindFirstChild("HumanoidRootPart")
    if not head then return nil end
    local h = Hst[tp]
    local vel = (h and h.vel) or (hrp and hrp.AssemblyLinearVelocity) or v3zero
    local acc = (h and h.acc) or v3zero
    local spd = GetWeaponSpeed(tool) or 2500
    local ping = HB_GetSmoothedPing()
    local basePos = head.Position
    local finalPos = basePos
    for iter = 1, 3 do
        local dist = (finalPos - camPos).Magnitude
        local t = (dist / spd) + (ping * 0.5) + 0.0333
        local targetPoint = basePos + vel * t
        if S.OneShotLead and acc.Magnitude > 0.1 then
            targetPoint = targetPoint + acc * (0.5 * t * t)
        end
        if S.OneShotGravity and not IsHitscan(tool) then
            targetPoint = newV3(targetPoint.X, targetPoint.Y + 0.5 * 196.2 * t * t, targetPoint.Z)
        end
        if S.OneShotAdaptive then
            local mem = OneShotMem[tp]
            if mem and mem.offset then
                local age = tick() - mem.t
                local decay = max(0, 1 - age / 20)
                targetPoint = targetPoint + mem.offset * decay
            end
        end
        finalPos = targetPoint
    end
    local finalDist = (finalPos - camPos).Magnitude
    local finalT = (finalDist / spd) + (ping * 0.5) + 0.0333
    return finalPos, finalT, finalDist
end

function HB_VerifyLOS(ch, camPos, aim)
    if not ch or not ch.Parent then return aim, false, nil end
    local params = RaycastParams.new()
    params.FilterType = E_RFT_INCLUDE
    params.FilterDescendantsInstances = {ch}
    params.IgnoreWater = true
    params.RespectCanCollide = false
    local result = workspace:Raycast(camPos, aim - camPos, params)
    if result and result.Instance then
        return result.Position, true, result.Instance
    end
    return aim, false, nil
end

function HB_MultiPointAim(ch, camPos, basePoint)
    if not ch or not ch.Parent then return basePoint, false, nil end
    local offsets = {
        Vector3.new(0, 0, 0),
        Vector3.new(0.15, 0, 0),   Vector3.new(-0.15, 0, 0),
        Vector3.new(0, 0.15, 0),   Vector3.new(0, -0.15, 0),
        Vector3.new(0, 0, 0.15),   Vector3.new(0, 0, -0.15),
        Vector3.new(0.35, 0, 0),   Vector3.new(-0.35, 0, 0),
        Vector3.new(0, 0.35, 0),   Vector3.new(0, -0.35, 0),
        Vector3.new(0, 0, 0.35),   Vector3.new(0, 0, -0.35),
        Vector3.new(0.2, 0.2, 0),  Vector3.new(-0.2, 0.2, 0),
        Vector3.new(0.2, -0.2, 0), Vector3.new(-0.2, -0.2, 0),
        Vector3.new(0.55, 0, 0),   Vector3.new(-0.55, 0, 0),
        Vector3.new(0, 0.55, 0),
    }
    for i = 1, #offsets do
        local testPoint = basePoint + offsets[i]
        local hitPos, hasLOS, hitPart = HB_VerifyLOS(ch, camPos, testPoint)
        if hasLOS then return hitPos, true, hitPart end
    end
    return basePoint, false, nil
end

function HB_PerfectAim(tp, ch, camPos, tool, hum)
    if not ch or not ch.Parent or not hum or hum.Health <= 0 then return nil end
    local head = ch:FindFirstChild("Head")
    local hrp  = ch:FindFirstChild("HumanoidRootPart")
    if not head then return nil end
    local leadAim, t, dist = HB_CalcLeadPosIterative(tp, ch, camPos, tool)
    if not leadAim then return nil end
    local hitPos, hasLOS, hitPart = HB_VerifyLOS(ch, camPos, leadAim)
    if hasLOS and hitPart and hitPart.Name == "Head" then
        return hitPos, t, dist, "head"
    end
    if S.HeadOnlyLock then
        local headAim = head.Position + (leadAim - head.Position) * 0.5
        return headAim, t, dist, "head_blind"
    end
    if hrp then
        local v = (Hst[tp] and Hst[tp].vel) or hrp.AssemblyLinearVelocity or v3zero
        local hrpLead = hrp.Position + v * (t or 0.05)
        local hrpHit, hrpLOS = HB_VerifyLOS(ch, camPos, hrpLead)
        if hrpLOS then return hrpHit, t, dist, "hrp" end
    end
    local mpAim, mpLOS = HB_MultiPointAim(ch, camPos, leadAim)
    if mpLOS then return mpAim, t, dist, "multipoint" end
    if hasLOS and hitPart then return hitPos, t, dist, hitPart.Name end
    return leadAim, t, dist, "blind"
end

function HB_PerfectShot(tp, ch, hum, camPos, tool)
    if not tool or not ch or not hum then return false end
    if hum.Health <= 0 or not hum.Parent then return true end
    local head = ch:FindFirstChild("Head")
    if not head then return false end
    local maxTries = S.OneShotPerfect and 4 or 1
    local lastAim, lastHitType, lastMissOffset
    for try = 1, maxTries do
        local aim, t, dist, hitType = HB_PerfectAim(tp, ch, camPos, tool, hum)
        if not aim then
            aim = head.Position
            t = 0
            hitType = "fallback"
        end
        local jitter = 0
        if try == 2 then jitter = 0.08
        elseif try == 3 then jitter = 0.20
        elseif try >= 4 then jitter = 0.35 end
        if jitter > 0 then
            aim = aim + newV3((random()-0.5)*jitter, (random()-0.5)*jitter, (random()-0.5)*jitter)
            local losPos, los = HB_VerifyLOS(ch, camPos, aim)
            if los then aim = losPos end
        end
        lastAim = aim; lastHitType = hitType
        local hpBefore = hum.Health
        HB_DBG.hitAttempts = (HB_DBG.hitAttempts or 0) + 1
        HB_DBG.lastHitType = hitType or "none"
        pcall(function() SilentFire(tool, aim, true) end)
        RS_Heartbeat:Wait()
        if not hum.Parent then
            HB_DBG.hitSuccess = (HB_DBG.hitSuccess or 0) + 1
            OneShotMem[tp] = nil; return true
        end
        if hum.Health < hpBefore then
            HB_DBG.hitSuccess = (HB_DBG.hitSuccess or 0) + 1
            OneShotMem[tp] = nil; return true
        end
        RS_Heartbeat:Wait()
        if not hum.Parent then
            HB_DBG.hitSuccess = (HB_DBG.hitSuccess or 0) + 1
            OneShotMem[tp] = nil; return true
        end
        if hum.Health < hpBefore then
            HB_DBG.hitSuccess = (HB_DBG.hitSuccess or 0) + 1
            OneShotMem[tp] = nil; return true
        end
        lastMissOffset = head.Position - aim
    end
    if S.OneShotAdaptive and lastMissOffset then
        local prev = OneShotMem[tp]
        if prev and prev.offset then
            local age = tick() - prev.t
            local decayFactor = max(0.4, 1 - age / 15)
            OneShotMem[tp] = {offset = prev.offset * decayFactor * 0.5 + lastMissOffset * 0.5, t = tick()}
        else
            OneShotMem[tp] = {offset = lastMissOffset * 0.6, t = tick()}
        end
    end
    return false
end

-- ============================================================
-- IA HELPERS (restaurados completos)
-- ============================================================
function MetaLearnUpdate(perf)
    if not S.REV_AI.meta then return end
    local snap = (Flick and Flick.snapDur) or 0.045
    local hist = RevAI.metaHistory
    hist[#hist+1] = {perf=perf, snap=snap, t=tick()}
    if #hist > 100 then tremove(hist, 1) end
    if #hist >= 20 and Flick then
        local sorted = {}; for i = 1, #hist do sorted[i] = hist[i] end
        tsort(sorted, function(a,b) return a.perf > b.perf end)
        local s = 0; local n = min(5, #sorted)
        for i = 1, n do s = s + sorted[i].snap end
        Flick.snapDur = Flick.snapDur * 0.7 + (s/n) * 0.3
        RevAI.epochs = RevAI.epochs + 1
    end
end
function WorldModelPredict(p, dt)
    if not S.REV_AI.worldModel then return nil end
    local h = Hst[p]; if not h or h.spCount < 5 then return nil end
    local state = RevAI.worldState[p] or {pos=h.lastPos, vel=h.vel}
    if not state.pos then return nil end
    return state.pos + state.vel * dt
end
function ActiveInference(p)
    if not S.REV_AI.activeInf or not p then return nil end
    local h = Hst[p]; if not h or h.spCount < 3 then return nil end
    local n = h.spCount < 10 and h.spCount or 10
    local head = h.spHead
    local sx, sy, sz = 0, 0, 0
    for i = 0, n-1 do local j = head-i; if j < 1 then j = j + HB_HIST_SZ end; sx=sx+h.spX[j]; sy=sy+h.spY[j]; sz=sz+h.spZ[j] end
    return newV3(sx/n, sy/n, sz/n), 1
end
function AttentionPredict(h, ft)
    if not S.REV_AI.transformer or h.spCount < 10 then return nil end
    local n = h.spCount < 20 and h.spCount or 20
    local head = h.spHead
    local sumW, wx, wy, wz = 0, 0, 0, 0
    for i = 1, n do
        local j = head-i+1; if j < 1 then j = j + HB_HIST_SZ end
        local w = exp(-(n-i)/4)
        wx=wx+h.spX[j]*w; wy=wy+h.spY[j]*w; wz=wz+h.spZ[j]*w
        sumW = sumW + w
    end
    if sumW == 0 then return nil end
    local invW = 1/sumW
    return newV3(wx*invW, wy*invW, wz*invW) + h.vel * ft * 0.7
end
function MoEExperts(dist, stab, weapon)
    if not S.REV_AI.moe then return 1 end
    if dist > 80 then return 1 end
    if dist < 20 and stab < 0.3 then return 2 end
    if weapon == "knife" then return 3 end
    if stab > 0.7 then return 4 end
    return 5
end
function Uncertainty(h)
    if not S.REV_AI.uncert then return 1 end
    if not h or h.spCount < 5 then return 0 end
    local n = h.spCount < 5 and h.spCount or 5
    local head = h.spHead
    local sx, sy, sz = 0, 0, 0
    for i = 0, n-1 do local j = head-i; if j < 1 then j = j + HB_HIST_SZ end; sx=sx+h.spX[j]; sy=sy+h.spY[j]; sz=sz+h.spZ[j] end
    sx, sy, sz = sx/n, sy/n, sz/n
    local v = 0
    for i = 0, n-1 do
        local j = head-i; if j < 1 then j = j + HB_HIST_SZ end
        local dx, dy, dz = h.spX[j]-sx, h.spY[j]-sy, h.spZ[j]-sz
        v = v + dx*dx + dy*dy + dz*dz
    end
    return 1 / (1 + sqrt(v/n))
end
function CounterfactualSim(tp, camPos)
    if not S.REV_AI.counterfact then return nil end
    local h = Hst[tp]; if not h then return nil end
    return h.lastPos + h.vel * 0.03
end
function AdversarialTick()
    if not S.REV_AI.adversarial then return end
    RevAI.adversarialCycles = RevAI.adversarialCycles + 1
    if RevAI.adversarialCycles % 30 == 0 then
        for _ = 1, 5 do HB_NNTrain({random(),random(),random(),random(),random(),random(),random(),random()}, {random()-0.5, random()-0.5, random()-0.5}) end
    end
end
function LifelongRecall(input)
    if not S.REV_AI.lifelong then return nil end
    return RevAI.lifelongMem[sformat("%.2f_%.2f_%.2f", input[1], input[2], input[3])]
end
function BehaviourClone(aimVec, targetVec)
    if not S.REV_AI.cloning then return end
    local buf = RevAI.cloneBuffer
    buf[#buf+1] = {inp=aimVec, out=targetVec, t=tick()}
    if #buf > 500 then tremove(buf, 1) end
    if #buf >= 100 and #buf % 10 == 0 then
        for _ = 1, 5 do
            local s = buf[random(1, #buf)]
            if s and s.inp and s.out then
                HB_NNTrain({s.inp.X,s.inp.Y,s.inp.Z,s.out.X,s.out.Y,s.out.Z,0.5,0}, {s.out.X, s.out.Y, s.out.Z})
            end
        end
    end
end
function SelfPlayTick()
    if not S.REV_AI.selfPlay then return end
    local games = RevAI.selfPlayGames
    if #games >= S.REV_AI.selfPlayEpochs then return end
    games[#games+1] = {epoch=#games+1, score=NNReal.trained/100}
    if #games % 10 == 0 then
        for _ = 1, 10 do HB_NNTrain({0,0,0,0,0,0,0.5,0.2}, {random()-0.5, random()-0.5, random()-0.5}) end
    end
end

PersonaPresets = {
    aggressive={snapMul=0.7,holdMul=1.3,smoothMul=0.5},
    cautious={snapMul=1.3,holdMul=0.9,smoothMul=1.8},
    imprevisivel={snapMul=1.2,holdMul=1.0,smoothMul=1.2},
    calculista={snapMul=0.9,holdMul=1.1,smoothMul=1.0},
    casual={snapMul=1.5,holdMul=0.8,smoothMul=2.0},
}
function PersonaApply()
    if not S.REV_HUMAN then return end
    local p = PersonaPresets[S.REV_HUMAN.persona]
    if not p or not Flick then return end
    local st = S.REV_HUMAN.personaStrength or 0.7
    Flick.snapDur = Flick.snapDur*(1-st) + (0.045*p.snapMul)*st
    Flick.holdDur = Flick.holdDur*(1-st) + (0.15*p.holdMul)*st
    S.AimSmooth = (S.AimSmooth or 0.15)*(1-st) + (0.15*p.smoothMul)*st
end
function WarmupFactor()
    if not S.REV_HUMAN or not S.REV_HUMAN.warmup then return 1 end
    local m = (tick()-S.SessionStart)/60
    if m < S.REV_HUMAN.warmupMin then return 0.7 + (m/S.REV_HUMAN.warmupMin)*0.3 end
    return 1
end
function CooldownFactor()
    if not S.REV_HUMAN or not S.REV_HUMAN.cooldown then return 1 end
    local m = (tick()-S.SessionStart)/60
    if m > 60 then return max(0.6, 1-(m-60)*0.005) end
    return 1
end
function EmotionUpdate()
    if not S.REV_HUMAN or not S.REV_HUMAN.emotion then return end
    local rk, rd = 0, 0; local now = tick()
    local k = KillLog; local head = k.head; local cnt = k.count; local slots = k.slots
    for i = 1, cnt do
        local j = head-i+1; if j < 1 then j = j + KILLLOG_SZ end
        local s = slots[j]
        if now - s.time < 120 then if s.miss then rd = rd + 1 else rk = rk + 1 end end
    end
    RevHuman.emotion = RevHuman.emotion * 0.7 + (rk/max(1, rk+rd)) * 0.3
end
function CognitiveLoad()
    if not S.REV_HUMAN or not S.REV_HUMAN.cognitive then return 1 end
    local visible = 0
    for i = 1, #Cache.List do
        local p = Cache.List[i]
        if p ~= LP then
            local hrp = Cache.HRPs[p]
            if hrp then
                local sp, on = Camera:WorldToViewportPoint(hrp.Position)
                if on and sp.Z > 0 then visible = visible + 1 end
            end
        end
    end
    RevHuman.cogLoad = min(1, visible / (S.REV_HUMAN.cogMultiMax or 4))
    return 1 - RevHuman.cogLoad * 0.15
end
function FatigueFactor()
    if not S.REV_HUMAN or not S.REV_HUMAN.fatigue then return 1 end
    local h = (tick()-S.SessionStart)/3600
    RevHuman.fatigue = min(0.5, h * (S.REV_HUMAN.fatiguePerHour or 0.05))
    return 1 - RevHuman.fatigue
end
function SquadDetect()
    if not S.REV_HUMAN or not S.REV_HUMAN.squad then return end
    local r = S.REV_HUMAN.squadRadius or 30
    RevHuman.squads = {}
    for i = 1, #Cache.List do
        local p1 = Cache.List[i]
        if p1 ~= LP then
            local h1 = Cache.HRPs[p1]
            if h1 then
                for j = 1, #Cache.List do
                    local p2 = Cache.List[j]
                    if p2 ~= p1 and p2 ~= LP then
                        local h2 = Cache.HRPs[p2]
                        if h2 and (h1.Position-h2.Position).Magnitude < r then
                            RevHuman.squads[p1] = RevHuman.squads[p1] or {}
                            RevHuman.squads[p1][p2] = true
                        end
                    end
                end
            end
        end
    end
end
function ReputationUpdate(p, isKill)
    if not S.REV_HUMAN or not S.REV_HUMAN.reputation then return end
    local r = RevHuman.reputa[p]
    if not r then r = {kills=0, deaths=0, lastSeen=tick()}; RevHuman.reputa[p] = r end
    if isKill then r.kills = r.kills + 1 else r.deaths = r.deaths + 1 end
    r.lastSeen = tick()
end
function BallisticSim(origin, targetPos, tool)
    if not S.REV_PHYS or not S.REV_PHYS.ballistic then return targetPos end
    local n = tool and slower(tool.Name) or ""
    if sfind(n,"knife") then return targetPos end
    local dist = (targetPos-origin).Magnitude
    local t = dist / GetWeaponSpeed(tool)
    return newV3(targetPos.X, targetPos.Y + 0.5*196.2*t*t, targetPos.Z)
end
function IKPrediction(char, ft)
    if not S.REV_PHYS or not S.REV_PHYS.ik then return nil end
    local head = char:FindFirstChild("Head"); local hrp = char:FindFirstChild("HumanoidRootPart")
    if not head or not hrp then return nil end
    return head.Position + hrp.CFrame.LookVector * ft * 20
end
function AnimPredict(char, ft)
    if not S.REV_PHYS or not S.REV_PHYS.animMirror then return nil end
    local head = char:FindFirstChild("Head"); if not head then return nil end
    return head.Position
end
function GameStateRecon()
    if not S.REV_PHYS or not S.REV_PHYS.gameStateRecon then return end
    RevPhys.reconState = {}
    for i = 1, #Cache.List do
        local p = Cache.List[i]
        if p ~= LP then local hrp = Cache.HRPs[p]; if hrp then RevPhys.reconState[p] = hrp.Position end end
    end
end
function ServerMirror(tp, pred) return pred end
function JitterBuffer(p)
    if not S.REV_PHYS or not S.REV_PHYS.jitterBuf then return nil end
    local h = Hst[p]; if not h or h.spCount < 3 then return nil end
    local j = h.spHead - 3; if j < 1 then j = j + HB_HIST_SZ end
    return newV3(h.spX[j], h.spY[j], h.spZ[j])
end
function Misdirect()
    if not S.REV_SOCIAL or not S.REV_SOCIAL.misdirect then return false end
    if random() < (S.REV_SOCIAL.misdirectRate or 0.15) then
        RevSocial.misdirectCount = RevSocial.misdirectCount + 1; return true
    end
    return false
end
function AntiReportGesture() return random() < (S.REV_SOCIAL.antiReportRate or 0.10) end
function SkillCurveFactor()
    if not S.REV_SOCIAL or not S.REV_SOCIAL.skillCurve then return 1 end
    local h = (tick()-S.SessionStart)/3600
    return min(1, 0.75 + (h/(S.REV_SOCIAL.skillCurveHours or 2))*0.25)
end
function SnapshotState()
    if not S.REV_ARCH or not S.REV_ARCH.rollback then return end
    local snaps = RevArch.snapshots
    snaps[#snaps+1] = {t=tick(), kills=S.Kills, deaths=S.Deaths}
    if #snaps > (S.REV_ARCH.snapshotFrames or 30) then tremove(snaps, 1) end
end
function BlockchainAdd(entry)
    if not S.REV_FEAT or not S.REV_FEAT.blockchain then return end
    local chain = RevFeat.chain
    local prev = #chain > 0 and chain[#chain].hash or "0"
    local data = prev.."|"..entry.."|"..tick()
    local hash = 0
    for i = 1, #data do hash = (hash*31 + data:byte(i)) % 2147483647 end
    chain[#chain+1] = {entry=entry, hash=hash, prev=prev, t=tick()}
    if #chain > 500 then tremove(chain, 1) end
end
function MultiRoundPlan()
    if not S.REV_GAME or not S.REV_GAME.multiRound then return end
    RevGame.roundPlan = {}
    for i = 1, (S.REV_GAME.multiRoundDepth or 5) do RevGame.roundPlan[i] = {round=i} end
end
function RoleRotation()
    if not S.REV_GAME or not S.REV_GAME.roleRot then return end
    local h = RevGame.roleHistory
    h[#h+1] = {role=GetRole(LP), t=tick()}
    if #h > 10 then tremove(h, 1) end
end
function LegendaryCheck()
    if not S.REV_GAME or not S.REV_GAME.legendary then return end
    if S.Kills >= (S.REV_GAME.legendaryThreshold or 20) and not RevGame.legendary.active then
        RevGame.legendary.active = true
    end
end
function AdversarialNoise(aimPos)
    if not S.REV_STEALTH or not S.REV_STEALTH.advExamples then return aimPos end
    local eps = S.REV_STEALTH.advEpsilon or 0.05
    return aimPos + newV3((random()-0.5)*eps, (random()-0.5)*eps, (random()-0.5)*eps)
end
function AntiAntiCheatCheck()
    if not S.REV_STEALTH or not S.REV_STEALTH.antiAntiCheat then return true end
    if RevStealth.aac and RevStealth.aac > 0 and tick() < RevStealth.aac then return false end
    if Err.count > 10 then RevStealth.aac = tick() + (S.REV_STEALTH.aacDelay or 30); Err.count = 0; return false end
    return true
end
function DigitalTwinUpdate()
    if not S.REV_MAD or not S.REV_MAD.digitalTwin then return end
    RevMad.twin.players = {}
    for i = 1, #Cache.List do
        local p = Cache.List[i]
        if p ~= LP then local hrp = Cache.HRPs[p]; if hrp then RevMad.twin.players[p] = {pos=hrp.Position, vel=hrp.AssemblyLinearVelocity or v3zero} end end
    end
end
function SleepWakeTick()
    if not S.REV_MAD or not S.REV_MAD.sleepWake then return end
    if tick() - IdleSince > (S.REV_MAD.sleepIdleThreshold or 300) then
        for _ = 1, 5 do HB_NNTrain({random(),random(),random(),random(),random(),random(),random(),random()}, {random()-0.5, random()-0.5, random()-0.5}) end
    end
end
function CurriculumAdvance()
    if not S.REV_MAD or not S.REV_MAD.curriculum then return end
    if Acc.rate() > 0.7 and NNReal.trained > 500 then S.REV_MAD.currStage = min(5, (S.REV_MAD.currStage or 1)+1) end
end
function DreamTrain()
    if not S.REV_MAD or not S.REV_MAD.dreamState then return end
    if tick() - IdleSince > 600 then
        for _ = 1, 10 do HB_NNTrain({random(),random(),random(),random(),random(),random(),random(),random()}, {random()-0.5, random()-0.5, random()-0.5}) end
    end
end
function RecursiveImprove()
    if not S.REV_MAD or not S.REV_MAD.recursive then return end
    if S.Kills > 0 and S.Kills % (S.REV_MAD.recursiveInterval or 1000) == 0 then
        NNReal.lr = NNReal.lr * (1 + (Acc.rate()-0.5)*0.1)
        RevMad.recursive.gens = (RevMad.recursive.gens or 0) + 1
    end
end
Acc.push = function(hit)
    local s = Acc.shots; s[#s+1] = hit and true or false
    if #s > 50 then tremove(s, 1) end
end
Acc.rate = function()
    local s = Acc.shots; if #s == 0 then return 0 end
    local h = 0; for i = 1, #s do if s[i] then h = h + 1 end end
    return h / #s
end

function ComputeAim(tp, tch, camPos, tool)
    if S.OneShotPerfect then
        local hum = tch and tch:FindFirstChildOfClass("Humanoid")
        if hum then
            local aim, t, dist, hitType = HB_PerfectAim(tp, tch, camPos, tool, hum)
            if aim then return aim, t, dist end
        end
    end
    if not tch or not tch.Parent then return nil end
    local head = tch:FindFirstChild("Head"); if not head then return nil end
    local h = Hst[tp]; if not h then return nil end
    local posNow = head.Position
    local dist = (posNow - camPos).Magnitude
    local totalTime = dist/GetWeaponSpeed(tool) + HB_GetSmoothedPing()*0.5 + 0.033
    if S.HitscanOpt and IsHitscan(tool) then return posNow, 0.02, dist end
    local base = HB_KalmanPred(h.kalman, totalTime)
    base = BallisticSim(camPos, base, tool)
    return base, totalTime, dist
end

Flick = {
    active=false, phase="idle", snapStartTick=0, flickStartTick=0,
    snapDur=0.014, holdDur=0.030, returnDur=0.035, verifyWait=0.150,
    targetPlayer=nil, targetChar=nil, targetHumanoid=nil, aimPos=nil,
    originCF=nil, originLookAt=nil, originalCameraType=nil, originalCameraSubject=nil,
    originalFOV=nil,
    shotsFired=0, killed=false, hitVerified=false, hpBefore=100, verifyStart=0,
    retriesLeft=0, lastFlickEnd=0, triggeredBy="manual", keyHeld=false,
    returnStartTick=0, returnStartCF=nil, returnTargetCF=nil, holdStartTick=0,
    proMode=false, overshootPct=0.010, microJitter=0, microJitterRate=10,
    preDipEnabled=false, preDipDur=0.020, preDipAmount=0.012, fireAtPeak=true,
    dipPos=nil, dipStartTick=0, jitterPhase=0, peakFired=false,
    oneShot=true, reactionDelay=0, reactionStartTick=0,
    adaptiveOvershoot=false, recoilEnabled=false, recoilAmount=0.020,
    recoilTime=0.055, recoilStartTick=0, recoilPhase="none", postShotSettle=0,
    peakFireDelay=0, currentDist=0, fired=false, bulletFired=false,
}
TriggerSuppressUntil = 0

function HB_ForceRestoreCamera()
    Flick.active=false; Flick.phase="idle"
    Flick.targetPlayer=nil; Flick.targetChar=nil; Flick.targetHumanoid=nil
    Flick.aimPos=nil; Flick.originCF=nil; Flick.originLookAt=nil
    Flick.returnStartCF=nil; Flick.returnTargetCF=nil
    Flick.originalCameraType=nil; Flick.originalCameraSubject=nil
    Flick.shotsFired=0; Flick.hitVerified=false; Flick.killed=false
    Flick.flickStartTick=0; Flick.lastFlickEnd=tick()
    Flick.dipStartTick=0; Flick.jitterPhase=0; Flick.peakFired=false
    Flick.reactionStartTick=0; Flick.recoilStartTick=0; Flick.recoilPhase="none"
    Flick.fired=false; Flick.bulletFired=false
    TriggerSuppressUntil = tick() + 0.20
    local function tryRestore()
        pcall(function()
            Camera.CameraType = E_CAM_CUSTOM
            local myChar = LP.Character
            local myHum = myChar and myChar:FindFirstChildOfClass("Humanoid")
            if myHum and myHum.Health > 0 then Camera.CameraSubject = myHum
            elseif myChar then Camera.CameraSubject = myChar end
            if S.ScreenStretch then
                local target = HB_GetScreenPresetFOV()
                if target then Camera.FieldOfView = target end
            end
        end)
    end
    tryRestore()
    for i = 1, 20 do delay(i * 0.025, tryRestore) end
end

function FindMurderQueue()
    local origin
    local lpHrp = Cache.HRPs[LP]
    if lpHrp then origin = lpHrp.Position else origin = Camera.CFrame.Position end
    local wallCheck = S.WallCheck ~= false
    local maxDist = S.FlickMaxDist or 5000
    local cands = {}
    local m, s, i_count = 0, 0, 0
    for i = 1, #Cache.List do
        local p = Cache.List[i]
        if p ~= LP then
            local role = GetRole(p)
            if role == "Murderer" then m = m + 1 elseif role == "Sheriff" then s = s + 1 else i_count = i_count + 1 end
            if role == "Murderer" then
                local ch = Cache.Chars[p]; local hrp = Cache.HRPs[p]
                if ch and ch.Parent and hrp then
                    local hum = ch:FindFirstChildOfClass("Humanoid")
                    if hum and hum.Health > 0 then
                        local d = (hrp.Position - origin).Magnitude
                        if d <= maxDist and (not wallCheck or HB_HasLineOfSight(ch)) then
                            cands[#cands+1] = {player=p, char=ch, hum=hum, dist=d}
                        end
                    end
                end
            end
        end
    end
    HB_DBG.murders = m; HB_DBG.sheriffs = s; HB_DBG.innocents = i_count
    HB_DBG.lastQueue = #cands
    tsort(cands, function(a,b) return a.dist < b.dist end)
    return cands
end

function StartFlick(target, triggeredBy)
    if Flick.active then HB_ForceRestoreCamera() end
    local curType = Camera.CameraType
    Flick.originalCameraType = (curType == E_CAM_SCRIPT) and E_CAM_CUSTOM or curType
    Flick.originalCameraSubject = Camera.CameraSubject
    Flick.originalFOV = Camera.FieldOfView
    local scf = Camera.CFrame
    Flick.targetPlayer = target.player; Flick.targetChar = target.char; Flick.targetHumanoid = target.hum
    Flick.originCF = scf; Flick.originLookAt = scf.Position + scf.LookVector * 100
    Flick.active = true; Flick.phase = "snap"
    Flick.snapStartTick = tick(); Flick.flickStartTick = tick()
    Flick.shotsFired = 0; Flick.killed = false; Flick.hitVerified = false; Flick.fired = false
    Flick.bulletFired = false
    Flick.hpBefore = target.hum.Health
    Flick.retriesLeft = Flick.oneShot and 0 or S.Retries
    Flick.triggeredBy = triggeredBy or "manual"
    Flick.dipStartTick = 0; Flick.jitterPhase = 0; Flick.peakFired = false
    Flick.reactionStartTick = 0; Flick.recoilStartTick = 0; Flick.recoilPhase = "none"
    Flick.peakFireDelay = random() * 0.012
    Flick.currentDist = target.dist or 0
    Camera.CameraType = E_CAM_SCRIPT
    pcall(ReputationUpdate, target.player, false)
    spawn(function()
        local s1 = FindSlot1Tool()
        if s1 then pcall(function() HB_EquipAndWait(s1, 0.5) end) end
    end)
end
function EndFlick()
    if not Flick.active then return end
    Flick.phase = "return"
    Flick.returnStartTick = tick()
    Flick.returnStartCF = Camera.CFrame
    Flick.returnTargetCF = Flick.originCF
end

HB_CONNS[#HB_CONNS+1] = RS_Render:Connect(function(dt)
    if not Flick then return end
    local F = Flick
    local cam = Camera
    if not F.active and cam.CameraType == E_CAM_SCRIPT then
        cam.CameraType = E_CAM_CUSTOM
        local myChar = LP.Character
        local myHum = myChar and myChar:FindFirstChildOfClass("Humanoid")
        if myHum and myHum.Health > 0 then cam.CameraSubject = myHum elseif myChar then cam.CameraSubject = myChar end
    end
    if F.active and F.flickStartTick > 0 and tick() - F.flickStartTick > 2.5 then
        HB_ForceRestoreCamera(); return
    end
    if S.FlickCameraMode == "Off" then
        if F.active then
            local tp, ch, hum = F.targetPlayer, F.targetChar, F.targetHumanoid
            if tp and tp.Parent and ch and ch.Parent and hum and hum.Health > 0 and not F.bulletFired then
                F.bulletFired = true
                local myChar = LP.Character
                if myChar then
                    local s1 = FindSlot1Tool()
                    if s1 then
                        local eq = HB_EquipAndWait(s1, 0.5)
                        if eq and not IsWeaponOnCooldown(eq) then
                            spawn(function()
                                local camPos = (Cache.Heads[LP] and Cache.Heads[LP].Position) or cam.CFrame.Position
                                local ok = HB_PerfectShot(tp, ch, hum, camPos, eq)
                                if ok then F.shotsFired = 1; F.hitVerified = true end
                            end)
                        end
                    end
                end
            end
            if tick() - (F.flickStartTick or 0) > 0.25 then HB_ForceRestoreCamera() end
        end
        return
    end
    if F.phase == "return" and F.active then
        if not F.returnStartCF or not F.returnTargetCF then HB_ForceRestoreCamera(); return end
        local el = tick() - (F.returnStartTick or tick())
        local dur = F.returnDur or 0.035
        if dur <= 0.001 then HB_ForceRestoreCamera(); return end
        local t = clamp(el / dur, 0, 1)
        local eased = HB_EaseBezier(t, 0.4, 0.6)
        local pos = F.returnStartCF.Position:Lerp(F.returnTargetCF.Position, eased)
        local lf = F.returnStartCF.Position + F.returnStartCF.LookVector * 100
        local lt = F.returnTargetCF.Position + F.returnTargetCF.LookVector * 100
        cam.CameraType = E_CAM_SCRIPT
        cam.CFrame = lookAt(pos, lf:Lerp(lt, eased))
        if t >= 1 then HB_ForceRestoreCamera() end
        return
    end
    if not F.active then return end
    local tp, ch, hum = F.targetPlayer, F.targetChar, F.targetHumanoid
    if not tp or not tp.Parent or not ch or not ch.Parent or not hum or not hum.Parent or hum.Health <= 0 then EndFlick(); return end
    if GetRole(tp) ~= "Murderer" then EndFlick(); return end
    local lpHead = Cache.Heads[LP]
    local camPos = lpHead and lpHead.Position or cam.CFrame.Position
    local myChar = LP.Character
    if not myChar then HB_ForceRestoreCamera(); return end
    local eqTool = myChar:FindFirstChildOfClass("Tool")
    local aimPos = ComputeAim(tp, ch, camPos, eqTool)
    if not aimPos then local head = ch:FindFirstChild("Head"); if head then aimPos = head.Position end end
    if not aimPos then EndFlick(); return end
    F.aimPos = aimPos
    if F.phase == "snap" then
        if F.reactionStartTick == 0 then F.reactionStartTick = tick() end
        if F.reactionStartTick > 0 and F.reactionDelay > 0 then
            local reactEl = tick() - F.reactionStartTick
            if reactEl < F.reactionDelay then return end
            F.reactionStartTick = -1
            F.snapStartTick = tick()
        end
        local el = tick() - F.snapStartTick
        local snapDur = F.snapDur * (FPS.cur < S.FPSAdaptiveMinFPS and (S.FPSAdaptiveMinFPS / max(FPS.cur, 15)) or 1)
        if snapDur <= 0.001 then snapDur = 0.001 end
        if el < snapDur then
            local t = clamp(el / snapDur, 0, 1)
            local look = F.originLookAt:Lerp(aimPos, HB_EaseS(t))
            if not F.bulletFired and t >= 0.45 then
                F.bulletFired = true; F.fired = true
                spawn(function()
                    local s1 = FindSlot1Tool(); if not s1 then return end
                    local eq = HB_EquipAndWait(s1, 0.5); if not eq then return end
                    F.hpBefore = hum.Health
                    local ok = HB_PerfectShot(tp, ch, hum, camPos, eq)
                    if ok then F.shotsFired = 1; F.hitVerified = true end
                end)
            end
            cam.CameraType = E_CAM_SCRIPT
            cam.CFrame = lookAt(camPos, look)
        else
            F.phase = "hold"; F.holdStartTick = tick(); F.jitterPhase = 0
        end
        return
    end
    if F.phase == "hold" then
        cam.CameraType = E_CAM_SCRIPT
        cam.CFrame = lookAt(camPos, aimPos)
        if not F.bulletFired then
            F.bulletFired = true; F.fired = true
            spawn(function()
                local s1 = FindSlot1Tool(); if not s1 then return end
                local eq = HB_EquipAndWait(s1, 0.5); if not eq then return end
                F.hpBefore = hum.Health
                local ok = HB_PerfectShot(tp, ch, hum, camPos, eq)
                if ok then F.shotsFired = 1; F.hitVerified = true end
            end)
        end
        local holdTarget = F.holdDur
        if F.oneShot and F.shotsFired == 1 then holdTarget = F.postShotSettle end
        if tick() - F.holdStartTick >= holdTarget then
            F.phase = "verify"; F.verifyStart = tick()
        end
        return
    end
    if F.phase == "verify" then
        if not hum.Parent or hum.Health <= 0 then F.killed = true end
        if hum.Health < F.hpBefore then F.hitVerified = true end
        if F.hitVerified then
            pcall(ReputationUpdate, tp, true)
            if ch and ch.Parent then spawn(HB_SpawnKillEffect, ch) end
            MetaLearnUpdate(1); EndFlick(); return
        end
        if tick() - F.verifyStart >= F.verifyWait then
            MetaLearnUpdate(0); EndFlick()
        end
    end
end)

HB_Visuals = {enabled=true, preset="Tryhard", saturation=0.22, contrast=0.18,
    brightness=0.02, tintColor=c3(255, 245, 235),
    bloomIntensity=0.55, bloomSize=22, bloomThreshold=1.45,
    sunRaysIntensity=0.04, sunRaysSpread=0.9,
    atmosphereEnabled=true, density=0.32, haze=1.6, glare=0.12,
    atmosphereColor=c3(180, 190, 220), atmosphereDecay=c3(120, 130, 160)}
function HB_ApplyVisuals()
    local L = Lighting
    for _, o in ipairs_(L:GetChildren()) do if sfind(o.Name, "HB_") then o:Destroy() end end
    if not HB_Visuals.enabled then return end
    if HB_Visuals.preset == "Tryhard" then
        HB_Visuals.saturation=0.22 HB_Visuals.contrast=0.18
        HB_Visuals.bloomIntensity=0.55 HB_Visuals.sunRaysIntensity=0.04
    elseif HB_Visuals.preset == "Cinematic" then
        HB_Visuals.saturation=0.35 HB_Visuals.contrast=0.30
        HB_Visuals.bloomIntensity=0.85 HB_Visuals.sunRaysIntensity=0.12
    elseif HB_Visuals.preset == "Clean" then
        HB_Visuals.saturation=0.10 HB_Visuals.contrast=0.08
        HB_Visuals.bloomIntensity=0.30 HB_Visuals.sunRaysIntensity=0.00
    end
    local cc = Instance_new("ColorCorrectionEffect")
    cc.Name = "HB_ColorCorrection"
    cc.Saturation=HB_Visuals.saturation cc.Contrast=HB_Visuals.contrast
    cc.Brightness=HB_Visuals.brightness cc.TintColor=HB_Visuals.tintColor
    cc.Parent = L
    local bl = Instance_new("BloomEffect")
    bl.Name="HB_Bloom" bl.Intensity=HB_Visuals.bloomIntensity
    bl.Size=HB_Visuals.bloomSize bl.Threshold=HB_Visuals.bloomThreshold
    bl.Parent = L
    local sr = Instance_new("SunRaysEffect")
    sr.Name="HB_SunRays" sr.Intensity=HB_Visuals.sunRaysIntensity
    sr.Spread=HB_Visuals.sunRaysSpread sr.Parent = L
    if HB_Visuals.atmosphereEnabled then
        local at = Instance_new("Atmosphere")
        at.Name="HB_Atmosphere" at.Density=HB_Visuals.density
        at.Haze=HB_Visuals.haze at.Glare=HB_Visuals.glare
        at.Color=HB_Visuals.atmosphereColor at.Decay=HB_Visuals.atmosphereDecay
        at.Parent = L
    end
end
function HB_RemoveVisuals()
    local L = Lighting
    for _, o in ipairs_(L:GetChildren()) do if sfind(o.Name, "HB_") then o:Destroy() end end
end

local VoidGuardAccum = 0
HB_CONNS[#HB_CONNS+1] = RS_Heartbeat:Connect(function(dt)
    if not S.AntiVoid then return end
    VoidGuardAccum = VoidGuardAccum + dt
    if VoidGuardAccum < 0.1 then return end
    VoidGuardAccum = 0
    local myChar = LP.Character
    local myHRP = myChar and myChar:FindFirstChild("HumanoidRootPart")
    local myHum = myChar and myChar:FindFirstChildOfClass("Humanoid")
    if not myHRP or not myHum or myHum.Health <= 0 then return end
    local y = myHRP.Position.Y
    local thresh = S.AntiVoidYThresh or -50
    if y > (thresh + 20) then LastSafeCF = myHRP.CFrame
    elseif y < thresh and LastSafeCF then
        pcall(function()
            myHRP.CFrame = newCF(LastSafeCF.Position + newV3(0, S.AntiVoidLift or 8, 0))
            myHRP.AssemblyLinearVelocity = v3zero
            myHRP.AssemblyAngularVelocity = v3zero
            myHum:ChangeState(E_HS_GETTING)
        end)
        HB_DBG.voidRescues = (HB_DBG.voidRescues or 0) + 1
    end
end)

local CamGuardAccum = 0
HB_CONNS[#HB_CONNS+1] = RS_Heartbeat:Connect(function(dt)
    CamGuardAccum = CamGuardAccum + dt
    if CamGuardAccum < 0.05 then return end
    CamGuardAccum = 0
    if Flick.active and Flick.flickStartTick > 0 and tick() - Flick.flickStartTick > 2.5 then
        HB_ForceRestoreCamera(); return
    end
    if Camera.CameraType == E_CAM_SCRIPT and not Flick.active then HB_ForceRestoreCamera(); return end
    if not Flick.active then
        local sinceEnd = tick() - (Flick.lastFlickEnd or 0)
        if sinceEnd < 3.0 then
            local myChar = LP.Character
            local myHum = myChar and myChar:FindFirstChildOfClass("Humanoid")
            if myHum and myHum.Health > 0 and Camera.CameraSubject ~= myHum then
                pcall(function()
                    Camera.CameraType = E_CAM_CUSTOM
                    Camera.CameraSubject = myHum
                end)
            end
        end
    end
end)

HB_GunDrop = {active=nil, highlight=nil, billboard=nil}
local GUNDROP_NAMES = {"GunDrop", "Gun Drop", "GunDrop1", "DroppedGun", "GunDropModel"}
local function HB_FindGunDrop()
    for _, nm in ipairs_(GUNDROP_NAMES) do
        local obj = workspace:FindFirstChild(nm, true)
        if obj then return obj end
    end
    for _, obj in ipairs_(workspace:GetChildren()) do
        if obj:IsA("Tool") or obj:IsA("Model") then
            local n = slower(obj.Name)
            if sfind(n,"gun") or sfind(n,"revolver") then
                local parent = obj.Parent
                if not (parent and parent:IsA("Model") and parent:FindFirstChildOfClass("Humanoid")) then
                    return obj
                end
            end
        end
    end
    return nil
end
local function HB_ClearGunDropESP()
    if HB_GunDrop.highlight then pcall(function() HB_GunDrop.highlight:Destroy() end) HB_GunDrop.highlight = nil end
    if HB_GunDrop.billboard then pcall(function() HB_GunDrop.billboard:Destroy() end) HB_GunDrop.billboard = nil end
    HB_GunDrop.active = nil
end
local function HB_CreateGunDropESP(gun)
    if not gun or not gun.Parent then return end
    if HB_GunDrop.active == gun and HB_GunDrop.highlight and HB_GunDrop.highlight.Parent then return end
    HB_ClearGunDropESP()
    local adornee = gun
    if gun:IsA("Model") then adornee = gun:FindFirstChildWhichIsA("BasePart", true) or gun
    elseif gun:IsA("Tool") then adornee = gun:FindFirstChild("Handle") or gun end
    local hl = Instance_new("Highlight")
    hl.Name = "HB_GunDrop_HL"; hl.Adornee = adornee
    hl.DepthMode = E_HL_AOT
    hl.FillColor = S.GunDropESPColor or c3(255, 210, 40)
    hl.OutlineColor = S.GunDropESPOutline or c3(255, 255, 255)
    hl.FillTransparency = S.GunDropESPFill or 0.5
    hl.OutlineTransparency = S.GunDropESPOutlineT or 0.3
    hl.Parent = adornee
    if S.GunDropESPText then
        local bb = Instance_new("BillboardGui")
        bb.Name = "HB_GunDrop_BB"; bb.Adornee = adornee
        bb.Size = newUD2(8, 0, 2, 0); bb.StudsOffset = newV3(0, 3.5, 0)
        bb.AlwaysOnTop = true; bb.LightInfluence = 0
        bb.MaxDistance = 500; bb.Parent = adornee
        local lbl = Instance_new("TextLabel")
        lbl.Name = "HB_GunDrop_Lbl"
        lbl.Size = newUD2(1, 0, 0.6, 0)
        lbl.BackgroundTransparency = 1; lbl.Text = "🔫 ARMA CAÍDA"
        lbl.TextColor3 = S.GunDropESPTextColor or c3(255, 210, 40)
        lbl.TextStrokeTransparency = 0; lbl.TextStrokeColor3 = c3(0, 0, 0)
        lbl.Font = E_GOTHAM_BOLD; lbl.TextSize = 16
        lbl.Parent = bb
        local dst = Instance_new("TextLabel")
        dst.Name = "HB_GunDrop_Dist"
        dst.Size = newUD2(1, 0, 0.4, 0)
        dst.Position = newUD2(0, 0, 0.6, 0)
        dst.BackgroundTransparency = 1; dst.Text = ""
        dst.TextColor3 = c3(220, 220, 220); dst.TextStrokeTransparency = 0
        dst.TextStrokeColor3 = c3(0, 0, 0); dst.Font = E_CODE; dst.TextSize = 12
        dst.Parent = bb
        HB_GunDrop.billboard = bb
    end
    HB_GunDrop.highlight = hl
    HB_GunDrop.active = gun
end
local GunDropAccum = 0
HB_CONNS[#HB_CONNS+1] = RS_Heartbeat:Connect(function(dt)
    if not S.GunDropESP then
        if HB_GunDrop.active then HB_ClearGunDropESP() end
        return
    end
    GunDropAccum = GunDropAccum + dt
    if GunDropAccum < 0.1 then return end
    GunDropAccum = 0
    local gun = HB_FindGunDrop()
    if gun then
        HB_CreateGunDropESP(gun)
        if S.GunDropESPDistance and HB_GunDrop.billboard and HB_GunDrop.billboard.Parent then
            local distLbl = HB_GunDrop.billboard:FindFirstChild("HB_GunDrop_Dist")
            if distLbl and LP.Character then
                local myHRP = LP.Character:FindFirstChild("HumanoidRootPart")
                if myHRP then
                    local adornee = HB_GunDrop.billboard.Adornee
                    if adornee and adornee.Position then
                        distLbl.Text = sformat("[%dm]", floor((adornee.Position - myHRP.Position).Magnitude))
                    end
                end
            end
        end
    elseif HB_GunDrop.active then HB_ClearGunDropESP() end
end)
HB_G.RefreshGunDropESP = function()
    if HB_GunDrop.highlight then
        HB_GunDrop.highlight.FillColor = S.GunDropESPColor or c3(255, 210, 40)
        HB_GunDrop.highlight.OutlineColor = S.GunDropESPOutline or c3(255, 255, 255)
        HB_GunDrop.highlight.FillTransparency = S.GunDropESPFill or 0.5
        HB_GunDrop.highlight.OutlineTransparency = S.GunDropESPOutlineT or 0.3
    end
    if HB_GunDrop.billboard then
        local lbl = HB_GunDrop.billboard:FindFirstChild("HB_GunDrop_Lbl")
        if lbl then lbl.TextColor3 = S.GunDropESPTextColor or c3(255, 210, 40) end
    end
end

local function HB_WireChar(char)
    if not char then return end
    spawn(function() wait(0.1); HB_ForceRestoreCamera() end)
    local hum = char:FindFirstChildOfClass("Humanoid")
    if hum then hum.Died:Connect(function() HB_ForceRestoreCamera() end) end
end
LP.CharacterAdded:Connect(HB_WireChar)
if LP.Character then HB_WireChar(LP.Character) end

local KFE_Hooked = setmetatable({}, {__mode = "k"})
local function HB_HookDeath(pl)
    if KFE_Hooked[pl] then return end
    KFE_Hooked[pl] = true
    local function hookChar(char)
        local hum = char:WaitForChild("Humanoid", 10); if not hum then return end
        hum.Died:Connect(function()
            spawn(function()
                wait(0.08)
                if HB_SpawnKillEffect and char and char.Parent then HB_SpawnKillEffect(char) end
            end)
            if pl ~= LP then
                local h = Hst[pl]
                if h and h.lastT and (tick() - h.lastT) < 2.0 then Acc.push(true) end
            end
        end)
    end
    pl.CharacterAdded:Connect(hookChar)
    if pl.Character then hookChar(pl.Character) end
end
for _, pl in ipairs_(Players:GetPlayers()) do HB_HookDeath(pl) end
Players.PlayerAdded:Connect(HB_HookDeath)

RadarDotPool = {}; RadarDotUsed = 0
function RadarGetDot()
    RadarDotUsed = RadarDotUsed + 1
    local dot = RadarDotPool[RadarDotUsed]
    if not dot then
        dot = HB_Create("Frame", {Size=newUD2(0,6,0,6), BackgroundColor3=c3(255,255,255), BorderSizePixel=0, ZIndex=71, Visible=false}, RADAR_FRAME)
        HB_Corner(dot, 3); RadarDotPool[RadarDotUsed] = dot
    end
    return dot
end
TimelineDotPool = {}; TimelineDotUsed = 0
function TimelineGetDot()
    TimelineDotUsed = TimelineDotUsed + 1
    local dot = TimelineDotPool[TimelineDotUsed]
    if not dot then
        dot = HB_Create("Frame", {Size=newUD2(0,4,0,4), BackgroundColor3=c3(255,255,255), BorderSizePixel=0, ZIndex=55, Visible=false}, TIMELINE_HOLDER)
        HB_Corner(dot, 2); TimelineDotPool[TimelineDotUsed] = dot
    end
    return dot
end

print("[HELLBORN] BLOCO 1/2 OK — ULTRA PRECISION + IA COMPLETA")
--==============================================================
-- HELLBORN v10.0 CHROME-MERGED — BLOCO 2/2
-- UI Chrome + Todas as sub-abas + ESP + HUD + Presets + Boot
-- ULTRA PRECISION · SHARINGAN · SCREEN STRETCH (em VISUAL)
--==============================================================

UIS_InputBegan:Connect(function(input, gp)
    if gp then return end
    if input.UserInputType == E_KEYBOARD then
        local kc = input.KeyCode
        if kc == S.FlickKey then
            Flick.keyHeld = true
            if not Flick.active then
                local now = tick()
                if S.PostKillDelay and now < PostKillTimer.until_ then return end
                if S.AntiFlickBlock and now < AntiFlickGuard.backoffUntil then return end
                if S.HoldToFlick then return end
                local q = FindMurderQueue()
                if #q > 0 then
                    Flick.lastFlickEnd = 0
                    TriggerSuppressUntil = now + 0.50
                    StartFlick(q[1], "manual")
                end
            end
        elseif kc == Enum.KeyCode.Insert then
            if UI and UI.Main then UI.Main.Visible = not UI.Main.Visible end
        elseif kc == Enum.KeyCode.F1 then
            S.AutoFlick=false S.TrigOn=false S.ESP=false
            HB_ForceRestoreCamera(); HB_Toast("PANIC", "danger")
        elseif kc == Enum.KeyCode.F6 then
            HB_ForceRestoreCamera(); HB_Toast("Câmera OK", "success")
        elseif kc == Enum.KeyCode.F4 then HB_PresetTryhard()
        elseif kc == Enum.KeyCode.F5 then HB_PresetRageMax()
        elseif kc == Enum.KeyCode.F7 then HB_ApplyPreset("PRO_CLIP")
        elseif kc == Enum.KeyCode.F8 then HB_ApplyPreset("RAGE_PRO")
        elseif kc == Enum.KeyCode.F9 then HB_ApplyPreset("RAGE_TRYHARD") end
    end
end)
UIS_InputEnded:Connect(function(input)
    if input.UserInputType == E_KEYBOARD and input.KeyCode == S.FlickKey then
        Flick.keyHeld = false
        if S.HoldToFlick and not Flick.active and S.AutoFlick then
            local now = tick()
            if S.AntiFlickBlock and now < AntiFlickGuard.backoffUntil then return end
            local q = FindMurderQueue()
            if #q > 0 then StartFlick(q[1], "hold-release") end
        end
    end
end)
LP.Chatted:Connect(function(msg)
    if not S.ChatCommands then return end
    local cmd, arg = msg:match("^/hb%s+(%S+)%s*(.*)")
    if not cmd then return end
    if cmd == "flick" then S.AutoFlick = (arg ~= "off")
    elseif cmd == "esp" then S.ESP = (arg ~= "off")
    elseif cmd == "trigger" then S.TrigOn = (arg ~= "off")
    elseif cmd == "slot1" then S.PullSlot1 = (arg ~= "off"); HB_Toast("Slot1 "..tostring(S.PullSlot1),"success")
    elseif cmd == "oneshot" then S.OneShotPerfect = (arg ~= "off"); HB_Toast("OneShot "..tostring(S.OneShotPerfect),"success")
    elseif cmd == "lead" then S.OneShotLead = (arg ~= "off"); HB_Toast("Lead "..tostring(S.OneShotLead),"success")
    elseif cmd == "grav" then S.OneShotGravity = (arg ~= "off"); HB_Toast("Grav "..tostring(S.OneShotGravity),"success")
    elseif cmd == "adapt" then S.OneShotAdaptive = (arg ~= "off"); HB_Toast("Adapt "..tostring(S.OneShotAdaptive),"success")
    elseif cmd == "cross" then S.Cross = (arg ~= "off"); if HB_BuildCrosshair then HB_BuildCrosshair() end; HB_Toast("Cross "..tostring(S.Cross),"success")
    elseif cmd == "stretch" then
        S.ScreenStretch = (arg ~= "off"); HB_ApplyScreenStretch()
        HB_Toast("Stretch "..tostring(S.ScreenStretch),"success")
    elseif cmd == "fov" then
        local n = tonumber(arg)
        if n and n >= 20 and n <= 120 then
            S.ScreenStretch = true; S.ScreenStretchPreset = "Custom"
            S.ScreenStretchFOV = floor(n); HB_ApplyScreenStretch()
            HB_Toast("FOV: "..S.ScreenStretchFOV,"success")
        end
    elseif cmd == "resetscreen" then HB_ResetScreenStretch(); HB_Toast("Tela resetada","success")
    elseif cmd == "gundrop" then S.GunDropESP = (arg ~= "off"); HB_Toast("GunDrop "..tostring(S.GunDropESP),"success")
    elseif cmd == "fixcam" then HB_ForceRestoreCamera(); HB_Toast("Câmera OK","success")
    elseif cmd == "panic" then S.AutoFlick=false S.TrigOn=false S.ESP=false; HB_Toast("Panic!","danger")
    elseif cmd == "hide" then if UI and UI.Main then UI.Main.Visible=false end
    elseif cmd == "show" then if UI and UI.Main then UI.Main.Visible=true end end
end)

UI = {}; UI.Registered = {}; UI.MainTabs = {}; UI.SubTabs = {}
UI.TabContents = {}
UI.CurrentMain = nil; UI.CurrentSub = nil

local UI_vp = Camera.ViewportSize
local UI_baseW, UI_baseH = 920, 640
local UI_scale = max(0.5, min((UI_vp.X*0.92)/UI_baseW, (UI_vp.Y*0.92)/UI_baseH, 1.0))

UI_screen = HB_Create("ScreenGui", {Name=HB_X.."UI", ResetOnSpawn=false, IgnoreGuiInset=true, DisplayOrder=100}, PG)
UI.Screen = UI_screen

UI_main = HB_Create("Frame", {
    Name="Main", Size=newUD2(0,UI_baseW,0,UI_baseH),
    Position=newUD2(0.5,0,0.5,0), AnchorPoint=Vector2.new(0.5,0.5),
    BackgroundColor3=Palette.Surface, BorderSizePixel=0, ClipsDescendants=true, Active=true
}, UI_screen)
HB_Corner(UI_main, 12)
HB_Stroke(UI_main, Palette.Accent, 2, 0.6)
UI.Main = UI_main
UI_uiScale = HB_Create("UIScale", {Scale=UI_scale}, UI_main)

UI_header = HB_Create("Frame", {
    Name="Header", Size=newUD2(1,0,0,52),
    BackgroundColor3=c3(22,22,28), BackgroundTransparency=0.1,
    BorderSizePixel=0, ZIndex=10, Active=true
}, UI_main)
HB_Corner(UI_header, 12)
HB_Create("TextLabel", {
    Size=newUD2(0,420,0,20), Position=newUD2(0,16,0,8),
    BackgroundTransparency=1, Text="⚡ HELLBORN v10.0 · ULTRA PRECISION",
    Font=E_GOTHAM_BLACK, TextSize=16, TextColor3=Palette.TextHigh,
    TextXAlignment=E_TXT_LEFT, ZIndex=12
}, UI_header)
HB_Create("TextLabel", {
    Size=newUD2(0,420,0,12), Position=newUD2(0,16,0,30),
    BackgroundTransparency=1, Text="4-PASS AIM · ONE SHOT · SHARINGAN · "..HB_SERIAL,
    Font=E_CODE, TextSize=9, TextColor3=Palette.Accent,
    TextXAlignment=E_TXT_LEFT, ZIndex=12
}, UI_header)

local function mkHeaderBtn(txt, xOff, cb, color)
    local b = HB_Create("TextButton", {
        Size=newUD2(0,26,0,26), Position=newUD2(1,xOff,0.5,-13),
        BackgroundColor3=color or Palette.Elevated2, BorderSizePixel=0,
        Text=txt, Font=E_GOTHAM_BOLD, TextSize=13, TextColor3=Palette.TextHigh,
        AutoButtonColor=false, Active=true, Selectable=false, ZIndex=13
    }, UI_header)
    HB_Corner(b, 13); HB_Stroke(b, Palette.Border, 1, 0.4)
    b.Activated:Connect(cb); return b
end
local UI_closeBtn = mkHeaderBtn("✕", -40, function() UI_main.Visible=false end)
local UI_panicBtn = mkHeaderBtn("!", -72, function()
    S.AutoFlick=false S.TrigOn=false S.ESP=false HB_ForceRestoreCamera() HB_Toast("PANIC","danger")
end, c3(120,20,20))
local UI_zoomOut = mkHeaderBtn("−", -104, function() UI_uiScale.Scale = max(0.5, UI_uiScale.Scale - 0.1) end)
local UI_zoomIn  = mkHeaderBtn("+", -136, function() UI_uiScale.Scale = min(1.5, UI_uiScale.Scale + 0.1) end)
local UI_dragBtn = mkHeaderBtn("✥", -168, function() end)

UI_mainTabsBar = HB_Create("Frame", {
    Size=newUD2(1,-8,0,34), Position=newUD2(0,4,0,54),
    BackgroundTransparency=1, ZIndex=9
}, UI_main)
UI_mainTabsScroll = HB_Create("ScrollingFrame", {
    Size=newUD2(1,0,1,0), BackgroundTransparency=1,
    ScrollBarThickness=0, CanvasSize=newUD2(0,0,0,0),
    AutomaticCanvasSize=Enum.AutomaticSize.X,
    ScrollingDirection=Enum.ScrollingDirection.X
}, UI_mainTabsBar)
HB_Create("UIListLayout", {
    FillDirection=Enum.FillDirection.Horizontal,
    SortOrder=Enum.SortOrder.LayoutOrder,
    Padding=udim(0,2), VerticalAlignment=Enum.VerticalAlignment.Center
}, UI_mainTabsScroll)

UI_subTabsBar = HB_Create("Frame", {
    Size=newUD2(1,-8,0,28), Position=newUD2(0,4,0,92),
    BackgroundColor3=c3(14,14,18), BackgroundTransparency=0.35,
    BorderSizePixel=0, ZIndex=8
}, UI_main)
HB_Corner(UI_subTabsBar, 6)
UI_subTabsScroll = HB_Create("ScrollingFrame", {
    Size=newUD2(1,-8,1,0), Position=newUD2(0,4,0,0),
    BackgroundTransparency=1, ScrollBarThickness=0,
    CanvasSize=newUD2(0,0,0,0),
    AutomaticCanvasSize=Enum.AutomaticSize.X,
    ScrollingDirection=Enum.ScrollingDirection.X
}, UI_subTabsBar)
HB_Create("UIListLayout", {
    FillDirection=Enum.FillDirection.Horizontal,
    SortOrder=Enum.SortOrder.LayoutOrder,
    Padding=udim(0,4), VerticalAlignment=Enum.VerticalAlignment.Center
}, UI_subTabsScroll)

UI.Content = HB_Create("Frame", {
    Size=newUD2(1,-16,1,-132), Position=newUD2(0,8,0,124),
    BackgroundTransparency=1, ZIndex=3
}, UI_main)

UI.TabDefs = {
    {name="AIM",       icon="🎯", subs={"Core","Targeting","Prediction","TriggerBot","Anti-Detect","Locks"}},
    {name="FLICK",     icon="⚔",  subs={"Timings","Pro","1-Shot","Advanced","WallCheck","Camera","Modes"}},
    {name="ESP",       icon="◉",  subs={"Basic","Info","Filter","Visual","GunDrop"}},
    {name="VISUAL",    icon="✦",  subs={"HUD","Crosshair","ReShade","Tracers","KillFX","Screen"}},
    {name="IA",        icon="◈",  subs={"Core","RevIA","RevHuman","RevPhys","RevSocial","RevArch","RevFeat","RevGame","RevStealth","RevMad"}},
    {name="SPEED",     icon="⚡", subs={"Base","Advanced"}},
    {name="MODES",     icon="🎬", subs={"FlickModes","MM2","Presets"}},
    {name="FEEDBACK",  icon="🎨", subs={"Visual","Sounds","HUDCounter"}},
    {name="ADV",       icon="⚙",  subs={"Curves","Extras","Persona"}},
    {name="MM2",       icon="🎮", subs={"Flick","Protect"}},
    {name="DEBUG",     icon="🐞", subs={"HUD","Tests","Info"}},
    {name="STATS",     icon="▤",  subs={"Session","Reset"}},
    {name="CONFIG",    icon="⚙",  subs={"Theme","System","AutoSave"}},
}

for _, def in ipairs_(UI.TabDefs) do
    for si, subName in ipairs_(def.subs) do
        local key = def.name.."/"..subName
        local sf = HB_Create("ScrollingFrame", {
            Name=key, Size=newUD2(1,0,1,0),
            BackgroundTransparency=1, BorderSizePixel=0,
            ScrollBarThickness=4, ScrollBarImageColor3=Palette.Accent,
            ScrollingDirection=Enum.ScrollingDirection.Y,
            CanvasSize=newUD2(0,0,0,0),
            AutomaticCanvasSize=E_AUTO_Y,
            Visible=false, ZIndex=3
        }, UI.Content)
        HB_Create("UIPadding", {
            PaddingTop=udim(0,8), PaddingLeft=udim(0,8),
            PaddingRight=udim(0,8), PaddingBottom=udim(0,40)
        }, sf)
        HB_Create("UIListLayout", {
            FillDirection=Enum.FillDirection.Vertical,
            SortOrder=Enum.SortOrder.LayoutOrder,
            Padding=udim(0,6)
        }, sf)
        UI.TabContents[key] = sf
    end
end

local function makeMainTab(def, i)
    local btn = HB_Create("TextButton", {
        Size=newUD2(0,110,0,30), BackgroundColor3=Palette.Elevated,
        BackgroundTransparency=0.35, BorderSizePixel=0,
        Text="  "..def.icon.."  "..def.name,
        Font=E_GOTHAM_BOLD, TextSize=12, TextColor3=Palette.TextMid,
        TextXAlignment=E_TXT_LEFT, AutoButtonColor=false,
        Active=true, Selectable=false, LayoutOrder=i, ZIndex=10
    }, UI_mainTabsScroll)
    HB_Corner(btn, 6)
    btn:SetAttribute("TabName", def.name)
    UI.MainTabs[def.name] = btn
    return btn
end
local function makeSubTab(mainName, subName, i)
    local key = mainName.."/"..subName
    local btn = HB_Create("TextButton", {
        Size=newUD2(0,0,0,22), AutomaticSize=Enum.AutomaticSize.X,
        BackgroundColor3=Palette.Elevated2, BackgroundTransparency=0.7,
        BorderSizePixel=0, Text="  "..subName.."  ",
        Font=E_GOTHAM_MED, TextSize=11, TextColor3=Palette.TextMid,
        TextXAlignment=E_TXT_CENTER, AutoButtonColor=false,
        Active=true, Selectable=false, LayoutOrder=i, ZIndex=9
    }, UI_subTabsScroll)
    HB_Corner(btn, 4)
    btn:SetAttribute("Key", key)
    UI.SubTabs[key] = btn
    return btn
end

UI.switchSub = function(mainName, subName)
    UI.CurrentSub = subName
    for k, sf in pairs_(UI.TabContents) do
        sf.Visible = (k == mainName.."/"..subName)
    end
    for k, btn in pairs_(UI.SubTabs) do
        local isOn = k == mainName.."/"..subName
        TweenService:Create(btn, TweenInfo.new(0.12), {
            BackgroundColor3 = isOn and Palette.Accent or Palette.Elevated2,
            BackgroundTransparency = isOn and 0.1 or 0.7,
            TextColor3 = isOn and c3(255,255,255) or Palette.TextMid
        }):Play()
    end
end
UI.switchMain = function(mainName)
    UI.CurrentMain = mainName
    for name, btn in pairs_(UI.MainTabs) do
        TweenService:Create(btn, TweenInfo.new(0.15), {
            BackgroundColor3 = (name == mainName) and Palette.Accent or Palette.Elevated,
            BackgroundTransparency = (name == mainName) and 0.1 or 0.35,
            TextColor3 = (name == mainName) and c3(255,255,255) or Palette.TextMid
        }):Play()
    end
    for _, c in ipairs_(UI_subTabsScroll:GetChildren()) do
        if c:IsA("TextButton") then c:Destroy() end
    end
    UI.SubTabs = {}
    local def = nil
    for _, d in ipairs_(UI.TabDefs) do if d.name == mainName then def = d; break end end
    if not def then return end
    for si, subName in ipairs_(def.subs) do
        local btn = makeSubTab(mainName, subName, si)
        btn.Activated:Connect(function() UI.switchSub(mainName, subName) end)
    end
    UI.switchSub(mainName, def.subs[1])
end
for i, def in ipairs_(UI.TabDefs) do
    local btn = makeMainTab(def, i)
    btn.Activated:Connect(function() UI.switchMain(def.name) end)
end

Cmp = {}
local function Cmp_reg(p, n, k)
    UI.Registered[#UI.Registered+1] = {parent=p, name=slower(n), keywords=k and slower(k) or ""}
end
Cmp.Section = function(parent, text)
    local holder = HB_Create("Frame", {Size=newUD2(1,0,0,28), BackgroundTransparency=1}, parent)
    local bar = HB_Create("Frame", {
        Size=newUD2(0,3,0,12), Position=newUD2(0,0,0.5,-6),
        BackgroundColor3=Palette.Accent, BorderSizePixel=0
    }, holder)
    HB_Corner(bar, 2)
    HB_Create("TextLabel", {
        Size=newUD2(1,-12,1,0), Position=newUD2(0,10,0,0),
        BackgroundTransparency=1, Text=text,
        Font=E_GOTHAM_BOLD, TextSize=12, TextColor3=Palette.TextHigh,
        TextXAlignment=E_TXT_LEFT
    }, holder)
end
Cmp.Toggle = function(parent, opts)
    local text = opts.text or "Toggle"
    local desc = opts.desc
    local default = opts.default == true
    local cb = opts.callback
    local h = desc and 52 or 40
    local holder = HB_Create("Frame", {
        Size=newUD2(1,0,0,h), BackgroundColor3=Palette.Elevated,
        BorderSizePixel=0, Active=true
    }, parent)
    HB_Corner(holder, 8); HB_Stroke(holder, Palette.Border, 1, 0.3)
    HB_Create("TextLabel", {
        Size=newUD2(1,-80,0,desc and 16 or h),
        Position=newUD2(0,14,0,desc and 6 or 0),
        BackgroundTransparency=1, Text=text,
        Font=E_GOTHAM_MED, TextSize=12, TextColor3=Palette.TextHigh,
        TextXAlignment=E_TXT_LEFT
    }, holder)
    if desc then
        HB_Create("TextLabel", {
            Size=newUD2(1,-80,0,14), Position=newUD2(0,14,0,24),
            BackgroundTransparency=1, Text=desc,
            Font=E_GOTHAM, TextSize=10, TextColor3=Palette.TextLow,
            TextXAlignment=E_TXT_LEFT
        }, holder)
    end
    local track = HB_Create("Frame", {
        Size=newUD2(0,40,0,20), Position=newUD2(1,-54,0.5,-10),
        BackgroundColor3=default and Palette.Accent or c3(50,50,58)
    }, holder)
    HB_Corner(track, 10)
    local knob = HB_Create("Frame", {
        Size=newUD2(0,16,0,16),
        Position=default and newUD2(1,-19,0.5,-8) or newUD2(0,3,0.5,-8),
        BackgroundColor3=c3(250,250,250)
    }, track)
    HB_Corner(knob, 8)
    local on = default
    local hitbox = HB_Create("TextButton", {
        Size=newUD2(1,0,1,0), BackgroundTransparency=1, Text="",
        AutoButtonColor=false, Active=true, Selectable=false, ZIndex=50
    }, holder)
    hitbox.Activated:Connect(function()
        on = not on
        TweenService:Create(track, TweenInfo.new(0.2), {
            BackgroundColor3 = on and Palette.Accent or c3(50,50,58)
        }):Play()
        TweenService:Create(knob, TweenInfo.new(0.3, E_BACK), {
            Position = on and newUD2(1,-19,0.5,-8) or newUD2(0,3,0.5,-8)
        }):Play()
        if cb then pcall(cb, on) end
    end)
    Cmp_reg(holder, text, desc)
end
Cmp.Slider = function(parent, opts)
    local text = opts.text or "Slider"
    local cb = opts.callback
    local suf = opts.suffix or ""
    local mn, mx = opts.min or 0, opts.max or 100
    local default = opts.default or mn
    local h = 46
    local holder = HB_Create("Frame", {
        Size=newUD2(1,0,0,h), BackgroundColor3=Palette.Elevated, BorderSizePixel=0
    }, parent)
    HB_Corner(holder, 8); HB_Stroke(holder, Palette.Border, 1, 0.3)
    HB_Create("TextLabel", {
        Size=newUD2(0.5,0,0,18), Position=newUD2(0,14,0,4),
        BackgroundTransparency=1, Text=text,
        Font=E_GOTHAM_MED, TextSize=12, TextColor3=Palette.TextHigh,
        TextXAlignment=E_TXT_LEFT
    }, holder)
    local vLbl = HB_Create("TextLabel", {
        Size=newUD2(0,70,0,18), Position=newUD2(1,-84,0,4),
        BackgroundTransparency=1, Text=tostring(default)..suf,
        Font=E_CODE, TextSize=12, TextColor3=Palette.Accent,
        TextXAlignment=E_TXT_RIGHT
    }, holder)
    local bBg = HB_Create("Frame", {
        Size=newUD2(1,-28,0,8), Position=newUD2(0,14,0,h-16),
        BackgroundColor3=c3(36,36,44), BorderSizePixel=0, Active=true
    }, holder)
    HB_Corner(bBg, 4)
    local initPct = (default-mn)/(mx-mn)
    local bFill = HB_Create("Frame", {
        Size=newUD2(initPct,0,1,0), BackgroundColor3=Palette.Accent
    }, bBg)
    HB_Corner(bFill, 4)
    local knob = HB_Create("Frame", {
        Size=newUD2(0,14,0,14), Position=newUD2(initPct,-7,0.5,-7),
        BackgroundColor3=c3(250,250,250)
    }, bBg)
    HB_Corner(knob, 7)
    local hit = HB_Create("TextButton", {
        Size=newUD2(1,0,1,0), BackgroundTransparency=1, Text="",
        AutoButtonColor=false, Active=true, Selectable=false, ZIndex=50
    }, bBg)
    local dragging = false
    local function upd(x)
        local pct = clamp((x-bBg.AbsolutePosition.X)/bBg.AbsoluteSize.X, 0, 1)
        local nv = floor(mn+(mx-mn)*pct+0.5)
        bFill.Size = newUD2(pct,0,1,0)
        knob.Position = newUD2(pct,-7,0.5,-7)
        vLbl.Text = tostring(nv)..suf
        if cb then pcall(cb, nv) end
    end
    hit.InputBegan:Connect(function(input)
        if input.UserInputType == E_MOUSE1 then dragging = true; upd(input.Position.X) end
    end)
    UIS_InputEnded:Connect(function(input)
        if input.UserInputType == E_MOUSE1 then dragging = false end
    end)
    UIS_InputChanged:Connect(function(input)
        if dragging and input.UserInputType == E_MOUSEMOVE then upd(input.Position.X) end
    end)
    Cmp_reg(holder, text, nil)
end
Cmp.Button = function(parent, opts)
    local text = opts.text or "Button"
    local cb = opts.callback
    local danger = opts.danger
    local color = danger and c3(60,20,22) or Palette.Elevated
    local tc = danger and Palette.Danger or Palette.TextHigh
    local btn = HB_Create("TextButton", {
        Size=newUD2(1,0,0,38), BackgroundColor3=color,
        BorderSizePixel=0, Text="", AutoButtonColor=false, Active=true, Selectable=false
    }, parent)
    HB_Corner(btn, 8); HB_Stroke(btn, Palette.Border, 1, 0.3)
    HB_Create("TextLabel", {
        Size=newUD2(1,-28,1,0), Position=newUD2(0,14,0,0),
        BackgroundTransparency=1, Text=text,
        Font=E_GOTHAM_BOLD, TextSize=12, TextColor3=tc,
        TextXAlignment=E_TXT_LEFT
    }, btn)
    btn.Activated:Connect(function() if cb then pcall(cb) end end)
    Cmp_reg(btn, text, nil)
end
Cmp.Dropdown = function(parent, opts)
    local text = opts.text or "Option"
    local options = opts.options or {}
    local default = opts.default or options[1] or "-"
    local cb = opts.callback
    local holder = HB_Create("Frame", {
        Size=newUD2(1,0,0,40), BackgroundColor3=Palette.Elevated, BorderSizePixel=0
    }, parent)
    HB_Corner(holder, 8); HB_Stroke(holder, Palette.Border, 1, 0.3)
    HB_Create("TextLabel", {
        Size=newUD2(0.5,-14,1,0), Position=newUD2(0,14,0,0),
        BackgroundTransparency=1, Text=text,
        Font=E_GOTHAM_MED, TextSize=12, TextColor3=Palette.TextHigh,
        TextXAlignment=E_TXT_LEFT
    }, holder)
    local idx = 1
    for i = 1, #options do if options[i] == default then idx = i; break end end
    local btn = HB_Create("TextButton", {
        Size=newUD2(0.5,-14,0,26), Position=newUD2(0.5,0,0.5,-13),
        BackgroundColor3=Palette.Elevated2, BorderSizePixel=0,
        Text=default, Font=E_GOTHAM_BOLD, TextSize=11,
        TextColor3=Palette.Accent, AutoButtonColor=false,
        Active=true, Selectable=false
    }, holder)
    HB_Corner(btn, 6); HB_Stroke(btn, Palette.Border, 1, 0.4)
    btn.Activated:Connect(function()
        idx = idx + 1
        if idx > #options then idx = 1 end
        btn.Text = options[idx]
        if cb then pcall(cb, options[idx]) end
    end)
    Cmp_reg(holder, text, nil)
end
Cmp.Keybind = function(parent, opts)
    local text = opts.text or "Keybind"
    local default = opts.default or Enum.KeyCode.Q
    local cb = opts.callback
    local holder = HB_Create("Frame", {
        Size=newUD2(1,0,0,40), BackgroundColor3=Palette.Elevated, BorderSizePixel=0
    }, parent)
    HB_Corner(holder, 8); HB_Stroke(holder, Palette.Border, 1, 0.3)
    HB_Create("TextLabel", {
        Size=newUD2(0.5,-14,1,0), Position=newUD2(0,14,0,0),
        BackgroundTransparency=1, Text=text,
        Font=E_GOTHAM_MED, TextSize=12, TextColor3=Palette.TextHigh,
        TextXAlignment=E_TXT_LEFT
    }, holder)
    local kb = HB_Create("TextButton", {
        Size=newUD2(0,80,0,26), Position=newUD2(1,-94,0.5,-13),
        BackgroundColor3=Palette.Elevated2, BorderSizePixel=0,
        Text=default.Name, Font=E_CODE, TextSize=11,
        TextColor3=Palette.Accent, AutoButtonColor=false,
        Active=true, Selectable=false
    }, holder)
    HB_Corner(kb, 6); HB_Stroke(kb, Palette.Border, 1, 0.4)
    local listening = false
    kb.Activated:Connect(function() listening = true; kb.Text = "..."; kb.TextColor3 = Palette.Warning end)
    UIS_InputBegan:Connect(function(input)
        if not listening then return end
        if input.UserInputType == E_KEYBOARD then
            kb.Text = input.KeyCode.Name; kb.TextColor3 = Palette.Accent; listening = false
            if cb then pcall(cb, input.KeyCode) end
        end
    end)
    Cmp_reg(holder, text, nil)
end

local P = UI.TabContents

-- ================== AIM ==================
do local p = P["AIM/Core"]
    Cmp.Section(p, "🎯 ULTRA PRECISION AIMBOT")
    Cmp.Toggle(p, {text="Auto Flick", default=true, callback=function(v) S.AutoFlick=v end})
    Cmp.Toggle(p, {text="Pull Slot 1", default=true, desc="Sempre puxa a arma da hotbar 1 antes de atirar", callback=function(v) S.PullSlot1=v end})
    Cmp.Keybind(p, {text="Flick Key", default=S.FlickKey, callback=function(kc) S.FlickKey=kc end})
    Cmp.Slider(p, {text="Align Tolerance", min=1, max=15, default=1, suffix="°", callback=function(v) S.AlignTol=v end})
    Cmp.Slider(p, {text="Aim Smooth", min=0, max=100, default=0, suffix="%", callback=function(v) S.AimSmooth=v/100 end})
    Cmp.Section(p, "🎯 SILENT")
    Cmp.Toggle(p, {text="Silent Aim", default=true, callback=function(v) S.SilentOn=v end})
    Cmp.Toggle(p, {text="Random Aim", default=true, callback=function(v) S.RandomAim=v end})
    Cmp.Toggle(p, {text="Humanize", default=true, callback=function(v) S.Humanize=v end})
end
do local p = P["AIM/Targeting"]
    Cmp.Section(p, "🎯 ALVO")
    Cmp.Dropdown(p, {text="Prioridade", options={"murderer","closest","lowest_hp","most_dangerous"}, default="murderer", callback=function(o) S.RagePriority=o end})
    Cmp.Dropdown(p, {text="Parte", options={"Head","Torso","HumanoidRootPart","Neck"}, default="Head", callback=function(o) S.AimPart=o end})
    Cmp.Toggle(p, {text="Smart Target", default=true, callback=function(v) S.SmartTarget=v end})
    Cmp.Toggle(p, {text="Pre-Aim", default=true, callback=function(v) S.PreAim=v end})
    Cmp.Toggle(p, {text="Sticky Aim", default=true, callback=function(v) S.StickyAim=v end})
    Cmp.Slider(p, {text="Sticky Strength", min=0, max=100, default=100, suffix="%", callback=function(v) S.StickyAimStrength=v/100 end})
    Cmp.Toggle(p, {text="Threat Trajectory", default=false, callback=function(v) S.ThreatTrajectory=v end})
    Cmp.Toggle(p, {text="Head Only Lock", default=true, callback=function(v) S.HeadOnlyLock=v end})
    Cmp.Toggle(p, {text="HRP Fallback", default=false, callback=function(v) S.HRPFallback=v end})
    Cmp.Toggle(p, {text="Neck Shot", default=false, callback=function(v) S.NeckShot=v end})
    Cmp.Toggle(p, {text="Backstab Snap", default=true, callback=function(v) S.BackstabSnap=v end})
    Cmp.Toggle(p, {text="Vertical Priority", default=false, callback=function(v) S.VerticalPriority=v end})
    Cmp.Toggle(p, {text="Closest to Crosshair", default=false, callback=function(v) S.ClosestToCrosshair=v end})
end
do local p = P["AIM/Prediction"]
    Cmp.Section(p, "👁 PREDIÇÃO ULTRA (4-pass)")
    Cmp.Toggle(p, {text="Ping Compensate", default=true, callback=function(v) S.PingCompensate=v end})
    Cmp.Toggle(p, {text="Latency Prediction", default=true, callback=function(v) S.LatencyPrediction=v end})
    Cmp.Toggle(p, {text="History Tracker", default=true, callback=function(v) S.HistoryTracker=v end})
    Cmp.Slider(p, {text="History Frames", min=10, max=60, default=30, callback=function(v) S.HistoryFrames=v end})
    Cmp.Toggle(p, {text="Moving Target Predict", default=true, callback=function(v) S.MovingTargetPredict=v end})
    Cmp.Toggle(p, {text="Kalman Predict V2", default=true, callback=function(v) S.KalmanPredictV2=v end})
    Cmp.Slider(p, {text="Kalman Tempo", min=1, max=100, default=15, suffix=" ×10ms", callback=function(v) S.KalmanPredTime=v/100 end})
    Cmp.Toggle(p, {text="Juke Counter", default=true, callback=function(v) S.JukeCounter=v end})
    Cmp.Toggle(p, {text="Velocity Match", default=false, callback=function(v) S.VelocityMatch=v end})
    Cmp.Toggle(p, {text="Strafe Detector", default=true, callback=function(v) S.StrafeDetector=v end})
    Cmp.Toggle(p, {text="Jump Predictor", default=true, callback=function(v) S.JumpPredictor=v end})
    Cmp.Toggle(p, {text="Crouch Detector", default=true, callback=function(v) S.CrouchDetector=v end})
    Cmp.Toggle(p, {text="First-Visual Lock", default=false, callback=function(v) S.FirstVisualLock=v end})
end
do local p = P["AIM/TriggerBot"]
    Cmp.Section(p, "⚡ TRIGGER BOT")
    Cmp.Toggle(p, {text="Trigger Bot", default=false, callback=function(v) S.TrigOn=v end})
    Cmp.Slider(p, {text="Radius", min=10, max=200, default=60, suffix=" px", callback=function(v) S.TrigRad=v end})
    Cmp.Slider(p, {text="Cooldown", min=1, max=100, default=35, suffix=" ×10ms", callback=function(v) S.TrigCD=v/100 end})
end
do local p = P["AIM/Anti-Detect"]
    Cmp.Section(p, "🛡 ANTI-DETECT (RAGE: tudo OFF)")
    Cmp.Toggle(p, {text="Rate Limiter", default=false, callback=function(v) S.RateLimit=v end})
    Cmp.Toggle(p, {text="Fake Miss", default=false, callback=function(v) S.FakeMiss=v end})
    Cmp.Toggle(p, {text="Anti-Flick Block", default=false, callback=function(v) S.AntiFlickBlock=v end})
    Cmp.Slider(p, {text="Anti-Flick Backoff", min=0, max=10, default=2, suffix=" s", callback=function(v) S.AntiFlickBackoff=v end})
    Cmp.Toggle(p, {text="Post-Kill Delay", default=false, callback=function(v) S.PostKillDelay=v end})
    Cmp.Slider(p, {text="Post-Kill Delay", min=100, max=1000, default=400, suffix=" ms", callback=function(v) S.PostKillDelayMs=v end})
end
do local p = P["AIM/Locks"]
    Cmp.Section(p, "🔒 TRAVAS")
    Cmp.Toggle(p, {text="Single Shot Lock", default=false, callback=function(v) S.SingleShotLock=v end})
    Cmp.Toggle(p, {text="Single Kill Lock", default=false, callback=function(v) S.SingleKillLock=v end})
    Cmp.Slider(p, {text="Cooldown pós-kill", min=0, max=200, default=35, suffix=" ×10ms", callback=function(v) S.KillCooldown=v/100 end})
    Cmp.Toggle(p, {text="Anti-Double Fire", default=false, callback=function(v) S.AntiDoubleFire=v end})
    Cmp.Toggle(p, {text="Anti-Chain Flick", default=false, callback=function(v) S.AntiChainFlick=v end})
    Cmp.Toggle(p, {text="Hold-to-Flick", default=false, callback=function(v) S.HoldToFlick=v end})
    Cmp.Toggle(p, {text="Tap-to-Flick", default=false, callback=function(v) S.TapToFlick=v end})
    Cmp.Slider(p, {text="Tap Max Time", min=5, max=50, default=15, suffix=" ×10ms", callback=function(v) S.TapMaxTime=v/100 end})
    Cmp.Toggle(p, {text="Cooldown Visual", default=false, callback=function(v) S.ShowCooldownVisual=v end})
end

-- ================== FLICK ==================
do local p = P["FLICK/Timings"]
    Cmp.Section(p, "⚔ TIMINGS (RAGE)")
    Cmp.Slider(p, {text="Snap (câmera vai)", min=10, max=100, default=14, suffix="ms", callback=function(v) Flick.snapDur=v/1000 end})
    Cmp.Slider(p, {text="Hold", min=30, max=300, default=30, suffix="ms", callback=function(v) Flick.holdDur=v/1000 end})
    Cmp.Slider(p, {text="Verify", min=150, max=800, default=150, suffix="ms", callback=function(v) Flick.verifyWait=v/1000 end})
    Cmp.Slider(p, {text="Return (câmera volta)", min=30, max=300, default=35, suffix="ms", callback=function(v) Flick.returnDur=v/1000 end})
end
do local p = P["FLICK/Pro"]
    Cmp.Section(p, "🎬 PRO (RAGE: tudo OFF)")
    Cmp.Toggle(p, {text="Modo Pro", default=false, callback=function(v) Flick.proMode=v end})
    Cmp.Toggle(p, {text="Reaction Delay", default=false, callback=function(v) Flick.reactionDelay = v and 0.040 or 0 end})
    Cmp.Slider(p, {text="Reaction (ms)", min=0, max=150, default=0, callback=function(v) Flick.reactionDelay=v/1000 end})
    Cmp.Toggle(p, {text="Pre-Dip", default=false, callback=function(v) Flick.preDipEnabled=v end})
    Cmp.Toggle(p, {text="Atirar no Pico", default=true, callback=function(v) Flick.fireAtPeak=v end})
    Cmp.Toggle(p, {text="Overshoot Adaptativo", default=false, callback=function(v) Flick.adaptiveOvershoot=v end})
    Cmp.Slider(p, {text="Overshoot", min=0, max=150, default=10, suffix=" ‰", callback=function(v) Flick.overshootPct=v/1000 end})
    Cmp.Toggle(p, {text="Recoil + Settle", default=false, callback=function(v) Flick.recoilEnabled=v end})
    Cmp.Slider(p, {text="Recoil", min=0, max=80, default=0, callback=function(v) Flick.recoilAmount=v/1000 end})
    Cmp.Slider(p, {text="Micro-Jitter", min=0, max=50, default=0, callback=function(v) Flick.microJitter=v/10 end})
    Cmp.Slider(p, {text="Jitter Rate (Hz)", min=10, max=80, default=10, callback=function(v) Flick.microJitterRate=v end})
end
do local p = P["FLICK/1-Shot"]
    Cmp.Section(p, "🎯 ULTRA PRECISION ONE SHOT")
    Cmp.Toggle(p, {text="One Shot Perfeito", default=true,
        desc="4 tentativas progressivas + 20 pts LOS + predição iterativa 3-pass",
        callback=function(v) S.OneShotPerfect=v end})
    Cmp.Toggle(p, {text="Lead + Ping Suavizado", default=true,
        desc="Cinemática completa (p+v·t+½·a·t²) + ping médio de 8 amostras",
        callback=function(v) S.OneShotLead=v end})
    Cmp.Toggle(p, {text="Gravidade", default=true,
        desc="Compensa queda de bala em armas não-hitscan",
        callback=function(v) S.OneShotGravity=v end})
    Cmp.Toggle(p, {text="Adaptativo (decay)", default=true,
        desc="Aprende offset com decaimento temporal (miss antigo pesa menos)",
        callback=function(v) S.OneShotAdaptive=v end})
    Cmp.Section(p, "🎯 LOS LOCK (100% ACCURACY)")
    Cmp.Button(p, {text="ℹ️ Como funciona o LOS Lock?", callback=function()
        HB_Toast("3 passes → head LOS → hrp → 20 multipoint → 4 tries", "info")
    end})
    Cmp.Section(p, "⚙ AJUSTES")
    Cmp.Toggle(p, {text="One Shot (1 bala)", default=true, callback=function(v) Flick.oneShot=v end})
    Cmp.Slider(p, {text="Post-Shot Settle (ms)", min=0, max=200, default=0, callback=function(v) Flick.postShotSettle=v/1000 end})
end
do local p = P["FLICK/Advanced"]
    Cmp.Section(p, "⚙ CURVAS (RAGE: tudo OFF)")
    Cmp.Toggle(p, {text="Multi-Step Snap", default=false, callback=function(v) S.Adv_MultiStepSnap=v end})
    Cmp.Slider(p, {text="Steps", min=2, max=6, default=3, callback=function(v) S.Adv_MultiStepN=v end})
    Cmp.Toggle(p, {text="Bezier Snap", default=false, callback=function(v) S.Adv_BezierSnap=v end})
    Cmp.Slider(p, {text="Bezier P1", min=0, max=100, default=25, callback=function(v) S.Adv_BezierP1=v/100 end})
    Cmp.Slider(p, {text="Bezier P2", min=0, max=100, default=75, callback=function(v) S.Adv_BezierP2=v/100 end})
    Cmp.Toggle(p, {text="Spline Flick", default=false, callback=function(v) S.Adv_SplineFlick=v end})
    Cmp.Toggle(p, {text="Ballistic Arc", default=false, callback=function(v) S.Adv_BallisticArc=v end})
    Cmp.Toggle(p, {text="Micro-Jitter Return", default=false, callback=function(v) S.Adv_MicroJitterRet=v end})
    Cmp.Slider(p, {text="Jitter Amount", min=1, max=50, default=5, callback=function(v) S.Adv_MicroJitterAmt=v/10 end})
    Cmp.Toggle(p, {text="Trailing Kill", default=false, callback=function(v) S.Adv_TrailingKill=v end})
    Cmp.Toggle(p, {text="Focus Zoom", default=false, callback=function(v) S.Adv_FocusZoom=v end})
    Cmp.Toggle(p, {text="Priority Switch", default=true, callback=function(v) S.Adv_PrioritySwitch=v end})
    Cmp.Toggle(p, {text="Perfect Return", default=true, callback=function(v) S.Adv_PerfectReturn=v end})
    Cmp.Toggle(p, {text="Adaptive Curve", default=false, callback=function(v) S.Adv_AdaptiveCurve=v end})
    Cmp.Toggle(p, {text="Cancel Window", default=false, callback=function(v) S.Adv_CancelWindow=v end})
    Cmp.Slider(p, {text="Cancel Window", min=1, max=20, default=3, suffix=" ms", callback=function(v) S.Adv_CancelMs=v end})
end
do local p = P["FLICK/WallCheck"]
    Cmp.Section(p, "🧱 WALL CHECK (RAGE: OFF)")
    Cmp.Toggle(p, {text="Wall Check (LOS)", default=false, callback=function(v) S.WallCheck=v end})
    Cmp.Slider(p, {text="Distância Máx", min=100, max=5000, default=5000, suffix=" st", callback=function(v) S.FlickMaxDist=v end})
end
do local p = P["FLICK/Camera"]
    Cmp.Section(p, "🎥 CÂMERA (RAGE: Off)")
    Cmp.Dropdown(p, {text="Modo", options={"Safe","Off","Full"}, default="Off", callback=function(o) S.FlickCameraMode=o end})
    Cmp.Button(p, {text="🔧 Reset Câmera Agora", callback=function() HB_ForceRestoreCamera(); HB_Toast("Reset","success") end})
    Cmp.Section(p, "🛡️ ANTI-VOID")
    Cmp.Toggle(p, {text="Anti-Void", default=true, callback=function(v) S.AntiVoid=v end})
    Cmp.Slider(p, {text="Y Threshold", min=-300, max=0, default=-50, callback=function(v) S.AntiVoidYThresh=v end})
    Cmp.Slider(p, {text="Lift", min=3, max=30, default=8, callback=function(v) S.AntiVoidLift=v end})
end
do local p = P["FLICK/Modes"]
    Cmp.Section(p, "🎬 MODOS")
    Cmp.Button(p, {text="🥷 Ninja (20/30)", callback=function() HB_ApplyPreset("PRO_CLIP") end})
    Cmp.Button(p, {text="🎬 Hollywood", callback=function()
        Flick.snapDur=0.080 Flick.returnDur=0.120 Flick.overshootPct=0.15; HB_Toast("Hollywood","success") end})
    Cmp.Button(p, {text="✨ Strobe (20/30)", danger=true, callback=function()
        Flick.snapDur=0.020 Flick.returnDur=0.030; HB_Toast("Strobe","warning") end})
    Cmp.Button(p, {text="🗡 Assassin (20/30)", callback=function() HB_ApplyPreset("RAGE_PRO") end})
    Cmp.Button(p, {text="⚡ Speedrun (15/20)", danger=true, callback=function()
        Flick.snapDur=0.015 Flick.returnDur=0.020; HB_Toast("Speedrun","danger") end})
    Cmp.Button(p, {text="👤 Legit", callback=function()
        Flick.snapDur=0.055 Flick.returnDur=0.085 Flick.overshootPct=0.030; HB_Toast("Legit","success") end})
    Cmp.Button(p, {text="🔥 RAGE + ULTRA PRECISION", danger=true, callback=function()
        Flick.proMode=false
        Flick.snapDur=0.014 Flick.holdDur=0.030 Flick.verifyWait=0.150 Flick.returnDur=0.035
        Flick.microJitter=0 Flick.recoilEnabled=false Flick.preDipEnabled=false
        Flick.adaptiveOvershoot=false Flick.reactionDelay=0 Flick.postShotSettle=0
        S.AntiFlickBlock=false S.RateLimit=false S.FakeMiss=false S.PostKillDelay=false
        S.WallCheck=false S.FlickMaxDist=5000 S.FlickCameraMode="Off"
        S.OneShotPerfect=true S.OneShotLead=true S.OneShotGravity=true S.OneShotAdaptive=true
        HB_Toast("RAGE + ULTRA PRECISION aplicado","danger") end})
end

-- ================== ESP ==================
do local p = P["ESP/Basic"]
    Cmp.Section(p, "◉ ESP (RAGE: ON)")
    Cmp.Toggle(p, {text="ESP ATIVADO", default=true, callback=function(v) S.ESP=v end})
    Cmp.Toggle(p, {text="Box", default=true, callback=function(v) S.ESPBox=v end})
    Cmp.Toggle(p, {text="Tracer", default=true, callback=function(v) S.ESPTracer=v end})
    Cmp.Slider(p, {text="Espessura", min=1, max=6, default=2, callback=function(v) S.ESPThick=v end})
end
do local p = P["ESP/Info"]
    Cmp.Section(p, "◉ INFO")
    Cmp.Toggle(p, {text="Nome + Role", default=true, callback=function(v) S.ESPName=v end})
    Cmp.Toggle(p, {text="Distância", default=true, callback=function(v) S.ESPDist=v end})
    Cmp.Toggle(p, {text="Health Bar", default=true, callback=function(v) S.ESPHealth=v end})
    Cmp.Toggle(p, {text="Weapon", default=false, callback=function(v) S.ESPWeapon=v end})
end
do local p = P["ESP/Filter"]
    Cmp.Section(p, "◉ FILTRO (RAGE: ver tudo)")
    Cmp.Toggle(p, {text="Mostrar Innocents", default=true, callback=function(v) S.ESPShowInnocents=v end})
    Cmp.Toggle(p, {text="Mostrar Sheriff", default=true, callback=function(v) S.ESPShowSheriff=v end})
    Cmp.Button(p, {text="🔄 Refresh Roles", callback=function()
        for k in pairs_(RoleCache) do RoleCache[k]=nil end
        RoleCacheTime = 0
        HB_Toast("Roles atualizados","success")
    end})
end
do local p = P["ESP/Visual"]
    Cmp.Section(p, "◉ VISUAL (RAGE: Chams+Radar+Timeline ON)")
    Cmp.Toggle(p, {text="Fill (fundo)", default=false, callback=function(v) S.ESPFill=v end})
    Cmp.Slider(p, {text="Fill Transparency", min=0, max=100, default=80, suffix="%", callback=function(v) S.ESPFillTransparency=v/100 end})
    Cmp.Toggle(p, {text="Chams (Highlight)", default=true, callback=function(v) S.Chams=v end})
    Cmp.Toggle(p, {text="Radar", default=true, callback=function(v) S.Radar=v end})
    Cmp.Toggle(p, {text="Timeline Predictor", default=true, callback=function(v) S.TimelinePredictor=v end})
end
do local p = P["ESP/GunDrop"]
    Cmp.Section(p, "🔫 GUN DROP ESP")
    Cmp.Toggle(p, {text="Gun Drop ESP Ativado", default=true,
        desc="Destaca a arma caída do Sheriff (atravessa paredes)",
        callback=function(v) S.GunDropESP=v end})
    Cmp.Toggle(p, {text="Mostrar Texto 'ARMA CAÍDA'", default=true,
        callback=function(v) S.GunDropESPText=v end})
    Cmp.Toggle(p, {text="Mostrar Distância", default=true,
        callback=function(v) S.GunDropESPDistance=v end})
    Cmp.Section(p, "🎨 VISUAL")
    Cmp.Slider(p, {text="Fill Transparency", min=0, max=100, default=50, suffix="%",
        callback=function(v) S.GunDropESPFill=v/100; _G.HB.RefreshGunDropESP() end})
    Cmp.Slider(p, {text="Outline Transparency", min=0, max=100, default=30, suffix="%",
        callback=function(v) S.GunDropESPOutlineT=v/100; _G.HB.RefreshGunDropESP() end})
    Cmp.Button(p, {text="🟡 Amarelo Dourado (padrão)", callback=function()
        S.GunDropESPColor=c3(255,210,40) S.GunDropESPOutline=c3(255,255,255)
        S.GunDropESPTextColor=c3(255,210,40)
        if _G.HB.RefreshGunDropESP then _G.HB.RefreshGunDropESP() end
    end})
    Cmp.Button(p, {text="🔴 Vermelho", callback=function()
        S.GunDropESPColor=c3(255,60,60) S.GunDropESPOutline=c3(255,255,255)
        S.GunDropESPTextColor=c3(255,120,120)
        if _G.HB.RefreshGunDropESP then _G.HB.RefreshGunDropESP() end
    end})
    Cmp.Button(p, {text="🟢 Verde Neon", callback=function()
        S.GunDropESPColor=c3(0,255,120) S.GunDropESPOutline=c3(255,255,255)
        S.GunDropESPTextColor=c3(120,255,180)
        if _G.HB.RefreshGunDropESP then _G.HB.RefreshGunDropESP() end
    end})
    Cmp.Button(p, {text="💜 Roxo", callback=function()
        S.GunDropESPColor=c3(200,80,255) S.GunDropESPOutline=c3(255,255,255)
        S.GunDropESPTextColor=c3(220,140,255)
        if _G.HB.RefreshGunDropESP then _G.HB.RefreshGunDropESP() end
    end})
    Cmp.Button(p, {text="🌈 Arco-íris (ciclo)", callback=function()
        task.spawn(function()
            local hue = 0
            while S.GunDropESP do
                hue = (hue + 0.02) % 1
                S.GunDropESPColor = Color3.fromHSV(hue, 1, 1)
                S.GunDropESPTextColor = Color3.fromHSV(hue, 0.7, 1)
                if _G.HB.RefreshGunDropESP then _G.HB.RefreshGunDropESP() end
                task.wait(0.05)
            end
        end)
    end})
    Cmp.Section(p, "ℹ️ INFO")
    Cmp.Button(p, {text="🔍 Forçar Refresh Agora", callback=function()
        if HB_GunDrop and HB_GunDrop.active then HB_GunDrop.active = nil end
        HB_Toast("GunDrop ESP atualizado", "success")
    end})
end

-- ================== VISUAL ==================
do local p = P["VISUAL/HUD"]
    Cmp.Section(p, "✦ HUD")
    Cmp.Toggle(p, {text="Hitmarker", default=true, callback=function(v) S.Hitmark=v end})
    Cmp.Toggle(p, {text="Kill Feed", default=true, callback=function(v) S.KillFeed=v end})
    Cmp.Toggle(p, {text="Crosshair", default=false, callback=function(v) S.Cross=v end})
    Cmp.Toggle(p, {text="Impact Flash", default=true, callback=function(v) S.FB_ImpactFlash=v end})
end
do local p = P["VISUAL/Crosshair"]
    Cmp.Section(p, "✦ CROSSHAIR (SHARINGAN)")
    Cmp.Toggle(p, {text="Crosshair Ativado", default=false, callback=function(v)
        S.Cross=v
        if HB_BuildCrosshair then HB_BuildCrosshair() end
    end})
    Cmp.Dropdown(p, {text="Estilo", options={"Sharingan","Dot","Cross","Circle","Hybrid"}, default="Sharingan",
        callback=function(o)
            S.CrossStyle=o
            if HB_BuildCrosshair then HB_BuildCrosshair() end
        end})
    Cmp.Slider(p, {text="Tamanho", min=10, max=60, default=24, callback=function(v)
        S.CrossSize=v
        if HB_BuildCrosshair then HB_BuildCrosshair() end
    end})
    Cmp.Toggle(p, {text="Seguir Mouse (esconde cursor)", default=true, callback=function(v) S.CrossFollowMouse=v end})
    Cmp.Section(p, "⚡ ATALHOS")
    Cmp.Button(p, {text="🍥 Ativar Sharingan (24px)", callback=function()
        S.Cross=true S.CrossStyle="Sharingan" S.CrossSize=24 S.CrossFollowMouse=true
        if HB_BuildCrosshair then HB_BuildCrosshair() end
        HB_Toast("Sharingan ativado!", "success")
    end})
    Cmp.Button(p, {text="🍥 Ativar Sharingan Grande (40px)", callback=function()
        S.Cross=true S.CrossStyle="Sharingan" S.CrossSize=40 S.CrossFollowMouse=true
        if HB_BuildCrosshair then HB_BuildCrosshair() end
        HB_Toast("Sharingan 40px ativado!", "success")
    end})
    Cmp.Button(p, {text="❌ Desativar Crosshair", danger=true, callback=function()
        S.Cross=false
        if HB_BuildCrosshair then HB_BuildCrosshair() end
        HB_Toast("Crosshair desativado", "warning")
    end})
end
do local p = P["VISUAL/ReShade"]
    Cmp.Section(p, "🎨 RESHADE")
    Cmp.Toggle(p, {text="ReShade Ativado", default=true, callback=function(v)
        HB_Visuals.enabled=v
        if v then HB_ApplyVisuals() else HB_RemoveVisuals() end
    end})
    Cmp.Dropdown(p, {text="Preset", options={"Tryhard","Cinematic","Clean"}, default="Tryhard",
        callback=function(o) HB_Visuals.preset=o; HB_ApplyVisuals() end})
    Cmp.Slider(p, {text="Saturação", min=0, max=100, default=22, suffix="%", callback=function(v) HB_Visuals.saturation=v/100; HB_ApplyVisuals() end})
    Cmp.Slider(p, {text="Contraste", min=0, max=100, default=18, suffix="%", callback=function(v) HB_Visuals.contrast=v/100; HB_ApplyVisuals() end})
    Cmp.Slider(p, {text="Bloom", min=0, max=200, default=55, suffix="%", callback=function(v) HB_Visuals.bloomIntensity=v/100; HB_ApplyVisuals() end})
    Cmp.Toggle(p, {text="Atmosphere", default=true, callback=function(v) HB_Visuals.atmosphereEnabled=v; HB_ApplyVisuals() end})
end
do local p = P["VISUAL/Tracers"]
    Cmp.Section(p, "🎯 TRACERS")
    Cmp.Toggle(p, {text="Tracer Ativado", default=true, callback=function(v) HB_Tracer.enabled=v end})
    Cmp.Toggle(p, {text="Tracer em Faca", default=true, callback=function(v) HB_Tracer.ignoreHitscan=v end})
    Cmp.Slider(p, {text="Duração", min=5, max=100, default=40, suffix=" ×10ms", callback=function(v) HB_Tracer.lifetime=v/100 end})
    Cmp.Slider(p, {text="Espessura", min=1, max=50, default=25, suffix=" ×10px", callback=function(v) HB_Tracer.thickness=v/10 end})
    Cmp.Slider(p, {text="Brilho", min=0, max=100, default=60, callback=function(v) HB_Tracer.glowBright=v/10 end})
end
do local p = P["VISUAL/KillFX"]
    Cmp.Section(p, "🎊 KILL EFFECTS")
    Cmp.Toggle(p, {text="Confete Ativado", default=true, callback=function(v) HB_KillEffects.enabled=v end})
    Cmp.Slider(p, {text="Partículas", min=20, max=200, default=70, callback=function(v) HB_KillEffects.burstCount=v end})
    Cmp.Slider(p, {text="Explosão", min=5, max=80, default=25, callback=function(v) HB_KillEffects.explosionY=v end})
end
do local p = P["VISUAL/Screen"]
    Cmp.Section(p, "🖥️ SCREEN STRETCH")
    Cmp.Toggle(p, {text="Screen Stretch Ativado", default=false,
        desc="Ajusta o FOV pra deixar os alvos maiores (estilo 4:3 CS)",
        callback=function(v)
            S.ScreenStretch=v
            HB_ApplyScreenStretch()
            HB_Toast("Stretch "..(v and "ON" or "OFF"), v and "success" or "warning")
        end})
    Cmp.Dropdown(p, {text="Preset", default="4:3 Stretch",
        options={"Normal","4:3 Stretch","5:4 Stretch","16:10 Stretch","21:9 Wide","Rage Zoom","Ultra Rage","Custom"},
        callback=function(o)
            S.ScreenStretchPreset = o
            if o ~= "Custom" then
                S.ScreenStretch = true
                S.ScreenStretchFOV = HB_ScreenPresets[o] or 70
            end
            HB_ApplyScreenStretch()
            HB_Toast("Preset: "..o, "success")
        end})
    Cmp.Section(p, "🎛️ CUSTOM")
    Cmp.Slider(p, {text="FOV Custom", min=20, max=120, default=52,
        callback=function(v)
            S.ScreenStretchPreset = "Custom"
            S.ScreenStretchFOV = v
            S.ScreenStretch = true
            HB_ApplyScreenStretch()
        end})
    Cmp.Section(p, "📐 PRESETS RÁPIDOS")
    Cmp.Button(p, {text="🎮 Normal (FOV 70)", callback=function()
        S.ScreenStretch=true S.ScreenStretchPreset="Normal" S.ScreenStretchFOV=70
        HB_ApplyScreenStretch(); HB_Toast("Normal", "success") end})
    Cmp.Button(p, {text="📺 4:3 Stretch (FOV 52) ⭐", danger=true, callback=function()
        S.ScreenStretch=true S.ScreenStretchPreset="4:3 Stretch" S.ScreenStretchFOV=52
        HB_ApplyScreenStretch(); HB_Toast("4:3 RAGE", "danger") end})
    Cmp.Button(p, {text="📺 5:4 Stretch (FOV 58)", callback=function()
        S.ScreenStretch=true S.ScreenStretchPreset="5:4 Stretch" S.ScreenStretchFOV=58
        HB_ApplyScreenStretch(); HB_Toast("5:4 Stretch", "success") end})
    Cmp.Button(p, {text="📺 16:10 Stretch (FOV 63)", callback=function()
        S.ScreenStretch=true S.ScreenStretchPreset="16:10 Stretch" S.ScreenStretchFOV=63
        HB_ApplyScreenStretch(); HB_Toast("16:10 Stretch", "success") end})
    Cmp.Button(p, {text="🌌 21:9 Wide (FOV 95)", callback=function()
        S.ScreenStretch=true S.ScreenStretchPreset="21:9 Wide" S.ScreenStretchFOV=95
        HB_ApplyScreenStretch(); HB_Toast("21:9 Wide", "success") end})
    Cmp.Button(p, {text="🔥 Rage Zoom (FOV 42)", danger=true, callback=function()
        S.ScreenStretch=true S.ScreenStretchPreset="Rage Zoom" S.ScreenStretchFOV=42
        HB_ApplyScreenStretch(); HB_Toast("RAGE ZOOM", "danger") end})
    Cmp.Button(p, {text="💀 Ultra Rage (FOV 32)", danger=true, callback=function()
        S.ScreenStretch=true S.ScreenStretchPreset="Ultra Rage" S.ScreenStretchFOV=32
        HB_ApplyScreenStretch(); HB_Toast("ULTRA RAGE", "danger") end})
    Cmp.Section(p, "🔄 RESET")
    Cmp.Button(p, {text="🔄 Reset Tela (FOV 70)", danger=true, callback=function()
        HB_ResetScreenStretch()
        HB_Toast("Tela resetada", "warning") end})
    Cmp.Section(p, "ℹ️ INFO")
    Cmp.Button(p, {text="ℹ️ O que é Screen Stretch?", callback=function()
        HB_Toast("FOV baixo = alvos maiores na tela. Ideal 4:3 = FOV 52", "info")
    end})
end

-- ================== IA ==================
do local p = P["IA/Core"]
    Cmp.Section(p, "◈ IA CORE (RAGE: OFF)")
    Cmp.Toggle(p, {text="IA On", default=false, callback=function(v) S.AIOn=v end})
    Cmp.Slider(p, {text="NN Rate", min=1, max=50, default=10, suffix=" ‰", callback=function(v) S.NNRate=v/1000 end})
end
do local p = P["IA/RevIA"]
    Cmp.Section(p, "⚡ REV IA (RAGE: tudo OFF)")
    local list = {{"Meta-Learning","meta"},{"NAS","nas"},{"Behavioural Cloning","cloning"},
        {"Self-Play","selfPlay"},{"World Model","worldModel"},{"Active Inference","activeInf"},
        {"Transformer","transformer"},{"MoE","moe"},{"Uncertainty","uncert"},{"Causal","causal"},
        {"Counterfactual","counterfact"},{"Adversarial","adversarial"},{"Transfer","transfer"},
        {"Federated","federated"},{"Lifelong","lifelong"}}
    for i = 1, #list do
        local it = list[i]
        Cmp.Toggle(p, {text=it[1], default=false, callback=function(v) S.REV_AI[it[2]]=v end})
    end
end
do local p = P["IA/RevHuman"]
    Cmp.Section(p, "🧠 HUMANA (RAGE: OFF)")
    Cmp.Toggle(p, {text="Warmup", default=false, callback=function(v) S.REV_HUMAN.warmup=v end})
    Cmp.Toggle(p, {text="Emotion", default=false, callback=function(v) S.REV_HUMAN.emotion=v end})
    Cmp.Toggle(p, {text="Cognitive", default=false, callback=function(v) S.REV_HUMAN.cognitive=v end})
    Cmp.Toggle(p, {text="Fatigue", default=false, callback=function(v) S.REV_HUMAN.fatigue=v end})
    Cmp.Toggle(p, {text="Squad", default=false, callback=function(v) S.REV_HUMAN.squad=v end})
    Cmp.Toggle(p, {text="Reputation", default=false, callback=function(v) S.REV_HUMAN.reputation=v end})
    Cmp.Toggle(p, {text="Alt Detect", default=false, callback=function(v) S.REV_HUMAN.altDetect=v end})
end
do local p = P["IA/RevPhys"]
    Cmp.Section(p, "⚙ FÍSICA (RAGE: OFF)")
    Cmp.Toggle(p, {text="Ballistic", default=false, callback=function(v) S.REV_PHYS.ballistic=v end})
    Cmp.Toggle(p, {text="IK", default=false, callback=function(v) S.REV_PHYS.ik=v end})
    Cmp.Toggle(p, {text="Anim Mirror", default=false, callback=function(v) S.REV_PHYS.animMirror=v end})
    Cmp.Toggle(p, {text="Recon", default=false, callback=function(v) S.REV_PHYS.gameStateRecon=v end})
    Cmp.Toggle(p, {text="Server Mirror", default=false, callback=function(v) S.REV_PHYS.serverMirror=v end})
    Cmp.Toggle(p, {text="Jitter Buffer", default=false, callback=function(v) S.REV_PHYS.jitterBuf=v end})
end
do local p = P["IA/RevSocial"]
    Cmp.Section(p, "🎭 SOCIAL (RAGE: OFF)")
    Cmp.Toggle(p, {text="Anti-Attribution", default=false, callback=function(v) S.REV_SOCIAL.antiAttr=v end})
    Cmp.Toggle(p, {text="Misdirect", default=false, callback=function(v) S.REV_SOCIAL.misdirect=v end})
    Cmp.Toggle(p, {text="Bait", default=false, callback=function(v) S.REV_SOCIAL.bait=v end})
    Cmp.Toggle(p, {text="Anti-Report", default=false, callback=function(v) S.REV_SOCIAL.antiReport=v end})
    Cmp.Toggle(p, {text="Skill Curve", default=false, callback=function(v) S.REV_SOCIAL.skillCurve=v end})
end
do local p = P["IA/RevArch"]
    Cmp.Section(p, "🔧 ARQUITETURA (RAGE: OFF)")
    Cmp.Toggle(p, {text="Rollback", default=false, callback=function(v) S.REV_ARCH.rollback=v end})
    Cmp.Toggle(p, {text="Diff Sync", default=false, callback=function(v) S.REV_ARCH.diffSync=v end})
end
do local p = P["IA/RevFeat"]
    Cmp.Section(p, "💫 FEATURES (RAGE: OFF)")
    Cmp.Toggle(p, {text="What-If", default=false, callback=function(v) S.REV_FEAT.whatIf=v end})
    Cmp.Toggle(p, {text="Forecast", default=false, callback=function(v) S.REV_FEAT.forecast=v end})
    Cmp.Toggle(p, {text="Director", default=false, callback=function(v) S.REV_FEAT.director=v end})
    Cmp.Toggle(p, {text="Blockchain", default=false, callback=function(v) S.REV_FEAT.blockchain=v end})
end
do local p = P["IA/RevGame"]
    Cmp.Section(p, "🎮 GAMEPLAY (RAGE: OFF)")
    Cmp.Toggle(p, {text="Multi-Round", default=false, callback=function(v) S.REV_GAME.multiRound=v end})
    Cmp.Toggle(p, {text="Meta-Game", default=false, callback=function(v) S.REV_GAME.metaGame=v end})
    Cmp.Toggle(p, {text="Role Rotation", default=false, callback=function(v) S.REV_GAME.roleRot=v end})
    Cmp.Toggle(p, {text="Legendary", default=false, callback=function(v) S.REV_GAME.legendary=v end})
end
do local p = P["IA/RevStealth"]
    Cmp.Section(p, "🛡 STEALTH (RAGE: OFF)")
    Cmp.Toggle(p, {text="Adversarial Noise", default=false, callback=function(v) S.REV_STEALTH.advExamples=v end})
    Cmp.Toggle(p, {text="Jitter Dist", default=false, callback=function(v) S.REV_STEALTH.jitterDist=v end})
    Cmp.Toggle(p, {text="Anti-Anti-Cheat", default=false, callback=function(v) S.REV_STEALTH.antiAntiCheat=v end})
    Cmp.Toggle(p, {text="Adaptive Rate", default=false, callback=function(v) S.REV_STEALTH.adaptiveRate=v end})
    Cmp.Toggle(p, {text="Plausible", default=false, callback=function(v) S.REV_STEALTH.plausible=v end})
end
do local p = P["IA/RevMad"]
    Cmp.Section(p, "🌀 MAD (RAGE: OFF)")
    Cmp.Toggle(p, {text="Neuro-Sym", default=false, callback=function(v) S.REV_MAD.neuroSym=v end})
    Cmp.Toggle(p, {text="Quantum", default=false, callback=function(v) S.REV_MAD.quantum=v end})
    Cmp.Toggle(p, {text="Evolutionary", default=false, callback=function(v) S.REV_MAD.evolutionary=v end})
    Cmp.Toggle(p, {text="Swarm", default=false, callback=function(v) S.REV_MAD.swarm=v end})
    Cmp.Toggle(p, {text="Digital Twin", default=false, callback=function(v) S.REV_MAD.digitalTwin=v end})
    Cmp.Toggle(p, {text="Sleep/Wake", default=false, callback=function(v) S.REV_MAD.sleepWake=v end})
    Cmp.Toggle(p, {text="Curriculum", default=false, callback=function(v) S.REV_MAD.curriculum=v end})
    Cmp.Toggle(p, {text="Dream", default=false, callback=function(v) S.REV_MAD.dreamState=v end})
    Cmp.Toggle(p, {text="Recursive", default=false, callback=function(v) S.REV_MAD.recursive=v end})
end

-- ================== SPEED ==================
do local p = P["SPEED/Base"]
    Cmp.Section(p, "⚡ BASE (RAGE)")
    Cmp.Slider(p, {text="Snap (ms)", min=15, max=500, default=15, suffix="ms", callback=function(v) Flick.snapDur=v/1000 end})
    Cmp.Slider(p, {text="Return (ms)", min=15, max=500, default=35, suffix="ms", callback=function(v) Flick.returnDur=v/1000 end})
end
do local p = P["SPEED/Advanced"]
    Cmp.Section(p, "🚀 AVANÇADO (RAGE: tudo ON)")
    Cmp.Toggle(p, {text="Sub-1ms Snap (20ms)", default=true, callback=function(v) S.Sub1msSnap=v end})
    Cmp.Toggle(p, {text="Dynamic Snap Speed", default=true, callback=function(v) S.DynamicSnapSpeed=v end})
    Cmp.Toggle(p, {text="Adaptive Snap Distância", default=true, callback=function(v) S.AdaptiveSnapDist=v end})
    Cmp.Toggle(p, {text="Progressive Return", default=true, callback=function(v) S.ProgressiveReturn=v end})
    Cmp.Toggle(p, {text="Zero Return Teleport", default=true, callback=function(v) S.ZeroReturnTeleport=v end})
    Cmp.Toggle(p, {text="Multi-Snap Steps", default=true, callback=function(v) S.MultiSnapSteps=v end})
    Cmp.Toggle(p, {text="Rage Burst Mode", default=true, callback=function(v) S.RageBurstMode=v end})
    Cmp.Toggle(p, {text="Slow-Mo Flick", default=false, callback=function(v) S.SlowMoFlick=v end})
end

-- ================== MODES ==================
do local p = P["MODES/FlickModes"]
    Cmp.Section(p, "🎬 MODOS DE FLICK")
    Cmp.Button(p, {text="🥷 Ninja (20/30)", callback=function() HB_ApplyPreset("PRO_CLIP") end})
    Cmp.Button(p, {text="🎬 Hollywood", callback=function()
        Flick.snapDur=0.080 Flick.returnDur=0.120 Flick.overshootPct=0.15; HB_Toast("Hollywood","success") end})
    Cmp.Button(p, {text="✨ Strobe", danger=true, callback=function()
        Flick.snapDur=0.020 Flick.returnDur=0.030; HB_Toast("Strobe","warning") end})
    Cmp.Button(p, {text="🗡 Assassin", callback=function() HB_ApplyPreset("RAGE_PRO") end})
    Cmp.Button(p, {text="⚡ Speedrun (15/20)", danger=true, callback=function()
        Flick.snapDur=0.015 Flick.returnDur=0.020; HB_Toast("Speedrun","danger") end})
    Cmp.Button(p, {text="👤 Legit", callback=function()
        Flick.snapDur=0.055 Flick.returnDur=0.085; HB_Toast("Legit","success") end})
end
do local p = P["MODES/MM2"]
    Cmp.Section(p, "🎮 MM2 (RAGE: auto-flick ON)")
    Cmp.Toggle(p, {text="Knife Auto-Flick", default=true, callback=function(v) S.MM2_KnifeAutoFlick=v end})
    Cmp.Toggle(p, {text="Gun Auto-Flick", default=true, callback=function(v) S.MM2_GunAutoFlick=v end})
    Cmp.Toggle(p, {text="Round-Start Flick", default=true, callback=function(v) S.MM2_RoundStartFlick=v end})
    Cmp.Toggle(p, {text="After-Kill Reset", default=true, callback=function(v) S.MM2_AfterKillReset=v end})
    Cmp.Toggle(p, {text="Sheriff Protect", default=false, callback=function(v) S.MM2_SheriffProtect=v end})
    Cmp.Toggle(p, {text="Death Flick", default=true, callback=function(v) S.MM2_DeathFlick=v end})
end
do local p = P["MODES/Presets"]
    Cmp.Section(p, "⚡ PRESETS")
    Cmp.Button(p, {text="⚡ TRYHARD", callback=function() HB_PresetTryhard() end})
    Cmp.Button(p, {text="🎯 PRO CLIP", callback=function() HB_ApplyPreset("PRO_CLIP") end})
    Cmp.Button(p, {text="🔥 RAGE PRO", danger=true, callback=function() HB_ApplyPreset("RAGE_PRO") end})
    Cmp.Button(p, {text="💀 RAGE MAX", danger=true, callback=function() HB_PresetRageMax() end})
    Cmp.Button(p, {text="☠ RAGE TRYHARD", danger=true, callback=function() HB_ApplyPreset("RAGE_TRYHARD") end})
    Cmp.Button(p, {text="🔄 RESETAR", callback=function() HB_PresetReset() end})
end

-- ================== FEEDBACK ==================
do local p = P["FEEDBACK/Visual"]
    Cmp.Section(p, "🎨 VISUAL")
    Cmp.Toggle(p, {text="Flick Trail", default=true, callback=function(v) S.FB_FlickTrail=v end})
    Cmp.Toggle(p, {text="Target Marker", default=true, callback=function(v) S.FB_TargetMarker=v end})
    Cmp.Toggle(p, {text="Impact Flash", default=true, callback=function(v) S.FB_ImpactFlash=v end})
end
do local p = P["FEEDBACK/Sounds"]
    Cmp.Section(p, "🔊 SONS")
    Cmp.Toggle(p, {text="Snap Sound", default=true, callback=function(v) S.FB_SnapSound=v end})
    Cmp.Toggle(p, {text="Kill Confirm Sound", default=true, callback=function(v) S.FB_KillConfirmSound=v end})
    Cmp.Toggle(p, {text="Hit Sound", default=true, callback=function(v) if HB_HitSound then HB_HitSound.enabled=v end end})
end
do local p = P["FEEDBACK/HUDCounter"]
    Cmp.Section(p, "📊 HUD")
    Cmp.Toggle(p, {text="Flick Counter HUD", default=true, callback=function(v)
        S.FB_FlickCounter=v; if FLICK_COUNTER then FLICK_COUNTER.Visible=v end end})
end

-- ================== ADV ==================
do local p = P["ADV/Curves"]
    Cmp.Section(p, "⚙ CURVAS (RAGE: OFF)")
    Cmp.Toggle(p, {text="Bezier Snap", default=false, callback=function(v) S.Adv_BezierSnap=v end})
    Cmp.Slider(p, {text="Bezier P1", min=0, max=100, default=25, callback=function(v) S.Adv_BezierP1=v/100 end})
    Cmp.Slider(p, {text="Bezier P2", min=0, max=100, default=75, callback=function(v) S.Adv_BezierP2=v/100 end})
    Cmp.Toggle(p, {text="Spline Flick", default=false, callback=function(v) S.Adv_SplineFlick=v end})
    Cmp.Toggle(p, {text="Ballistic Arc", default=false, callback=function(v) S.Adv_BallisticArc=v end})
end
do local p = P["ADV/Extras"]
    Cmp.Section(p, "🎯 EXTRAS")
    Cmp.Toggle(p, {text="Micro-Jitter Return", default=false, callback=function(v) S.Adv_MicroJitterRet=v end})
    Cmp.Slider(p, {text="Jitter Amount", min=1, max=50, default=5, callback=function(v) S.Adv_MicroJitterAmt=v/10 end})
    Cmp.Toggle(p, {text="Trailing Kill", default=false, callback=function(v) S.Adv_TrailingKill=v end})
    Cmp.Toggle(p, {text="Focus Zoom", default=false, callback=function(v) S.Adv_FocusZoom=v end})
    Cmp.Toggle(p, {text="Priority Switch", default=true, callback=function(v) S.Adv_PrioritySwitch=v end})
    Cmp.Toggle(p, {text="Perfect Return", default=true, callback=function(v) S.Adv_PerfectReturn=v end})
    Cmp.Toggle(p, {text="Cancel Window", default=false, callback=function(v) S.Adv_CancelWindow=v end})
    Cmp.Slider(p, {text="Cancel Window", min=1, max=20, default=3, suffix=" ms", callback=function(v) S.Adv_CancelMs=v end})
end
do local p = P["ADV/Persona"]
    Cmp.Section(p, "🎭 PERSONA (RAGE: aggressive)")
    Cmp.Dropdown(p, {text="Persona", options={"aggressive","cautious","imprevisivel","calculista","casual"},
        default="aggressive", callback=function(o) S.REV_HUMAN.persona=o; PersonaApply() end})
    Cmp.Slider(p, {text="Strength", min=0, max=100, default=0, suffix="%", callback=function(v) S.REV_HUMAN.personaStrength=v/100 end})
end

-- ================== MM2 ==================
do local p = P["MM2/Flick"]
    Cmp.Section(p, "🎮 MM2 FLICK (RAGE)")
    Cmp.Toggle(p, {text="Knife Auto-Flick", default=true, callback=function(v) S.MM2_KnifeAutoFlick=v end})
    Cmp.Toggle(p, {text="Gun Auto-Flick", default=true, callback=function(v) S.MM2_GunAutoFlick=v end})
    Cmp.Toggle(p, {text="Round-Start Flick", default=true, callback=function(v) S.MM2_RoundStartFlick=v end})
end
do local p = P["MM2/Protect"]
    Cmp.Section(p, "🎮 MM2 PROTECT (RAGE: protect OFF)")
    Cmp.Toggle(p, {text="Sheriff Protect", default=false, callback=function(v) S.MM2_SheriffProtect=v end})
    Cmp.Toggle(p, {text="After-Kill Reset", default=true, callback=function(v) S.MM2_AfterKillReset=v end})
    Cmp.Toggle(p, {text="Death Flick", default=true, callback=function(v) S.MM2_DeathFlick=v end})
end

-- ================== DEBUG ==================
local DEBUG_HUD
do local p = P["DEBUG/HUD"]
    Cmp.Section(p, "🐞 DEBUG HUD")
    DEBUG_HUD = HB_Create("TextLabel", {
        Size=newUD2(1,0,0,240), Position=newUD2(0,0,0,32),
        BackgroundColor3=c3(0,0,0), BackgroundTransparency=0.4,
        BorderSizePixel=0, Text="",
        Font=E_CODE, TextSize=11, TextColor3=c3(120,255,120),
        TextXAlignment=E_TXT_LEFT, TextYAlignment=E_TXT_TOP,
        Visible=true
    }, p)
    HB_Corner(DEBUG_HUD, 6); HB_Stroke(DEBUG_HUD, c3(0,200,0), 1, 0.3)
    Cmp.Toggle(p, {text="Mostrar Debug HUD", default=true, callback=function(v) DEBUG_HUD.Visible=v end})
end
do local p = P["DEBUG/Tests"]
    Cmp.Section(p, "🧪 TESTES")
    Cmp.Button(p, {text="▶ Force Flick", danger=true, callback=function()
        local q = FindMurderQueue()
        if #q > 0 then StartFlick(q[1], "debug") else HB_Toast("Sem Murderer","warning") end
    end})
    Cmp.Button(p, {text="🔄 Refresh Roles", callback=function()
        for k in pairs_(RoleCache) do RoleCache[k]=nil end RoleCacheTime=0
        HB_Toast("Roles OK","success")
    end})
    Cmp.Button(p, {text="🐢 LENTO (400ms)", danger=true, callback=function()
        Flick.snapDur=0.400 Flick.returnDur=0.400; HB_Toast("Slow 400ms","warning") end})
    Cmp.Button(p, {text="⚡ RÁPIDO (15/15ms)", callback=function()
        Flick.snapDur=0.015 Flick.returnDur=0.015; HB_Toast("Fast 15ms","success") end})
    Cmp.Button(p, {text="🔧 Reset Câmera", callback=function() HB_ForceRestoreCamera(); HB_Toast("Reset","success") end})
    Cmp.Button(p, {text="🔥 PANIC", danger=true, callback=function()
        S.AutoFlick=false S.ESP=false S.TrigOn=false; HB_ForceRestoreCamera(); HB_Toast("PANIC","danger") end})
end
do local p = P["DEBUG/Info"]
    Cmp.Section(p, "🔍 INFO")
    Cmp.Button(p, {text="🔍 Print Debug (console)", callback=function()
        print("=== HELLBORN v10.0 · ULTRA PRECISION ===")
        print("Cache:", #Cache.List, "Snap:", Flick.snapDur, "Ret:", Flick.returnDur)
        print("OneShot:", S.OneShotPerfect, "Lead:", S.OneShotLead, "Grav:", S.OneShotGravity, "Adapt:", S.OneShotAdaptive)
        print("Stretch:", S.ScreenStretch, "Preset:", S.ScreenStretchPreset, "FOV:", Camera.FieldOfView)
        print("Hit attempts:", HB_DBG.hitAttempts or 0, "Hit success:", HB_DBG.hitSuccess or 0)
        print("Last hit type:", HB_DBG.lastHitType or "none")
        print("Crosshair:", S.Cross, "Style:", S.CrossStyle, "Size:", S.CrossSize)
        print("Ping smoothed:", HB_GetSmoothedPing())
        local s1 = FindSlot1Tool()
        print("Slot1:", s1 and s1.Name or "nil")
        HB_Toast("Ver console (F9)","success")
    end})
end

-- ================== STATS ==================
do local p = P["STATS/Session"]
    Cmp.Section(p, "▤ SESSÃO")
    local box = HB_Create("Frame", {
        Size=newUD2(1,0,0,300), BackgroundColor3=Palette.Elevated, BorderSizePixel=0
    }, p)
    HB_Corner(box, 8)
    UI.StatsDisplay = HB_Create("TextLabel", {
        Size=newUD2(1,-20,1,-20), Position=newUD2(0,10,0,10),
        BackgroundTransparency=1, Text="",
        Font=E_CODE, TextSize=12, TextColor3=Palette.TextHigh,
        TextXAlignment=E_TXT_LEFT, TextYAlignment=E_TXT_TOP, TextWrapped=true
    }, box)
end
do local p = P["STATS/Reset"]
    Cmp.Section(p, "▤ RESET")
    Cmp.Button(p, {text="Resetar Stats", danger=true, callback=function()
        S.Kills=0 S.Deaths=0 S.Hits=0 S.Misses=0 S.Streak=0 S.BestStreak=0
        Acc.shots = {}
        HB_DBG.hitAttempts = 0; HB_DBG.hitSuccess = 0
        HB_Toast("Stats resetados","success")
    end})
end

-- ================== CONFIG ==================
do local p = P["CONFIG/Theme"]
    Cmp.Section(p, "🎨 TEMA")
    local list = {}
    for k in pairs_(Themes) do list[#list+1] = k end
    tsort(list)
    Cmp.Dropdown(p, {text="Cor", options=list, default="Red",
        callback=function(o) if Themes[o] then Palette.Accent = Themes[o]; S.Theme=o end end})
end
do local p = P["CONFIG/System"]
    Cmp.Section(p, "⚙ SISTEMA")
    Cmp.Toggle(p, {text="Auto Save", default=true, callback=function(v) S.AutoSave=v end})
    Cmp.Toggle(p, {text="Chat Commands", default=true, callback=function(v) S.ChatCommands=v end})
end
do local p = P["CONFIG/AutoSave"]
    Cmp.Section(p, "💾 AUTO-SAVE")
    Cmp.Button(p, {text="💾 Salvar Agora", callback=function() HB_AutoSaveTick(); HB_Toast("Saved","success") end})
    Cmp.Button(p, {text="📂 Restaurar", callback=function() HB_AutoSaveLoad(); HB_Toast("Loaded","success") end})
    Cmp.Button(p, {text="🗑 Apagar", danger=true, callback=function() HB_AutoSaveClear(); HB_Toast("Cleared","danger") end})
end

for _, sf in pairs_(UI.TabContents) do
    local maxY = 0
    for _, ch in ipairs_(sf:GetChildren()) do
        if ch:IsA("GuiObject") then
            local b = ch.AbsolutePosition.Y + ch.AbsoluteSize.Y
            local rel = b - sf.AbsolutePosition.Y
            if rel > maxY then maxY = rel end
        end
    end
    sf.CanvasSize = newUD2(0,0,0, maxY + 60)
end

local UI_dragState = {active=false, start=nil, origin=nil}
UIS_InputBegan:Connect(function(input)
    if input.UserInputType ~= E_MOUSE1 then return end
    local hdrHit = HB_PointIn(input.Position, UI_header)
    local dragHit = HB_PointIn(input.Position, UI_dragBtn)
    if dragHit or (hdrHit
        and not HB_PointIn(input.Position, UI_closeBtn)
        and not HB_PointIn(input.Position, UI_panicBtn)
        and not HB_PointIn(input.Position, UI_zoomIn)
        and not HB_PointIn(input.Position, UI_zoomOut)) then
        UI_dragState.active = true
        UI_dragState.start = input.Position
        UI_dragState.origin = UI_main.Position
    end
end)
UIS_InputChanged:Connect(function(input)
    if not UI_dragState.active then return end
    if input.UserInputType ~= E_MOUSEMOVE then return end
    local d = input.Position - UI_dragState.start
    UI_main.Position = newUD2(
        UI_dragState.origin.X.Scale, UI_dragState.origin.X.Offset + d.X,
        UI_dragState.origin.Y.Scale, UI_dragState.origin.Y.Offset + d.Y)
end)
UIS_InputEnded:Connect(function(input)
    if input.UserInputType == E_MOUSE1 then UI_dragState.active = false end
end)

--========= ESP / RADAR / TIMELINE / HUD =========
ESP_GUI = HB_Create("ScreenGui", {Name="HB_ESP_Overlay", ResetOnSpawn=false, IgnoreGuiInset=true, DisplayOrder=90}, PG)
ESP_HOLDER = HB_Create("Frame", {Size=newUD2(1,0,1,0), BackgroundTransparency=1}, ESP_GUI)
ESP_COLORS = {Murderer=c3(255,40,40), Sheriff=c3(50,140,255), Innocent=c3(50,220,90), Dead=c3(120,120,120)}
ESP_LABELS = {Murderer="MURDERER", Sheriff="SHERIFF", Innocent="INNOCENT"}
ESP_CACHE = {}; CHAMS_CACHE = {}

function ESP_create()
    local box = HB_Create("Frame", {BackgroundTransparency=1, BorderSizePixel=0, Visible=false, ZIndex=5}, ESP_HOLDER)
    local st = HB_Create("UIStroke", {Color=c3(255,255,255), Thickness=2, Transparency=0}, box)
    local fill = HB_Create("Frame", {Size=newUD2(1,0,1,0), BackgroundColor3=c3(255,255,255), BackgroundTransparency=0.8, BorderSizePixel=0, ZIndex=1}, box); HB_Corner(fill, 2)
    local nameTag = HB_Create("TextLabel", {Size=newUD2(1,0,0,16), Position=newUD2(0,0,0,-20), BackgroundTransparency=1, Text="", Font=E_GOTHAM_BOLD, TextSize=13, TextColor3=c3(255,255,255), TextStrokeTransparency=0, TextStrokeColor3=c3(0,0,0), TextXAlignment=E_TXT_CENTER, Visible=false, ZIndex=7}, box)
    local distTag = HB_Create("TextLabel", {Size=newUD2(1,0,0,12), Position=newUD2(0,0,0,-8), BackgroundTransparency=1, Text="", Font=E_CODE, TextSize=10, TextColor3=c3(220,220,220), TextStrokeTransparency=0, TextStrokeColor3=c3(0,0,0), TextXAlignment=E_TXT_CENTER, Visible=false, ZIndex=7}, box)
    local healthBg = HB_Create("Frame", {Size=newUD2(0,3,1,0), Position=newUD2(0,-7,0,0), BackgroundColor3=c3(0,0,0), BackgroundTransparency=0.4, BorderSizePixel=0, Visible=false, ZIndex=7}, box)
    local healthFill = HB_Create("Frame", {Size=newUD2(1,0,1,0), BackgroundColor3=c3(0,220,80), BorderSizePixel=0}, healthBg)
    local tracer = HB_Create("Frame", {BackgroundColor3=c3(255,255,255), BorderSizePixel=0, Visible=false, ZIndex=4, AnchorPoint=Vector2.new(0.5,0.5)}, ESP_HOLDER)
    local weaponTag = HB_Create("TextLabel", {Size=newUD2(1,0,0,12), Position=newUD2(0,0,0,20), BackgroundTransparency=1, Text="", Font=E_GOTHAM, TextSize=10, TextColor3=c3(200,200,200), TextStrokeTransparency=0.3, TextStrokeColor3=c3(0,0,0), TextXAlignment=E_TXT_CENTER, Visible=false, ZIndex=7}, box)
    return {box=box, stroke=st, fill=fill, nameTag=nameTag, distTag=distTag, tracer=tracer, healthBg=healthBg, healthFill=healthFill, weaponTag=weaponTag}
end

RADAR_GUI = HB_Create("ScreenGui", {Name="HB_Radar", ResetOnSpawn=false, IgnoreGuiInset=true, DisplayOrder=86}, PG)
RADAR_FRAME = HB_Create("Frame", {
    Size=newUD2(0,160,0,160), Position=newUD2(0,10,1,-170),
    BackgroundColor3=c3(10,10,14), BackgroundTransparency=0.4,
    BorderSizePixel=0, Visible=false, ZIndex=70
}, RADAR_GUI)
HB_Corner(RADAR_FRAME, 80); HB_Stroke(RADAR_FRAME, c3(255,255,255), 2, 0.5)
HB_Create("Frame", {Size=newUD2(0,8,0,8), Position=newUD2(0.5,-4,0.5,-4), BackgroundColor3=c3(255,255,255), BorderSizePixel=0, ZIndex=72}, RADAR_FRAME)

TIMELINE_GUI = HB_Create("ScreenGui", {Name="HB_Timeline", ResetOnSpawn=false, IgnoreGuiInset=true, DisplayOrder=87}, PG)
TIMELINE_HOLDER = HB_Create("Frame", {Size=newUD2(1,0,1,0), BackgroundTransparency=1}, TIMELINE_GUI)

HUD_GUI = HB_Create("ScreenGui", {Name="HB_HUD_Overlay", ResetOnSpawn=false, IgnoreGuiInset=true, DisplayOrder=95}, PG)
KILLFEED = HB_Create("Frame", {Size=newUD2(0,300,0,300), Position=newUD2(1,-310,0,100), BackgroundTransparency=1}, HUD_GUI)
HITMARKER = HB_Create("Frame", {Size=newUD2(0,40,0,40), Position=newUD2(0.5,-20,0.5,-20), BackgroundTransparency=1, Visible=false, ZIndex=50}, HUD_GUI)
for _, cfg in ipairs_({ {-8,-8,45},{8,-8,-45},{-8,8,-45},{8,8,45} }) do
    HB_Create("Frame", {Size=newUD2(0,10,0,2), Position=newUD2(0.5,cfg[1],0.5,cfg[2]),
        AnchorPoint=Vector2.new(0.5,0.5), BackgroundColor3=c3(255,255,255), BorderSizePixel=0, Rotation=cfg[3]}, HITMARKER)
end

-- ================= CROSSHAIR (SHARINGAN) =================
CROSSHAIR = HB_Create("Frame", {Size=newUD2(0,24,0,24), Position=newUD2(0.5,-12,0.5,-12), BackgroundTransparency=1, Visible=S.Cross, ZIndex=100}, HUD_GUI)

function HB_BuildCrosshair()
    if not CROSSHAIR then return end
    for _, child in ipairs(CROSSHAIR:GetChildren()) do child:Destroy() end
    CROSSHAIR.Size = newUD2(0, S.CrossSize, 0, S.CrossSize)
    CROSSHAIR.Visible = S.Cross
    local size = S.CrossSize

    if S.CrossStyle == "Sharingan" then
        local bg = Instance.new("Frame")
        bg.Size = UDim2.new(1, 0, 1, 0)
        bg.BackgroundColor3 = Color3.fromRGB(160, 10, 10)
        bg.BorderSizePixel = 0
        bg.Parent = CROSSHAIR
        local bgCorner = Instance.new("UICorner"); bgCorner.CornerRadius = UDim.new(1, 0); bgCorner.Parent = bg

        local ring = Instance.new("Frame")
        ring.Size = UDim2.new(0.85, 0, 0.85, 0)
        ring.Position = UDim2.new(0.075, 0, 0.075, 0)
        ring.BackgroundColor3 = Color3.fromRGB(4, 4, 4)
        ring.BorderSizePixel = 0
        ring.Parent = CROSSHAIR
        local ringCorner = Instance.new("UICorner"); ringCorner.CornerRadius = UDim.new(1, 0); ringCorner.Parent = ring

        local innerRed = Instance.new("Frame")
        innerRed.Size = UDim2.new(0.8, 0, 0.8, 0)
        innerRed.Position = UDim2.new(0.1, 0, 0.1, 0)
        innerRed.BackgroundColor3 = Color3.fromRGB(160, 10, 10)
        innerRed.BorderSizePixel = 0
        innerRed.Parent = CROSSHAIR
        local innerRedCorner = Instance.new("UICorner"); innerRedCorner.CornerRadius = UDim.new(1, 0); innerRedCorner.Parent = innerRed

        for i = 1, 3 do
            local blade = Instance.new("Frame")
            blade.Size = UDim2.new(1, 0, 1, 0)
            blade.BackgroundTransparency = 1
            blade.Rotation = (i - 1) * 120
            blade.Parent = innerRed

            local dot = Instance.new("Frame")
            dot.Size = UDim2.new(0.22, 0, 0.22, 0)
            dot.Position = UDim2.new(0.5, 0, 0.1, 0)
            dot.AnchorPoint = Vector2.new(0.5, 0.5)
            dot.BackgroundColor3 = Color3.fromRGB(4, 4, 4)
            dot.BorderSizePixel = 0
            dot.Parent = blade
            local dotCorner = Instance.new("UICorner"); dotCorner.CornerRadius = UDim.new(1, 0); dotCorner.Parent = dot

            local tail = Instance.new("Frame")
            tail.Size = UDim2.new(0.08, 0, 0.3, 0)
            tail.Position = UDim2.new(0.5, 0, 0.1, 0)
            tail.AnchorPoint = Vector2.new(0.5, 0)
            tail.BackgroundColor3 = Color3.fromRGB(4, 4, 4)
            tail.BorderSizePixel = 0
            tail.Rotation = 30
            tail.Parent = blade
            local tailCorner = Instance.new("UICorner"); tailCorner.CornerRadius = UDim.new(1, 0); tailCorner.Parent = tail
        end

        local center = Instance.new("Frame")
        center.Size = UDim2.new(0.15, 0, 0.15, 0)
        center.Position = UDim2.new(0.5, 0, 0.5, 0)
        center.AnchorPoint = Vector2.new(0.5, 0.5)
        center.BackgroundColor3 = Color3.fromRGB(4, 4, 4)
        center.BorderSizePixel = 0
        center.Parent = innerRed
        local centerCorner = Instance.new("UICorner"); centerCorner.CornerRadius = UDim.new(1, 0); centerCorner.Parent = center
    else
        local thickness = 2
        local offset = size * 0.3
        local configs = {}
        if S.CrossStyle == "Dot" then
            configs = { {0, 0, thickness, thickness} }
        elseif S.CrossStyle == "Cross" then
            configs = { {0, -offset, thickness, size*0.4}, {0, offset, thickness, size*0.4}, {-offset, 0, size*0.4, thickness}, {offset, 0, size*0.4, thickness} }
        else
            configs = { {0, -offset, thickness, size*0.4}, {0, offset, thickness, size*0.4}, {-offset, 0, size*0.4, thickness}, {offset, 0, size*0.4, thickness}, {0, 0, thickness, thickness} }
        end
        for _, cfg in ipairs(configs) do
            local line = Instance.new("Frame")
            line.Size = UDim2.new(0, cfg[3], 0, cfg[4])
            line.Position = UDim2.new(0.5, cfg[1], 0.5, cfg[2])
            line.AnchorPoint = Vector2.new(0.5, 0.5)
            line.BackgroundColor3 = Color3.fromRGB(220, 40, 40)
            line.BorderSizePixel = 0
            line.Parent = CROSSHAIR
        end
    end
end
HB_BuildCrosshair()

RS.RenderStepped:Connect(function()
    if not CROSSHAIR or not CROSSHAIR.Parent then return end
    CROSSHAIR.Visible = S.Cross
    if not S.Cross then
        if UIS.MouseIconEnabled == false then UIS.MouseIconEnabled = true end
        return
    end
    UIS.MouseIconEnabled = false
    if S.CrossFollowMouse then
        local mouseLoc = UIS:GetMouseLocation()
        CROSSHAIR.Position = UDim2.new(0, mouseLoc.X - (S.CrossSize/2), 0, mouseLoc.Y - (S.CrossSize/2))
    else
        CROSSHAIR.Position = UDim2.new(0.5, -(S.CrossSize/2), 0.5, -(S.CrossSize/2))
    end
end)
-- ========================================================

COOLDOWN_BAR = HB_Create("Frame", {Size=newUD2(0,80,0,6), Position=newUD2(0.5,-40,1,-30),
    BackgroundColor3=c3(30,30,40), BorderSizePixel=0, Visible=false, ZIndex=50}, HUD_GUI)
HB_Corner(COOLDOWN_BAR, 3)
COOLDOWN_FILL = HB_Create("Frame", {Size=newUD2(1,0,1,0), BackgroundColor3=Palette.Accent, BorderSizePixel=0}, COOLDOWN_BAR)
HB_Corner(COOLDOWN_FILL, 3)
FLICK_COUNTER = HB_Create("TextLabel", {Size=newUD2(0,750,0,22), Position=newUD2(0,20,0,20),
    BackgroundTransparency=1, Text="FLICKS: 0 | KILLS: 0", Font=E_CODE, TextSize=14,
    TextColor3=Palette.Accent, TextXAlignment=E_TXT_LEFT, TextStrokeTransparency=0.4,
    TextStrokeColor3=c3(0,0,0), ZIndex=10}, HUD_GUI)

HB_HitSound = {enabled=true, soundId="rbxasset://sounds/electronicpingshort.wav",
    volume=0.4, pitchMin=1.1, pitchMax=1.4, lastPlay=0, cooldown=0.05, instance=nil}
HB_KillConfirmSound = {enabled=true, soundId="rbxasset://sounds/electronicpingshort.wav",
    volume=0.6, pitch=0.7, lastPlay=0, instance=nil}
HB_AutoSave = {enabled=true, interval=30, lastSave=0, saveKey="HB_AutoSave_Config", savesCount=0}

function HB_InitHitSound()
    if HB_HitSound.instance then return end
    local s = Instance.new("Sound")
    s.Name = "HB_HitSound"; s.SoundId = HB_HitSound.soundId
    s.Volume = HB_HitSound.volume; s.Parent = SoundService
    HB_HitSound.instance = s
end
function HB_InitKillSound()
    if HB_KillConfirmSound.instance then return end
    local s = Instance.new("Sound")
    s.Name = "HB_KillSound"; s.SoundId = HB_KillConfirmSound.soundId
    s.Volume = HB_KillConfirmSound.volume
    s.PlaybackSpeed = HB_KillConfirmSound.pitch; s.Parent = SoundService
    HB_KillConfirmSound.instance = s
end
function HB_PlayHitSound()
    if not HB_HitSound.enabled then return end
    local now = tick()
    if now - HB_HitSound.lastPlay < HB_HitSound.cooldown then return end
    HB_HitSound.lastPlay = now
    if not HB_HitSound.instance then HB_InitHitSound() end
    local base = HB_HitSound.instance
    if base then
        local s = base:Clone()
        s.PlaybackSpeed = HB_HitSound.pitchMin + random() * (HB_HitSound.pitchMax - HB_HitSound.pitchMin)
        s.Volume = HB_HitSound.volume; s.Parent = SoundService; s:Play()
        delay(1, function() if s then s:Destroy() end end)
    end
end
function HB_PlayKillSound()
    if not HB_KillConfirmSound.enabled then return end
    if tick() - HB_KillConfirmSound.lastPlay < 0.3 then return end
    HB_KillConfirmSound.lastPlay = tick()
    if not HB_KillConfirmSound.instance then HB_InitKillSound() end
    local base = HB_KillConfirmSound.instance
    if base then
        local s = base:Clone()
        s.Volume = HB_KillConfirmSound.volume; s.Parent = SoundService; s:Play()
        delay(2, function() if s then s:Destroy() end end)
    end
end
function HB_AutoSaveTick()
    if not HB_AutoSave.enabled then return end
    if tick() - HB_AutoSave.lastSave < HB_AutoSave.interval then return end
    HB_AutoSave.lastSave = tick()
    HB_AutoSave.savesCount = HB_AutoSave.savesCount + 1
    local snapshot = {}
    for k, v in pairs_(S) do
        local t = type(v)
        if t == "boolean" or t == "number" or t == "string" then snapshot[k] = v end
    end
    if Flick then
        snapshot._snapDur = Flick.snapDur
        snapshot._holdDur = Flick.holdDur
        snapshot._verifyWait = Flick.verifyWait
        snapshot._returnDur = Flick.returnDur
    end
    _G[HB_AutoSave.saveKey] = snapshot
end
function HB_AutoSaveLoad()
    local saved = _G[HB_AutoSave.saveKey]
    if not saved then return false end
    for k, v in pairs_(saved) do
        if ssub(k, 1, 1) ~= "_" then S[k] = v end
    end
    if Flick then
        if saved._snapDur then Flick.snapDur = saved._snapDur end
        if saved._holdDur then Flick.holdDur = saved._holdDur end
        if saved._verifyWait then Flick.verifyWait = saved._verifyWait end
        if saved._returnDur then Flick.returnDur = saved._returnDur end
    end
    if S.ScreenStretch then HB_ApplyScreenStretch() end
    if HB_BuildCrosshair then HB_BuildCrosshair() end
    return true
end
function HB_AutoSaveClear()
    _G[HB_AutoSave.saveKey] = nil; HB_AutoSave.savesCount = 0
end

HB_Presets = {
    TRYHARD = {AutoFlick=true, PullSlot1=true, AlignTol=1, AimSmooth=0.02,
        RateLimit=false, FakeMiss=false, Humanize=false, AntiFlickBlock=false,
        ESP=true, Chams=true, Radar=true, Hitmark=true, KillFeed=true,
        WallCheck=true, CycleEnabled=false, MaxCycles=1, FlickMaxDist=2000,
        OneShotPerfect=true, OneShotLead=true, OneShotGravity=true, OneShotAdaptive=true},
    PRO_CLIP = {AutoFlick=true, PullSlot1=true, AlignTol=0.3, AimSmooth=0.0,
        RateLimit=false, FakeMiss=false, Humanize=true, AntiFlickBlock=false,
        AntiFlickBackoff=0, PostKillDelay=false,
        ESP=false, Chams=false, Radar=false, Hitmark=true, KillFeed=true,
        Cross=false, CrossStyle="Sharingan", CrossSize=24, CrossFollowMouse=true,
        WallCheck=true, CycleEnabled=false, MaxCycles=1,
        FlickMaxDist=4000, SilentOn=true, SmartTarget=true, PreAim=true, StickyAim=true,
        StickyAimStrength=0.5, HitscanOpt=false, FPSAdaptive=true, FPSAdaptiveMinFPS=30,
        OneShotPerfect=true, OneShotLead=true, OneShotGravity=true, OneShotAdaptive=true},
    RAGE_PRO = {AutoFlick=true, PullSlot1=true, AlignTol=0.1, AimSmooth=0.0,
        RateLimit=false, FakeMiss=false, Humanize=false, AntiFlickBlock=false,
        AntiFlickBackoff=0, PostKillDelay=false, RandomAim=false, WeaponCooldownCheck=false,
        ESP=true, ESPThick=3, Chams=true, Radar=true, TimelinePredictor=true,
        Hitmark=true, KillFeed=true, Cross=true, CrossStyle="Sharingan", CrossSize=28, CrossFollowMouse=true,
        WallCheck=false, CycleEnabled=false, MaxCycles=1, FlickMaxDist=5000,
        SilentOn=true, SmartTarget=true, PreAim=true, StickyAim=true,
        StickyAimStrength=1.0, HitscanOpt=false, FPSAdaptive=true, FPSAdaptiveMinFPS=20,
        HeadOnlyLock=true, FlickCameraMode="Off",
        OneShotPerfect=true, OneShotLead=true, OneShotGravity=true, OneShotAdaptive=true,
        ScreenStretch=true, ScreenStretchPreset="4:3 Stretch", ScreenStretchFOV=52},
    RAGE_MAX = {AutoFlick=true, PullSlot1=true, AlignTol=0.5, AimSmooth=0.0,
        RateLimit=false, FakeMiss=false, Humanize=false, AntiFlickBlock=false,
        ESP=true, ESPThick=3, Chams=true, Radar=true, TimelinePredictor=true,
        Hitmark=true, KillFeed=true, Cross=true, CrossSize=32, CrossStyle="Sharingan", CrossFollowMouse=true,
        WallCheck=false, CycleEnabled=false, MaxCycles=1, FlickMaxDist=5000,
        HeadOnlyLock=true, FlickCameraMode="Off",
        OneShotPerfect=true, OneShotLead=true, OneShotGravity=true, OneShotAdaptive=true,
        ScreenStretch=true, ScreenStretchPreset="Rage Zoom", ScreenStretchFOV=42},
    RAGE_TRYHARD = {AutoFlick=true, PullSlot1=true, AlignTol=0.5, AimSmooth=0.0,
        RateLimit=false, FakeMiss=false, Humanize=false, AntiFlickBlock=false,
        AntiFlickBackoff=0, PostKillDelay=false, RandomAim=false, WeaponCooldownCheck=false,
        ESP=true, ESPThick=3, Chams=true, Radar=true, TimelinePredictor=true,
        Hitmark=true, KillFeed=true, Cross=true, CrossStyle="Sharingan", CrossSize=30, CrossFollowMouse=true,
        WallCheck=false, FlickMaxDist=5000, CycleEnabled=false, MaxCycles=1,
        SilentOn=true, SmartTarget=true, PreAim=true, StickyAim=true,
        StickyAimStrength=1.0, HitscanOpt=false, FPSAdaptive=true, FPSAdaptiveMinFPS=20,
        HeadOnlyLock=true, FlickCameraMode="Off", Theme="Blood",
        OneShotPerfect=true, OneShotLead=true, OneShotGravity=true, OneShotAdaptive=true,
        ScreenStretch=true, ScreenStretchPreset="Ultra Rage", ScreenStretchFOV=32},
}
function HB_ApplyPreset(name)
    local preset = HB_Presets[name]
    if not preset then return end
    for k, v in pairs_(preset) do S[k] = v end
    if Flick then
        Flick.oneShot = true; Flick.retriesLeft = 0
        if name == "PRO_CLIP" then
            Flick.proMode = true
            Flick.snapDur = 0.026; Flick.holdDur = 0.070
            Flick.verifyWait = 0.30; Flick.returnDur = 0.080
            Flick.overshootPct = 0.055; Flick.adaptiveOvershoot = true
            Flick.microJitter = 0.10; Flick.microJitterRate = 42
            Flick.preDipEnabled = true; Flick.preDipDur = 0.020; Flick.preDipAmount = 0.012
            Flick.fireAtPeak = true; Flick.reactionDelay = 0.045
            Flick.recoilEnabled = true; Flick.recoilAmount = 0.018; Flick.recoilTime = 0.050
            Flick.postShotSettle = 0.035
        elseif name == "RAGE_PRO" or name == "RAGE_MAX" or name == "RAGE_TRYHARD" then
            Flick.proMode = false
            Flick.snapDur = 0.014; Flick.holdDur = 0.030
            Flick.verifyWait = 0.150; Flick.returnDur = 0.035
            Flick.overshootPct = 0.010; Flick.adaptiveOvershoot = false
            Flick.microJitter = 0; Flick.microJitterRate = 10
            Flick.preDipEnabled = false; Flick.fireAtPeak = true
            Flick.reactionDelay = 0
            Flick.recoilEnabled = false; Flick.postShotSettle = 0
        elseif name == "TRYHARD" then
            Flick.proMode = true
            Flick.snapDur = 0.024; Flick.holdDur = 0.065
            Flick.overshootPct = 0.048; Flick.adaptiveOvershoot = true
            Flick.microJitter = 0.08
            Flick.preDipEnabled = true; Flick.fireAtPeak = true
            Flick.reactionDelay = 0.040
            Flick.recoilEnabled = true; Flick.recoilAmount = 0.018
            Flick.postShotSettle = 0.030
        end
    end
    if S.REV_HUMAN then
        S.REV_HUMAN.warmup=false S.REV_HUMAN.cooldown=false
        S.REV_HUMAN.fatigue=false S.REV_HUMAN.cognitive=false S.REV_HUMAN.emotion=false
        S.REV_HUMAN.squad=false S.REV_HUMAN.reputation=false S.REV_HUMAN.altDetect=false
        if name == "RAGE_MAX" or name == "RAGE_TRYHARD" or name == "RAGE_PRO" then
            S.REV_HUMAN.persona = "aggressive"; S.REV_HUMAN.personaStrength = 0.0
        elseif name == "PRO_CLIP" then
            S.REV_HUMAN.persona = "calculista"; S.REV_HUMAN.personaStrength = 0.5
        end
    end
    if name == "RAGE_TRYHARD" and Themes.Blood then Palette.Accent = Themes.Blood end
    HB_ApplyScreenStretch()
    if HB_BuildCrosshair then HB_BuildCrosshair() end
end
function HB_PresetTryhard() HB_ApplyPreset("TRYHARD") end
function HB_PresetRageMax() HB_ApplyPreset("RAGE_MAX") end
function HB_PresetReset()
    if Flick then
        Flick.snapDur = 0.014; Flick.holdDur = 0.030
        Flick.verifyWait = 0.150; Flick.returnDur = 0.035
        Flick.retriesLeft = 0
        Flick.proMode = false; Flick.oneShot = true
        Flick.overshootPct = 0.010; Flick.adaptiveOvershoot = false
        Flick.microJitter = 0; Flick.microJitterRate = 10
        Flick.preDipEnabled = false; Flick.fireAtPeak = true
        Flick.reactionDelay = 0
        Flick.recoilEnabled = false; Flick.postShotSettle = 0
    end
    S.AlignTol=1 S.AimSmooth=0
    S.FakeMiss=false S.RateLimit=false S.Humanize=true S.AntiFlickBlock=false
    S.TrigOn=false S.ESP=true S.Chams=true S.Radar=true
    S.TimelinePredictor=true
    S.WallCheck=false S.CycleEnabled=false S.MaxCycles=1
    S.FlickMaxDist=5000 S.FlickCameraMode="Off"
    S.HeadOnlyLock=true S.PostKillDelay=false
    S.OneShotPerfect=true S.OneShotLead=true S.OneShotGravity=true S.OneShotAdaptive=true
    S.Cross=false S.CrossStyle="Sharingan" S.CrossSize=24 S.CrossFollowMouse=true
    HB_ResetScreenStretch()
    HB_ForceRestoreCamera()
    if HB_BuildCrosshair then HB_BuildCrosshair() end
end

local HB_MLFinal = MetaLearnUpdate
MetaLearnUpdate = function(perf)
    HB_MLFinal(perf)
    if perf and perf > 0.5 then pcall(HB_PlayKillSound) else pcall(HB_PlayHitSound) end
end

-- TRIGGER BOT
local TriggerAccum = 0
RS_Heartbeat:Connect(function(dt)
    if not S.TrigOn then return end
    TriggerAccum = TriggerAccum + dt
    if TriggerAccum < 1/30 then return end
    TriggerAccum = 0
    local now = tick()
    local flickBusy = Flick and (Flick.active or (now - (Flick.lastFlickEnd or 0)) < 0.25)
    if flickBusy or now < TriggerSuppressUntil or (Flick and Flick.keyHeld) then return end
    local mouse = UIS:GetMouseLocation()
    local best, bestD = nil, S.TrigRad
    for i = 1, #Cache.List do
        local p2 = Cache.List[i]
        if p2 ~= LP and GetRole(p2) == "Murderer" then
            local head = Cache.Heads[p2]
            if head then
                local sp, on = Camera:WorldToViewportPoint(head.Position)
                if on then
                    local dx, dy = sp.X - mouse.X, sp.Y - mouse.Y
                    local d = sqrt(dx*dx + dy*dy)
                    if d < bestD then bestD = d; best = p2 end
                end
            end
        end
    end
    if not best then return end
    local ch = Cache.Chars[best]
    if S.WallCheck and ch and not HB_HasLineOfSight(ch) then return end
    local s1 = FindSlot1Tool()
    if not s1 then return end
    local hum = ch and ch:FindFirstChildOfClass("Humanoid")
    if not hum then return end
    task.spawn(function()
        local eq = HB_EquipAndWait(s1, 0.5)
        if eq and not IsWeaponOnCooldown(eq) then
            local camPos = (Cache.Heads[LP] and Cache.Heads[LP].Position) or Camera.CFrame.Position
            HB_PerfectShot(best, ch, hum, camPos, eq)
        end
    end)
end)

RS_Heartbeat:Connect(function()
    local vpSize = Camera.ViewportSize; local vpX2 = vpSize.X * 0.5; local vpY = vpSize.Y
    local myChar = LP.Character; local myHRP = myChar and myChar:FindFirstChild("HumanoidRootPart")
    local myPos = myHRP and myHRP.Position or Camera.CFrame.Position
    local roleCache = {}
    for i = 1, #Cache.List do
        local pl = Cache.List[i]
        if pl ~= LP then roleCache[pl] = GetRole(pl) end
    end
    for i = 1, #Cache.List do
        local pl = Cache.List[i]
        if pl ~= LP then
            local e = ESP_CACHE[pl]; if not e then e = ESP_create(); ESP_CACHE[pl] = e end
            local char = pl.Character; local head = char and char:FindFirstChild("Head")
            local hrp = char and char:FindFirstChild("HumanoidRootPart"); local hum = char and char:FindFirstChildOfClass("Humanoid")
            local role = roleCache[pl]
            local show = S.ESP and head and hrp and hum and hum.Health > 0 and (
                (role == "Murderer") or (role == "Sheriff" and S.ESPShowSheriff) or (role == "Innocent" and S.ESPShowInnocents))
            if show then
                local color = ESP_COLORS[role] or ESP_COLORS.Innocent
                local hs, on1 = Camera:WorldToViewportPoint(head.Position + Vector3.new(0,1.2,0))
                local fs, on2 = Camera:WorldToViewportPoint(hrp.Position - Vector3.new(0,2.5,0))
                if on1 and on2 and hs.Z > 0 and fs.Z > 0 then
                    local topY, botY = hs.Y, fs.Y; local hPx = abs(botY - topY); local wPx = hPx * 0.55; local cx = hs.X
                    e.box.Visible = S.ESPBox; e.box.Size = newUD2(0,wPx,0,hPx); e.box.Position = newUD2(0,cx-wPx*0.5,0,topY)
                    e.stroke.Color = color; e.stroke.Thickness = S.ESPThick or 2
                    e.fill.Visible = S.ESPFill; e.fill.BackgroundColor3 = color; e.fill.BackgroundTransparency = S.ESPFillTransparency or 0.8
                    e.nameTag.Visible = S.ESPName; e.nameTag.Text = ESP_LABELS[role].." "..pl.Name
                    e.nameTag.TextColor3 = color; e.nameTag.Position = newUD2(0,-wPx*0.5,0,topY-38); e.nameTag.Size = newUD2(0,wPx*3,0,16)
                    local distStuds = (head.Position - myPos).Magnitude
                    e.distTag.Visible = S.ESPDist; e.distTag.Text = sformat("[%d]", floor(distStuds))
                    e.distTag.Position = newUD2(0,-wPx*0.5,0,topY-20); e.distTag.Size = newUD2(0,wPx*3,0,12)
                    e.healthBg.Visible = S.ESPHealth
                    e.healthFill.Size = newUD2(clamp(hum.Health/hum.MaxHealth,0,1),0,1,0)
                    e.healthFill.BackgroundColor3 = c3(floor(255*(1-hum.Health/hum.MaxHealth)), floor(255*(hum.Health/hum.MaxHealth)), 50)
                    if S.ESPWeapon then
                        local eq = char:FindFirstChildOfClass("Tool")
                        e.weaponTag.Visible = eq ~= nil; if eq then e.weaponTag.Text = eq.Name end
                        e.weaponTag.Position = newUD2(0,-wPx*0.5,0,botY+4); e.weaponTag.Size = newUD2(0,wPx*3,0,12)
                    else e.weaponTag.Visible = false end
                    if S.ESPTracer then
                        local dx = cx - vpX2; local dy = (topY+hPx) - vpY; local len = sqrt(dx*dx+dy*dy)
                        e.tracer.Visible = true; e.tracer.Size = newUD2(0,len,0,1)
                        e.tracer.Position = newUD2(0, vpX2 + dx*0.5, 0, vpY + dy*0.5)
                        e.tracer.Rotation = math.deg(atan2(dy, dx))
                        e.tracer.BackgroundColor3 = color; e.tracer.BackgroundTransparency = 0.3
                    else e.tracer.Visible = false end
                else
                    e.box.Visible=false; e.tracer.Visible=false; e.nameTag.Visible=false
                    e.distTag.Visible=false; e.healthBg.Visible=false; e.weaponTag.Visible=false
                end
            elseif e then
                e.box.Visible=false; e.tracer.Visible=false; e.nameTag.Visible=false
                e.distTag.Visible=false; e.healthBg.Visible=false; e.weaponTag.Visible=false
            end
        end
    end
    for pl, e in pairs_(ESP_CACHE) do
        if not pl.Parent then
            if e.box then e.box:Destroy() end
            if e.tracer then e.tracer:Destroy() end
            ESP_CACHE[pl] = nil
        end
    end
    if not S.Chams then
        if next(CHAMS_CACHE) then
            for _, h in pairs_(CHAMS_CACHE) do if h and h.Parent then h:Destroy() end end
            CHAMS_CACHE = {}
        end
    else
        for i = 1, #Cache.List do
            local pl = Cache.List[i]
            if pl ~= LP then
                local h = CHAMS_CACHE[pl]
                if not h then
                    h = Instance.new("Highlight")
                    h.Name = "HB_Chams_"..pl.Name
                    h.FillTransparency=0.5; h.OutlineTransparency=0.2
                    h.DepthMode = Enum.HighlightDepthMode.AlwaysOnTop
                    h.Parent = PG; CHAMS_CACHE[pl] = h
                end
                local char = pl.Character; local hum = char and char:FindFirstChildOfClass("Humanoid")
                if char and hum and hum.Health > 0 then
                    local color = ESP_COLORS[roleCache[pl]] or ESP_COLORS.Innocent
                    h.FillColor = color; h.OutlineColor = color; h.Adornee = char
                else h.Adornee = nil end
            end
        end
    end
    if not S.Radar then
        if RADAR_FRAME.Visible then RADAR_FRAME.Visible = false end
        for i = 1, RadarDotUsed do RadarDotPool[i].Visible = false end
        RadarDotUsed = 0
    elseif myPos then
        RADAR_FRAME.Visible = true
        RadarDotUsed = 0
        local range = 150; local invRange = 1 / range
        for i = 1, #Cache.List do
            local pl = Cache.List[i]
            if pl ~= LP then
                local char = pl.Character; local hrp = char and char:FindFirstChild("HumanoidRootPart")
                local hum = char and char:FindFirstChildOfClass("Humanoid")
                if hrp and hum and hum.Health > 0 then
                    local rp = hrp.Position
                    local rx, rz = rp.X - myPos.X, rp.Z - myPos.Z
                    local dist = sqrt(rx*rx + rz*rz)
                    if dist <= range then
                        local dot = RadarGetDot()
                        dot.Visible = true
                        dot.Position = newUD2(0.5 + rx*invRange*0.45, -3, 0.5 + rz*invRange*0.45, -3)
                        dot.BackgroundColor3 = ESP_COLORS[roleCache[pl]] or ESP_COLORS.Innocent
                    end
                end
            end
        end
        for i = RadarDotUsed + 1, #RadarDotPool do
            if RadarDotPool[i].Visible then RadarDotPool[i].Visible = false end
        end
    end
    if not S.TimelinePredictor then
        for i = 1, TimelineDotUsed do TimelineDotPool[i].Visible = false end
        TimelineDotUsed = 0
    else
        TimelineDotUsed = 0
        for i = 1, #Cache.List do
            local pl = Cache.List[i]
            if pl ~= LP then
                local h = Hst[pl]
                if h and h.lastPos and h.vel then
                    local color = ESP_COLORS[roleCache[pl]] or ESP_COLORS.Innocent
                    for t = 1, 6 do
                        local fp = h.lastPos + h.vel * (t * 0.2)
                        local s, on = Camera:WorldToViewportPoint(fp)
                        if on and s.Z > 0 then
                            local dot = TimelineGetDot()
                            dot.Visible = true
                            dot.Position = newUD2(0, s.X - 2, 0, s.Y - 2)
                            dot.BackgroundColor3 = color
                            dot.BackgroundTransparency = 1 - (t/6)*0.6
                        end
                    end
                end
            end
        end
        for i = TimelineDotUsed + 1, #TimelineDotPool do
            if TimelineDotPool[i].Visible then TimelineDotPool[i].Visible = false end
        end
    end
    if CROSSHAIR and CROSSHAIR.Visible ~= S.Cross then CROSSHAIR.Visible = S.Cross end
end)

local HUDAccum = 0
RS_Heartbeat:Connect(function(dt)
    HUDAccum = HUDAccum + dt
    if HUDAccum < 0.15 then return end
    HUDAccum = 0
    if S.FB_FlickCounter and FLICK_COUNTER then
        local acc = 0
        if HB_DBG.hitAttempts and HB_DBG.hitAttempts > 0 then
            acc = floor((HB_DBG.hitSuccess or 0) / HB_DBG.hitAttempts * 100)
        end
        FLICK_COUNTER.Text = sformat("KILLS:%d | HIT:%d%% | SNAP:%dms | 1SHOT:%s | FOV:%d | LOCK:%s | CROSS:%s",
            S.Kills, acc, floor((Flick.snapDur or 0)*1000),
            S.OneShotPerfect and "ON" or "OFF", floor(Camera.FieldOfView),
            HB_DBG.lastHitType or "none",
            S.Cross and "ON" or "OFF")
    end
    if S.ShowCooldownVisual and COOLDOWN_BAR and COOLDOWN_FILL then
        COOLDOWN_BAR.Visible = true
        local now = tick()
        local cd = (PostKillTimer.until_ or 0) - now
        if cd > 0 then
            local pct = clamp(1 - (cd / ((S.PostKillDelayMs or 400)/1000)), 0, 1)
            COOLDOWN_FILL.Size = newUD2(pct,0,1,0)
            COOLDOWN_FILL.BackgroundColor3 = Palette.Warning
        else
            COOLDOWN_FILL.Size = newUD2(1,0,1,0)
            COOLDOWN_FILL.BackgroundColor3 = Palette.Accent
        end
    else
        if COOLDOWN_BAR then COOLDOWN_BAR.Visible = false end
    end
    if UI.StatsDisplay and UI.StatsDisplay.Parent then
        local fps = FPS.cur or 60
        local ping = floor(HB_GetSmoothedPing() * 1000)
        local acc = 0
        if HB_DBG.hitAttempts and HB_DBG.hitAttempts > 0 then
            acc = floor((HB_DBG.hitSuccess or 0) / HB_DBG.hitAttempts * 100)
        end
        UI.StatsDisplay.Text = sformat(
            "📊 v10.0 · ULTRA PRECISION\n\nKills: %d\nDeaths: %d\nStreak: %d\nBest: %d\nFPS: %.0f\nPing: %dms\n---\nHitrate: %d%%\nTentativas: %d\nSucessos: %d\nLock: %s\n---\nOneShot: %s\nLead: %s\nGrav: %s\nAdapt: %s\n---\nStretch: %s\nFOV: %d (%s)\nCrosshair: %s (%s)\nSlot1: %s",
            S.Kills, S.Deaths, S.Streak or 0, S.BestStreak or 0,
            fps, ping, acc,
            HB_DBG.hitAttempts or 0, HB_DBG.hitSuccess or 0,
            HB_DBG.lastHitType or "none",
            S.OneShotPerfect and "ON" or "OFF",
            S.OneShotLead and "ON" or "OFF",
            S.OneShotGravity and "ON" or "OFF",
            S.OneShotAdaptive and "ON" or "OFF",
            S.ScreenStretch and "ON" or "OFF",
            floor(Camera.FieldOfView), S.ScreenStretchPreset or "Normal",
            S.Cross and "ON" or "OFF", S.CrossStyle or "-",
            S.PullSlot1 and "ON" or "OFF")
    end
    if DEBUG_HUD and DEBUG_HUD.Visible then
        DEBUG_HUD.Text = sformat(
            "⚡ HELLBORN v10.0 · ULTRA PRECISION\nCache:%d | Murderers:%d | Sheriffs:%d\nSnap:%dms Ret:%dms Ver:%dms\nOneShot:%s Lead:%s Grav:%s Adapt:%s\nAttempts:%d Success:%d\nLOCK TYPE: %s\nFired:%s Verified:%s\nCross:%s(%s %dpx)\nStretch:%s FOV:%d(%s)\nPing smooth:%.0fms\nFlicks:%d Kills:%d\nFPS:%.0f",
            #Cache.List, HB_DBG.murders or 0, HB_DBG.sheriffs or 0,
            floor((Flick.snapDur or 0)*1000), floor((Flick.returnDur or 0)*1000), floor((Flick.verifyWait or 0)*1000),
            tostring(S.OneShotPerfect), tostring(S.OneShotLead), tostring(S.OneShotGravity), tostring(S.OneShotAdaptive),
            HB_DBG.hitAttempts or 0, HB_DBG.hitSuccess or 0,
            tostring(HB_DBG.lastHitType or "none"),
            tostring(Flick.fired), tostring(Flick.hitVerified),
            tostring(S.Cross), tostring(S.CrossStyle), S.CrossSize,
            tostring(S.ScreenStretch), floor(Camera.FieldOfView), S.ScreenStretchPreset or "Normal",
            HB_GetSmoothedPing() * 1000,
            S.Kills, S.Kills,
            FPS.cur or 60)
    end
end)

local TaskAccum = {t5=0, t30=0}
RS_Heartbeat:Connect(function(dt)
    TaskAccum.t5 = TaskAccum.t5 + dt; TaskAccum.t30 = TaskAccum.t30 + dt
    if TaskAccum.t5 >= 5 then
        TaskAccum.t5 = 0
        pcall(MultiRoundPlan); pcall(RoleRotation); pcall(LegendaryCheck)
        if HB_AutoSave.enabled then pcall(HB_AutoSaveTick) end
    end
    if TaskAccum.t30 >= 30 then
        TaskAccum.t30 = 0
        pcall(SnapshotState); pcall(AdversarialTick); pcall(SelfPlayTick)
    end
end)

-- BOOT
S.TrigOn = false
UI.switchMain("AIM")
UI_main.Visible = true
HB_AutoSaveLoad()
if S.ScreenStretch then HB_ApplyScreenStretch() end
task.spawn(function() task.wait(1); HB_ApplyVisuals() end)
game:BindToClose(function() HB_RemoveVisuals() end)
HB_Toast("HELLBORN v10.0 · ULTRA PRECISION carregado", "success")
print("[HELLBORN] BLOCO 2/2 OK — ULTRA PRECISION + SHARINGAN + STRETCH em VISUAL")
_G.HB_KILL = function()
    _G.HB_ALIVE = nil
    if _G.HB and _G.HB.CONNECTIONS then
        for i = 1, #_G.HB.CONNECTIONS do
            pcall(function() _G.HB.CONNECTIONS[i]:Disconnect() end)
        end
    end
    pcall(function() Camera.FieldOfView = 70 end)
    pcall(function() UIS.MouseIconEnabled = true end)
end