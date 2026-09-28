--[================================================================]--
-- GitHub Asset Loader & State Overlay + Music (Executor Script)
-- Скачивает Image1.png, Image2.png, Image3.png и fem.mp4 из репозитория
--[================================================================]--

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local CoreGui = game:GetService("CoreGui")
local SoundService = game:GetService("SoundService")

local player = Players.LocalPlayer

-- ЗАМЕНИ ЭТУ ССЫЛКУ на прямую ссылку на твой репозиторий GitHub (ветка main/master)
local GITHUB_REPO_URL = "https://raw.githubusercontent.com/BNDPA/Candyware/main/"

-- Универсальная функция для скачивания любых файлов с GitHub (картинки, видео, аудио)
local function loadGitHubFile(fileName, isAsset)
	local filePath = "OverlayAssets_" .. fileName
	
	if not writefile or not readfile or not getcustomasset then
		warn("Твой эксплойт не поддерживает функции файловой системы (writefile/getcustomasset)!")
		return ""
	end
	
	local success, response = pcall(function()
		return game:HttpGet(GITHUB_REPO_URL .. fileName)
	end)
	
	if success and response and #response > 0 then
		writefile(filePath, response)
		if isAsset then
			return getcustomasset(filePath)
		else
			return filePath -- Возвращаем путь для локального воспроизведения звука через readfile/getcustomasset
		end
	else
		warn("Не удалось скачать файл с GitHub: " .. fileName)
		return ""
	end
end

print("[Overlay] Загрузка файлов из репозитория...")
local IMG_DEFAULT = loadGitHubFile("Image1.png", true) -- Покой
local IMG_JUMP    = loadGitHubFile("Image2.png", true) -- Прыжок
local IMG_WALK    = loadGitHubFile("Image3.png", true) -- Ходьба
local MUSIC_PATH  = loadGitHubFile("fem.mp4", true)    -- Музыка fem.mp4 (эксплойты отлично воспроизводят видео/аудио через customasset)
print("[Overlay] Загрузка завершена!")

-- Запуск музыки `fem.mp4`
if MUSIC_PATH ~= "" then
	local sound = Instance.new("Sound")
	sound.Name = "OverlayMusic"
	sound.SoundId = MUSIC_PATH
	sound.Looped = true
	sound.Volume = 1
	sound.Parent = SoundService
	sound:Play()
	print("[Overlay] Музыка успешно запущена!")
else
	warn("[Overlay] Не удалось запустить fem.mp4 (файл пуст или не скачался).")
end

-- Защита от дублирования при повторном запуске
if CoreGui:FindFirstChild("StateImageOverlay_Repo") then
	CoreGui.StateImageOverlay_Repo:Destroy()
end

-- Создаем интерфейс для картинок
local screenGui = Instance.new("ScreenGui")
screenGui.Name = "StateImageOverlay_Repo"
screenGui.IgnoreGuiInset = true
screenGui.ResetOnSpawn = false
screenGui.DisplayOrder = 99999
pcall(function()
	screenGui.Parent = CoreGui
end)
if not screenGui.Parent then
	screenGui.Parent = player:WaitForChild("PlayerGui")
end

local imageLabel = Instance.new("ImageLabel")
imageLabel.Name = "Overlay"
imageLabel.Size = UDim2.new(1, 0, 1, 0)
imageLabel.Position = UDim2.new(0, 0, 0, 0)
imageLabel.BackgroundTransparency = 1
imageLabel.ScaleType = Enum.ScaleType.Stretch
imageLabel.Image = IMG_DEFAULT ~= "" and IMG_DEFAULT or "rbxassetid://0"
imageLabel.Parent = screenGui

local isJumping = false

UserInputService.JumpRequest:Connect(function()
	isJumping = true
	task.delay(0.4, function()
		isJumping = false
	end)
end)

-- Главный цикл отслеживания движений
RunService.RenderStepped:Connect(function()
	local character = player.Character
	if not character then return end
	
	local humanoid = character:FindFirstChildOfClass("Humanoid")
	local rootPart = character:FindFirstChild("HumanoidRootPart")
	
	if not humanoid or not rootPart then return end
	
	local velocity = rootPart.AssemblyLinearVelocity
	local horizontalSpeed = Vector3.new(velocity.X, 0, velocity.Z).Magnitude
	local isWalking = (horizontalSpeed > 1 and humanoid.FloorMaterial ~= Enum.Material.Air)
	
	-- Переключение картинок
	if isJumping or humanoid:GetState() == Enum.HumanoidStateType.Jumping then
		if imageLabel.Image ~= IMG_JUMP and IMG_JUMP ~= "" then
			imageLabel.Image = IMG_JUMP
		end
	elseif isWalking then
		if imageLabel.Image ~= IMG_WALK and IMG_WALK ~= "" then
			imageLabel.Image = IMG_WALK
		end
	else
		if imageLabel.Image ~= IMG_DEFAULT and IMG_DEFAULT ~= "" then
			imageLabel.Image = IMG_DEFAULT
		end
	end
end)
