local GameState = require 'lib.GameState'
local ListaDuplamenteEncadeada = require 'lib.ListaDuplamenteEncadeada'
local Peca  = require 'lib.Peca'
local WIDTH, HEIGHT = love.window.getDesktopDimensions()
local config = require "config"
local IAFacil = require "lib.iaFacil"


VEZ_DO_JOGADOR = true --Sempre começa na vez do jogador

local Game = {
    botaoComprar = {
        x = config.WIDTH - config.btnResponsiveX - 20, --20 de margem direita
        y = config.HEIGHT - config.btnResponsiveY -240,-- 2x tamnho da peça + 40 sobrando, alterar posteiormente
        width = config.btnResponsiveX-80 ,
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


local function imprimirPecas(x,y,pecas)
    calcular_disposicao_pecas_Mao(pecas,"jogador")
    for _,piece in ipairs(pecas) do--NOTE:
        if piece.isHovering and VEZ_DO_JOGADOR then
            love.graphics.setColor(1,1,1,1)
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
            
        love.graphics.draw(piece.img,piece.x,piece.y)
    end
        
        love.graphics.setColor(1,1,1,1)
    
end

local function imprimirPecasIA()
    calcular_disposicao_pecas_Mao(Game.maoIA,"IA")
        for _,piece in ipairs(Game.maoIA) do--NOTE:
            love.graphics.draw(piece.img,piece.x,piece.y)
        end
end


local function criarPecas(monte)
        for i=0,6 do
        for j=i,6 do
            local imagemPeca = love.graphics.newImage("images/"..i.."-"..j..".png")--carrega a imagem da peça
            print("images/"..i.."-"..j..".png")
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
            table.insert(monte,novaPeca)

        end
    end
end



function Game:enter()
    
    criarPecas(self.monte)
    DistribuirPecas(self.monte)

    
    
end


function Embaralhar(monte)
    local j
    for i = #monte, 2, -1 do
        j = love.math.random(i)
        monte[i], monte[j] = monte[j], monte[i]--OBS
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
    for i=1,7 do
        local peca = table.remove(Game.monte)
        table.insert(Game.maoJogador,peca)

        peca = table.remove(Game.monte)
        --peca.img = love.graphics.newImage("images/pecaVazia.png") Retirei para testes futuros
        table.insert(Game.maoIA,peca)
    end


end

local function imprimirBotaoCompra(x,y, botao)
    if botao.isHovering and VEZ_DO_JOGADOR then
        love.graphics.setColor(0.8, 0.8, 0.8, 1)
    else
        love.graphics.setColor(1,1,1,1)
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
    love.graphics.setColor(0,0,0,1)
    love.graphics.rectangle("line", botao.x, botao.y, botao.width, botao.height)
    local posicaoTexto = botao.y + (botao.height / 2) - (botao.fonte:getHeight() / 2)
    love.graphics.printf(botao.text, botao.x, posicaoTexto, botao.width, "center")
    love.graphics.setColor(1,1,1,1)
end


function Game:draw()
    local mx = love.mouse.getX()
    local my = love.mouse.getY()
    

    love.graphics.clear(0.953, 0.953, 0.953, 1)

    imprimirBotaoCompra(mx,my,self.botaoComprar)
    imprimirPecas(mx,my,self.maoJogador)
    imprimirPecasIA(self.maoIA)



    

--NOTE: Explicação do for acima:
-- em Lua não se sabe oque a tabela é, se é apenas uma tabela normal [1,2,3,4,5] ou uma tabela-hashtable {"primeiro"=5,"segundo"=2}
-- assim devemos deixar claro como deve se percorrer a tabela assim:
-- ipairs diz a Lua que deve percorrer a lista em ordem (1,2,3,4)
-- o "_" representa o index i que usamos normalmente. Porém, é algo comun usar o _ para representar um index que não pretedemos usar
-- isso é necessário pois, a linguagem lua retorna dois valores ao colocar apenas "for piece in lista"
-- irá retornar o valor do indice e o valor da lista, assim sendo necessário """"""tratar""""" ambos


--COMEÇAR OS TESTES PARA O DESENHO FINAL DO TABULEIRO, ONDE TODAS AS PEÇAS SERÃO COLOCADAS

love.graphics.setColor(0,1,0,1)

love.graphics.rectangle("fill", 655, 475, 135, 75)

love.graphics.setColor(1,0,0,1)
love.graphics.rectangle("fill", 790, 475, 135, 75)

love.graphics.setColor(0,0,0,1)
love.graphics.rectangle("fill", 925, 475, 135, 75)

love.graphics.setColor(1,0,0,1)
love.graphics.rectangle("fill", 1060, 475, 135, 75)

love.graphics.setColor(0,0,0,1)
love.graphics.rectangle("fill", 1195, 475, 135, 75)

love.graphics.setColor(0,0,0,1)
love.graphics.rectangle("fill", 520, 475, 135, 75)

love.graphics.setColor(1,0,0,1)
love.graphics.rectangle("fill", 385, 475, 135, 75)

love.graphics.setColor(0,0,0,1)
love.graphics.rectangle("fill", 250, 475, 135, 75)

love.graphics.setColor(1,0,0,1)
love.graphics.rectangle("fill", 115, 475, 135, 75)

love.graphics.setColor(1,0,0,1)
love.graphics.rectangle("fill", 1330, 415, 75, 135)

love.graphics.setColor(0,0,0,1)
love.graphics.rectangle("fill", 1330, 280, 75, 135)

love.graphics.setColor(1,0,0,1)
love.graphics.rectangle("fill", 1195, 280, 135, 75)

love.graphics.setColor(0,0,0,1)
love.graphics.rectangle("fill", 1060, 280, 135, 75)

love.graphics.setColor(1,0,0,1)
love.graphics.rectangle("fill", 925, 280, 135, 75)

love.graphics.setColor(0,0,0,1)
love.graphics.rectangle("fill", 790, 280, 135, 75)

love.graphics.setColor(1,0,0,1)
love.graphics.rectangle("fill", 655, 280, 135, 75)

love.graphics.setColor(0,0,0,1)
love.graphics.rectangle("fill", 520, 280, 135, 75)

love.graphics.setColor(1,0,0,1)
love.graphics.rectangle("fill", 385, 280, 135, 75)

love.graphics.setColor(0,0,0,1)
love.graphics.rectangle("fill", 250, 280, 135, 75)

love.graphics.setColor(1,0,0,1)
love.graphics.rectangle("fill", 115, 280, 135, 75)


--PEÇAS RESTANTES NA PARTE INFERIOR DO TABULEIRO


love.graphics.setColor(0,0,0,1)
love.graphics.rectangle("fill", 40, 475, 75, 135)

love.graphics.setColor(1,0,0,1)
love.graphics.rectangle("fill", 40, 610, 75, 135)

love.graphics.setColor(0,0,0,1)
love.graphics.rectangle("fill", 115, 670, 135, 75)

love.graphics.setColor(1,0,0,1)
love.graphics.rectangle("fill", 250, 670, 135, 75)

love.graphics.setColor(0,0,0,1)
love.graphics.rectangle("fill", 385, 670, 135, 75)

love.graphics.setColor(1,0,0,1)
love.graphics.rectangle("fill", 520, 670, 135, 75)

love.graphics.setColor(0,0,0,1)
love.graphics.rectangle("fill", 655, 670, 135, 75)
    
    
end

function Game:comprarAteEncontrarJogadaIA()

    while #self.monte > 0 do

        local pecaComprada = table.remove(self.monte)
        table.insert(self.maoIA, pecaComprada)

        print("IA comprou uma peça")

        -- verifica se agora pode jogar
        if self:pecaEncaixaNaMesa(pecaComprada) then
            print("IA encontrou peça jogável!")
            return true
        end
    end

    print("Monte acabou. IA passou a vez.")
    return false
end

function Game:update()
    local mx = love.mouse.getX()
    local my = love.mouse.getY()

    for _,piece in ipairs(self.maoJogador) do

        if mx > piece.x and
           mx < piece.x + piece.width and
           my > piece.y and
           my < piece.y + piece.height
        then
            piece.isHovering = true
        else
            piece.isHovering = false
        end
    end
    if not VEZ_DO_JOGADOR then
        IAFacil.jogada(self)
        VEZ_DO_JOGADOR = true
    end
 
    
end

function Game:mousepressed(x, y, button, istouch)
    if VEZ_DO_JOGADOR == true then
        
        if button == 1 then
            
            for i,piece in ipairs(self.maoJogador) do
                if piece.isHovering == true then
                    self.mesa:addFirst(piece.valor1, piece.valor2) 
                    
                    table.remove(self.maoJogador, i)

                    VEZ_DO_JOGADOR = false 

                end
            end

            if x > self.botaoComprar.x and
               x < self.botaoComprar.x + self.botaoComprar.width and
               y > self.botaoComprar.y and
               y < self.botaoComprar.y + self.botaoComprar.height
            then
            
            -- Se já existir peça jogável, não pode comprar
            if self:existePecaJogavel(self.maoJogador) then
                print("Você já tem peça jogável! Não pode comprar.")
                return
            end

            -- Senão compra até achar ou acabar o monte
            self:comprarAteEncontrarJogada()
        end
        end
    end
   
end

function Game:pecaEncaixaNaMesa(peca)
    -- Se mesa estiver vazia, qualquer peça pode ser jogada
    if self.mesa:isEmpty() then
        return true
    end

    -- AQUI você pode implementar depois a lógica real de dominó
    -- Por enquanto vou deixar sempre true para teste
    return true
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

        print("Jogador comprou uma peça")

        if self:pecaEncaixaNaMesa(pecaComprada) then
            print("Peça comprada pode ser jogada!")
            return
        end
    end

    print("Monte acabou. Jogador passou a vez.")
end

return Game