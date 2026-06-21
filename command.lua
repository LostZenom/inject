-- ═══════════════════════════════════════════════════════════════════════════
--  RIKUSU COMMAND BAR  ·  v4.6 (Floating UI Refinements & Clickable Help)
--  fly · unfly · noclip · clip · speed · jump · reset · rejoin · reanim
--  newcmd · editcmd · delcmd · cmds · help
-- ═══════════════════════════════════════════════════════════════════════════
local Players          = game:GetService("Players")
local TweenService     = game:GetService("TweenService")
local RunService       = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local TeleportService  = game:GetService("TeleportService")

local lp  = Players.LocalPlayer
local gui = lp:WaitForChild("PlayerGui")

-- destroy any prior instance
local old = gui:FindFirstChild("Rikusu_CmdBar")
if old then old:Destroy() end

-- ═══════════════════════════════════════════════════════════════════════════
--  PERSISTENCE
-- ═══════════════════════════════════════════════════════════════════════════
local STORE_NAME = "Rikusu_Commands"

local function getStore()
    local f = workspace:FindFirstChild(STORE_NAME)
    if not f then
        f      = Instance.new("Folder")
        f.Name = STORE_NAME
        f.Parent = workspace
    end
    return f
end

local function saveCmd(name, code)
    local f  = getStore()
    local ex = f:FindFirstChild(name)
    if ex then ex:Destroy() end
    local sv = Instance.new("StringValue")
    sv.Name   = name
    sv.Value  = code
    sv.Parent = f
end

local function loadCmd(name)
    local sv = getStore():FindFirstChild(name)
    return sv and sv.Value or nil
end

local function deleteCmd(name)
    local sv = getStore():FindFirstChild(name)
    if sv then sv:Destroy(); return true end
    return false
end

local function listCmds()
    local t = {}
    for _, sv in ipairs(getStore():GetChildren()) do
        if sv:IsA("StringValue") then table.insert(t, sv.Name) end
    end
    table.sort(t)
    return t
end

-- ═══════════════════════════════════════════════════════════════════════════
--  PALETTE
-- ═══════════════════════════════════════════════════════════════════════════
local C = {
    BG      = Color3.fromRGB( 10,  12,  22),
    BG2     = Color3.fromRGB( 14,  17,  30),
    BG3     = Color3.fromRGB( 18,  22,  40),
    STROKE  = Color3.fromRGB( 60,  75, 130),
    ACCENT  = Color3.fromRGB( 90, 175, 255),
    TEXT    = Color3.fromRGB(225, 235, 255),
    DIM     = Color3.fromRGB(120, 135, 175),
    DIM2    = Color3.fromRGB( 65,  78, 120),
    ON      = Color3.fromRGB( 50, 210, 120),
    OFF     = Color3.fromRGB(240,  70, 100),
    WARN    = Color3.fromRGB(255, 195,  60),
    ASH1    = Color3.fromRGB(185, 190, 200),
    ASH2    = Color3.fromRGB( 48,  92, 222),
    ASH3    = Color3.fromRGB(255,  28,  28),

    PANEL   = Color3.fromRGB( 10,  12,  22),
    ACCENT2 = Color3.fromRGB(145,  90, 255),
    ACTION  = Color3.fromRGB( 65, 140, 240),
    DANGER  = Color3.fromRGB(240,  70, 100),
    CARD    = Color3.fromRGB( 16,  20,  40),
    DIV     = Color3.fromRGB( 38,  48,  80),
    SUB     = Color3.fromRGB(155, 170, 215),
}

local ES, ED = Enum.EasingStyle, Enum.EasingDirection
local TI = {
    Pop     = TweenInfo.new(0.52, ES.Back,  ED.Out),
    PopOut  = TweenInfo.new(0.36, ES.Back,  ED.In),
    Fade    = TweenInfo.new(0.28, ES.Sine,  ED.Out),
    FadeOut = TweenInfo.new(0.20, ES.Sine,  ED.In),
    Hover   = TweenInfo.new(0.14, ES.Sine,  ED.Out),
    Flash   = TweenInfo.new(0.38, ES.Quint, ED.Out),
}

local function tw(obj, info, goals)
    if obj and obj.Parent then TweenService:Create(obj, info, goals):Play() end
end

-- ═══════════════════════════════════════════════════════════════════════════
--  ROOT ScreenGui
-- ═══════════════════════════════════════════════════════════════════════════
local sg = Instance.new("ScreenGui")
sg.Name            = "Rikusu_CmdBar"
sg.ResetOnSpawn    = false
sg.IgnoreGuiInset  = true
sg.ZIndexBehavior  = Enum.ZIndexBehavior.Sibling
pcall(function() sg.DisplayOrder = 9999 end)
sg.Parent = (rawget(_G,"gethui") and gethui()) or gui

-- ═══════════════════════════════════════════════════════════════════════════
--  LUA SYNTAX HIGHLIGHTER  (RichText)
-- ═══════════════════════════════════════════════════════════════════════════
local KW = {["and"]=1,["break"]=1,["do"]=1,["else"]=1,["elseif"]=1,["end"]=1,["false"]=1,["for"]=1,["function"]=1,["if"]=1,["in"]=1,["local"]=1,["nil"]=1,["not"]=1,["or"]=1,["repeat"]=1,["return"]=1,["then"]=1,["true"]=1,["until"]=1,["while"]=1}
local BLT = {["print"]=1,["pairs"]=1,["ipairs"]=1,["next"]=1,["select"]=1,["type"]=1,["tostring"]=1,["tonumber"]=1,["error"]=1,["pcall"]=1,["xpcall"]=1,["rawget"]=1,["rawset"]=1,["setmetatable"]=1,["getmetatable"]=1,["unpack"]=1,["require"]=1,["loadstring"]=1,["assert"]=1,["math"]=1,["string"]=1,["table"]=1,["task"]=1,["wait"]=1,["game"]=1,["workspace"]=1,["script"]=1,["Instance"]=1,["Vector3"]=1,["Vector2"]=1,["Color3"]=1,["CFrame"]=1,["UDim2"]=1,["UDim"]=1,["Enum"]=1,["RunService"]=1,["Players"]=1}
local SYN = { KW="5BA8FF", BLT="A68FFF", STR="7EC894", NUM="F0A05A", CMT="4A6070", OP="7788BB", PL="C8D8F8" }

