local GameState                      = require 'lib.GameState'
local ListaDuplamenteEncadeada       = require 'lib.ListaDuplamenteEncadeada'
local Peca                           = require 'lib.Peca'
local WIDTH, HEIGHT                  = love.window.getDesktopDimensions()
local config                         = require "config"
local iaFacil                        = require "lib.iaFacil"
local iaMedio                        = require "lib.iaMedio"
local IADificil                      = require "lib.iaDificil"
local tempoIA                        = 0
local delayIA                        = 1
local tempoMostrarCompraIA           = 0
local delayMostrarCompraIA           = 2.0
local iaProcessando                  = false
local iaEsperandoJogarDepoisDaCompra = false


VEZ_DO_JOGADOR                       = true --Sempre começa na vez do jogador
GAME_OVER                            = false

local Game                           = {
    botaoComprar = {
        x = config.WIDTH - config.btnResponsiveX - 20,  --20 de margem direita
        y = config.HEIGHT - config.btnResponsiveY - 240, -- 2x tamnho da peça + 40 sobrando, alterar posteiormente
        width = config.btnResponsiveX - 80,
        height = config.btnResponsiveY,
        text = "Comprar",
        isHovering = false,
        fonte = config.fonteBotoes
    },
    maoJogador = {},
    maoIA = {},
    monte = {},
    mesa = ListaDuplamenteEncadeada.new(),
}
local function calcular_disposicao_pecas_Mao(pecas, entidade)
    local posicaoAtualX = 0
    local posicaoAtualY = 0
    if entidade == "jogador" then
        posicaoAtualY = config.HEIGHT - 20 -
        160                                      --20 de margem inferior e 160 altura da peça(alterar para variável posteriormente
    elseif entidade == "IA" then
        posicaoAtualY = 20 --20 de margem superior
    end

    if #pecas % 2 == 0 then
        posicaoAtualX = (config.WIDTH / 2) -
        ((#pecas / 2) * (100 + 20))                                                      --100 largura da peça e 20 espaçamento entre as peças(alterar para variável posteriormente)
    else
        posicaoAtualX = (config.WIDTH / 2) - (math.floor(#pecas / 2) * (100 + 20)) -
        (100 / 2)                                                                        --100 largura da peça e 20 espaçamento entre as peças(alterar para variável posteriormente)
    end

    for _, piece in ipairs(pecas) do
        piece.x = posicaoAtualX
        piece.y = posicaoAtualY


        posicaoAtualX = posicaoAtualX + piece.width + 20
    end
end


local function imprimirPecas(x, y, pecas)
    calcular_disposicao_pecas_Mao(pecas, "jogador")
    for _, piece in ipairs(pecas) do --NOTE:
        if piece.isHovering and VEZ_DO_JOGADOR then
            love.graphics.setColor(1, 1, 1, 1)
        else
            love.graphics.setColor(0.9, 0.9, 0.9, 1)
        end
        if x > piece.x and
            x < piece.x + piece.width and
            y > piece.y and
            y < piece.y + piece.height
        then
            piece.isHovering = true
        else
            piece.isHovering = false
        end

        love.graphics.draw(piece.img, piece.x, piece.y)
    end

    love.graphics.setColor(1, 1, 1, 1)
end

local function imprimirPecasIA()
    calcular_disposicao_pecas_Mao(Game.maoIA, "IA")
    for _, piece in ipairs(Game.maoIA) do    --NOTE:
        love.graphics.draw(piece.img, piece.x, piece.y)
    end
end


local function criarPecas(monte)
    for i = 0, 6 do
        for j = i, 6 do
            local imagemPeca = love.graphics.newImage("images/" .. i .. "-" .. j .. ".png") --carrega a imagem da peça
            print("images/" .. i .. "-" .. j .. ".png")
            local novaPeca = {
                valor1 = i,
                valor2 = j,
                img = imagemPeca,
                x = 0,
                y = 0,
                width = 100,
                height = 160,
                isHovering = false
            }
            table.insert(monte, novaPeca)
        end
    end
end



function Game:enter(dificuldade)
    self.dificuldade = dificuldade or "facil"

    self.maoJogador = {}
    self.maoIA = {}
    self.monte = {}
    self.mesa = ListaDuplamenteEncadeada.new()

    VEZ_DO_JOGADOR = true
    GAME_OVER = false

    criarPecas(self.monte)
    DistribuirPecas(self.monte)
end

function Embaralhar(monte)
    local j
    for i = #monte, 2, -1 do
        j = love.math.random(i)
        monte[i], monte[j] = monte[j], monte[i] --OBS
    end
    return monte
end

--OBS: Obs:
--deck[i], deck[j] = deck[j], deck[i]

--É equivalente a:

--Peca temp = deck[i];
--deck[i] = deck[j];
--deck[j] = temp
--no java

function DistribuirPecas(monte)
    Game.monte = Embaralhar(monte)
    for i = 1, 7 do
        local peca = table.remove(Game.monte)
        table.insert(Game.maoJogador, peca)

        peca = table.remove(Game.monte)
        --peca.img = love.graphics.newImage("images/pecaVazia.png") Retirei para testes futuros
        table.insert(Game.maoIA, peca)
    end
end

local function imprimirBotaoCompra(x, y, botao)
    if botao.isHovering and VEZ_DO_JOGADOR then
        love.graphics.setColor(0.8, 0.8, 0.8, 1)
    else
        love.graphics.setColor(1, 1, 1, 1)
    end
    if x > botao.x and
        x < botao.x + botao.width and
        y > botao.y and
        y < botao.y + botao.height
    then
        botao.isHovering = true
    else
        botao.isHovering = false
    end

    --botao comprar
    love.graphics.rectangle("fill", botao.x, botao.y, botao.width, botao.height)
    love.graphics.setColor(0, 0, 0, 1)
    love.graphics.rectangle("line", botao.x, botao.y, botao.width, botao.height)
    local posicaoTexto = botao.y + (botao.height / 2) - (botao.fonte:getHeight() / 2)
    love.graphics.printf(botao.text, botao.x, posicaoTexto, botao.width, "center")
    love.graphics.setColor(1, 1, 1, 1)
end


function Game:draw()
    local mx = love.mouse.getX()
    local my = love.mouse.getY()


    love.graphics.clear(0.953, 0.953, 0.953, 1)

    imprimirBotaoCompra(mx, my, self.botaoComprar)
    imprimirPecas(mx, my, self.maoJogador)
    imprimirPecasIA(self.maoIA)

    --COMEÇAR OS TESTES PARA O DESENHO FINAL DO TABULEIRO, ONDE TODAS AS PEÇAS SERÃO COLOCADAS

    love.graphics.setColor(0, 1, 0, 1)

    love.graphics.rectangle("fill", 655, 475, 135, 75)

    love.graphics.setColor(1, 0, 0, 1)
    love.graphics.rectangle("fill", 790, 475, 135, 75)

    love.graphics.setColor(0, 0, 0, 1)
    love.graphics.rectangle("fill", 925, 475, 135, 75)

    love.graphics.setColor(1, 0, 0, 1)
    love.graphics.rectangle("fill", 1060, 475, 135, 75)

    love.graphics.setColor(0, 0, 0, 1)
    love.graphics.rectangle("fill", 1195, 475, 135, 75)

    love.graphics.setColor(0, 0, 0, 1)
    love.graphics.rectangle("fill", 520, 475, 135, 75)

    love.graphics.setColor(1, 0, 0, 1)
    love.graphics.rectangle("fill", 385, 475, 135, 75)

    love.graphics.setColor(0, 0, 0, 1)
    love.graphics.rectangle("fill", 250, 475, 135, 75)

    love.graphics.setColor(1, 0, 0, 1)
    love.graphics.rectangle("fill", 115, 475, 135, 75)

    love.graphics.setColor(1, 0, 0, 1)
    love.graphics.rectangle("fill", 1330, 415, 75, 135)

    love.graphics.setColor(0, 0, 0, 1)
    love.graphics.rectangle("fill", 1330, 280, 75, 135)

    love.graphics.setColor(1, 0, 0, 1)
    love.graphics.rectangle("fill", 1195, 280, 135, 75)

    love.graphics.setColor(0, 0, 0, 1)
    love.graphics.rectangle("fill", 1060, 280, 135, 75)

    love.graphics.setColor(1, 0, 0, 1)
    love.graphics.rectangle("fill", 925, 280, 135, 75)

    love.graphics.setColor(0, 0, 0, 1)
    love.graphics.rectangle("fill", 790, 280, 135, 75)

    love.graphics.setColor(1, 0, 0, 1)
    love.graphics.rectangle("fill", 655, 280, 135, 75)

    love.graphics.setColor(0, 0, 0, 1)
    love.graphics.rectangle("fill", 520, 280, 135, 75)

    love.graphics.setColor(1, 0, 0, 1)
    love.graphics.rectangle("fill", 385, 280, 135, 75)

    love.graphics.setColor(0, 0, 0, 1)
    love.graphics.rectangle("fill", 250, 280, 135, 75)

    love.graphics.setColor(1, 0, 0, 1)
    love.graphics.rectangle("fill", 115, 280, 135, 75)


    --PEÇAS RESTANTES NA PARTE INFERIOR DO TABULEIRO


    love.graphics.setColor(0, 0, 0, 1)
    love.graphics.rectangle("fill", 40, 475, 75, 135)

    love.graphics.setColor(1, 0, 0, 1)
    love.graphics.rectangle("fill", 40, 610, 75, 135)

    love.graphics.setColor(0, 0, 0, 1)
    love.graphics.rectangle("fill", 115, 670, 135, 75)

    love.graphics.setColor(1, 0, 0, 1)
    love.graphics.rectangle("fill", 250, 670, 135, 75)

    love.graphics.setColor(0, 0, 0, 1)
    love.graphics.rectangle("fill", 385, 670, 135, 75)

    love.graphics.setColor(1, 0, 0, 1)
    love.graphics.rectangle("fill", 520, 670, 135, 75)

    love.graphics.setColor(0, 0, 0, 1)
    love.graphics.rectangle("fill", 655, 670, 135, 75)

    --QUAIS AVISOS SAO NECESSARIOS PARA SEREM MOSTRADOS NA TELA (VEZ DO JOGADOR, VEZ DO OPONENTE, OPONENTE COMPRANDO E JOGO TRAVADO)

    love.graphics.setColor(0, 0, 0, 1)
    if VEZ_DO_JOGADOR then
        love.graphics.printf("Vez do jogador...", 1500, 300, 400, "center")
    elseif not VEZ_DO_JOGADOR and not self:existePecaJogavel(self.maoIA) then
        love.graphics.printf("Oponente esta comprando...", 1500, 300, 400, "center")
    elseif not VEZ_DO_JOGADOR and self:existePecaJogavel(self.maoIA) then
        love.graphics.printf("Vez do oponente...", 1500, 300, 400, "center")
    elseif (#self.monte == 0) and (not self:existePecaJogavel(self.maoJogador)) and self:existePecaJogavel(self.maoIA) then
        VEZ_DO_JOGADOR = false
    elseif (#self.monte == 0) and (not self:existePecaJogavel(self.maoJogador)) and (not self:existePecaJogavel(self.maoIA)) then
        love.graphics.printf("O jogo travou...", 1500, 300, 400, "center")
    end
end

function Game:update(dt)
    if GAME_OVER then
        return
    end

    local mx = love.mouse.getX()
    local my = love.mouse.getY()

    for _, piece in ipairs(self.maoJogador) do
        if mx > piece.x and
            mx < piece.x + piece.width and
            my > piece.y and
            my < piece.y + piece.height and
            self:pecaEncaixaNaMesa(piece) then
            piece.isHovering = true
        else
            piece.isHovering = false
        end
    end

    if VEZ_DO_JOGADOR == false then
        -- se a IA já comprou uma peça jogável e está esperando mostrar na mão
        if iaEsperandoJogarDepoisDaCompra then
            tempoMostrarCompraIA = tempoMostrarCompraIA + dt

            if tempoMostrarCompraIA >= delayMostrarCompraIA then
                iaEsperandoJogarDepoisDaCompra = false

                if DIFICULDADE_ESCOLHIDA == "Facil" then
                    iaFacil.jogada(self)
                elseif DIFICULDADE_ESCOLHIDA == "Medio" then
                    iaMedio.jogada(self)
                elseif DIFICULDADE_ESCOLHIDA == "Dificil" then
                    IADificil.jogada(self)
                end

                self:verificarFimDeJogo()
                VEZ_DO_JOGADOR = true
                tempoIA = 0
                iaProcessando = false
            end

            return
        end

        tempoIA = tempoIA + dt

        if tempoIA >= delayIA and not iaProcessando then
            iaProcessando = true

            if DIFICULDADE_ESCOLHIDA == "Facil" then
                local resultado = iaFacil.jogada(self)

                -- só passa a vez se não ficou esperando jogar depois da compra
                if not iaEsperandoJogarDepoisDaCompra then
                    self:verificarFimDeJogo()
                    VEZ_DO_JOGADOR = true
                    tempoIA = 0
                    iaProcessando = false
                end
            end

            if DIFICULDADE_ESCOLHIDA == "Medio" then
                local resultado = iaMedio.jogada(self)

                -- só passa a vez se não ficou esperando jogar depois da compra
                if not iaEsperandoJogarDepoisDaCompra then
                    self:verificarFimDeJogo()
                    VEZ_DO_JOGADOR = true
                    tempoIA = 0
                    iaProcessando = false
                end
            end
            if DIFICULDADE_ESCOLHIDA == "Dificil" then
                local resultado = IADificil.jogada(self)

                -- só passa a vez se não ficou esperando jogar depois da compra
                if not iaEsperandoJogarDepoisDaCompra then
                    self:verificarFimDeJogo()
                    VEZ_DO_JOGADOR = true
                    tempoIA = 0
                    iaProcessando = false
                end
            end
        end
    else
        tempoIA = 0
        iaProcessando = false
    end
end

function Game:mousepressed(x, y, button, istouch)
    if GAME_OVER then
        return
    end

    if VEZ_DO_JOGADOR == true then
        if button == 1 then
            for i, piece in ipairs(self.maoJogador) do
                if piece.isHovering == true then
                    if self.mesa:isEmpty() then
                        self.mesa:addLast(piece.valor1, piece.valor2)
                        table.remove(self.maoJogador, i)
                        self:verificarFimDeJogo()
                        VEZ_DO_JOGADOR = false
                        print("jogador jogou primeira peca:", piece.valor1, piece.valor2)
                        return
                    else
                        local esquerda = self.mesa:getHeadValue()
                        local direita = self.mesa:getTailValue()

                        if piece.valor1 == esquerda or piece.valor2 == esquerda then
                            self.mesa:addFirst(piece.valor1, piece.valor2)
                            table.remove(self.maoJogador, i)
                            self:verificarFimDeJogo()
                            VEZ_DO_JOGADOR = false
                            print("jogador jogou na esquerda:", piece.valor1, piece.valor2)
                            return
                        elseif piece.valor1 == direita or piece.valor2 == direita then
                            self.mesa:addLast(piece.valor1, piece.valor2)
                            table.remove(self.maoJogador, i)
                            self:verificarFimDeJogo()
                            VEZ_DO_JOGADOR = false
                            print("jogador jogou na direita:", piece.valor1, piece.valor2)
                            return
                        else
                            print("peca do jogador nao encaixa")
                            return
                        end
                    end
                end
            end

            if x > self.botaoComprar.x and
                x < self.botaoComprar.x + self.botaoComprar.width and
                y > self.botaoComprar.y and
                y < self.botaoComprar.y + self.botaoComprar.height
            then
                -- Se já existir peça jogável, não pode comprar
                if self:existePecaJogavel(self.maoJogador) then
                    print("Voce ja tem peca jogavel! Nao pode comprar.")
                    return
                end

                -- Senão compra até achar ou acabar o monte
                self:comprarAteEncontrarJogada()
            end
        end
    end
end

function Game:comprarAteEncontrarJogadaIA()
    print("ia entrou na funcao de compra")

    while #self.monte > 0 do
        local pecaComprada = table.remove(self.monte)

        if not pecaComprada then
            print("nenhuma peca foi removida do monte")
            self:verificarFimDeJogo()
            return false
        end

        table.insert(self.maoIA, pecaComprada)

        print("ia comprou:", pecaComprada.valor1 .. "-" .. pecaComprada.valor2)

        love.timer.sleep(0.3)

        if self:pecaEncaixaNaMesa(pecaComprada) then
            print("a peca comprada encaixa na mesa")

            iaEsperandoJogarDepoisDaCompra = true
            tempoMostrarCompraIA = 0
            return true
        else
            print("a peca comprada nao encaixa na mesa")
        end
    end

    print("monte acabou. ia passou a vez.")
    self:verificarFimDeJogo()
    return false
end

function Game:pecaEncaixaNaMesa(peca)
    if self.mesa:isEmpty() then
        return true
    end

    local esquerda = self.mesa:getHeadValue()
    local direita = self.mesa:getTailValue()

    if peca.valor1 == esquerda or
        peca.valor2 == esquerda or
        peca.valor1 == direita or
        peca.valor2 == direita then
        return true
    end

    return false
end

function Game:existePecaJogavel(mao)
    for _, peca in ipairs(mao) do
        if self:pecaEncaixaNaMesa(peca) then
            return true
        end
    end
    return false
end

function Game:comprarAteEncontrarJogada()
    while #self.monte > 0 do
        local pecaComprada = table.remove(self.monte)
        table.insert(self.maoJogador, pecaComprada)

        print("jogador comprou uma peca")

        if self:pecaEncaixaNaMesa(pecaComprada) then
            print("peca comprada pode ser jogada")
            self:verificarFimDeJogo()
            return
        end
    end

    print("monte acabou. jogador passou a vez.")
    self:verificarFimDeJogo()
end

function Game:somarPontos(mao)
    local soma = 0

    for _, peca in ipairs(mao) do
        soma = soma + peca.valor1 + peca.valor2
    end

    return soma
end

function Game:verificarFimDeJogo()
    -- vitória normal
    if #self.maoJogador == 0 then
        GAME_OVER = true
        GameState.switch("Vencedor", "jogador", "O jogador humano ficou sem peças.")
        return true
    end

    if #self.maoIA == 0 then
        GAME_OVER = true
        GameState.switch("Vencedor", "ia", "A IA ficou sem peças.")
        return true
    end

    -- travamento do jogo
    local monteAcabou = (#self.monte == 0)
    local jogadorPodeJogar = self:existePecaJogavel(self.maoJogador)
    local iaPodeJogar = self:existePecaJogavel(self.maoIA)

    if monteAcabou and not jogadorPodeJogar and not iaPodeJogar and self.maoJogador ~= 0 and self.maoIA ~= 0 then
        local pontosJogador = self:somarPontos(self.maoJogador)
        local pontosIA = self:somarPontos(self.maoIA)

        GAME_OVER = true

        if pontosJogador < pontosIA then
            GameState.switch(
                "Vencedor",
                "jogador",
                "Jogo travado. Jogador venceu por menos pontos: " .. pontosJogador .. " x " .. pontosIA
            )
        elseif pontosIA < pontosJogador then
            GameState.switch(
                "Vencedor",
                "ia",
                "Jogo travado. IA venceu por menos pontos: " .. pontosIA .. " x " .. pontosJogador
            )
        else
            GameState.switch(
                "Vencedor",
                "empate",
                "Jogo travado com empate em pontos: " .. pontosJogador .. " x " .. pontosIA
            )
        end

        return true
    end

    return false
end

return Game
