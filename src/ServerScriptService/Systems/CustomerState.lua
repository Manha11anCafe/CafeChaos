-- CustomerState.lua
-- State ทั้งหมดของลูกค้า ตั้งแต่ spawn จนออกจากร้าน

local CustomerState = {
	Spawning        = "Spawning",        -- เพิ่ง spawn ยังไม่ได้ทำอะไร
	WalkingToQueue  = "WalkingToQueue",  -- กำลังเดินเข้าคิว
	WaitingInQueue  = "WaitingInQueue",  -- ยืนรอในคิว
	Ordering        = "Ordering",        -- กำลังสั่งอาหาร
	WaitingForFood  = "WaitingForFood",  -- รออาหาร
	Eating          = "Eating",          -- กำลังกิน
	Paying          = "Paying",          -- กำลังจ่ายเงิน
	Leaving         = "Leaving",         -- กำลังเดินออก
	Finished        = "Finished"         -- ออกจากร้านแล้ว
}

return table.freeze(CustomerState)