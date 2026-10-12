--==============================================================
-- HELLBORN v9.1 SUPREME — CORRIGIDO
-- Correções aplicadas:
--   FIX 1: SilentFire não derruba mais o personagem (sem HRP.CFrame)
--   FIX 2: Auto-flick não cancela ao soltar tecla (atira no hold)
--   FIX 3: S.RetryMiss definido no STATE (retry funciona)
--==============================================================

--========= CONSTANTES =========
local tick = os.clock
local wait, spawn, delay = task.wait, task.spawn, task.delay
local floor, sqrt, exp, log, cos, sin, atan2 = math.floor, math.sqrt, math.exp, math.log, math.cos, math.sin, math.atan2
local abs, min, max, clamp, random, pi = math.abs, math.min, math.max, math.clamp, math.random, math.pi
local newV3, newUD2, newCF, lookAt = Vector3.new, UDim2.new, CFrame.new, CFrame.lookAt
local udim, c3 = UDim.new, Color3.fromRGB
local v3zero = Vector3.zero
local tinsert, tremove, tsort = table.insert, table.remove, table.sort
local sformat, ssub, slower = string.format, string.sub, string.lower
local pairs_, ipairs_, next_ = pairs, ipairs, next
local type, typeof, tostring, tonumber = type, typeof, tostring, tonumber
local setmetatable = setmetatable

local E_GOTHAM       = Enum.Font.Gotham
local E_GOTHAM_MED   = Enum.Font.GothamMedium
local E_GOTHAM_BOLD  = Enum.Font.GothamBold
local E_GOTHAM_BLACK = Enum.Font.GothamBlack
local E_CODE         = Enum.Font.Code
local E_TXT_LEFT     = Enum.TextXAlignment.Left
local E_TXT_RIGHT    = Enum.TextXAlignment.Right
local E_TXT_TOP      = Enum.TextYAlignment.Top
local E_MOUSE1       = Enum.UserInputType.MouseButton1
local E_MOUSEMOVE    = Enum.UserInputType.MouseMovement
local E_KEYBOARD     = Enum.UserInputType.Keyboard
local E_CAM_SCRIPT   = Enum.CameraType.Scriptable
local E_AUTO_Y       = Enum.AutomaticSize.Y
local E_BACK         = Enum.EasingStyle.Back

--========= SERVIÇOS =========
local Players       = game:GetService("Players")
local UIS           = game:GetService("UserInputService")
local RS            = game:GetService("RunService")
local TweenService  = game:GetService("TweenService")
local Lighting      = game:GetService("Lighting")
local HttpService   = game:GetService("HttpService")
local SoundService  = game:GetService("SoundService")

local LP     = Players.LocalPlayer
local PG     = LP:WaitForChild("PlayerGui")
local Camera = workspace.CurrentCamera

local RS_Heartbeat = RS.Heartbeat
local RS_Render    = RS.RenderStepped

local UIS_InputBegan   = UIS.InputBegan
local UIS_InputEnded   = UIS.InputEnded
local UIS_InputChanged = UIS.InputChanged

--========= IDENTIDADE =========
local HB_V       = "v9.1"
local HB_SERIAL  = tostring(random(10000000, 99999999))
local HB_TITLE   = "HELLBORN"
local HB_X       = "HB_" .. random(10000, 99999) .. "_"
local HB_HIST_SZ = 60
local KILLLOG_SZ = 100

--========= LIMPEZA =========
for _, g in ipairs_(PG:GetChildren()) do
    if g:IsA("ScreenGui") and (g.Name:find("HB_") or g.Name:find("HELLBORN")) then
        g:Destroy()
    end
end
for _, o in ipairs_(Lighting:GetChildren()) do
    if o:IsA("BlurEffect") then o:Destroy() end
end

--========= HELPERS =========
function HB_Create(cls, props, children)
    local i = Instance.new(cls)
    local par
    if props then
        for k, v in next_, props, nil do
            if k == "Parent" then par = v
            else i[k] = v end
        end
    end
    if children then
        if typeof(children) == "Instance" then
            i.Parent = children
        else
            for j = 1, #children do children[j].Parent = i end
        end
    end
    if par then i.Parent = par end
    return i
end

function HB_Corner(p, r)
    return HB_Create("UICorner", {CornerRadius = udim(0, r or 8), Parent = p})
end

function HB_Stroke(p, c, t, tr)
    return HB_Create("UIStroke", {
        Color = c or c3(40,40,48), Thickness = t or 1,
        Transparency = tr or 0, Parent = p
    })
end

function HB_EaseS(t) return t * t * (3 - 2 * t) end

function HB_EaseBezier(t, p1, p2)
    local u = 1 - t
    return 3*u*u*t*p1 + 3*u*t*t*p2 + t*t*t
end

function HB_PointIn(pos, obj)
    if not obj or not obj.Parent then return false end
    local ap, sz = obj.AbsolutePosition, obj.AbsoluteSize
    return pos.X >= ap.X and pos.X <= ap.X + sz.X
       and pos.Y >= ap.Y and pos.Y <= ap.Y + sz.Y
end

--========= PALETA =========
Palette = {
    Base      = c3(10,10,12),
    Surface   = c3(18,18,22),
    Elevated  = c3(26,26,32),
    Elevated2 = c3(34,34,42),
    Border    = c3(40,40,50),
    TextHigh  = c3(245,245,250),
    TextMid   = c3(160,160,175),
    TextLow   = c3(100,100,115),
    Accent    = c3(220,40,40),
    Success   = c3(0,210,120),
    Warning   = c3(255,180,0),
    Danger    = c3(255,60,60),
}

Themes = {
    Red = c3(220,40,40), Blue = c3(50,130,255), Green = c3(30,200,90),
    Purple = c3(170,60,230), Cyan = c3(30,210,220), Neon = c3(0,255,180),
    Matrix = c3(0,230,70), Blood = c3(140,0,0),
}

--========= STATE =========
S = S or {}
S.AutoFlick=true S.FlickKey=Enum.KeyCode.Q S.SilentOn=true S.AIOn=true
S.AlignTol=4 S.Retries=2 S.AimSmooth=0.15 S.FlickMode="Normal"
S.TrigOn=false S.TrigRad=60 S.TrigCD=0.35
S.ESP=false S.ESPName=true S.ESP_LOD=true S.Chams=false
S.ESPArrows=false S.ESPSkeleton=false S.Radar=false S.TimelinePredictor=false
S.Hitmark=true S.KillFeed=true S.Cross=false S.CrossStyle="Cross" S.CrossSize=12
S.ESPThick=2 S.AutoSave=true S.Theme="Red" S.Humanize=true
S.RateLimit=true S.RandomAim=true S.FakeMiss=false S.ChatCommands=true
S.Kills=0 S.Deaths=0 S.Hits=0 S.Misses=0 S.Streak=0 S.BestStreak=0
S.SessionStart=tick()
S.FPSAdaptive=true S.FPSAdaptiveMinFPS=45 S.HitscanOpt=true
S.WeaponCooldownCheck=true S.AntiFlickBlock=true S.AntiFlickBackoff=2
S.PostKillDelay=true S.PostKillDelayMs=400 S.ThreatTrajectory=true
S.SmartTarget=true S.NNRate=0.01 S.PreAim=true S.StickyAim=true
S.StickyAimStrength=0.30 S.ProgressiveFlick=true S.RSIEnabled=true

-- ✅ FIX 3: RetryMiss definido (antes era nil e o retry nunca disparava)
S.RetryMiss = true

S.REV_AI = {meta=true,nas=true,cloning=true,selfPlay=true,worldModel=true,
    activeInf=true,transformer=true,moe=true,uncert=true,causal=true,
    counterfact=true,adversarial=true,transfer=true,federated=true,lifelong=true,
    selfPlayEpochs=100,uncertThreshold=0.7}
S.REV_HUMAN = {persona="calculista",personaStrength=0.7,warmup=true,warmupMin=2,
    cooldown=true,emotion=true,cognitive=true,cogMultiMax=4,fatigue=true,
    fatiguePerHour=0.05,squad=true,squadRadius=30,reputation=true,
    altDetect=true,altThreshold=0.8}
S.REV_PHYS = {ballistic=true,rayTrace=true,ik=true,animMirror=true,
    gameStateRecon=true,serverMirror=true,latency2=true,uploadMs=30,jitterBuf=true}
S.REV_SOCIAL = {antiAttr=true,misdirect=true,misdirectRate=0.15,bait=true,
    antiReport=true,antiReportRate=0.10,skillCurve=true,skillCurveHours=2,
    p2p=false,zkProof=false}
S.REV_ARCH = {rollback=true,snapshotFrames=30,diffSync=true}
S.REV_FEAT = {whatIf=true,forecast=true,director=true,directorClips=10,
    wager=true,blockchain=true}
S.REV_GAME = {multiRound=true,multiRoundDepth=5,metaGame=true,roleRot=true,
    legendary=true,legendaryThreshold=20}
S.REV_STEALTH = {advExamples=true,advEpsilon=0.05,jitterDist=true,jitterMean=0.23,
    jitterStd=0.08,antiAntiCheat=true,aacDelay=30,adaptiveRate=true,
    rateWindow=10,plausible=true}
S.REV_MAD = {neuroSym=true,quantum=true,quantumTemp=100,evolutionary=true,
    swarm=true,genetic=true,antColony=true,digitalTwin=true,sleepWake=true,
    sleepIdleThreshold=300,curriculum=true,currStage=1,dreamState=true,
    recursive=true,recursiveInterval=1000}

--========= CACHE E ESTADO =========
Cache = {Chars={}, Heads={}, HRPs={}, List={}, Set={}}
Hst = {}
Sil = {enabled=true, bspd=2500, lastFire=0, fail=0}
KillLog = {head=0, count=0, slots={}}
for i = 1, KILLLOG_SZ do
    KillLog.slots[i] = {time=0, victim=nil, dist=0, miss=false, hs=false}
end
Acc = {shots={}}
Err = {count=0, last=0}
Round = {cur=0, alive=0, start=0, time=0, phase="early"}
Game = {name="Unknown", mode="Normal"}
Weapon = {learnedSpeeds={}, lastFireTime={}}
WinRate = {murderer={w=0,l=0}, sheriff={w=0,l=0}, innocent={w=0,l=0}}
IdleSince = tick()
AntiFlickGuard = {fails=0, backoffUntil=0}
PostKillTimer = {until_=0}
FPS = {cur=60, lastT=tick()}

RevAI = {metaHistory={}, nasArchs={}, cloneBuffer={}, selfPlayGames={},
    worldState={}, causalGraph={}, adversarialCycles=0, transferCache={},
    lifelongMem={}, epochs=0}
RevHuman = {squads={}, reputa={}, emotion=0, cogLoad=0, fatigue=0}
RevPhys = {reconState={}}
RevSocial = {attributionTrail={}, misdirectCount=0, zkChain={}}
RevArch = {snapshots={}}
RevFeat = {directorBuf={}, chain={}}
RevGame = {roundPlan={}, roleHistory={}, legendary={}}
RevStealth = {rateBuf={}, plausible={}}
RevMad = {twin={}, recursive={gens=0}}

NNReal = {inputN=8, hiddenN=6, outputN=3, W1={}, b1={}, W2={}, b2={}, lr=0.01, trained=0}

--========= HST FACTORY =========
function HB_GetH(p)
    local h = Hst[p]
    if not h then
        h = {
            spX={}, spY={}, spZ={}, spT={},
            spHead=0, spCount=0,
            kalman={x={0,0,0,0,0,0}, lastT=0, gain=0.35},
            vel=v3zero, prevVel=nil, acc=v3zero,
            jit=0, stab=1, lastPos=nil, lastT=0,
            dCh=0, lastDir=nil, chase=false, chaseFr=0,
            tpIgn=0, weapon="unknown", shotsFired=0, shotsHit=0
        }
        for i = 1, HB_HIST_SZ do
            h.spX[i]=0 h.spY[i]=0 h.spZ[i]=0 h.spT[i]=0
        end
        Hst[p] = h
    end
    return h
end

function HB_KalmanPred(k, dt)
    local x = k.x
    return newV3(x[1]+x[4]*dt, x[2]+x[5]*dt, x[3]+x[6]*dt)
end

--========= REDE NEURAL =========
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
    local W1, b1 = NNReal.W1, NNReal.b1
    for i = 1, NNReal.hiddenN do
        local s = b1[i]
        local row = W1[i]
        for j = 1, NNReal.inputN do s = s + input[j] * row[j] end
        hidden[i] = math.tanh(s)
    end
    local out = {}
    local W2, b2 = NNReal.W2, NNReal.b2
    for i = 1, NNReal.outputN do
        local s = b2[i]
        local row = W2[i]
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
    local W2, b2 = NNReal.W2, NNReal.b2
    for i = 1, NNReal.outputN do
        local row = W2[i]; local e = err[i]
        for j = 1, NNReal.hiddenN do row[j] = row[j] + lr * e * hidden[j] end
        b2[i] = b2[i] + lr * e
    end
    local W1, b1 = NNReal.W1, NNReal.b1
    for j = 1, NNReal.hiddenN do
        local dh = 0
        for i = 1, NNReal.outputN do dh = dh + err[i] * W2[i][j] end
        dh = dh * (1 - hidden[j] * hidden[j])
        local row = W1[j]
        for k = 1, NNReal.inputN do row[k] = row[k] + lr * dh * input[k] end
        b1[j] = b1[j] + lr * dh
    end
    NNReal.trained = NNReal.trained + 1
end

