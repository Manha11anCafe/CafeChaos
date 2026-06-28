-- GameConfig.lua
local GameConfig = {}

-- ข้อมูลเกม
GameConfig.Game = {
	Name    = "CafeChaos",
	Version = "0.1.0"
}

-- Debug mode — ปิดตอน release
GameConfig.Debug = true

-- ระบบคิว
GameConfig.Queue = {
	MaxSize       = 5,    -- คนได้สูงสุดในคิว
	MoveTimeout   = 60,   -- วินาที รอ NPC เดินถึงก่อน force Destroy
}

-- ระบบ Spawn ลูกค้า
GameConfig.Customer = {
	SpawnInterval = 10,   -- วินาที ระหว่าง spawn แต่ละคน
	MaxPatience   = 60,   -- วินาที รอสูงสุดก่อนหมดอารมณ์
}

-- ระบบเศรษฐกิจ
GameConfig.Economy = {
	BaseReward    = 10,   -- เงินพื้นฐานต่อลูกค้า
	TipMax        = 5,    -- Tip สูงสุด
}

return GameConfig