local function escRich(s) return s:gsub("&","&amp;"):gsub("<","&lt;"):gsub(">","&gt;") end
local function span(text, col) if text == "" then return "" end return string.format('<font color="#%s">%s</font>', col, escRich(text)) end
local function highlightLine(line)
    local out, i, len = {}, 1, #line
    while i <= len do
        local c = line:sub(i,i)
        if line:sub(i,i+1) == "--" then table.insert(out, span(line:sub(i), SYN.CMT)); break
        elseif c=='"' or c=="'" then
            local q, j = c, i+1
            while j<=len and line:sub(j,j)~=q do if line:sub(j,j)=="\\" then j=j+1 end; j=j+1 end
            table.insert(out, span(line:sub(i,math.min(j,len)), SYN.STR)); i=j+1
        elseif c:match("%d") or (c=="." and line:sub(i+1,i+1):match("%d")) then
            local j=i
            while j<=len and line:sub(j,j):match("[%d%.xXa-fA-F_]") do j=j+1 end
            table.insert(out, span(line:sub(i,j-1), SYN.NUM)); i=j
        elseif c:match("[%a_]") then
            local j=i
            while j<=len and line:sub(j,j):match("[%w_]") do j=j+1 end
            local w=line:sub(i,j-1)
            table.insert(out, span(w, KW[w] and SYN.KW or BLT[w] and SYN.BLT or SYN.PL)); i=j
        elseif c:match("[%+%-%*%/%=%%<>~#%.%,%;%:%[%]%(%)%{%}]") then
            table.insert(out, span(c, SYN.OP)); i=i+1
        else
            local j=i
            while j<=len and line:sub(j,j):match("%s") do j=j+1 end
            table.insert(out, span(line:sub(i,j-1), SYN.PL)); i=j
        end
    end
    return table.concat(out)
end
local function highlight(code)
    local rows={}
    for _, ln in ipairs(code:split("\n")) do table.insert(rows, highlightLine(ln)) end
    return table.concat(rows,"\n")
end
local function countLines(s) local n=1; for _ in s:gmatch("\n") do n=n+1 end; return n end
local function gutterText(n)
    local rows={}
    for i=1,n do table.insert(rows, string.format('<font color="#%s">%3d</font>', SYN.CMT, i)) end
    return table.concat(rows,"\n")
end

-- ═══════════════════════════════════════════════════════════════════════════
--  INVISIBLE SCROLLBAR
-- ═══════════════════════════════════════════════════════════════════════════
local function makeScrollFrame(parent, size, pos, zIdx, canvasH)
    local sf = Instance.new("ScrollingFrame")
    sf.Size                   = size
    sf.Position               = pos
    sf.BackgroundTransparency = 1
    sf.BorderSizePixel        = 0
    sf.ScrollBarThickness     = 0          
    sf.CanvasSize             = UDim2.new(0, 0, 0, canvasH)
    sf.ScrollingDirection     = Enum.ScrollingDirection.Y
    sf.ScrollBarImageTransparency = 1
    sf.ElasticBehavior        = Enum.ElasticBehavior.WhenScrollable
    sf.ZIndex                 = zIdx
    sf.Parent                 = parent
    return sf
end

-- ═══════════════════════════════════════════════════════════════════════════
--  PANEL SYSTEM (Floating, Draggable, Clean Slate Style)
-- ═══════════════════════════════════════════════════════════════════════════
local dragOwner = nil
local function makePanelDraggable(pnl, bar, onMove)
    local dragging     = false
    local touchInput   = nil
    local dragStartM   = Vector2.zero
    local dragStartPos = UDim2.new()
    
    local function pointerPos()
        if touchInput then return Vector2.new(touchInput.Position.X, touchInput.Position.Y) end
        return UserInputService:GetMouseLocation()
    end
    
    bar.InputBegan:Connect(function(i)
        if dragging or (dragOwner ~= nil and dragOwner ~= pnl) then return end
        if i.UserInputType == Enum.UserInputType.MouseButton1 then
            touchInput = nil; dragStartM = UserInputService:GetMouseLocation()
            dragStartPos = pnl.Position; dragging = true; dragOwner = pnl
        elseif i.UserInputType == Enum.UserInputType.Touch then
            touchInput = i; dragStartM = Vector2.new(i.Position.X, i.Position.Y)
            dragStartPos = pnl.Position; dragging = true; dragOwner = pnl
        end
    end)
    
    UserInputService.InputEnded:Connect(function(i)
        if i == touchInput or i.UserInputType == Enum.UserInputType.MouseButton1 then
            if dragging then
                dragging = false; touchInput = nil
                if dragOwner == pnl then dragOwner = nil end
            end
        end
    end)
    
    RunService.RenderStepped:Connect(function()
        if not dragging then return end
        local d   = pointerPos() - dragStartM
        local cam = workspace.CurrentCamera
        local vp  = cam and cam.ViewportSize or Vector2.new(1280, 720)
        local ps  = pnl.AbsoluteSize
        local curPxX = dragStartPos.X.Offset + dragStartPos.X.Scale * vp.X
        local curPxY = dragStartPos.Y.Offset + dragStartPos.Y.Scale * vp.Y
        local anchorOffX = pnl.AnchorPoint.X * ps.X
        local anchorOffY = pnl.AnchorPoint.Y * ps.Y
        local newX = math.clamp(curPxX + d.X, anchorOffX, vp.X - ps.X + anchorOffX)
        local newY = math.clamp(curPxY + d.Y, anchorOffY, vp.Y - ps.Y + anchorOffY)
        local newPos = UDim2.new(0, newX, 0, newY)
        pnl.Position = newPos
        if onMove then onMove(newPos) end
    end)
end

local function makeFloatingPanel(parent, w, h, posX, posY)
    local pnl = Instance.new("Frame", parent)
    pnl.Size                   = UDim2.new(0, w, 0, h)
    pnl.AnchorPoint            = Vector2.new(0.5, 0.5)
    pnl.Position               = UDim2.new(posX, 0, posY, 0)
    pnl.BackgroundColor3       = C.PANEL
    pnl.BackgroundTransparency = 0
    pnl.BorderSizePixel        = 0
    pnl.ZIndex                 = 150
    pnl.Active                 = true
    pnl.Visible                = true
    pnl.ClipsDescendants       = true
    Instance.new("UICorner", pnl).CornerRadius = UDim.new(0, 10)

    local grad = Instance.new("UIGradient", pnl)
    grad.Color = ColorSequence.new({
        ColorSequenceKeypoint.new(0,   Color3.fromRGB(18, 20, 42)),
        ColorSequenceKeypoint.new(0.6, Color3.fromRGB(10, 12, 26)),
        ColorSequenceKeypoint.new(1,   Color3.fromRGB( 8, 10, 20)),
    })
    grad.Rotation = 130

    local pStroke = Instance.new("UIStroke", pnl)
    pStroke.Color = C.STROKE; pStroke.Thickness = 1
    pStroke.Transparency = 0.35; pStroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border

    return pnl
end

