Players=game:GetService("Players")
UIS=game:GetService("UserInputService")
RS=game:GetService("RunService")
TweenService=game:GetService("TweenService")
Lighting=game:GetService("Lighting")
HttpService=game:GetService("HttpService")
ReplicatedStorage=game:GetService("ReplicatedStorage")
LP=Players.LocalPlayer
PG=LP:WaitForChild("PlayerGui")
Camera=workspace.CurrentCamera
HB_V="v9.0"
HB_SERIAL=tostring(math.random(10000000,99999999))
HB_TITLE="HELLBORN"
HB_X="HB_"..math.random(10000,99999).."_"
HB_PAD=14
HB_ROW_H=42
HB_ROW_GAP=8
HB_SECTION_H=34
HB_HIST_SZ=60
HB_MAX_UNDO=30
HB_POOL_SIZE=200
for _,g in ipairs(PG:GetChildren()) do
    if g:IsA("ScreenGui") and (g.Name:find("HB_") or g.Name:find("HELLBORN")) then
        g:Destroy()
    end
end
for _,o in ipairs(Lighting:GetChildren()) do
    if o:IsA("BlurEffect") then
        o:Destroy()
    end
end
function HB_Safe(fn,...)
    local a={...}
    return pcall(function()
        return fn(table.unpack(a))
    end)
end
function HB_Create(cls,props,children)
    local i=Instance.new(cls)
    local par
    if props then
        for k,v in pairs(props) do
            if k=="Parent" then
                par=v
            else
                pcall(function() i[k]=v end)
            end
        end
    end
    if children then
        if typeof(children)=="Instance" then
            i.Parent=children
        else
            for _,c in ipairs(children) do
                c.Parent=i
            end
        end
    end
    if par then
        i.Parent=par
    end
    return i
end
function HB_Corner(p,r)
    return HB_Create("UICorner",{CornerRadius=UDim.new(0,r or 8),Parent=p})
end
function HB_Stroke(p,c,t,tr)
    return HB_Create("UIStroke",{Color=c or Color3.fromRGB(40,40,48),Thickness=t or 1,Transparency=tr or 0,Parent=p})
end
function HB_EaseS(t)
    return t*t*(3-2*t)
end
function HB_EaseBezier(t,p1,p2)
    local u=1-t
    return 3*u*u*t*p1+3*u*t*t*p2+t*t*t
end
function HB_Spring(obj,prop,target,speed)
    speed=speed or 16
    local conn
    conn=RS.Heartbeat:Connect(function(dt)
        if not obj or not obj.Parent then
            conn:Disconnect()
            return
        end
        local cur=obj[prop]
        if typeof(cur)=="number" then
            local n=cur+(target-cur)*math.min(dt*speed,1)
            if math.abs(target-cur)<0.0005 then
                obj[prop]=target
                conn:Disconnect()
                return
            end
            obj[prop]=n
        elseif typeof(cur)=="Color3" then
            local r=cur.R+(target.R-cur.R)*math.min(dt*speed,1)
            local g=cur.G+(target.G-cur.G)*math.min(dt*speed,1)
            local b=cur.B+(target.B-cur.B)*math.min(dt*speed,1)
            if math.abs(target.R-cur.R)<0.005 and math.abs(target.B-cur.B)<0.005 then
                obj[prop]=target
                conn:Disconnect()
                return
            end
            obj[prop]=Color3.new(r,g,b)
        else
            obj[prop]=target
            conn:Disconnect()
        end
    end)
end
function HB_PointIn(pos,obj)
    if not obj or not obj.Parent then
        return false
    end
    local ap,sz=obj.AbsolutePosition,obj.AbsoluteSize
    return pos.X>=ap.X and pos.X<=ap.X+sz.X and pos.Y>=ap.Y and pos.Y<=ap.Y+sz.Y
end
Palette={
    Base=Color3.fromRGB(10,10,12),
    Surface=Color3.fromRGB(18,18,22),
    Elevated=Color3.fromRGB(26,26,32),
    Elevated2=Color3.fromRGB(34,34,42),
    Border=Color3.fromRGB(40,40,50),
    TextHigh=Color3.fromRGB(245,245,250),
    TextMid=Color3.fromRGB(160,160,175),
    TextLow=Color3.fromRGB(100,100,115),
    Accent=Color3.fromRGB(220,40,40),
    Success=Color3.fromRGB(0,210,120),
    Warning=Color3.fromRGB(255,180,0),
    Danger=Color3.fromRGB(255,60,60),
}
Themes={
    Red=Color3.fromRGB(220,40,40),
    Blue=Color3.fromRGB(50,130,255),
    Green=Color3.fromRGB(30,200,90),
    Purple=Color3.fromRGB(170,60,230),
    Cyan=Color3.fromRGB(30,210,220),
    Neon=Color3.fromRGB(0,255,180),
    Matrix=Color3.fromRGB(0,230,70),
    Blood=Color3.fromRGB(140,0,0),
    Custom=Color3.fromRGB(220,40,40),
}
S=S or {}
S.AutoFlick=true
S.FlickKey=Enum.KeyCode.Q
S.SilentOn=true
S.AIOn=true
S.KillConfirm=true
S.VerifyHit=true
S.RetryMiss=true
S.AlignTol=4
S.Retries=2
S.AimSmooth=0.15
S.FlickMode="Normal"
S.TrigOn=false
S.TrigRad=60
S.TrigCD=0.35
S.TrigHead=true
S.ESP=false
S.ESPName=true
S.ESP_LOD=true
S.Companion=false
S.Hitmark=true
S.KillFeed=true
S.Watermark=false
S.Cross=false
S.CrossStyle="Cross"
S.CrossSize=12
S.FOVCirc=false
S.LockVis=false
S.LockInd=true
S.HUD=false
S.Stealth=false
S.UISnd=true
S.HitSnd=true
S.HitSndType="Default"
S.PerAction=false
S.AutoSave=true
S.Theme="Red"
S.UIFont="Gotham"
S.Profile="Default"
S.Part=true
S.PartCount=40
S.AntiDetect=true
S.Clean=false
S.DebugOn=false
S.LayoutEd=false
S.KeybindPer=false
S.SnapToEdge=true
S.MicroDev=true
S.ReactDelay=true
S.ReactMin=0.08
S.ReactMax=0.18
S.MouseSim=true
S.Backoff=true
S.FakeIn=true
S.AdminOff=true
S.PSHide=true
S.BotDet=true
S.Humanize=true
S.RateLimit=true
S.RandomAim=true
S.FakeMiss=false
S.KernelLvl=1
S.IdlePattern=true
S.PassiveAntiReport=true
S.HumanCameraSettle=true
S.Coins=false
S.CoinsRad=30
S.Flee=true
S.FleeDist=15
S.RoundAnal=true
S.SpecDet=false
S.KillerTrack=true
S.KillChain=false
S.AutoSheriff=false
S.BackstabWarn=false
S.RoundTimer=true
S.DeathRecap=true
S.StreakRwd=true
S.AutoSheriffPick=true
S.MurderTracker=true
S.BotMode=false
S.BotModeTimeout=120
S.KillCamReplay=true
S.DeathRecapVisual=true
S.DeadmanHeartbeat=true
S.Confidence=true
S.Ensemble=true
S.JukeDet=true
S.WeaponSpeed=true
S.Backtrack=true
S.JumpPredict=true
S.Markov=true
S.ChaseWeight=true
S.AdaptiveOff=true
S.OutlierRej=true
S.NNReal=true
S.NNRate=0.01
S.WeaponAutoTune=true
S.SmartTarget=true
S.HysteresisMs=500
S.Timeline=false
S.Anomaly=true
S.AutoShot=false
S.ReplayExp=false
S.HeatmapView=false
S.KDChart=true
S.PlayerProf=true
S.PlayerPersist=true
S.RoundPhaseAdapt=true
S.ThreatLivePanel=true
S.Haptic=true
S.KillExp=true
S.Shake="Médio"
S.Trail=true
S.Blood=false
S.Chromatic=false
S.CrossDynamic=false
S.ToastIcons=true
S.Deadman=true
S.FallbackSilent=true
S.AdaptiveTiming=true
S.AutoRecon=true
S.SelfDiag=true
S.ErrGuard=true
S.AutoRestart=true
S.CameraRecover=true
S.NetworkLossGuard=true
S.ConfigBackup=true
S.BezierMouse=true
S.HitSoundVerify=true
S.Train=false
S.ReplaySlow=false
S.Dummy=false
S.FlickScore=true
S.PredVis=false
S.AutoGame=true
S.ProfileGame=true
S.ExtraRoles=false
S.ModeDetect=true
S.CrossKeys=false
S.FavoritePins={}
S.CompactHUD=false
S.ProfileManager=true
S.PanicBtn=true
S.ChatCommands=true
S.ConfirmationReset=true
S.Kills=0
S.Deaths=0
S.Hits=0
S.Misses=0
S.BestStreak=0
S.Streak=0
S.SessionStart=tick()
S._notif={}
S._pingJit=0
S.FPSAdaptive=true
S.FPSAdaptiveMinFPS=45
S.PreAim=true
S.PreAimDist=80
S.StickyAim=true
S.StickyAimMs=200
S.StickyAimStrength=0.30
S.ProgressiveFlick=true
S.MicroCorrectMs=30
S.WeaponCooldownCheck=true
S.KMeansEnable=true
S.KMeansClusters=3
S.HitSoundSync=true
S.RecoilComp=true
S.RecoilCompVal=0.15
S.HitscanOpt=true
S.ThreatTrajectory=true
S.ThreatTrajectoryWindow=0.5
S.AntiFlickBlock=true
S.AntiFlickBackoff=2
S.PostKillDelay=true
S.PostKillDelayMs=400
S.ReplayLearning=true
S.BouncePredict=true
S.FlickCurveMode="SCurve"
S.TargetSwitchDelay=true
S.TargetSwitchDelayMs=500
S.AimHumanization=true
S.AimHumanizationPct=0.15
S.AimNoiseAmp=0.5
S.AimNoiseFreq=8
S.SmartWeaponSelect=true
S.WeaponAutoSwap=true
S.REV_AI={meta=true,nas=true,cloning=true,selfPlay=true,worldModel=true,activeInf=true,transformer=true,moe=true,uncert=true,causal=true,counterfact=true,adversarial=true,transfer=true,federated=true,lifelong=true,metaLR=0.01,nasEpochs=20,selfPlayEpochs=100,worldModelSteps=5,infDepth=3,attnHeads=4,moeExperts=5,uncertThreshold=0.7,causalWindow=60,counterfactN=20,adversarialInterval=300,transferGames=3,federatedPeers=10,lifelongMemoryMB=50}
S.REV_HUMAN={persona="calculista",personaStrength=0.7,warmup=true,warmupMin=2,cooldown=true,cooldownMin=2,emotion=true,emotionSens=0.5,cognitive=true,cogMultiMax=4,fatigue=true,fatiguePerHour=0.05,squad=true,squadRadius=30,reputation=true,reputaWindow=600,altDetect=true,altThreshold=0.8}
S.REV_PHYS={ballistic=true,grav=196.2,drag=0.01,bounce=true,maxBounces=2,rayTrace=true,rayCount=100,ik=true,ikBones=8,animMirror=true,animWindow=15,gameStateRecon=true,reconRange=200,serverMirror=true,mirrorErrThresh=0.05,latency2=true,uploadMs=30,jitterBuf=true,jitterWindow=5}
S.REV_SOCIAL={antiAttr=true,misdirect=true,misdirectRate=0.15,mimicry=false,mimicStrength=0.5,bait=true,baitPlayers=3,antiReport=true,antiReportRate=0.10,skillCurve=true,skillCurveHours=2,p2p=false,p2pKey=math.random(100000,999999),zkProof=false,zkChainLen=10}
S.REV_ARCH={multiProc=true,procCount=3,simd=true,simdWidth=8,bytecode=true,bytecodeCache=100,rollback=true,snapshotFrames=30,timeSlice=true,sliceFrames=4,diffSync=true,diffThreshold=0.5,hotSwap=true,aotCompile=true}
S.REV_FEAT={whatIf=true,whatIfIter=1000,forecast=true,forecastSec=10,director=true,directorClips=10,voice=false,voiceLang="pt-BR",wager=true,wagerConf=0.7,blockchain=true,blockchainHash="sha256"}
S.REV_GAME={multiRound=true,multiRoundDepth=5,metaGame=true,metaSample=20,adaptDiff=true,adaptRange=0.3,teamSync=false,teamChannel=1,roleRot=true,roleRotCool=3,legendary=true,legendaryThreshold=20,faction=false,factionTag="HB"}
S.REV_STEALTH={advExamples=true,advEpsilon=0.05,steganog=true,stegChannels=3,jitterDist=true,jitterMean=0.23,jitterStd=0.08,antiAntiCheat=true,aacDelay=30,obfuscate=true,obfuscateLevel=2,adaptiveRate=true,rateWindow=10,plausible=true,plausibleDelay=5}
S.REV_MAD={neuroSym=true,neuroLR=0.005,quantum=true,quantumTemp=100,evolutionary=true,evoPop=20,evoGens=50,swarm=true,swarmN=5,genetic=true,geneLength=100,antColony=true,antN=20,digitalTwin=true,twinFPS=30,sleepWake=true,sleepIdleThreshold=300,curriculum=true,currStage=1,transferReal=false,dreamState=true,dreamNightRate=0.5,recursive=true,recursiveInterval=1000}
Profiles={Default={},Rage={},Legit={},Sniper={},AntiAdmin={},Training={},Bot={}}
Cache={Chars={},Heads={},HRPs={},List={},Set={}}
Hst={}
Ping={samples={},jitter=0,lastBeat=0,fps=60,fpsHist={}}
Sil={enabled=true,restore=0.12,bspd=2500,lastFire=0,fail=0,method="cframe"}
Wat={beats={},log={}}
KillLog={}
Stats={Kills=0,Deaths=0,Hits=0,Misses=0,Best=0}
Acc={shots={}}
Undo={past={},future={},_undolock=false}
Heatmap={pts={}}
HeatDeath={pts={}}
Err={count=0,last=0,disabled=false}
Admin={list={},cache={},hopPending=false}
Round={cur=0,alive=0,start=0,time=0,phase="early"}
KillTrack={killer=nil}
Spect={watching={},specters={}}
Anly={timeline={},angles={},dists={},anomalies={}}
FX={shake=0,shakeDur=0}
Train={history={}}
Game={name="Unknown",mode="Normal"}
PerKeys={}
Weapon={learnedSpeeds={},lastFireTime={}}
PlayerReaction={}
PlayerRatings={}
WinRate={murderer={w=0,l=0},sheriff={w=0,l=0},innocent={w=0,l=0}}
ReplayBuffer={frames={},maxFrames=180}
Dummy={model=nil}
IdleSince=tick()
PredRing={part=nil}
RevAI={metaHistory={},nasArchs={},cloneBuffer={},selfPlayGames={},worldState={},attnCache={},causalGraph={},counterfactResults={},adversarialCycles=0,transferCache={},federatedW={},lifelongMem={},epochs=0}
RevHuman={squads={},reputa={},emotion=0,cogLoad=0,fatigue=0}
RevPhys={reconState={}}
RevSocial={attributionTrail={},misdirectCount=0,p2pMsgs={},zkChain={}}
RevArch={procs={},bytecode={},snapshots={},diffLast={},hotMods={},aotCache={}}
RevFeat={whatIfResults={},forecastCache={},directorBuf={},voiceCache={},wagerCache={},chain={}}
RevGame={roundPlan={},meta={},adaptLevel=1,roleHistory={},legendary={},faction={}}
RevStealth={advNoise={},stegBuf={},jitterSamp={},aac=0,obfMap={},rateBuf={},plausible={}}
RevMad={quantum={},twin={},recursive={gens=0}}
ReplayLearn={templates={},saves=0}
AntiFlickGuard={fails=0,backoffUntil=0}
PostKillTimer={until_=0}
StickyAimData={player=nil,until_=0}
PreAimData={active=false,startTick=0}
FPS={cur=60,samples={},lastT=tick()}
NNReal={inputN=8,hiddenN=6,outputN=3,W1={},b1={},W2={},b2={},lr=0.01,trained=0}
NNLSTM={h={0,0,0,0},c={0,0,0,0},trained=0}
function HB_NNInit()
    NNReal.W1={}
    NNReal.b1={}
    NNReal.W2={}
    NNReal.b2={}
    for i=1,NNReal.hiddenN do
        NNReal.W1[i]={}
        for j=1,NNReal.inputN do
            NNReal.W1[i][j]=(math.random()-0.5)*0.5
        end
        NNReal.b1[i]=0
    end
    for i=1,NNReal.outputN do
        NNReal.W2[i]={}
        for j=1,NNReal.hiddenN do
            NNReal.W2[i][j]=(math.random()-0.5)*0.5
        end
        NNReal.b2[i]=0
    end
end
HB_NNInit()
function HB_NNForward(input)
    local hidden={}
    for i=1,NNReal.hiddenN do
        local s=NNReal.b1[i]
        for j=1,NNReal.inputN do
            s=s+input[j]*NNReal.W1[i][j]
        end
        hidden[i]=math.tanh(s)
    end
    local out={}
    for i=1,NNReal.outputN do
        local s=NNReal.b2[i]
        for j=1,NNReal.hiddenN do
            s=s+hidden[j]*NNReal.W2[i][j]
        end
        out[i]=s
    end
    return out,hidden
end
function HB_NNTrain(input,target)
    local out,hidden=HB_NNForward(input)
    local err={}
    for i=1,NNReal.outputN do
        err[i]=target[i]-out[i]
    end
    local lr=S.NNRate
    for i=1,NNReal.outputN do
        for j=1,NNReal.hiddenN do
            NNReal.W2[i][j]=NNReal.W2[i][j]+lr*err[i]*hidden[j]
        end
        NNReal.b2[i]=NNReal.b2[i]+lr*err[i]
    end
    for j=1,NNReal.hiddenN do
        local dh=0
        for i=1,NNReal.outputN do
            dh=dh+err[i]*NNReal.W2[i][j]
        end
        dh=dh*(1-hidden[j]*hidden[j])
        for k=1,NNReal.inputN do
            NNReal.W1[j][k]=NNReal.W1[j][k]+lr*dh*input[k]
        end
        NNReal.b1[j]=NNReal.b1[j]+lr*dh
    end
    NNReal.trained=NNReal.trained+1
