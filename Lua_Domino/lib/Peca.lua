local Peca = {}

Peca.__index = Peca

function Peca.new(leftValue, rightValue)
    local instance = {
        rightValue = rightValue,
        leftValue = leftValue,
    }

    setmetatable(instance, Peca)
    return instance
end

function Peca:EhCarrerao()
    return self.rightValue == self.leftValue
end

function Peca:EhCompativelLadoEsquerdo(value)
    return self.leftValue == value or self.rightValue == value
end

function Peca:EhCompativelLadoDireito(value)
    return self.leftValue == value or self.rightValue == value
end

function Peca:returnsRightValue()
    return self.rightValue
end

function Peca:virar()
    self.leftValue, self.rightValue = self.rightValue, self.leftValue
end

return Peca