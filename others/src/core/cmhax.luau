local o; o = hookmetamethod(game, "__namecall", function(self,...)
    if not checkcaller() then

    local method = getnamecallmethod()
    if method == "FireServer" and self:IsA("RemoteEvent") and self.Name == "Remote" then
            local args = {...}
            if args[1] == "BarrelPositionUpdated" then
                args[2] = game:GetService("Players").LocalPlayer:GetMouse().Hit.Position
            end
            print(table.unpack(args))

            return o(self,table.unpack(args))
        end
    end

    return o(self,...)

end)