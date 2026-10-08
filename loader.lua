-- Mount RNG: raport diagnostikues i strukturës së ngarkuar në klient.
-- Ky skedar është kontrollues diagnostikues. Auto-farm kërkon përshtatje me lojën.
-- Nuk shkarkon kod, nuk lexon Script.Source dhe nuk thërret RemoteEvent/RemoteFunction.
-- Nuk është testuar brenda Mount RNG ose Xeno.
-- Kopjo të gjithë tekstin në një mjedis klienti Luau dhe ekzekutoje.
-- Alternativa Studio: LocalScript në StarterPlayer > StarterPlayerScripts, pastaj Play.

local Players = game:GetService("Players")
local Storage = game:GetService("ReplicatedStorage")
local player = Players.LocalPlayer
assert(player, "Ky kontrollues kërkon ekzekutim në klient.")
local playerGui = player:WaitForChild("PlayerGui", 15)
assert(playerGui, "PlayerGui nuk u ngarkua. Provo pasi personazhi të jetë në lojë.")

local function make(className, properties, parent)
    local object = Instance.new(className)
    for key, value in pairs(properties) do object[key] = value end
    object.Parent = parent
    return object
end

local gui = make("ScreenGui", {
    Name = "MountRNG_Structure_Report",
    ResetOnSpawn = false,
    DisplayOrder = 20,
    ZIndexBehavior = Enum.ZIndexBehavior.Sibling,
}, playerGui)
local frame = make("Frame", {
    AnchorPoint = Vector2.new(0.5, 0.5),
    Position = UDim2.fromScale(0.5, 0.5),
    Size = UDim2.fromScale(0.9, 0.8),
    BackgroundColor3 = Color3.fromRGB(20, 25, 35),
    BorderSizePixel = 0,
}, gui)
make("TextLabel", {
    Position = UDim2.fromOffset(12, 8),
    Size = UDim2.new(1, -24, 0, 25),
    BackgroundTransparency = 1,
    Font = Enum.Font.GothamBold,
    TextSize = 18,
    TextColor3 = Color3.fromRGB(235, 240, 250),
    TextXAlignment = Enum.TextXAlignment.Left,
    Text = "Mount RNG | Kontrolluesi i strukturës",
}, frame)
local status = make("TextLabel", {
    Position = UDim2.fromOffset(12, 36),
    Size = UDim2.new(1, -24, 0, 32),
    BackgroundTransparency = 1,
    TextColor3 = Color3.fromRGB(150, 195, 235),
    TextSize = 14,
    TextWrapped = true,
    TextXAlignment = Enum.TextXAlignment.Left,
    Text = "Duke lexuar objektet e ngarkuara…",
}, frame)
local scroll = make("ScrollingFrame", {
    Position = UDim2.fromOffset(12, 74),
    Size = UDim2.new(1, -24, 1, -132),
    BackgroundColor3 = Color3.fromRGB(12, 16, 24),
    BorderSizePixel = 0,
    ScrollBarThickness = 8,
    CanvasSize = UDim2.fromOffset(1800, 100),
}, frame)
local box = make("TextBox", {
    Position = UDim2.fromOffset(8, 8),
    Size = UDim2.fromOffset(1780, 100),
    BackgroundTransparency = 1,
    ClearTextOnFocus = false,
    MultiLine = true,
    TextWrapped = false,
    TextXAlignment = Enum.TextXAlignment.Left,
    TextYAlignment = Enum.TextYAlignment.Top,
    Font = Enum.Font.Code,
    TextSize = 14,
    TextColor3 = Color3.fromRGB(220, 235, 245),
    Text = "Po përgatitet raporti…",
}, scroll)

local function button(label, x)
    return make("TextButton", {
        Position = UDim2.new(x, 8, 1, -46),
        Size = UDim2.new(0.333, -16, 0, 34),
        BackgroundColor3 = Color3.fromRGB(43, 70, 100),
        TextColor3 = Color3.new(1, 1, 1),
        Font = Enum.Font.Gotham,
        TextSize = 13,
        TextWrapped = true,
        Text = label,
    }, frame)
end
local selectButton = button("PËRZGJIDH TEKSTIN", 0)
local rescanButton = button("SKANO SËRISH", 0.333)
local closeButton = button("MBYLL", 0.666)
local closed, busy = false, false

local function isPlayerObject(object)
    for _, other in ipairs(Players:GetPlayers()) do
        local character = other.Character
        if character and (object == character or object:IsDescendantOf(character)) then
            return true
        end
    end
    return false
end

local function path(object)
    return object:GetFullName():gsub("[\r\n\t]", " ")
end

