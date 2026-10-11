local Players = game:GetService("Players")

local artygrav = {}
artygrav.__index = artygrav

function artygrav.new()
	return setmetatable({
		savedGravity = nil,
	}, artygrav)
end

-- puts gravity back to what it was before we changed it
function artygrav:_restore()
	if self.savedGravity then
		workspace.Gravity = self.savedGravity
		self.savedGravity = nil
	end
end

function artygrav:_hookCharacter(character)
	-- dying while seated never fires Seated(false), so clean up on every new character
	self:_restore()

	local humanoid = character:WaitForChild("Humanoid", 10)
	if not humanoid then
		return
	end

	humanoid.Seated:Connect(function(isSeated)
		if isSeated then
			if Toggles.ArtyGravity.Value then
				self.savedGravity = self.savedGravity or workspace.Gravity
				workspace.Gravity = Options.GravitySlider.Value
			end
		else
			self:_restore()
		end
	end)
end

function artygrav:start()
	local Client = Players.LocalPlayer

	Client.CharacterAdded:Connect(function(character)
		self:_hookCharacter(character)
	end)

	if Client.Character then
		self:_hookCharacter(Client.Character)
	end
end

return artygrav
