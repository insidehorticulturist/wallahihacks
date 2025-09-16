-- example script by https://github.com/mstudio45/LinoriaLib/blob/main/Example.lua and modified by deivid
-- You can suggest changes with a pull request or something

local repo = "https://raw.githubusercontent.com/deividcomsono/Obsidian/main/"
local Library = loadstring(game:HttpGet(repo .. "Library.lua"))()
local ThemeManager = loadstring(game:HttpGet(repo .. "addons/ThemeManager.lua"))()
local SaveManager = loadstring(game:HttpGet(repo .. "addons/SaveManager.lua"))()

local Options = Library.Options
local Toggles = Library.Toggles

Library.ForceCheckbox = false
Library.ShowToggleFrameInKeybinds = true

local Window = Library:CreateWindow({
	Title = "mini.hub",
	Footer = `https://discord.gg/xuEAHusEKh | {game.PlaceVersion}`,
	NotifySide = "Right",
	ShowCustomCursor = false,
})

getgenv().Toggles = Toggles
getgenv().Options = Options

return {
	autoload = function()
		local UISettings = Window:AddTab("UI Settings", "settings")

		-- UI Settings
		local MenuGroup = UISettings:AddLeftGroupbox("Menu", "wrench")

		MenuGroup:AddToggle("KeybindMenuOpen", {
			Default = Library.KeybindFrame.Visible,
			Text = "Open Keybind Menu",
			Callback = function(value)
				Library.KeybindFrame.Visible = value
			end,
		})
		MenuGroup:AddToggle("ShowCustomCursor", {
			Text = "Custom Cursor",
			Default = false,
			Callback = function(Value)
				Library.ShowCustomCursor = Value
			end,
		})
		MenuGroup:AddDropdown("NotificationSide", {
			Values = { "Left", "Right" },
			Default = "Right",

			Text = "Notification Side",

			Callback = function(Value)
				Library:SetNotifySide(Value)
			end,
		})
		MenuGroup:AddDropdown("DPIDropdown", {
			Values = { "50%", "75%", "100%", "125%", "150%", "175%", "200%" },
			Default = "100%",

			Text = "DPI Scale",

			Callback = function(Value)
				Value = Value:gsub("%%", "")
				local DPI = tonumber(Value)

				Library:SetDPIScale(DPI)
			end,
		})
		MenuGroup:AddDivider()
		MenuGroup:AddLabel("Menu bind")
			:AddKeyPicker("MenuKeybind", { Default = "Insert", NoUI = true, Text = "Menu keybind" })

		MenuGroup:AddButton("Unload", function()
			Library:Unload()
		end)

		Library.ToggleKeybind = Options.MenuKeybind

		ThemeManager:SetLibrary(Library)
		SaveManager:SetLibrary(Library)

		SaveManager:IgnoreThemeSettings()
		SaveManager:SetIgnoreIndexes({ "MenuKeybind" })

		ThemeManager:SetFolder("MyScriptHub")
		SaveManager:SetFolder("MyScriptHub/specific-game")
		SaveManager:SetSubFolder("specific-place")

		SaveManager:BuildConfigSection(UISettings)
		ThemeManager:ApplyToTab(UISettings)
		SaveManager:LoadAutoloadConfig()
	end,

	Window = Window,
	Library = Library,
	Toggles = Toggles,
	Options = Options,
}
