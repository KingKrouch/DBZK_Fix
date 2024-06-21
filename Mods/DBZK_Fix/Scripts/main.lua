local UEHelpers = require("UEHelpers")
local inifile = require("inifile");

local GetKismetSystemLibrary = UEHelpers.GetKismetSystemLibrary

local ksl   = GetKismetSystemLibrary()

local engine = FindFirstOf("Engine")

local canExecute = true
local init = false

--- @type bool
local showFPSStats = false

--- @type bool
local useTemporalUpscaling = false

--- @type bool
-- By default, the game uses motion blur, so let's keep that on.
local useMotionBlur = true

--- @type int
local fpsCap = 0

--- @type int
local vsyncInterval = 1

--- @type float
local ogAspectRatio = 16 / 9

-- This is just a bit from a Persona 3 tweaks mod.
--- @param cmd string
function ExecCmd(cmd)
    if not ksl:IsValid() then
        error("KismetSystemLibrary not valid\n")
    end
    ksl:ExecuteConsoleCommand(UEHelpers:GetWorldContextObject(),cmd, nil)
end

function Fix()
    local PlayerController = UEHelpers.GetPlayerController()

    if PlayerController:IsValid() then
        local CheatManager = PlayerController.CheatManager

        if CheatManager:IsValid() then
            CheatManager:ATFrameRateVariable(fpsCap)
        else
            logError("Invalid CheatManager!\n")
        end
    else
        logError("Invalid Player Controller!\n")
    end

    ExecCmd("rhi.SyncInterval " ..vsyncInterval)

    if useTemporalUpscaling then
        ExecCmd("r.DefaultFeature.AntiAliasing 2")
        ExecCmd("r.PostProcessAAQuality 6")
        ExecCmd("r.TemporalAA.Upsampling 1")
        ExecCmd("r.TemporalAA.Algorithm 1")
    end
    if not useMotionBlur then
        ExecCmd("r.MotionBlurQuality 0")
    end

    -- For now this is going to be commented until we know that the more advanced hook works: ExecCmd("ATFrameRateVariable " ..fpsCap)
    if showFPSStats then
        ExecCmd("stat unit")
        ExecCmd("stat fps")
    end
end

function Init()
    if init then
        return
    end

    local config = inifile.parse("Config.ini")

    -- Initialize config variables
    showFPSStats         = config["Misc"]["ShowFPSStats"]
    useTemporalUpscaling = config["Graphics"]["TemporalUpscaling"]
    useMotionBlur        = config["Graphics"]["MotionBlur"]
    vsyncInterval        = config["Framerate"]["VSyncInterval"]
    local fpsCapCheck    = config["Framerate"]["MaxFPS"]
    if fpsCapCheck == 0 then -- the reason for this is because apparently there's side effects when setting it to 0 rather than a high number.
        fpsCap           = 9999
    else
        fpsCap           = fpsCapCheck
    end
    
    init = true

    print("[DBZK_Fix] Initializing...\n")
end

Init()

RegisterHook("/Script/Engine.PlayerController:ClientRestart", function()
    Fix()
end)

--- @param hfov float
--- @param aspect_ratio float
function hfov_to_vfov(hfov, aspect_ratio) -- Convert from Vert- to Hor+
    local hfov_radians = math.rad(hfov / 2)  -- Convert HFOV to radians and divide by 2
    local vfov_radians = 2 * math.atan(math.tan(hfov_radians) / aspect_ratio)
    local vfov_degrees = math.deg(vfov_radians)  -- Convert VFOV back to degrees
    return vfov_degrees
end

--- @param vfov float
--- @param aspect_ratio float
function vfov_to_hfov(vfov, aspect_ratio) -- Convert from Hor+ to Vert-
    local vfov_radians = math.rad(vfov / 2)  -- Convert VFOV to radians and divide by 2
    local hfov_radians = 2 * math.atan(aspect_ratio * math.tan(vfov_radians))
    local hfov_degrees = math.deg(hfov_radians)  -- Convert HFOV back to degrees
    return hfov_degrees
end

RegisterHook("/Script/AT.ATSaveManager:Load", function()
    print("[DBZK_Fix] Loading...\n")
    Fix()
end)

RegisterHook("/Script/AT.ATSaveManager:Save", function()
    print("[DBZK_Fix] Saving...\n")
    Fix()
end)

-- NOTE: Figure out why this isn't working. Almost as if it's being rewritten.
NotifyOnNewObject("/Script/Engine.LocalPlayer",
function(CreatedObject)
    print("[DBZK_Fix] Found the LocalPlayer.\n")
    if CreatedObject:IsValid() then
        -- Because the AspectRatioAxisConstraint is an Enum, we use 0 to get AspectRatio_MaintainYFOV.
        CreatedObject.AspectRatioAxisConstraint = 0
        print("[DBZK_Fix] Patched LocalPlayer's AspectRatioAxisConstraint.\n")
    end
end)


