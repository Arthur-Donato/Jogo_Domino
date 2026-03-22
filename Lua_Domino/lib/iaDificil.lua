local config = require "config"
local IADificil = {}

-- Função auxiliar para girar a peça graficamente
local function girarPeca(peca)
    local temp = peca.leftValue
    peca.leftValue = peca.rightValue
    peca.rightValue = temp
    peca.turned = not peca.turned
end

local function pesoPeca(peca)
    return peca.leftValue + peca.rightValue
end

local function ehDupla(peca)
    return peca.leftValue == peca.rightValue
end

local function contarNumerosNaMao(mao, ignorarIndice)
    local contagem = {}
    for i = 0, 6 do
        contagem[i] = 0
    end

    for indice, peca in ipairs(mao) do
        if indice ~= ignorarIndice then
            contagem[peca.leftValue] = contagem[peca.leftValue] + 1
            contagem[peca.rightValue] = contagem[peca.rightValue] + 1
        end
    end

    return contagem
end

local function contarNumerosJaSaidos(game)
    local contagem = {}
    for i = 0, 6 do
        contagem[i] = 0
    end

    local atual = game.mesa.head
    while atual do
        -- Tratamento para pegar a peça corretamente do nó da lista
        if atual.peca then
            contagem[atual.peca.leftValue] = contagem[atual.peca.leftValue] + 1
            contagem[atual.peca.rightValue] = contagem[atual.peca.rightValue] + 1
        end
        atual = atual.nextNode
    end

    for _, peca in ipairs(game.maoIA) do
        contagem[peca.leftValue] = contagem[peca.leftValue] + 1
        contagem[peca.rightValue] = contagem[peca.rightValue] + 1
    end

    return contagem
end

local function descobrirValorAberto(peca, lado, esquerda, direita)
    if lado == "esquerda" then
        if peca.leftValue == esquerda then
            return peca.rightValue
        else
            return peca.leftValue
        end
    else
        if peca.leftValue == direita then
            return peca.rightValue
        else
            return peca.leftValue
        end
    end
end

local function contarContinuidade(mao, ignorarIndice, valorAlvo)
    local total = 0

    for indice, peca in ipairs(mao) do
        if indice ~= ignorarIndice then
            if peca.leftValue == valorAlvo or peca.rightValue == valorAlvo then
                total = total + 1
            end
        end
    end

    return total
end

function IADificil.buscarJogadasValidas(game)
    local jogadas = {}

    local esquerda = game.mesa:getHeadValue()
    local direita = game.mesa:getTailValue()

    if esquerda == nil or direita == nil then
        for i, peca in ipairs(game.maoIA) do
            table.insert(jogadas, {
                indice = i,
                lado = "primeira",
                soma = pesoPeca(peca),
                valorAberto = peca.rightValue
            })
        end
        return jogadas
    end

    for i, peca in ipairs(game.maoIA) do
        local soma = pesoPeca(peca)

        if peca.leftValue == esquerda or peca.rightValue == esquerda then
            local valorAberto = descobrirValorAberto(peca, "esquerda", esquerda, direita)
            table.insert(jogadas, {
                indice = i,
                lado = "esquerda",
                soma = soma,
                valorAberto = valorAberto
            })
        end

        if peca.leftValue == direita or peca.rightValue == direita then
            local valorAberto = descobrirValorAberto(peca, "direita", esquerda, direita)
            table.insert(jogadas, {
                indice = i,
                lado = "direita",
                soma = soma,
                valorAberto = valorAberto
            })
        end
    end

    return jogadas
end

