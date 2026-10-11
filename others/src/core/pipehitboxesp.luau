local Structures: Folder = workspace.Structures

Structures.DescendantAdded:Connect(function(Child)
        if Child.Name:find("Flange") then
            local Selection: SelectionBox = Instance.new("SelectionBox")
            Selection.Parent = Child
            Selection.Adornee = Child
            Selection.LineThickness = 0.05
            Selection.Color3 = Color3.new(255,0,0)
        end
    end)