local main = {}
main.__index = main

function main.new()
    return setmetatable({}, main)
end

function main:start() end

function main:update() end

return main
