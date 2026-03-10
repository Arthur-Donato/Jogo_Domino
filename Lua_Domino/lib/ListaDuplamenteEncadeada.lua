local ListaDuplamenteEncadeada = {}
local Peca = require 'lib.Peca'

ListaDuplamenteEncadeada.__index = ListaDuplamenteEncadeada

function ListaDuplamenteEncadeada.new()
    local instance = {
        head = nil,
        tail = nil,
        size = 0
    }

    setmetatable(instance, ListaDuplamenteEncadeada)
    return instance
end

local function newNode(leftValue, rightValue)
    return {
        peca = Peca.new(leftValue, rightValue),
        previousNode = nil,
        nextNode = nil
    }
end

function ListaDuplamenteEncadeada:addFirst(leftValue, rightValue)
    local newPeca = newNode(leftValue, rightValue)

    if self:isEmpty() then
        self.head = newPeca
        self.tail = newPeca
        self.size = self.size + 1
        return true
    end

    local valorEsquerdaMesa = self.head.peca.leftValue

    if newPeca.peca:EhCompativelLadoEsquerdo(valorEsquerdaMesa) then
        -- para entrar na esquerda, o lado direito da nova peça
        -- precisa encostar no lado esquerdo atual da mesa
        if newPeca.peca.rightValue ~= valorEsquerdaMesa then
            newPeca.peca:virar()
        end

        local pecaAux = self.head
        self.head = newPeca
        self.head.previousNode = nil
        self.head.nextNode = pecaAux
        pecaAux.previousNode = self.head

        self.size = self.size + 1
        return true
    end

    return false
end

function ListaDuplamenteEncadeada:addLast(leftValue, rightValue)
    local newPeca = newNode(leftValue, rightValue)

    if self:isEmpty() then
        self.tail = newPeca
        self.head = newPeca
        self.size = self.size + 1
        return true
    end

    local valorDireitaMesa = self.tail.peca.rightValue

    if newPeca.peca:EhCompativelLadoDireito(valorDireitaMesa) then
        -- para entrar na direita, o lado esquerdo da nova peça
        -- precisa encostar no lado direito atual da mesa
        if newPeca.peca.leftValue ~= valorDireitaMesa then
            newPeca.peca:virar()
        end

        local nodeAux = self.tail
        self.tail = newPeca
        self.tail.nextNode = nil
        self.tail.previousNode = nodeAux
        nodeAux.nextNode = self.tail

        self.size = self.size + 1
        return true
    end

    return false
end

function ListaDuplamenteEncadeada:getHeadValue()
    if self.head then
        return self.head.peca.leftValue
    end
    return nil
end

function ListaDuplamenteEncadeada:getTailValue()
    if self.tail then
        return self.tail.peca.rightValue
    end
    return nil
end

function ListaDuplamenteEncadeada:isEmpty()
    return self.head == nil
end

function ListaDuplamenteEncadeada:count()
    return self.size
end

return ListaDuplamenteEncadeada