local function makePanelTitleBar(pnl, title, onClose, onMinimize)
    local bar = Instance.new("Frame", pnl)
    bar.Size = UDim2.new(1, 0, 0, 36); bar.BackgroundTransparency = 1
    bar.BorderSizePixel = 0; bar.ZIndex = 151

    local topLine = Instance.new("Frame", bar)
    topLine.Size = UDim2.new(0.55, 0, 0, 1); topLine.AnchorPoint = Vector2.new(0.5, 0)
    topLine.Position = UDim2.new(0.5, 0, 0, 0); topLine.BackgroundColor3 = C.ACCENT
    topLine.BorderSizePixel = 0; topLine.ZIndex = 152
    local tlGrad = Instance.new("UIGradient", topLine)
    tlGrad.Transparency = NumberSequence.new({
        NumberSequenceKeypoint.new(0, 1), NumberSequenceKeypoint.new(0.2, 0),
        NumberSequenceKeypoint.new(0.8, 0), NumberSequenceKeypoint.new(1, 1),
    })

    local lbl = Instance.new("TextLabel", bar)
    lbl.Text = title; lbl.Font = Enum.Font.GothamBold; lbl.TextSize = 12
    lbl.TextColor3 = C.TEXT; lbl.Position = UDim2.new(0, 14, 0, 0)
    lbl.Size = UDim2.new(1, -80, 1, 0); lbl.BackgroundTransparency = 1
    lbl.TextXAlignment = Enum.TextXAlignment.Left; lbl.ZIndex = 152
    local lblGrad = Instance.new("UIGradient", lbl)
    lblGrad.Color = ColorSequence.new(C.ACCENT, C.ACCENT2)
    lblGrad.Rotation = 0

    if onMinimize then
        local minBtn = Instance.new("TextButton", bar)
        minBtn.Text = "–"; minBtn.Size = UDim2.new(0, 22, 0, 22)
        minBtn.Position = UDim2.new(1, -54, 0.5, -11)
        minBtn.BackgroundTransparency = 1; minBtn.BorderSizePixel = 0
        minBtn.ZIndex = 153; minBtn.AutoButtonColor = false
        minBtn.Font = Enum.Font.GothamBold; minBtn.TextSize = 14
        minBtn.TextColor3 = C.DIM
        minBtn.MouseButton1Click:Connect(onMinimize)
        minBtn.MouseEnter:Connect(function() tw(minBtn, TweenInfo.new(0.15), {TextColor3 = C.TEXT}) end)
        minBtn.MouseLeave:Connect(function() tw(minBtn, TweenInfo.new(0.18), {TextColor3 = C.DIM}) end)
    end

    local closeBtn = Instance.new("TextButton", bar)
    closeBtn.Text = ""; closeBtn.Size = UDim2.new(0, 22, 0, 22)
    closeBtn.Position = UDim2.new(1, -28, 0.5, -11)
    closeBtn.BackgroundTransparency = 1; closeBtn.BorderSizePixel = 0
    closeBtn.ZIndex = 153; closeBtn.AutoButtonColor = false

    local closeIcon = Instance.new("ImageLabel", closeBtn)
    closeIcon.BackgroundTransparency = 1; closeIcon.Size = UDim2.new(0, 10, 0, 10)
    closeIcon.Position = UDim2.new(0.5, 0, 0.5, 0); closeIcon.AnchorPoint = Vector2.new(0.5, 0.5)
    closeIcon.Image = "rbxassetid://82927197777156"
    closeIcon.ImageColor3 = Color3.new(1, 1, 1); closeIcon.ImageTransparency = 0.5; closeIcon.ZIndex = 154

    closeBtn.MouseButton1Click:Connect(onClose)
    closeBtn.MouseEnter:Connect(function() tw(closeIcon, TweenInfo.new(0.15), {ImageTransparency = 0, ImageColor3 = C.DANGER}) end)
    closeBtn.MouseLeave:Connect(function() tw(closeIcon, TweenInfo.new(0.2), {ImageTransparency = 0.5, ImageColor3 = Color3.new(1,1,1)}) end)

    return bar
end

-- Forward declarations for command execution
local processCommand
local toggleHelp
local TITLE_BAR_H = 36

-- ═══════════════════════════════════════════════════════════════════════════
--  CMDS PANEL  (Floating Window)
-- ═══════════════════════════════════════════════════════════════════════════
local CMDS_W      = 420
local CMDS_ROW_H  = 38
local CMDS_BOT    = 12
local CMDS_MAX_H  = 320

local cmdsPanelOpen = false
local cmdsPanelSG   = nil

local function destroyCmdsPanel()
    if cmdsPanelSG and cmdsPanelSG.Parent then
        cmdsPanelSG:Destroy()
        cmdsPanelSG = nil
    end
    cmdsPanelOpen = false
end

