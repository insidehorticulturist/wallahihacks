local structures = workspace:WaitForChild("Structures")

local main = {}
main.__index = main

function main.new()
	local x = setmetatable({}, main)
	x.arsenals = {}
	x.ssims = {}
	x.combined = {}

	for _, obj in ipairs(structures:GetChildren()) do
		x:_checkAndAdd(obj)
	end

	structures.ChildAdded:Connect(function(obj)
		x:_checkAndAdd(obj)
	end)

	structures.ChildRemoved:Connect(function(obj)
		x:_checkAndRemove(obj)
	end)

	return x
end

local function TableConcat(t1, t2)
	for i = 1, #t2 do
		t1[#t1 + 1] = t2[i]
	end
	return t1
end

local function TableRemove(tbl, obj)
	if typeof(tbl) == "table" then
		for i, v in ipairs(tbl) do
			if v == obj then
				table.remove(tbl, i)
				break
			end
		end
	end
end

function main:_checkAndAdd(obj)
	if not obj or not obj:IsA("Model") then return end
	local teamColor = game:GetService("Players").LocalPlayer.TeamColor

	if obj:GetAttribute("Team") == teamColor then
		table.insert(self.arsenals, obj)
	elseif obj.Name == "S.S.I.M." then
		table.insert(self.ssims, obj)
	else
		return 
	end

	self.combined = TableConcat(table.clone(self.arsenals), self.ssims)
end

function main:_checkAndRemove(obj)
	TableRemove(self.arsenals, obj)
	TableRemove(self.ssims, obj)

	self.combined = TableConcat(table.clone(self.arsenals), self.ssims)
end

return main
