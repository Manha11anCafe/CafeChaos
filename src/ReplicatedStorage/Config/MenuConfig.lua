-- MenuConfig.lua
-- รายการเมนูทั้งหมดในร้าน
-- เพิ่มเมนูใหม่ได้ที่นี่เลย

local MenuConfig = {

	Items = {

		{
			Id         = "coffee",
			Name       = "Coffee",
			Price      = 12,
			TimeToCook = 8,     -- วินาที
		},

		{
			Id         = "tea",
			Name       = "Tea",
			Price      = 10,
			TimeToCook = 6,
		},

		{
			Id         = "cake",
			Name       = "Cake",
			Price      = 18,
			TimeToCook = 12,
		},

		{
			Id         = "cookie",
			Name       = "Cookie",
			Price      = 8,
			TimeToCook = 5,
		},

	}

}

return MenuConfig