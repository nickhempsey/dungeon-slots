local Bank = {}

function Bank:new()
    return {
        symbolCounts = {}, -- map SymbolType→count
    }
end

return Bank
