local IADificil = {}

local function pesoPeca(peca)
    return peca.valor1 + peca.valor2
end

local function ehDupla(peca)
    return peca.valor1 == peca.valor2
end

local function contarNumerosNaMao(mao, ignorarIndice)
    local contagem = {}
    for i = 0, 6 do
        contagem[i] = 0
    end

    for indice, peca in ipairs(mao) do
        if indice ~= ignorarIndice then
            contagem[peca.valor1] = contagem[peca.valor1] + 1
            contagem[peca.valor2] = contagem[peca.valor2] + 1
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
        contagem[atual.peca.leftValue] = contagem[atual.peca.leftValue] + 1
        contagem[atual.peca.rightValue] = contagem[atual.peca.rightValue] + 1
        atual = atual.nextNode
    end

    for _, peca in ipairs(game.maoIA) do
        contagem[peca.valor1] = contagem[peca.valor1] + 1
        contagem[peca.valor2] = contagem[peca.valor2] + 1
    end

    return contagem
end

local function descobrirValorAberto(peca, lado, esquerda, direita)
    if lado == "esquerda" then
        if peca.valor1 == esquerda then
            return peca.valor2
        else
            return peca.valor1
        end
    else
        if peca.valor1 == direita then
            return peca.valor2
        else
            return peca.valor1
        end
    end
end

local function contarContinuidade(mao, ignorarIndice, valorAlvo)
    local total = 0

    for indice, peca in ipairs(mao) do
        if indice ~= ignorarIndice then
            if peca.valor1 == valorAlvo or peca.valor2 == valorAlvo then
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
                lado = "direita",
                soma = pesoPeca(peca),
                valorAberto = peca.valor2
            })
        end
        return jogadas
    end

    for i, peca in ipairs(game.maoIA) do
        local soma = pesoPeca(peca)

        if peca.valor1 == esquerda or peca.valor2 == esquerda then
            local valorAberto = descobrirValorAberto(peca, "esquerda", esquerda, direita)
            table.insert(jogadas, {
                indice = i,
                lado = "esquerda",
                soma = soma,
                valorAberto = valorAberto
            })
        end

        if peca.valor1 == direita or peca.valor2 == direita then
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
        pontuacao = pontuacao + 8 + peca.valor1
    end

    local continuidade = contarContinuidade(game.maoIA, jogada.indice, valorAberto)
    pontuacao = pontuacao + (continuidade * 6)

    if continuidade == 0 then
        pontuacao = pontuacao - 15
    elseif continuidade == 1 then
        pontuacao = pontuacao - 5
    end

    local jaSaiu = numerosSaidos[valorAberto]
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

    print("Jogadas válidas da IA difícil:", #jogadas)

    -- Se já existe jogada, joga
    if #jogadas > 0 then
        local escolhida = IADificil.escolherJogadaDificil(game, jogadas)
        local peca = table.remove(game.maoIA, escolhida.indice)

        if escolhida.lado == "esquerda" then
            local inseriu = game.mesa:addFirst(peca.valor1, peca.valor2)
            if not inseriu then
                print("Erro ao inserir peça da IA na esquerda")
                table.insert(game.maoIA, peca)
                return false
            end
        else
            local inseriu = game.mesa:addLast(peca.valor1, peca.valor2)
            if not inseriu then
                print("Erro ao inserir peça da IA na direita")
                table.insert(game.maoIA, peca)
                return false
            end
        end

        print("IA difícil jogou:", peca.valor1 .. "-" .. peca.valor2)
        return true
    end

    -- Se não tem jogada, compra
    print("IA difícil não tem jogada válida, vai comprar")
    local conseguiuComprar = game:comprarAteEncontrarJogadaIA()

    -- Se comprou algo jogável, tenta jogar de novo
    if conseguiuComprar then
        jogadas = IADificil.buscarJogadasValidas(game)
        print("Depois da compra, jogadas válidas:", #jogadas)

        if #jogadas > 0 then
            local escolhida = IADificil.escolherJogadaDificil(game, jogadas)
            local peca = table.remove(game.maoIA, escolhida.indice)

            if escolhida.lado == "esquerda" then
                local inseriu = game.mesa:addFirst(peca.valor1, peca.valor2)
                if not inseriu then
                    print("Erro ao inserir peça comprada da IA na esquerda")
                    table.insert(game.maoIA, peca)
                    return false
                end
            else
                local inseriu = game.mesa:addLast(peca.valor1, peca.valor2)
                if not inseriu then
                    print("Erro ao inserir peça comprada da IA na direita")
                    table.insert(game.maoIA, peca)
                    return false
                end
            end

            print("IA difícil comprou e jogou:", peca.valor1 .. "-" .. peca.valor2)
            return true
        end
    end

    print("IA difícil passou a vez")
    return false
end

return IADificil