end
function HB_Toast(msg,kind)
    kind=kind or "info"
    if not UI or not UI.Screen or not UI.Screen.Parent then
        return
    end
    if not UI.ToastHolder then
        UI.ToastHolder=HB_Create("Frame",{Size=UDim2.new(0,300,0,500),Position=UDim2.new(1,-320,0,20),BackgroundTransparency=1},UI.Screen)
    end
    local color=Palette.Accent
    if kind=="success" then
        color=Palette.Success
    elseif kind=="warning" then
        color=Palette.Warning
    elseif kind=="danger" then
        color=Palette.Danger
    end
    local t=HB_Create("Frame",{Size=UDim2.new(1,0,0,42),Position=UDim2.new(1,320,0,0),BackgroundColor3=Palette.Surface,BackgroundTransparency=0.05,BorderSizePixel=0},UI.ToastHolder)
    HB_Corner(t,8)
    HB_Stroke(t,color,1.5,0.3)
    HB_Create("Frame",{Size=UDim2.new(0,3,1,-12),Position=UDim2.new(0,6,0,6),BackgroundColor3=color,BorderSizePixel=0},t)
    HB_Create("TextLabel",{Size=UDim2.new(1,-20,1,0),Position=UDim2.new(0,14,0,0),BackgroundTransparency=1,Text=msg,Font=Enum.Font.Gotham,TextSize=12,TextColor3=Palette.TextHigh,TextXAlignment=Enum.TextXAlignment.Left,TextWrapped=true},t)
    local ex={}
    for _,c in ipairs(UI.ToastHolder:GetChildren()) do
        if c:IsA("Frame") and c~=t then
            ex[#ex+1]=c
        end
    end
    for i,ct in ipairs(ex) do
        TweenService:Create(ct,TweenInfo.new(0.2),{Position=UDim2.new(0,0,0,(i-1)*48)}):Play()
    end
    TweenService:Create(t,TweenInfo.new(0.3),{Position=UDim2.new(0,0,0,#ex*48)}):Play()
    task.delay(3,function()
        t:Destroy()
    end)
end
HBToast=HB_Toast
function HB_RebuildList()
    local t={}
    for p in pairs(Cache.Set) do
        t[#t+1]=p
    end
    Cache.List=t
end
function HB_HookChar(p)
    p.CharacterAdded:Connect(function(c)
        Cache.Chars[p]=c
        task.wait(0.25)
        Cache.Heads[p]=c:FindFirstChild("Head")
        Cache.HRPs[p]=c:FindFirstChild("HumanoidRootPart")
    end)
    if p.Character then
        Cache.Chars[p]=p.Character
        Cache.Heads[p]=p.Character:FindFirstChild("Head")
        Cache.HRPs[p]=p.Character:FindFirstChild("HumanoidRootPart")
    end
end
function HB_AddPlayer(p)
    Cache.Set[p]=true
    HB_HookChar(p)
    HB_RebuildList()
end
function HB_RemovePlayer(p)
    Cache.Set[p]=nil
    Cache.Chars[p]=nil
    Cache.Heads[p]=nil
    Cache.HRPs[p]=nil
    Hst[p]=nil
    HB_RebuildList()
end
for _,p in ipairs(Players:GetPlayers()) do
    HB_AddPlayer(p)
end
Players.PlayerAdded:Connect(HB_AddPlayer)
Players.PlayerRemoving:Connect(HB_RemovePlayer)
MURD_NAMES={"Knife","Cleaver","Blade","Sword","Dagger","Machete"}
GUN_NAMES={"Gun","Revolver","Pistol","Sheriff","Firearm","Taser"}
function HB_FindTool(player)
    if player.Character then
        for _,t in ipairs(player.Character:GetChildren()) do
            if t:IsA("Tool") then
                return t.Name
            end
        end
    end
    local bp=player:FindFirstChild("Backpack") or player:FindFirstChildOfClass("Backpack")
    if bp then
        for _,t in ipairs(bp:GetChildren()) do
            if t:IsA("Tool") then
                return t.Name
            end
        end
    end
    return nil
end
function GetRole(p)
    if not p then
        return "Innocent"
    end
    local ch=Cache.Chars[p] or p.Character
    if not ch or not ch.Parent then
        return "Innocent"
    end
    local hum=ch:FindFirstChildOfClass("Humanoid")
    if not hum or hum.Health<=0 then
        return "Innocent"
    end
    for _,attr in ipairs({"Role","role","Team","team","Class","class"}) do
        local ok,val=pcall(function()
            return p:GetAttribute(attr)
        end)
        if ok and val then
            local v=tostring(val):lower()
            if v:find("murder") or v:find("killer") or v:find("assassin") then
                return "Murderer"
            end
            if v:find("sheriff") or v:find("cop") or v:find("deputy") then
                return "Sheriff"
            end
            if v:find("innocent") then
                return "Innocent"
            end
        end
    end
    local tool=HB_FindTool(p)
    if tool then
        local n=tool:lower()
        for _,mn in ipairs(MURD_NAMES) do
            if n:find(mn:lower()) then
                return "Murderer"
            end
        end
        for _,gn in ipairs(GUN_NAMES) do
            if n:find(gn:lower()) then
                return "Sheriff"
            end
        end
    end
    return "Innocent"
end
function HB_GetH(p)
    if not Hst[p] then
        Hst[p]={
            samples={},
            kalman={x={0,0,0,0,0,0},lastT=0,gain=0.35},
            vel=Vector3.zero,
            prevVel=nil,
            acc=Vector3.zero,
            jit=0,
            stab=1,
            lastPos=nil,
            lastT=0,
            dCh=0,
            lastDir=nil,
            markov={},
            lastD2=nil,
            lastD1=nil,
            jumps={},
            lastY=0,
            jumpPred=0,
            chase=false,
            chaseFr=0,
            tpIgn=0,
            weapon="unknown",
            trajectoryScore=0,
            shotsFired=0,
            shotsHit=0,
        }
    end
    return Hst[p]
end
function HB_KalmanPred(k,dt)
    return Vector3.new(k.x[1]+k.x[4]*dt,k.x[2]+k.x[5]*dt,k.x[3]+k.x[6]*dt)
end
function HB_UpdateH(p,pos,hum)
    local h=HB_GetH(p)
    local now=tick()
    if h.lastPos and (pos-h.lastPos).Magnitude>50 and (now-h.lastT)<0.1 then
        h.tpIgn=now
        return
    end
    if now-h.tpIgn<0.5 then
        return
    end
    if h.kalman.lastT==0 then
        h.kalman.lastT=now
    end
    local dt=math.max(now-h.kalman.lastT,1/120)
    h.kalman.lastT=now
    for i,ax in ipairs({"X","Y","Z"}) do
        local m=pos[ax]
        local pr=h.kalman.x[i]+h.kalman.x[i+3]*dt
        local e=m-pr
        h.kalman.x[i]=pr+h.kalman.gain*e
        h.kalman.x[i+3]=h.kalman.x[i+3]+(e/dt)*0.4
    end
    table.insert(h.samples,{pos=pos,t=now})
    if #h.samples>HB_HIST_SZ then
        table.remove(h.samples,1)
    end
    if h.lastPos and h.lastT>0 then
        local dt2=now-h.lastT
        if dt2>0.001 then
            local v=(pos-h.lastPos)/dt2
            h.vel=h.vel:Lerp(v,0.4)
            if h.prevVel then
                h.acc=h.acc:Lerp((h.vel-h.prevVel)/dt2,0.25)
            end
            h.prevVel=h.vel
            if h.vel.Magnitude>1 then
                local dir=h.vel.Unit
                if h.lastDir and dir:Dot(h.lastDir)<0.3 then
                    h.dCh=h.dCh+1
                end
                h.lastDir=dir
            end
            local lpHrp=Cache.HRPs[LP]
            if lpHrp then
                local toMe=lpHrp.Position-pos
                if toMe.Magnitude>0.1 then
                    if h.vel.Unit:Dot(toMe.Unit)>0.7 then
                        h.chaseFr=h.chaseFr+1
                    else
                        h.chaseFr=math.max(0,h.chaseFr-1)
                    end
                    h.chase=h.chaseFr>20
                    h.trajectoryScore=h.vel:Dot(toMe.Unit)/20
                end
            end
            local ch=Cache.Chars[p]
            if ch then
                if ch:FindFirstChild("Knife") then
                    h.weapon="knife"
                elseif ch:FindFirstChild("Gun") then
                    h.weapon="gun"
                end
            end
        end
    end
    h.lastPos=pos
    h.lastT=now
    local n=#h.samples
    if n>=5 then
        local sd=0
        for i=n-4,n do
            if i>1 then
                sd=sd+(h.samples[i].pos-h.samples[i-1].pos).Magnitude
            end
        end
        h.jit=sd/4
        h.stab=math.clamp(1-h.jit*2,0,1)
    end
end
task.spawn(function()
    while task.wait(0.05) do
        local lpHrp=Cache.HRPs[LP]
        if not lpHrp then
            continue
        end
        for _,p in ipairs(Cache.List) do
            if p==LP then
                continue
            end
            local hrp=Cache.HRPs[p]
            local hum=Cache.Chars[p] and Cache.Chars[p]:FindFirstChildOfClass("Humanoid")
            if hrp and (hrp.Position-lpHrp.Position).Magnitude<500 then
                HB_UpdateH(p,hrp.Position,hum)
            end
        end
    end
end)
task.spawn(function()
    local count=0
    RS.RenderStepped:Connect(function()
        count=count+1
        local now=tick()
        if now-FPS.lastT>=0.5 then
            FPS.cur=count/(now-FPS.lastT)
            count=0
            FPS.lastT=now
        end
    end)
end)
function FindWeapon()
    if not LP.Character then
        return nil
    end
    local eq=LP.Character:FindFirstChildOfClass("Tool")
    if eq then
        return eq
    end
    local bp=LP:FindFirstChild("Backpack")
    if bp then
        for _,t in ipairs(bp:GetChildren()) do
            if t:IsA("Tool") then
                return t
            end
        end
    end
    return nil
end
function EquipWeapon(tool)
    if not tool or not LP.Character then
        return false
    end
    if tool.Parent==LP.Character then
        return true
    end
    local h=LP.Character:FindFirstChildOfClass("Humanoid")
    if not h then
        return false
    end
    return pcall(function()
        h:EquipTool(tool)
    end)
end
function GetWeaponSpeed(tool)
    if not S.WeaponSpeed then
        return Sil.bspd
    end
    if not tool then
        return Sil.bspd
    end
    local n=tool.Name:lower()
    if n:find("knife") or n:find("cleaver") then
        return Weapon.learnedSpeeds.knife or 1200
    end
    if n:find("revolver") or n:find("pistol") then
        return Weapon.learnedSpeeds.pistol or 2800
    end
    if n:find("gun") then
        return Weapon.learnedSpeeds.gun or 3000
    end
    return Sil.bspd
end
function IsHitscan(tool)
    if not tool then
        return false
    end
    local n=tool.Name:lower()
    return n:find("knife") or n:find("cleaver") or n:find("sword")
end
function IsWeaponOnCooldown(tool)
    if not S.WeaponCooldownCheck then
        return false
    end
    if not tool then
        return false
    end
    local last=Weapon.lastFireTime[tool]
    if not last then
        return false
    end
    return tick()-last<0.3
end
function SilentFire(tool,aimPos)
    if not tool or not aimPos then
        return false
    end
    if S.RateLimit then
        for i=#RevStealth.rateBuf,1,-1 do
            if tick()-RevStealth.rateBuf[i]>1 then
                table.remove(RevStealth.rateBuf,i)
            end
        end
        if #RevStealth.rateBuf>=15 then
            return false
        end
        table.insert(RevStealth.rateBuf,tick())
    end
    if S.AntiFlickBlock and tick()<AntiFlickGuard.backoffUntil then
        return false
    end
    if tick()-Sil.lastFire<0.2 then
        return false
    end
    Sil.lastFire=tick()
    local k={snapMul=1,restoreMul=1,missChance=0}
    if S.FakeMiss and math.random()<k.missChance then
        aimPos=aimPos+Vector3.new((math.random()-0.5)*2,(math.random()-0.5)*2,(math.random()-0.5)*2)
    end
    local handle=tool:FindFirstChild("Handle")
    local lpCh=LP.Character
    if not handle or not lpCh then
        return false
    end
    local hrp=lpCh:FindFirstChild("HumanoidRootPart")
    local head=lpCh:FindFirstChild("Head")
    if hrp then
        local flat=Vector3.new(aimPos.X,hrp.Position.Y,aimPos.Z)
        if (flat-hrp.Position).Magnitude>0.1 then
            hrp.CFrame=CFrame.lookAt(hrp.Position,flat)
        end
    end
    if head then
        pcall(function()
            head.CFrame=CFrame.lookAt(head.Position,aimPos)
        end)
    end
    handle.CFrame=CFrame.lookAt(handle.Position,aimPos)
    local ok=pcall(function()
        tool:Activate()
    end)
    if ok then
        Weapon.lastFireTime[tool]=tick()
        AntiFlickGuard.fails=0
    else
        AntiFlickGuard.fails=AntiFlickGuard.fails+1
        if S.AntiFlickBlock and AntiFlickGuard.fails>=3 then
            AntiFlickGuard.backoffUntil=tick()+S.AntiFlickBackoff
            AntiFlickGuard.fails=0
        end
    end
    return ok
end
print("[HB] ✅ PARTE 1/5 — "..HB_SERIAL)
MetaLearnUpdate=function(perf)
    if not S.REV_AI.meta then
        return
    end
    local snap=(Flick and Flick.snapDur) or 0.045
    table.insert(RevAI.metaHistory,{perf=perf,snap=snap,t=tick()})
    if #RevAI.metaHistory>100 then
        table.remove(RevAI.metaHistory,1)
    end
    if #RevAI.metaHistory>=20 and Flick then
        local sorted={}
        for _,h in ipairs(RevAI.metaHistory) do
            table.insert(sorted,h)
        end
        table.sort(sorted,function(a,b)
            return a.perf>b.perf
        end)
        local s=0
        for i=1,math.min(5,#sorted) do
            s=s+sorted[i].snap
        end
        Flick.snapDur=Flick.snapDur*0.7+(s/5)*0.3
        RevAI.epochs=RevAI.epochs+1
    end
end
function NASSelect()
    if not S.REV_AI.nas then
        return 1
    end
    if #RevAI.nasArchs==0 then
        for i=1,5 do
            table.insert(RevAI.nasArchs,{layers=math.random(1,3),loss=math.random()})
        end
    end
    local best,bestLoss=1,math.huge
    for i,a in ipairs(RevAI.nasArchs) do
        if a.loss<bestLoss then
            bestLoss=a.loss
            best=i
        end
    end
    return best
end
function BehaviourClone(aimVec,targetVec)
    if not S.REV_AI.cloning then
        return
    end
    table.insert(RevAI.cloneBuffer,{inp=aimVec,out=targetVec,t=tick()})
    if #RevAI.cloneBuffer>500 then
        table.remove(RevAI.cloneBuffer,1)
    end
    if #RevAI.cloneBuffer>=100 and #RevAI.cloneBuffer%10==0 then
        for _=1,5 do
            local s=RevAI.cloneBuffer[math.random(1,#RevAI.cloneBuffer)]
            if s and s.inp and s.out then
                HB_NNTrain({s.inp.X,s.inp.Y,s.inp.Z,s.out.X,s.out.Y,s.out.Z,0.5,0},{s.out.X,s.out.Y,s.out.Z})
            end
        end
    end
end
function SelfPlayTick()
    if not S.REV_AI.selfPlay then
        return
    end
    if #RevAI.selfPlayGames>=S.REV_AI.selfPlayEpochs then
        return
    end
    table.insert(RevAI.selfPlayGames,{epoch=#RevAI.selfPlayGames+1,score=NNReal.trained/100})
    if #RevAI.selfPlayGames%10==0 then
        for _=1,10 do
            HB_NNTrain({0,0,0,0,0,0,0.5,0.2},{math.random()-0.5,math.random()-0.5,math.random()-0.5})
        end
    end
end
function WorldModelPredict(p,dt)
    if not S.REV_AI.worldModel then
        return nil
    end
    local h=Hst[p]
    if not h or #h.samples<5 then
        return nil
    end
    local state=RevAI.worldState[p] or {pos=h.lastPos,vel=h.vel}
    if not state.pos then
        return nil
    end
    return state.pos+state.vel*dt
end
function ActiveInference(p)
    if not S.REV_AI.activeInf then
        return nil
    end
    local h=Hst[p]
    if not h or #h.samples<3 then
        return nil
    end
    local n=math.min(10,#h.samples)
    local mean=Vector3.zero
    for i=#h.samples-n+1,#h.samples do
        if h.samples[i] then
            mean=mean+h.samples[i].pos
        end
    end
    mean=mean/n
    return mean,1
end
function AttentionPredict(h,futureTime)
    if not S.REV_AI.transformer or #h.samples<10 then
        return nil
    end
    local n=math.min(20,#h.samples)
    local start=#h.samples-n+1
    local sumW=0
    local weighted=Vector3.zero
    for i=1,n do
        local idx=start+i-1
        if h.samples[idx] then
            local w=math.exp(-(n-i)/4)
            weighted=weighted+h.samples[idx].pos*w
            sumW=sumW+w
        end
    end
    if sumW==0 then
        return nil
    end
    return weighted/sumW+h.vel*futureTime*0.7
end
function MoEExperts(dist,stab,weapon)
    if not S.REV_AI.moe then
        return 1
    end
    if dist>80 then
        return 1
    end
    if dist<20 and stab<0.3 then
        return 2
    end
    if weapon=="knife" then
        return 3
    end
    if stab>0.7 then
        return 4
    end
    return 5
end
function Uncertainty(h)
    if not S.REV_AI.uncert then
        return 1
    end
    if not h or #h.samples<5 then
        return 0
    end
    local n=math.min(5,#h.samples)
    local mean=Vector3.zero
    for i=#h.samples-n+1,#h.samples do
        if h.samples[i] then
            mean=mean+h.samples[i].pos
        end
    end
    mean=mean/n
    local variance=0
    for i=#h.samples-n+1,#h.samples do
        if h.samples[i] then
            variance=variance+(h.samples[i].pos-mean).Magnitude^2
        end
    end
    variance=variance/n
    return 1/(1+math.sqrt(variance))
end
function CausalAnalyze(action,result)
    if not S.REV_AI.causal then
        return nil
    end
    table.insert(RevAI.causalGraph,{a=action,r=result,t=tick()})
    if #RevAI.causalGraph>500 then
        table.remove(RevAI.causalGraph,1)
    end
end
function CounterfactualSim(tp,camPos)
    if not S.REV_AI.counterfact then
        return nil
    end
    local h=Hst[tp]
    if not h then
        return nil
    end
    return h.lastPos+h.vel*0.03
end
function AdversarialTick()
    if not S.REV_AI.adversarial then
        return
    end
    RevAI.adversarialCycles=RevAI.adversarialCycles+1
    if RevAI.adversarialCycles%30==0 then
        for _=1,5 do
            HB_NNTrain({math.random(),math.random(),math.random(),math.random(),math.random(),math.random(),math.random(),math.random()},{math.random()-0.5,math.random()-0.5,math.random()-0.5})
        end
    end
end
function CrossGameTransfer()
    if not S.REV_AI.transfer then
        return
    end
    RevAI.transferCache[Game.name]=RevAI.transferCache[Game.name] or {}
end
function FederatedAggregate()
    if not S.REV_AI.federated then
        return
    end
    RevAI.federatedW={}
    for _,p in ipairs(Cache.List) do
        RevAI.federatedW[p.Name]={t=tick(),weight=math.random()}
    end
end
function LifelongStore(input,target)
    if not S.REV_AI.lifelong then
        return
    end
    local key=string.format("%.2f_%.2f_%.2f",input[1],input[2],input[3])
    RevAI.lifelongMem[key]={inp=input,out=target,t=tick()}
    local count=0
    for _ in pairs(RevAI.lifelongMem) do
        count=count+1
    end
    if count>(S.REV_AI.lifelongMemoryMB or 50)*100 then
        local oldest,oldestT=nil,math.huge
        for k,v in pairs(RevAI.lifelongMem) do
            if v.t<oldestT then
                oldestT=v.t
                oldest=k
            end
        end
        if oldest then
            RevAI.lifelongMem[oldest]=nil
        end
    end
end
function LifelongRecall(input)
    if not S.REV_AI.lifelong then
        return nil
    end
    return RevAI.lifelongMem[string.format("%.2f_%.2f_%.2f",input[1],input[2],input[3])]
end
PersonaPresets={
    aggressive={snapMul=0.7,holdMul=1.3,smoothMul=0.5,reactMin=0.05,reactMax=0.12},
    cautious={snapMul=1.3,holdMul=0.9,smoothMul=1.8,reactMin=0.12,reactMax=0.22},
    imprevisivel={snapMul=1.2,holdMul=1.0,smoothMul=1.2,reactMin=0.06,reactMax=0.28},
    calculista={snapMul=0.9,holdMul=1.1,smoothMul=1.0,reactMin=0.10,reactMax=0.16},
    casual={snapMul=1.5,holdMul=0.8,smoothMul=2.0,reactMin=0.15,reactMax=0.35},
}
function PersonaApply()
    if not S.REV_HUMAN then
        return
    end
    local p=PersonaPresets[S.REV_HUMAN.persona]
    if not p or not Flick then
        return
    end
    local strength=S.REV_HUMAN.personaStrength or 0.7
    Flick.snapDur=Flick.snapDur*(1-strength)+(0.045*p.snapMul)*strength
    Flick.holdDur=Flick.holdDur*(1-strength)+(0.15*p.holdMul)*strength
    S.AimSmooth=S.AimSmooth*(1-strength)+(0.15*p.smoothMul)*strength
    S.ReactMin=p.reactMin
    S.ReactMax=p.reactMax
end
function WarmupFactor()
    if not S.REV_HUMAN or not S.REV_HUMAN.warmup then
        return 1
    end
    local m=(tick()-S.SessionStart)/60
    if m<S.REV_HUMAN.warmupMin then
        return 0.7+(m/S.REV_HUMAN.warmupMin)*0.3
    end
    return 1
end
function CooldownFactor()
    if not S.REV_HUMAN or not S.REV_HUMAN.cooldown then
        return 1
    end
    local m=(tick()-S.SessionStart)/60
    if m>60 then
        return math.max(0.6,1-(m-60)*0.005)
    end
    return 1
end
function EmotionUpdate()
    if not S.REV_HUMAN or not S.REV_HUMAN.emotion then
        return
    end
    local rk,rd=0,0
    for _,k in ipairs(KillLog) do
        if tick()-k.time<120 then
            if k.miss then
                rd=rd+1
            else
                rk=rk+1
            end
        end
    end
    RevHuman.emotion=RevHuman.emotion*0.7+(rk/math.max(1,rk+rd))*0.3
end
function CognitiveLoad()
    if not S.REV_HUMAN or not S.REV_HUMAN.cognitive then
        return 1
    end
    local visible=0
    for _,p in ipairs(Cache.List) do
        if p~=LP then
            local hrp=Cache.HRPs[p]
            if hrp then
                local sp,on=Camera:WorldToViewportPoint(hrp.Position)
                if on and sp.Z>0 then
                    visible=visible+1
                end
            end
        end
    end
    RevHuman.cogLoad=math.min(1,visible/(S.REV_HUMAN.cogMultiMax or 4))
    return 1-RevHuman.cogLoad*0.15
end
function FatigueFactor()
    if not S.REV_HUMAN or not S.REV_HUMAN.fatigue then
        return 1
    end
    local h=(tick()-S.SessionStart)/3600
    RevHuman.fatigue=math.min(0.5,h*(S.REV_HUMAN.fatiguePerHour or 0.05))
    return 1-RevHuman.fatigue
end
function SquadDetect()
    if not S.REV_HUMAN or not S.REV_HUMAN.squad then
        return
    end
    local r=S.REV_HUMAN.squadRadius or 30
    RevHuman.squads={}
    for _,p1 in ipairs(Cache.List) do
        if p1~=LP then
            local h1=Cache.HRPs[p1]
            if h1 then
                for _,p2 in ipairs(Cache.List) do
                    if p2~=p1 and p2~=LP then
                        local h2=Cache.HRPs[p2]
                        if h2 and (h1.Position-h2.Position).Magnitude<r then
                            RevHuman.squads[p1]=RevHuman.squads[p1] or {}
                            RevHuman.squads[p1][p2]=true
                        end
                    end
                end
            end
        end
    end
end
function ReputationUpdate(p,isKill)
    if not S.REV_HUMAN or not S.REV_HUMAN.reputation then
        return
    end
    RevHuman.reputa[p]=RevHuman.reputa[p] or {kills=0,deaths=0,lastSeen=tick()}
    if isKill then
        RevHuman.reputa[p].kills=RevHuman.reputa[p].kills+1
    else
        RevHuman.reputa[p].deaths=RevHuman.reputa[p].deaths+1
    end
    RevHuman.reputa[p].lastSeen=tick()
end
function AltDetect(p)
    if not S.REV_HUMAN or not S.REV_HUMAN.altDetect then
        return false
    end
    local score=0
    if p.AccountAge and p.AccountAge<30 then
        score=score+0.3
    end
    if #p.Name<6 then
        score=score+0.2
    end
    return score>(S.REV_HUMAN.altThreshold or 0.8)
end
function BallisticSim(origin,targetPos,tool)
    if not S.REV_PHYS or not S.REV_PHYS.ballistic then
        return targetPos
    end
    local n=tool and tool.Name:lower() or ""
    if n:find("knife") then
        return targetPos
    end
    local dist=(targetPos-origin).Magnitude
    local bspd=GetWeaponSpeed(tool)
    local t=dist/bspd
    local dropY=0.5*(S.REV_PHYS.grav or 196.2)*t*t
    return Vector3.new(targetPos.X,targetPos.Y+dropY,targetPos.Z)
end
function RayTracePath(origin,targetPos)
    if not S.REV_PHYS or not S.REV_PHYS.rayTrace then
        return targetPos
    end
    local dir=(targetPos-origin)
    local rc=S.REV_PHYS.rayCount or 100
    for i=1,math.min(5,rc//20) do
        local step=origin+dir*((i-1)/5)
        local ray=Ray.new(step,dir.Unit*2)
        local part=workspace:FindPartOnRay(ray,LP.Character)
        if part then
            return step
        end
    end
    return targetPos
end
function IKPrediction(char,ft)
    if not S.REV_PHYS or not S.REV_PHYS.ik then
        return nil
    end
    local head=char:FindFirstChild("Head")
    local hrp=char:FindFirstChild("HumanoidRootPart")
    if not head or not hrp then
        return nil
    end
    return head.Position+hrp.CFrame.LookVector*ft*20
end
function AnimPredict(char,ft)
    if not S.REV_PHYS or not S.REV_PHYS.animMirror then
        return nil
    end
    local head=char:FindFirstChild("Head")
    if not head then
        return nil
    end
    local hum=char:FindFirstChildOfClass("Humanoid")
    if hum then
        local state=hum:GetState()
        if state==Enum.HumanoidStateType.Jumping or state==Enum.HumanoidStateType.Freefall then
            return head.Position+Vector3.new(0,ft*5,0)
        end
    end
    return head.Position
end
function GameStateRecon()
    if not S.REV_PHYS or not S.REV_PHYS.gameStateRecon then
        return
    end
    RevPhys.reconState={}
    for _,p in ipairs(Cache.List) do
        if p~=LP then
            local hrp=Cache.HRPs[p]
            if hrp then
                RevPhys.reconState[p]=hrp.Position
            end
        end
    end
end
function ServerMirror(tp,pred)
    if not S.REV_PHYS or not S.REV_PHYS.serverMirror then
        return pred
    end
    local ping=LP:GetNetworkPing()
    return pred
end
function LatencyComp()
    if not S.REV_PHYS or not S.REV_PHYS.latency2 then
        return LP:GetNetworkPing()*0.5
    end
    local total=LP:GetNetworkPing()
    local up=(S.REV_PHYS.uploadMs or 30)/1000
    return (total-up*0.5)*0.7+up*0.3
end
function JitterBuffer(p)
    if not S.REV_PHYS or not S.REV_PHYS.jitterBuf then
        return nil
    end
    local h=Hst[p]
    if not h or #h.samples<3 then
        return nil
    end
    return h.samples[math.max(1,#h.samples-3)].pos
end
function AntiAttribution(p)
    if not S.REV_SOCIAL or not S.REV_SOCIAL.antiAttr then
        return
    end
    RevSocial.attributionTrail[p]=RevSocial.attributionTrail[p] or {lastFake=0}
end
function Misdirect()
    if not S.REV_SOCIAL or not S.REV_SOCIAL.misdirect then
        return false
    end
    if math.random()<(S.REV_SOCIAL.misdirectRate or 0.15) then
        RevSocial.misdirectCount=RevSocial.misdirectCount+1
        return true
    end
    return false
end
function MimicryAdjust()
    if not S.REV_SOCIAL or not S.REV_SOCIAL.mimicry then
        return 1
    end
    return 1
end
function BaitDetect()
    if not S.REV_SOCIAL or not S.REV_SOCIAL.bait then
        return false
    end
    return false
end
function AntiReportGesture()
    if not S.REV_SOCIAL or not S.REV_SOCIAL.antiReport then
        return false
    end
    return math.random()<(S.REV_SOCIAL.antiReportRate or 0.10)
end
function SkillCurveFactor()
    if not S.REV_SOCIAL or not S.REV_SOCIAL.skillCurve then
        return 1
    end
    local h=(tick()-S.SessionStart)/3600
    return math.min(1,0.75+(h/(S.REV_SOCIAL.skillCurveHours or 2))*0.25)
end
function P2PEncode(msg)
    if not S.REV_SOCIAL or not S.REV_SOCIAL.p2p then
        return nil
    end
    local k=S.REV_SOCIAL.p2pKey
    local r=""
    for i=1,#msg do
        r=r..string.char((msg:byte(i)+k)%256)
    end
    return r
end
function P2PReceive(msg)
    if not S.REV_SOCIAL or not S.REV_SOCIAL.p2p then
        return
    end
    table.insert(RevSocial.p2pMsgs,{t=tick(),msg=msg})
end
function ZKProofChallenge()
    if not S.REV_SOCIAL or not S.REV_SOCIAL.zkProof then
        return
    end
    RevSocial.zkChain={}
    for i=1,(S.REV_SOCIAL.zkChainLen or 10) do
        table.insert(RevSocial.zkChain,{hash=math.random(100000,999999),t=tick()})
    end
end
function SnapshotState()
    if not S.REV_ARCH or not S.REV_ARCH.rollback then
        return
    end
    table.insert(RevArch.snapshots,{t=tick(),kills=S.Kills,deaths=S.Deaths})
    if #RevArch.snapshots>(S.REV_ARCH.snapshotFrames or 30) then
        table.remove(RevArch.snapshots,1)
    end
end
function DiffSync(key,value)
    if not S.REV_ARCH or not S.REV_ARCH.diffSync then
        return value
    end
    RevArch.diffLast[key]={val=value,t=tick()}
    return value
end
function BytecodeCache(key,fn)
    if not S.REV_ARCH or not S.REV_ARCH.bytecode then
        return fn()
    end
    if RevArch.bytecode[key] then
        return RevArch.bytecode[key]
    end
    local r=fn()
    RevArch.bytecode[key]=r
    return r
end
function HotSwap(name,newVal)
    if not S.REV_ARCH or not S.REV_ARCH.hotSwap then
        return
    end
    RevArch.hotMods[name]={old=RevArch.hotMods[name],new=newVal,t=tick()}
end
function WhatIfSim(aimPos)
    if not S.REV_FEAT or not S.REV_FEAT.whatIf then
        return aimPos
    end
    RevFeat.whatIfResults={}
    for i=1,math.min(50,S.REV_FEAT.whatIfIter or 1000) do
        local variation=aimPos+Vector3.new((math.random()-0.5)*2,(math.random()-0.5)*2,(math.random()-0.5)*2)
        table.insert(RevFeat.whatIfResults,variation)
    end
    return aimPos
end
function ThreatForecast(p,sec)
    if not S.REV_FEAT or not S.REV_FEAT.forecast then
        return nil
    end
    local h=Hst[p]
    if not h or #h.samples<5 then
        return nil
    end
    return h.lastPos+h.vel*sec+0.5*h.acc*sec*sec
end
function DirectorRecord(evt)
    if not S.REV_FEAT or not S.REV_FEAT.director then
        return
    end
    table.insert(RevFeat.directorBuf,{event=evt,t=tick()})
    if #RevFeat.directorBuf>(S.REV_FEAT.directorClips or 10)*10 then
        table.remove(RevFeat.directorBuf,1)
    end
end
function WagerPredict()
    if not S.REV_FEAT or not S.REV_FEAT.wager then
        return nil
    end
    local alive,murdererAlive=0,false
    for _,p in ipairs(Cache.List) do
        local ch=Cache.Chars[p]
        if ch then
            local hum=ch:FindFirstChildOfClass("Humanoid")
            if hum and hum.Health>0 then
                alive=alive+1
                if GetRole(p)=="Murderer" then
                    murdererAlive=true
                end
            end
        end
    end
    return {conf=0.5+(murdererAlive and 0.2 or -0.3),alive=alive}
end
function BlockchainAdd(entry)
    if not S.REV_FEAT or not S.REV_FEAT.blockchain then
        return
    end
    local prev=#RevFeat.chain>0 and RevFeat.chain[#RevFeat.chain].hash or "0"
    local data=prev.."|"..entry.."|"..tick()
    local hash=0
    for i=1,#data do
        hash=(hash*31+data:byte(i))%2147483647
    end
    table.insert(RevFeat.chain,{entry=entry,hash=hash,prev=prev,t=tick()})
    if #RevFeat.chain>500 then
        table.remove(RevFeat.chain,1)
    end
end
function MultiRoundPlan()
    if not S.REV_GAME or not S.REV_GAME.multiRound then
        return
    end
    RevGame.roundPlan={}
    for i=1,(S.REV_GAME.multiRoundDepth or 5) do
        table.insert(RevGame.roundPlan,{round=Round.cur+i})
    end
end
function MetaGameAnalyze()
    if not S.REV_GAME or not S.REV_GAME.metaGame then
        return
    end
    local sampleSize=S.REV_GAME.metaSample or 20
    RevGame.meta.avgSkill=0
    for _,p in ipairs(Cache.List) do
        if p~=LP then
            local rep=RevHuman.reputa[p]
            if rep then
                RevGame.meta.avgSkill=RevGame.meta.avgSkill+(rep.kills or 0)
            end
        end
    end
    if #Cache.List>1 then
        RevGame.meta.avgSkill=RevGame.meta.avgSkill/(#Cache.List-1)
    end
end
function RoleRotation()
    if not S.REV_GAME or not S.REV_GAME.roleRot then
        return
    end
    local myRole=GetRole(LP)
    table.insert(RevGame.roleHistory,{role=myRole,t=tick()})
    if #RevGame.roleHistory>10 then
        table.remove(RevGame.roleHistory,1)
    end
end
function LegendaryCheck()
    if not S.REV_GAME or not S.REV_GAME.legendary then
        return
    end
    if S.Kills>=(S.REV_GAME.legendaryThreshold or 20) and not RevGame.legendary.active then
        RevGame.legendary.active=true
        HB_Toast("LEGENDARY ACHIEVED","success")
    end
end
function AdversarialNoise(aimPos)
    if not S.REV_STEALTH or not S.REV_STEALTH.advExamples then
        return aimPos
    end
    local eps=S.REV_STEALTH.advEpsilon or 0.05
    return aimPos+Vector3.new((math.random()-0.5)*eps,(math.random()-0.5)*eps,(math.random()-0.5)*eps)
end
function JitterMatchDelay()
    if not S.REV_STEALTH or not S.REV_STEALTH.jitterDist then
        return math.random()*0.1
    end
    local mean=S.REV_STEALTH.jitterMean or 0.23
    local std=S.REV_STEALTH.jitterStd or 0.08
    local u1,u2=math.random(),math.random()
    local z=math.sqrt(-2*math.log(u1))*math.cos(2*math.pi*u2)
    return math.max(0.05,mean+z*std)
end
function AntiAntiCheatCheck()
    if not S.REV_STEALTH or not S.REV_STEALTH.antiAntiCheat then
        return true
    end
    if RevStealth.aac>0 and tick()<RevStealth.aac then
        return false
    end
    if Err.count>10 then
        RevStealth.aac=tick()+(S.REV_STEALTH.aacDelay or 30)
        Err.count=0
        return false
    end
    return true
end
function AdaptiveRateCheck()
    if not S.REV_STEALTH or not S.REV_STEALTH.adaptiveRate then
        return true
    end
    for i=#RevStealth.rateBuf,1,-1 do
        if tick()-RevStealth.rateBuf[i]>(S.REV_STEALTH.rateWindow or 10) then
            table.remove(RevStealth.rateBuf,i)
        end
    end
    table.insert(RevStealth.rateBuf,tick())
    return #RevStealth.rateBuf<20
end
function PlausibleDefense()
    if not S.REV_STEALTH or not S.REV_STEALTH.plausible then
        return
    end
    RevStealth.plausible.lastClaim=tick()
end
function SteganographyHide(payload)
    if not S.REV_STEALTH or not S.REV_STEALTH.steganog then
        return payload
    end
    RevStealth.stegBuf={}
    for i=1,#payload do
        table.insert(RevStealth.stegBuf,{char=payload:byte(i),ch=i%(S.REV_STEALTH.stegChannels or 3)})
    end
    return payload
end
function NeuroSymbolic(input)
    if not S.REV_MAD or not S.REV_MAD.neuroSym then
        return nil
    end
    local out=HB_NNForward(input)
    local lr=S.REV_MAD.neuroLR or 0.005
    if type(out)=="table" and out[1] and out[2] then
        return out[1]
    end
    return nil
end
function QuantumAnnealing(cands,costFn)
    if not S.REV_MAD or not S.REV_MAD.quantum then
        return cands[1]
    end
    local temp=S.REV_MAD.quantumTemp or 100
    local cur=cands[math.random(1,#cands)]
    local curC=costFn(cur)
    for _=1,50 do
        temp=temp*0.95
        local nxt=cands[math.random(1,#cands)]
        local nxtC=costFn(nxt)
        if nxtC<curC or math.random()<math.exp((curC-nxtC)/temp) then
            cur=nxt
            curC=nxtC
        end
    end
    return cur
end
function EvolutionStep(pop,fitFn)
    if not S.REV_MAD or not S.REV_MAD.evolutionary then
        return pop
    end
    local pop2={}
    for i=1,(S.REV_MAD.evoPop or 20) do
        local p1=pop[math.random(1,#pop)]
        local p2=pop[math.random(1,#pop)]
        table.insert(pop2,{a=p1.a or 0,b=p2.b or 0})
    end
    return pop2
end
function SwarmStep(nodes,target)
    if not S.REV_MAD or not S.REV_MAD.swarm then
        return nil
    end
    local best,bestD=nil,math.huge
    for _,n in ipairs(nodes) do
        local d=(n-target).Magnitude
        if d<bestD then
            bestD=d
            best=n
        end
    end
    return best
end
function GeneMutate(genes,rate)
    if not S.REV_MAD or not S.REV_MAD.genetic then
        return genes
    end
    for i=1,#genes do
        if math.random()<(rate or 0.1) then
            genes[i]=genes[i]+(math.random()-0.5)*0.1
        end
    end
    return genes
end
function AntColonySolve(points)
    if not S.REV_MAD or not S.REV_MAD.antColony then
        return points
    end
    local best,bestD=nil,math.huge
    for _,pt in ipairs(points) do
        local d=pt.Magnitude or 0
        if d<bestD then
            bestD=d
            best=pt
        end
    end
    return {best}
end
function DigitalTwinUpdate()
    if not S.REV_MAD or not S.REV_MAD.digitalTwin then
        return
    end
    RevMad.twin.players={}
    for _,p in ipairs(Cache.List) do
        if p~=LP then
            local hrp=Cache.HRPs[p]
            if hrp then
                RevMad.twin.players[p]={pos=hrp.Position,vel=hrp.AssemblyLinearVelocity or Vector3.zero}
            end
        end
    end
end
function SleepWakeTick()
    if not S.REV_MAD or not S.REV_MAD.sleepWake then
        return
    end
    if tick()-IdleSince>(S.REV_MAD.sleepIdleThreshold or 300) then
        for _=1,5 do
            HB_NNTrain({math.random(),math.random(),math.random(),math.random(),math.random(),math.random(),math.random(),math.random()},{math.random()-0.5,math.random()-0.5,math.random()-0.5})
        end
    end
end
function CurriculumAdvance()
    if not S.REV_MAD or not S.REV_MAD.curriculum then
        return
    end
    if Acc.rate()>0.7 and NNReal.trained>500 then
        S.REV_MAD.currStage=math.min(5,(S.REV_MAD.currStage or 1)+1)
    end
end
function DreamTrain()
    if not S.REV_MAD or not S.REV_MAD.dreamState then
        return
    end
    if tick()-IdleSince>600 then
        for _=1,10 do
            HB_NNTrain({math.random(),math.random(),math.random(),math.random(),math.random(),math.random(),math.random(),math.random()},{math.random()-0.5,math.random()-0.5,math.random()-0.5})
        end
    end
end
function RecursiveImprove()
    if not S.REV_MAD or not S.REV_MAD.recursive then
        return
    end
    local interval=S.REV_MAD.recursiveInterval or 1000
    if S.Kills>0 and S.Kills%interval==0 then
        NNReal.lr=NNReal.lr*(1+(Acc.rate()-0.5)*0.1)
        RevMad.recursive.gens=(RevMad.recursive.gens or 0)+1
    end
end
Acc.push=function(hit)
    table.insert(Acc.shots,hit and true or false)
    if #Acc.shots>50 then
        table.remove(Acc.shots,1)
    end
end
Acc.rate=function()
    if #Acc.shots==0 then
        return 0
    end
    local h=0
    for _,v in ipairs(Acc.shots) do
        if v then
            h=h+1
        end
    end
    return h/#Acc.shots
end
function LogKill(victim,dist,hs)
    table.insert(KillLog,1,{time=tick(),victim=victim,dist=dist,miss=false,hs=hs})
    if #KillLog>100 then
        table.remove(KillLog)
    end
    Stats.Kills=Stats.Kills+1
    S.Kills=S.Kills+1
    S.Streak=(S.Streak or 0)+1
    if S.Streak>(S.BestStreak or 0) then
        S.BestStreak=S.Streak
    end
end
function LogMiss(victim)
    table.insert(KillLog,1,{time=tick(),victim=victim,dist=0,miss=true})
    if #KillLog>100 then
        table.remove(KillLog)
    end
    S.Streak=0
end
print("[HB] ✅ PARTE 2/5 ok")
function ComputeAim(tp,tch,camPos,tool)
    if not tch or not tch.Parent then
        return nil
    end
    if GetRole(tp)~="Murderer" then
        return nil
    end
    local head=tch:FindFirstChild("Head")
    if not head then
        return nil
    end
    local h=Hst[tp]
    if not h then
        return nil
    end
    local posNow=head.Position
    local dist=(posNow-camPos).Magnitude
    local bspd=GetWeaponSpeed(tool)
    local pingSec=LP:GetNetworkPing()
    local totalTime=dist/bspd+pingSec*0.5+0.010
    if S.HitscanOpt and IsHitscan(tool) then
        return posNow,0.02,dist
    end
    local base=HB_KalmanPred(h.kalman,totalTime)
    if NNReal.trained>50 then
        local nnOut=HB_NNForward({h.vel.X,h.vel.Y,h.vel.Z,h.acc.X,h.acc.Y,h.acc.Z,h.stab,pingSec})
        if nnOut then
            base=base:Lerp(posNow+Vector3.new(nnOut[1],nnOut[2],nnOut[3])*totalTime*10,0.3)
        end
    end
    local wm=WorldModelPredict(tp,totalTime)
    if wm then
        base=base:Lerp(wm,0.25)
    end
    local aiMean=ActiveInference(tp)
    if aiMean then
        base=base:Lerp(aiMean,0.2)
    end
    local attn=AttentionPredict(h,totalTime)
    if attn then
        base=base:Lerp(attn,0.25)
    end
    local expert=MoEExperts(dist,h.stab,h.weapon)
    if expert==1 then
        base=base+h.vel*totalTime*0.3
    elseif expert==2 then
        base=base:Lerp(posNow,0.3)
    elseif expert==3 then
        return posNow,0.01,dist
    elseif expert==4 then
        base=base:Lerp(HB_KalmanPred(h.kalman,totalTime),0.5)
    end
    local cf=CounterfactualSim(tp,camPos)
    if cf then
        base=base:Lerp(cf,0.15)
    end
    local uncert=Uncertainty(h)
    if S.REV_AI.uncert and uncert<S.REV_AI.uncertThreshold and h.stab<0.3 then
        return nil
    end
    local mem=LifelongRecall({h.vel.X,h.vel.Y,h.vel.Z})
    if mem then
        base=base:Lerp(Vector3.new(mem.out[1],mem.out[2],mem.out[3]),0.1)
    end
    local humanMul=WarmupFactor()*CooldownFactor()*CognitiveLoad()*FatigueFactor()*SkillCurveFactor()
    if humanMul<0.95 then
        local blur=(1-humanMul)*2
        base=base+Vector3.new((math.random()-0.5)*blur,(math.random()-0.5)*blur,(math.random()-0.5)*blur)
    end
    base=BallisticSim(camPos,base,tool)
    local ik=IKPrediction(tch,totalTime)
    if ik then
        base=base:Lerp(ik,0.2)
    end
    local ap=AnimPredict(tch,totalTime)
    if ap then
        base=base:Lerp(ap,0.15)
    end
    base=ServerMirror(tp,base)
    local jb=JitterBuffer(tp)
    if jb then
        base=base:Lerp(jb,0.2)
    end
    if BaitDetect() then
        return nil
    end
    if AntiReportGesture() then
        return nil
    end
    base=AdversarialNoise(base)
    if S.PreAim and PreAimData then
        PreAimData.active=true
        PreAimData.startTick=tick()
    end
    return base,totalTime,dist
end
Flick={
    active=false,
    phase="idle",
    startTick=0,
    snapStartTick=0,
    snapDur=0.045,
    holdDur=0.15,
    returnDur=0.10,
    cooldown=0.15,
    verifyWait=0.50,
    targetPlayer=nil,
    targetChar=nil,
    targetHumanoid=nil,
    aimPos=nil,
    originCF=nil,
    originLookAt=nil,
    originalCameraType=nil,
    originalCameraSubject=nil,
    shotsFired=0,
    killed=false,
    hitVerified=false,
    hpBefore=100,
    verifyStart=0,
    retriesLeft=2,
    hitStreak=0,
    missStreak=0,
    lastFlickEnd=0,
    triggeredBy="manual",
    keyHeld=false,
    returnStartTick=0,
    returnStartCF=nil,
    returnTargetCF=nil,
    holdStartTick=0,
    snapPhase=1,
    hitSoundConfirmed=false,
    startedAt=0,
}
function FindMurderQueue()
    local origin=Cache.HRPs[LP] and Cache.HRPs[LP].Position or Camera.CFrame.Position
    local cands={}
    for _,p in ipairs(Cache.List) do
        if p~=LP and GetRole(p)=="Murderer" then
            local ch=Cache.Chars[p]
            local hrp=Cache.HRPs[p]
            if ch and ch.Parent and hrp then
                local hum=ch:FindFirstChildOfClass("Humanoid")
                if hum and hum.Health>0 then
                    local d=(hrp.Position-origin).Magnitude
                    if d<500 then
                        table.insert(cands,{player=p,char=ch,hum=hum,dist=d})
                    end
                end
            end
        end
    end
    table.sort(cands,function(a,b)
        return a.dist<b.dist
    end)
    return cands
end
function StartFlick(target,triggeredBy)
    if not Flick.originalCameraType then
        Flick.originalCameraType=Camera.CameraType
    end
    if not Flick.originalCameraSubject then
        Flick.originalCameraSubject=Camera.CameraSubject
    end
    local scf=Camera.CFrame
    Flick.targetPlayer=target.player
    Flick.targetChar=target.char
    Flick.targetHumanoid=target.hum
    Flick.originCF=scf
    Flick.originLookAt=scf.Position+scf.LookVector*100
    Flick.active=true
    Flick.phase="snap"
    Flick.snapStartTick=tick()
    Flick.startedAt=tick()
    Flick.snapPhase=1
    Flick.shotsFired=0
    Flick.killed=false
    Flick.hitVerified=false
    Flick.hpBefore=target.hum.Health
    Flick.retriesLeft=S.Retries
    Flick.triggeredBy=triggeredBy or "manual"
    Camera.CameraType=Enum.CameraType.Scriptable
    Camera.CameraSubject=nil
    pcall(ReputationUpdate,target.player,false)
end
function EndFlick()
    if not Flick.active then
        return
    end
    Flick.phase="return"
    Flick.returnStartTick=tick()
    Flick.returnStartCF=Camera.CFrame
    Flick.returnTargetCF=Flick.originCF
end
RS:BindToRenderStep(HB_X.."Flick",Enum.RenderPriority.Camera.Value+10,function(dt)
    if not Flick then
        return
    end
    if Flick.phase=="return" and Flick.active then
        local el=tick()-Flick.returnStartTick
        local t=math.clamp(el/Flick.returnDur,0,1)
        local eased=HB_EaseBezier(t,0.4,0.6)
        local pos=Flick.returnStartCF.Position:Lerp(Flick.returnTargetCF.Position,eased)
        local lf=Flick.returnStartCF.Position+Flick.returnStartCF.LookVector*100
        local lt=Flick.returnTargetCF.Position+Flick.returnTargetCF.LookVector*100
        Camera.CameraType=Enum.CameraType.Scriptable
        Camera.CFrame=CFrame.lookAt(pos,lf:Lerp(lt,eased))
        if t>=1 then
            Flick.active=false
            Flick.phase="idle"
            Flick.targetPlayer=nil
            Flick.targetChar=nil
            Flick.targetHumanoid=nil
            Flick.lastFlickEnd=tick()
            if Flick.originalCameraType then
                Camera.CameraType=Flick.originalCameraType
                Camera.CameraSubject=Flick.originalCameraSubject
                Flick.originalCameraType=nil
                Flick.originalCameraSubject=nil
            end
        end
        return
    end
    if not Flick.active then
        return
    end
    if Flick.triggeredBy=="manual" and not (Flick.keyHeld or UIS:IsKeyDown(S.FlickKey)) then
        EndFlick()
        return
    end
    local tp,ch,hum=Flick.targetPlayer,Flick.targetChar,Flick.targetHumanoid
    if not tp or not tp.Parent or not ch or not ch.Parent or not hum or hum.Health<=0 then
        EndFlick()
        return
    end
    if GetRole(tp)~="Murderer" then
        EndFlick()
        return
    end
    local lpHead=Cache.Heads[LP]
    local camPos=lpHead and lpHead.Position or Camera.CFrame.Position
    local eqTool=LP.Character and LP.Character:FindFirstChildOfClass("Tool")
    local aimPos,flightT,dist=ComputeAim(tp,ch,camPos,eqTool)
    if not aimPos then
        local head=ch:FindFirstChild("Head")
        if head then
            aimPos=head.Position
        end
    end
    if not aimPos then
        EndFlick()
        return
    end
    Flick.aimPos=aimPos
    if Flick.phase=="snap" then
        local el=tick()-Flick.snapStartTick
        local snapDur=Flick.snapDur*(FPS.cur<S.FPSAdaptiveMinFPS and (S.FPSAdaptiveMinFPS/math.max(FPS.cur,15)) or 1)
        if el<snapDur then
            local t=math.clamp(el/snapDur,0,1)
            local eased=HB_EaseS(t)
            local look=Flick.originLookAt:Lerp(aimPos,eased)
            Camera.CameraType=Enum.CameraType.Scriptable
            Camera.CFrame=CFrame.lookAt(camPos,look)
        else
            Flick.phase="hold"
            Flick.holdStartTick=tick()
        end
        return
    end
    if Flick.phase=="hold" then
        Camera.CameraType=Enum.CameraType.Scriptable
        Camera.CFrame=CFrame.lookAt(camPos,aimPos)
        if Flick.shotsFired==0 then
            local w=FindWeapon()
            if w then
                local eq=LP.Character:FindFirstChildOfClass("Tool")
                if eq~=w then
                    EquipWeapon(w)
                    task.wait(0.05)
                    eq=LP.Character:FindFirstChildOfClass("Tool")
                end
                if eq and not IsWeaponOnCooldown(eq) then
                    Flick.shotsFired=1
                    Flick.hpBefore=hum.Health
                    local ok=SilentFire(eq,aimPos)
                    if ok then
                        Flick.phase="verify"
                        Flick.verifyStart=tick()
                    end
                end
            end
            return
        end
        if tick()-Flick.holdStartTick>=Flick.holdDur then
            Flick.phase="verify"
            Flick.verifyStart=tick()
        end
        return
    end
    if Flick.phase=="verify" then
        if not hum.Parent or hum.Health<=0 then
            Flick.killed=true
        end
        if hum.Health<Flick.hpBefore then
            Flick.hitVerified=true
        end
        if Flick.hitVerified then
            pcall(ReputationUpdate,tp,true)
            pcall(BlockchainAdd,"KILL:"..tp.Name)
            MetaLearnUpdate(1)
            Flick.hitStreak=Flick.hitStreak+1
            Flick.missStreak=0
            EndFlick()
            return
        end
        if tick()-Flick.verifyStart>=Flick.verifyWait then
            if S.RetryMiss and Flick.retriesLeft>0 then
                Flick.retriesLeft=Flick.retriesLeft-1
                Flick.phase="snap"
                Flick.snapStartTick=tick()
                Flick.shotsFired=0
                Flick.hitVerified=false
                Flick.hpBefore=hum.Health
                Flick.originLookAt=Camera.CFrame.Position+Camera.CFrame.LookVector*100
                return
            end
            MetaLearnUpdate(0)
            Flick.missStreak=Flick.missStreak+1
            EndFlick()
        end
    end
end)
UIS.InputBegan:Connect(function(input,gp)
    if gp then
        return
    end
    if input.UserInputType==Enum.UserInputType.Keyboard then
        if input.KeyCode==S.FlickKey then
            Flick.keyHeld=true
            if not Flick.active then
                if S.PostKillDelay and tick()<PostKillTimer.until_ then
                    return
                end
                if S.AntiFlickBlock and tick()<AntiFlickGuard.backoffUntil then
                    return
                end
                local q=FindMurderQueue()
                if #q>0 then
                    Flick.lastFlickEnd=0
                    StartFlick(q[1],"manual")
                end
            end
        end
        if input.KeyCode==Enum.KeyCode.Insert then
            if UI and UI.Main then
                UI.Main.Visible=not UI.Main.Visible
            end
        end
        if input.KeyCode==Enum.KeyCode.F1 then
            S.AutoFlick=false
            S.TrigOn=false
            S.ESP=false
            HB_Toast("PANIC","danger")
        end
        if input.KeyCode==Enum.KeyCode.F2 then
            if HB_LegacySave then
                HB_LegacySave()
            end
        end
    end
end)
UIS.InputEnded:Connect(function(input)
    if input.UserInputType==Enum.UserInputType.Keyboard and input.KeyCode==S.FlickKey then
        Flick.keyHeld=false
    end
end)
LP.Chatted:Connect(function(msg)
    if not S.ChatCommands then
        return
    end
    local cmd,arg=msg:match("^/hb%s+(%S+)%s*(.*)")
    if not cmd then
        return
    end
    if cmd=="flick" then
        S.AutoFlick=(arg~="off")
    elseif cmd=="esp" then
        S.ESP=(arg~="off")
    elseif cmd=="trigger" then
        S.TrigOn=(arg~="off")
    elseif cmd=="panic" then
        S.AutoFlick=false
        S.TrigOn=false
        S.ESP=false
        HB_Toast("Panic!","danger")
    elseif cmd=="hide" then
        if UI and UI.Main then
            UI.Main.Visible=false
        end
    elseif cmd=="show" then
        if UI and UI.Main then
            UI.Main.Visible=true
        end
    elseif cmd=="save" then
        HB_Toast("Salvo","success")
    elseif cmd=="status" then
        HB_Toast(string.format("K:%d D:%d NN:%d",S.Kills,S.Deaths,NNReal.trained),"info")
    end
end)
task.spawn(function()
    while task.wait(3) do
        pcall(SquadDetect)
        pcall(EmotionUpdate)
        pcall(GameStateRecon)
        pcall(AntiAttribution,LP)
    end
end)
task.spawn(function()
    while task.wait(30) do
        pcall(SnapshotState)
        pcall(AdversarialTick)
        pcall(SelfPlayTick)
        pcall(CrossGameTransfer)
        pcall(FederatedAggregate)
    end
end)
task.spawn(function()
    while task.wait(10) do
        pcall(DigitalTwinUpdate)
        pcall(SleepWakeTick)
        pcall(CurriculumAdvance)
        pcall(DreamTrain)
        pcall(RecursiveImprove)
    end
end)
task.spawn(function()
    while task.wait(5) do
        pcall(MultiRoundPlan)
        pcall(MetaGameAnalyze)
        pcall(RoleRotation)
        pcall(LegendaryCheck)
    end
end)
task.spawn(function()
    while task.wait(1) do
        pcall(AntiAntiCheatCheck)
        pcall(AdaptiveRateCheck)
        pcall(PlausibleDefense)
    end
end)
task.spawn(function()
    while task.wait(1/30) do
        if S.TrigOn then
            local mouse=UIS:GetMouseLocation()
            local best,bestD=nil,S.TrigRad
            for _,p in ipairs(Cache.List) do
                if p~=LP and GetRole(p)=="Murderer" then
                    local head=Cache.Heads[p]
                    if head then
                        local sp,on=Camera:WorldToViewportPoint(head.Position)
                        if on then
                            local d=(Vector2.new(sp.X,sp.Y)-mouse).Magnitude
                            if d<bestD then
                                bestD=d
                                best=p
                            end
                        end
                    end
                end
            end
            if best then
                local w=FindWeapon()
                if w then
                    local head=Cache.Heads[best]
                    if head then
                        local eq=LP.Character and LP.Character:FindFirstChildOfClass("Tool")
                        if eq~=w then
                            EquipWeapon(w)
                            task.wait(0.05)
                            eq=LP.Character:FindFirstChildOfClass("Tool")
                        end
                        if eq and not IsWeaponOnCooldown(eq) then
                            SilentFire(eq,head.Position)
                        end
                    end
                end
            end
        end
    end
end)
task.spawn(function()
    while task.wait(1/30) do
        if S.StickyAim and StickyAimData.player then
            local hrp=Cache.HRPs[StickyAimData.player]
            if hrp and tick()<StickyAimData.until_ then
                local sp,on=Camera:WorldToViewportPoint(hrp.Position)
            else
                StickyAimData.player=nil
            end
        end
    end
end)
print("[HB] ✅ PARTE 3/5 ok")
UI={}
UI.Registered={}
UI.TabButtons={}
UI.TabContents={}
UI_vp=Camera.ViewportSize
UI_baseW,UI_baseH=900,620
UI_scale=math.max(0.5,math.min((UI_vp.X*0.92)/UI_baseW,(UI_vp.Y*0.92)/UI_baseH,1.0))
UI_screen=HB_Create("ScreenGui",{Name=HB_X.."UI",ResetOnSpawn=false,IgnoreGuiInset=true,DisplayOrder=100},PG)
UI.Screen=UI_screen
UI_main=HB_Create("Frame",{Name="Main",Size=UDim2.new(0,UI_baseW,0,UI_baseH),Position=UDim2.new(0.5,0,0.5,0),AnchorPoint=Vector2.new(0.5,0.5),BackgroundColor3=Palette.Surface,BorderSizePixel=0,ClipsDescendants=true,Active=true},UI_screen)
HB_Corner(UI_main,14)
HB_Stroke(UI_main,Palette.Accent,2,0.6)
UI.Main=UI_main
UI_uiScale=HB_Create("UIScale",{Scale=UI_scale},UI_main)
UI_header=HB_Create("Frame",{Name="Header",Size=UDim2.new(1,0,0,70),BackgroundColor3=Color3.fromRGB(24,24,30),BackgroundTransparency=0.15,BorderSizePixel=0,ZIndex=5,Active=true},UI_main)
HB_Corner(UI_header,14)
HB_Create("TextLabel",{Size=UDim2.new(0,400,0,24),Position=UDim2.new(0,20,0,14),BackgroundTransparency=1,Text="HELLBORN ULTIMATE v9.0",Font=Enum.Font.GothamBlack,TextSize=20,TextColor3=Palette.TextHigh,TextXAlignment=Enum.TextXAlignment.Left,ZIndex=7},UI_header)
HB_Create("TextLabel",{Size=UDim2.new(0,400,0,14),Position=UDim2.new(0,20,0,42),BackgroundTransparency=1,Text="46 FEATURES · "..HB_SERIAL,Font=Enum.Font.Code,TextSize=10,TextColor3=Palette.Accent,TextXAlignment=Enum.TextXAlignment.Left,ZIndex=7},UI_header)
UI_avF=HB_Create("Frame",{Size=UDim2.new(0,46,0,46),Position=UDim2.new(1,-260,0.5,-23),BackgroundColor3=Palette.Elevated2,BorderSizePixel=0,ZIndex=7},UI_header)
HB_Corner(UI_avF,23)
HB_Stroke(UI_avF,Palette.Accent,2,0)
HB_Create("ImageLabel",{Size=UDim2.new(1,-4,1,-4),Position=UDim2.new(0,2,0,2),BackgroundTransparency=1,Image="rbxthumb://type=AvatarHeadShot&id="..LP.UserId.."&w=150&h=150",ZIndex=8},UI_avF)
function UI_mkHeaderBtn(txt,xOff,cb,color)
    local b=HB_Create("TextButton",{Size=UDim2.new(0,28,0,28),Position=UDim2.new(1,xOff,0.5,-14),BackgroundColor3=color or Palette.Elevated2,BorderSizePixel=0,Text=txt,Font=Enum.Font.GothamBold,TextSize=14,TextColor3=Palette.TextHigh,AutoButtonColor=false,Active=true,Selectable=false,ZIndex=8},UI_header)
    HB_Corner(b,14)
    HB_Stroke(b,Palette.Border,1,0.4)
    b.Activated:Connect(cb)
    return b
end
UI_closeBtn=UI_mkHeaderBtn("✕",-46,function() UI_main.Visible=false end)
UI_panicBtn=UI_mkHeaderBtn("!",-84,function() S.AutoFlick=false S.TrigOn=false S.ESP=false HB_Toast("PANIC","danger") end,Color3.fromRGB(120,20,20))
UI_zoomOut=UI_mkHeaderBtn("−",-122,function() UI_uiScale.Scale=math.max(0.5,UI_uiScale.Scale-0.1) end)
UI_zoomIn=UI_mkHeaderBtn("+",-158,function() UI_uiScale.Scale=math.min(1.5,UI_uiScale.Scale+0.1) end)
UI_dragBtn=UI_mkHeaderBtn("✥",-194,function() end)
UI_searchWrap=HB_Create("Frame",{Size=UDim2.new(1,-28,0,36),Position=UDim2.new(0,14,0,78),BackgroundColor3=Palette.Elevated,BorderSizePixel=0,ZIndex=4},UI_main)
HB_Corner(UI_searchWrap,10)
HB_Stroke(UI_searchWrap,Palette.Border,1,0.3)
HB_Create("TextLabel",{Size=UDim2.new(0,24,0,36),Position=UDim2.new(0,8,0,0),BackgroundTransparency=1,Text="🔍",Font=Enum.Font.Gotham,TextSize=14,TextColor3=Palette.TextMid},UI_searchWrap)
UI_searchBox=HB_Create("TextBox",{Size=UDim2.new(1,-44,1,0),Position=UDim2.new(0,34,0,0),BackgroundTransparency=1,Text="",PlaceholderText="Buscar feature...",PlaceholderColor3=Palette.TextLow,Font=Enum.Font.Gotham,TextSize=13,TextColor3=Palette.TextHigh,TextXAlignment=Enum.TextXAlignment.Left,ClearTextOnFocus=false},UI_searchWrap)
UI_clearBtn=HB_Create("TextButton",{Size=UDim2.new(0,24,0,36),Position=UDim2.new(1,-28,0,0),BackgroundTransparency=1,Text="✕",Font=Enum.Font.GothamBold,TextSize=12,TextColor3=Palette.TextMid,AutoButtonColor=false,Visible=false},UI_searchWrap)
UI_clearBtn.Activated:Connect(function() UI_searchBox.Text="" UI_clearBtn.Visible=false end)
UI_searchBox:GetPropertyChangedSignal("Text"):Connect(function()
    local q=string.lower(UI_searchBox.Text)
    UI_clearBtn.Visible=q~=""
    for _,d in ipairs(UI.Registered) do
        if d.parent and d.parent.Parent then
            d.parent.Visible=q=="" or d.name:find(q,1,true) or d.keywords:find(q,1,true)
        end
    end
end)
UI_sidebar=HB_Create("Frame",{Size=UDim2.new(0,190,1,-210),Position=UDim2.new(0,14,0,124),BackgroundColor3=Palette.Base,BackgroundTransparency=0.3,BorderSizePixel=0,ZIndex=3},UI_main)
HB_Corner(UI_sidebar,10)
HB_Stroke(UI_sidebar,Palette.Border,1,0.5)
UI_tabScroll=HB_Create("ScrollingFrame",{Size=UDim2.new(1,-12,1,-12),Position=UDim2.new(0,6,0,6),BackgroundTransparency=1,ScrollBarThickness=0,CanvasSize=UDim2.new(0,0,0,0),AutomaticCanvasSize=Enum.AutomaticSize.Y},UI_sidebar)
UI.Content=HB_Create("Frame",{Size=UDim2.new(1,-14*3-190,1,-210),Position=UDim2.new(0,14+190+14,0,124),BackgroundTransparency=1,ZIndex=3},UI_main)
UI_TabsList={
    {icon="🎯",name="Aimbot"},{icon="⚔",name="Flick"},{icon="◉",name="ESP"},
    {icon="✦",name="Visual"},{icon="▤",name="Stats"},{icon="◈",name="IA"},
    {icon="⚡",name="RevIA"},{icon="🧠",name="RevHuman"},{icon="⚙",name="RevPhys"},
    {icon="🎭",name="RevSocial"},{icon="🔧",name="RevArch"},{icon="💫",name="RevFeat"},
    {icon="🎮",name="RevGame"},{icon="🛡",name="RevStealth"},{icon="🌀",name="RevMad"},
    {icon="🔬",name="Innova"},{icon="💎",name="Revolu"},{icon="🎨",name="Config"},
}
for _,t in ipairs(UI_TabsList) do
    local sf=HB_Create("ScrollingFrame",{Name=t.name,Size=UDim2.new(1,0,1,0),BackgroundTransparency=1,ScrollBarThickness=4,ScrollBarImageColor3=Palette.Accent,CanvasSize=UDim2.new(0,0,0,0),AutomaticCanvasSize=Enum.AutomaticSize.Y,Visible=false},UI.Content)
    HB_Create("UIPadding",{PaddingTop=UDim.new(0,6),PaddingRight=UDim.new(0,6),PaddingBottom=UDim.new(0,30),PaddingLeft=UDim.new(0,6)},sf)
    UI.TabContents[t.name]=sf
end
UI.switchTab=function(name)
    for tn,c in pairs(UI.TabContents) do
        c.Visible=(tn==name)
    end
    for _,btn in ipairs(UI.TabButtons) do
        local isOn=btn:GetAttribute("TabName")==name
        TweenService:Create(btn,TweenInfo.new(0.15),{BackgroundTransparency=isOn and 0.2 or 0.7,TextColor3=isOn and Palette.Accent or Palette.TextMid}):Play()
    end
end
for i,tab in ipairs(UI_TabsList) do
    local btn=HB_Create("TextButton",{Size=UDim2.new(1,-4,0,36),Position=UDim2.new(0,4,0,(i-1)*40+4),BackgroundColor3=Palette.Elevated,BackgroundTransparency=0.7,BorderSizePixel=0,Text="  "..tab.icon.."   "..tab.name,Font=Enum.Font.GothamMedium,TextSize=13,TextColor3=Palette.TextMid,TextXAlignment=Enum.TextXAlignment.Left,AutoButtonColor=false,Active=true,Selectable=false},UI_tabScroll)
    HB_Corner(btn,8)
    btn:SetAttribute("TabName",tab.name)
    btn.Activated:Connect(function()
        UI.switchTab(tab.name)
    end)
    UI.TabButtons[#UI.TabButtons+1]=btn
end
Cmp={}
function Cmp_reg(p,n,k)
    table.insert(UI.Registered,{parent=p,name=string.lower(n),keywords=k and string.lower(k) or ""})
end
Cmp.Section=function(parent,text,y)
    local h=34
    local holder=HB_Create("Frame",{Size=UDim2.new(1,0,0,h),Position=UDim2.new(0,0,0,y),BackgroundTransparency=1},parent)
    local bar=HB_Create("Frame",{Size=UDim2.new(0,3,0,14),Position=UDim2.new(0,0,0.5,-7),BackgroundColor3=Palette.Accent,BorderSizePixel=0},holder)
    HB_Corner(bar,2)
    HB_Create("TextLabel",{Size=UDim2.new(1,-12,1,0),Position=UDim2.new(0,12,0,0),BackgroundTransparency=1,Text=text,Font=Enum.Font.GothamBold,TextSize=13,TextColor3=Palette.TextHigh,TextXAlignment=Enum.TextXAlignment.Left},holder)
    return y+h+6
end
Cmp.Toggle=function(parent,opts,y)
    local text=opts.text or "Toggle"
    local desc=opts.desc
    local default=opts.default==true
    local cb=opts.callback
    local h=desc and 56 or 42
    local holder=HB_Create("Frame",{Size=UDim2.new(1,0,0,h),Position=UDim2.new(0,0,0,y),BackgroundColor3=Palette.Elevated,BorderSizePixel=0,Active=true},parent)
    HB_Corner(holder,8)
    HB_Stroke(holder,Palette.Border,1,0.3)
    HB_Create("TextLabel",{Size=UDim2.new(1,-80,0,desc and 18 or h),Position=UDim2.new(0,14,0,desc and 8 or 0),BackgroundTransparency=1,Text=text,Font=Enum.Font.GothamMedium,TextSize=13,TextColor3=Palette.TextHigh,TextXAlignment=Enum.TextXAlignment.Left},holder)
    if desc then
        HB_Create("TextLabel",{Size=UDim2.new(1,-80,0,14),Position=UDim2.new(0,14,0,26),BackgroundTransparency=1,Text=desc,Font=Enum.Font.Gotham,TextSize=10,TextColor3=Palette.TextLow,TextXAlignment=Enum.TextXAlignment.Left},holder)
    end
    local track=HB_Create("Frame",{Size=UDim2.new(0,42,0,22),Position=UDim2.new(1,-56,0.5,-11),BackgroundColor3=default and Palette.Accent or Color3.fromRGB(50,50,58),BorderSizePixel=0},holder)
    HB_Corner(track,11)
    local knob=HB_Create("Frame",{Size=UDim2.new(0,18,0,18),Position=default and UDim2.new(1,-21,0.5,-9) or UDim2.new(0,3,0.5,-9),BackgroundColor3=Color3.fromRGB(250,250,250),BorderSizePixel=0},track)
    HB_Corner(knob,9)
    local on=default
    local hitbox=HB_Create("TextButton",{Size=UDim2.new(1,0,1,0),BackgroundTransparency=1,Text="",AutoButtonColor=false,Active=true,Selectable=false,ZIndex=50},holder)
    hitbox.Activated:Connect(function()
        on=not on
        TweenService:Create(track,TweenInfo.new(0.2),{BackgroundColor3=on and Palette.Accent or Color3.fromRGB(50,50,58)}):Play()
        TweenService:Create(knob,TweenInfo.new(0.35,Enum.EasingStyle.Back),{Position=on and UDim2.new(1,-21,0.5,-9) or UDim2.new(0,3,0.5,-9)}):Play()
        if cb then
            pcall(cb,on)
        end
    end)
    Cmp_reg(holder,text,desc)
    return y+h+8
end
Cmp.Slider=function(parent,opts,y)
    local text=opts.text or "Slider"
    local cb=opts.callback
    local suf=opts.suffix or ""
    local mn,mx=opts.min or 0,opts.max or 100
    local default=opts.default or mn
    local h=50
    local holder=HB_Create("Frame",{Size=UDim2.new(1,0,0,h),Position=UDim2.new(0,0,0,y),BackgroundColor3=Palette.Elevated,BorderSizePixel=0},parent)
    HB_Corner(holder,8)
    HB_Stroke(holder,Palette.Border,1,0.3)
    HB_Create("TextLabel",{Size=UDim2.new(0.5,0,0,20),Position=UDim2.new(0,14,0,6),BackgroundTransparency=1,Text=text,Font=Enum.Font.GothamMedium,TextSize=12,TextColor3=Palette.TextHigh,TextXAlignment=Enum.TextXAlignment.Left},holder)
    local vLbl=HB_Create("TextLabel",{Size=UDim2.new(0,60,0,20),Position=UDim2.new(1,-74,0,6),BackgroundTransparency=1,Text=tostring(default)..suf,Font=Enum.Font.Code,TextSize=12,TextColor3=Palette.Accent,TextXAlignment=Enum.TextXAlignment.Right},holder)
    local bBg=HB_Create("Frame",{Size=UDim2.new(1,-28,0,8),Position=UDim2.new(0,14,0,h-18),BackgroundColor3=Color3.fromRGB(36,36,44),BorderSizePixel=0,Active=true},holder)
    HB_Corner(bBg,4)
    local bFill=HB_Create("Frame",{Size=UDim2.new((default-mn)/(mx-mn),0,1,0),BackgroundColor3=Palette.Accent,BorderSizePixel=0},bBg)
    HB_Corner(bFill,4)
    local knob=HB_Create("Frame",{Size=UDim2.new(0,16,0,16),Position=UDim2.new((default-mn)/(mx-mn),-8,0.5,-8),BackgroundColor3=Color3.fromRGB(250,250,250),BorderSizePixel=0},bBg)
    HB_Corner(knob,8)
    local hit=HB_Create("TextButton",{Size=UDim2.new(1,0,1,0),BackgroundTransparency=1,Text="",AutoButtonColor=false,Active=true,Selectable=false,ZIndex=50},bBg)
    local dragging=false
    local function upd(x)
        local pct=math.clamp((x-bBg.AbsolutePosition.X)/bBg.AbsoluteSize.X,0,1)
        local nv=math.floor(mn+(mx-mn)*pct+0.5)
        bFill.Size=UDim2.new(pct,0,1,0)
        knob.Position=UDim2.new(pct,-8,0.5,-8)
        vLbl.Text=tostring(nv)..suf
        if cb then
            pcall(cb,nv)
        end
    end
    hit.InputBegan:Connect(function(input)
        if input.UserInputType==Enum.UserInputType.MouseButton1 then
            dragging=true
            upd(input.Position.X)
        end
    end)
    UIS.InputEnded:Connect(function(input)
        if input.UserInputType==Enum.UserInputType.MouseButton1 then
            dragging=false
        end
    end)
    UIS.InputChanged:Connect(function(input)
        if dragging and input.UserInputType==Enum.UserInputType.MouseMovement then
            upd(input.Position.X)
        end
    end)
    Cmp_reg(holder,text,nil)
    return y+h+8
end
Cmp.Button=function(parent,opts,y)
    local text=opts.text or "Button"
    local cb=opts.callback
    local danger=opts.danger
    local color=danger and Color3.fromRGB(60,20,22) or Palette.Elevated
    local tc=danger and Palette.Danger or Palette.TextHigh
    local h=42
    local btn=HB_Create("TextButton",{Size=UDim2.new(1,0,0,h),Position=UDim2.new(0,0,0,y),BackgroundColor3=color,BorderSizePixel=0,Text="",AutoButtonColor=false,Active=true,Selectable=false},parent)
    HB_Corner(btn,8)
    HB_Stroke(btn,Palette.Border,1,0.3)
    HB_Create("TextLabel",{Size=UDim2.new(1,-28,1,0),Position=UDim2.new(0,14,0,0),BackgroundTransparency=1,Text=text,Font=Enum.Font.GothamBold,TextSize=13,TextColor3=tc,TextXAlignment=Enum.TextXAlignment.Left},btn)
    btn.Activated:Connect(function()
        if cb then
            pcall(cb)
        end
    end)
    Cmp_reg(btn,text,nil)
    return y+h+8
end
Cmp.Dropdown=function(parent,opts,y)
    local text=opts.text or "Option"
    local options=opts.options or {}
    local default=opts.default or options[1] or "-"
    local cb=opts.callback
    local h=42
    local holder=HB_Create("Frame",{Size=UDim2.new(1,0,0,h),Position=UDim2.new(0,0,0,y),BackgroundColor3=Palette.Elevated,BorderSizePixel=0},parent)
    HB_Corner(holder,8)
    HB_Stroke(holder,Palette.Border,1,0.3)
    HB_Create("TextLabel",{Size=UDim2.new(0.5,-14,1,0),Position=UDim2.new(0,14,0,0),BackgroundTransparency=1,Text=text,Font=Enum.Font.GothamMedium,TextSize=12,TextColor3=Palette.TextHigh,TextXAlignment=Enum.TextXAlignment.Left},holder)
    local idx=1
    for i,o in ipairs(options) do
        if o==default then
            idx=i
            break
        end
    end
    local btn=HB_Create("TextButton",{Size=UDim2.new(0.5,-14,0,28),Position=UDim2.new(0.5,0,0.5,-14),BackgroundColor3=Palette.Elevated2,BorderSizePixel=0,Text=default,Font=Enum.Font.GothamBold,TextSize=11,TextColor3=Palette.Accent,AutoButtonColor=false,Active=true,Selectable=false},holder)
    HB_Corner(btn,6)
    HB_Stroke(btn,Palette.Border,1,0.4)
    btn.Activated:Connect(function()
        idx=idx+1
        if idx>#options then
            idx=1
        end
        btn.Text=options[idx]
        if cb then
            pcall(cb,options[idx])
        end
    end)
    Cmp_reg(holder,text,nil)
    return y+h+8
end
Cmp.Keybind=function(parent,opts,y)
    local text=opts.text or "Keybind"
    local default=opts.default or Enum.KeyCode.Q
    local cb=opts.callback
    local h=42
    local holder=HB_Create("Frame",{Size=UDim2.new(1,0,0,h),Position=UDim2.new(0,0,0,y),BackgroundColor3=Palette.Elevated,BorderSizePixel=0},parent)
    HB_Corner(holder,8)
    HB_Stroke(holder,Palette.Border,1,0.3)
    HB_Create("TextLabel",{Size=UDim2.new(0.5,-14,1,0),Position=UDim2.new(0,14,0,0),BackgroundTransparency=1,Text=text,Font=Enum.Font.GothamMedium,TextSize=12,TextColor3=Palette.TextHigh,TextXAlignment=Enum.TextXAlignment.Left},holder)
    local kb=HB_Create("TextButton",{Size=UDim2.new(0,80,0,28),Position=UDim2.new(1,-94,0.5,-14),BackgroundColor3=Palette.Elevated2,BorderSizePixel=0,Text=default.Name,Font=Enum.Font.Code,TextSize=11,TextColor3=Palette.Accent,AutoButtonColor=false,Active=true,Selectable=false},holder)
    HB_Corner(kb,6)
    HB_Stroke(kb,Palette.Border,1,0.4)
    local listening=false
    kb.Activated:Connect(function()
        listening=true
        kb.Text="..."
        kb.TextColor3=Palette.Warning
    end)
    UIS.InputBegan:Connect(function(input)
        if not listening then
            return
        end
        if input.UserInputType==Enum.UserInputType.Keyboard then
            kb.Text=input.KeyCode.Name
            kb.TextColor3=Palette.Accent
            listening=false
            if cb then
                pcall(cb,input.KeyCode)
            end
        end
    end)
    Cmp_reg(holder,text,nil)
    return y+h+8
end
P=UI.TabContents
p=P["Aimbot"]
y=0
y=Cmp.Section(p,"🎯 AIMBOT",y)
y=Cmp.Toggle(p,{text="Auto Flick",default=S.AutoFlick,callback=function(v) S.AutoFlick=v end},y)
y=Cmp.Keybind(p,{text="Flick Key",default=S.FlickKey,callback=function(kc) S.FlickKey=kc end},y)
y=Cmp.Slider(p,{text="Align Tolerance",min=1,max=15,default=S.AlignTol,suffix="°",callback=function(v) S.AlignTol=v end},y)
y=Cmp.Slider(p,{text="Retries",min=0,max=3,default=S.Retries,callback=function(v) S.Retries=v end},y)
y=Cmp.Section(p,"TRIGGER",y)
y=Cmp.Toggle(p,{text="Trigger Bot",default=S.TrigOn,callback=function(v) S.TrigOn=v end},y)
y=Cmp.Slider(p,{text="Radius",min=10,max=200,default=S.TrigRad,suffix="px",callback=function(v) S.TrigRad=v end},y)
y=Cmp.Section(p,"ANTI-DETECT",y)
y=Cmp.Toggle(p,{text="Rate Limiter",default=S.RateLimit,callback=function(v) S.RateLimit=v end},y)
y=Cmp.Toggle(p,{text="Fake Miss",default=S.FakeMiss,callback=function(v) S.FakeMiss=v end},y)
y=Cmp.Toggle(p,{text="Anti-Flick Block",default=true,callback=function(v) S.AntiFlickBlock=v end},y)
y=Cmp.Toggle(p,{text="Hitscan Opt",default=true,callback=function(v) S.HitscanOpt=v end},y)
y=Cmp.Toggle(p,{text="FPS Adaptive",default=true,callback=function(v) S.FPSAdaptive=v end},y)
p=P["Flick"]
y=0
y=Cmp.Section(p,"⚔ TIMINGS",y)
y=Cmp.Slider(p,{text="Snap (ms)",min=10,max=100,default=45,suffix="ms",callback=function(v) if Flick then Flick.snapDur=v/1000 end end},y)
y=Cmp.Slider(p,{text="Hold (ms)",min=50,max=400,default=150,suffix="ms",callback=function(v) if Flick then Flick.holdDur=v/1000 end end},y)
y=Cmp.Slider(p,{text="Verify (ms)",min=200,max=1000,default=500,suffix="ms",callback=function(v) if Flick then Flick.verifyWait=v/1000 end end},y)
y=Cmp.Slider(p,{text="Return (ms)",min=30,max=300,default=100,suffix="ms",callback=function(v) if Flick then Flick.returnDur=v/1000 end end},y)
y=Cmp.Section(p,"SILENT",y)
y=Cmp.Toggle(p,{text="Silent Aim",default=true,callback=function(v) S.SilentOn=v end},y)
y=Cmp.Toggle(p,{text="Random Aim",default=true,callback=function(v) S.RandomAim=v end},y)
y=Cmp.Section(p,"PERSONA",y)
y=Cmp.Dropdown(p,{text="Persona",options={"aggressive","cautious","imprevisivel","calculista","casual"},default="calculista",callback=function(o) S.REV_HUMAN.persona=o PersonaApply() end},y)
y=Cmp.Slider(p,{text="Strength",min=0,max=100,default=70,suffix="%",callback=function(v) S.REV_HUMAN.personaStrength=v/100 end},y)
p=P["ESP"]
y=0
y=Cmp.Section(p,"ESP",y)
y=Cmp.Toggle(p,{text="ESP Ativado",default=S.ESP,callback=function(v) S.ESP=v end},y)
y=Cmp.Toggle(p,{text="Box + Tracer",default=true,callback=function(v) S.ESPBox=v end},y)
y=Cmp.Slider(p,{text="Espessura",min=1,max=4,default=S.ESPThick,callback=function(v) S.ESPThick=v end},y)
y=Cmp.Section(p,"AVANÇADO",y)
y=Cmp.Toggle(p,{text="Chams (Highlight)",default=false,callback=function(v) S.Chams=v end},y)
y=Cmp.Toggle(p,{text="ESP Arrows",default=false,callback=function(v) S.ESPArrows=v end},y)
y=Cmp.Toggle(p,{text="ESP Skeleton",default=false,callback=function(v) S.ESPSkeleton=v end},y)
y=Cmp.Toggle(p,{text="Radar",default=false,callback=function(v) S.Radar=v end},y)
y=Cmp.Toggle(p,{text="Timeline Predictor",default=false,callback=function(v) S.TimelinePredictor=v end},y)
p=P["Visual"]
y=0
y=Cmp.Section(p,"HUD",y)
y=Cmp.Toggle(p,{text="Hitmarker",default=S.Hitmark,callback=function(v) S.Hitmark=v end},y)
y=Cmp.Toggle(p,{text="Kill Feed",default=S.KillFeed,callback=function(v) S.KillFeed=v end},y)
y=Cmp.Toggle(p,{text="Crosshair",default=S.Cross,callback=function(v) S.Cross=v end},y)
y=Cmp.Section(p,"CROSSHAIR",y)
y=Cmp.Dropdown(p,{text="Estilo",options={"Dot","Cross","Circle","Hybrid"},default="Cross",callback=function(o) S.CrossStyle=o end},y)
y=Cmp.Slider(p,{text="Tamanho",min=4,max=30,default=12,callback=function(v) S.CrossSize=v end},y)
p=P["Stats"]
y=0
y=Cmp.Section(p,"SESSÃO",y)
UI_statsBox=HB_Create("Frame",{Size=UDim2.new(1,0,0,200),Position=UDim2.new(0,0,0,y),BackgroundColor3=Palette.Elevated,BorderSizePixel=0},p)
HB_Corner(UI_statsBox,8)
UI.StatsDisplay=HB_Create("TextLabel",{Size=UDim2.new(1,-20,1,-20),Position=UDim2.new(0,10,0,10),BackgroundTransparency=1,Text="",Font=Enum.Font.Code,TextSize=12,TextColor3=Palette.TextHigh,TextXAlignment=Enum.TextXAlignment.Left,TextYAlignment=Enum.TextYAlignment.Top,TextWrapped=true},UI_statsBox)
y=y+210
y=Cmp.Button(p,{text="Resetar",danger=true,callback=function()
    S.Kills=0
    S.Deaths=0
    S.Hits=0
    S.Misses=0
    S.Streak=0
    S.BestStreak=0
    Acc.shots={}
end},y)
p=P["IA"]
y=0
y=Cmp.Section(p,"IA CORE",y)
y=Cmp.Toggle(p,{text="IA On",default=true,callback=function(v) S.AIOn=v end},y)
y=Cmp.Toggle(p,{text="NN Real",default=true,callback=function(v) S.NNReal=v end},y)
y=Cmp.Slider(p,{text="NN Rate",min=1,max=50,default=10,suffix="‰",callback=function(v) S.NNRate=v/1000 end},y)
p=P["RevIA"]
y=0
y=Cmp.Section(p,"⚡ REV IA",y)
revIAList={{"Meta-Learning","meta"},{"NAS","nas"},{"Behavioural Cloning","cloning"},{"Self-Play","selfPlay"},{"World Model","worldModel"},{"Active Inference","activeInf"},{"Transformer","transformer"},{"MoE","moe"},{"Uncertainty","uncert"},{"Causal","causal"},{"Counterfactual","counterfact"},{"Adversarial","adversarial"},{"Transfer","transfer"},{"Federated","federated"},{"Lifelong","lifelong"}}
for _,it in ipairs(revIAList) do
    y=Cmp.Toggle(p,{text=it[1],default=true,callback=function(v) S.REV_AI[it[2]]=v end},y)
end
p=P["RevHuman"]
y=0
y=Cmp.Section(p,"🧠 HUMANA",y)
y=Cmp.Toggle(p,{text="Warmup",default=true,callback=function(v) S.REV_HUMAN.warmup=v end},y)
y=Cmp.Slider(p,{text="Warmup (min)",min=1,max=10,default=2,callback=function(v) S.REV_HUMAN.warmupMin=v end},y)
y=Cmp.Toggle(p,{text="Cool-down",default=true,callback=function(v) S.REV_HUMAN.cooldown=v end},y)
y=Cmp.Toggle(p,{text="Emotion",default=true,callback=function(v) S.REV_HUMAN.emotion=v end},y)
y=Cmp.Toggle(p,{text="Cognitive",default=true,callback=function(v) S.REV_HUMAN.cognitive=v end},y)
y=Cmp.Toggle(p,{text="Fatigue",default=true,callback=function(v) S.REV_HUMAN.fatigue=v end},y)
y=Cmp.Toggle(p,{text="Squad",default=true,callback=function(v) S.REV_HUMAN.squad=v end},y)
y=Cmp.Toggle(p,{text="Reputation",default=true,callback=function(v) S.REV_HUMAN.reputation=v end},y)
y=Cmp.Toggle(p,{text="Alt Detect",default=true,callback=function(v) S.REV_HUMAN.altDetect=v end},y)
p=P["RevPhys"]
y=0
y=Cmp.Section(p,"⚙ FÍSICA",y)
y=Cmp.Toggle(p,{text="Ballistic",default=true,callback=function(v) S.REV_PHYS.ballistic=v end},y)
y=Cmp.Toggle(p,{text="Ray-Trace",default=true,callback=function(v) S.REV_PHYS.rayTrace=v end},y)
y=Cmp.Toggle(p,{text="IK",default=true,callback=function(v) S.REV_PHYS.ik=v end},y)
y=Cmp.Toggle(p,{text="Anim Mirror",default=true,callback=function(v) S.REV_PHYS.animMirror=v end},y)
y=Cmp.Toggle(p,{text="Recon",default=true,callback=function(v) S.REV_PHYS.gameStateRecon=v end},y)
y=Cmp.Toggle(p,{text="Server Mirror",default=true,callback=function(v) S.REV_PHYS.serverMirror=v end},y)
y=Cmp.Toggle(p,{text="Latency 2.0",default=true,callback=function(v) S.REV_PHYS.latency2=v end},y)
y=Cmp.Toggle(p,{text="Jitter Buffer",default=true,callback=function(v) S.REV_PHYS.jitterBuf=v end},y)
p=P["RevSocial"]
y=0
y=Cmp.Section(p,"🎭 SOCIAL",y)
y=Cmp.Toggle(p,{text="Anti-Attribution",default=true,callback=function(v) S.REV_SOCIAL.antiAttr=v end},y)
y=Cmp.Toggle(p,{text="Misdirect",default=true,callback=function(v) S.REV_SOCIAL.misdirect=v end},y)
y=Cmp.Toggle(p,{text="Bait",default=true,callback=function(v) S.REV_SOCIAL.bait=v end},y)
y=Cmp.Toggle(p,{text="Anti-Report",default=true,callback=function(v) S.REV_SOCIAL.antiReport=v end},y)
y=Cmp.Toggle(p,{text="Skill Curve",default=true,callback=function(v) S.REV_SOCIAL.skillCurve=v end},y)
y=Cmp.Toggle(p,{text="P2P",default=false,callback=function(v) S.REV_SOCIAL.p2p=v end},y)
y=Cmp.Toggle(p,{text="ZK Proof",default=false,callback=function(v) S.REV_SOCIAL.zkProof=v end},y)
p=P["RevArch"]
y=0
y=Cmp.Section(p,"🔧 ARQUITETURA",y)
y=Cmp.Toggle(p,{text="Rollback",default=true,callback=function(v) S.REV_ARCH.rollback=v end},y)
y=Cmp.Toggle(p,{text="Diff Sync",default=true,callback=function(v) S.REV_ARCH.diffSync=v end},y)
y=Cmp.Toggle(p,{text="Bytecode Cache",default=true,callback=function(v) S.REV_ARCH.bytecode=v end},y)
y=Cmp.Toggle(p,{text="Hot-Swap",default=true,callback=function(v) S.REV_ARCH.hotSwap=v end},y)
p=P["RevFeat"]
y=0
y=Cmp.Section(p,"💫 FEATURES",y)
y=Cmp.Toggle(p,{text="What-If",default=true,callback=function(v) S.REV_FEAT.whatIf=v end},y)
y=Cmp.Toggle(p,{text="Forecast",default=true,callback=function(v) S.REV_FEAT.forecast=v end},y)
y=Cmp.Toggle(p,{text="Director",default=true,callback=function(v) S.REV_FEAT.director=v end},y)
y=Cmp.Toggle(p,{text="Wager",default=true,callback=function(v) S.REV_FEAT.wager=v end},y)
y=Cmp.Toggle(p,{text="Blockchain",default=true,callback=function(v) S.REV_FEAT.blockchain=v end},y)
p=P["RevGame"]
y=0
y=Cmp.Section(p,"🎮 GAMEPLAY",y)
y=Cmp.Toggle(p,{text="Multi-Round",default=true,callback=function(v) S.REV_GAME.multiRound=v end},y)
y=Cmp.Toggle(p,{text="Meta-Game",default=true,callback=function(v) S.REV_GAME.metaGame=v end},y)
y=Cmp.Toggle(p,{text="Role Rotation",default=true,callback=function(v) S.REV_GAME.roleRot=v end},y)
y=Cmp.Toggle(p,{text="Legendary",default=true,callback=function(v) S.REV_GAME.legendary=v end},y)
p=P["RevStealth"]
y=0
y=Cmp.Section(p,"🛡 STEALTH",y)
y=Cmp.Toggle(p,{text="Adversarial",default=true,callback=function(v) S.REV_STEALTH.advExamples=v end},y)
y=Cmp.Toggle(p,{text="Jitter Dist",default=true,callback=function(v) S.REV_STEALTH.jitterDist=v end},y)
y=Cmp.Toggle(p,{text="Anti-Anti-Cheat",default=true,callback=function(v) S.REV_STEALTH.antiAntiCheat=v end},y)
y=Cmp.Toggle(p,{text="Adaptive Rate",default=true,callback=function(v) S.REV_STEALTH.adaptiveRate=v end},y)
y=Cmp.Toggle(p,{text="Plausible",default=true,callback=function(v) S.REV_STEALTH.plausible=v end},y)
y=Cmp.Toggle(p,{text="Steganography",default=true,callback=function(v) S.REV_STEALTH.steganog=v end},y)
p=P["RevMad"]
y=0
y=Cmp.Section(p,"🌀 MAD",y)
y=Cmp.Toggle(p,{text="Neuro-Sym",default=true,callback=function(v) S.REV_MAD.neuroSym=v end},y)
y=Cmp.Toggle(p,{text="Quantum",default=true,callback=function(v) S.REV_MAD.quantum=v end},y)
y=Cmp.Toggle(p,{text="Evolutionary",default=true,callback=function(v) S.REV_MAD.evolutionary=v end},y)
y=Cmp.Toggle(p,{text="Swarm",default=true,callback=function(v) S.REV_MAD.swarm=v end},y)
y=Cmp.Toggle(p,{text="Genetic",default=true,callback=function(v) S.REV_MAD.genetic=v end},y)
y=Cmp.Toggle(p,{text="Ant Colony",default=true,callback=function(v) S.REV_MAD.antColony=v end},y)
y=Cmp.Toggle(p,{text="Digital Twin",default=true,callback=function(v) S.REV_MAD.digitalTwin=v end},y)
y=Cmp.Toggle(p,{text="Sleep/Wake",default=true,callback=function(v) S.REV_MAD.sleepWake=v end},y)
y=Cmp.Toggle(p,{text="Curriculum",default=true,callback=function(v) S.REV_MAD.curriculum=v end},y)
y=Cmp.Toggle(p,{text="Dream",default=true,callback=function(v) S.REV_MAD.dreamState=v end},y)
y=Cmp.Toggle(p,{text="Recursive",default=true,callback=function(v) S.REV_MAD.recursive=v end},y)
p=P["Innova"]
y=0
y=Cmp.Section(p,"🔬 INNOVATIONS",y)
y=Cmp.Toggle(p,{text="1. Flick Preview",default=false,callback=function(v) S.FlickPreview=v end},y)
y=Cmp.Toggle(p,{text="2. Flick Trails",default=false,callback=function(v) S.FlickTrails=v end},y)
y=Cmp.Toggle(p,{text="3. Miss Logger",default=false,callback=function(v) S.MissLogger=v end},y)
y=Cmp.Toggle(p,{text="4. Weapon Profiles",default=false,callback=function(v) S.WeaponProfiles=v end},y)
y=Cmp.Toggle(p,{text="5. Flick Heatmap",default=false,callback=function(v) S.FlickHeatmap=v end},y)
y=Cmp.Toggle(p,{text="6. Predictable Flag",default=true,callback=function(v) S.PredictableFlag=v end},y)
y=Cmp.Toggle(p,{text="7. Priority Queue",default=false,callback=function(v) S.PriorityQueue=v end},y)
y=Cmp.Toggle(p,{text="8. Post-Flick Stats",default=true,callback=function(v) S.PostFlickStats=v end},y)
y=Cmp.Toggle(p,{text="9. ESP Skeleton",default=false,callback=function(v) S.ESPSkeleton=v end},y)
y=Cmp.Toggle(p,{text="10. ESP Arrows",default=false,callback=function(v) S.ESPArrows=v end},y)
y=Cmp.Toggle(p,{text="11. Chams",default=false,callback=function(v) S.Chams=v end},y)
y=Cmp.Toggle(p,{text="13. Radar",default=false,callback=function(v) S.Radar=v end},y)
y=Cmp.Toggle(p,{text="14. Muzzle Flash",default=false,callback=function(v) S.MuzzleFlash=v end},y)
y=Cmp.Toggle(p,{text="15. Footstep ESP",default=false,callback=function(v) S.FootstepESP=v end},y)
y=Cmp.Toggle(p,{text="16. Personality",default=true,callback=function(v) S.PersonalityProfiles=v end},y)
y=Cmp.Toggle(p,{text="17. Confidence Bar",default=true,callback=function(v) S.ConfidenceBar=v end},y)
y=Cmp.Toggle(p,{text="18. Adaptive Snap",default=true,callback=function(v) S.AdaptiveSnap=v end},y)
y=Cmp.Toggle(p,{text="19. Weapon Learning",default=false,callback=function(v) S.WeaponLearning=v end},y)
y=Cmp.Toggle(p,{text="20. Anti-Spectate",default=false,callback=function(v) S.AntiSpectate=v end},y)
y=Cmp.Toggle(p,{text="21. Round Faker",default=false,callback=function(v) S.RoundFaker=v end},y)
y=Cmp.Toggle(p,{text="22. Latency Spoofer",default=false,callback=function(v) S.LatencySpoof=v end},y)
y=Cmp.Toggle(p,{text="23. Auto-Reply",default=false,callback=function(v) S.AutoReplyAntiCheat=v end},y)
y=Cmp.Toggle(p,{text="24. Quick Panel",default=false,callback=function(v) S.QuickPanel=v end},y)
y=Cmp.Toggle(p,{text="25. Presets",default=false,callback=function(v) S.PresetsEnabled=v end},y)
y=Cmp.Toggle(p,{text="26. Chat Bot",default=false,callback=function(v) S.ChatBot=v end},y)
y=Cmp.Toggle(p,{text="28. K/D Chart",default=false,callback=function(v) S.KDChart=v end},y)
y=Cmp.Toggle(p,{text="29. Profile Panel",default=false,callback=function(v) S.PlayerProfile=v end},y)
y=Cmp.Toggle(p,{text="30. Threat Panel",default=false,callback=function(v) S.ThreatLivePanel=v end},y)
p=P["Revolu"]
y=0
y=Cmp.Section(p,"💎 REVOLUTIONARIES",y)
y=Cmp.Toggle(p,{text="1. DNA System",default=false,callback=function(v) S.DNASystem=v end},y)
y=Cmp.Toggle(p,{text="2. Timeline Predictor",default=false,callback=function(v) S.TimelinePredictor=v end},y)
y=Cmp.Toggle(p,{text="3. Crowd Intelligence",default=false,callback=function(v) S.CrowdIntelligence=v end},y)
y=Cmp.Toggle(p,{text="4. Behavioral Mirror",default=false,callback=function(v) S.BehavioralMirror=v end},y)
y=Cmp.Toggle(p,{text="5. Dream Simulation",default=false,callback=function(v) S.DreamSimulation=v end},y)
y=Cmp.Toggle(p,{text="6. Live Threat Meter",default=true,callback=function(v) S.LiveThreatMeter=v end},y)
y=Cmp.Toggle(p,{text="7. Reverse Engineering",default=false,callback=function(v) S.ReverseEngineering=v end},y)
y=Cmp.Toggle(p,{text="8. Living Map",default=true,callback=function(v) S.LivingMap=v end},y)
y=Cmp.Toggle(p,{text="9. Squad Mimicry",default=false,callback=function(v) S.SquadMimicry=v end},y)
y=Cmp.Toggle(p,{text="10. A/B Testing",default=true,callback=function(v) S.ABTesting=v end},y)
y=Cmp.Toggle(p,{text="11. Rhythm Flick",default=false,callback=function(v) S.RhythmFlick=v end},y)
y=Cmp.Toggle(p,{text="12. Prediction Market",default=false,callback=function(v) S.PredMarket=v end},y)
y=Cmp.Toggle(p,{text="13. Death Recap 3D",default=true,callback=function(v) S.DeathRecap3D=v end},y)
y=Cmp.Toggle(p,{text="14. Anti-Meta Adapt",default=true,callback=function(v) S.AntiMetaAdapt=v end},y)
y=Cmp.Toggle(p,{text="15. Emotional AI",default=true,callback=function(v) S.EmotionalAI=v end},y)
y=Cmp.Toggle(p,{text="16. Legacy Mode",default=true,callback=function(v) S.LegacyMode=v end},y)
p=P["Config"]
y=0
y=Cmp.Section(p,"🎨 TEMA",y)
themeList={}
for k in pairs(Themes) do
    table.insert(themeList,k)
end
table.sort(themeList)
y=Cmp.Dropdown(p,{text="Cor",options=themeList,default="Red",callback=function(o)
    if Themes[o] then
        Palette.Accent=Themes[o]
        S.Theme=o
    end
end},y)
y=Cmp.Section(p,"SISTEMA",y)
y=Cmp.Toggle(p,{text="Auto Save",default=true,callback=function(v) S.AutoSave=v end},y)
y=Cmp.Toggle(p,{text="Chat Commands",default=true,callback=function(v) S.ChatCommands=v end},y)
y=Cmp.Section(p,"AÇÕES",y)
y=Cmp.Button(p,{text="Exportar Stats",callback=function()
    local d={kills=S.Kills,deaths=S.Deaths,nnTrained=NNReal.trained}
    if setclipboard then
        setclipboard(HttpService:JSONEncode(d))
        HB_Toast("Stats copiadas","success")
    end
end},y)
y=Cmp.Button(p,{text="Reset Layout",danger=true,callback=function()
    UI_main.Position=UDim2.new(0.5,0,0.5,0)
    UI_uiScale.Scale=UI_scale
    HB_Toast("Layout resetado","info")
end},y)
UI_dragState={active=false,start=nil,origin=nil}
UIS.InputBegan:Connect(function(input)
    if input.UserInputType~=Enum.UserInputType.MouseButton1 then
        return
    end
    local hdrHit=HB_PointIn(input.Position,UI_header)
    local dragBtnHit=HB_PointIn(input.Position,UI_dragBtn)
    if dragBtnHit or (hdrHit and not HB_PointIn(input.Position,UI_closeBtn) and not HB_PointIn(input.Position,UI_panicBtn) and not HB_PointIn(input.Position,UI_zoomIn) and not HB_PointIn(input.Position,UI_zoomOut)) then
        UI_dragState.active=true
        UI_dragState.start=input.Position
        UI_dragState.origin=UI_main.Position
    end
end)
UIS.InputChanged:Connect(function(input)
    if not UI_dragState.active then
        return
    end
    if input.UserInputType~=Enum.UserInputType.MouseMovement then
        return
    end
    local d=input.Position-UI_dragState.start
    UI_main.Position=UDim2.new(UI_dragState.origin.X.Scale,UI_dragState.origin.X.Offset+d.X,UI_dragState.origin.Y.Scale,UI_dragState.origin.Y.Offset+d.Y)
end)
UIS.InputEnded:Connect(function(input)
    if input.UserInputType~=Enum.UserInputType.MouseButton1 then
        return
    end
    if UI_dragState.active then
        UI_dragState.active=false
    end
end)
ESP_GUI=HB_Create("ScreenGui",{Name="HB_ESP_Overlay",ResetOnSpawn=false,IgnoreGuiInset=true,DisplayOrder=90},PG)
ESP_HOLDER=HB_Create("Frame",{Size=UDim2.new(1,0,1,0),BackgroundTransparency=1},ESP_GUI)
ESP_COLORS={Murderer=Color3.fromRGB(255,40,40),Sheriff=Color3.fromRGB(50,140,255),Innocent=Color3.fromRGB(50,220,90),Dead=Color3.fromRGB(120,120,120)}
ESP_CACHE={}
function ESP_create()
    local box=HB_Create("Frame",{BackgroundTransparency=1,BorderSizePixel=0,Visible=false,ZIndex=5},ESP_HOLDER)
    local st=HB_Create("UIStroke",{Color=Color3.fromRGB(255,255,255),Thickness=2,Transparency=0},box)
    local tracer=HB_Create("Frame",{BackgroundColor3=Color3.fromRGB(255,255,255),BorderSizePixel=0,Visible=false,ZIndex=4,AnchorPoint=Vector2.new(0.5,0.5)},ESP_HOLDER)
    return {box=box,stroke=st,tracer=tracer}
end
CHAMS_CACHE={}
RADAR_GUI=HB_Create("ScreenGui",{Name="HB_Radar",ResetOnSpawn=false,IgnoreGuiInset=true,DisplayOrder=86},PG)
RADAR_FRAME=HB_Create("Frame",{Size=UDim2.new(0,160,0,160),Position=UDim2.new(0,10,1,-170),BackgroundColor3=Color3.fromRGB(10,10,14),BackgroundTransparency=0.4,BorderSizePixel=0,Visible=false,ZIndex=70},RADAR_GUI)
HB_Corner(RADAR_FRAME,80)
HB_Stroke(RADAR_FRAME,Color3.fromRGB(255,255,255),2,0.5)
RADAR_CENTER=HB_Create("Frame",{Size=UDim2.new(0,8,0,8),Position=UDim2.new(0.5,-4,0.5,-4),BackgroundColor3=Color3.fromRGB(255,255,255),BorderSizePixel=0,ZIndex=72},RADAR_FRAME)
HB_Corner(RADAR_CENTER,4)
TIMELINE_GUI=HB_Create("ScreenGui",{Name="HB_Timeline",ResetOnSpawn=false,IgnoreGuiInset=true,DisplayOrder=87},PG)
TIMELINE_HOLDER=HB_Create("Frame",{Size=UDim2.new(1,0,1,0),BackgroundTransparency=1},TIMELINE_GUI)
HUD_GUI=HB_Create("ScreenGui",{Name="HB_HUD_Overlay",ResetOnSpawn=false,IgnoreGuiInset=true,DisplayOrder=95},PG)
KILLFEED=HB_Create("Frame",{Size=UDim2.new(0,300,0,300),Position=UDim2.new(1,-310,0,100),BackgroundTransparency=1},HUD_GUI)
HITMARKER=HB_Create("Frame",{Size=UDim2.new(0,40,0,40),Position=UDim2.new(0.5,-20,0.5,-20),BackgroundTransparency=1,Visible=false,ZIndex=50},HUD_GUI)
for _,cfg in ipairs({{-8,-8,45},{8,-8,-45},{-8,8,-45},{8,8,45}}) do
    HB_Create("Frame",{Size=UDim2.new(0,10,0,2),Position=UDim2.new(0.5,cfg[1],0.5,cfg[2]),AnchorPoint=Vector2.new(0.5,0.5),BackgroundColor3=Color3.fromRGB(255,255,255),BorderSizePixel=0,Rotation=cfg[3]},HITMARKER)
end
CROSSHAIR=HB_Create("Frame",{Size=UDim2.new(0,40,0,40),Position=UDim2.new(0.5,-20,0.5,-20),BackgroundTransparency=1,Visible=S.Cross,ZIndex=40},HUD_GUI)
for _,cfg in ipairs({{0,-12,2,8},{0,12,2,8},{-12,0,8,2},{12,0,8,2}}) do
    HB_Create("Frame",{Size=UDim2.new(0,cfg[3],0,cfg[4]),Position=UDim2.new(0.5,cfg[1],0.5,cfg[2]),AnchorPoint=Vector2.new(0.5,0.5),BackgroundColor3=Color3.fromRGB(220,40,40),BorderSizePixel=0},CROSSHAIR)
end
CONF_GUI=HB_Create("ScreenGui",{Name="HB_Confidence",ResetOnSpawn=false,IgnoreGuiInset=true,DisplayOrder=87},PG)
CONF_FRAME=HB_Create("Frame",{Size=UDim2.new(0,200,0,30),Position=UDim2.new(0.5,-100,1,-60),BackgroundColor3=Color3.fromRGB(18,18,22),BackgroundTransparency=0.3,BorderSizePixel=0,Visible=false,ZIndex=60},CONF_GUI)
HB_Corner(CONF_FRAME,8)
HB_Stroke(CONF_FRAME,Palette.Accent,1.5,0.3)
CONF_FILL=HB_Create("Frame",{Size=UDim2.new(0,0,1,0),BackgroundColor3=Color3.fromRGB(0,210,120),BorderSizePixel=0,ZIndex=61},CONF_FRAME)
HB_Corner(CONF_FILL,8)
CONF_LABEL=HB_Create("TextLabel",{Size=UDim2.new(1,0,1,0),BackgroundTransparency=1,Text="Confidence 0%",Font=Enum.Font.GothamBold,TextSize=12,TextColor3=Color3.fromRGB(245,245,250),ZIndex=62},CONF_FRAME)
THREAT_GUI=HB_Create("ScreenGui",{Name="HB_ThreatMeter",ResetOnSpawn=false,IgnoreGuiInset=true,DisplayOrder=88},PG)
THREAT_FRAME=HB_Create("Frame",{Size=UDim2.new(0,220,0,34),Position=UDim2.new(1,-240,0,130),BackgroundColor3=Color3.fromRGB(18,18,22),BackgroundTransparency=0.2,BorderSizePixel=0,Visible=false,ZIndex=70},THREAT_GUI)
HB_Corner(THREAT_FRAME,8)
THREAT_FILL=HB_Create("Frame",{Size=UDim2.new(0,0,1,0),BackgroundColor3=Color3.fromRGB(0,210,120),BorderSizePixel=0,ZIndex=71},THREAT_FRAME)
HB_Corner(THREAT_FILL,8)
THREAT_LABEL=HB_Create("TextLabel",{Size=UDim2.new(1,0,1,0),BackgroundTransparency=1,Text="Threat 0%",Font=Enum.Font.GothamBold,TextSize=12,TextColor3=Color3.fromRGB(245,245,250),ZIndex=72},THREAT_FRAME)
QUICK_GUI=HB_Create("ScreenGui",{Name="HB_QuickPanel",ResetOnSpawn=false,IgnoreGuiInset=true,DisplayOrder=89},PG)
QUICK_FRAME=HB_Create("Frame",{Size=UDim2.new(0,180,0,320),Position=UDim2.new(0,10,0.5,-160),BackgroundColor3=Color3.fromRGB(18,18,22),BackgroundTransparency=0.15,BorderSizePixel=0,Visible=false,ZIndex=70},QUICK_GUI)
HB_Corner(QUICK_FRAME,12)
HB_Stroke(QUICK_FRAME,Color3.fromRGB(220,40,40),2,0.3)
HB_Create("TextLabel",{Size=UDim2.new(1,0,0,26),BackgroundTransparency=1,Text="⚡ QUICK TOGGLES",Font=Enum.Font.GothamBold,TextSize=12,TextColor3=Color3.fromRGB(245,245,250),ZIndex=71},QUICK_FRAME)
QUICK_ICONS={{"Auto Flick","AutoFlick"},{"ESP","ESP"},{"Trigger","TrigOn"},{"Crosshair","Cross"},{"Kill Feed","KillFeed"},{"Hitmarker","Hitmark"},{"Radar","Radar"},{"Chams","Chams"}}
for i,it in ipairs(QUICK_ICONS) do
    local btn=HB_Create("TextButton",{Size=UDim2.new(1,-16,0,30),Position=UDim2.new(0,8,0,30+(i-1)*34),BackgroundColor3=S[it[2]] and Color3.fromRGB(40,80,40) or Color3.fromRGB(40,40,46),BorderSizePixel=0,Text=it[1],Font=Enum.Font.GothamMedium,TextSize=11,TextColor3=Color3.fromRGB(245,245,250),AutoButtonColor=false,Active=true,Selectable=false,ZIndex=71},QUICK_FRAME)
    HB_Corner(btn,6)
    btn.Activated:Connect(function()
        S[it[2]]=not S[it[2]]
        btn.BackgroundColor3=S[it[2]] and Color3.fromRGB(40,80,40) or Color3.fromRGB(40,40,46)
    end)
end
HBShowHitmarker=function()
    if not S.Hitmark then
        return
    end
    HITMARKER.Visible=true
    for _,c in ipairs(HITMARKER:GetChildren()) do
        if c:IsA("Frame") then
            c.BackgroundColor3=Color3.fromRGB(255,60,60)
        end
    end
    HITFADE=task.delay(0.15,function()
        HITMARKER.Visible=false
        for _,c in ipairs(HITMARKER:GetChildren()) do
            if c:IsA("Frame") then
                c.BackgroundColor3=Color3.fromRGB(255,255,255)
            end
        end
    end)
end
HBKillFeed=function(victimName,distance)
    if not S.KillFeed then
        return
    end
    local entry=HB_Create("Frame",{Size=UDim2.new(1,0,0,30),Position=UDim2.new(1,0,0,0),BackgroundColor3=Color3.fromRGB(18,18,22),BackgroundTransparency=0.15,BorderSizePixel=0},KILLFEED)
    HB_Corner(entry,6)
    HB_Stroke(entry,Palette.Accent,1,0.3)
    HB_Create("TextLabel",{Size=UDim2.new(1,-20,1,0),Position=UDim2.new(0,10,0,0),BackgroundTransparency=1,Text=string.format("☠ %s [%dm]",victimName,math.floor(distance or 0)),Font=Enum.Font.GothamMedium,TextSize=12,TextColor3=Color3.fromRGB(255,200,200),TextXAlignment=Enum.TextXAlignment.Left},entry)
    task.delay(4,function()
        TweenService:Create(entry,TweenInfo.new(0.5),{BackgroundTransparency=1}):Play()
        task.wait(0.6)
        if entry.Parent then
            entry:Destroy()
        end
    end)
end
RS.RenderStepped:Connect(function()
    local espOn=S.ESP==true
    local vpSize=Camera.ViewportSize
    local thick=S.ESPThick or 2
    for _,player in ipairs(Players:GetPlayers()) do
        if player~=LP then
            local e=ESP_CACHE[player]
            if not e then
                e=ESP_create()
                ESP_CACHE[player]=e
            end
            local char=player.Character
            local head=char and char:FindFirstChild("Head")
            local hrp=char and char:FindFirstChild("HumanoidRootPart")
            local hum=char and char:FindFirstChildOfClass("Humanoid")
            local alive=char and head and hrp and hum and hum.Health>0
            if espOn and alive then
                local role=GetRole(player)
                local color=ESP_COLORS[role] or ESP_COLORS.Innocent
                local headScreen,on1=Camera:WorldToViewportPoint(head.Position+Vector3.new(0,1,0))
                local feetScreen,on2=Camera:WorldToViewportPoint(hrp.Position-Vector3.new(0,2.5,0))
                if on1 and on2 and headScreen.Z>0 and feetScreen.Z>0 then
                    local topY,botY=headScreen.Y,feetScreen.Y
                    local heightPx=math.abs(botY-topY)
                    local widthPx=heightPx*0.55
                    local centerX=headScreen.X
                    e.box.Visible=true
                    e.box.Size=UDim2.new(0,widthPx,0,heightPx)
                    e.box.Position=UDim2.new(0,centerX-widthPx/2,0,topY)
                    e.stroke.Color=color
                    e.stroke.Thickness=thick
                    local originX,originY=vpSize.X/2,vpSize.Y
                    local dx=centerX-originX
                    local dy=(topY+heightPx)-originY
                    local len=math.sqrt(dx*dx+dy*dy)
                    local angle=math.deg(math.atan2(dy,dx))
                    e.tracer.Visible=true
                    e.tracer.Size=UDim2.new(0,len,0,1)
                    e.tracer.Position=UDim2.new(0,originX+dx/2,0,originY+dy/2)
                    e.tracer.Rotation=angle
                    e.tracer.BackgroundColor3=color
                    e.tracer.BackgroundTransparency=0.3
                else
                    e.box.Visible=false
                    e.tracer.Visible=false
                end
            else
                if e then
                    e.box.Visible=false
                    e.tracer.Visible=false
                end
            end
        end
    end
    for player,e in pairs(ESP_CACHE) do
        if not player.Parent then
            if e.box then
                e.box:Destroy()
            end
            if e.tracer then
                e.tracer:Destroy()
            end
            ESP_CACHE[player]=nil
        end
    end
end)
RS.RenderStepped:Connect(function()
    if not S.Chams then
        for _,h in pairs(CHAMS_CACHE) do
            if h and h.Parent then
                h:Destroy()
            end
        end
        CHAMS_CACHE={}
        return
    end
    for _,player in ipairs(Players:GetPlayers()) do
        if player~=LP then
            local h=CHAMS_CACHE[player]
            if not h then
                h=Instance.new("Highlight")
                h.Name="HB_Chams_"..player.Name
                h.FillTransparency=0.5
                h.OutlineTransparency=0.2
                h.DepthMode=Enum.HighlightDepthMode.AlwaysOnTop
                h.Adornee=nil
                h.Parent=PG
                CHAMS_CACHE[player]=h
            end
            local char=player.Character
            local hum=char and char:FindFirstChildOfClass("Humanoid")
            local role=GetRole(player)
            if char and hum and hum.Health>0 then
                local color=ESP_COLORS[role] or ESP_COLORS.Innocent
                h.FillColor=color
                h.OutlineColor=color
                h.Adornee=char
            else
                h.Adornee=nil
            end
        end
    end
end)
RS.RenderStepped:Connect(function()
    if not S.Radar then
        RADAR_FRAME.Visible=false
        return
    end
    RADAR_FRAME.Visible=true
    local myHrp=LP.Character and LP.Character:FindFirstChild("HumanoidRootPart")
    if not myHrp then
        return
    end
    local myPos=myHrp.Position
    local range=150
    for _,c in ipairs(RADAR_FRAME:GetChildren()) do
        if c:IsA("Frame") and c~=RADAR_CENTER then
            c:Destroy()
        end
    end
    for _,player in ipairs(Players:GetPlayers()) do
        if player~=LP then
            local hrp=player.Character and player.Character:FindFirstChild("HumanoidRootPart")
            local hum=player.Character and player.Character:FindFirstChildOfClass("Humanoid")
            if hrp and hum and hum.Health>0 then
                local rel=hrp.Position-myPos
                local dist=math.sqrt(rel.X*rel.X+rel.Z*rel.Z)
                if dist<=range then
                    local nx=rel.X/range
                    local nz=rel.Z/range
                    local role=GetRole(player)
                    local color=ESP_COLORS[role] or ESP_COLORS.Innocent
                    local dot=HB_Create("Frame",{Size=UDim2.new(0,6,0,6),Position=UDim2.new(0.5+nx*0.45,-3,0.5+nz*0.45,-3),BackgroundColor3=color,BorderSizePixel=0,ZIndex=71},RADAR_FRAME)
                    HB_Corner(dot,3)
                end
            end
        end
    end
end)
RS.RenderStepped:Connect(function()
    if not S.TimelinePredictor then
        for _,c in ipairs(TIMELINE_HOLDER:GetChildren()) do
            c:Destroy()
        end
        return
    end
    for _,c in ipairs(TIMELINE_HOLDER:GetChildren()) do
        c:Destroy()
    end
    for _,player in ipairs(Players:GetPlayers()) do
        if player~=LP then
            local h=Hst[player]
            if h and h.lastPos and h.vel then
                local role=GetRole(player)
                local color=ESP_COLORS[role] or ESP_COLORS.Innocent
                for t=1,6 do
                    local futurePos=h.lastPos+h.vel*(t*0.2)
                    local screen,on=Camera:WorldToViewportPoint(futurePos)
                    if on and screen.Z>0 then
                        local dot=HB_Create("Frame",{Size=UDim2.new(0,4,0,4),Position=UDim2.new(0,screen.X-2,0,screen.Y-2),BackgroundColor3=color,BackgroundTransparency=1-(t/6)*0.6,BorderSizePixel=0,ZIndex=55},TIMELINE_HOLDER)
                        HB_Corner(dot,2)
                    end
                end
            end
        end
    end
end)
RS.RenderStepped:Connect(function()
    CROSSHAIR.Visible=S.Cross==true
end)
task.spawn(function()
    while task.wait(0.2) do
        if S.ConfidenceBar and FindMurderQueue then
            local q=FindMurderQueue()
            if #q>0 then
                CONF_FRAME.Visible=true
                local t=q[1]
                local h=Hst[t.player]
                local conf=50
                if h then
                    conf=math.floor((1-h.jit/10)*100)
                    conf=math.clamp(conf,20,99)
                end
                TweenService:Create(CONF_FILL,TweenInfo.new(0.2),{Size=UDim2.new(conf/100,0,1,0)}):Play()
                CONF_FILL.BackgroundColor3=conf>70 and Color3.fromRGB(0,210,120) or (conf>40 and Color3.fromRGB(255,180,0) or Color3.fromRGB(255,60,60))
                CONF_LABEL.Text="Confidence "..conf.."%"
            else
                CONF_FRAME.Visible=false
            end
        else
            CONF_FRAME.Visible=false
        end
    end
end)
task.spawn(function()
    while task.wait(0.5) do
        if S.LiveThreatMeter then
            THREAT_FRAME.Visible=true
            local score=0
            if S.FakeMiss==false then
                score=score+15
            end
            if S.RateLimit==false then
                score=score+15
            end
            if not S.Humanize then
                score=score+20
            end
            if S.ESP then
                score=score+10
            end
            score=math.clamp(score,0,100)
            THREAT_FILL.Size=UDim2.new(score/100,0,1,0)
            THREAT_FILL.BackgroundColor3=score>60 and Color3.fromRGB(255,60,60) or (score>30 and Color3.fromRGB(255,180,0) or Color3.fromRGB(0,210,120))
            THREAT_LABEL.Text=string.format("Threat %d%%",score)
        else
            THREAT_FRAME.Visible=false
        end
    end
end)
task.spawn(function()
    while task.wait(0.3) do
        QUICK_FRAME.Visible=S.QuickPanel==true
    end
end)
HBLoadPreset=function(name)
    local presets={
        RAGE={AutoFlick=true,AlignTol=2,Retries=3,FakeMiss=false,RateLimit=false},
        LEGIT={AutoFlick=true,AlignTol=8,Retries=1,FakeMiss=true,RateLimit=true},
        SNIPER={AutoFlick=true,AlignTol=3,Retries=2},
    }
    local preset=presets[name]
    if not preset then
        return
    end
    for k,v in pairs(preset) do
        S[k]=v
    end
    HB_Toast("Preset: "..name,"success")
end
task.spawn(function()
    while task.wait(0.5) do
        if UI.StatsDisplay and UI.StatsDisplay.Parent then
            local fps=FPS.cur or 60
            local ping=math.floor(LP:GetNetworkPing()*1000)
            UI.StatsDisplay.Text=string.format("📊 SESSÃO\n\nKills: %d\nDeaths: %d\nStreak: %d\nBest: %d\n\nNN trained: %d\nMeta epochs: %d\nFPS: %.0f\nPing: %dms",S.Kills,S.Deaths,S.Streak or 0,S.BestStreak or 0,NNReal.trained,RevAI.epochs,fps,ping)
        end
    end
end)
_prevML=MetaLearnUpdate
MetaLearnUpdate=function(perf)
    _prevML(perf)
    if perf and perf>0.5 then
        local target=Flick and Flick.targetPlayer
        if target then
            local dist=0
            if Cache.HRPs[target] then
                dist=(Cache.HRPs[target].Position-Camera.CFrame.Position).Magnitude
            end
            HBKillFeed(target.Name,dist)
            HBShowHitmarker()
            pcall(BlockchainAdd,"KILL:"..target.Name)
        end
    end
end
HB_LegacySave=function()
    local sess={start=S.SessionStart,end_=tick(),kills=S.Kills,deaths=S.Deaths}
    sess.duration=sess.end_-sess.start
    table.insert(RevGame.roleHistory,sess)
    HB_Toast(string.format("Sessão salva: %dK %dD",sess.kills,sess.deaths),"success")
end
function HBShowAllRoles()
    print("═══ ROLES ═══")
    for _,p in ipairs(Players:GetPlayers()) do
        if p~=LP then
            print(string.format("%s → %s | Tool: %s",p.Name,GetRole(p),HB_FindTool(p) or "nenhuma"))
        end
    end
    print("═══════════════════════════════")
end
UI.switchTab("Aimbot")
UI_main.Visible=true
print("═══════════════════════════════════════════")
print("✅ HELLBORN ULTIMATE v9.0 — CARREGADO!")
print("═══════════════════════════════════════════")
print("📊 46 features · 18 abas · ESP + HUD")
print("🎯 ESP: 🔴 Murderer | 🔵 Sheriff | 🟢 Innocent")
print("⌨️  Insert = menu | Q = Flick | F1 = Panic | F2 = Legacy save")
print("💡 HBShowAllRoles() pra debug")
print("═══════════════════════════════════════════")
HB_WeaponProfiles={}
HB_MissLog={}
HB_FlickHeatmap={}
HB_PredictableTargets={}
HB_KillStats={totalKills=0,bestTime=9999,avgTime=0,times={}}
HB_Personalities={}
HB_WeaponSigs={}
HB_RoundHistory={}
HB_AntiSpectate={active=false}
HB_LatencySpoof={active=false,until_=0}
HB_PersonalityTypes={CAMPER="🏕️ Camper",RUSHER="⚡ Rusher",JUKER="🌀 Juker",STALKER="👁️ Stalker",SNIPER="🎯 Sniper",CHAOTIC="💥 Chaotic"}
HB_FlickPreviewGui=HB_Create("ScreenGui",{Name="HB_FlickPreview",ResetOnSpawn=false,IgnoreGuiInset=true,DisplayOrder=88},PG)
HB_FlickPreviewHolder=HB_Create("Frame",{Size=UDim2.new(1,0,1,0),BackgroundTransparency=1},HB_FlickPreviewGui)
HB_FlickTrailGui=HB_Create("ScreenGui",{Name="HB_FlickTrails",ResetOnSpawn=false,IgnoreGuiInset=true,DisplayOrder=87},PG)
HB_FlickTrailHolder=HB_Create("Frame",{Size=UDim2.new(1,0,1,0),BackgroundTransparency=1},HB_FlickTrailGui)
HB_HeatmapGui=HB_Create("ScreenGui",{Name="HB_FlickHeatmap",ResetOnSpawn=false,IgnoreGuiInset=true,DisplayOrder=85},PG)
HB_HeatmapFrame=HB_Create("Frame",{Size=UDim2.new(0,200,0,200),Position=UDim2.new(1,-220,1,-220),BackgroundColor3=Palette.Surface,BackgroundTransparency=0.3,BorderSizePixel=0,Visible=false,ZIndex=70},HB_HeatmapGui)
HB_Corner(HB_HeatmapFrame,10)
HB_Stroke(HB_HeatmapFrame,Palette.Accent,1.5,0.5)
HB_Create("TextLabel",{Size=UDim2.new(1,0,0,20),BackgroundTransparency=1,Text="🗺️ Flick Heatmap",Font=Enum.Font.GothamBold,TextSize=12,TextColor3=Palette.TextHigh,ZIndex=71},HB_HeatmapFrame)
HB_PriorityGui=HB_Create("ScreenGui",{Name="HB_PriorityQueue",ResetOnSpawn=false,IgnoreGuiInset=true,DisplayOrder=86},PG)
HB_PriorityFrame=HB_Create("Frame",{Size=UDim2.new(0,200,0,80),Position=UDim2.new(0,10,0.5,-40),BackgroundColor3=Palette.Surface,BackgroundTransparency=0.2,BorderSizePixel=0,Visible=false,ZIndex=70},HB_PriorityGui)
HB_Corner(HB_PriorityFrame,10)
HB_Stroke(HB_PriorityFrame,Palette.Danger,2,0.3)
HB_PriorityList=HB_Create("TextLabel",{Size=UDim2.new(1,-20,1,-20),Position=UDim2.new(0,10,0,10),BackgroundTransparency=1,Text="",Font=Enum.Font.Code,TextSize=11,TextColor3=Palette.TextHigh,TextXAlignment=Enum.TextXAlignment.Left,TextYAlignment=Enum.TextYAlignment.Top,TextWrapped=true},HB_PriorityFrame)
HB_ProfileGui=HB_Create("ScreenGui",{Name="HB_PlayerProfile",ResetOnSpawn=false,IgnoreGuiInset=true,DisplayOrder=88},PG)
HB_ProfileFrame=HB_Create("Frame",{Size=UDim2.new(0,240,0,240),Position=UDim2.new(0,10,0,180),BackgroundColor3=Color3.fromRGB(18,18,22),BackgroundTransparency=0.15,BorderSizePixel=0,Visible=false,ZIndex=70},HB_ProfileGui)
HB_Corner(HB_ProfileFrame,10)
HB_Stroke(HB_ProfileFrame,Color3.fromRGB(220,40,40),1.5,0.4)
HB_Create("TextLabel",{Size=UDim2.new(1,0,0,24),BackgroundTransparency=1,Text="👤 Player Profiles",Font=Enum.Font.GothamBold,TextSize=12,TextColor3=Palette.TextHigh,ZIndex=71},HB_ProfileFrame)
HB_ProfileList=HB_Create("TextLabel",{Size=UDim2.new(1,-16,1,-32),Position=UDim2.new(0,8,0,28),BackgroundTransparency=1,Text="",Font=Enum.Font.Code,TextSize=10,TextColor3=Palette.TextHigh,TextXAlignment=Enum.TextXAlignment.Left,TextYAlignment=Enum.TextYAlignment.Top,TextWrapped=true,ZIndex=71},HB_ProfileFrame)
HB_ThreatPanelGui=HB_Create("ScreenGui",{Name="HB_ThreatPanel",ResetOnSpawn=false,IgnoreGuiInset=true,DisplayOrder=89},PG)
HB_ThreatPanelFrame=HB_Create("Frame",{Size=UDim2.new(0,220,0,30),Position=UDim2.new(0.5,-110,0,60),BackgroundColor3=Color3.fromRGB(18,18,22),BackgroundTransparency=0.2,BorderSizePixel=0,Visible=false,ZIndex=70},HB_ThreatPanelGui)
HB_Corner(HB_ThreatPanelFrame,8)
HB_Stroke(HB_ThreatPanelFrame,Color3.fromRGB(220,40,40),1.5,0.3)
HB_ThreatPanelLabel=HB_Create("TextLabel",{Size=UDim2.new(1,0,1,0),BackgroundTransparency=1,Text="THREAT: LOW",Font=Enum.Font.GothamBold,TextSize=13,TextColor3=Color3.fromRGB(0,210,120),ZIndex=71},HB_ThreatPanelFrame)
HB_KDGui=HB_Create("ScreenGui",{Name="HB_KDChart",ResetOnSpawn=false,IgnoreGuiInset=true,DisplayOrder=86},PG)
HB_KDFrame=HB_Create("Frame",{Size=UDim2.new(0,260,0,140),Position=UDim2.new(1,-280,0,180),BackgroundColor3=Color3.fromRGB(18,18,22),BackgroundTransparency=0.2,BorderSizePixel=0,Visible=false,ZIndex=70},HB_KDGui)
HB_Corner(HB_KDFrame,10)
HB_Stroke(HB_KDFrame,Color3.fromRGB(220,40,40),1.5,0.4)
HB_Create("TextLabel",{Size=UDim2.new(1,0,0,22),BackgroundTransparency=1,Text="📊 K/D por Round",Font=Enum.Font.GothamBold,TextSize=11,TextColor3=Palette.TextHigh,ZIndex=71},HB_KDFrame)
HB_KDBars=HB_Create("Frame",{Size=UDim2.new(1,-16,1,-32),Position=UDim2.new(0,8,0,26),BackgroundTransparency=1,ZIndex=71},HB_KDFrame)
HB_MuzzleGui=HB_Create("ScreenGui",{Name="HB_MuzzleFlash",ResetOnSpawn=false,IgnoreGuiInset=true,DisplayOrder=93},PG)
HB_MuzzleHolder=HB_Create("Frame",{Size=UDim2.new(1,0,1,0),BackgroundTransparency=1},HB_MuzzleGui)
HB_FootstepGui=HB_Create("ScreenGui",{Name="HB_FootstepESP",ResetOnSpawn=false,IgnoreGuiInset=true,DisplayOrder=87},PG)
HB_FootstepHolder=HB_Create("Frame",{Size=UDim2.new(1,0,1,0),BackgroundTransparency=1},HB_FootstepGui)
HB_ArrowGui=HB_Create("ScreenGui",{Name="HB_ESPArrows",ResetOnSpawn=false,IgnoreGuiInset=true,DisplayOrder=88},PG)
HB_ArrowHolder=HB_Create("Frame",{Size=UDim2.new(1,0,1,0),BackgroundTransparency=1},HB_ArrowGui)
HB_SkeletonGui=HB_Create("ScreenGui",{Name="HB_ESPSkeleton",ResetOnSpawn=false,IgnoreGuiInset=true,DisplayOrder=89},PG)
HB_SkeletonHolder=HB_Create("Frame",{Size=UDim2.new(1,0,1,0),BackgroundTransparency=1},HB_SkeletonGui)
HB_SkelCache={}
HB_ArrowCache={}
HB_DNA={snapBase=0.045,angleBias=0,aggressionLevel=0.5,preferredDist=30,signature=nil,samples=0}
HB_CrowdNet={}
HB_Mirror={target=nil,style={},lastUpdate=0}
HB_DreamState={active=false,iterations=0,lastTrain=0}
HB_ReverseEng={recording=false,buffer={},learned={}}
HB_LivingMap={grid={},samples=0}
HB_SquadMimicry={squad={},style={}}
HB_ABTest={strategyA={snap=0.045,hitRate=0.5,samples=0},strategyB={snap=0.060,hitRate=0.5,samples=0},useA=true}
HB_Rhythm={phase=0,rate=2.0,amplitude=0.15}
HB_PredMarket={activeBet=nil,wins=0,losses=0,balance=100}
HB_DeathRecap={active=false,data=nil}
HB_AntiMeta={lastPing=0,lastFps=60,lastPlayerCount=0,adaptations=0}
HB_Emotion={state="neutral",samples=0}
HB_Legacy={sessions={},bestKills=0,totalKills=0,totalDeaths=0,totalPlayTime=0,currentSession={start=tick(),kills=0,deaths=0}}
HB_ChatReplies={"kkk puro talento mano","treinei muito pra isso","sorte","confia","👍","mano é só prática"}
HB_Presets={
    RAGE={AutoFlick=true,AlignTol=2,Retries=3,FakeMiss=false,RateLimit=false},
    LEGIT={AutoFlick=true,AlignTol=8,Retries=1,FakeMiss=true,RateLimit=true,Humanize=true},
    SNIPER={AutoFlick=true,AlignTol=3,Retries=2},
    ANTIADMIN={AutoFlick=true,AdminOff=true,PSHide=true,FakeMiss=true,RateLimit=true,Humanize=true},
}
function HB_FlickPreviewShow(fromScreen,toScreen,color)
    if not S.FlickPreview then
        return
    end
    HB_FlickPreviewHolder:ClearAllChildren()
    local dx=toScreen.X-fromScreen.X
    local dy=toScreen.Y-fromScreen.Y
    local len=math.sqrt(dx*dx+dy*dy)
    local angle=math.deg(math.atan2(dy,dx))
    local line=HB_Create("Frame",{Size=UDim2.new(0,len,0,2),Position=UDim2.new(0,fromScreen.X+dx/2,0,fromScreen.Y+dy/2),AnchorPoint=Vector2.new(0.5,0.5),BackgroundColor3=color or Color3.fromRGB(255,200,100),BackgroundTransparency=0.5,BorderSizePixel=0,Rotation=angle,ZIndex=60},HB_FlickPreviewHolder)
    task.delay(0.6,function()
        if line and line.Parent then
            TweenService:Create(line,TweenInfo.new(0.2),{BackgroundTransparency=1}):Play()
            task.wait(0.25)
            line:Destroy()
        end
    end)
end
function HB_FlickTrailAdd(screenPos,color)
    if not S.FlickTrails then
        return
    end
    local dot=HB_Create("Frame",{Size=UDim2.new(0,8,0,8),Position=UDim2.new(0,screenPos.X-4,0,screenPos.Y-4),BackgroundColor3=color or Color3.fromRGB(255,100,100),BackgroundTransparency=0.3,BorderSizePixel=0,ZIndex=55},HB_FlickTrailHolder)
    HB_Corner(dot,4)
    TweenService:Create(dot,TweenInfo.new(0.4),{Size=UDim2.new(0,2,0,2),BackgroundTransparency=1}):Play()
    task.delay(0.5,function()
        if dot.Parent then
            dot:Destroy()
        end
    end)
end
function HB_LogMissReason(reason,details)
    if not S.MissLogger then
        return
    end
    table.insert(HB_MissLog,{t=tick(),reason=reason,details=details})
    if #HB_MissLog>100 then
        table.remove(HB_MissLog,1)
    end
    print("[HB-Miss]",reason,details or "")
end
function HB_WeaponProfileTrack(weaponName,snap,hold,verify,hit)
    if not S.WeaponProfiles then
        return
    end
    local prof=HB_WeaponProfiles[weaponName]
    if not prof then
        prof={snap=snap,hold=hold,verify=verify,hits=0,misses=0,samples=0}
        HB_WeaponProfiles[weaponName]=prof
    end
    prof.samples=prof.samples+1
    if hit then
        prof.hits=prof.hits+1
        prof.snap=prof.snap*0.95+snap*0.05
    else
        prof.misses=prof.misses+1
        prof.verify=math.min(prof.verify*1.05,0.8)
    end
end
function HB_WeaponProfileApply(weaponName)
    if not S.WeaponProfiles then
        return
    end
    local prof=HB_WeaponProfiles[weaponName]
    if prof and prof.samples>=10 and Flick then
        Flick.snapDur=prof.snap
        Flick.holdDur=prof.hold
        Flick.verifyWait=prof.verify
    end
end
function HB_HeatmapAdd(position)
    if not S.FlickHeatmap then
        return
    end
    table.insert(HB_FlickHeatmap,{x=position.X,z=position.Z,t=tick()})
    if #HB_FlickHeatmap>300 then
        table.remove(HB_FlickHeatmap,1)
    end
end
function HB_PredictableTrack(playerName,hit)
    if not S.PredictableFlag then
        return
    end
    local t=HB_PredictableTargets[playerName]
    if not t then
        t={hits=0,misses=0}
        HB_PredictableTargets[playerName]=t
    end
    if hit then
        t.hits=t.hits+1
    else
        t.misses=t.misses+1
    end
end
function HB_IsPredictable(playerName)
    if not S.PredictableFlag then
        return false
    end
    local t=HB_PredictableTargets[playerName]
    if not t then
        return false
    end
    local total=t.hits+t.misses
    if total<3 then
        return false
    end
    return (t.hits/total)>=0.8
end
function HB_PostFlickStats(flickTime,hit)
    if not S.PostFlickStats then
        return
    end
    HB_KillStats.totalKills=HB_KillStats.totalKills+1
    if hit then
        table.insert(HB_KillStats.times,flickTime)
        if flickTime<HB_KillStats.bestTime then
            HB_KillStats.bestTime=flickTime
        end
        local sum=0
        for _,t in ipairs(HB_KillStats.times) do
            sum=sum+t
        end
        HB_KillStats.avgTime=sum/#HB_KillStats.times
    end
end
function HB_AnalyzePersonality(player)
    local h=Hst[player]
    if not h or #h.samples<20 then
        return nil
    end
    local typ="STALKER"
    local avgSpeed=0
    local jukeCount=0
    for i=2,#h.samples do
        local d=(h.samples[i].pos-h.samples[i-1].pos).Magnitude
        avgSpeed=avgSpeed+d
        if i>3 then
            local d1=(h.samples[i].pos-h.samples[i-1].pos).Unit
            local d2=(h.samples[i-1].pos-h.samples[i-2].pos).Unit
            if d1:Dot(d2)<0.3 then
                jukeCount=jukeCount+1
            end
        end
    end
    avgSpeed=avgSpeed/math.max(1,#h.samples)
    if jukeCount>8 then
        typ="JUKER"
    elseif avgSpeed>15 then
        typ="RUSHER"
    elseif avgSpeed<3 then
        typ="CAMPER"
    elseif h.chase then
        typ="STALKER"
    else
        typ="CHAOTIC"
    end
    HB_Personalities[player]={type=typ,label=HB_PersonalityTypes[typ],speed=avgSpeed,jukes=jukeCount,t=tick()}
end
function HB_LearnWeapon(tool)
    if not S.WeaponLearning or not tool then
        return
    end
    local n=tool.Name
    HB_WeaponSigs[n]=HB_WeaponSigs[n] or {samples=0,lastFire=0,intervals={}}
    local sig=HB_WeaponSigs[n]
    local now=tick()
    if sig.lastFire>0 then
        local interval=now-sig.lastFire
        if interval<2 then
            table.insert(sig.intervals,interval)
            if #sig.intervals>50 then
                table.remove(sig.intervals,1)
            end
        end
    end
    sig.lastFire=now
    sig.samples=sig.samples+1
end
function HB_LivingMapRecord(pos,event)
    if not S.LivingMap then
        return
    end
    local key=string.format("%d_%d",math.floor(pos.X/20),math.floor(pos.Z/20))
    HB_LivingMap.grid[key]=HB_LivingMap.grid[key] or {kills=0,deaths=0,camps=0,seen=0}
    local cell=HB_LivingMap.grid[key]
    cell.seen=cell.seen+1
    if event=="kill" then
        cell.kills=cell.kills+1
    elseif event=="death" then
        cell.deaths=cell.deaths+1
    elseif event=="camp" then
        cell.camps=cell.camps+1
    end
    HB_LivingMap.samples=HB_LivingMap.samples+1
end
function HB_DNAUpdate(snap,angle,dist,hit)
    if not S.DNASystem then
        return
    end
    local d=HB_DNA
    d.samples=d.samples+1
    d.snapBase=d.snapBase*0.98+snap*0.02
    d.angleBias=d.angleBias*0.95+angle*0.05
    d.preferredDist=d.preferredDist*0.95+dist*0.05
    if hit then
        d.aggressionLevel=math.min(1,d.aggressionLevel+0.01)
    else
        d.aggressionLevel=math.max(0,d.aggressionLevel-0.005)
    end
    if d.samples==50 or d.samples%100==0 then
        d.signature=string.format("DNA-%X-%X-%X",math.floor(d.snapBase*10000),math.floor(d.angleBias*1000+500),math.floor(d.preferredDist))
    end
end
function HB_CrowdPush(data)
    if not S.CrowdIntelligence then
        return
    end
    HB_CrowdNet[LP.UserId]={data=data,t=tick()}
end
function HB_CrowdPull()
    if not S.CrowdIntelligence then
        return {}
    end
    local result={}
    for uid,entry in pairs(HB_CrowdNet) do
        if uid~=LP.UserId and tick()-entry.t<10 then
            result[uid]=entry.data
        end
    end
    return result
end
function HB_ReverseEngStart()
    HB_ReverseEng.recording=true
    HB_ReverseEng.buffer={}
    HB_Toast("🔴 Gravando seu estilo","warning")
end
function HB_ReverseEngStop()
    HB_ReverseEng.recording=false
    local buf=HB_ReverseEng.buffer
    if #buf>10 then
        local avgSnap=0
        for _,v in ipairs(buf) do
            avgSnap=avgSnap+v.snap
        end
        HB_ReverseEng.learned={snap=avgSnap/#buf,samples=#buf}
        HB_Toast("✅ Estilo aprendido","success")
    end
end
function HB_ABTestRecord(hit)
    if not S.ABTesting then
        return
    end
    local test=HB_ABTest
    local active=test.useA and test.strategyA or test.strategyB
    active.samples=active.samples+1
    active.hitRate=active.hitRate*0.9+(hit and 1 or 0)*0.1
    if active.samples>=30 then
        if test.useA and test.strategyB.hitRate>test.strategyA.hitRate+0.1 then
            test.useA=false
        elseif not test.useA and test.strategyA.hitRate>test.strategyB.hitRate+0.1 then
            test.useA=true
        end
    end
end
function HB_PredMarketBet()
    if not S.PredMarket then
        return
    end
    HB_PredMarket.activeBet={placedAt=tick(),target=0.2,amount=10}
    HB_Toast("🎰 Aposta: <200ms","warning")
end
function HB_PredMarketResolve(hitTime,hit)
    if not S.PredMarket or not HB_PredMarket.activeBet then
        return
    end
    local bet=HB_PredMarket.activeBet
    if hit and hitTime<bet.target then
        HB_PredMarket.wins=HB_PredMarket.wins+1
        HB_PredMarket.balance=HB_PredMarket.balance+bet.amount
        HB_Toast("✅ Aposta ganha! +"..bet.amount,"success")
    else
        HB_PredMarket.losses=HB_PredMarket.losses+1
        HB_PredMarket.balance=HB_PredMarket.balance-bet.amount
        HB_Toast("❌ Aposta perdida! -"..bet.amount,"danger")
    end
    HB_PredMarket.activeBet=nil
end
function HB_DeathRecapStart()
    if not S.DeathRecap3D then
        return
    end
    HB_DeathRecap.active=true
    local myPos=LP.Character and LP.Character:FindFirstChild("HumanoidRootPart") and LP.Character.HumanoidRootPart.Position
    HB_DeathRecap.data={startT=tick(),myPos=myPos,killer=nil}
    if myPos then
        local closest,closestDist=nil,50
        for _,p in ipairs(Players:GetPlayers()) do
            if p~=LP then
                local hrp=p.Character and p.Character:FindFirstChild("HumanoidRootPart")
                if hrp then
                    local d=(hrp.Position-myPos).Magnitude
                    if d<closestDist then
                        closestDist=d
                        closest=p
                    end
                end
            end
        end
        HB_DeathRecap.data.killer=closest and closest.Name or "?"
        if closest then
            HB_Toast("💀 Morto por: "..closest.Name,"danger")
        end
    end
    task.delay(4,function()
        HB_DeathRecap.active=false
    end)
end
function HB_LegacySessionSave()
    if not S.LegacyMode then
        return
    end
    local sess=HB_Legacy.currentSession
    sess.end_=tick()
    sess.duration=sess.end_-sess.start
    table.insert(HB_Legacy.sessions,sess)
    if #HB_Legacy.sessions>50 then
        table.remove(HB_Legacy.sessions,1)
    end
    HB_Legacy.totalPlayTime=HB_Legacy.totalPlayTime+sess.duration
    HB_Toast(string.format("Legacy: %dK %dD",sess.kills,sess.deaths),"success")
end
task.spawn(function()
    while task.wait(0.1) do
        if HB_ReverseEng.recording and S.ReverseEngineering then
            local cam=Camera.CFrame
            table.insert(HB_ReverseEng.buffer,{snap=Flick and Flick.snapDur or 0.045,angle=cam.LookVector.Y,t=tick()})
            if #HB_ReverseEng.buffer>500 then
                table.remove(HB_ReverseEng.buffer,1)
            end
        end
    end
end)
task.spawn(function()
    while task.wait(3) do
        if S.PersonalityProfiles then
            for _,p in ipairs(Players:GetPlayers()) do
                if p~=LP then
                    pcall(HB_AnalyzePersonality,p)
                end
            end
        end
    end
end)
task.spawn(function()
    while task.wait(1) do
        if S.AdaptiveSnap and Flick then
            local fps=FPS.cur or 60
            local ping=LP:GetNetworkPing()
            local target=0.045
            if fps<30 then
                target=0.08
            elseif fps<50 then
                target=0.06
            elseif fps>100 then
                target=0.035
            end
            target=target+ping*0.3
            Flick.snapDur=Flick.snapDur*0.85+target*0.15
        end
    end
end)
task.spawn(function()
    while task.wait(2) do
        if S.AntiSpectate then
            local specFound=false
            for _,p in ipairs(Players:GetPlayers()) do
                if p~=LP and p.CameraSubject then
                    local sub=p.CameraSubject
                    if sub==LP.Character or (sub and sub.Parent==LP.Character) then
                        specFound=true
                        break
                    end
                end
            end
            if specFound and not HB_AntiSpectate.active then
                HB_AntiSpectate.active=true
                S.AutoFlick=false
                S.ESP=false
                HB_Toast("🚨 Spectate detectado","danger")
            elseif not specFound and HB_AntiSpectate.active then
                HB_AntiSpectate.active=false
            end
        end
    end
end)
task.spawn(function()
    while task.wait(15) do
        if S.LatencySpoof and math.random()<0.3 and not HB_LatencySpoof.active then
            HB_LatencySpoof.active=true
            HB_LatencySpoof.until_=tick()+math.random(1,3)
        end
        if HB_LatencySpoof.active and tick()>HB_LatencySpoof.until_ then
            HB_LatencySpoof.active=false
        end
    end
end)
task.spawn(function()
    while task.wait(5) do
        if S.CrowdIntelligence then
            HB_CrowdPush({pos=LP.Character and LP.Character:FindFirstChild("HumanoidRootPart") and LP.Character.HumanoidRootPart.Position,kills=S.Kills,t=tick()})
        end
        if S.BehavioralMirror then
            local best,bestKills=nil,0
            for _,p in ipairs(Players:GetPlayers()) do
                if p~=LP then
                    local h=Hst[p]
                    if h and h.shotsHit and h.shotsHit>bestKills then
                        bestKills=h.shotsHit
                        best=p
                    end
                end
            end
            if best then
                HB_Mirror.target=best
                local h=Hst[best]
                if h then
                    HB_Mirror.style={avgSpeed=h.vel.Magnitude,aggression=h.chase and 0.9 or 0.4}
                end
            end
        end
    end
end)
task.spawn(function()
    while task.wait(10) do
        if S.DreamSimulation then
            local now=tick()
            if now-HB_DreamState.lastTrain>5 then
                HB_DreamState.lastTrain=now
                HB_DreamState.active=true
                for _=1,20 do
                    local inp={}
                    for j=1,8 do
                        inp[j]=math.random()*2-1
                    end
                    local target={math.random()-0.5,math.random()-0.5,math.random()-0.5}
                    pcall(HB_NNTrain,inp,target)
                    HB_DreamState.iterations=HB_DreamState.iterations+1
                end
                HB_DreamState.active=false
            end
        end
    end
end)
task.spawn(function()
    while task.wait(5) do
        if S.SquadMimicry then
            local myHrp=LP.Character and LP.Character:FindFirstChild("HumanoidRootPart")
            if myHrp then
                HB_SquadMimicry.squad={}
                for _,p in ipairs(Players:GetPlayers()) do
                    if p~=LP then
                        local hrp=p.Character and p.Character:FindFirstChild("HumanoidRootPart")
                        if hrp and (hrp.Position-myHrp.Position).Magnitude<25 then
                            table.insert(HB_SquadMimicry.squad,p)
                        end
                    end
                end
            end
        end
    end
end)
task.spawn(function()
    while task.wait(0.1) do
        if S.RhythmFlick and Flick then
            HB_Rhythm.phase=HB_Rhythm.phase+0.1*HB_Rhythm.rate
            local osc=math.sin(HB_Rhythm.phase)*HB_Rhythm.amplitude
            Flick.snapDur=math.clamp(Flick.snapDur+osc*0.005,0.03,0.15)
        end
    end
end)
task.spawn(function()
    while task.wait(3) do
        if S.AntiMetaAdapt then
            local ping=LP:GetNetworkPing()
            local fps=FPS.cur or 60
            local pCount=#Players:GetPlayers()
            local am=HB_AntiMeta
            if math.abs(ping-am.lastPing)>0.05 or math.abs(fps-am.lastFps)>20 or math.abs(pCount-am.lastPlayerCount)>3 then
                if fps<30 then
                    S.ESP=false
                    S.Chams=false
                    S.ESPSkeleton=false
                end
                if ping>0.15 and Flick then
                    Flick.verifyWait=math.min(1.0,Flick.verifyWait+0.1)
                end
                am.adaptations=am.adaptations+1
                am.lastPing=ping
                am.lastFps=fps
                am.lastPlayerCount=pCount
            end
        end
    end
end)
task.spawn(function()
    while task.wait(2) do
        if S.EmotionalAI then
            local recent=0
            for _,k in ipairs(KillLog) do
                if tick()-k.time<60 and not k.miss then
                    recent=recent+1
                end
            end
            if (S.Streak or 0)>=3 then
                HB_Emotion.state="confident"
            elseif recent<2 and S.Deaths>S.Kills then
                HB_Emotion.state="tilted"
            else
                HB_Emotion.state="neutral"
            end
            if HB_Emotion.state=="tilted" and Flick then
                Flick.snapDur=Flick.snapDur*1.1
                S.AlignTol=math.min(15,(S.AlignTol or 4)+1)
            elseif HB_Emotion.state=="confident" and Flick then
                Flick.snapDur=Flick.snapDur*0.95
                S.AlignTol=math.max(2,(S.AlignTol or 4)-0.5)
            end
        end
    end
end)
task.spawn(function()
    while task.wait(5) do
        if S.LegacyMode then
            local sess=HB_Legacy.currentSession
            if S.Kills>sess.kills then
                sess.kills=S.Kills
                if S.Kills>HB_Legacy.bestKills then
                    HB_Legacy.bestKills=S.Kills
                end
            end
            if S.Deaths>sess.deaths then
                sess.deaths=S.Deaths
            end
        end
    end
end)
task.spawn(function()
    while task.wait(1) do
        if S.FlickHeatmap then
            HB_HeatmapFrame.Visible=true
            for _,c in ipairs(HB_HeatmapFrame:GetChildren()) do
                if c:IsA("Frame") and c.Name=="Dot" then
                    c:Destroy()
                end
            end
            if #HB_FlickHeatmap>0 then
                local minX,maxX=99999,-99999
                local minZ,maxZ=99999,-99999
                for _,pt in ipairs(HB_FlickHeatmap) do
                    if pt.x<minX then
                        minX=pt.x
                    end
                    if pt.x>maxX then
                        maxX=pt.x
                    end
                    if pt.z<minZ then
                        minZ=pt.z
                    end
                    if pt.z>maxZ then
                        maxZ=pt.z
                    end
                end
                local rangeX=math.max(maxX-minX,1)
                local rangeZ=math.max(maxZ-minZ,1)
                for _,pt in ipairs(HB_FlickHeatmap) do
                    local nx=(pt.x-minX)/rangeX
                    local nz=(pt.z-minZ)/rangeZ
                    local dot=HB_Create("Frame",{Name="Dot",Size=UDim2.new(0,4,0,4),Position=UDim2.new(nx,-2,nz,20),BackgroundColor3=Color3.fromRGB(255,100,100),BackgroundTransparency=0.4,BorderSizePixel=0,ZIndex=72},HB_HeatmapFrame)
                    HB_Corner(dot,2)
                end
            end
        else
            HB_HeatmapFrame.Visible=false
        end
    end
end)
task.spawn(function()
    while task.wait(0.5) do
        if S.PriorityQueue and FindMurderQueue then
            HB_PriorityFrame.Visible=true
            local q=FindMurderQueue()
            local lines={}
            for i=1,math.min(3,#q) do
                local t=q[i]
                local flag=HB_IsPredictable(t.player.Name) and " ⭐" or ""
                table.insert(lines,string.format("%d. %s [%dm]%s",i,t.player.Name:sub(1,10),math.floor(t.dist),flag))
            end
            HB_PriorityList.Text=#lines>0 and table.concat(lines,"\n") or "Nenhum próximo"
        else
            HB_PriorityFrame.Visible=false
        end
    end
end)
task.spawn(function()
    while task.wait(2) do
        if S.PlayerProfile then
            HB_ProfileFrame.Visible=true
            local lines={}
            for _,p in ipairs(Players:GetPlayers()) do
                if p~=LP then
                    local role=GetRole(p)
                    local pers=HB_Personalities[p]
                    local persLabel=pers and pers.label or "?"
                    local flag=HB_IsPredictable(p.Name) and " ⭐" or ""
                    local icon=role=="Murderer" and "🔴" or (role=="Sheriff" and "🔵" or "🟢")
                    table.insert(lines,string.format("%s %s%s\n   %s",icon,p.Name:sub(1,14),flag,persLabel))
                end
            end
            HB_ProfileList.Text=table.concat(lines,"\n")
        else
            HB_ProfileFrame.Visible=false
        end
    end
end)
task.spawn(function()
    while task.wait(0.5) do
        if S.ThreatLivePanel then
            HB_ThreatPanelFrame.Visible=true
            local alive=0
            local murderers=0
            for _,p in ipairs(Players:GetPlayers()) do
                local ch=p.Character
                local hum=ch and ch:FindFirstChildOfClass("Humanoid")
                if hum and hum.Health>0 then
                    alive=alive+1
                    if GetRole(p)=="Murderer" then
                        murderers=murderers+1
                    end
                end
            end
            local level="LOW"
            local color=Color3.fromRGB(0,210,120)
            if murderers>=2 or alive<=3 then
                level="CRITICAL"
                color=Color3.fromRGB(255,60,60)
            elseif murderers>=1 or alive<=6 then
                level="MEDIUM"
                color=Color3.fromRGB(255,180,0)
            end
            HB_ThreatPanelLabel.Text=string.format("THREAT: %s | Alive: %d | M: %d",level,alive,murderers)
            HB_ThreatPanelLabel.TextColor3=color
        else
            HB_ThreatPanelFrame.Visible=false
        end
    end
end)
task.spawn(function()
    while task.wait(1) do
        if S.KDChart and #HB_RoundHistory>0 then
            HB_KDFrame.Visible=true
            for _,c in ipairs(HB_KDBars:GetChildren()) do
                c:Destroy()
            end
            local maxKills=5
            local barW=math.min(20,(HB_KDBars.AbsoluteSize.X-10)/math.max(1,#HB_RoundHistory))
            for i,r in ipairs(HB_RoundHistory) do
                local h=(r.kills/maxKills)*(HB_KDBars.AbsoluteSize.Y-10)
                local bar=HB_Create("Frame",{Size=UDim2.new(0,barW-2,0,h),Position=UDim2.new(0,(i-1)*barW,1,-h),BackgroundColor3=Color3.fromRGB(220,40,40),BorderSizePixel=0,ZIndex=71},HB_KDBars)
                HB_Corner(bar,2)
            end
        else
            HB_KDFrame.Visible=false
        end
    end
end)
RS.RenderStepped:Connect(function()
    if not S.ESPArrows then
        for _,a in pairs(HB_ArrowCache) do
            if a and a.Parent then
                a.Visible=false
            end
        end
        return
    end
    local vpSize=Camera.ViewportSize
    local cx,cy=vpSize.X/2,vpSize.Y/2
    local radius=math.min(vpSize.X,vpSize.Y)*0.32
    for _,player in ipairs(Players:GetPlayers()) do
        if player~=LP then
            local a=HB_ArrowCache[player]
            if not a then
                a=HB_Create("Frame",{Size=UDim2.new(0,28,0,28),BackgroundColor3=Color3.fromRGB(255,60,60),BorderSizePixel=0,AnchorPoint=Vector2.new(0.5,0.5),ZIndex=65,Visible=false},HB_ArrowHolder)
                HB_Corner(a,14)
                HB_Create("TextLabel",{Size=UDim2.new(1,0,1,0),BackgroundTransparency=1,Text="➤",Font=Enum.Font.GothamBold,TextSize=18,TextColor3=Color3.fromRGB(255,255,255),ZIndex=66},a)
                HB_ArrowCache[player]=a
            end
            local char=player.Character
            local hrp=char and char:FindFirstChild("HumanoidRootPart")
            local hum=char and char:FindFirstChildOfClass("Humanoid")
            local role=GetRole(player)
            if char and hrp and hum and hum.Health>0 and role=="Murderer" then
                local screen,onScreen=Camera:WorldToViewportPoint(hrp.Position)
                local offScreen=not onScreen or screen.Z<=0 or screen.X<50 or screen.X>vpSize.X-50 or screen.Y<50 or screen.Y>vpSize.Y-50
                if offScreen then
                    local dir=hrp.Position-Camera.CFrame.Position
                    local angle=math.atan2(dir.Z,dir.X)
                    local ax=cx+math.cos(angle)*radius
                    local ay=cy+math.sin(angle)*radius
                    a.Visible=true
                    a.Position=UDim2.new(0,ax,0,ay)
                    a.Rotation=math.deg(angle)
                else
                    a.Visible=false
                end
            else
                if a then
                    a.Visible=false
                end
            end
        end
    end
end)
HB_MakeLine=function(parent)
    return HB_Create("Frame",{BackgroundColor3=Color3.fromRGB(255,255,255),BorderSizePixel=0,AnchorPoint=Vector2.new(0.5,0.5),Visible=false,ZIndex=6},parent)
end
HB_DrawLine=function(frame,p1,p2,color)
    if not p1 or not p2 then
        frame.Visible=false
        return
    end
    local s1,on1=Camera:WorldToViewportPoint(p1)
    local s2,on2=Camera:WorldToViewportPoint(p2)
    if not on1 or not on2 or s1.Z<=0 or s2.Z<=0 then
        frame.Visible=false
        return
    end
    local dx=s2.X-s1.X
    local dy=s2.Y-s1.Y
    local len=math.sqrt(dx*dx+dy*dy)
    local angle=math.deg(math.atan2(dy,dx))
    frame.Visible=true
    frame.Size=UDim2.new(0,len,0,2)
    frame.Position=UDim2.new(0,s1.X+dx/2,0,s1.Y+dy/2)
    frame.Rotation=angle
    frame.BackgroundColor3=color
end
RS.RenderStepped:Connect(function()
    if not S.ESPSkeleton then
        for _,s in pairs(HB_SkelCache) do
            for _,line in pairs(s) do
                if line and line.Parent then
                    line.Visible=false
                end
            end
        end
        return
    end
    for _,player in ipairs(Players:GetPlayers()) do
        if player~=LP then
            local char=player.Character
            if char then
                local head=char:FindFirstChild("Head")
                local torso=char:FindFirstChild("UpperTorso") or char:FindFirstChild("Torso")
                local lowerTorso=char:FindFirstChild("LowerTorso")
                local lArm=char:FindFirstChild("LeftUpperArm") or char:FindFirstChild("Left Arm")
                local rArm=char:FindFirstChild("RightUpperArm") or char:FindFirstChild("Right Arm")
                local lLeg=char:FindFirstChild("LeftUpperLeg") or char:FindFirstChild("Left Leg")
                local rLeg=char:FindFirstChild("RightUpperLeg") or char:FindFirstChild("Right Leg")
                local s=HB_SkelCache[player]
                if not s then
                    s={ht=HB_MakeLine(HB_SkeletonHolder),tl=HB_MakeLine(HB_SkeletonHolder),la=HB_MakeLine(HB_SkeletonHolder),ra=HB_MakeLine(HB_SkeletonHolder),ll=HB_MakeLine(HB_SkeletonHolder),rl=HB_MakeLine(HB_SkeletonHolder)}
                    HB_SkelCache[player]=s
                end
                if head and torso and lArm and rArm and lLeg and rLeg then
                    local role=GetRole(player)
                    local color=ESP_COLORS[role] or ESP_COLORS.Innocent
                    HB_DrawLine(s.ht,head.Position,torso.Position,color)
                    if lowerTorso then
                        HB_DrawLine(s.tl,torso.Position,lowerTorso.Position,color)
                    else
                        s.tl.Visible=false
                    end
                    HB_DrawLine(s.la,torso.Position,lArm.Position,color)
                    HB_DrawLine(s.ra,torso.Position,rArm.Position,color)
                    HB_DrawLine(s.ll,(lowerTorso and lowerTorso.Position or torso.Position),lLeg.Position,color)
                    HB_DrawLine(s.rl,(lowerTorso and lowerTorso.Position or torso.Position),rLeg.Position,color)
                end
            end
        end
    end
end)
HB_MuzzleFlash=function(pos)
    if not S.MuzzleFlash then
        return
    end
    local myPos=Camera.CFrame.Position
    if (pos-myPos).Magnitude>80 then
        return
    end
    local screen,on=Camera:WorldToViewportPoint(pos)
    if not on or screen.Z<=0 then
        return
    end
    local flash=HB_Create("Frame",{Size=UDim2.new(0,40,0,40),Position=UDim2.new(0,screen.X-20,0,screen.Y-20),BackgroundColor3=Color3.fromRGB(255,220,100),BackgroundTransparency=0.3,BorderSizePixel=0,ZIndex=75},HB_MuzzleHolder)
    HB_Corner(flash,20)
    TweenService:Create(flash,TweenInfo.new(0.3),{Size=UDim2.new(0,80,0,80),Position=UDim2.new(0,screen.X-40,0,screen.Y-40),BackgroundTransparency=1}):Play()
    task.delay(0.35,function()
        if flash.Parent then
            flash:Destroy()
        end
    end)
end
task.spawn(function()
    while task.wait(0.4) do
        if S.FootstepESP then
            for _,p in ipairs(Players:GetPlayers()) do
                if p~=LP then
                    local char=p.Character
                    local hrp=char and char:FindFirstChild("HumanoidRootPart")
                    local hum=char and char:FindFirstChildOfClass("Humanoid")
                    if hrp and hum and hum.Health>0 and hum.MoveDirection.Magnitude>0.1 then
                        local role=GetRole(p)
                        local color=ESP_COLORS[role] or ESP_COLORS.Innocent
                        local screen,on=Camera:WorldToViewportPoint(hrp.Position)
                        if on and screen.Z>0 then
                            local ring=HB_Create("Frame",{Size=UDim2.new(0,20,0,20),Position=UDim2.new(0,screen.X-10,0,screen.Y-10),BackgroundTransparency=1,BorderSizePixel=0,ZIndex=45},HB_FootstepHolder)
                            local st=HB_Create("UIStroke",{Color=color,Thickness=2,Transparency=0.3},ring)
                            HB_Corner(ring,10)
                            TweenService:Create(ring,TweenInfo.new(0.8),{Size=UDim2.new(0,60,0,60),Position=UDim2.new(0,screen.X-30,0,screen.Y-30)}):Play()
                            TweenService:Create(st,TweenInfo.new(0.8),{Transparency=1}):Play()
                            task.delay(0.9,function()
                                if ring.Parent then
                                    ring:Destroy()
                                end
                            end)
                        end
                    end
                end
            end
        end
    end
end)
HB_ChatBot={messages={"kkk","boa","ae","gg","?"},last=0,interval=45}
task.spawn(function()
    while task.wait(10) do
        if S.ChatBot and tick()-HB_ChatBot.last>HB_ChatBot.interval then
            if math.random()<0.5 then
                HB_ChatBot.last=tick()
            end
        end
    end
end)
LP.Chatted:Connect(function(msg)
    if not S.AutoReplyAntiCheat then
        return
    end
    local l=string.lower(msg)
    if l:find("hack") or l:find("cheat") or l:find("trapa") or l:find("aim") then
        local r=HB_ChatReplies[math.random(1,#HB_ChatReplies)]
        task.wait(1.5+math.random())
    end
end)
_prevSF=StartFlick
StartFlick=function(target,tb)
    if S.FlickPreview and target.hum and target.hum.Parent then
        local fromScreen=Camera:WorldToViewportPoint(Camera.CFrame.Position)
        local head=target.hum.Parent:FindFirstChild("Head")
        if head then
            local toScreen=Camera:WorldToViewportPoint(head.Position)
            if toScreen then
                HB_FlickPreviewShow(fromScreen,toScreen,Color3.fromRGB(255,200,100))
            end
        end
    end
    if S.WeaponProfiles then
        local w=FindWeapon()
        if w then
            HB_WeaponProfileApply(w.Name)
        end
    end
    _prevSF(target,tb)
end
_prevML2=MetaLearnUpdate
MetaLearnUpdate=function(perf)
    _prevML2(perf)
    local hit=perf and perf>0.5
    if hit then
        if Flick and Flick.snapDur then
            HB_PostFlickStats(Flick.snapDur,true)
            HB_DNAUpdate(Flick.snapDur,0,30,true)
        end
        local target=Flick and Flick.targetPlayer
        if target and Cache.HRPs[target] then
            HB_HeatmapAdd(Cache.HRPs[target].Position)
            HB_PredictableTrack(target.Name,true)
            HB_LivingMapRecord(Cache.HRPs[target].Position,"kill")
        end
    else
        local target=Flick and Flick.targetPlayer
        if target then
            HB_PredictableTrack(target.Name,false)
            HB_LogMissReason("Flick failed",target.Name)
        end
    end
    HB_ABTestRecord(hit)
    if Flick and Flick.snapDur then
        HB_PredMarketResolve(Flick.snapDur,hit)
    end
end
HB_DebugRoles=function()
    for _,p in ipairs(Players:GetPlayers()) do
        if p~=LP then
            print(string.format("%s → %s | Tool: %s",p.Name,GetRole(p),HB_FindTool(p) or "nenhuma"))
        end
    end
end
HB_ShowAllRoles=HB_DebugRoles
task.spawn(function()
    local lastHealth=100
    while task.wait(0.2) do
        local hum=LP.Character and LP.Character:FindFirstChildOfClass("Humanoid")
        if hum then
            if hum.Health<lastHealth and hum.Health<=0 then
                pcall(HB_DeathRecapStart)
                S.Deaths=S.Deaths+1
                S.Streak=0
            end
            lastHealth=hum.Health
        end
    end
end)
UIS.InputBegan:Connect(function(input,gp)
    if gp then
        return
    end
    if input.KeyCode==Enum.KeyCode.F2 then
        pcall(HB_LegacySessionSave)
    end
end)
print("═══════════════════════════════════════════")
print("✅ HELLBORN ULTIMATE v9.0 — COMPLETO!")
print("═══════════════════════════════════════════")
print("📊 46 features · 18 abas")
print("🎯 ESP: 🔴 Murderer | 🔵 Sheriff | 🟢 Innocent")
print("⌨️  Insert = menu | Q = Flick | F1 = Panic | F2 = Legacy")
print("💡 HBShowAllRoles() pra debug")
print("═══════════════════════════════════════════")
HB_RSI={
    enabled=true,
    generation=1,
    population={},
    popSize=20,
    bestGenome=nil,
    bestFitness=0,
    mutations=0,
    crossovers=0,
    reverts=0,
    killsSinceEvolve=0,
    evolveEveryKills=5,
    fitnessSamples={},
    generationHistory={},
    lastApplyTick=0,
    applyInterval=1.0,
    maxHistory=50,
}

function HB_RSI_NewGenome()
    return {
        snap=0.030+math.random()*0.040,
        hold=0.100+math.random()*0.150,
        verify=0.300+math.random()*0.400,
        noise=0.00+math.random()*0.30,
        aggression=0.3+math.random()*0.7,
        fitness=0.5,
        wins=0,
        losses=0,
        bornAt=tick(),
    }
end

function HB_RSI_Init()
    HB_RSI.population={}
    for i=1,HB_RSI.popSize do
        table.insert(HB_RSI.population,HB_RSI_NewGenome())
    end
    HB_RSI.bestGenome=HB_RSI.population[1]
    HB_RSI.bestFitness=0.5
end
HB_RSI_Init()

function HB_RSI_Mutate(genome,rate)
    rate=rate or 0.15
    local g={
        snap=genome.snap,
        hold=genome.hold,
        verify=genome.verify,
        noise=genome.noise,
        aggression=genome.aggression,
        fitness=0.5,
        wins=0,
        losses=0,
        bornAt=tick(),
    }
    if math.random()<rate then
        g.snap=math.clamp(g.snap+(math.random()-0.5)*0.015,0.015,0.150)
    end
    if math.random()<rate then
        g.hold=math.clamp(g.hold+(math.random()-0.5)*0.060,0.050,0.400)
    end
    if math.random()<rate then
        g.verify=math.clamp(g.verify+(math.random()-0.5)*0.150,0.200,1.000)
    end
    if math.random()<rate then
        g.noise=math.clamp(g.noise+(math.random()-0.5)*0.100,0.000,0.500)
    end
    if math.random()<rate then
        g.aggression=math.clamp(g.aggression+(math.random()-0.5)*0.200,0.100,1.000)
    end
    HB_RSI.mutations=HB_RSI.mutations+1
    return g
end

function HB_RSI_Crossover(a,b)
    local g={
        snap=math.random()<0.5 and a.snap or b.snap,
        hold=math.random()<0.5 and a.hold or b.hold,
        verify=math.random()<0.5 and a.verify or b.verify,
        noise=math.random()<0.5 and a.noise or b.noise,
        aggression=math.random()<0.5 and a.aggression or b.aggression,
        fitness=0.5,
        wins=0,
        losses=0,
        bornAt=tick(),
    }
    HB_RSI.crossovers=HB_RSI.crossovers+1
    return g
end

function HB_RSI_Fitness(genome)
    local total=genome.wins+genome.losses
    if total==0 then
        return 0.5
    end
    return genome.wins/total
end

function HB_RSI_Evolve()
    table.sort(HB_RSI.population,function(a,b)
        return HB_RSI_Fitness(a)>HB_RSI_Fitness(b)
    end)
    local elite=math.floor(HB_RSI.popSize*0.2)
    local newPop={}
    for i=1,elite do
        table.insert(newPop,HB_RSI.population[i])
    end
    while #newPop<HB_RSI.popSize do
        local a=HB_RSI.population[math.random(1,elite)]
        local b=HB_RSI.population[math.random(1,elite)]
        local child=HB_RSI_Crossover(a,b)
        child=HB_RSI_Mutate(child,0.20)
        table.insert(newPop,child)
    end
    HB_RSI.population=newPop
    local oldBest=HB_RSI.bestFitness
    HB_RSI.bestGenome=HB_RSI.population[1]
    HB_RSI.bestFitness=HB_RSI_Fitness(HB_RSI.bestGenome)
    if HB_RSI.bestFitness<oldBest then
        HB_RSI.reverts=HB_RSI.reverts+1
    end
    HB_RSI.generation=HB_RSI.generation+1
    table.insert(HB_RSI.generationHistory,{
        gen=HB_RSI.generation,
        fitness=HB_RSI.bestFitness,
        snap=HB_RSI.bestGenome.snap,
        hold=HB_RSI.bestGenome.hold,
        t=tick(),
    })
    if #HB_RSI.generationHistory>HB_RSI.maxHistory then
        table.remove(HB_RSI.generationHistory,1)
    end
    HB_Toast(string.format("🧬 Gen %d | Fit %.0f%%",HB_RSI.generation,HB_RSI.bestFitness*100),"success")
end

function HB_RSI_Apply()
    if not HB_RSI.enabled then
        return
    end
    if tick()-HB_RSI.lastApplyTick<HB_RSI.applyInterval then
        return
    end
    HB_RSI.lastApplyTick=tick()
    local g=HB_RSI.bestGenome
    if not g or not Flick then
        return
    end
    local targetSnap=g.snap
    local targetHold=g.hold
    local targetVerify=g.verify
    Flick.snapDur=Flick.snapDur*0.85+targetSnap*0.15
    Flick.holdDur=Flick.holdDur*0.85+targetHold*0.15
    Flick.verifyWait=Flick.verifyWait*0.85+targetVerify*0.15
    if S.AimNoiseAmp then
        S.AimNoiseAmp=S.AimNoiseAmp*0.85+g.noise*0.15
    end
    if S.AlignTol then
        local tol=2+g.aggression*8
        S.AlignTol=S.AlignTol*0.85+tol*0.15
    end
end

function HB_RSI_RecordKill()
    if not HB_RSI.enabled then
        return
    end
    local g=HB_RSI.bestGenome
    if g then
        g.wins=g.wins+1
        g.fitness=HB_RSI_Fitness(g)
    end
    HB_RSI.killsSinceEvolve=HB_RSI.killsSinceEvolve+1
    if HB_RSI.killsSinceEvolve>=HB_RSI.evolveEveryKills then
        HB_RSI.killsSinceEvolve=0
        pcall(HB_RSI_Evolve)
    end
end

function HB_RSI_RecordMiss()
    if not HB_RSI.enabled then
        return
    end
    local g=HB_RSI.bestGenome
    if g then
        g.losses=g.losses+1
        g.fitness=HB_RSI_Fitness(g)
    end
end

HB_RSI_Gui=HB_Create("ScreenGui",{Name="HB_RSI_Overlay",ResetOnSpawn=false,IgnoreGuiInset=true,DisplayOrder=91},PG)
HB_RSI_Frame=HB_Create("Frame",{Name="RSI",Size=UDim2.new(0,240,0,140),Position=UDim2.new(0,10,0,300),BackgroundColor3=Color3.fromRGB(18,18,22),BackgroundTransparency=0.15,BorderSizePixel=0,Visible=false,ZIndex=70},HB_RSI_Gui)
HB_Corner(HB_RSI_Frame,10)
HB_Stroke(HB_RSI_Frame,Color3.fromRGB(150,100,255),2,0.3)
HB_RSI_Title=HB_Create("TextLabel",{Size=UDim2.new(1,0,0,22),Position=UDim2.new(0,0,0,4),BackgroundTransparency=1,Text="🧬 RECURSIVE SELF-IMPROVEMENT",Font=Enum.Font.GothamBold,TextSize=11,TextColor3=Color3.fromRGB(200,180,255),TextXAlignment=Enum.TextXAlignment.Center,ZIndex=71},HB_RSI_Frame)
HB_RSI_Info=HB_Create("TextLabel",{Size=UDim2.new(1,-16,1,-30),Position=UDim2.new(0,8,0,26),BackgroundTransparency=1,Text="",Font=Enum.Font.Code,TextSize=10,TextColor3=Color3.fromRGB(245,245,250),TextXAlignment=Enum.TextXAlignment.Left,TextYAlignment=Enum.TextYAlignment.Top,TextWrapped=true,ZIndex=71},HB_RSI_Frame)

task.spawn(function()
    while task.wait(0.5) do
        if HB_RSI.enabled and HB_RSI_Frame.Visible then
            local g=HB_RSI.bestGenome
            if g then
                local total=g.wins+g.losses
                HB_RSI_Info.Text=string.format(
                    "Gen: %d | Mut: %d | Cross: %d\nFit: %.0f%% (%d/%d)\nSnap: %.3f  Hold: %.3f\nVerify: %.3f  Noise: %.2f\nAggro: %.2f  Reverts: %d",
                    HB_RSI.generation,
                    HB_RSI.mutations,
                    HB_RSI.crossovers,
                    HB_RSI_Fitness(g)*100,
                    g.wins,
                    total,
                    g.snap,
                    g.hold,
                    g.verify,
                    g.noise,
                    g.aggression,
                    HB_RSI.reverts
                )
            end
        end
    end
end)

task.spawn(function()
    while task.wait(1) do
        if HB_RSI.enabled then
            pcall(HB_RSI_Apply)
        end
    end
end)

HB_RSI_OrigMeta=MetaLearnUpdate
MetaLearnUpdate=function(perf)
    HB_RSI_OrigMeta(perf)
    if not HB_RSI.enabled then
        return
    end
    if perf and perf>0.5 then
        pcall(HB_RSI_RecordKill)
    else
        pcall(HB_RSI_RecordMiss)
    end
end

HB_RSI_OrigFinalize=HB_RSI_Apply
HB_RSI_Apply=function()
    HB_RSI_OrigFinalize()
    if HB_RSI.enabled and HB_RSI_Frame then
        HB_RSI_Frame.Visible=S.RSIOverlay==true
    end
end

RS.RenderStepped:Connect(function()
    if HB_RSI.enabled and HB_RSI_Frame then
        HB_RSI_Frame.Visible=S.RSIOverlay==true
    end
end)

function HB_RSI_ForceEvolve()
    HB_RSI.killsSinceEvolve=0
    HB_RSI_Evolve()
    HB_Toast("🧬 Evolução forçada — Gen "..HB_RSI.generation,"success")
end

function HB_RSI_ShowHistory()
    print("═══ RSI HISTORY ═══")
    for _,h in ipairs(HB_RSI.generationHistory) do
        print(string.format("Gen %d | Fit %.0f%% | snap %.3f | hold %.3f",h.gen,h.fitness*100,h.snap,h.hold))
    end
    print("════════════════════")
end

function HB_RSI_Reset()
    HB_RSI_Init()
    HB_RSI.generation=1
    HB_RSI.mutations=0
    HB_RSI.crossovers=0
    HB_RSI.reverts=0
    HB_RSI.generationHistory={}
    HB_Toast("🧬 RSI resetado","info")
end

S.RSIOverlay=S.RSIOverlay or false
S.RSIEnabled=S.RSIEnabled or true

HB_RSI_TabHook=function()
    local tab=_G.UI and _G.UI.TabContents and _G.UI.TabContents["Revolu"]
    if not tab or not _G.Cmp then
        return
    end
    local y=0
    for _,c in ipairs(tab:GetChildren()) do
        if c:IsA("Frame") then
            y=math.max(y,c.Position.Y.Offset+c.Size.Y.Offset+8)
        end
    end
    y=_G.Cmp.Section(tab,"🧬 RECURSIVE SELF-IMPROVEMENT",y)
    y=_G.Cmp.Toggle(tab,{text="RSI Enable",desc="Auto-melhora por kill",default=true,callback=function(v)
        S.RSIEnabled=v
        HB_RSI.enabled=v
    end},y)
    y=_G.Cmp.Toggle(tab,{text="RSI Overlay",desc="Mostra painel Gen/Fitness",default=false,callback=function(v)
        S.RSIOverlay=v
    end},y)
    y=_G.Cmp.Button(tab,{text="🧬 Forçar Evolução",callback=function()
        HB_RSI_ForceEvolve()
    end},y)
    y=_G.Cmp.Button(tab,{text="📊 Ver Histórico",callback=function()
        HB_RSI_ShowHistory()
    end},y)
    y=_G.Cmp.Button(tab,{text="🔄 Resetar RSI",danger=true,callback=function()
        HB_RSI_Reset()
    end},y)
end

task.delay(1,function()
    pcall(HB_RSI_TabHook)
end)

HB_RSI.enabled=S.RSIEnabled

print("[HB] ✅ Recursive Self-Improvement Loop ativo — Gen "..HB_RSI.generation)