local function report()
    local sections = {top = {}, folders = {}, npcs = {}, remotes = {}, tools = {}}
    local seenModels = {}
    for _, child in ipairs(workspace:GetChildren()) do
        if not isPlayerObject(child) then
            table.insert(sections.top, path(child) .. " [" .. child.ClassName .. "]")
        end
    end
    for _, container in ipairs({workspace, Storage}) do
        local objects = container:GetDescendants()
        local limit = math.min(#objects, 30000)
        for index = 1, limit do
            if closed then return nil end
            local object = objects[index]
            local name = string.lower(object.Name)
            if object:IsA("RemoteEvent") or object:IsA("RemoteFunction")
                or object:IsA("UnreliableRemoteEvent") then
                table.insert(sections.remotes, path(object) .. " [" .. object.ClassName .. "]")
            end
            if object:IsA("Folder") or object:IsA("Model") then
                local looksRelevant = name:find("mob", 1, true)
                    or name:find("enem", 1, true) or name:find("npc", 1, true)
                    or name:find("boss", 1, true) or name:find("monster", 1, true)
                    or name:find("combat", 1, true) or name:find("remote", 1, true)
                if (object.Parent == Storage or looksRelevant) and not isPlayerObject(object) then
                    table.insert(sections.folders, path(object) .. " [" .. object.ClassName .. "]")
                end
            end
            if container == workspace and (object:IsA("Humanoid")
                or object:IsA("AnimationController")) then
                local model = object:FindFirstAncestorOfClass("Model")
                if model and not seenModels[model] and not isPlayerObject(model) then
                    seenModels[model] = true
                    local root = model:FindFirstChild("HumanoidRootPart") or model.PrimaryPart
                    local note = " | " .. object.ClassName
                    if object:IsA("Humanoid") then
                        note = note .. " | Jetë=" .. tostring(object.Health)
                    end
                    note = note .. " | Pjesa bazë=" .. (root and root.Name or "mungon")
                    table.insert(sections.npcs, path(model) .. note)
                end
            end
            if index % 500 == 0 then task.wait() end
        end
        if #objects > limit then
            table.insert(sections.top, "KUFI: u lexuan vetëm " .. limit .. " objekte te " .. container.Name)
        end
    end
    local function readTools(container)
        if not container then return end
        for _, item in ipairs(container:GetChildren()) do
            if item:IsA("Tool") then
                table.insert(sections.tools, item.Name .. " | " .. container.ClassName
                    .. " | Aktive=" .. tostring(item.Enabled)
                    .. " | Kërkon Handle=" .. tostring(item.RequiresHandle))
            end
        end
    end
    readTools(player.Character)
    readTools(player:FindFirstChildOfClass("Backpack"))

    local lines = {
        "MOUNT RNG - RAPORT DIAGNOSTIKUES v1.1",
        "PlaceId=" .. tostring(game.PlaceId) .. " | GameId=" .. tostring(game.GameId),
        "StreamingEnabled=" .. tostring(workspace.StreamingEnabled),
        "Lexohen vetëm objektet që klienti ka ngarkuar në këtë çast.",
        "Modelet kandidate mund të jenë edhe mounts ose personazhe miqësore.",
        "Emri i një Remote nuk tregon argumentet ose rregullat e sulmit.",
        "Rruga është përshkrim: emrat mund të përmbajnë pika ose të përsëriten.",
    }
    local function add(title, entries)
        table.sort(entries)
        table.insert(lines, "\n" .. title .. " (" .. #entries .. ")")
        for index = 1, math.min(#entries, 120) do
            table.insert(lines, entries[index])
        end
        if #entries == 0 then table.insert(lines, "Asnjë i gjetur.") end
        if #entries > 120 then table.insert(lines, "Raporti tregon vetëm 120 hyrjet e para.") end
    end
    add("OBJEKTET KRYESORE TË WORKSPACE", sections.top)
    add("DOSJE DHE MODELE KANDIDATE", sections.folders)
    add("MODELE ME HUMANOID OSE ANIMATIONCONTROLLER", sections.npcs)
    add("KOMUNIKIMET ME SERVERIN (REMOTE) - VETËM EMRAT", sections.remotes)
    add("ARMËT DHE MJETET (TOOLS) TË PERSONAZHIT DHE ÇANTËS", sections.tools)
    return table.concat(lines, "\n")
end

local function scan()
    if busy or closed then return end
    busy = true
    status.Text = "Duke lexuar objektet e ngarkuara…"
    local ok, result = pcall(report)
    if not closed then
        box.Text = ok and (result or "Skanimi u ndal.") or ("Gabim: " .. tostring(result))
        local _, newlineCount = box.Text:gsub("\n", "")
        local height = (newlineCount + 4) * 18
        box.Size = UDim2.fromOffset(1780, height)
        scroll.CanvasSize = UDim2.fromOffset(1800, height + 16)
        status.Text = "Kliko PËRZGJIDH TEKSTIN, pastaj Ctrl+C. Dërgo raportin në bisedë."
    end
    busy = false
end
selectButton.Activated:Connect(function()
    if busy then return end
    box:CaptureFocus()
    box.SelectionStart = 1
    box.CursorPosition = #box.Text + 1
end)
rescanButton.Activated:Connect(scan)
closeButton.Activated:Connect(function()
    closed = true
    gui:Destroy()
end)
task.spawn(scan)
