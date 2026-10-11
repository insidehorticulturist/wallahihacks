game.Players.PlayerAdded:Connect(function(p)
    for _,v in ipairs({
        "BusyCityGuy",
        "Stormingness",
        "Nuckyz",
        "Angelic_Pride",
        "Smaltin",
        "lansraad"
    }) do
     if v:lower() == p.name:lower() then
        game.Players.LocalPlayer:Kick("staff joined lol") 
    end
end
end)