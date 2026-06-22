local wave, super = Class(Wave)

function wave:canEnd()
    return false
end

return wave