--========= TOAST =========
function HB_Toast(msg, kind)
    kind = kind or "info"
    if not UI or not UI.Screen or not UI.Screen.Parent then return end
    if not UI.ToastHolder then
        UI.ToastHolder = HB_Create("Frame", {
            Size=newUD2(0,300,0,500), Position=newUD2(1,-320,0,20),
            BackgroundTransparency=1, Parent=UI.Screen
        })
    end
    local color = Palette.Accent
    if kind=="success" then color=Palette.Success
    elseif kind=="warning" then color=Palette.Warning
    elseif kind=="danger" then color=Palette.Danger end

    local t = HB_Create("Frame", {
        Size=newUD2(1,0,0,42), Position=newUD2(1,320,0,0),
        BackgroundColor3=Palette.Surface, BackgroundTransparency=0.05,
        BorderSizePixel=0, Parent=UI.ToastHolder
    })
    HB_Corner(t, 8); HB_Stroke(t, color, 1.5, 0.3)
    HB_Create("Frame", {
        Size=newUD2(0,3,1,-12), Position=newUD2(0,6,0,6),
        BackgroundColor3=color, BorderSizePixel=0, Parent=t
    })
    HB_Create("TextLabel", {
        Size=newUD2(1,-20,1,0), Position=newUD2(0,14,0,0),
        BackgroundTransparency=1, Text=msg,
        Font=E_GOTHAM, TextSize=12, TextColor3=Palette.TextHigh,
        TextXAlignment=E_TXT_LEFT, TextWrapped=true, Parent=t
    })
    local ex = {}
    for _, c in ipairs_(UI.ToastHolder:GetChildren()) do
        if c:IsA("Frame") and c ~= t then ex[#ex+1] = c end
    end
    for i = 1, #ex do
        TweenService:Create(ex[i], TweenInfo.new(0.2),
            {Position = newUD2(0,0,0,(i-1)*48)}):Play()
    end
    TweenService:Create(t, TweenInfo.new(0.3),
        {Position = newUD2(0,0,0,#ex*48)}):Play()
    delay(3, function() t:Destroy() end)
end
HBToast = HB_Toast

--========= PLAYER CACHE =========
function HB_RebuildList()
    local t = {}
    local set = Cache.Set
    for p in next_, set, nil do t[#t+1] = p end
    Cache.List = t
end

function HB_HookChar(p)
    local function onChar(c)
        Cache.Chars[p] = c
        wait(0.25)
        Cache.Heads[p] = c:FindFirstChild("Head")
        Cache.HRPs[p]  = c:FindFirstChild("HumanoidRootPart")
    end
    p.CharacterAdded:Connect(onChar)
    if p.Character then onChar(p.Character) end
end

function HB_AddPlayer(p)
    Cache.Set[p] = true
    HB_HookChar(p)
    HB_RebuildList()
end

function HB_RemovePlayer(p)
    Cache.Set[p] = nil
    Cache.Chars[p] = nil; Cache.Heads[p] = nil; Cache.HRPs[p] = nil
    Hst[p] = nil
    HB_RebuildList()
end

for _, p in ipairs_(Players:GetPlayers()) do HB_AddPlayer(p) end
Players.PlayerAdded:Connect(HB_AddPlayer)
Players.PlayerRemoving:Connect(HB_RemovePlayer)

--========= ARMAS =========
local MURD_NAMES = {"Knife","Cleaver","Blade","Sword","Dagger","Machete"}
local GUN_NAMES  = {"Gun","Revolver","Pistol","Sheriff","Firearm","Taser"}
local MURD_LOWER, GUN_LOWER = {}, {}
for i = 1, #MURD_NAMES do MURD_LOWER[i] = slower(MURD_NAMES[i]) end
for i = 1, #GUN_NAMES  do GUN_LOWER[i]  = slower(GUN_NAMES[i])  end

function HB_FindTool(player)
    if player.Character then
        for _, t in ipairs_(player.Character:GetChildren()) do
            if t:IsA("Tool") then return t.Name end
        end
    end
    local bp = player:FindFirstChild("Backpack") or player:FindFirstChildOfClass("Backpack")
    if bp then
        for _, t in ipairs_(bp:GetChildren()) do
            if t:IsA("Tool") then return t.Name end
        end
    end
    return nil
end

--========= GETROLE =========
local RoleCache     = setmetatable({}, {__mode = "k"})
local RoleCacheTime = 0
local ROLE_TTL      = 0.25
local ROLE_ATTRS = {"Role","role","Team","team","Class","class"}

function GetRole(p)
    if not p then return "Innocent" end
    local now = tick()
    if now - RoleCacheTime > ROLE_TTL then
        RoleCache = setmetatable({}, {__mode = "k"})
        RoleCacheTime = now
    end
    local cached = RoleCache[p]
    if cached then return cached end

    local role = "Innocent"
    local ch = Cache.Chars[p]
    if ch and ch.Parent then
        local tool = ch:FindFirstChildOfClass("Tool")
        if not tool then
            local bag = p:FindFirstChild("Backpack")
            if bag then
                for _, t in ipairs_(bag:GetChildren()) do
                    if t:IsA("Tool") then tool = t; break end
                end
            end
        end
        if tool and tool:IsA("Tool") then
            local n = slower(tool.Name)
            for i = 1, #MURD_LOWER do
                if n:find(MURD_LOWER[i], 1, true) then
                    RoleCache[p] = "Murderer"; return "Murderer"
                end
            end
            for i = 1, #GUN_LOWER do
                if n:find(GUN_LOWER[i], 1, true) then
                    RoleCache[p] = "Sheriff"; return "Sheriff"
                end
            end
        end
        local hum = ch:FindFirstChildOfClass("Humanoid")
        if hum and hum.Health > 0 then
            for i = 1, 6 do
                local ok, val = pcall(p.GetAttribute, p, ROLE_ATTRS[i])
                if ok and val then
                    local v = slower(tostring(val))
                    if v:find("murder",1,true) or v:find("killer",1,true) or v:find("assassin",1,true) then
                        RoleCache[p] = "Murderer"; return "Murderer"
                    elseif v:find("sheriff",1,true) or v:find("cop",1,true) or v:find("deputy",1,true) then
                        RoleCache[p] = "Sheriff"; return "Sheriff"
                    end
                end
            end
        end
    end
    RoleCache[p] = role
    return role
end

--========= HB_UpdateH =========
function HB_UpdateH(p, pos, hum)
    local h = HB_GetH(p)
    local now = tick()
    local px, py, pz = pos.X, pos.Y, pos.Z
    local lastPos = h.lastPos

    if lastPos and (now - h.lastT) < 0.1 then
        local ddx, ddy, ddz = px-lastPos.X, py-lastPos.Y, pz-lastPos.Z
        if (ddx*ddx + ddy*ddy + ddz*ddz) > 2500 then
            h.tpIgn = now; return
        end
    end
    if now - h.tpIgn < 0.5 then return end

    local k = h.kalman
    if k.lastT == 0 then k.lastT = now end
    local dt = now - k.lastT
    if dt < 1/120 then dt = 1/120 end
    k.lastT = now
    local x = k.x; local gain = k.gain
    local pr, e
    pr = x[1]+x[4]*dt; e = px-pr; x[1]=pr+gain*e; x[4]=x[4]+(e/dt)*0.4
    pr = x[2]+x[5]*dt; e = py-pr; x[2]=pr+gain*e; x[5]=x[5]+(e/dt)*0.4
    pr = x[3]+x[6]*dt; e = pz-pr; x[3]=pr+gain*e; x[6]=x[6]+(e/dt)*0.4

    local idx = h.spHead + 1
    if idx > HB_HIST_SZ then idx = 1 end
    h.spHead = idx
    h.spX[idx]=px; h.spY[idx]=py; h.spZ[idx]=pz; h.spT[idx]=now
    if h.spCount < HB_HIST_SZ then h.spCount = h.spCount + 1 end

    if lastPos and h.lastT > 0 then
        local dt2 = now - h.lastT
        if dt2 > 0.001 then
            local invdt2 = 1 / dt2
            local vx = (px - lastPos.X) * invdt2
            local vy = (py - lastPos.Y) * invdt2
            local vz = (pz - lastPos.Z) * invdt2
            h.vel = h.vel:Lerp(newV3(vx, vy, vz), 0.4)
            if h.prevVel then
                h.acc = h.acc:Lerp((h.vel - h.prevVel) * invdt2, 0.25)
            end
            h.prevVel = h.vel
            local vMag = h.vel.Magnitude
            if vMag > 1 then
                local inv = 1/vMag
                local dx, dy, dz = h.vel.X*inv, h.vel.Y*inv, h.vel.Z*inv
                local ld = h.lastDir
                if ld and (dx*ld.X + dy*ld.Y + dz*ld.Z) < 0.3 then h.dCh = h.dCh + 1 end
                h.lastDir = newV3(dx, dy, dz)
            end
            local lpHrp = Cache.HRPs[LP]
            if lpHrp then
                local lpP = lpHrp.Position
                local tx, ty, tz = lpP.X-px, lpP.Y-py, lpP.Z-pz
                local tm = sqrt(tx*tx+ty*ty+tz*tz)
                if tm > 0.1 then
                    local dot = (h.vel.X*tx + h.vel.Y*ty + h.vel.Z*tz) / (vMag * tm + 1e-9)
                    if dot > 0.7 then h.chaseFr = h.chaseFr + 1
                    else h.chaseFr = h.chaseFr > 0 and h.chaseFr - 1 or 0 end
                    h.chase = h.chaseFr > 20
                end
            end
            local ch = Cache.Chars[p]
            if ch then
                if ch:FindFirstChild("Knife") then h.weapon = "knife"
                elseif ch:FindFirstChild("Gun") then h.weapon = "gun" end
            end
        end
    end
    h.lastPos = pos
    h.lastT   = now

    local cnt = h.spCount
    if cnt >= 5 then
        local sd = 0
        local head = h.spHead
        for i = 1, 4 do
            local cur = head - i + 1
            if cur < 1 then cur = cur + HB_HIST_SZ end
            local prev = cur - 1
            if prev < 1 then prev = prev + HB_HIST_SZ end
            local ddx = h.spX[cur] - h.spX[prev]
            local ddy = h.spY[cur] - h.spY[prev]
            local ddz = h.spZ[cur] - h.spZ[prev]
            sd = sd + sqrt(ddx*ddx + ddy*ddy + ddz*ddz)
        end
        h.jit = sd / 4
        h.stab = clamp(1 - h.jit * 2, 0, 1)
    end
end

--========= FPS + TRACKING =========
local _fpsFrameCount = 0
local TrackAccum = 0
local TRACK_INTERVAL = 0.05

RS_Render:Connect(function()
    _fpsFrameCount = _fpsFrameCount + 1
    local now = tick()
    if now - FPS.lastT >= 0.5 then
        FPS.cur = _fpsFrameCount / (now - FPS.lastT)
        _fpsFrameCount = 0
        FPS.lastT = now
    end
end)

RS_Heartbeat:Connect(function(dt)
    TrackAccum = TrackAccum + dt
    if TrackAccum < TRACK_INTERVAL then return end
    TrackAccum = 0

    local lpHrp = Cache.HRPs[LP]
    if not lpHrp then return end
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
--========= ARMAS =========
function FindWeapon()
    if not LP.Character then return nil end
    local eq = LP.Character:FindFirstChildOfClass("Tool")
    if eq then return eq end
    local bp = LP:FindFirstChild("Backpack")
    if bp then
        for _, t in ipairs_(bp:GetChildren()) do
            if t:IsA("Tool") then return t end
        end
    end
    return nil
end

function EquipWeapon(tool)
    if not tool or not LP.Character then return false end
    if tool.Parent == LP.Character then return true end
    local h = LP.Character:FindFirstChildOfClass("Humanoid")
    if not h then return false end
    return pcall(function() h:EquipTool(tool) end)
end

function GetWeaponSpeed(tool)
    if not tool then return Sil.bspd end
    local n = slower(tool.Name)
    if n:find("knife") or n:find("cleaver") then return Weapon.learnedSpeeds.knife or 1200 end
    if n:find("revolver") or n:find("pistol") then return Weapon.learnedSpeeds.pistol or 2800 end
    if n:find("gun") then return Weapon.learnedSpeeds.gun or 3000 end
    return Sil.bspd
end

function IsHitscan(tool)
    if not tool then return false end
    local n = slower(tool.Name)
    return n:find("knife") ~= nil or n:find("cleaver") ~= nil or n:find("sword") ~= nil
end

function IsWeaponOnCooldown(tool)
    if not S.WeaponCooldownCheck or not tool then return false end
    local last = Weapon.lastFireTime[tool]
    return last ~= nil and (tick() - last) < 0.3
end

--========= SILENTFIRE (CORRIGIDO — não derruba mais o personagem) =========
function SilentFire(tool, aimPos)
    if not tool or not aimPos then return false end

    if S.RateLimit then
        local rb = RevStealth.rateBuf
        local now = tick()
        for i = #rb, 1, -1 do
            if now - rb[i] > 1 then tremove(rb, i) end
        end
        if #rb >= 15 then return false end
        rb[#rb+1] = now
    end

    local now = tick()
    if S.AntiFlickBlock and now < AntiFlickGuard.backoffUntil then return false end
    -- ✅ reduzido de 0.2 para 0.12 (permite disparo mais rápido em retries)
    if now - Sil.lastFire < 0.12 then return false end
    Sil.lastFire = now

    if S.FakeMiss and random() < 0.01 then
        aimPos = aimPos + newV3(
            (random()-0.5)*4, (random()-0.5)*4, (random()-0.5)*4
        )
    end

    local handle = tool:FindFirstChild("Handle")
    local lpCh = LP.Character
    if not lpCh then return false end

    local hum  = lpCh:FindFirstChildOfClass("Humanoid")
    local head = lpCh:FindFirstChild("Head")

    -- ✅ FIX 1: NÃO mexer em HRP.CFrame — era isso que fazia o boneco CAIR.
    -- Guardamos o AutoRotate para restaurar depois.
    local oldAuto = hum and hum.AutoRotate
    if hum then hum.AutoRotate = false end

    -- Só apontamos o Handle (a arma) e a Head (para hitscan)
    if handle then
        handle.CFrame = lookAt(handle.Position, aimPos)
    end
    if head then
        pcall(function()
            head.CFrame = lookAt(head.Position, aimPos)
        end)
    end

    -- Compatibilidade MM2: força mouse.Target para o alvo
    local mouse = LP:GetMouse()
    local fakePart
    if mouse then
        pcall(function()
            fakePart = Instance.new("Part")
            fakePart.Size = Vector3.new(0.1,0.1,0.1)
            fakePart.Transparency = 1
            fakePart.CanCollide = false
            fakePart.Anchored = true
            fakePart.CFrame = CFrame.new(aimPos)
            fakePart.Parent = workspace
            mouse.Target = fakePart
        end)
    end

    local ok = pcall(function() tool:Activate() end)

    -- ✅ Restaura AutoRotate
    if hum then hum.AutoRotate = oldAuto end
    if fakePart then
        task.delay(0.05, function() if fakePart then fakePart:Destroy() end end)
    end

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

--========= META / CLONING / SELFPLAY =========
function MetaLearnUpdate(perf)
    if not S.REV_AI.meta then return end
    local snap = (Flick and Flick.snapDur) or 0.045
    local hist = RevAI.metaHistory
    hist[#hist+1] = {perf=perf, snap=snap, t=tick()}
    if #hist > 100 then tremove(hist, 1) end
    if #hist >= 20 and Flick then
        local sorted = {}
        for i = 1, #hist do sorted[i] = hist[i] end
        tsort(sorted, function(a,b) return a.perf > b.perf end)
        local s = 0
        local n = min(5, #sorted)
        for i = 1, n do s = s + sorted[i].snap end
        Flick.snapDur = Flick.snapDur * 0.7 + (s/n) * 0.3
        RevAI.epochs = RevAI.epochs + 1
    end
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
                HB_NNTrain(
                    {s.inp.X,s.inp.Y,s.inp.Z,s.out.X,s.out.Y,s.out.Z,0.5,0},
                    {s.out.X, s.out.Y, s.out.Z}
                )
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
        for _ = 1, 10 do
            HB_NNTrain({0,0,0,0,0,0,0.5,0.2},
                {random()-0.5, random()-0.5, random()-0.5})
        end
    end
end

function WorldModelPredict(p, dt)
    if not S.REV_AI.worldModel then return nil end
    local h = Hst[p]
    if not h or h.spCount < 5 then return nil end
    local state = RevAI.worldState[p] or {pos=h.lastPos, vel=h.vel}
    if not state.pos then return nil end
    return state.pos + state.vel * dt
end

function ActiveInference(p)
    if not S.REV_AI.activeInf or not p then return nil end
    local h = Hst[p]
    if not h or h.spCount < 3 then return nil end
    local n = h.spCount < 10 and h.spCount or 10
    local head = h.spHead
    local sx, sy, sz = 0, 0, 0
    for i = 0, n-1 do
        local j = head - i
        if j < 1 then j = j + HB_HIST_SZ end
        sx=sx+h.spX[j]; sy=sy+h.spY[j]; sz=sz+h.spZ[j]
    end
    return newV3(sx/n, sy/n, sz/n), 1
end

function AttentionPredict(h, futureTime)
    if not S.REV_AI.transformer or h.spCount < 10 then return nil end
    local n = h.spCount < 20 and h.spCount or 20
    local head = h.spHead
    local sumW, wx, wy, wz = 0, 0, 0, 0
    for i = 1, n do
        local j = head - i + 1
        if j < 1 then j = j + HB_HIST_SZ end
        local w = exp(-(n-i)/4)
        wx=wx+h.spX[j]*w; wy=wy+h.spY[j]*w; wz=wz+h.spZ[j]*w
        sumW = sumW + w
    end
    if sumW == 0 then return nil end
    local invW = 1/sumW
    return newV3(wx*invW, wy*invW, wz*invW) + h.vel * futureTime * 0.7
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
    for i = 0, n-1 do
        local j = head - i
        if j < 1 then j = j + HB_HIST_SZ end
        sx=sx+h.spX[j]; sy=sy+h.spY[j]; sz=sz+h.spZ[j]
    end
    sx, sy, sz = sx/n, sy/n, sz/n
    local v = 0
    for i = 0, n-1 do
        local j = head - i
        if j < 1 then j = j + HB_HIST_SZ end
        local dx, dy, dz = h.spX[j]-sx, h.spY[j]-sy, h.spZ[j]-sz
        v = v + dx*dx + dy*dy + dz*dz
    end
    return 1 / (1 + sqrt(v/n))
end

function CounterfactualSim(tp, camPos)
    if not S.REV_AI.counterfact then return nil end
    local h = Hst[tp]
    if not h then return nil end
    return h.lastPos + h.vel * 0.03
end

function AdversarialTick()
    if not S.REV_AI.adversarial then return end
    RevAI.adversarialCycles = RevAI.adversarialCycles + 1
    if RevAI.adversarialCycles % 30 == 0 then
        for _ = 1, 5 do
            HB_NNTrain(
                {random(),random(),random(),random(),random(),random(),random(),random()},
                {random()-0.5, random()-0.5, random()-0.5}
            )
        end
    end
end

function LifelongStore(input, target)
    if not S.REV_AI.lifelong then return end
    local key = sformat("%.2f_%.2f_%.2f", input[1], input[2], input[3])
    RevAI.lifelongMem[key] = {inp=input, out=target, t=tick()}
end

function LifelongRecall(input)
    if not S.REV_AI.lifelong then return nil end
    return RevAI.lifelongMem[sformat("%.2f_%.2f_%.2f", input[1], input[2], input[3])]
end

--========= PERSONAS / HUMAN =========
PersonaPresets = {
    aggressive   = {snapMul=0.7, holdMul=1.3, smoothMul=0.5, reactMin=0.05, reactMax=0.12},
    cautious     = {snapMul=1.3, holdMul=0.9, smoothMul=1.8, reactMin=0.12, reactMax=0.22},
    imprevisivel = {snapMul=1.2, holdMul=1.0, smoothMul=1.2, reactMin=0.06, reactMax=0.28},
    calculista   = {snapMul=0.9, holdMul=1.1, smoothMul=1.0, reactMin=0.10, reactMax=0.16},
    casual       = {snapMul=1.5, holdMul=0.8, smoothMul=2.0, reactMin=0.15, reactMax=0.35},
}

function PersonaApply()
    if not S.REV_HUMAN then return end
    local p = PersonaPresets[S.REV_HUMAN.persona]
    if not p or not Flick then return end
    local st = S.REV_HUMAN.personaStrength or 0.7
    Flick.snapDur = Flick.snapDur*(1-st) + (0.045*p.snapMul)*st
    Flick.holdDur = Flick.holdDur*(1-st) + (0.15*p.holdMul)*st
    S.AimSmooth = S.AimSmooth*(1-st) + (0.15*p.smoothMul)*st
    S.ReactMin = p.reactMin
    S.ReactMax = p.reactMax
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
    local rk, rd = 0, 0
    local now = tick()
    local k = KillLog
    local head = k.head
    local cnt = k.count
    local slots = k.slots
    for i = 1, cnt do
        local j = head - i + 1
        if j < 1 then j = j + KILLLOG_SZ end
        local s = slots[j]
        if now - s.time < 120 then
            if s.miss then rd = rd + 1 else rk = rk + 1 end
        end
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
                            local sq = RevHuman.squads[p1] or {}
                            RevHuman.squads[p1] = sq
                            sq[p2] = true
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
    if not r then
        r = {kills=0, deaths=0, lastSeen=tick()}
        RevHuman.reputa[p] = r
    end
    if isKill then r.kills = r.kills + 1 else r.deaths = r.deaths + 1 end
    r.lastSeen = tick()
end

function AltDetect(p)
    if not S.REV_HUMAN or not S.REV_HUMAN.altDetect then return false end
    local score = 0
    if p.AccountAge and p.AccountAge < 30 then score = score + 0.3 end
    if #p.Name < 6 then score = score + 0.2 end
    return score > (S.REV_HUMAN.altThreshold or 0.8)
end

--========= PHYS =========
function BallisticSim(origin, targetPos, tool)
    if not S.REV_PHYS or not S.REV_PHYS.ballistic then return targetPos end
    local n = tool and slower(tool.Name) or ""
    if n:find("knife") then return targetPos end
    local dist = (targetPos-origin).Magnitude
    local bspd = GetWeaponSpeed(tool)
    local t = dist / bspd
    return newV3(targetPos.X, targetPos.Y + 0.5*196.2*t*t, targetPos.Z)
end

function IKPrediction(char, ft)
    if not S.REV_PHYS or not S.REV_PHYS.ik then return nil end
    local head = char:FindFirstChild("Head")
    local hrp = char:FindFirstChild("HumanoidRootPart")
    if not head or not hrp then return nil end
    return head.Position + hrp.CFrame.LookVector * ft * 20
end

function AnimPredict(char, ft)
    if not S.REV_PHYS or not S.REV_PHYS.animMirror then return nil end
    local head = char:FindFirstChild("Head")
    if not head then return nil end
    return head.Position
end

function GameStateRecon()
    if not S.REV_PHYS or not S.REV_PHYS.gameStateRecon then return end
    RevPhys.reconState = {}
    for i = 1, #Cache.List do
        local p = Cache.List[i]
        if p ~= LP then
            local hrp = Cache.HRPs[p]
            if hrp then RevPhys.reconState[p] = hrp.Position end
        end
    end
end

function ServerMirror(tp, pred)
    if not S.REV_PHYS or not S.REV_PHYS.serverMirror then return pred end
    return pred
end

function JitterBuffer(p)
    if not S.REV_PHYS or not S.REV_PHYS.jitterBuf then return nil end
    local h = Hst[p]
    if not h or h.spCount < 3 then return nil end
    local j = h.spHead - 3
    if j < 1 then j = j + HB_HIST_SZ end
    return newV3(h.spX[j], h.spY[j], h.spZ[j])
end

--========= SOCIAL =========
function AntiAttribution(p)
    if not S.REV_SOCIAL or not S.REV_SOCIAL.antiAttr then return end
    RevSocial.attributionTrail[p] = RevSocial.attributionTrail[p] or {lastFake=0}
end

function Misdirect()
    if not S.REV_SOCIAL or not S.REV_SOCIAL.misdirect then return false end
    if random() < (S.REV_SOCIAL.misdirectRate or 0.15) then
        RevSocial.misdirectCount = RevSocial.misdirectCount + 1
        return true
    end
    return false
end

function AntiReportGesture()
    if not S.REV_SOCIAL or not S.REV_SOCIAL.antiReport then return false end
    return random() < (S.REV_SOCIAL.antiReportRate or 0.10)
end

function SkillCurveFactor()
    if not S.REV_SOCIAL or not S.REV_SOCIAL.skillCurve then return 1 end
    local h = (tick()-S.SessionStart)/3600
    return min(1, 0.75 + (h/(S.REV_SOCIAL.skillCurveHours or 2))*0.25)
end

--========= ARCH / FEAT / GAME / STEALTH / MAD =========
function SnapshotState()
    if not S.REV_ARCH or not S.REV_ARCH.rollback then return end
    local snaps = RevArch.snapshots
    snaps[#snaps+1] = {t=tick(), kills=S.Kills, deaths=S.Deaths}
    if #snaps > (S.REV_ARCH.snapshotFrames or 30) then tremove(snaps, 1) end
end

function DiffSync(key, value)
    if not S.REV_ARCH or not S.REV_ARCH.diffSync then return value end
    return value
end

function ThreatForecast(p, sec)
    if not S.REV_FEAT or not S.REV_FEAT.forecast then return nil end
    local h = Hst[p]
    if not h or h.spCount < 5 then return nil end
    return h.lastPos + h.vel*sec + 0.5*h.acc*sec*sec
end

function DirectorRecord(evt)
    if not S.REV_FEAT or not S.REV_FEAT.director then return end
    local buf = RevFeat.directorBuf
    buf[#buf+1] = {event=evt, t=tick()}
    if #buf > (S.REV_FEAT.directorClips or 10)*10 then tremove(buf, 1) end
end

function WagerPredict()
    if not S.REV_FEAT or not S.REV_FEAT.wager then return nil end
    local alive, murdererAlive = 0, false
    for i = 1, #Cache.List do
        local p = Cache.List[i]
        local ch = Cache.Chars[p]
        if ch then
            local hum = ch:FindFirstChildOfClass("Humanoid")
            if hum and hum.Health > 0 then
                alive = alive + 1
                if GetRole(p) == "Murderer" then murdererAlive = true end
            end
        end
    end
    return {conf=0.5+(murdererAlive and 0.2 or -0.3), alive=alive}
end

function BlockchainAdd(entry)
    if not S.REV_FEAT or not S.REV_FEAT.blockchain then return end
    local chain = RevFeat.chain
    local prev = #chain > 0 and chain[#chain].hash or "0"
    local data = prev .. "|" .. entry .. "|" .. tick()
    local hash = 0
    for i = 1, #data do
        hash = (hash*31 + data:byte(i)) % 2147483647
    end
    chain[#chain+1] = {entry=entry, hash=hash, prev=prev, t=tick()}
    if #chain > 500 then tremove(chain, 1) end
end

function MultiRoundPlan()
    if not S.REV_GAME or not S.REV_GAME.multiRound then return end
    RevGame.roundPlan = {}
    for i = 1, (S.REV_GAME.multiRoundDepth or 5) do
        RevGame.roundPlan[i] = {round=Round.cur+i}
    end
end

function RoleRotation()
    if not S.REV_GAME or not S.REV_GAME.roleRot then return end
    local myRole = GetRole(LP)
    local h = RevGame.roleHistory
    h[#h+1] = {role=myRole, t=tick()}
    if #h > 10 then tremove(h, 1) end
end

function LegendaryCheck()
    if not S.REV_GAME or not S.REV_GAME.legendary then return end
    if S.Kills >= (S.REV_GAME.legendaryThreshold or 20)
        and not RevGame.legendary.active then
        RevGame.legendary.active = true
    end
end

function AdversarialNoise(aimPos)
    if not S.REV_STEALTH or not S.REV_STEALTH.advExamples then return aimPos end
    local eps = S.REV_STEALTH.advEpsilon or 0.05
    return aimPos + newV3(
        (random()-0.5)*eps, (random()-0.5)*eps, (random()-0.5)*eps
    )
end

function JitterMatchDelay()
    if not S.REV_STEALTH or not S.REV_STEALTH.jitterDist then return random()*0.1 end
    local mean = S.REV_STEALTH.jitterMean or 0.23
    local std  = S.REV_STEALTH.jitterStd  or 0.08
    local u1, u2 = random(), random()
    local z = sqrt(-2*log(u1)) * cos(2*pi*u2)
    return max(0.05, mean + z*std)
end

function AntiAntiCheatCheck()
    if not S.REV_STEALTH or not S.REV_STEALTH.antiAntiCheat then return true end
    if RevStealth.aac and RevStealth.aac > 0 and tick() < RevStealth.aac then return false end
    if Err.count > 10 then
        RevStealth.aac = tick() + (S.REV_STEALTH.aacDelay or 30)
        Err.count = 0
        return false
    end
    return true
end

function AdaptiveRateCheck()
    if not S.REV_STEALTH or not S.REV_STEALTH.adaptiveRate then return true end
    local rb = RevStealth.rateBuf
    local now = tick()
    for i = #rb, 1, -1 do
        if now - rb[i] > (S.REV_STEALTH.rateWindow or 10) then tremove(rb, i) end
    end
    rb[#rb+1] = now
    return #rb < 20
end

function PlausibleDefense()
    if not S.REV_STEALTH or not S.REV_STEALTH.plausible then return end
    RevStealth.plausible.lastClaim = tick()
end

function NeuroSymbolic(input)
    if not S.REV_MAD or not S.REV_MAD.neuroSym then return nil end
    return HB_NNForward(input)
end

function QuantumAnnealing(cands, costFn)
    if not S.REV_MAD or not S.REV_MAD.quantum then return cands[1] end
    local temp = S.REV_MAD.quantumTemp or 100
    local cur = cands[random(1, #cands)]
    local curC = costFn(cur)
    for _ = 1, 50 do
        temp = temp * 0.95
        local nxt = cands[random(1, #cands)]
        local nxtC = costFn(nxt)
        if nxtC < curC or random() < exp((curC-nxtC)/temp) then
            cur, curC = nxt, nxtC
        end
    end
    return cur
end

function SwarmStep(nodes, target)
    if not S.REV_MAD or not S.REV_MAD.swarm then return nil end
    local best, bestD = nil, math.huge
    for i = 1, #nodes do
        local n = nodes[i]
        local d = (n-target).Magnitude
        if d < bestD then bestD = d; best = n end
    end
    return best
end

function DigitalTwinUpdate()
    if not S.REV_MAD or not S.REV_MAD.digitalTwin then return end
    RevMad.twin.players = {}
    for i = 1, #Cache.List do
        local p = Cache.List[i]
        if p ~= LP then
            local hrp = Cache.HRPs[p]
            if hrp then
                RevMad.twin.players[p] = {
                    pos = hrp.Position,
                    vel = hrp.AssemblyLinearVelocity or v3zero
                }
            end
        end
    end
end

function SleepWakeTick()
    if not S.REV_MAD or not S.REV_MAD.sleepWake then return end
    if tick() - IdleSince > (S.REV_MAD.sleepIdleThreshold or 300) then
        for _ = 1, 5 do
            HB_NNTrain(
                {random(),random(),random(),random(),random(),random(),random(),random()},
                {random()-0.5, random()-0.5, random()-0.5}
            )
        end
    end
end

function CurriculumAdvance()
    if not S.REV_MAD or not S.REV_MAD.curriculum then return end
    if Acc.rate() > 0.7 and NNReal.trained > 500 then
        S.REV_MAD.currStage = min(5, (S.REV_MAD.currStage or 1)+1)
    end
end

function DreamTrain()
    if not S.REV_MAD or not S.REV_MAD.dreamState then return end
    if tick() - IdleSince > 600 then
        for _ = 1, 10 do
            HB_NNTrain(
                {random(),random(),random(),random(),random(),random(),random(),random()},
                {random()-0.5, random()-0.5, random()-0.5}
            )
        end
    end
end

function RecursiveImprove()
    if not S.REV_MAD or not S.REV_MAD.recursive then return end
    local interval = S.REV_MAD.recursiveInterval or 1000
    if S.Kills > 0 and S.Kills % interval == 0 then
        NNReal.lr = NNReal.lr * (1 + (Acc.rate()-0.5)*0.1)
        RevMad.recursive.gens = (RevMad.recursive.gens or 0) + 1
    end
end

--========= ACC / KILL LOG =========
Acc.push = function(hit)
    local s = Acc.shots
    s[#s+1] = hit and true or false
    if #s > 50 then tremove(s, 1) end
end

Acc.rate = function()
    local s = Acc.shots
    if #s == 0 then return 0 end
    local h = 0
    for i = 1, #s do
        if s[i] then h = h + 1 end
    end
    return h / #s
end

function LogKill(victim, dist, hs)
    local k = KillLog
    local idx = k.head + 1
    if idx > KILLLOG_SZ then idx = 1 end
    k.head = idx
    if k.count < KILLLOG_SZ then k.count = k.count + 1 end
    local s = k.slots[idx]
    s.time = tick(); s.victim = victim; s.dist = dist; s.miss = false; s.hs = hs
    S.Kills = S.Kills + 1
    S.Streak = (S.Streak or 0) + 1
    if S.Streak > (S.BestStreak or 0) then S.BestStreak = S.Streak end
end

function LogMiss(victim)
    local k = KillLog
    local idx = k.head + 1
    if idx > KILLLOG_SZ then idx = 1 end
    k.head = idx
    if k.count < KILLLOG_SZ then k.count = k.count + 1 end
    local s = k.slots[idx]
    s.time = tick(); s.victim = victim; s.dist = 0; s.miss = true
    S.Streak = 0
end

--========= COMPUTE AIM =========
function ComputeAim(tp, tch, camPos, tool)
    if not tch or not tch.Parent then return nil end
    local head = tch:FindFirstChild("Head")
    if not head then return nil end
    local h = Hst[tp]
    if not h then return nil end

    local posNow = head.Position
    local dx, dy, dz = posNow.X-camPos.X, posNow.Y-camPos.Y, posNow.Z-camPos.Z
    local dist = sqrt(dx*dx + dy*dy + dz*dz)
    local bspd = GetWeaponSpeed(tool)
    local pingSec = LP:GetNetworkPing()
    local totalTime = dist/bspd + pingSec*0.5 + 0.010

    if S.HitscanOpt and IsHitscan(tool) then return posNow, 0.02, dist end

    local base = HB_KalmanPred(h.kalman, totalTime)

    if NNReal.trained > 50 then
        local nnOut = HB_NNForward({
            h.vel.X, h.vel.Y, h.vel.Z,
            h.acc.X, h.acc.Y, h.acc.Z,
            h.stab, pingSec
        })
        if nnOut then
            base = base:Lerp(posNow + newV3(nnOut[1],nnOut[2],nnOut[3]) * totalTime * 10, 0.3)
        end
    end

    local wm = WorldModelPredict(tp, totalTime)
    if wm then base = base:Lerp(wm, 0.25) end

    local aiMean = ActiveInference(tp)
    if aiMean then base = base:Lerp(aiMean, 0.2) end

    local attn = AttentionPredict(h, totalTime)
    if attn then base = base:Lerp(attn, 0.25) end

    local expert = MoEExperts(dist, h.stab, h.weapon)
    if expert == 1 then base = base + h.vel * totalTime * 0.3
    elseif expert == 2 then base = base:Lerp(posNow, 0.3)
    elseif expert == 3 then return posNow, 0.01, dist
    elseif expert == 4 then base = base:Lerp(HB_KalmanPred(h.kalman, totalTime), 0.5) end

    local cf = CounterfactualSim(tp, camPos)
    if cf then base = base:Lerp(cf, 0.15) end

    local uncert = Uncertainty(h)
    if S.REV_AI.uncert and uncert < S.REV_AI.uncertThreshold and h.stab < 0.3 then
        return nil
    end

    local mem = LifelongRecall({h.vel.X, h.vel.Y, h.vel.Z})
    if mem then base = base:Lerp(newV3(mem.out[1], mem.out[2], mem.out[3]), 0.1) end

    local humanMul = WarmupFactor() * CooldownFactor() * CognitiveLoad()
                     * FatigueFactor() * SkillCurveFactor()
    if humanMul < 0.95 then
        local blur = (1-humanMul) * 2
        base = base + newV3(
            (random()-0.5)*blur, (random()-0.5)*blur, (random()-0.5)*blur
        )
    end

    base = BallisticSim(camPos, base, tool)

    local ik = IKPrediction(tch, totalTime)
    if ik then base = base:Lerp(ik, 0.2) end

    local ap = AnimPredict(tch, totalTime)
    if ap then base = base:Lerp(ap, 0.15) end

    base = ServerMirror(tp, base)

    local jb = JitterBuffer(tp)
    if jb then base = base:Lerp(jb, 0.2) end

    if Misdirect() then return nil end
    if AntiReportGesture() then return nil end

    base = AdversarialNoise(base)

    if S.REV_AI.cloning and random() < 0.05 then
        BehaviourClone(posNow - camPos, base - camPos)
    end

    return base, totalTime, dist
end

--========= FLICK STATE =========
Flick = {
    active=false, phase="idle", snapStartTick=0,
    snapDur=0.045, holdDur=0.15, returnDur=0.10, verifyWait=0.50,
    targetPlayer=nil, targetChar=nil, targetHumanoid=nil,
    aimPos=nil, originCF=nil, originLookAt=nil,
    originalCameraType=nil, originalCameraSubject=nil,
    shotsFired=0, killed=false, hitVerified=false,
    hpBefore=100, verifyStart=0, retriesLeft=2,
    lastFlickEnd=0, triggeredBy="manual", keyHeld=false,
    returnStartTick=0, returnStartCF=nil, returnTargetCF=nil,
    holdStartTick=0,
}

TriggerSuppressUntil = 0

function FindMurderQueue()
    local origin
    local lpHrp = Cache.HRPs[LP]
    if lpHrp then origin = lpHrp.Position else origin = Camera.CFrame.Position end
    local cands = {}
    local list = Cache.List
    for i = 1, #list do
        local p = list[i]
        if p ~= LP and GetRole(p) == "Murderer" then
            local ch = Cache.Chars[p]
            local hrp = Cache.HRPs[p]
            if ch and ch.Parent and hrp then
                local hum = ch:FindFirstChildOfClass("Humanoid")
                if hum and hum.Health > 0 then
                    local d = (hrp.Position - origin).Magnitude
                    if d < 500 then
                        cands[#cands+1] = {player=p, char=ch, hum=hum, dist=d}
                    end
                end
            end
        end
    end
    tsort(cands, function(a,b) return a.dist < b.dist end)
    return cands
end

function StartFlick(target, triggeredBy)
    if not Flick.originalCameraType then
        Flick.originalCameraType = Camera.CameraType
    end
    if not Flick.originalCameraSubject then
        Flick.originalCameraSubject = Camera.CameraSubject
    end
    local scf = Camera.CFrame
    Flick.targetPlayer = target.player
    Flick.targetChar = target.char
    Flick.targetHumanoid = target.hum
    Flick.originCF = scf
    Flick.originLookAt = scf.Position + scf.LookVector * 100
    Flick.active = true
    Flick.phase = "snap"
    Flick.snapStartTick = tick()
    Flick.shotsFired = 0
    Flick.killed = false
    Flick.hitVerified = false
    Flick.hpBefore = target.hum.Health
    Flick.retriesLeft = S.Retries
    Flick.triggeredBy = triggeredBy or "manual"
    Camera.CameraType = E_CAM_SCRIPT
    Camera.CameraSubject = nil
    pcall(ReputationUpdate, target.player, false)
end

function EndFlick()
    if not Flick.active then return end
    Flick.phase = "return"
    Flick.returnStartTick = tick()
    Flick.returnStartCF = Camera.CFrame
    Flick.returnTargetCF = Flick.originCF
end

--========= POOLS (Radar + Timeline) =========
local RadarDotPool = {}
local RadarDotUsed = 0

local function RadarGetDot()
    RadarDotUsed = RadarDotUsed + 1
    local dot = RadarDotPool[RadarDotUsed]
    if not dot then
        dot = HB_Create("Frame", {
            Size = newUD2(0,6,0,6),
            BackgroundColor3 = c3(255,255,255),
            BorderSizePixel = 0, ZIndex = 71, Visible = false
        }, RADAR_FRAME)
        HB_Corner(dot, 3)
        RadarDotPool[RadarDotUsed] = dot
    end
    return dot
end

local TimelineDotPool = {}
local TimelineDotUsed = 0

local function TimelineGetDot()
    TimelineDotUsed = TimelineDotUsed + 1
    local dot = TimelineDotPool[TimelineDotUsed]
    if not dot then
        dot = HB_Create("Frame", {
            Size = newUD2(0,4,0,4),
            BackgroundColor3 = c3(255,255,255),
            BorderSizePixel = 0, ZIndex = 55, Visible = false
        }, TIMELINE_HOLDER)
        HB_Corner(dot, 2)
        TimelineDotPool[TimelineDotUsed] = dot
    end
    return dot
end
--========= RENDERSTEPPED — FLICK (CORRIGIDO) =========
RS_Render:Connect(function(dt)
    if not Flick then return end

    if Flick.phase == "return" and Flick.active then
        local el = tick() - Flick.returnStartTick
        local t = clamp(el / Flick.returnDur, 0, 1)
        local eased = HB_EaseBezier(t, 0.4, 0.6)
        local pos = Flick.returnStartCF.Position:Lerp(Flick.returnTargetCF.Position, eased)
        local lf = Flick.returnStartCF.Position + Flick.returnStartCF.LookVector * 100
        local lt = Flick.returnTargetCF.Position + Flick.returnTargetCF.LookVector * 100
        Camera.CameraType = E_CAM_SCRIPT
        Camera.CFrame = lookAt(pos, lf:Lerp(lt, eased))
        if t >= 1 then
            Flick.active = false
            Flick.phase = "idle"
            Flick.targetPlayer = nil
            Flick.targetChar = nil
            Flick.targetHumanoid = nil
            Flick.lastFlickEnd = tick()
            TriggerSuppressUntil = tick() + 0.30
            if Flick.originalCameraType then
                Camera.CameraType = Flick.originalCameraType
                Camera.CameraSubject = Flick.originalCameraSubject
                Flick.originalCameraType = nil
                Flick.originalCameraSubject = nil
            end
        end
        return
    end

    if not Flick.active then return end

    -- ✅ FIX 2: NÃO cancela mais o flick ao soltar a tecla.
    -- O flick precisa completar snap -> hold -> verify para atirar.
    -- Só cancelamos se o alvo morrer/perder (checagens abaixo).

    local tp, ch, hum = Flick.targetPlayer, Flick.targetChar, Flick.targetHumanoid
    if not tp or not tp.Parent or not ch or not ch.Parent
       or not hum or hum.Health <= 0 then
        EndFlick()
        return
    end
    if GetRole(tp) ~= "Murderer" then EndFlick(); return end

    local lpHead = Cache.Heads[LP]
    local camPos = lpHead and lpHead.Position or Camera.CFrame.Position
    local myChar = LP.Character
    local eqTool = myChar and myChar:FindFirstChildOfClass("Tool")
    local aimPos, flightT, dist = ComputeAim(tp, ch, camPos, eqTool)
    if not aimPos then
        local head = ch:FindFirstChild("Head")
        if head then aimPos = head.Position end
    end
    if not aimPos then EndFlick(); return end

    Flick.aimPos = aimPos

    if Flick.phase == "snap" then
        local el = tick() - Flick.snapStartTick
        local snapDur = Flick.snapDur * (FPS.cur < S.FPSAdaptiveMinFPS
            and (S.FPSAdaptiveMinFPS / max(FPS.cur, 15)) or 1)
        if el < snapDur then
            local t = clamp(el / snapDur, 0, 1)
            local eased = HB_EaseS(t)
            local look = Flick.originLookAt:Lerp(aimPos, eased)
            Camera.CameraType = E_CAM_SCRIPT
            Camera.CFrame = lookAt(camPos, look)
        else
            Flick.phase = "hold"
            Flick.holdStartTick = tick()
        end
        return
    end

    if Flick.phase == "hold" then
        Camera.CameraType = E_CAM_SCRIPT
        Camera.CFrame = lookAt(camPos, aimPos)
        if Flick.shotsFired == 0 then
            local w = FindWeapon()
            if w then
                local eq = myChar and myChar:FindFirstChildOfClass("Tool")
                if eq ~= w then
                    EquipWeapon(w)
                    eq = myChar and myChar:FindFirstChildOfClass("Tool")
                end
                if eq and not IsWeaponOnCooldown(eq) then
                    Flick.shotsFired = 1
                    Flick.hpBefore = hum.Health
                    local ok = SilentFire(eq, aimPos)
                    if ok then
                        Flick.phase = "verify"
                        Flick.verifyStart = tick()
                    end
                end
            end
            return
        end
        if tick() - Flick.holdStartTick >= Flick.holdDur then
            Flick.phase = "verify"
            Flick.verifyStart = tick()
        end
        return
    end

    if Flick.phase == "verify" then
        if not hum.Parent or hum.Health <= 0 then Flick.killed = true end
        if hum.Health < Flick.hpBefore then Flick.hitVerified = true end
        if Flick.hitVerified then
            pcall(ReputationUpdate, tp, true)
            pcall(BlockchainAdd, "KILL:" .. tp.Name)
            MetaLearnUpdate(1)
            EndFlick()
            return
        end
        if tick() - Flick.verifyStart >= Flick.verifyWait then
            -- ✅ FIX 3: S.RetryMiss agora está definido, retry funciona
            if S.RetryMiss and Flick.retriesLeft > 0 then
                Flick.retriesLeft = Flick.retriesLeft - 1
                Flick.phase = "snap"
                Flick.snapStartTick = tick()
                Flick.shotsFired = 0
                Flick.hitVerified = false
                Flick.hpBefore = hum.Health
                Flick.originLookAt = Camera.CFrame.Position + Camera.CFrame.LookVector * 100
            else
                MetaLearnUpdate(0)
                EndFlick()
            end
        end
    end
end)

--========= HEARTBEAT — ESP / Chams / Radar / Timeline / Crosshair =========
RS_Heartbeat:Connect(function(dt)
    local players = Cache.List
    local nPlayers = #players
    local vpSize = Camera.ViewportSize
    local vpX2 = vpSize.X * 0.5
    local vpY = vpSize.Y
    local myChar = LP.Character
    local myHrp = myChar and myChar:FindFirstChild("HumanoidRootPart")
    local myPos = myHrp and myHrp.Position

    local roles = {}
    for i = 1, nPlayers do
        local pl = players[i]
        if pl ~= LP then roles[pl] = GetRole(pl) end
    end

    -- ESP
    local espOn = S.ESP == true
    local thick = S.ESPThick or 2
    for i = 1, nPlayers do
        local pl = players[i]
        if pl ~= LP then
            local e = ESP_CACHE[pl]
            if not e then e = ESP_create(); ESP_CACHE[pl] = e end
            local char = pl.Character
            local head = char and char:FindFirstChild("Head")
            local hrp = char and char:FindFirstChild("HumanoidRootPart")
            local hum = char and char:FindFirstChildOfClass("Humanoid")
            if espOn and head and hrp and hum and hum.Health > 0 then
                local color = ESP_COLORS[roles[pl]] or ESP_COLORS.Innocent
                local hs, on1 = Camera:WorldToViewportPoint(head.Position + newV3(0,1,0))
                local fs, on2 = Camera:WorldToViewportPoint(hrp.Position - newV3(0,2.5,0))
                if on1 and on2 and hs.Z > 0 and fs.Z > 0 then
                    local topY, botY = hs.Y, fs.Y
                    local hPx = abs(botY - topY)
                    local wPx = hPx * 0.55
                    local cx = hs.X
                    e.box.Visible = true
                    e.box.Size = newUD2(0, wPx, 0, hPx)
                    e.box.Position = newUD2(0, cx - wPx*0.5, 0, topY)
                    e.stroke.Color = color
                    e.stroke.Thickness = thick
                    local dx = cx - vpX2
                    local dy = (topY + hPx) - vpY
                    local len = sqrt(dx*dx + dy*dy)
                    e.tracer.Visible = true
                    e.tracer.Size = newUD2(0, len, 0, 1)
                    e.tracer.Position = newUD2(0, vpX2 + dx*0.5, 0, vpY + dy*0.5)
                    e.tracer.Rotation = math.deg(atan2(dy, dx))
                    e.tracer.BackgroundColor3 = color
                    e.tracer.BackgroundTransparency = 0.3
                else
                    e.box.Visible = false
                    e.tracer.Visible = false
                end
            elseif e then
                e.box.Visible = false
                e.tracer.Visible = false
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

    -- Chams
    if not S.Chams then
        if next(CHAMS_CACHE) then
            for _, h in pairs_(CHAMS_CACHE) do
                if h and h.Parent then h:Destroy() end
            end
            CHAMS_CACHE = {}
        end
    else
        for i = 1, nPlayers do
            local pl = players[i]
            if pl ~= LP then
                local h = CHAMS_CACHE[pl]
                if not h then
                    h = Instance.new("Highlight")
                    h.Name = "HB_Chams_" .. pl.Name
                    h.FillTransparency = 0.5
                    h.OutlineTransparency = 0.2
                    h.DepthMode = Enum.HighlightDepthMode.AlwaysOnTop
                    h.Adornee = nil
                    h.Parent = PG
                    CHAMS_CACHE[pl] = h
                end
                local char = pl.Character
                local hum = char and char:FindFirstChildOfClass("Humanoid")
                if char and hum and hum.Health > 0 then
                    local color = ESP_COLORS[roles[pl]] or ESP_COLORS.Innocent
                    h.FillColor = color
                    h.OutlineColor = color
                    h.Adornee = char
                else
                    h.Adornee = nil
                end
            end
        end
    end

    -- Radar
    if not S.Radar then
        if RADAR_FRAME.Visible then RADAR_FRAME.Visible = false end
        for i = 1, RadarDotUsed do RadarDotPool[i].Visible = false end
        RadarDotUsed = 0
    elseif myPos then
        RADAR_FRAME.Visible = true
        RadarDotUsed = 0
        local range = 150
        local invRange = 1 / range
        for i = 1, nPlayers do
            local pl = players[i]
            if pl ~= LP then
                local char = pl.Character
                local hrp = char and char:FindFirstChild("HumanoidRootPart")
                local hum = char and char:FindFirstChildOfClass("Humanoid")
                if hrp and hum and hum.Health > 0 then
                    local rp = hrp.Position
                    local rx, rz = rp.X - myPos.X, rp.Z - myPos.Z
                    local dist = sqrt(rx*rx + rz*rz)
                    if dist <= range then
                        local dot = RadarGetDot()
                        dot.Visible = true
                        dot.Position = newUD2(0.5 + rx*invRange*0.45, -3,
                                              0.5 + rz*invRange*0.45, -3)
                        dot.BackgroundColor3 = ESP_COLORS[roles[pl]] or ESP_COLORS.Innocent
                    end
                end
            end
        end
        for i = RadarDotUsed + 1, #RadarDotPool do
            if RadarDotPool[i].Visible then RadarDotPool[i].Visible = false end
        end
    end

    -- Timeline
    if not S.TimelinePredictor then
        for i = 1, TimelineDotUsed do TimelineDotPool[i].Visible = false end
        TimelineDotUsed = 0
    else
        TimelineDotUsed = 0
        for i = 1, nPlayers do
            local pl = players[i]
            if pl ~= LP then
                local h = Hst[pl]
                if h and h.lastPos and h.vel then
                    local color = ESP_COLORS[roles[pl]] or ESP_COLORS.Innocent
                    local basePos = h.lastPos
                    local vel = h.vel
                    for t = 1, 6 do
                        local fp = basePos + vel * (t * 0.2)
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

    -- Crosshair
    local crossOn = S.Cross == true
    if CROSSHAIR.Visible ~= crossOn then CROSSHAIR.Visible = crossOn end
end)

--========= INPUT =========
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
            HB_Toast("PANIC", "danger")
        elseif kc == Enum.KeyCode.F2 then
            if HB_LegacySave then HB_LegacySave() end
        elseif kc == Enum.KeyCode.F3 then
            if HB_RageMeter and HB_RageMeter.active then
                HB_RageMeter_Deactivate("manual")
            elseif HB_RageMeter then
                HB_RageMeter.roundStartTick = 0
                HB_RageMeter_Activate()
            end
        elseif kc == Enum.KeyCode.F4 then
            if HB_PresetTryhard then HB_PresetTryhard() end
        elseif kc == Enum.KeyCode.F5 then
            if HB_PresetRageMax then HB_PresetRageMax() end
        end
    end
end)

UIS_InputEnded:Connect(function(input)
    if input.UserInputType == E_KEYBOARD and input.KeyCode == S.FlickKey then
        Flick.keyHeld = false
        -- ✅ Não cancela mais o flick aqui — deixa ele terminar naturalmente.
    end
end)

LP.Chatted:Connect(function(msg)
    if not S.ChatCommands then return end
    local cmd, arg = msg:match("^/hb%s+(%S+)%s*(.*)")
    if not cmd then return end
    if cmd == "flick" then S.AutoFlick = (arg ~= "off")
    elseif cmd == "esp" then S.ESP = (arg ~= "off")
    elseif cmd == "trigger" then S.TrigOn = (arg ~= "off")
    elseif cmd == "panic" then
        S.AutoFlick=false S.TrigOn=false S.ESP=false
        HB_Toast("Panic!", "danger")
    elseif cmd == "hide" then
        if UI and UI.Main then UI.Main.Visible = false end
    elseif cmd == "show" then
        if UI and UI.Main then UI.Main.Visible = true end
    elseif cmd == "save" then
        HB_Toast("Salvo", "success")
    end
end)

--========= UI CONSTRUCTION =========
UI = {}
UI.Registered = {}
UI.TabButtons = {}
UI.TabContents = {}

local UI_vp = Camera.ViewportSize
local UI_baseW, UI_baseH = 900, 620
local UI_scale = max(0.5, min((UI_vp.X*0.92)/UI_baseW, (UI_vp.Y*0.92)/UI_baseH, 1.0))

UI_screen = HB_Create("ScreenGui", {
    Name = HB_X .. "UI", ResetOnSpawn = false,
    IgnoreGuiInset = true, DisplayOrder = 100
}, PG)
UI.Screen = UI_screen

UI_main = HB_Create("Frame", {
    Name = "Main",
    Size = newUD2(0, UI_baseW, 0, UI_baseH),
    Position = newUD2(0.5, 0, 0.5, 0),
    AnchorPoint = Vector2.new(0.5, 0.5),
    BackgroundColor3 = Palette.Surface,
    BorderSizePixel = 0, ClipsDescendants = true, Active = true
}, UI_screen)
HB_Corner(UI_main, 14)
HB_Stroke(UI_main, Palette.Accent, 2, 0.6)
UI.Main = UI_main

UI_uiScale = HB_Create("UIScale", {Scale = UI_scale}, UI_main)

UI_header = HB_Create("Frame", {
    Name = "Header",
    Size = newUD2(1, 0, 0, 70),
    BackgroundColor3 = c3(24, 24, 30),
    BackgroundTransparency = 0.15, BorderSizePixel = 0,
    ZIndex = 5, Active = true
}, UI_main)
HB_Corner(UI_header, 14)

HB_Create("TextLabel", {
    Size = newUD2(0, 400, 0, 24), Position = newUD2(0, 20, 0, 14),
    BackgroundTransparency = 1, Text = "HELLBORN ULTIMATE v9.1",
    Font = E_GOTHAM_BLACK, TextSize = 20, TextColor3 = Palette.TextHigh,
    TextXAlignment = E_TXT_LEFT, ZIndex = 7
}, UI_header)

HB_Create("TextLabel", {
    Size = newUD2(0, 400, 0, 14), Position = newUD2(0, 20, 0, 42),
    BackgroundTransparency = 1, Text = "SUPREME · " .. HB_SERIAL,
    Font = E_CODE, TextSize = 10, TextColor3 = Palette.Accent,
    TextXAlignment = E_TXT_LEFT, ZIndex = 7
}, UI_header)

local UI_avF = HB_Create("Frame", {
    Size = newUD2(0, 46, 0, 46), Position = newUD2(1, -260, 0.5, -23),
    BackgroundColor3 = Palette.Elevated2, BorderSizePixel = 0, ZIndex = 7
}, UI_header)
HB_Corner(UI_avF, 23)
HB_Stroke(UI_avF, Palette.Accent, 2, 0)
HB_Create("ImageLabel", {
    Size = newUD2(1, -4, 1, -4), Position = newUD2(0, 2, 0, 2),
    BackgroundTransparency = 1,
    Image = "rbxthumb://type=AvatarHeadShot&id=" .. LP.UserId .. "&w=150&h=150",
    ZIndex = 8
}, UI_avF)

local function UI_mkHeaderBtn(txt, xOff, cb, color)
    local b = HB_Create("TextButton", {
        Size = newUD2(0, 28, 0, 28), Position = newUD2(1, xOff, 0.5, -14),
        BackgroundColor3 = color or Palette.Elevated2, BorderSizePixel = 0,
        Text = txt, Font = E_GOTHAM_BOLD, TextSize = 14,
        TextColor3 = Palette.TextHigh, AutoButtonColor = false,
        Active = true, Selectable = false, ZIndex = 8
    }, UI_header)
    HB_Corner(b, 14)
    HB_Stroke(b, Palette.Border, 1, 0.4)
    b.Activated:Connect(cb)
    return b
end

UI_closeBtn = UI_mkHeaderBtn("✕", -46, function() UI_main.Visible = false end)
UI_panicBtn = UI_mkHeaderBtn("!", -84, function()
    S.AutoFlick=false S.TrigOn=false S.ESP=false
    HB_Toast("PANIC", "danger")
end, c3(120, 20, 20))
UI_zoomOut = UI_mkHeaderBtn("−", -122, function()
    UI_uiScale.Scale = max(0.5, UI_uiScale.Scale - 0.1)
end)
UI_zoomIn = UI_mkHeaderBtn("+", -158, function()
    UI_uiScale.Scale = min(1.5, UI_uiScale.Scale + 0.1)
end)
UI_dragBtn = UI_mkHeaderBtn("✥", -194, function() end)

-- Search
local UI_searchWrap = HB_Create("Frame", {
    Size = newUD2(1, -28, 0, 36), Position = newUD2(0, 14, 0, 78),
    BackgroundColor3 = Palette.Elevated, BorderSizePixel = 0, ZIndex = 4
}, UI_main)
HB_Corner(UI_searchWrap, 10)
HB_Stroke(UI_searchWrap, Palette.Border, 1, 0.3)

HB_Create("TextLabel", {
    Size = newUD2(0, 24, 0, 36), Position = newUD2(0, 8, 0, 0),
    BackgroundTransparency = 1, Text = "🔍",
    Font = E_GOTHAM, TextSize = 14, TextColor3 = Palette.TextMid
}, UI_searchWrap)

UI_searchBox = HB_Create("TextBox", {
    Size = newUD2(1, -44, 1, 0), Position = newUD2(0, 34, 0, 0),
    BackgroundTransparency = 1, Text = "",
    PlaceholderText = "Buscar feature...",
    PlaceholderColor3 = Palette.TextLow,
    Font = E_GOTHAM, TextSize = 13, TextColor3 = Palette.TextHigh,
    TextXAlignment = E_TXT_LEFT, ClearTextOnFocus = false
}, UI_searchWrap)

local UI_clearBtn = HB_Create("TextButton", {
    Size = newUD2(0, 24, 0, 36), Position = newUD2(1, -28, 0, 0),
    BackgroundTransparency = 1, Text = "✕",
    Font = E_GOTHAM_BOLD, TextSize = 12,
    TextColor3 = Palette.TextMid, AutoButtonColor = false, Visible = false
}, UI_searchWrap)

UI_clearBtn.Activated:Connect(function()
    UI_searchBox.Text = ""
    UI_clearBtn.Visible = false
end)

UI_searchBox:GetPropertyChangedSignal("Text"):Connect(function()
    local q = slower(UI_searchBox.Text)
    UI_clearBtn.Visible = q ~= ""
    for i = 1, #UI.Registered do
        local d = UI.Registered[i]
        if d.parent and d.parent.Parent then
            d.parent.Visible = q == "" or d.name:find(q, 1, true) or d.keywords:find(q, 1, true)
        end
    end
end)

-- Sidebar
local UI_sidebar = HB_Create("Frame", {
    Size = newUD2(0, 190, 1, -210), Position = newUD2(0, 14, 0, 124),
    BackgroundColor3 = Palette.Base, BackgroundTransparency = 0.3,
    BorderSizePixel = 0, ZIndex = 3
}, UI_main)
HB_Corner(UI_sidebar, 10)
HB_Stroke(UI_sidebar, Palette.Border, 1, 0.5)

UI_tabScroll = HB_Create("ScrollingFrame", {
    Size = newUD2(1, -12, 1, -12), Position = newUD2(0, 6, 0, 6),
    BackgroundTransparency = 1, ScrollBarThickness = 0,
    CanvasSize = newUD2(0, 0, 0, 0), AutomaticCanvasSize = E_AUTO_Y
}, UI_sidebar)

UI.Content = HB_Create("Frame", {
    Size = newUD2(1, -14*3-190, 1, -210),
    Position = newUD2(0, 14+190+14, 0, 124),
    BackgroundTransparency = 1, ZIndex = 3
}, UI_main)

UI_TabsList = {
    {icon="🎯", name="Aimbot"},   {icon="⚔", name="Flick"},
    {icon="◉", name="ESP"},       {icon="✦", name="Visual"},
    {icon="▤", name="Stats"},     {icon="◈", name="IA"},
    {icon="⚡", name="RevIA"},     {icon="🧠", name="RevHuman"},
    {icon="⚙", name="RevPhys"},   {icon="🎭", name="RevSocial"},
    {icon="🔧", name="RevArch"},  {icon="💫", name="RevFeat"},
    {icon="🎮", name="RevGame"},  {icon="🛡", name="RevStealth"},
    {icon="🌀", name="RevMad"},   {icon="🔬", name="Innova"},
    {icon="💎", name="Revolu"},   {icon="🎨", name="Config"},
}

for _, t in ipairs_(UI_TabsList) do
    local sf = HB_Create("ScrollingFrame", {
        Name = t.name, Size = newUD2(1, 0, 1, 0),
        BackgroundTransparency = 1, ScrollBarThickness = 4,
        ScrollBarImageColor3 = Palette.Accent,
        CanvasSize = newUD2(0, 0, 0, 0), AutomaticCanvasSize = E_AUTO_Y,
        Visible = false
    }, UI.Content)
    HB_Create("UIPadding", {
        PaddingTop = udim(0, 6), PaddingRight = udim(0, 6),
        PaddingBottom = udim(0, 30), PaddingLeft = udim(0, 6)
    }, sf)
    UI.TabContents[t.name] = sf
end

UI.switchTab = function(name)
    for tn, c in pairs_(UI.TabContents) do c.Visible = (tn == name) end
    for i = 1, #UI.TabButtons do
        local btn = UI.TabButtons[i]
        local isOn = btn:GetAttribute("TabName") == name
        TweenService:Create(btn, TweenInfo.new(0.15), {
            BackgroundTransparency = isOn and 0.2 or 0.7,
            TextColor3 = isOn and Palette.Accent or Palette.TextMid
        }):Play()
    end
end

for i, tab in ipairs_(UI_TabsList) do
    local btn = HB_Create("TextButton", {
        Size = newUD2(1, -4, 0, 36), Position = newUD2(0, 4, 0, (i-1)*40+4),
        BackgroundColor3 = Palette.Elevated, BackgroundTransparency = 0.7,
        BorderSizePixel = 0,
        Text = "  " .. tab.icon .. "   " .. tab.name,
        Font = E_GOTHAM_MED, TextSize = 13, TextColor3 = Palette.TextMid,
        TextXAlignment = E_TXT_LEFT, AutoButtonColor = false,
        Active = true, Selectable = false
    }, UI_tabScroll)
    HB_Corner(btn, 8)
    btn:SetAttribute("TabName", tab.name)
    btn.Activated:Connect(function() UI.switchTab(tab.name) end)
    UI.TabButtons[#UI.TabButtons+1] = btn
end
--========= COMPONENTES =========
Cmp = {}

local function Cmp_reg(p, n, k)
    UI.Registered[#UI.Registered+1] = {
        parent = p, name = slower(n),
        keywords = k and slower(k) or ""
    }
end

Cmp.Section = function(parent, text, y)
    local h = 34
    local holder = HB_Create("Frame", {
        Size = newUD2(1, 0, 0, h), Position = newUD2(0, 0, 0, y),
        BackgroundTransparency = 1
    }, parent)
    local bar = HB_Create("Frame", {
        Size = newUD2(0, 3, 0, 14), Position = newUD2(0, 0, 0.5, -7),
        BackgroundColor3 = Palette.Accent, BorderSizePixel = 0
    }, holder)
    HB_Corner(bar, 2)
    HB_Create("TextLabel", {
        Size = newUD2(1, -12, 1, 0), Position = newUD2(0, 12, 0, 0),
        BackgroundTransparency = 1, Text = text,
        Font = E_GOTHAM_BOLD, TextSize = 13, TextColor3 = Palette.TextHigh,
        TextXAlignment = E_TXT_LEFT
    }, holder)
    return y + h + 6
end

Cmp.Toggle = function(parent, opts, y)
    local text = opts.text or "Toggle"
    local desc = opts.desc
    local default = opts.default == true
    local cb = opts.callback
    local h = desc and 56 or 42
    local holder = HB_Create("Frame", {
        Size = newUD2(1, 0, 0, h), Position = newUD2(0, 0, 0, y),
        BackgroundColor3 = Palette.Elevated, BorderSizePixel = 0, Active = true
    }, parent)
    HB_Corner(holder, 8)
    HB_Stroke(holder, Palette.Border, 1, 0.3)
    HB_Create("TextLabel", {
        Size = newUD2(1, -80, 0, desc and 18 or h),
        Position = newUD2(0, 14, 0, desc and 8 or 0),
        BackgroundTransparency = 1, Text = text,
        Font = E_GOTHAM_MED, TextSize = 13, TextColor3 = Palette.TextHigh,
        TextXAlignment = E_TXT_LEFT
    }, holder)
    if desc then
        HB_Create("TextLabel", {
            Size = newUD2(1, -80, 0, 14), Position = newUD2(0, 14, 0, 26),
            BackgroundTransparency = 1, Text = desc,
            Font = E_GOTHAM, TextSize = 10, TextColor3 = Palette.TextLow,
            TextXAlignment = E_TXT_LEFT
        }, holder)
    end
    local track = HB_Create("Frame", {
        Size = newUD2(0, 42, 0, 22), Position = newUD2(1, -56, 0.5, -11),
        BackgroundColor3 = default and Palette.Accent or c3(50, 50, 58),
        BorderSizePixel = 0
    }, holder)
    HB_Corner(track, 11)
    local knob = HB_Create("Frame", {
        Size = newUD2(0, 18, 0, 18),
        Position = default and newUD2(1, -21, 0.5, -9) or newUD2(0, 3, 0.5, -9),
        BackgroundColor3 = c3(250, 250, 250), BorderSizePixel = 0
    }, track)
    HB_Corner(knob, 9)
    local on = default
    local hitbox = HB_Create("TextButton", {
        Size = newUD2(1, 0, 1, 0), BackgroundTransparency = 1, Text = "",
        AutoButtonColor = false, Active = true, Selectable = false, ZIndex = 50
    }, holder)
    hitbox.Activated:Connect(function()
        on = not on
        TweenService:Create(track, TweenInfo.new(0.2), {
            BackgroundColor3 = on and Palette.Accent or c3(50, 50, 58)
        }):Play()
        TweenService:Create(knob, TweenInfo.new(0.35, E_BACK), {
            Position = on and newUD2(1, -21, 0.5, -9) or newUD2(0, 3, 0.5, -9)
        }):Play()
        if cb then pcall(cb, on) end
    end)
    Cmp_reg(holder, text, desc)
    return y + h + 8
end

Cmp.Slider = function(parent, opts, y)
    local text = opts.text or "Slider"
    local cb = opts.callback
    local suf = opts.suffix or ""
    local mn, mx = opts.min or 0, opts.max or 100
    local default = opts.default or mn
    local h = 50
    local holder = HB_Create("Frame", {
        Size = newUD2(1, 0, 0, h), Position = newUD2(0, 0, 0, y),
        BackgroundColor3 = Palette.Elevated, BorderSizePixel = 0
    }, parent)
    HB_Corner(holder, 8)
    HB_Stroke(holder, Palette.Border, 1, 0.3)
    HB_Create("TextLabel", {
        Size = newUD2(0.5, 0, 0, 20), Position = newUD2(0, 14, 0, 6),
        BackgroundTransparency = 1, Text = text,
        Font = E_GOTHAM_MED, TextSize = 12, TextColor3 = Palette.TextHigh,
        TextXAlignment = E_TXT_LEFT
    }, holder)
    local vLbl = HB_Create("TextLabel", {
        Size = newUD2(0, 60, 0, 20), Position = newUD2(1, -74, 0, 6),
        BackgroundTransparency = 1, Text = tostring(default) .. suf,
        Font = E_CODE, TextSize = 12, TextColor3 = Palette.Accent,
        TextXAlignment = E_TXT_RIGHT
    }, holder)
    local bBg = HB_Create("Frame", {
        Size = newUD2(1, -28, 0, 8), Position = newUD2(0, 14, 0, h-18),
        BackgroundColor3 = c3(36, 36, 44), BorderSizePixel = 0, Active = true
    }, holder)
    HB_Corner(bBg, 4)
    local initPct = (default - mn) / (mx - mn)
    local bFill = HB_Create("Frame", {
        Size = newUD2(initPct, 0, 1, 0),
        BackgroundColor3 = Palette.Accent, BorderSizePixel = 0
    }, bBg)
    HB_Corner(bFill, 4)
    local knob = HB_Create("Frame", {
        Size = newUD2(0, 16, 0, 16), Position = newUD2(initPct, -8, 0.5, -8),
        BackgroundColor3 = c3(250, 250, 250), BorderSizePixel = 0
    }, bBg)
    HB_Corner(knob, 8)
    local hit = HB_Create("TextButton", {
        Size = newUD2(1, 0, 1, 0), BackgroundTransparency = 1, Text = "",
        AutoButtonColor = false, Active = true, Selectable = false, ZIndex = 50
    }, bBg)
    local dragging = false
    local function upd(x)
        local pct = clamp((x - bBg.AbsolutePosition.X) / bBg.AbsoluteSize.X, 0, 1)
        local nv = floor(mn + (mx - mn) * pct + 0.5)
        bFill.Size = newUD2(pct, 0, 1, 0)
        knob.Position = newUD2(pct, -8, 0.5, -8)
        vLbl.Text = tostring(nv) .. suf
        if cb then pcall(cb, nv) end
    end
    hit.InputBegan:Connect(function(input)
        if input.UserInputType == E_MOUSE1 then
            dragging = true
            upd(input.Position.X)
        end
    end)
    UIS_InputEnded:Connect(function(input)
        if input.UserInputType == E_MOUSE1 then dragging = false end
    end)
    UIS_InputChanged:Connect(function(input)
        if dragging and input.UserInputType == E_MOUSEMOVE then
            upd(input.Position.X)
        end
    end)
    Cmp_reg(holder, text, nil)
    return y + h + 8
end

Cmp.Button = function(parent, opts, y)
    local text = opts.text or "Button"
    local cb = opts.callback
    local danger = opts.danger
    local color = danger and c3(60, 20, 22) or Palette.Elevated
    local tc = danger and Palette.Danger or Palette.TextHigh
    local h = 42
    local btn = HB_Create("TextButton", {
        Size = newUD2(1, 0, 0, h), Position = newUD2(0, 0, 0, y),
        BackgroundColor3 = color, BorderSizePixel = 0, Text = "",
        AutoButtonColor = false, Active = true, Selectable = false
    }, parent)
    HB_Corner(btn, 8)
    HB_Stroke(btn, Palette.Border, 1, 0.3)
    HB_Create("TextLabel", {
        Size = newUD2(1, -28, 1, 0), Position = newUD2(0, 14, 0, 0),
        BackgroundTransparency = 1, Text = text,
        Font = E_GOTHAM_BOLD, TextSize = 13, TextColor3 = tc,
        TextXAlignment = E_TXT_LEFT
    }, btn)
    btn.Activated:Connect(function()
        if cb then pcall(cb) end
    end)
    Cmp_reg(btn, text, nil)
    return y + h + 8
end

Cmp.Dropdown = function(parent, opts, y)
    local text = opts.text or "Option"
    local options = opts.options or {}
    local default = opts.default or options[1] or "-"
    local cb = opts.callback
    local h = 42
    local holder = HB_Create("Frame", {
        Size = newUD2(1, 0, 0, h), Position = newUD2(0, 0, 0, y),
        BackgroundColor3 = Palette.Elevated, BorderSizePixel = 0
    }, parent)
    HB_Corner(holder, 8)
    HB_Stroke(holder, Palette.Border, 1, 0.3)
    HB_Create("TextLabel", {
        Size = newUD2(0.5, -14, 1, 0), Position = newUD2(0, 14, 0, 0),
        BackgroundTransparency = 1, Text = text,
        Font = E_GOTHAM_MED, TextSize = 12, TextColor3 = Palette.TextHigh,
        TextXAlignment = E_TXT_LEFT
    }, holder)
    local idx = 1
    for i = 1, #options do
        if options[i] == default then idx = i; break end
    end
    local btn = HB_Create("TextButton", {
        Size = newUD2(0.5, -14, 0, 28), Position = newUD2(0.5, 0, 0.5, -14),
        BackgroundColor3 = Palette.Elevated2, BorderSizePixel = 0,
        Text = default, Font = E_GOTHAM_BOLD, TextSize = 11,
        TextColor3 = Palette.Accent, AutoButtonColor = false,
        Active = true, Selectable = false
    }, holder)
    HB_Corner(btn, 6)
    HB_Stroke(btn, Palette.Border, 1, 0.4)
    btn.Activated:Connect(function()
        idx = idx + 1
        if idx > #options then idx = 1 end
        btn.Text = options[idx]
        if cb then pcall(cb, options[idx]) end
    end)
    Cmp_reg(holder, text, nil)
    return y + h + 8
end

Cmp.Keybind = function(parent, opts, y)
    local text = opts.text or "Keybind"
    local default = opts.default or Enum.KeyCode.Q
    local cb = opts.callback
    local h = 42
    local holder = HB_Create("Frame", {
        Size = newUD2(1, 0, 0, h), Position = newUD2(0, 0, 0, y),
        BackgroundColor3 = Palette.Elevated, BorderSizePixel = 0
    }, parent)
    HB_Corner(holder, 8)
    HB_Stroke(holder, Palette.Border, 1, 0.3)
    HB_Create("TextLabel", {
        Size = newUD2(0.5, -14, 1, 0), Position = newUD2(0, 14, 0, 0),
        BackgroundTransparency = 1, Text = text,
        Font = E_GOTHAM_MED, TextSize = 12, TextColor3 = Palette.TextHigh,
        TextXAlignment = E_TXT_LEFT
    }, holder)
    local kb = HB_Create("TextButton", {
        Size = newUD2(0, 80, 0, 28), Position = newUD2(1, -94, 0.5, -14),
        BackgroundColor3 = Palette.Elevated2, BorderSizePixel = 0,
        Text = default.Name, Font = E_CODE, TextSize = 11,
        TextColor3 = Palette.Accent, AutoButtonColor = false,
        Active = true, Selectable = false
    }, holder)
    HB_Corner(kb, 6)
    HB_Stroke(kb, Palette.Border, 1, 0.4)
    local listening = false
    kb.Activated:Connect(function()
        listening = true
        kb.Text = "..."
        kb.TextColor3 = Palette.Warning
    end)
    UIS_InputBegan:Connect(function(input)
        if not listening then return end
        if input.UserInputType == E_KEYBOARD then
            kb.Text = input.KeyCode.Name
            kb.TextColor3 = Palette.Accent
            listening = false
            if cb then pcall(cb, input.KeyCode) end
        end
    end)
    Cmp_reg(holder, text, nil)
    return y + h + 8
end

--========= POPULAR ABAS =========
local P = UI.TabContents
local y

-- Aimbot
y = 0
local p = P["Aimbot"]
y = Cmp.Section(p, "🎯 AIMBOT", y)
y = Cmp.Toggle(p, {text="Auto Flick", default=true, callback=function(v) S.AutoFlick=v end}, y)
y = Cmp.Keybind(p, {text="Flick Key", default=S.FlickKey, callback=function(kc) S.FlickKey=kc end}, y)
y = Cmp.Slider(p, {text="Align Tolerance", min=1, max=15, default=4, suffix="°", callback=function(v) S.AlignTol=v end}, y)
y = Cmp.Slider(p, {text="Retries", min=0, max=3, default=2, callback=function(v) S.Retries=v end}, y)
y = Cmp.Section(p, "TRIGGER", y)
y = Cmp.Toggle(p, {text="Trigger Bot", default=false, callback=function(v) S.TrigOn=v end}, y)
y = Cmp.Slider(p, {text="Radius", min=10, max=200, default=60, suffix="px", callback=function(v) S.TrigRad=v end}, y)
y = Cmp.Section(p, "ANTI-DETECT", y)
y = Cmp.Toggle(p, {text="Rate Limiter", default=true, callback=function(v) S.RateLimit=v end}, y)
y = Cmp.Toggle(p, {text="Fake Miss", default=false, callback=function(v) S.FakeMiss=v end}, y)
y = Cmp.Toggle(p, {text="Anti-Flick Block", default=true, callback=function(v) S.AntiFlickBlock=v end}, y)
y = Cmp.Toggle(p, {text="Hitscan Opt", default=true, callback=function(v) S.HitscanOpt=v end}, y)
y = Cmp.Toggle(p, {text="FPS Adaptive", default=true, callback=function(v) S.FPSAdaptive=v end}, y)

-- Flick
y = 0
p = P["Flick"]
y = Cmp.Section(p, "⚔ TIMINGS", y)
y = Cmp.Slider(p, {text="Snap (ms)", min=10, max=100, default=45, suffix="ms", callback=function(v) if Flick then Flick.snapDur=v/1000 end end}, y)
y = Cmp.Slider(p, {text="Hold (ms)", min=50, max=400, default=150, suffix="ms", callback=function(v) if Flick then Flick.holdDur=v/1000 end end}, y)
y = Cmp.Slider(p, {text="Verify (ms)", min=200, max=1000, default=500, suffix="ms", callback=function(v) if Flick then Flick.verifyWait=v/1000 end end}, y)
y = Cmp.Slider(p, {text="Return (ms)", min=30, max=300, default=100, suffix="ms", callback=function(v) if Flick then Flick.returnDur=v/1000 end end}, y)
y = Cmp.Section(p, "SILENT", y)
y = Cmp.Toggle(p, {text="Silent Aim", default=true, callback=function(v) S.SilentOn=v end}, y)
y = Cmp.Toggle(p, {text="Random Aim", default=true, callback=function(v) S.RandomAim=v end}, y)
y = Cmp.Section(p, "PERSONA", y)
y = Cmp.Dropdown(p, {text="Persona", options={"aggressive","cautious","imprevisivel","calculista","casual"}, default="calculista", callback=function(o) S.REV_HUMAN.persona=o PersonaApply() end}, y)
y = Cmp.Slider(p, {text="Strength", min=0, max=100, default=70, suffix="%", callback=function(v) S.REV_HUMAN.personaStrength=v/100 end}, y)

-- ESP
y = 0
p = P["ESP"]
y = Cmp.Section(p, "ESP", y)
y = Cmp.Toggle(p, {text="ESP Ativado", default=false, callback=function(v) S.ESP=v end}, y)
y = Cmp.Toggle(p, {text="Box + Tracer", default=true}, y)
y = Cmp.Slider(p, {text="Espessura", min=1, max=4, default=2, callback=function(v) S.ESPThick=v end}, y)
y = Cmp.Section(p, "AVANÇADO", y)
y = Cmp.Toggle(p, {text="Chams (Highlight)", default=false, callback=function(v) S.Chams=v end}, y)
y = Cmp.Toggle(p, {text="ESP Arrows", default=false, callback=function(v) S.ESPArrows=v end}, y)
y = Cmp.Toggle(p, {text="ESP Skeleton", default=false, callback=function(v) S.ESPSkeleton=v end}, y)
y = Cmp.Toggle(p, {text="Radar", default=false, callback=function(v) S.Radar=v end}, y)
y = Cmp.Toggle(p, {text="Timeline Predictor", default=false, callback=function(v) S.TimelinePredictor=v end}, y)

-- Visual
y = 0
p = P["Visual"]
y = Cmp.Section(p, "HUD", y)
y = Cmp.Toggle(p, {text="Hitmarker", default=true, callback=function(v) S.Hitmark=v end}, y)
y = Cmp.Toggle(p, {text="Kill Feed", default=true, callback=function(v) S.KillFeed=v end}, y)
y = Cmp.Toggle(p, {text="Crosshair", default=false, callback=function(v) S.Cross=v end}, y)
y = Cmp.Section(p, "CROSSHAIR", y)
y = Cmp.Dropdown(p, {text="Estilo", options={"Dot","Cross","Circle","Hybrid"}, default="Cross", callback=function(o) S.CrossStyle=o end}, y)
y = Cmp.Slider(p, {text="Tamanho", min=4, max=30, default=12, callback=function(v) S.CrossSize=v end}, y)

-- Stats
y = 0
p = P["Stats"]
y = Cmp.Section(p, "SESSÃO", y)
local UI_statsBox = HB_Create("Frame", {
    Size = newUD2(1, 0, 0, 200), Position = newUD2(0, 0, 0, y),
    BackgroundColor3 = Palette.Elevated, BorderSizePixel = 0
}, p)
HB_Corner(UI_statsBox, 8)
UI.StatsDisplay = HB_Create("TextLabel", {
    Size = newUD2(1, -20, 1, -20), Position = newUD2(0, 10, 0, 10),
    BackgroundTransparency = 1, Text = "",
    Font = E_CODE, TextSize = 12, TextColor3 = Palette.TextHigh,
    TextXAlignment = E_TXT_LEFT, TextYAlignment = E_TXT_TOP, TextWrapped = true
}, UI_statsBox)
y = y + 210
y = Cmp.Button(p, {text="Resetar", danger=true, callback=function()
    S.Kills=0 S.Deaths=0 S.Hits=0 S.Misses=0 S.Streak=0 S.BestStreak=0
    Acc.shots = {}
end}, y)

-- IA
y = 0
p = P["IA"]
y = Cmp.Section(p, "IA CORE", y)
y = Cmp.Toggle(p, {text="IA On", default=true, callback=function(v) S.AIOn=v end}, y)
y = Cmp.Toggle(p, {text="NN Real", default=true}, y)
y = Cmp.Slider(p, {text="NN Rate", min=1, max=50, default=10, suffix="‰", callback=function(v) S.NNRate=v/1000 end}, y)

-- RevIA
y = 0
p = P["RevIA"]
y = Cmp.Section(p, "⚡ REV IA", y)
local revIAList = {
    {"Meta-Learning","meta"},{"NAS","nas"},{"Behavioural Cloning","cloning"},
    {"Self-Play","selfPlay"},{"World Model","worldModel"},{"Active Inference","activeInf"},
    {"Transformer","transformer"},{"MoE","moe"},{"Uncertainty","uncert"},
    {"Causal","causal"},{"Counterfactual","counterfact"},{"Adversarial","adversarial"},
    {"Transfer","transfer"},{"Federated","federated"},{"Lifelong","lifelong"}
}
for i = 1, #revIAList do
    local it = revIAList[i]
    y = Cmp.Toggle(p, {text=it[1], default=true, callback=function(v) S.REV_AI[it[2]]=v end}, y)
end

-- RevHuman
y = 0
p = P["RevHuman"]
y = Cmp.Section(p, "🧠 HUMANA", y)
y = Cmp.Toggle(p, {text="Warmup", default=true, callback=function(v) S.REV_HUMAN.warmup=v end}, y)
y = Cmp.Slider(p, {text="Warmup (min)", min=1, max=10, default=2, callback=function(v) S.REV_HUMAN.warmupMin=v end}, y)
y = Cmp.Toggle(p, {text="Cool-down", default=true, callback=function(v) S.REV_HUMAN.cooldown=v end}, y)
y = Cmp.Toggle(p, {text="Emotion", default=true, callback=function(v) S.REV_HUMAN.emotion=v end}, y)
y = Cmp.Toggle(p, {text="Cognitive", default=true, callback=function(v) S.REV_HUMAN.cognitive=v end}, y)
y = Cmp.Toggle(p, {text="Fatigue", default=true, callback=function(v) S.REV_HUMAN.fatigue=v end}, y)
y = Cmp.Toggle(p, {text="Squad", default=true, callback=function(v) S.REV_HUMAN.squad=v end}, y)
y = Cmp.Toggle(p, {text="Reputation", default=true, callback=function(v) S.REV_HUMAN.reputation=v end}, y)
y = Cmp.Toggle(p, {text="Alt Detect", default=true, callback=function(v) S.REV_HUMAN.altDetect=v end}, y)

-- RevPhys
y = 0
p = P["RevPhys"]
y = Cmp.Section(p, "⚙ FÍSICA", y)
y = Cmp.Toggle(p, {text="Ballistic", default=true, callback=function(v) S.REV_PHYS.ballistic=v end}, y)
y = Cmp.Toggle(p, {text="Ray-Trace", default=true, callback=function(v) S.REV_PHYS.rayTrace=v end}, y)
y = Cmp.Toggle(p, {text="IK", default=true, callback=function(v) S.REV_PHYS.ik=v end}, y)
y = Cmp.Toggle(p, {text="Anim Mirror", default=true, callback=function(v) S.REV_PHYS.animMirror=v end}, y)
y = Cmp.Toggle(p, {text="Recon", default=true, callback=function(v) S.REV_PHYS.gameStateRecon=v end}, y)
y = Cmp.Toggle(p, {text="Server Mirror", default=true, callback=function(v) S.REV_PHYS.serverMirror=v end}, y)
y = Cmp.Toggle(p, {text="Latency 2.0", default=true, callback=function(v) S.REV_PHYS.latency2=v end}, y)
y = Cmp.Toggle(p, {text="Jitter Buffer", default=true, callback=function(v) S.REV_PHYS.jitterBuf=v end}, y)

-- RevSocial
y = 0
p = P["RevSocial"]
y = Cmp.Section(p, "🎭 SOCIAL", y)
y = Cmp.Toggle(p, {text="Anti-Attribution", default=true, callback=function(v) S.REV_SOCIAL.antiAttr=v end}, y)
y = Cmp.Toggle(p, {text="Misdirect", default=true, callback=function(v) S.REV_SOCIAL.misdirect=v end}, y)
y = Cmp.Toggle(p, {text="Bait", default=true, callback=function(v) S.REV_SOCIAL.bait=v end}, y)
y = Cmp.Toggle(p, {text="Anti-Report", default=true, callback=function(v) S.REV_SOCIAL.antiReport=v end}, y)
y = Cmp.Toggle(p, {text="Skill Curve", default=true, callback=function(v) S.REV_SOCIAL.skillCurve=v end}, y)

-- RevArch
y = 0
p = P["RevArch"]
y = Cmp.Section(p, "🔧 ARQUITETURA", y)
y = Cmp.Toggle(p, {text="Rollback", default=true, callback=function(v) S.REV_ARCH.rollback=v end}, y)
y = Cmp.Toggle(p, {text="Diff Sync", default=true, callback=function(v) S.REV_ARCH.diffSync=v end}, y)

-- RevFeat
y = 0
p = P["RevFeat"]
y = Cmp.Section(p, "💫 FEATURES", y)
y = Cmp.Toggle(p, {text="What-If", default=true, callback=function(v) S.REV_FEAT.whatIf=v end}, y)
y = Cmp.Toggle(p, {text="Forecast", default=true, callback=function(v) S.REV_FEAT.forecast=v end}, y)
y = Cmp.Toggle(p, {text="Director", default=true, callback=function(v) S.REV_FEAT.director=v end}, y)
y = Cmp.Toggle(p, {text="Wager", default=true, callback=function(v) S.REV_FEAT.wager=v end}, y)
y = Cmp.Toggle(p, {text="Blockchain", default=true, callback=function(v) S.REV_FEAT.blockchain=v end}, y)

-- RevGame
y = 0
p = P["RevGame"]
y = Cmp.Section(p, "🎮 GAMEPLAY", y)
y = Cmp.Toggle(p, {text="Multi-Round", default=true, callback=function(v) S.REV_GAME.multiRound=v end}, y)
y = Cmp.Toggle(p, {text="Meta-Game", default=true, callback=function(v) S.REV_GAME.metaGame=v end}, y)
y = Cmp.Toggle(p, {text="Role Rotation", default=true, callback=function(v) S.REV_GAME.roleRot=v end}, y)
y = Cmp.Toggle(p, {text="Legendary", default=true, callback=function(v) S.REV_GAME.legendary=v end}, y)

-- RevStealth
y = 0
p = P["RevStealth"]
y = Cmp.Section(p, "🛡 STEALTH", y)
y = Cmp.Toggle(p, {text="Adversarial", default=true, callback=function(v) S.REV_STEALTH.advExamples=v end}, y)
y = Cmp.Toggle(p, {text="Jitter Dist", default=true, callback=function(v) S.REV_STEALTH.jitterDist=v end}, y)
y = Cmp.Toggle(p, {text="Anti-Anti-Cheat", default=true, callback=function(v) S.REV_STEALTH.antiAntiCheat=v end}, y)
y = Cmp.Toggle(p, {text="Adaptive Rate", default=true, callback=function(v) S.REV_STEALTH.adaptiveRate=v end}, y)
y = Cmp.Toggle(p, {text="Plausible", default=true, callback=function(v) S.REV_STEALTH.plausible=v end}, y)

-- RevMad
y = 0
p = P["RevMad"]
y = Cmp.Section(p, "🌀 MAD", y)
y = Cmp.Toggle(p, {text="Neuro-Sym", default=true, callback=function(v) S.REV_MAD.neuroSym=v end}, y)
y = Cmp.Toggle(p, {text="Quantum", default=true, callback=function(v) S.REV_MAD.quantum=v end}, y)
y = Cmp.Toggle(p, {text="Evolutionary", default=true, callback=function(v) S.REV_MAD.evolutionary=v end}, y)
y = Cmp.Toggle(p, {text="Swarm", default=true, callback=function(v) S.REV_MAD.swarm=v end}, y)
y = Cmp.Toggle(p, {text="Genetic", default=true, callback=function(v) S.REV_MAD.genetic=v end}, y)
y = Cmp.Toggle(p, {text="Ant Colony", default=true, callback=function(v) S.REV_MAD.antColony=v end}, y)
y = Cmp.Toggle(p, {text="Digital Twin", default=true, callback=function(v) S.REV_MAD.digitalTwin=v end}, y)
y = Cmp.Toggle(p, {text="Sleep/Wake", default=true, callback=function(v) S.REV_MAD.sleepWake=v end}, y)
y = Cmp.Toggle(p, {text="Curriculum", default=true, callback=function(v) S.REV_MAD.curriculum=v end}, y)
y = Cmp.Toggle(p, {text="Dream", default=true, callback=function(v) S.REV_MAD.dreamState=v end}, y)
y = Cmp.Toggle(p, {text="Recursive", default=true, callback=function(v) S.REV_MAD.recursive=v end}, y)

-- Innova
y = 0
p = P["Innova"]
y = Cmp.Section(p, "🔬 INNOVATIONS", y)
y = Cmp.Toggle(p, {text="Personality Profiles", default=true}, y)
y = Cmp.Toggle(p, {text="Chams", default=false, callback=function(v) S.Chams=v end}, y)
y = Cmp.Toggle(p, {text="Radar", default=false, callback=function(v) S.Radar=v end}, y)
y = Cmp.Toggle(p, {text="Timeline Predictor", default=false, callback=function(v) S.TimelinePredictor=v end}, y)
y = Cmp.Toggle(p, {text="Muzzle Flash", default=true}, y)

-- Revolu
y = 0
p = P["Revolu"]
y = Cmp.Section(p, "🎯 PREDIÇÃO AVANÇADA", y)
y = Cmp.Toggle(p, {text="Multi-Model Blending", default=true, callback=function(v) HB_MultiModel.enabled=v end}, y)
y = Cmp.Toggle(p, {text="Adaptive FOV", default=true, callback=function(v) HB_AdaptiveFOV.enabled=v end}, y)
y = Cmp.Toggle(p, {text="Ballistic Curve", default=true, callback=function(v) HB_BallisticCurve.enabled=v end}, y)
y = Cmp.Toggle(p, {text="Juke Memory", default=true, callback=function(v) HB_JukeMemory.enabled=v end}, y)
y = Cmp.Section(p, "🔊 FEEDBACK", y)
y = Cmp.Toggle(p, {text="Hit Sound", default=true, callback=function(v) HB_HitSound.enabled=v end}, y)
y = Cmp.Toggle(p, {text="Kill Confirm Sound", default=true, callback=function(v) HB_KillConfirmSound.enabled=v end}, y)
y = Cmp.Section(p, "💾 AUTO-SAVE", y)
y = Cmp.Toggle(p, {text="Auto-Save Enable", default=true, callback=function(v) HB_AutoSave.enabled=v end}, y)
y = Cmp.Button(p, {text="💾 Salvar Agora", callback=function() HB_AutoSaveTick() end}, y)
y = Cmp.Button(p, {text="📂 Restaurar", callback=function() HB_AutoSaveLoad() end}, y)
y = Cmp.Button(p, {text="🗑️ Apagar", danger=true, callback=function() HB_AutoSaveClear() end}, y)

-- Config
y = 0
p = P["Config"]
y = Cmp.Section(p, "🎨 TEMA", y)
local themeList = {}
for k in pairs_(Themes) do themeList[#themeList+1] = k end
tsort(themeList)
y = Cmp.Dropdown(p, {text="Cor", options=themeList, default="Red", callback=function(o)
    if Themes[o] then Palette.Accent = Themes[o]; S.Theme = o end
end}, y)
y = Cmp.Section(p, "SISTEMA", y)
y = Cmp.Toggle(p, {text="Auto Save", default=true, callback=function(v) S.AutoSave=v end}, y)
y = Cmp.Toggle(p, {text="Chat Commands", default=true, callback=function(v) S.ChatCommands=v end}, y)
y = Cmp.Section(p, "⚡ PRESETS", y)
y = Cmp.Button(p, {text="⚡ CARREGAR TRYHARD", callback=function() HB_PresetTryhard() end}, y)
y = Cmp.Button(p, {text="💀 CARREGAR RAGE MAX", danger=true, callback=function() HB_PresetRageMax() end}, y)
y = Cmp.Button(p, {text="🔄 RESETAR", callback=function() HB_PresetReset() end}, y)

--========= UI DRAG =========
local UI_dragState = {active=false, start=nil, origin=nil}
UIS_InputBegan:Connect(function(input)
    if input.UserInputType ~= E_MOUSE1 then return end
    local hdrHit = HB_PointIn(input.Position, UI_header)
    local dragBtnHit = HB_PointIn(input.Position, UI_dragBtn)
    if dragBtnHit or (hdrHit
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
        UI_dragState.origin.Y.Scale, UI_dragState.origin.Y.Offset + d.Y
    )
end)
UIS_InputEnded:Connect(function(input)
    if input.UserInputType ~= E_MOUSE1 then return end
    UI_dragState.active = false
end)

--========= ESP OVERLAY =========
ESP_GUI = HB_Create("ScreenGui", {
    Name = "HB_ESP_Overlay", ResetOnSpawn = false,
    IgnoreGuiInset = true, DisplayOrder = 90
}, PG)
ESP_HOLDER = HB_Create("Frame", {
    Size = newUD2(1, 0, 1, 0), BackgroundTransparency = 1
}, ESP_GUI)

ESP_COLORS = {
    Murderer = c3(255, 40, 40), Sheriff = c3(50, 140, 255),
    Innocent = c3(50, 220, 90), Dead = c3(120, 120, 120)
}
ESP_CACHE = {}
CHAMS_CACHE = {}

function ESP_create()
    local box = HB_Create("Frame", {
        BackgroundTransparency = 1, BorderSizePixel = 0,
        Visible = false, ZIndex = 5
    }, ESP_HOLDER)
    local st = HB_Create("UIStroke", {
        Color = c3(255, 255, 255), Thickness = 2, Transparency = 0
    }, box)
    local tracer = HB_Create("Frame", {
        BackgroundColor3 = c3(255, 255, 255),
        BorderSizePixel = 0, Visible = false, ZIndex = 4,
        AnchorPoint = Vector2.new(0.5, 0.5)
    }, ESP_HOLDER)
    return {box=box, stroke=st, tracer=tracer}
end

RADAR_GUI = HB_Create("ScreenGui", {
    Name = "HB_Radar", ResetOnSpawn = false,
    IgnoreGuiInset = true, DisplayOrder = 86
}, PG)
RADAR_FRAME = HB_Create("Frame", {
    Size = newUD2(0, 160, 0, 160), Position = newUD2(0, 10, 1, -170),
    BackgroundColor3 = c3(10, 10, 14), BackgroundTransparency = 0.4,
    BorderSizePixel = 0, Visible = false, ZIndex = 70
}, RADAR_GUI)
HB_Corner(RADAR_FRAME, 80)
HB_Stroke(RADAR_FRAME, c3(255, 255, 255), 2, 0.5)
RADAR_CENTER = HB_Create("Frame", {
    Size = newUD2(0, 8, 0, 8), Position = newUD2(0.5, -4, 0.5, -4),
    BackgroundColor3 = c3(255, 255, 255),
    BorderSizePixel = 0, ZIndex = 72
}, RADAR_FRAME)
HB_Corner(RADAR_CENTER, 4)

TIMELINE_GUI = HB_Create("ScreenGui", {
    Name = "HB_Timeline", ResetOnSpawn = false,
    IgnoreGuiInset = true, DisplayOrder = 87
}, PG)
TIMELINE_HOLDER = HB_Create("Frame", {
    Size = newUD2(1, 0, 1, 0), BackgroundTransparency = 1
}, TIMELINE_GUI)

HUD_GUI = HB_Create("ScreenGui", {
    Name = "HB_HUD_Overlay", ResetOnSpawn = false,
    IgnoreGuiInset = true, DisplayOrder = 95
}, PG)

KILLFEED = HB_Create("Frame", {
    Size = newUD2(0, 300, 0, 300), Position = newUD2(1, -310, 0, 100),
    BackgroundTransparency = 1
}, HUD_GUI)

HITMARKER = HB_Create("Frame", {
    Size = newUD2(0, 40, 0, 40), Position = newUD2(0.5, -20, 0.5, -20),
    BackgroundTransparency = 1, Visible = false, ZIndex = 50
}, HUD_GUI)
for _, cfg in ipairs_({ {-8,-8,45},{8,-8,-45},{-8,8,-45},{8,8,45} }) do
    HB_Create("Frame", {
        Size = newUD2(0, 10, 0, 2),
        Position = newUD2(0.5, cfg[1], 0.5, cfg[2]),
        AnchorPoint = Vector2.new(0.5, 0.5),
        BackgroundColor3 = c3(255, 255, 255),
        BorderSizePixel = 0, Rotation = cfg[3]
    }, HITMARKER)
end

CROSSHAIR = HB_Create("Frame", {
    Size = newUD2(0, 40, 0, 40), Position = newUD2(0.5, -20, 0.5, -20),
    BackgroundTransparency = 1, Visible = S.Cross, ZIndex = 40
}, HUD_GUI)
for _, cfg in ipairs_({ {0,-12,2,8},{0,12,2,8},{-12,0,8,2},{12,0,8,2} }) do
    HB_Create("Frame", {
        Size = newUD2(0, cfg[3], 0, cfg[4]),
        Position = newUD2(0.5, cfg[1], 0.5, cfg[2]),
        AnchorPoint = Vector2.new(0.5, 0.5),
        BackgroundColor3 = c3(220, 40, 40),
        BorderSizePixel = 0
    }, CROSSHAIR)
end

--========= HUD HELPERS =========
local HITFADE
HBShowHitmarker = function()
    if not S.Hitmark then return end
    HITMARKER.Visible = true
    for _, c in ipairs_(HITMARKER:GetChildren()) do
        if c:IsA("Frame") then c.BackgroundColor3 = c3(255, 60, 60) end
    end
    if HITFADE then task.cancel(HITFADE) end
    HITFADE = delay(0.15, function()
        HITMARKER.Visible = false
        for _, c in ipairs_(HITMARKER:GetChildren()) do
            if c:IsA("Frame") then c.BackgroundColor3 = c3(255, 255, 255) end
        end
    end)
end

HBKillFeed = function(victimName, distance)
    if not S.KillFeed then return end
    local entry = HB_Create("Frame", {
        Size = newUD2(1, 0, 0, 30), Position = newUD2(1, 0, 0, 0),
        BackgroundColor3 = c3(18, 18, 22), BackgroundTransparency = 0.15,
        BorderSizePixel = 0
    }, KILLFEED)
    HB_Corner(entry, 6)
    HB_Stroke(entry, Palette.Accent, 1, 0.3)
    HB_Create("TextLabel", {
        Size = newUD2(1, -20, 1, 0), Position = newUD2(0, 10, 0, 0),
        BackgroundTransparency = 1,
        Text = sformat("☠ %s [%dm]", victimName, floor(distance or 0)),
        Font = E_GOTHAM_MED, TextSize = 12,
        TextColor3 = c3(255, 200, 200), TextXAlignment = E_TXT_LEFT
    }, entry)
    delay(4, function()
        TweenService:Create(entry, TweenInfo.new(0.5), {BackgroundTransparency=1}):Play()
        wait(0.6)
        if entry.Parent then entry:Destroy() end
    end)
end

--========= SISTEMAS AVANÇADOS =========
HB_MultiModel = {
    enabled=true, samples=3, kalmanWeight=0.4, nnWeight=0.4,
    activeInfWeight=0.2, lastPrediction=nil, hits=0, misses=0
}
HB_AdaptiveFOV = {
    enabled=true, nearDist=15, farDist=80, nearFOV=90, farFOV=60,
    currentFOV=70, originalFOV=70, smooth=0.15, lastUpdate=0
}
HB_BallisticCurve = {
    enabled=true, gravity=196.2, drag=0.015, wind=v3zero, lastCalc=nil
}
HB_JukeMemory = {
    enabled=true, memory={}, maxPatterns=8, detectThreshold=0.4, lastCheck=0
}
HB_HitSound = {
    enabled=true, soundId="rbxasset://sounds/electronicpingshort.wav",
    volume=0.4, pitchMin=1.1, pitchMax=1.4,
    lastPlay=0, cooldown=0.05, instance=nil
}
HB_KillConfirmSound = {
    enabled=true, soundId="rbxasset://sounds/electronicpingshort.wav",
    volume=0.6, pitch=0.7, lastPlay=0, instance=nil
}
HB_AutoSave = {
    enabled=true, interval=30, lastSave=0,
    saveKey="HB_AutoSave_Config", savesCount=0
}

--========= SONS =========
function HB_InitHitSound()
    if HB_HitSound.instance then return end
    local s = Instance.new("Sound")
    s.Name = "HB_HitSound"
    s.SoundId = HB_HitSound.soundId
    s.Volume = HB_HitSound.volume
    s.Parent = SoundService
    HB_HitSound.instance = s
end

function HB_InitKillSound()
    if HB_KillConfirmSound.instance then return end
    local s = Instance.new("Sound")
    s.Name = "HB_KillSound"
    s.SoundId = HB_KillConfirmSound.soundId
    s.Volume = HB_KillConfirmSound.volume
    s.PlaybackSpeed = HB_KillConfirmSound.pitch
    s.Parent = SoundService
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
        s.PlaybackSpeed = HB_HitSound.pitchMin
            + random() * (HB_HitSound.pitchMax - HB_HitSound.pitchMin)
        s.Volume = HB_HitSound.volume
        s.Parent = SoundService
        s:Play()
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
        s.Volume = HB_KillConfirmSound.volume
        s.Parent = SoundService
        s:Play()
        delay(2, function() if s then s:Destroy() end end)
    end
end

--========= JUKE / FOV / AUTOSAVE =========
function HB_JukeMemoryAnalyze(player, h)
    if not HB_JukeMemory.enabled or not h or h.spCount < 10 then return nil end
    local n = h.spCount < 10 and h.spCount or 10
    local head = h.spHead
    local moveX, moveY, moveZ = {}, {}, {}
    local mMag = 0
    local prevJ = head - n + 1
    if prevJ < 1 then prevJ = prevJ + HB_HIST_SZ end
    for i = 1, n - 1 do
        local curJ = prevJ + 1
        if curJ > HB_HIST_SZ then curJ = curJ - HB_HIST_SZ end
        local dx = h.spX[curJ] - h.spX[prevJ]
        local dy = h.spY[curJ] - h.spY[prevJ]
        local dz = h.spZ[curJ] - h.spZ[prevJ]
        local mag = sqrt(dx*dx + dy*dy + dz*dz)
        if mag > 0.1 then
            mMag = mMag + 1
            moveX[mMag] = dx/mag
            moveY[mMag] = dy/mag
            moveZ[mMag] = dz/mag
        end
        prevJ = curJ
    end
    if mMag < 5 then return nil end
    local dirChanges = 0
    for i = 2, mMag do
        local dot = moveX[i]*moveX[i-1] + moveY[i]*moveY[i-1] + moveZ[i]*moveZ[i-1]
        if dot < HB_JukeMemory.detectThreshold then dirChanges = dirChanges + 1 end
    end
    local jukeType = "straight"
    if dirChanges >= 3 then jukeType = "zigzag"
    elseif dirChanges >= 1 then jukeType = "single" end
    local mem = HB_JukeMemory.memory[player]
    if not mem then mem = {patterns = {}, total = 0}; HB_JukeMemory.memory[player] = mem end
    mem.patterns[jukeType] = (mem.patterns[jukeType] or 0) + 1
    mem.total = mem.total + 1
    if mem.total % (HB_JukeMemory.maxPatterns * 5) == 0 then
        local bestCount = 0
        for k, v in pairs_(mem.patterns) do
            if v > bestCount then bestCount = v; mem.dominant = k end
        end
    end
    return jukeType
end

function HB_UpdateAdaptiveFOV()
    if not HB_AdaptiveFOV.enabled then return end
    local targetDist = HB_AdaptiveFOV.farDist
    local closestDist = 9999
    local myHrp = LP.Character and LP.Character:FindFirstChild("HumanoidRootPart")
    if myHrp then
        local myPos = myHrp.Position
        for i = 1, #Cache.List do
            local p2 = Cache.List[i]
            if p2 ~= LP and GetRole(p2) == "Murderer" then
                local hrp = Cache.HRPs[p2]
                if hrp then
                    local d = (hrp.Position - myPos).Magnitude
                    if d < closestDist then closestDist = d end
                end
            end
        end
    end
    if closestDist < 9999 then targetDist = closestDist end
    local pct = clamp(
        (targetDist - HB_AdaptiveFOV.nearDist)
        / (HB_AdaptiveFOV.farDist - HB_AdaptiveFOV.nearDist),
        0, 1
    )
    local targetFOV = HB_AdaptiveFOV.nearFOV
        + (HB_AdaptiveFOV.farFOV - HB_AdaptiveFOV.nearFOV) * pct
    HB_AdaptiveFOV.currentFOV = HB_AdaptiveFOV.currentFOV
        + (targetFOV - HB_AdaptiveFOV.currentFOV) * HB_AdaptiveFOV.smooth
    pcall(function() Camera.FieldOfView = HB_AdaptiveFOV.currentFOV end)
end

function HB_AutoSaveTick()
    if not HB_AutoSave.enabled then return end
    if tick() - HB_AutoSave.lastSave < HB_AutoSave.interval then return end
    HB_AutoSave.lastSave = tick()
    HB_AutoSave.savesCount = HB_AutoSave.savesCount + 1
    local snapshot = {}
    for k, v in pairs_(S) do
        local t = type(v)
        if t == "boolean" or t == "number" or t == "string" then
            snapshot[k] = v
        end
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
    return true
end

function HB_AutoSaveClear()
    _G[HB_AutoSave.saveKey] = nil
    HB_AutoSave.savesCount = 0
end

--========= RSI =========
HB_RSI = {
    enabled=true, generation=1, population={}, popSize=20,
    bestGenome=nil, bestFitness=0, mutations=0, crossovers=0, reverts=0,
    killsSinceEvolve=0, evolveEveryKills=5,
    generationHistory={}, lastApplyTick=0, applyInterval=1.0, maxHistory=50
}

function HB_RSI_NewGenome()
    return {
        snap=0.030+random()*0.040, hold=0.100+random()*0.150,
        verify=0.300+random()*0.400, noise=0.00+random()*0.30,
        aggression=0.3+random()*0.7,
        fitness=0.5, wins=0, losses=0, bornAt=tick()
    }
end

function HB_RSI_Init()
    HB_RSI.population = {}
    for i = 1, HB_RSI.popSize do
        HB_RSI.population[i] = HB_RSI_NewGenome()
    end
    HB_RSI.bestGenome = HB_RSI.population[1]
    HB_RSI.bestFitness = 0.5
end
HB_RSI_Init()

function HB_RSI_Mutate(genome, rate)
    rate = rate or 0.15
    local g = {
        snap=genome.snap, hold=genome.hold, verify=genome.verify,
        noise=genome.noise, aggression=genome.aggression,
        fitness=0.5, wins=0, losses=0, bornAt=tick()
    }
    if random() < rate then g.snap = clamp(g.snap + (random()-0.5)*0.015, 0.015, 0.150) end
    if random() < rate then g.hold = clamp(g.hold + (random()-0.5)*0.060, 0.050, 0.400) end
    if random() < rate then g.verify = clamp(g.verify + (random()-0.5)*0.150, 0.200, 1.000) end
    if random() < rate then g.noise = clamp(g.noise + (random()-0.5)*0.100, 0.000, 0.500) end
    if random() < rate then g.aggression = clamp(g.aggression + (random()-0.5)*0.200, 0.100, 1.000) end
    HB_RSI.mutations = HB_RSI.mutations + 1
    return g
end

function HB_RSI_Crossover(a, b)
    local g = {
        snap = random()<0.5 and a.snap or b.snap,
        hold = random()<0.5 and a.hold or b.hold,
        verify = random()<0.5 and a.verify or b.verify,
        noise = random()<0.5 and a.noise or b.noise,
        aggression = random()<0.5 and a.aggression or b.aggression,
        fitness=0.5, wins=0, losses=0, bornAt=tick()
    }
    HB_RSI.crossovers = HB_RSI.crossovers + 1
    return g
end

function HB_RSI_Fitness(genome)
    local total = genome.wins + genome.losses
    if total == 0 then return 0.5 end
    return genome.wins / total
end

function HB_RSI_Evolve()
    tsort(HB_RSI.population, function(a, b)
        return HB_RSI_Fitness(a) > HB_RSI_Fitness(b)
    end)
    local elite = floor(HB_RSI.popSize * 0.2)
    local newPop = {}
    for i = 1, elite do newPop[i] = HB_RSI.population[i] end
    while #newPop < HB_RSI.popSize do
        local a = HB_RSI.population[random(1, elite)]
        local b = HB_RSI.population[random(1, elite)]
        local child = HB_RSI_Crossover(a, b)
        child = HB_RSI_Mutate(child, 0.20)
        newPop[#newPop+1] = child
    end
    HB_RSI.population = newPop
    local oldBest = HB_RSI.bestFitness
    HB_RSI.bestGenome = HB_RSI.population[1]
    HB_RSI.bestFitness = HB_RSI_Fitness(HB_RSI.bestGenome)
    if HB_RSI.bestFitness < oldBest then HB_RSI.reverts = HB_RSI.reverts + 1 end
    HB_RSI.generation = HB_RSI.generation + 1
    HB_RSI.generationHistory[#HB_RSI.generationHistory+1] = {
        gen=HB_RSI.generation, fitness=HB_RSI.bestFitness,
        snap=HB_RSI.bestGenome.snap, hold=HB_RSI.bestGenome.hold, t=tick()
    }
    if #HB_RSI.generationHistory > HB_RSI.maxHistory then
        tremove(HB_RSI.generationHistory, 1)
    end
end

function HB_RSI_Apply()
    if not HB_RSI.enabled then return end
    if tick() - HB_RSI.lastApplyTick < HB_RSI.applyInterval then return end
    HB_RSI.lastApplyTick = tick()
    local g = HB_RSI.bestGenome
    if not g or not Flick then return end
    Flick.snapDur = Flick.snapDur * 0.85 + g.snap * 0.15
    Flick.holdDur = Flick.holdDur * 0.85 + g.hold * 0.15
    Flick.verifyWait = Flick.verifyWait * 0.85 + g.verify * 0.15
end

function HB_RSI_RecordKill()
    if not HB_RSI.enabled then return end
    local g = HB_RSI.bestGenome
    if g then
        g.wins = g.wins + 1
        g.fitness = HB_RSI_Fitness(g)
    end
    HB_RSI.killsSinceEvolve = HB_RSI.killsSinceEvolve + 1
    if HB_RSI.killsSinceEvolve >= HB_RSI.evolveEveryKills then
        HB_RSI.killsSinceEvolve = 0
        pcall(HB_RSI_Evolve)
    end
end

function HB_RSI_RecordMiss()
    if not HB_RSI.enabled then return end
    local g = HB_RSI.bestGenome
    if g then
        g.losses = g.losses + 1
        g.fitness = HB_RSI_Fitness(g)
    end
end

--========= RAGE METER =========
HB_RageMeter = {
    enabled=true, active=false, activatedAt=0,
    roundStartTick=0, lastRoundCheck=0,
    rageKills=0, rageDeaths=0, myDeathThisRound=false,
    boostSnap=0.5, boostHold=0.5, boostVerify=0.5,
    originalValues={}
}

function HB_RageMeter_SaveOriginals()
    if not Flick then return end
    HB_RageMeter.originalValues = {
        snapDur=Flick.snapDur, holdDur=Flick.holdDur,
        verifyWait=Flick.verifyWait,
        alignTol=S.AlignTol, retries=S.Retries,
        rateLimit=S.RateLimit, fakeMiss=S.FakeMiss,
        antiFlick=S.AntiFlickBlock
    }
end

function HB_RageMeter_Activate()
    if not HB_RageMeter.enabled or HB_RageMeter.active then return end
    HB_RageMeter_SaveOriginals()
    HB_RageMeter.active = true
    HB_RageMeter.activatedAt = tick()
    HB_RageMeter.rageKills = 0
    HB_RageMeter.rageDeaths = 0
    HB_RageMeter.myDeathThisRound = false
    if Flick then
        Flick.snapDur = Flick.snapDur * HB_RageMeter.boostSnap
        Flick.holdDur = Flick.holdDur * HB_RageMeter.boostHold
        Flick.verifyWait = Flick.verifyWait * HB_RageMeter.boostVerify
        Flick.retriesLeft = 20
    end
    S.AlignTol = max(1, S.AlignTol * 0.5)
    S.Retries = 20
    S.RateLimit = false
    S.FakeMiss = false
    S.AntiFlickBlock = false
end

function HB_RageMeter_Deactivate(reason)
    if not HB_RageMeter.active then return end
    HB_RageMeter.active = false
    local o = HB_RageMeter.originalValues
    if Flick then
        if o.snapDur then Flick.snapDur = o.snapDur end
        if o.holdDur then Flick.holdDur = o.holdDur end
        if o.verifyWait then Flick.verifyWait = o.verifyWait end
    end
    if o.alignTol then
        S.AlignTol = o.alignTol
        S.Retries = o.retries
        S.RateLimit = o.rateLimit
        S.FakeMiss = o.fakeMiss
        S.AntiFlickBlock = o.antiFlick
    end
end

function HB_RageMeter_IsAlive()
    local myChar = LP.Character
    if not myChar then return false end
    local myHum = myChar:FindFirstChildOfClass("Humanoid")
    return myHum and myHum.Health > 0
end

function HB_RageMeter_DetectRoundStart()
    local now = tick()
    if now - HB_RageMeter.lastRoundCheck < 1 then return false end
    HB_RageMeter.lastRoundCheck = now
    if not HB_RageMeter_IsAlive() then return false end
    local aliveCount, murdererCount, totalPlayers = 0, 0, 0
    for i = 1, #Cache.List do
        local p2 = Cache.List[i]
        totalPlayers = totalPlayers + 1
        local ch = Cache.Chars[p2]
        if ch then
            local hum = ch:FindFirstChildOfClass("Humanoid")
            if hum and hum.Health > 0 then
                aliveCount = aliveCount + 1
                if GetRole(p2) == "Murderer" then murdererCount = murdererCount + 1 end
            end
        end
    end
    if aliveCount >= totalPlayers - 1 and murdererCount >= 1 then
        if now - HB_RageMeter.roundStartTick > 15 then
            HB_RageMeter.roundStartTick = now
            return true
        end
    end
    return false
end

function HB_RageMeter_DetectRoundEnd()
    if not HB_RageMeter.active then return false end
    if not HB_RageMeter_IsAlive() then
        if not HB_RageMeter.myDeathThisRound then
            HB_RageMeter.myDeathThisRound = true
            HB_RageMeter.rageDeaths = HB_RageMeter.rageDeaths + 1
            return "death"
        end
        return false
    end
    local aliveMurderers = 0
    for i = 1, #Cache.List do
        local p2 = Cache.List[i]
        if p2 ~= LP and GetRole(p2) == "Murderer" then
            local ch = Cache.Chars[p2]
            if ch then
                local hum = ch:FindFirstChildOfClass("Humanoid")
                if hum and hum.Health > 0 then aliveMurderers = aliveMurderers + 1 end
            end
        end
    end
    local myRole = GetRole(LP)
    if myRole == "Murderer" then
        local aliveInnocents = 0
        for i = 1, #Cache.List do
            local p2 = Cache.List[i]
            if p2 ~= LP then
                local role = GetRole(p2)
                if role == "Innocent" or role == "Sheriff" then
                    local ch = Cache.Chars[p2]
                    if ch then
                        local hum = ch:FindFirstChildOfClass("Humanoid")
                        if hum and hum.Health > 0 then aliveInnocents = aliveInnocents + 1 end
                    end
                end
            end
        end
        if aliveInnocents == 0 then return "round_end" end
    else
        if aliveMurderers == 0 then return "round_end" end
    end
    return false
end

--========= PRESETS =========
HB_Presets = {}

HB_Presets.TRYHARD = {
    AutoFlick=true, AlignTol=1, Retries=20, AimSmooth=0.02, FlickMode="Rage",
    TrigOn=false, TrigRad=250, RateLimit=false, FakeMiss=false, Humanize=false,
    AntiFlickBlock=false, RandomAim=false, ESP=true, Chams=true, ESPArrows=true,
    ESPSkeleton=true, Radar=true, TimelinePredictor=true, Hitmark=true,
    KillFeed=true, Cross=true, FPSAdaptive=true, HitscanOpt=true,
    WeaponCooldownCheck=false, PostKillDelay=false, PreAim=true, StickyAim=true,
    StickyAimStrength=0.6, ProgressiveFlick=true, SmartTarget=true,
    NNReal=true, NNRate=0.05, RSIEnabled=true
}

HB_Presets.RAGE_MAX = {
    AutoFlick=true, AlignTol=0.5, Retries=99, AimSmooth=0.0, FlickMode="Rage",
    TrigOn=false, TrigRad=999, RateLimit=false, FakeMiss=false, Humanize=false,
    AntiFlickBlock=false, RandomAim=false, ESP=true, ESPThick=3, Chams=true,
    ESPArrows=true, ESPSkeleton=true, Radar=true, TimelinePredictor=true,
    Hitmark=true, KillFeed=true, Cross=true, CrossSize=20, FPSAdaptive=true,
    FPSAdaptiveMinFPS=15, HitscanOpt=true, WeaponCooldownCheck=false,
    PostKillDelay=false, PreAim=true, StickyAim=true, StickyAimStrength=1.0,
    ProgressiveFlick=true, SmartTarget=true, AimHumanization=false,
    NNReal=true, NNRate=0.20, RSIEnabled=true, HysteresisMs=0,
    AntiFlickBackoff=0
}

function HB_ApplyPreset(name)
    local preset = HB_Presets[name]
    if not preset then return end
    for k, v in pairs_(preset) do S[k] = v end
    if Flick then
        if name == "RAGE_MAX" then
            Flick.snapDur = 0.001
            Flick.holdDur = 0.010
            Flick.verifyWait = 0.050
            Flick.returnDur = 0.020
            Flick.retriesLeft = 999
        else
            Flick.snapDur = 0.010
            Flick.holdDur = 0.050
            Flick.verifyWait = 0.200
            Flick.returnDur = 0.060
            Flick.retriesLeft = 20
        end
    end
    if S.REV_HUMAN then
        S.REV_HUMAN.warmup = false
        S.REV_HUMAN.cooldown = false
        S.REV_HUMAN.fatigue = false
        S.REV_HUMAN.cognitive = false
        S.REV_HUMAN.emotion = false
        if name == "RAGE_MAX" then
            S.REV_HUMAN.persona = "aggressive"
            S.REV_HUMAN.personaStrength = 1.0
        end
    end
    if HB_RSI then
        HB_RSI.enabled = true
        HB_RSI.evolveEveryKills = (name == "RAGE_MAX") and 2 or 5
    end
    if HB_RageMeter then
        HB_RageMeter.enabled = true
        if name == "RAGE_MAX" then
            HB_RageMeter.boostSnap = 0.10
            HB_RageMeter.boostHold = 0.10
            HB_RageMeter.boostVerify = 0.10
        else
            HB_RageMeter.boostSnap = 0.30
            HB_RageMeter.boostHold = 0.30
            HB_RageMeter.boostVerify = 0.30
        end
    end
end

function HB_PresetTryhard() HB_ApplyPreset("TRYHARD") end
function HB_PresetRageMax() HB_ApplyPreset("RAGE_MAX") end

function HB_PresetReset()
    if Flick then
        Flick.snapDur = 0.045
        Flick.holdDur = 0.150
        Flick.verifyWait = 0.500
        Flick.returnDur = 0.100
        Flick.retriesLeft = 2
    end
    S.AlignTol = 4
    S.Retries = 2
    S.AimSmooth = 0.15
    S.FakeMiss = false
    S.RateLimit = true
    S.Humanize = true
    S.AntiFlickBlock = true
    S.TrigOn = false
    S.ESP = false
    S.Chams = false
    S.ESPArrows = false
    S.ESPSkeleton = false
    S.Radar = false
    S.TimelinePredictor = false
    S.PreAim = false
    S.StickyAim = false
    S.ProgressiveFlick = false
    if HB_RageMeter then HB_RageMeter_Deactivate("manual") end
end

--========= HOOK MetaLearn (sons + RSI + RageMeter) =========
local HB_MLFinal = MetaLearnUpdate
MetaLearnUpdate = function(perf)
    HB_MLFinal(perf)
    if perf and perf > 0.5 then
        pcall(HB_PlayKillSound)
        pcall(HB_RSI_RecordKill)
        if HB_RageMeter.active then
            HB_RageMeter.rageKills = HB_RageMeter.rageKills + 1
            if Flick then Flick.snapDur = max(0.005, Flick.snapDur * 0.92) end
        end
    else
        pcall(HB_PlayHitSound)
        pcall(HB_RSI_RecordMiss)
    end
end

--========= TRIGGER BOT =========
local TriggerAccum = 0
local TRIGGER_INTERVAL = 1 / 30

RS_Heartbeat:Connect(function(dt)
    if not S.TrigOn then return end
    TriggerAccum = TriggerAccum + dt
    if TriggerAccum < TRIGGER_INTERVAL then return end
    TriggerAccum = 0

    local now = tick()
    local flickBusy = Flick and (Flick.active or (now - (Flick.lastFlickEnd or 0)) < 0.25)
    local suppressed = now < TriggerSuppressUntil
    local flickKeyHeld = Flick and Flick.keyHeld
    if flickBusy or suppressed or flickKeyHeld then return end

    local mouse = UIS:GetMouseLocation()
    local best, bestD = nil, S.TrigRad
    local list = Cache.List
    for i = 1, #list do
        local p2 = list[i]
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

    local w = FindWeapon()
    if not w then return end
    local head = Cache.Heads[best]
    if not head then return end

    local myChar = LP.Character
    local eq = myChar and myChar:FindFirstChildOfClass("Tool")
    if eq ~= w then
        EquipWeapon(w)
        eq = myChar and myChar:FindFirstChildOfClass("Tool")
    end
    if eq and not IsWeaponOnCooldown(eq) then
        SilentFire(eq, head.Position)
    end
end)

--========= LOOP CONSOLIDADO =========
local TaskAccum = {t01=0, t05=0, t1=0, t5=0, t10=0, t30=0}

RS_Heartbeat:Connect(function(dt)
    local a = TaskAccum
    a.t01 = a.t01 + dt
    a.t05 = a.t05 + dt
    a.t1  = a.t1  + dt
    a.t5  = a.t5  + dt
    a.t10 = a.t10 + dt
    a.t30 = a.t30 + dt

    if a.t01 >= 0.1 then
        a.t01 = 0
        pcall(HB_UpdateAdaptiveFOV)
    end

    if a.t05 >= 0.5 then
        a.t05 = 0
        pcall(SquadDetect)
        pcall(EmotionUpdate)
        pcall(GameStateRecon)
        if HB_JukeMemory.enabled then
            for i = 1, #Cache.List do
                local p2 = Cache.List[i]
                if p2 ~= LP then
                    local h = Hst[p2]
                    if h then pcall(HB_JukeMemoryAnalyze, p2, h) end
                end
            end
        end
        if HB_RageMeter.enabled then
            if not HB_RageMeter.active then
                if HB_RageMeter_DetectRoundStart() then
                    wait(random(1, 3))
                    pcall(HB_RageMeter_Activate)
                end
            else
                local r = HB_RageMeter_DetectRoundEnd()
                if r then pcall(HB_RageMeter_Deactivate, r) end
            end
        end
        if UI.StatsDisplay and UI.StatsDisplay.Parent then
            local fps = FPS.cur or 60
            local ping = floor(LP:GetNetworkPing() * 1000)
            UI.StatsDisplay.Text = sformat(
                "📊 SESSÃO\n\nKills: %d\nDeaths: %d\nStreak: %d\nBest: %d\n\nNN trained: %d\nMeta epochs: %d\nRSI gen: %d (%.0f%%)\nFPS: %.0f\nPing: %dms",
                S.Kills, S.Deaths, S.Streak or 0, S.BestStreak or 0,
                NNReal.trained, RevAI.epochs,
                HB_RSI.generation, HB_RSI.bestFitness * 100,
                fps, ping
            )
        end
    end

    if a.t1 >= 1 then
        a.t1 = 0
        pcall(AntiAntiCheatCheck)
        if HB_RSI.enabled then pcall(HB_RSI_Apply) end
    end

    if a.t5 >= 5 then
        a.t5 = 0
        pcall(MultiRoundPlan)
        pcall(RoleRotation)
        pcall(LegendaryCheck)
        if HB_AutoSave.enabled then pcall(HB_AutoSaveTick) end
    end

    if a.t10 >= 10 then
        a.t10 = 0
        pcall(DigitalTwinUpdate)
        pcall(SleepWakeTick)
        pcall(CurriculumAdvance)
        pcall(DreamTrain)
        pcall(RecursiveImprove)
    end

    if a.t30 >= 30 then
        a.t30 = 0
        pcall(SnapshotState)
        pcall(AdversarialTick)
        pcall(SelfPlayTick)
    end
end)

--========= BOOT =========
S.TrigOn = false
UI.switchTab("Aimbot")
UI_main.Visible = true
HB_AutoSaveLoad()