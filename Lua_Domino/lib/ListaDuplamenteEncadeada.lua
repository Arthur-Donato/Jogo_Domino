local ListaDuplamenteEncadeada = {}
local Peca = require 'lib.Peca'

ListaDuplamenteEncadeada.__index = ListaDuplamenteEncadeada

function ListaDuplamenteEncadeada.new()
    local instance = {
        head = nil,
        tail = nil,
        size = 0;
        rightSize = 1,
        leftSize = 1,
        middle = nil
    }

    setmetatable(instance, ListaDuplamenteEncadeada)
    return instance
    
end

local function newNode(pecaExistente)
    return {
        peca = pecaExistente,
        previousNode = nil,
        nextNode = nil
    }
end



function ListaDuplamenteEncadeada:addFirst(pecaExistente)
    
    local newPeca = newNode(pecaExistente)
    
    if self:isEmpty() then
        self.head = newPeca
        self.middle = newPeca
        self.head.previousNode = nil
        self.tail = newPeca
        self.tail.nextNode = nil
    elseif newPeca.peca.rightValue == -1 then --peça Meramente grafica. Server para mostrar o local onde as peças podem ser jogadas
        
        self.head.previousNode = newPeca
        newPeca.nextNode = self.head
    else  
        local nodeAux = self.head
        self.head = newPeca
        self.head.previousNode = nil
        self.head.nextNode = nodeAux
        nodeAux.previousNode = self.head
        self.leftSize = self.leftSize + 1
    end
    self.size = self.size + 1
end


function ListaDuplamenteEncadeada:addLast(pecaExistente)
    
    --ADICIONAR O NOVO NO NO FINAL DA LISTA, UTILIZANDO A MESMA LOGICA DO METODO ACIMA
    local newPeca = newNode(pecaExistente)

    if self:isEmpty() then
        self.tail = newPeca
        self.middle = newPeca
        self.tail.nextNode = nil
        self.head = newPeca
        self.head.previousNode = nil

    elseif newPeca.peca.rightValue == -1 then --peça Meramente grafica. Server para mostrar o local onde as peças podem ser jogadas

        self.tail.nextNode = newPeca
        newPeca.previousNode = self.tail
    else
            local nodeAux = self.tail
            self.tail = newPeca
            self.tail.nextNode = nil
            self.tail.previousNode = nodeAux

            nodeAux.nextNode = self.tail
            self.rightSize = self.rightSize + 1
        end
        self.size = self.size + 1
end

function ListaDuplamenteEncadeada:EhCompativelDoisLados(pecaExistente)

    local headValue = self:getHeadValue()
    local tailValue = self:getTailValue()
    

    return  (pecaExistente:EhCompativelLadoDireito(tailValue) or pecaExistente:EhCompativelLadoEsquerdo(tailValue)) and
            (pecaExistente:EhCompativelLadoDireito(headValue) or pecaExistente:EhCompativelLadoEsquerdo(headValue))
    
end

function ListaDuplamenteEncadeada:addPecaGraficaEsquerda(x,y)
    local peca = Peca.new(-1,-1)
    peca.x = x
    peca.y = y
    peca.height = 160 --alterar para variavel posteiormente
    peca.width = 100 
    local imagemPeca = love.graphics.newImage("images/0-0.png")
    peca.img = imagemPeca
    self:addFirst(peca)
end
function ListaDuplamenteEncadeada:addPecaGraficaDireita(x,y)
    local peca = Peca.new(-1,-1)
    peca.x = x
    peca.y = y
    peca.height = 160 --alterar para variavel posteiormente
    peca.width = 100 
    local imagemPeca = love.graphics.newImage("images/0-0.png")
    peca.img = imagemPeca
    self:addLast(peca)
end

function ListaDuplamenteEncadeada:removePecasGraficas()
    -- Remove o fantasma da esquerda (se existir)
    if self.head ~= nil and self.head.previousNode ~= nil then
        self.head.previousNode.nextNode = nil
        self.head.previousNode = nil
        self.size = self.size - 1 -- Corrige a contagem
    end

    -- Remove o fantasma da direita (se existir)
    if self.tail ~= nil and self.tail.nextNode ~= nil then
        self.tail.nextNode.previousNode = nil
        self.tail.nextNode = nil
        self.size = self.size - 1 -- Corrige a contagem
    end
end

-- No arquivo ListaDuplamenteEncadeada.lua
function ListaDuplamenteEncadeada:getHeadValue()
    if not self:isEmpty() then
        return self.head.peca.leftValue
    end
    return nil
end

function ListaDuplamenteEncadeada:getTailValue()
    --RETORNAR APENAS O VALOR DA DIREITA DA PECA DE DOMINO QUE SE ENCONTRA NA CAUDA DA NOSSA LISTA
    if not self:isEmpty() then
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