-- TODO: Figure out why this doesn't work. Ideally we should be hooking the function modifying the FOV during gameplay, run our calculations, and then return the proper FOV. We only really have to do this because old UE4 versions doesn't convert the FOV properly.
RegisterHook("/Script/Engine.CameraComponent:SetFieldOfView", function(InFieldOfView)
    if InFieldOfView:IsValid() then
        local fovOld = InFieldOfView;
        InFieldOfView = hfov_to_vfov(fovOld, ogAspectRatio)
        print("[DBZK_Fix] New FOV: ", InFieldOfView, ". Old FOV: ", fovOld, ".")
    end
end)

-- NOTE: Need to figure out why realtime cutscenes don't display in 21:9.
NotifyOnNewObject("/Script/Engine.CameraComponent", function(CreatedObject)
    if CreatedObject:IsValid() then
        print("[DBZK_Fix] Found a Camera Component.\n")
        CreatedObject.bConstrainAspectRatio = false
    end
end)

NotifyOnNewObject("/Game/Maps/Boot/Title/Title.Title:PersistentLevel.CameraActor_1.CameraComponent", function (CreatedObject)
    if CreatedObject:IsValid() then
        print("[DBZK_Fix] Found the title screen Camera Component.\n")
        CreatedObject.bConstrainAspectRatio = false
    end
end)

NotifyOnNewObject("/Game/Maps/Boot/Title/Title.Title:PersistentLevel.CameraActor_0.CameraComponent", function (CreatedObject)
    if CreatedObject:IsValid() then
        print("[DBZK_Fix] Found the title screen Camera Component.\n")
        CreatedObject.bConstrainAspectRatio = false
    end
end)

NotifyOnNewObject("/Script/AT.AT_UITPSLockOnMark", function(CreatedObject)
    if CreatedObject:IsValid() then
        print("Intercepted LockOnMark Widget.")
        --CreatedObject.WL_AllBattleLock00.
    end
end)

-- Grabs any new CheatManager and adjusts FPS cap
-- (Title Screen, In game, etc...)
NotifyOnNewObject("/Script/AT.ATCheatManager",
function(CreatedObject)
    --logPrint("CheatManager created!\n")
    if CreatedObject:IsValid() then
        CreatedObject:ATFrameRateVariable(fpsCap)
    else
        logError("Invalid CheatManager created!\n")
    end
end)

-- Uncaps the UI during pre-rendered cutscenes
NotifyOnNewObject("/Script/ATExt.ATSceneEvent", function(CreatedObject)
    print("ATSceneEvent created!\n")
    Fix()
end)

-- Uncaps the game during any in-game cutscenes
NotifyOnNewObject("/Script/ATExt.ATSceneDemoBase", function(CreatedObject)
    print("ATSceneDemoBase created!\n")
    Fix()
end)

-- Notes:
--CameraComponent /Script/ATExt.Default__ViewActor:CameraComp_ViewActor

--Would probably want to find the derivatives and then allow adjusting FieldOfView on a per-context basis.

--Patch /Script/Engine.LocalPlayer (to change the game to use Hor+ scaling or Vert- depending on the aspect ratio)

--/Script/Engine.PlayerController:GetViewportSize (We will want to hook this to grab the game's current aspect ratio)

----RegisterHook("/Script/ATExt.ATSaveSystemOption:RenderRate")
-- NOTE: /Script/ATExt.ATSaveSystem seemingly is the class that contains a reference to the ATSaveSystem:Options struct property.

-- TODO: Find video playback and find a way to constrain that to 16:9.

-- Hook Function /Script/UMG.Widget:GetDesiredSize, change the return size to always be a 16:9 portion on screen.
-- Need to find a hook for SCanvas::OnArrangeChildren

-- Just a random note, you can launch Cheat Engine at the same time as your game of choice by using "PROTON_REMOTE_DEBUG_CMD="/home/$USER/Applications/Cheat_Engine/cheatengine-x86_64.exe" %command%"

-- /Engine/Transient.GameEngine_0.BP_ATGameInstance_C_0.Gameover_C_0.WidgetTree_0.All_Nut

-- Look into BaseDemoScene so we can hook that and change the framerate cap then too.

-- There's a slideshow around when Trunks finds the exoskeleton that's seemingly anchored towards the left side of the screen. This also occurs after Cell absorbs one of the androids.
-- The options menu rows have incorrect anchoring. They should be in the center.