-- by amedote
-- 

local xd = setmetatable({
	["Arsenal"] =	{
		{
			'SMG',
			'Assault Rifle',
			'Minigun',
		},
		{
			'Shotgun',
			'Sniper Rifle',
			'Napalm Deployer',
		},
		{
			'Grenade Launcher',
			'Rocket Launcher',
			'Satchel Charge',
			'Cruise Missile',
		},
		{
			'Scanner',
			'Laser Drill',
			'Painter',
		},
	},
	["S.S.I.M."] = {
		{
			"Laser Strike",
			"Orbital Shield",
			"Orbital Fabricator"
		},

    }
},
{
	__call = function(self, name, arsenal)
		name = name:lower()
		local container = self[arsenal] 

		if not container then return nil,nil end

		for menu = 1, #container do
			local sub = container[menu]
			for gun = 1, #sub do
				if sub[gun]:lower() == name then
					return menu, gun
				end
			end
		end

		return nil, nil
	end,
})
return xd

-- xd("SMG") -- 1,1
-- xd("Minigun") -- 1,3
-- xd("Scanner") -- 4,1
-- xd("Laser Strike") -- 1,1 