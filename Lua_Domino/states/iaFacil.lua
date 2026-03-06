-- IA FÁCIL
local IAFacil = {}

-- BUSCAR JOGADAS VÁLIDAS DA IA
function IAFacil.buscarJogadasValidas(game) 

    local jogadas = {}

    -- Se a mesa estiver vazia, não há jogada possível
    local esquerda = game.mesa:getHeadValue()
    local direita = game.mesa:getTailValue()

    if esquerda == nil or direita == nil then
        return jogadas
    end

    -- Pegar todas as jogadas possíveis
    for i, peca in ipairs(game.maoIA) do 

        local soma = peca.valor1 + peca.valor2

        -- Verifica lado esquerdo
        if peca.valor1 == esquerda or peca.valor2 == esquerda then
            table.insert(jogadas, {
                indice = i,
                lado = "esquerda",
                soma = soma
            })
        end

        -- Verifica lado direito
        if peca.valor1 == direita or peca.valor2 == direita then
            table.insert(jogadas, {
                indice = i,
                lado = "direita",
                soma = soma
            })
        end
    end

    return jogadas
end


-- ESCOLHER JOGADA FÁCIL
function IAFacil.escolherJogadaFacil(jogadas)

    -- Ordenar por soma menor primeiro
    table.sort(jogadas, function(a, b)
        return a.soma < b.soma
    end)

    local menorSoma = jogadas[1].soma
    local empatadas = {}

    -- Se houver empate, guarda apenas as de menor soma 
    for _, jogada in ipairs(jogadas) do
        if jogada.soma == menorSoma then
            table.insert(empatadas, jogada)
        else
            break
        end
    end

    -- Escolhe aleatoriamente entre as empatadas
    return empatadas[love.math.random(#empatadas)]
end


-- IA - MODO FÁCIL
function IAFacil.jogada(game)

    -- Pegar todas as jogadas possíveis
    local jogadas = IAFacil.buscarJogadasValidas(game)

    -- Se encontrou jogada válida
    if #jogadas > 0 then

        -- Escolher jogada pela menor soma (com desempate aleatório)
        local escolhida = IAFacil.escolherJogadaFacil(jogadas)

        -- Remove a peça da mão da IA
        local peca = table.remove(game.maoIA, escolhida.indice)

        -- Adiciona na mesa conforme o lado escolhido
        if escolhida.lado == "esquerda" then
            game.mesa:addFirst(peca.valor1, peca.valor2)

        elseif escolhida.lado == "direita" then
            game.mesa:addLast(peca.valor1, peca.valor2)
        end
    end

    -- Se não houver jogadas válidas,
    -- a IA simplesmente não joga.
    -- Compra e passe NÃO são responsabilidade desta IA.
end

return IAFacil