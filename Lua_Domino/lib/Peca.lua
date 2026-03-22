local Peca = {}
local config = require "config"

Peca.__index = Peca

function Peca.new(leftValue, rightValue)

    local instance = {
        rightValue = rightValue,
        leftValue = leftValue,
        img=nil,
        x = 0,
        y = 0,
        width = 100,
        height = 160,
        isHovering = false,
        turned = false,
    }

    setmetatable(instance, Peca)
    return instance
    
end

function Peca:EhCarrerao()
    return self.rightValue == self.leftValue
    
end


function Peca:EhCompativelLadoEsquerdo(value)
    
    return self.leftValue == value
end

function Peca:EhCompativelLadoDireito(value)
    
    return self.rightValue == value

end

function Peca:returnsRightValue()
    return self.rightValue
end

return Peca