function IADificil.avaliarJogada(game, jogada)
    local peca = game.maoIA[jogada.indice]
    local numerosNaMao = contarNumerosNaMao(game.maoIA, jogada.indice)
    local numerosSaidos = contarNumerosJaSaidos(game)

    local pontuacao = 0
    local valorAberto = jogada.valorAberto

    pontuacao = pontuacao + (pesoPeca(peca) * 2)

    if ehDupla(peca) then
        pontuacao = pontuacao + 8 + peca.leftValue
    end

    local continuidade = contarContinuidade(game.maoIA, jogada.indice, valorAberto)
    pontuacao = pontuacao + (continuidade * 6)

    if continuidade == 0 then
        pontuacao = pontuacao - 15
    elseif continuidade == 1 then
        pontuacao = pontuacao - 5
    end

    local jaSaiu = numerosSaidos[valorAberto]
    if jaSaiu then
        pontuacao = pontuacao + (jaSaiu * 3)

        if jaSaiu >= 6 then
            pontuacao = pontuacao + 12
        elseif jaSaiu >= 5 then
            pontuacao = pontuacao + 8
        end

        if jaSaiu >= 5 and continuidade >= 1 then
            pontuacao = pontuacao + 10
        end

        if jaSaiu <= 2 and continuidade <= 1 then
            pontuacao = pontuacao - 10
        end
    end

    if #game.maoIA <= 3 then
        pontuacao = pontuacao + pesoPeca(peca) * 2
    end

    return pontuacao
end

function IADificil.escolherJogadaDificil(game, jogadas)
    local melhor = nil
    local melhorPontuacao = -math.huge

    for _, jogada in ipairs(jogadas) do
        jogada.pontuacao = IADificil.avaliarJogada(game, jogada)
        local peca = game.maoIA[jogada.indice]

        if jogada.pontuacao > melhorPontuacao then
            melhorPontuacao = jogada.pontuacao
            melhor = jogada
        elseif jogada.pontuacao == melhorPontuacao then
            local pecaMelhor = game.maoIA[melhor.indice]

            if pesoPeca(peca) > pesoPeca(pecaMelhor) then
                melhor = jogada
            elseif pesoPeca(peca) == pesoPeca(pecaMelhor) then
                if ehDupla(peca) and not ehDupla(pecaMelhor) then
                    melhor = jogada
                end
            end
        end
    end

    return melhor
end

function IADificil.jogada(game)
    local jogadas = IADificil.buscarJogadasValidas(game)

    print("Jogadas validas da IA dificil:", #jogadas)

    -- Se já existe jogada, joga
    if #jogadas > 0 then
        local escolhida = IADificil.escolherJogadaDificil(game, jogadas)
        local peca = table.remove(game.maoIA, escolhida.indice)

        -- Se a mesa estiver vazia
        if game.mesa:isEmpty() or escolhida.lado == "primeira" then
            peca.x = config.WIDTH 
            peca.y = config.HEIGHT
            game.mesa:addFirst(peca)
            print("IA dificil jogou a primeira peca: " .. peca.leftValue .. "-" .. peca.rightValue)
            return true
        end

        local esquerda = game.mesa:getHeadValue()
        local direita = game.mesa:getTailValue()

        if escolhida.lado == "esquerda" then
            if peca.leftValue == esquerda then
                girarPeca(peca)
            end
            peca.x = config.WIDTH - (game.mesa.leftSize * peca.height)
            peca.y = config.HEIGHT
            game.mesa:addFirst(peca)
        else
            if peca.rightValue == direita then
                girarPeca(peca)
            end
            peca.x = config.WIDTH + (game.mesa.rightSize * peca.height)
            peca.y = config.HEIGHT
            game.mesa:addLast(peca)
        end

        print("IA dificil jogou:", peca.leftValue .. "-" .. peca.rightValue)
        return true
    end

    -- Se não tem jogada, compra
    print("IA dificil não tem jogada valida, vai comprar")
    local conseguiuComprar = game:comprarAteEncontrarJogadaIA()

    if conseguiuComprar then
        print("IA difícil comprou uma peça jogável e vai esperar o delay para jogar")
        return true
    end

    print("IA difícil passou a vez")
    return false
end

return IADificil