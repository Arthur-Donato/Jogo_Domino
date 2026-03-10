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
    self.size  = self.size + 1

    local newPeca = newNode(leftValue, rightValue)

    if self:isEmpty() then
        self.head = newPeca
        self.head.previousNode = nil
        self.tail = newPeca
        self.tail.nextNode = nil
    else
        --COMPARAR OS DOIS LADOS DA PECA COM O LADO ESQUERDO DA HEAD PARA SABER SE SAO IGUAIS s
        if self.head.peca:EhCompativelLadoEsquerdo(newPeca.peca.leftValue) 
        or self.head.peca:EhCompativelLadoDireito(newPeca.peca.rightValue) then
            local pecaAux = self.head

            self.head = newPeca
            self.head.previousNode = nil
            self.head.nextNode = pecaAux

            pecaAux.previousNode = self.head
        end

    end
end

function ListaDuplamenteEncadeada:addLast(leftValue, rightValue)
    
    --ADICIONAR O NOVO NO NO FINAL DA LISTA, UTILIZANDO A MESMA LOGICA DO METODO ACIMA
    local newPeca = newNode(leftValue, rightValue)

    if self:isEmpty() then
        self.tail = newPeca
        self.tail.nextNode = nil
        self.head = newPeca
        self.head.previousNode = nil
    else
        if self.tail.peca:EhCompativelLadoDireito(newPeca.peca.leftValue) or self.tail.peca:EhCompativelLadoDireito(newPeca.peca.rightValue) then
            local nodeAux = self.tail

            self.tail = newPeca
            self.tail.nextNode = nil
            self.tail.previousNode = nodeAux

            nodeAux.nextNode = self.tail
            self.size  = self.size + 1
        end
    end
end

-- No arquivo ListaDuplamenteEncadeada.lua
function ListaDuplamenteEncadeada:getHeadValue()
    if self.head then
        return self.head.peca.leftValue
    end
    return nil
end

function ListaDuplamenteEncadeada:getTailValue()
    --RETORNAR APENAS O VALOR DA DIREITA DA PECA DE DOMINO QUE SE ENCONTRA NA CAUDA DA NOSSA LISTA
    if self.tail then
        return self.tail.peca:returnsRightValue()
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