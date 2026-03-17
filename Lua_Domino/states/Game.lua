local GameState                      = require 'lib.GameState'
local ListaDuplamenteEncadeada       = require 'lib.ListaDuplamenteEncadeada'
local Peca                           = require 'lib.Peca'
local WIDTH, HEIGHT                  = love.window.getDesktopDimensions()
local config                         = require "config"
local iaFacil                        = require "lib.iaFacil"
local iaMedio                        = require "lib.iaMedio"
local IADificil                      = require "lib.iaDificil"

-- Variáveis de controle de estado
local tempoIA                        = 0
local delayIA                        = 1
local tempoMostrarCompraIA           = 0
local delayMostrarCompraIA           = 2.0
local iaProcessando                  = false
local iaEsperandoJogarDepoisDaCompra = false

VEZ_DO_JOGADOR                       = true
GAME_OVER                            = false

local Game = {
    botaoComprar = {
        x = config.WIDTH - config.btnResponsiveX - 20,
        y = config.HEIGHT - config.btnResponsiveY - 240,
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
    pecaSelecionada = nil,
}

local function calcular_disposicao_pecas_Mao(pecas, entidade)
    local posicaoAtualX = 0 
    local posicaoAtualY = 0
    if entidade == "jogador" then
        posicaoAtualY = config.HEIGHT - 20 - 160 --20 de margem inferior e 160 altura da peça(alterar para variável posteriormente

    elseif entidade =="IA" then
        posicaoAtualY = 20 --20 de margem superior
    end

    if #pecas%2 == 0 then
        posicaoAtualX = (config.WIDTH/2) - ((#pecas/2) * (100 + 20)) --100 largura da peça e 20 espaçamento entre as peças(alterar para variável posteriormente)

    else
        posicaoAtualX = (config.WIDTH/2) - (math.floor(#pecas/2) * (100 + 20)) - (100/2) --100 largura da peça e 20 espaçamento entre as peças(alterar para variável posteriormente)
    end

    for _,piece in ipairs(pecas) do
            piece.x = posicaoAtualX
            piece.y = posicaoAtualY


            posicaoAtualX = posicaoAtualX + piece.width + 20

        end
end

local function imprimirPecas(x, y, pecas)
    calcular_disposicao_pecas_Mao(pecas, "jogador")
    for _, piece in ipairs(pecas) do
        if piece.isHovering and VEZ_DO_JOGADOR then
            love.graphics.setColor(1, 1, 1, 1)
        else
            love.graphics.setColor(0.9, 0.9, 0.9, 1)
        end
        if x > piece.x and x < piece.x + piece.width and y > piece.y and y < piece.y + piece.height then
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
    for _, piece in ipairs(Game.maoIA) do
        love.graphics.draw(piece.img, piece.x, piece.y)

        local imagemPecaInvertida = love.graphics.newImage("images/pecaVazia.png")

        love.graphics.draw(imagemPecaInvertida, piece.x, piece.y)

    end
end

function Game:imprimirMonte()
    local imagemMonte = love.graphics.newImage("images/Monte1.png")--carrega a imagem do monte
    if #self.monte == 1 then
        love.graphics.draw(imagemMonte, self.botaoComprar.x + self.botaoComprar.width / 2, self.botaoComprar.y - self.botaoComprar.height*2) --posição fixa para o monte
    elseif #self.monte == 2 then
        imagemMonte = love.graphics.newImage("images/Monte2.png")--carrega a imagem do monte
        love.graphics.draw(imagemMonte, self.botaoComprar.x + self.botaoComprar.width / 2, self.botaoComprar.y - self.botaoComprar.height*2) --posição fixa para o monte
    elseif #self.monte >= 3 then
        imagemMonte = love.graphics.newImage("images/Monte3+.png")--carrega a imagem do monte
        love.graphics.draw(imagemMonte, self.botaoComprar.x + (self.botaoComprar.width / 2)-40, self.botaoComprar.y - self.botaoComprar.height*2) --posição fixa para o monte
    end
end

local function criarPecas(monte)
    for i = 0, 6 do
        for j = i, 6 do
            local novaPeca = Peca.new(i, j)
            local imagemPeca = love.graphics.newImage("images/" .. i .. "-" .. j .. ".png")
            if (i==1 and j ==2) and (love.math.random(100) > 0) then
                imagemPeca = love.graphics.newImage("images/1-2Referencia.png")
            end
            novaPeca.img = imagemPeca
            table.insert(monte, novaPeca)
        end
    end
end

function Embaralhar(monte)
    local j
    for i = #monte, 2, -1 do
        j = love.math.random(i)
        monte[i], monte[j] = monte[j], monte[i]
    end
    return monte
end

function DistribuirPecas(monte)
    Game.monte = Embaralhar(monte)
    for i=1,7 do
        local peca = table.remove(Game.monte)
        table.insert(Game.maoJogador,peca)

        peca = table.remove(Game.monte)
        table.insert(Game.maoIA,peca)
    end


end

function Game:enter(dificuldade)
    self.dificuldade = dificuldade or "facil"
    self.maoJogador = {}
    self.maoIA = {}
    self.monte = {}
    self.mesa = ListaDuplamenteEncadeada.new()
    self.pecaSelecionada = nil

    VEZ_DO_JOGADOR = true
    GAME_OVER = false
    iaProcessando = false
    iaEsperandoJogarDepoisDaCompra = false

    criarPecas(self.monte)
    DistribuirPecas(self.monte)
end

local function imprimirMesa(mesa)
    love.graphics.push()
    love.graphics.scale(0.4, 0.4)
    if not mesa:isEmpty() then
        local aux = mesa.head
        if aux.previousNode ~= nil then aux = aux.previousNode end
        
        for i = 0, mesa:count() - 1, 1 do
            if aux.peca.rightValue == -1 then
                local myColor = {0, 1, 0, 1}
                love.graphics.setColor(myColor)
                love.graphics.draw(aux.peca.img, aux.peca.x, aux.peca.y, math.rad(270), 1, 1, aux.peca.width / 2, aux.peca.height / 2)
                love.graphics.setColor(1, 1, 1, 1)
            elseif aux.peca.turned then
                love.graphics.draw(aux.peca.img, aux.peca.x, aux.peca.y, math.rad(90), 1, 1, aux.peca.width / 2, aux.peca.height / 2)
            else
                love.graphics.draw(aux.peca.img, aux.peca.x, aux.peca.y, math.rad(270), 1, 1, aux.peca.width / 2, aux.peca.height / 2)
            end
            if aux.nextNode ~= nil then aux = aux.nextNode end
        end
    end
    love.graphics.pop()
end

local function imprimirBotaoCompra(x, y, botao)
    if botao.isHovering and VEZ_DO_JOGADOR then
        love.graphics.setColor(0.8, 0.8, 0.8, 1)
    else
        love.graphics.setColor(1, 1, 1, 1)
    end
    if x > botao.x and x < botao.x + botao.width and y > botao.y and y < botao.y + botao.height then
        botao.isHovering = true
    else
        botao.isHovering = false
    end

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
    imprimirPecasIA()
    imprimirMesa(self.mesa)
    self:imprimirMonte()

    -- Avisos na tela (Lógica da V2)
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
    if GAME_OVER then return end

    local mx = love.mouse.getX()
    local my = love.mouse.getY()

    -- Hover na mão do jogador (V1)
    for _, piece in ipairs(self.maoJogador) do
        if mx > piece.x and mx < piece.x + piece.width and my > piece.y and my < piece.y + piece.height then
            piece.isHovering = true
        else
            piece.isHovering = false
        end
    end

    -- Hover na mesa (V1)
    local mouseMesaX = mx / 0.4
    local mouseMesaY = my / 0.4

    if not self.mesa:isEmpty() then
        local aux = self.mesa.head
        if aux.previousNode ~= nil then aux = aux.previousNode end
        
        while aux ~= nil do
            local pieceMesa = aux.peca
            local esquerda = pieceMesa.x - (pieceMesa.height / 2)
            local direita  = pieceMesa.x + (pieceMesa.height / 2)
            local topo     = pieceMesa.y - (pieceMesa.width / 2)
            local base     = pieceMesa.y + (pieceMesa.width / 2)

            if mouseMesaX > esquerda and mouseMesaX < direita and mouseMesaY > topo and mouseMesaY < base then
                pieceMesa.isHovering = true
            else
                pieceMesa.isHovering = false
            end
            aux = aux.nextNode
        end
    end

    -- Lógica de Turno da IA (V2)
    if not VEZ_DO_JOGADOR then
        if iaEsperandoJogarDepoisDaCompra then
            tempoMostrarCompraIA = tempoMostrarCompraIA + dt
            if tempoMostrarCompraIA >= delayMostrarCompraIA then
                iaEsperandoJogarDepoisDaCompra = false

                if self.dificuldade == "facil" then iaFacil.jogada(self)
                elseif self.dificuldade == "medio" then iaMedio.jogada(self)
                elseif self.dificuldade == "dificil" then IADificil.jogada(self)
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

            if self.dificuldade == "facil" then iaFacil.jogada(self)
            elseif self.dificuldade == "medio" then iaMedio.jogada(self)
            elseif self.dificuldade == "dificil" then IADificil.jogada(self)
            end

            if not iaEsperandoJogarDepoisDaCompra then
                self:verificarFimDeJogo()
                VEZ_DO_JOGADOR = true
                tempoIA = 0
                iaProcessando = false
            end
        end
    else
        tempoIA = 0
        iaProcessando = false
    end
end

local function girarPeca(peca)
    local temp = peca.leftValue
    peca.leftValue = peca.rightValue
    peca.rightValue = temp
    peca.turned = not peca.turned
end

function Game:mousepressed(x, y, button, istouch)
    if GAME_OVER or VEZ_DO_JOGADOR == false or button ~= 1 then return end

    -- 1. Espaços verdes da mesa
    -- 1. Espaços verdes da mesa
    if self.pecaSelecionada ~= nil and not self.mesa:isEmpty() then
        local aux = self.mesa.head
        if aux.previousNode ~= nil then aux = aux.previousNode end
        
        while aux ~= nil do
            if aux.peca.isHovering == true and aux.peca.rightValue == -1 then
                
                -- Se clicou na primeira posição (Esquerda)
                if aux == self.mesa.head.previousNode then
                    -- VERIFICA SE PRECISA GIRAR ANTES DE ENCAIXAR NA ESQUERDA
                    if self.pecaSelecionada.leftValue == self.mesa:getHeadValue() then
                        girarPeca(self.pecaSelecionada)
                    end
                    
                    self.pecaSelecionada.x = config.WIDTH - (self.mesa.leftSize * self.pecaSelecionada.height)
                    self.pecaSelecionada.y = config.HEIGHT
                    self.mesa:addFirst(self.pecaSelecionada)
                    
                -- Se clicou na última posição (Direita)
                elseif aux == self.mesa.tail.nextNode then
                    -- VERIFICA SE PRECISA GIRAR ANTES DE ENCAIXAR NA DIREITA
                    if self.pecaSelecionada.rightValue == self.mesa:getTailValue() then
                        girarPeca(self.pecaSelecionada)
                    end
                    
                    self.pecaSelecionada.x = config.WIDTH + (self.mesa.rightSize * self.pecaSelecionada.height)
                    self.pecaSelecionada.y = config.HEIGHT
                    self.mesa:addLast(self.pecaSelecionada)
                end

                self.mesa:removePecasGraficas()
                self.pecaSelecionada = nil -- Limpa a seleção
                self:verificarFimDeJogo()
                VEZ_DO_JOGADOR = false 
                return -- Encerra o clique
            end
            aux = aux.nextNode
        end
    end
    -- 2. Clicou numa peça da mão
    for i, piece in ipairs(self.maoJogador) do
        if piece.isHovering == true then
            if self.mesa:isEmpty() then
                piece.x = config.WIDTH 
                piece.y = config.HEIGHT
                self.mesa:addFirst(piece)
                table.remove(self.maoJogador, i)
                self:verificarFimDeJogo()
                VEZ_DO_JOGADOR = false

            elseif self.mesa:EhCompativelDoisLados(piece) then
                self.mesa:addPecaGraficaEsquerda(config.WIDTH - (self.mesa.leftSize * piece.height), config.HEIGHT)
                self.mesa:addPecaGraficaDireita(config.WIDTH + (self.mesa.rightSize * piece.height), config.HEIGHT) 
                self.pecaSelecionada = piece 
                table.remove(self.maoJogador, i)

            elseif piece:EhCompativelLadoDireito(self.mesa:getHeadValue()) then
                piece.x = config.WIDTH - (self.mesa.leftSize * piece.height)
                piece.y = config.HEIGHT
                self.mesa:addFirst(piece)
                table.remove(self.maoJogador, i)
                self:verificarFimDeJogo()
                VEZ_DO_JOGADOR = false

            elseif piece:EhCompativelLadoEsquerdo(self.mesa:getHeadValue()) then
                girarPeca(piece)
                piece.x = config.WIDTH - (self.mesa.leftSize * piece.height)
                piece.y = config.HEIGHT
                self.mesa:addFirst(piece)
                table.remove(self.maoJogador, i)
                self:verificarFimDeJogo()
                VEZ_DO_JOGADOR = false

            elseif piece:EhCompativelLadoDireito(self.mesa:getTailValue()) then
                girarPeca(piece)
                piece.x = config.WIDTH + (self.mesa.rightSize * piece.height)
                piece.y = config.HEIGHT
                self.mesa:addLast(piece)
                table.remove(self.maoJogador, i)
                self:verificarFimDeJogo()
                VEZ_DO_JOGADOR = false

            elseif piece:EhCompativelLadoEsquerdo(self.mesa:getTailValue()) then
                piece.x = config.WIDTH + (self.mesa.rightSize * piece.height)
                piece.y = config.HEIGHT
                self.mesa:addLast(piece)
                table.remove(self.maoJogador, i)
                self:verificarFimDeJogo()
                VEZ_DO_JOGADOR = false
            end
            return
        end
    end

    -- 3. Clicou em Comprar
    if x > self.botaoComprar.x and x < self.botaoComprar.x + self.botaoComprar.width and
       y > self.botaoComprar.y and y < self.botaoComprar.y + self.botaoComprar.height then
        if self:existePecaJogavel(self.maoJogador) then
            print("Você já tem peça jogável! Não pode comprar.")
            return
        end
        self:comprarAteEncontrarJogada()
    end
end

function Game:pecaEncaixaNaMesa(peca)
    if self.mesa:isEmpty() then return true end

    local esquerda = self.mesa:getHeadValue()
    local direita = self.mesa:getTailValue()

    if peca.leftValue == esquerda or peca.rightValue == esquerda or
       peca.leftValue == direita or peca.rightValue == direita then
        return true
    end
    return false
end

function Game:existePecaJogavel(mao)
    for _, peca in ipairs(mao) do
        if self:pecaEncaixaNaMesa(peca) then return true end
    end
    return false
end

function Game:comprarAteEncontrarJogada()
    while #self.monte > 0 do
        local pecaComprada = table.remove(self.monte)
        table.insert(self.maoJogador, pecaComprada)
        print("Jogador comprou uma peca")

        if self:pecaEncaixaNaMesa(pecaComprada) then
            print("Peca comprada pode ser jogada")
            self:verificarFimDeJogo()
            return
        end
    end
    print("Monte acabou. Jogador passou a vez.")
    VEZ_DO_JOGADOR = false
    self:verificarFimDeJogo()
end

function Game:comprarAteEncontrarJogadaIA()
    while #self.monte > 0 do
        local pecaComprada = table.remove(self.monte)
        if not pecaComprada then
            self:verificarFimDeJogo()
            return false
        end

        table.insert(self.maoIA, pecaComprada)
        print("IA comprou: " .. pecaComprada.leftValue .. "-" .. pecaComprada.rightValue)

        if self:pecaEncaixaNaMesa(pecaComprada) then
            iaEsperandoJogarDepoisDaCompra = true
            tempoMostrarCompraIA = 0
            return true
        end
    end
    print("Monte acabou. IA passou a vez.")
    self:verificarFimDeJogo()
    return false
end

function Game:somarPontos(mao)
    local soma = 0
    for _, peca in ipairs(mao) do
        soma = soma + peca.leftValue + peca.rightValue
    end
    return soma
end

function Game:verificarFimDeJogo()
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

    local monteAcabou = (#self.monte == 0)
    local jogadorPodeJogar = self:existePecaJogavel(self.maoJogador)
    local iaPodeJogar = self:existePecaJogavel(self.maoIA)

    if monteAcabou and not jogadorPodeJogar and not iaPodeJogar and #self.maoJogador ~= 0 and #self.maoIA ~= 0 then
        local pontosJogador = self:somarPontos(self.maoJogador)
        local pontosIA = self:somarPontos(self.maoIA)

        GAME_OVER = true

        if pontosJogador < pontosIA then
            GameState.switch("Vencedor", "jogador", "Jogo travado. Jogador venceu por menos pontos: " .. pontosJogador .. " x " .. pontosIA)
        elseif pontosIA < pontosJogador then
            GameState.switch("Vencedor", "ia", "Jogo travado. IA venceu por menos pontos: " .. pontosIA .. " x " .. pontosJogador)
        else
            GameState.switch("Vencedor", "empate", "Jogo travado com empate em pontos: " .. pontosJogador .. " x " .. pontosIA)
        end
        return true
    end
    return false
end

return Game