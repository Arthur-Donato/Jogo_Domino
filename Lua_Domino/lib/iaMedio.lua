local config = require "config"
local IAMedio = {}

-- Função auxiliar para girar a peça graficamente
local function girarPeca(peca)
    local temp = peca.leftValue
    peca.leftValue = peca.rightValue
    peca.rightValue = temp
    peca.turned = not peca.turned
end

-- BUSCAR JOGADAS VÁLIDAS DA IA
function IAMedio.buscarJogadasValidas(game) 
    local jogadas = {}

    local esquerda = game.mesa:getHeadValue()
    local direita = game.mesa:getTailValue()

    -- Se a mesa estiver vazia, a IA pode jogar qualquer peça
    if esquerda == nil or direita == nil then
        for i, peca in ipairs(game.maoIA) do
            table.insert(jogadas, {
                indice = i,
                lado = "primeira",
                soma = peca.leftValue + peca.rightValue
            })
        end
        return jogadas
    end

    -- Pegar todas as jogadas possíveis
    for i, peca in ipairs(game.maoIA) do 
        local soma = peca.leftValue + peca.rightValue

        -- Verifica lado esquerdo
        if peca.leftValue == esquerda or peca.rightValue == esquerda then
            table.insert(jogadas, {
                indice = i,
                lado = "esquerda",
                soma = soma
            })
        end

        -- Verifica lado direito
        if peca.leftValue == direita or peca.rightValue == direita then
            table.insert(jogadas, {
                indice = i,
                lado = "direita",
                soma = soma
            })
        end
    end

    return jogadas
end

-- ESCOLHER JOGADA MÉDIO (Prioriza a maior soma)
function IAMedio.escolherJogadaMedio(jogadas)
    -- Ordenar por soma MAIOR primeiro (Estratégia Média)
    table.sort(jogadas, function(a, b)
        return a.soma > b.soma
    end)

    local maiorSoma = jogadas[1].soma
    local empatadas = {}

    -- Se houver empate, guarda apenas as de maior soma 
    for _, jogada in ipairs(jogadas) do
        if jogada.soma == maiorSoma then
            table.insert(empatadas, jogada)
        else
            break
        end
    end

    -- Escolhe aleatoriamente entre as empatadas
    return empatadas[love.math.random(#empatadas)]
end

-- IA - MODO MÉDIO
function IAMedio.jogada(game)
    -- Pegar todas as jogadas possíveis
    local jogadas = IAMedio.buscarJogadasValidas(game)

    -- Se encontrou jogada válida
    if #jogadas > 0 then
        -- Escolher jogada
        local escolhida = IAMedio.escolherJogadaMedio(jogadas)

        -- Remove a peça da mão da IA
        local peca = table.remove(game.maoIA, escolhida.indice)

        -- Se a mesa estiver vazia
        if game.mesa:isEmpty() or escolhida.lado == "primeira" then
            peca.x = config.WIDTH 
            peca.y = config.HEIGHT
            game.mesa:addFirst(peca)
            return true
        end

        local esquerda = game.mesa:getHeadValue()
        local direita = game.mesa:getTailValue()

        -- Adiciona na mesa conforme o lado escolhido e alinha visualmente
        if escolhida.lado == "esquerda" then
            if peca.leftValue == esquerda then
                girarPeca(peca)
            end
            peca.x = config.WIDTH - (game.mesa.leftSize * peca.height)
            peca.y = config.HEIGHT
            game.mesa:addFirst(peca)

        elseif escolhida.lado == "direita" then
            if peca.rightValue == direita then
                girarPeca(peca)
            end
            peca.x = config.WIDTH + (game.mesa.rightSize * peca.height)
            peca.y = config.HEIGHT
            game.mesa:addLast(peca)
        end
        return true
    end
    
    -- Se não houver jogadas válidas, a IA tenta comprar
    print("IA (Médio) não tem jogada válida")
    local conseguiu = game:comprarAteEncontrarJogadaIA()
    if conseguiu then
        print("IA (Médio) comprou uma peça jogável. Aguardando delay para jogar...")
    else
        print("IA (Médio) passou a vez")
    end
    
    return false
end

return IAMedio