local function openCmdsPanel()
    if cmdsPanelOpen then destroyCmdsPanel(); return end
    cmdsPanelOpen = true

    local names = listCmds()

    local pSG = Instance.new("ScreenGui")
    pSG.Name           = "Rikusu_CmdsPanel"
    pSG.ResetOnSpawn   = false
    pSG.IgnoreGuiInset = true
    pSG.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
    pcall(function() pSG.DisplayOrder = 10001 end)
    pSG.Parent = (rawget(_G,"gethui") and gethui()) or gui
    cmdsPanelSG = pSG

    local rowCount = math.max(#names, 1)
    local listH    = math.min(rowCount * CMDS_ROW_H + CMDS_BOT, CMDS_MAX_H)
    local totalH   = TITLE_BAR_H + listH

    local mainPanel = makeFloatingPanel(pSG, CMDS_W, totalH, 0.5, 0.5)
    local scl = Instance.new("UIScale", mainPanel)
    scl.Scale = 0.88

    local function close()
        tw(scl, TI.PopOut, { Scale = 0.88 })
        tw(mainPanel, TI.FadeOut, { BackgroundTransparency = 1 })
        task.delay(0.25, destroyCmdsPanel)
    end

    local isMinimized = false
    local topBar = makePanelTitleBar(
        mainPanel, 
        "Custom Commands  ·  " .. tostring(#names), 
        close, 
        function()
            isMinimized = not isMinimized
            tw(mainPanel, TweenInfo.new(0.3, ES.Quint, ED.Out), {Size = UDim2.new(0, CMDS_W, 0, isMinimized and TITLE_BAR_H or totalH)})
        end
    )
    makePanelDraggable(mainPanel, topBar)

    local contentArea = Instance.new("Frame", mainPanel)
    contentArea.BackgroundTransparency = 1
    contentArea.Position = UDim2.new(0, 0, 0, TITLE_BAR_H)
    -- FIX: Static pixel height protects against layout squishing when minimized!
    contentArea.Size = UDim2.new(1, 0, 0, listH)
    contentArea.ZIndex = 150

    local canvasH = #names * CMDS_ROW_H + CMDS_BOT
    local sf = makeScrollFrame(contentArea, UDim2.new(1,0,1,0), UDim2.new(0,0,0,0), 152, canvasH)

    if #names == 0 then
        local empty = Instance.new("TextLabel")
        empty.Size = UDim2.new(1,0,0,CMDS_ROW_H); empty.Position = UDim2.new(0,0,0,0)
        empty.BackgroundTransparency = 1; empty.Text = "No custom commands yet  ·  type  newcmd <name>"
        empty.Font = Enum.Font.Gotham; empty.TextSize = 11
        empty.TextColor3 = C.DIM; empty.ZIndex = 153; empty.Parent = sf
    else
        for idx, name in ipairs(names) do
            local y = (idx-1) * CMDS_ROW_H
            if idx > 1 then
                local div = Instance.new("Frame")
                div.Size = UDim2.new(1,-32,0,1); div.Position = UDim2.new(0,16,0,y)
                div.BackgroundColor3 = C.DIV; div.BorderSizePixel = 0
                div.ZIndex = 153; div.Parent = sf
            end

            local rowBg = Instance.new("TextButton")
            rowBg.Size = UDim2.new(1,0,0,CMDS_ROW_H); rowBg.Position = UDim2.new(0,0,0,y)
            rowBg.BackgroundColor3 = C.ACCENT; rowBg.BackgroundTransparency = 1
            rowBg.BorderSizePixel = 0; rowBg.Text = ""; rowBg.ZIndex = 153; rowBg.Parent = sf
            rowBg.MouseEnter:Connect(function() tw(rowBg, TI.Hover, { BackgroundTransparency = 0.90 }) end)
            rowBg.MouseLeave:Connect(function() tw(rowBg, TI.Hover, { BackgroundTransparency = 1 }) end)
            rowBg.MouseButton1Click:Connect(function()
                close()
                task.delay(0.22, function()
                    local existing = loadCmd(name)
                    if existing then _G.__rikusu_openEditor(name, existing) end
                end)
            end)

            local nameLbl = Instance.new("TextLabel")
            nameLbl.Size = UDim2.new(1,-100,0,CMDS_ROW_H); nameLbl.Position = UDim2.new(0,16,0,y)
            nameLbl.BackgroundTransparency = 1; nameLbl.Text = name
            nameLbl.Font = Enum.Font.RobotoMono; nameLbl.TextSize = 13
            nameLbl.TextColor3 = C.TEXT; nameLbl.TextXAlignment = Enum.TextXAlignment.Left
            nameLbl.ZIndex = 154; nameLbl.Parent = sf

            local editHint = Instance.new("TextLabel")
            editHint.Size = UDim2.new(0,80,0,CMDS_ROW_H); editHint.AnchorPoint = Vector2.new(1,0)
            editHint.Position = UDim2.new(1,-12,0,y); editHint.BackgroundTransparency = 1
            editHint.Text = "edit ›"; editHint.Font = Enum.Font.Gotham
            editHint.TextSize = 10; editHint.TextColor3 = C.DIM
            editHint.TextXAlignment = Enum.TextXAlignment.Right; editHint.ZIndex = 154
            editHint.Parent = sf
        end
    end

    tw(scl, TI.Pop,  { Scale = 1 })
    return close
end

-- ═══════════════════════════════════════════════════════════════════════════
--  CODE EDITOR POPUP (Floating Window)
-- ═══════════════════════════════════════════════════════════════════════════
local EDITOR_W  = 660
local EDITOR_H  = 458
local GUTTER_W  = 44
local FOOTER_H  = 48

local editorSG   = nil
local editorOpen = false

local function destroyEditor()
    if editorSG and editorSG.Parent then editorSG:Destroy(); editorSG = nil end
    editorOpen = false
end

local function openEditor(cmdName, existingCode, onSave)
    if editorOpen then destroyEditor() end
    editorOpen = true

    local defaultCode = table.concat({
        "-- Command: " .. cmdName,
        "-- Globals: lp, Players, workspace, game, task, args",
        "-- args[2], args[3]... are words typed after '" .. cmdName .. "'",
        "",
        "print(\"[" .. cmdName .. "] Hello!\")",
    }, "\n")

    local code = existingCode or defaultCode

    local eSG = Instance.new("ScreenGui")
    eSG.Name           = "Rikusu_Editor"
    eSG.ResetOnSpawn   = false
    eSG.IgnoreGuiInset = true
    eSG.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
    pcall(function() eSG.DisplayOrder = 10002 end)
    eSG.Parent = (rawget(_G,"gethui") and gethui()) or gui
    editorSG = eSG

    local mainPanel = makeFloatingPanel(eSG, EDITOR_W, EDITOR_H, 0.5, 0.5)
    local eScl = Instance.new("UIScale", mainPanel)
    eScl.Scale = 0.88

    local function closeE()
        tw(eScl, TI.PopOut, { Scale = 0.88 })
        tw(mainPanel, TI.FadeOut, { BackgroundTransparency = 1 })
        task.delay(0.22, destroyEditor)
    end

    local isMinimized = false
    local topBar = makePanelTitleBar(
        mainPanel, 
        cmdName .. ".lua", 
        closeE,
        function()
            isMinimized = not isMinimized
            tw(mainPanel, TweenInfo.new(0.3, ES.Quint, ED.Out), {Size = UDim2.new(0, EDITOR_W, 0, isMinimized and TITLE_BAR_H or EDITOR_H)})
        end
    )
    makePanelDraggable(mainPanel, topBar)

    local contentArea = Instance.new("Frame", mainPanel)
    contentArea.BackgroundTransparency = 1; contentArea.Position = UDim2.new(0, 0, 0, TITLE_BAR_H)
    -- FIX: Static pixel height protects the footer from being pushed up when mainPanel shrinks height!
    contentArea.Size = UDim2.new(1, 0, 0, EDITOR_H - TITLE_BAR_H); contentArea.ZIndex = 150

    local codeArea = Instance.new("Frame", contentArea)
    codeArea.Size = UDim2.new(1,0,1,-FOOTER_H); codeArea.Position = UDim2.new(0,0,0,0)
    codeArea.BackgroundColor3 = Color3.fromRGB(11,13,24); codeArea.BorderSizePixel = 0
    codeArea.ClipsDescendants = true; codeArea.ZIndex = 151

    local gutter = Instance.new("Frame", codeArea)
    gutter.Size = UDim2.new(0,GUTTER_W,1,0); gutter.BackgroundColor3 = Color3.fromRGB(16,20,36)
    gutter.BorderSizePixel = 0; gutter.ZIndex = 152

    local gutterBorder = Instance.new("Frame", gutter)
    gutterBorder.Size = UDim2.new(0,1,1,0); gutterBorder.Position = UDim2.new(1,-1,0,0)
    gutterBorder.BackgroundColor3 = C.STROKE; gutterBorder.BackgroundTransparency = 0.65
    gutterBorder.BorderSizePixel = 0; gutterBorder.ZIndex = 153

    local gutterLbl = Instance.new("TextLabel", gutter)
    gutterLbl.Size = UDim2.new(1,-8,1,0); gutterLbl.Position = UDim2.new(0,0,0,6)
    gutterLbl.BackgroundTransparency = 1; gutterLbl.Text = gutterText(countLines(code))
    gutterLbl.Font = Enum.Font.RobotoMono; gutterLbl.TextSize = 12
    gutterLbl.TextColor3 = C.DIM2; gutterLbl.TextXAlignment = Enum.TextXAlignment.Right
    gutterLbl.TextYAlignment = Enum.TextYAlignment.Top; gutterLbl.RichText = true; gutterLbl.ZIndex = 154

    local hlLbl = Instance.new("TextLabel", codeArea)
    hlLbl.Size = UDim2.new(1,-(GUTTER_W+12),1,0); hlLbl.Position = UDim2.new(0,GUTTER_W+10,0,6)
    hlLbl.BackgroundTransparency = 1; hlLbl.Text = highlight(code)
    hlLbl.Font = Enum.Font.RobotoMono; hlLbl.TextSize = 12
    hlLbl.TextColor3 = C.TEXT; hlLbl.TextXAlignment = Enum.TextXAlignment.Left
    hlLbl.TextYAlignment = Enum.TextYAlignment.Top; hlLbl.RichText = true; hlLbl.ZIndex = 153

    local codeBox = Instance.new("TextBox", codeArea)
    codeBox.Size = UDim2.new(1,-(GUTTER_W+12),1,0); codeBox.Position = UDim2.new(0,GUTTER_W+10,0,6)
    codeBox.BackgroundTransparency = 1; codeBox.Text = code
    codeBox.Font = Enum.Font.RobotoMono; codeBox.TextSize = 12
    codeBox.TextColor3 = Color3.fromRGB(0,0,0); codeBox.TextTransparency = 0.999
    codeBox.TextXAlignment = Enum.TextXAlignment.Left; codeBox.TextYAlignment = Enum.TextYAlignment.Top
    codeBox.MultiLine = true; codeBox.ClearTextOnFocus = false; codeBox.ZIndex = 155

    codeBox:GetPropertyChangedSignal("Text"):Connect(function()
        local t = codeBox.Text
        hlLbl.Text = highlight(t)
        gutterLbl.Text = gutterText(countLines(t))
    end)

    local foot = Instance.new("Frame", contentArea)
    foot.Size = UDim2.new(1,0,0,FOOTER_H); foot.Position = UDim2.new(0,0,1,-FOOTER_H)
    foot.BackgroundColor3 = C.BG2; foot.BorderSizePixel = 0; foot.ZIndex = 151
    
    local fill = Instance.new("Frame", foot)
    fill.Size = UDim2.new(1,0,0,16); fill.BackgroundColor3 = C.BG2
    fill.BorderSizePixel = 0; fill.ZIndex = 151
    Instance.new("UICorner",foot).CornerRadius = UDim.new(0,10)

    local statusLbl = Instance.new("TextLabel", foot)
    statusLbl.Size = UDim2.new(1,-145,1,0); statusLbl.Position = UDim2.new(0,16,0,0)
    statusLbl.BackgroundTransparency = 1; statusLbl.Text = "Ctrl + S  to save"
    statusLbl.Font = Enum.Font.Gotham; statusLbl.TextSize = 11
    statusLbl.TextColor3 = C.DIM2; statusLbl.TextXAlignment = Enum.TextXAlignment.Left
    statusLbl.ZIndex = 153

    local function setStatus(msg, col, autoClear)
        statusLbl.Text = msg; statusLbl.TextColor3 = col or C.DIM2
        if autoClear then
            task.delay(2.8, function()
                if statusLbl and statusLbl.Parent then
                    statusLbl.Text = "Ctrl + S  to save"; statusLbl.TextColor3 = C.DIM2
                end
            end)
        end
    end

    local saveBtn = Instance.new("TextButton", foot)
    saveBtn.Size = UDim2.new(0,108,0,30); saveBtn.AnchorPoint = Vector2.new(1,0.5)
    saveBtn.Position = UDim2.new(1,-12,0.5,0); saveBtn.BackgroundColor3 = C.ACTION
    saveBtn.BorderSizePixel = 0; saveBtn.Text = "Save"
    saveBtn.Font = Enum.Font.GothamBold; saveBtn.TextSize = 12
    saveBtn.TextColor3 = Color3.fromRGB(4,8,18); saveBtn.ZIndex = 153
    Instance.new("UICorner",saveBtn).CornerRadius = UDim.new(0,8)
    saveBtn.MouseEnter:Connect(function() tw(saveBtn,TI.Hover,{BackgroundColor3=Color3.fromRGB(135,205,255)}) end)
    saveBtn.MouseLeave:Connect(function() tw(saveBtn,TI.Hover,{BackgroundColor3=C.ACTION}) end)

    local function doSave()
        local src = codeBox.Text
        local fn, err = loadstring(src)
        if fn then
            saveCmd(cmdName, src)
            if onSave then onSave(cmdName, src) end
            setStatus("✓  Saved — '" .. cmdName .. "' is ready", C.ON, true)
        else
            local short = tostring(err):match(":(%d+:.+)") or tostring(err)
            setStatus("✗  " .. short, C.OFF, true)
        end
    end

    saveBtn.MouseButton1Click:Connect(doSave)

    local ctrlConn
    ctrlConn = UserInputService.InputBegan:Connect(function(inp, ate)
        if ate then return end
        if inp.KeyCode == Enum.KeyCode.S and UserInputService:IsKeyDown(Enum.KeyCode.LeftControl) then
            doSave()
        end
        if inp.KeyCode == Enum.KeyCode.Escape then closeE() end
    end)
    
    eSG.Destroying:Connect(function() if ctrlConn then ctrlConn:Disconnect() end end)

    tw(eScl, TI.Pop, { Scale = 1 })
    task.delay(0.1, function()
        if codeBox and codeBox.Parent then codeBox:CaptureFocus() end
    end)
end

_G.__rikusu_openEditor = function(name, existing)
    openEditor(name, existing, function(n, src)
        customCmdRegistry[n:lower()] = { name = n, code = src }
    end)
end

-- ═══════════════════════════════════════════════════════════════════════════
--  HELP PANEL  (Floating Window, Scrollable, Clickable, Auto-updating)
-- ═══════════════════════════════════════════════════════════════════════════
local HELP_ROW_H = 31
local HELP_BOT   = 10
local HELP_W     = 420
local HELP_MAX_H = 400

local BUILTIN_CMDS = {
    { cmd="fly [speed]",    desc="Enable flight  (default 50)",  hi=false },
    { cmd="unfly",          desc="Disable flight",               hi=false },
    { cmd="noclip",         desc="Walk through walls",           hi=false },
    { cmd="clip",           desc="Re-enable collision",          hi=false },
    { cmd="speed [n]",      desc="Set walk speed",               hi=false },
    { cmd="jump [n]",       desc="Set jump power",               hi=false },
    { cmd="reset",          desc="Kill your character",          hi=false },
    { cmd="rejoin",         desc="Rejoin current server",        hi=false },
    { cmd="reanim",         desc="Load Reanim script",           hi=false },
    { cmd="newcmd <name>",  desc="Create a custom command",      hi=true  },
    { cmd="editcmd <name>", desc="Edit an existing custom cmd",  hi=true  },
    { cmd="delcmd <name>",  desc="Delete a custom command",      hi=true  },
    { cmd="cmds",           desc="Browse custom commands",       hi=true  },
    { cmd="help",           desc="Toggle this panel",            hi=false },
}

local helpOpen = false
local helpSG = nil

local function destroyHelpPanel()
    if helpSG and helpSG.Parent then helpSG:Destroy(); helpSG = nil end
    helpOpen = false
end

-- Must pre-declare since they share calls
local cmdInput 

function toggleHelp()
    if helpOpen then destroyHelpPanel(); return end
    helpOpen = true

    local hSG = Instance.new("ScreenGui")
    hSG.Name           = "Rikusu_HelpPanel"
    hSG.ResetOnSpawn   = false
    hSG.IgnoreGuiInset = true
    hSG.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
    pcall(function() hSG.DisplayOrder = 10000 end)
    hSG.Parent = (rawget(_G,"gethui") and gethui()) or gui
    helpSG = hSG

    -- Collect Built-in + Custom commands
    local allCmds = {}
    for _, c in ipairs(BUILTIN_CMDS) do
        table.insert(allCmds, { cmd = c.cmd, desc = c.desc, hi = c.hi, isCustom = false })
    end
    for _, n in ipairs(listCmds()) do
        table.insert(allCmds, { cmd = n, desc = "Custom command", hi = false, isCustom = true })
    end

    local listH        = #allCmds * HELP_ROW_H + HELP_BOT
    local visibleListH = math.min(listH, HELP_MAX_H)
    local totalH       = TITLE_BAR_H + visibleListH

    local mainPanel = makeFloatingPanel(hSG, HELP_W, totalH, 0.5, 0.5)
    local scl = Instance.new("UIScale", mainPanel)
    scl.Scale = 0.88

    local function closeHelp()
        tw(scl, TI.PopOut, { Scale = 0.88 })
        tw(mainPanel, TI.FadeOut, { BackgroundTransparency = 1 })
        task.delay(0.25, destroyHelpPanel)
    end

    local isMinimized = false
    local topBar = makePanelTitleBar(
        mainPanel, 
        "Help & Commands", 
        closeHelp, 
        function()
            isMinimized = not isMinimized
            tw(mainPanel, TweenInfo.new(0.3, ES.Quint, ED.Out), {Size = UDim2.new(0, HELP_W, 0, isMinimized and TITLE_BAR_H or totalH)})
        end
    )
    makePanelDraggable(mainPanel, topBar)

    -- Command Count Pill (Centered in Title Bar)
    local pill = Instance.new("Frame", topBar)
    pill.Size = UDim2.new(0, 96, 0, 20)
    pill.Position = UDim2.new(0.5, 0, 0.5, 0)
    pill.AnchorPoint = Vector2.new(0.5, 0.5)
    pill.BackgroundColor3 = C.CARD
    pill.BorderSizePixel = 0
    Instance.new("UICorner", pill).CornerRadius = UDim.new(1, 0)
    
    local pillStr = Instance.new("UIStroke", pill)
    pillStr.Color = C.STROKE; pillStr.Transparency = 0.5
    
    local pillTxt = Instance.new("TextLabel", pill)
    pillTxt.Size = UDim2.new(1, 0, 1, 0)
    pillTxt.BackgroundTransparency = 1
    pillTxt.Text = tostring(#allCmds) .. " Commands"
    pillTxt.Font = Enum.Font.GothamMedium
    pillTxt.TextSize = 10
    pillTxt.TextColor3 = C.TEXT
    pillTxt.ZIndex = 155

    local contentArea = Instance.new("Frame", mainPanel)
    contentArea.BackgroundTransparency = 1
    contentArea.Position = UDim2.new(0, 0, 0, TITLE_BAR_H)
    -- Static pixel height ensures clean clipping!
    contentArea.Size = UDim2.new(1, 0, 0, visibleListH)
    contentArea.ZIndex = 150

    local sf = makeScrollFrame(contentArea, UDim2.new(1,0,1,0), UDim2.new(0,0,0,0), 152, listH)

    for i, entry in ipairs(allCmds) do
        local y = (i-1)*HELP_ROW_H

        if i > 1 then
            local div = Instance.new("Frame", sf)
            div.Size = UDim2.new(1,-32,0,1); div.Position = UDim2.new(0,16,0,y)
            div.BackgroundColor3 = C.DIV; div.BorderSizePixel = 0; div.ZIndex = 153
        end

        -- Clickable Row Background
        local rowBg = Instance.new("TextButton", sf)
        rowBg.Size = UDim2.new(1,0,0,HELP_ROW_H); rowBg.Position = UDim2.new(0,0,0,y)
        rowBg.BackgroundColor3 = C.ACCENT; rowBg.BackgroundTransparency = 1
        rowBg.BorderSizePixel = 0; rowBg.Text = ""; rowBg.ZIndex = 153
        
        rowBg.MouseEnter:Connect(function() tw(rowBg, TI.Hover, { BackgroundTransparency = 0.92 }) end)
        rowBg.MouseLeave:Connect(function() tw(rowBg, TI.Hover, { BackgroundTransparency = 1 }) end)

        rowBg.MouseButton1Click:Connect(function()
            local base = entry.cmd:split(" ")[1]
            local hasArgs = entry.cmd:find("<") or entry.cmd:find("%[")
            
            -- If it needs args, prep the input bar for typing
            if hasArgs and not entry.isCustom then
                if cmdInput and cmdInput.Parent then
                    cmdInput.Text = base .. " "
                    cmdInput:CaptureFocus()
                end
            else
                -- Otherwise instantly process the base command
                processCommand(base)
            end
        end)

        local lc = Instance.new("TextLabel", sf)
        lc.Size = UDim2.new(0,160,0,HELP_ROW_H-1); lc.Position = UDim2.new(0,16,0,y+2)
        lc.BackgroundTransparency = 1; lc.Text = entry.cmd
        lc.Font = Enum.Font.RobotoMono; lc.TextSize = 12
        lc.TextColor3 = entry.hi and C.WARN or C.ACCENT; lc.TextXAlignment = Enum.TextXAlignment.Left
        lc.ZIndex = 154

        local ld = Instance.new("TextLabel", sf)
        ld.Size = UDim2.new(1,-180,0,HELP_ROW_H-1); ld.Position = UDim2.new(0,176,0,y+2)
        ld.BackgroundTransparency = 1; ld.Text = entry.desc
        ld.Font = Enum.Font.Gotham; ld.TextSize = 11
        ld.TextColor3 = entry.isCustom and C.ACCENT2 or C.DIM; ld.TextXAlignment = Enum.TextXAlignment.Left
        ld.ZIndex = 154
    end

    tw(scl, TI.Pop, { Scale = 1 })
end

-- ═══════════════════════════════════════════════════════════════════════════
--  COMMAND BAR UI
-- ═══════════════════════════════════════════════════════════════════════════
local BAR_W  = 580
local BAR_H  = 54

local wrapper = Instance.new("Frame")
wrapper.Size            = UDim2.new(0,BAR_W,0,BAR_H)
wrapper.AnchorPoint     = Vector2.new(0.5,0.5)
wrapper.Position        = UDim2.new(0.5,0,0.85,0)
wrapper.BackgroundTransparency = 1
wrapper.ZIndex          = 10
wrapper.Parent          = sg

local barScale = Instance.new("UIScale")
barScale.Scale  = 0.82
barScale.Parent = wrapper

local bar = Instance.new("CanvasGroup")
bar.Size              = UDim2.new(1,0,1,0)
bar.BackgroundColor3  = C.BG
bar.BorderSizePixel   = 0
bar.ClipsDescendants  = true
bar.GroupTransparency = 1
bar.ZIndex            = 10
bar.Parent            = wrapper
Instance.new("UICorner",bar).CornerRadius = UDim.new(0,14)

local borderStroke = Instance.new("UIStroke")
borderStroke.Color          = C.STROKE
borderStroke.Thickness      = 1
borderStroke.Transparency   = 0.28
borderStroke.ApplyStrokeMode= Enum.ApplyStrokeMode.Border
borderStroke.Parent         = bar

-- water shimmer
local water = Instance.new("Frame")
water.Size                  = UDim2.new(1,0,0.5,0)
water.Position              = UDim2.new(0,0,0.5,0)
water.BackgroundColor3      = Color3.fromRGB(8,10,18)
water.BackgroundTransparency= 0.78
water.BorderSizePixel       = 0
water.ZIndex                = 11
water.Parent                = bar
do
    local g = Instance.new("UIGradient")
    g.Rotation = 90
    g.Color = ColorSequence.new({
        ColorSequenceKeypoint.new(0,Color3.fromRGB(35,42,70)),
        ColorSequenceKeypoint.new(1,Color3.fromRGB(10,12,22)),
    })
    g.Transparency = NumberSequence.new({
        NumberSequenceKeypoint.new(0,0.80),
        NumberSequenceKeypoint.new(1,0.55),
    })
    g.Parent = water
end

local refl = Instance.new("Frame")
refl.Size                   = UDim2.new(1,0,0.5,0)
refl.Position               = UDim2.new(0,0,0.5,0)
refl.BackgroundColor3       = Color3.fromRGB(60,70,95)
refl.BackgroundTransparency = 0.93
refl.BorderSizePixel        = 0
refl.ZIndex                 = 11
refl.Parent                 = bar
Instance.new("UICorner",refl).CornerRadius = UDim.new(0,14)

local reflGrad = Instance.new("UIGradient")
reflGrad.Rotation = 90
reflGrad.Color = ColorSequence.new({
    ColorSequenceKeypoint.new(0,Color3.fromRGB(120,130,170)),
    ColorSequenceKeypoint.new(1,Color3.fromRGB(20,24,34)),
})
reflGrad.Transparency = NumberSequence.new({
    NumberSequenceKeypoint.new(0,0.92),
    NumberSequenceKeypoint.new(1,1),
})
reflGrad.Parent = refl

local ash = {}
for i = 1, 20 do
    local p = Instance.new("Frame")
    p.AnchorPoint            = Vector2.new(0.5,0.5)
    p.Size                   = UDim2.new(0,math.random(2,3),0,math.random(2,3))
    p.BackgroundColor3       = C.ASH2
    p.BackgroundTransparency = 1
    p.BorderSizePixel        = 0
    p.ZIndex                 = 12
    p.Parent                 = bar
    Instance.new("UICorner",p).CornerRadius = UDim.new(1,0)
    ash[i] = {
        obj=p, sx=math.random(5,95)/100, sy=math.random(20,95)/100,
        drift=math.random(-10,10)/100, rise=math.random(20,60)/100,
        speed=math.random(10,20)/10, phase=math.random()*math.pi*2, delay=math.random()*2.0,
    }
end

local t0 = tick()
local ambientConn = RunService.Heartbeat:Connect(function()
    local t = tick()-t0
    for _, a in ipairs(ash) do
        local life = ((t+a.delay)%3.0)/3.0
        local rise = math.sin(life*math.pi)
        local x    = a.sx + math.sin(t*a.speed+a.phase)*0.01 + a.drift*life
        local y    = a.sy - a.rise*life
        local fade
        if    life < 0.15 then fade = 1-(life/0.15)
        elseif life > 0.85 then fade = (life-0.85)/0.15
        else                     fade = 0.1 end
        local tint = 1-rise*0.35
        a.obj.Position = UDim2.new(x,0,y,0)
        a.obj.BackgroundColor3 = Color3.new(
            math.clamp(C.ASH1.R*tint+C.ASH3.R*(1-tint),0,1),
            math.clamp(C.ASH1.G*tint+C.ASH3.G*(1-tint),0,1),
            math.clamp(C.ASH1.B*tint+C.ASH3.B*(1-tint),0,1)
        )
        a.obj.BackgroundTransparency = math.clamp(fade+0.10,0,1)
    end
    water.BackgroundTransparency = 0.78+math.sin(t*1.8)*0.03
    refl.BackgroundTransparency  = 0.94+math.sin(t*2.1)*0.015
    reflGrad.Rotation            = 90 +math.sin(t*0.7)*2
end)

local prefix = Instance.new("TextLabel")
prefix.Size               = UDim2.new(0,30,1,0)
prefix.Position           = UDim2.new(0,16,0,0)
prefix.BackgroundTransparency = 1
prefix.Text               = ">_"
prefix.Font               = Enum.Font.RobotoMono
prefix.TextSize           = 14
prefix.TextColor3         = C.ACCENT
prefix.TextXAlignment     = Enum.TextXAlignment.Left
prefix.ZIndex             = 20
prefix.Parent             = bar

cmdInput = Instance.new("TextBox")
cmdInput.Size             = UDim2.new(1,-100,1,0)
cmdInput.Position         = UDim2.new(0,46,0,0)
cmdInput.BackgroundTransparency = 1
cmdInput.Text             = ""
cmdInput.PlaceholderText  = "enter command  ·  help for list  ·  cmds to browse"
cmdInput.Font             = Enum.Font.RobotoMono
cmdInput.TextSize         = 13
cmdInput.TextColor3       = C.TEXT
cmdInput.PlaceholderColor3= C.DIM
cmdInput.TextXAlignment   = Enum.TextXAlignment.Left
cmdInput.ClearTextOnFocus = false
cmdInput.ZIndex           = 21
cmdInput.Parent           = bar

local closeBtn = Instance.new("TextButton")
closeBtn.Size             = UDim2.new(0,BAR_H,0,BAR_H)
closeBtn.AnchorPoint      = Vector2.new(1,0)
closeBtn.Position         = UDim2.new(1,0,0,0)
closeBtn.BackgroundTransparency = 1
closeBtn.Text             = "x"
closeBtn.Font             = Enum.Font.GothamBold
closeBtn.TextSize         = 11
closeBtn.TextColor3       = C.DIM
closeBtn.ZIndex           = 22
closeBtn.Parent           = bar
closeBtn.MouseEnter:Connect(function() tw(closeBtn,TI.Hover,{TextColor3=C.OFF}) end)
closeBtn.MouseLeave:Connect(function() tw(closeBtn,TI.Hover,{TextColor3=C.DIM}) end)

local function flashBorder(ok)
    tw(borderStroke, TI.Flash, { Color=ok and C.ON or C.OFF, Transparency=0 })
    task.delay(0.55, function()
        if bar and bar.Parent then
            tw(borderStroke, TI.Fade, { Color=C.STROKE, Transparency=0.28 })
        end
    end)
end

-- ═══════════════════════════════════════════════════════════════════════════
--  COMMAND LOGIC ENGINE
-- ═══════════════════════════════════════════════════════════════════════════
local noclipCon = nil
local flyVel, flyGyro, flyConn

local function stopFlight()
    if flyConn then flyConn:Disconnect(); flyConn=nil end
    if flyVel  then flyVel:Destroy();     flyVel=nil  end
    if flyGyro then flyGyro:Destroy();    flyGyro=nil end
    local hum = lp.Character and lp.Character:FindFirstChildOfClass("Humanoid")
    if hum then hum.PlatformStand = false end
end

customCmdRegistry = {}
do
    for _, name in ipairs(listCmds()) do
        local code = loadCmd(name)
        if code then customCmdRegistry[name:lower()] = { name=name, code=code } end
    end
end

-- Primary Execution Node
function processCommand(txt)
    local args = txt:split(" ")
    local cmd  = args[1]:lower()
    local ok   = true

    if cmd == "help" then
        toggleHelp()

    elseif cmd == "newcmd" then
        local name = args[2]
        if name and name ~= "" then
            openEditor(name, nil, function(n, src)
                customCmdRegistry[n:lower()] = { name=n, code=src }
            end)
        else
            ok = false
        end

    elseif cmd == "editcmd" then
        local name = args[2]
        local existing = name and loadCmd(name)
        if existing then
            openEditor(name, existing, function(n, src)
                customCmdRegistry[n:lower()] = { name=n, code=src }
            end)
        else
            ok = false
        end

    elseif cmd == "delcmd" then
        local name = args[2]
        if name and deleteCmd(name) then
            customCmdRegistry[name:lower()] = nil
        else
            ok = false
        end

    elseif cmd == "cmds" then
        openCmdsPanel()

    elseif cmd == "fly" then
        local speed = tonumber(args[2]) or 50
        local hrp   = lp.Character and lp.Character:FindFirstChild("HumanoidRootPart")
        if hrp then
            stopFlight()
            flyGyro           = Instance.new("BodyGyro",hrp)
            flyGyro.P         = 9e4
            flyGyro.MaxTorque = Vector3.new(9e9,9e9,9e9)
            flyGyro.CFrame    = hrp.CFrame
            flyVel            = Instance.new("BodyVelocity",hrp)
            flyVel.Velocity   = Vector3.new(0,0,0)
            flyVel.MaxForce   = Vector3.new(9e9,9e9,9e9)
            local hum = lp.Character:FindFirstChildOfClass("Humanoid")
            if hum then hum.PlatformStand = true end
            flyConn = RunService.RenderStepped:Connect(function()
                local cam = workspace.CurrentCamera
                local dir = Vector3.new()
                if UserInputService:IsKeyDown(Enum.KeyCode.W)         then dir+=cam.CFrame.LookVector  end
                if UserInputService:IsKeyDown(Enum.KeyCode.S)         then dir-=cam.CFrame.LookVector  end
                if UserInputService:IsKeyDown(Enum.KeyCode.A)         then dir-=cam.CFrame.RightVector end
                if UserInputService:IsKeyDown(Enum.KeyCode.D)         then dir+=cam.CFrame.RightVector end
                if UserInputService:IsKeyDown(Enum.KeyCode.Space)     then dir+=Vector3.new(0,1,0)     end
                if UserInputService:IsKeyDown(Enum.KeyCode.LeftShift) then dir-=Vector3.new(0,1,0)     end
                flyVel.Velocity = (dir.Magnitude>0 and dir.Unit or dir)*speed
                flyGyro.CFrame  = cam.CFrame
            end)
        else ok=false end

    elseif cmd == "unfly" then
        stopFlight()

    elseif cmd == "noclip" then
        if noclipCon then noclipCon:Disconnect() end
        noclipCon = RunService.Stepped:Connect(function()
            if lp.Character then
                for _, p in ipairs(lp.Character:GetDescendants()) do
                    if p:IsA("BasePart") then p.CanCollide=false end
                end
            end
        end)

    elseif cmd == "clip" then
        if noclipCon then noclipCon:Disconnect(); noclipCon=nil end

    elseif cmd == "speed" then
        local n   = tonumber(args[2])
        local hum = lp.Character and lp.Character:FindFirstChildOfClass("Humanoid")
        if n and hum then hum.WalkSpeed=n else ok=false end

    elseif cmd == "jump" then
        local n   = tonumber(args[2])
        local hum = lp.Character and lp.Character:FindFirstChildOfClass("Humanoid")
        if n and hum then
            hum.UseJumpPower=true; hum.JumpPower=n
        else ok=false end

    elseif cmd == "reset" then
        local hum = lp.Character and lp.Character:FindFirstChildOfClass("Humanoid")
        if hum then hum.Health=0 else ok=false end

    elseif cmd == "rejoin" then
        TeleportService:TeleportToPlaceInstance(game.PlaceId, game.JobId, lp)

    elseif cmd == "reanim" then
        local s = pcall(function()
            loadstring(game:HttpGet("https://raw.githubusercontent.com/LostZenom/inject/refs/heads/main/Reanim.lua"))()
        end)
        if not s then ok=false end

    else
        local entry = customCmdRegistry[cmd]
        if entry then
            local fn, loadErr = loadstring(entry.code)
            if fn then
                local env = setmetatable({
                    args=args, lp=lp,
                    Players=Players, workspace=workspace,
                    game=game, print=print, warn=warn,
                    task=task, wait=wait,
                }, { __index=getfenv() })
                setfenv(fn, env)
                local ran, runErr = pcall(fn)
                if not ran then
                    warn("[RIKUSU] '" .. entry.name .. "' error: " .. tostring(runErr))
                    ok=false
                end
            else
                warn("[RIKUSU] '" .. entry.name .. "' load error: " .. tostring(loadErr))
                ok=false
            end
        else
            ok=false
        end
    end

    flashBorder(ok)
end

-- Input Hook
cmdInput.FocusLost:Connect(function(entered)
    if not entered then return end
    local txt = cmdInput.Text:match("^%s*(.-)%s*$")
    if txt == "" then return end
    cmdInput.Text = ""
    
    processCommand(txt)
    
    task.delay(0.02, function()
        if cmdInput and cmdInput.Parent then cmdInput:CaptureFocus() end
    end)
end)

-- ═══════════════════════════════════════════════════════════════════════════
--  OPEN ANIMATION & CLOSE HOOK
-- ═══════════════════════════════════════════════════════════════════════════
tw(bar,      TI.Fade, { GroupTransparency=0 })
tw(barScale, TI.Pop,  { Scale=1 })
task.delay(0.14, function() cmdInput:CaptureFocus() end)

local closing = false
closeBtn.MouseButton1Click:Connect(function()
    if closing then return end
    closing = true

    if helpOpen      then destroyHelpPanel() end
    if cmdsPanelOpen then destroyCmdsPanel() end
    if editorOpen    then destroyEditor()    end
    if ambientConn   then ambientConn:Disconnect() end
    stopFlight()
    if noclipCon     then noclipCon:Disconnect(); noclipCon=nil end

    tw(bar,      TI.FadeOut, { GroupTransparency=1 })
    local pop = TweenService:Create(barScale, TI.PopOut, { Scale=0.82 })
    pop:Play()
    pop.Completed:Connect(function()
        if sg and sg.Parent then sg:Destroy() end
    end)
end)
