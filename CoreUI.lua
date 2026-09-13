local CoreGui = game:GetService("CoreGui")
local RunService = game:GetService("RunService")

local SCALE = tonumber(getgenv().CoreUIScale) or 0.55
SCALE = math.clamp(SCALE, 0.01, 1.00)

local TAG = "__JoaoCoreUIScale"

if getgenv().__JoaoCoreUIFix then
    pcall(function()
        getgenv().__JoaoCoreUIFix:Disconnect()
    end)
    getgenv().__JoaoCoreUIFix = nil
end

local function find(root, name)
    if not root then
        return nil
    end

    if root.Name == name then
        return root
    end

    local direct = root:FindFirstChild(name)
    if direct then
        return direct
    end

    for _, v in ipairs(root:GetDescendants()) do
        if v.Name == name then
            return v
        end
    end

    return nil
end

local function setScale(gui, value)
    if not gui or not gui:IsA("GuiObject") then
        return
    end

    gui.ClipsDescendants = false

    local uiScale = gui:FindFirstChild(TAG)
    if not uiScale then
        uiScale = Instance.new("UIScale")
        uiScale.Name = TAG
        uiScale.Parent = gui
    end

    uiScale.Scale = value
end

local topbarContainer
repeat
    topbarContainer = CoreGui:FindFirstChild("TopBarApp")
    task.wait()
until topbarContainer

local topbar = topbarContainer:FindFirstChild("TopBarApp") or topbarContainer
local menuHolder = find(topbar, "MenuIconHolder")
local unibarLeft = find(topbar, "UnibarLeftFrame")
local unibarMenu = find(topbar, "UnibarMenu")

if not menuHolder or not unibarLeft or not unibarMenu then
    error("CoreUI nao encontrada")
end

menuHolder.ClipsDescendants = false
unibarLeft.ClipsDescendants = false
unibarMenu.ClipsDescendants = false

local trigger = find(menuHolder, "TriggerPoint")
if trigger and trigger:IsA("GuiObject") then
    trigger.ClipsDescendants = false
end

local robloxButton
if trigger then
    robloxButton = find(trigger, "IconHitArea")
        or find(trigger, "Background")
        or trigger
else
    robloxButton = menuHolder
end

if robloxButton:IsA("GuiObject") then
    robloxButton.ClipsDescendants = false
end

local chat = CoreGui:FindFirstChild("ExperienceChat")
local appLayout = chat and find(chat, "appLayout") or nil

-- Normalize our own previous scale first so re-running this script is NOT cumulative.
setScale(menuHolder, 1)
setScale(unibarMenu, 1)
if appLayout then
    setScale(appLayout, 1)
end

if not getgenv().__JoaoCoreUIOriginalLeftPosition then
    getgenv().__JoaoCoreUIOriginalLeftPosition = unibarLeft.Position
end

unibarLeft.Position = getgenv().__JoaoCoreUIOriginalLeftPosition

RunService.RenderStepped:Wait()
RunService.RenderStepped:Wait()

local originalButtonX = robloxButton.AbsolutePosition.X
local originalButtonWidth = robloxButton.AbsoluteSize.X
local originalUnibarX = unibarMenu.AbsolutePosition.X
local originalGap = originalUnibarX - (originalButtonX + originalButtonWidth)

if originalGap < 0 then
    originalGap = 0
end

setScale(menuHolder, SCALE)
setScale(unibarMenu, SCALE)
if appLayout then
    setScale(appLayout, SCALE)
end

RunService.RenderStepped:Wait()
RunService.RenderStepped:Wait()
RunService.RenderStepped:Wait()

local desiredButtonWidth = originalButtonWidth * SCALE
local desiredGap = originalGap * SCALE
local desiredUnibarX = originalButtonX + desiredButtonWidth + desiredGap
local currentUnibarX = unibarMenu.AbsolutePosition.X
local moveX = desiredUnibarX - currentUnibarX

local basePosition = getgenv().__JoaoCoreUIOriginalLeftPosition
local targetPosition = UDim2.new(
    basePosition.X.Scale,
    basePosition.X.Offset + moveX,
    basePosition.Y.Scale,
    basePosition.Y.Offset
)

unibarLeft.Position = targetPosition

local stackedElements = find(topbar, "StackedElements")

local function hideShopBag()
    if not stackedElements or not stackedElements.Parent then
        stackedElements = find(topbar, "StackedElements")
    end

    if not stackedElements then
        return
    end

    local found = false

    for _, v in ipairs(stackedElements:GetChildren()) do
        if v:IsA("GuiObject") and v.LayoutOrder == 1 then
            v.Visible = false
            found = true
        end
    end

    if found then
        return
    end

    for _, v in ipairs(stackedElements:GetDescendants()) do
        local name = string.lower(v.Name)
        if string.find(name, "shop", 1, true)
            or string.find(name, "store", 1, true)
            or string.find(name, "offer", 1, true)
        then
            local current = v
            while current and current.Parent and current.Parent ~= stackedElements do
                current = current.Parent
            end

            if current and current:IsA("GuiObject") then
                current.Visible = false
            end
        end
    end
end

hideShopBag()

getgenv().__JoaoCoreUIFix = RunService.RenderStepped:Connect(function()
    if unibarLeft and unibarLeft.Parent then
        unibarLeft.Position = targetPosition
    end

    hideShopBag()
end)
