local GameState = require 'lib.GameState'
local ListaDuplamenteEncadeada = require 'lib.ListaDuplamenteEncadeada'
local Peca  = require 'lib.Peca'
local WIDTH, HEIGHT = love.window.getDesktopDimensions()

VEZ_DO_JOGADOR = true --Sempre começa na vez do jogador

local Game = {
    botaoComprar = {
            x = 1010,
            y = 878,
            width = 200,
            height = 80,
            text = "Comprar",
            isHovering = false
    },
    maoJogador = {},
    maoIA = {},
    monte = {}
}

function Game:enter()
    
    self.fonteBotoes = love.graphics.newFont(32)
    self.mesa = ListaDuplamenteEncadeada.new()

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
                height = 160
            }
            table.insert(self.monte,novaPeca)

        end
    end
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

function DistribuirPecas(monte)
    Game.monte = Embaralhar(monte)
    for i=0,7 do
        local peca = table.remove(Game.monte)
        table.insert(Game.maoJogador,peca)

        peca = table.remove(Game.monte)
        table.insert(Game.maoIA,peca)
    end


end
--OBS: Obs:
--deck[i], deck[j] = deck[j], deck[i]

--É equivalente a:

--Peca temp = deck[i];
--deck[i] = deck[j];
--deck[j] = temp
--no java

function Game:draw()
    local mx = love.mouse.getX()
    local my = love.mouse.getY()
    local posicaoAtual = 30

    love.graphics.clear(0.953, 0.953, 0.953, 1)

    --ADICIONANDO O BTOAO DE COMPRAR UMA NOVA PECA
    if self.botaoComprar.isHovering then
        love.graphics.setColor(0.8, 0.8, 0.8, 1)
    else
        love.graphics.setColor(1,1,1,1)
    end
    if mx > self.botaoComprar.x and
       mx < self.botaoComprar.x + self.botaoComprar.width and
       my > self.botaoComprar.y and
       my < self.botaoComprar.y + self.botaoComprar.height
    then
        self.botaoComprar.isHovering = true
    else
        self.botaoComprar.isHovering = false
    end

    love.graphics.rectangle("fill", self.botaoComprar.x, self.botaoComprar.y, self.botaoComprar.width, self.botaoComprar.height)

    love.graphics.setColor(0,0,0,1)

    love.graphics.rectangle("line", self.botaoComprar.x, self.botaoComprar.y, self.botaoComprar.width, self.botaoComprar.height)

    local posicaoTexto = self.botaoComprar.y + (self.botaoComprar.height / 2) - (self.fonteBotoes:getHeight() / 2)

    love.graphics.printf(self.botaoComprar.text, self.botaoComprar.x, posicaoTexto, self.botaoComprar.width, "center")

    love.graphics.setColor(1,1,1,1)
    --ADICIONANDO AS PECAS DO JOGO
    

    for _,piece in ipairs(self.maoJogador) do--NOTE:
        love.graphics.draw(piece.img,posicaoAtual,850)
        piece.x = posicaoAtual
        piece.y = 850 --alterar para variável posteriormente
        posicaoAtual = posicaoAtual + piece.width + 20
    end


    if VEZ_DO_JOGADOR == false then
        local pecaJogada -- variavel que armazena a peça jogada pela IA independente do nivel de dificuldade

        -- table.insert(self.mesa, pecaJogada)
        -- table.remove(self.maoJogador, posicaoPeçaJogada)
        -- VEZ_DO_JOGADOR = true
    end

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

function Game:update()
    local mx = love.mouse.getX()
    local my = love.mouse.getY()

    for _,piece in ipairs(self.maoJogador) do
    --LOGICA PARA ALTERAR O HOVERING DO BOTAO INICIAR JOGO
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

  
    
end

function Game:mousepressed(x, y, button, istouch)
    if VEZ_DO_JOGADOR == true then
        
        if button == 1 then
            
            for i,piece in ipairs(self.maoJogador) do
                if piece.isHovering == true then
                    table.insert(self.mesa, piece)
                    table.remove(self.maoJogador, i)

                    VEZ_DO_JOGADOR = false

                end
            end
        end
    end
   
end


return Game