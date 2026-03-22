local GameState = require 'lib.GameState'
local config = require 'config'

local ranking = {

    listaRanking = {}
}

local posicaoRetangulo = 0

local function calcularPosicaoDoBotao(botao)
    local posicaoAtualX = config.WIDTH - botao.width * 1.25
    local posicaoAtualY = config.HEIGHT - botao.height * 2

    botao.x = posicaoAtualX
    botao.y = posicaoAtualY
end

function ranking:enter()
    self.fonteBotoes = love.graphics.newFont(32)

    self.botaoVoltar = {
        x = 1010,
        y = 878,
        width = 370,
        height = 90,
        text = "VOLTAR",
        isHovering = false
    }
    

    calcularPosicaoDoBotao(self.botaoVoltar)
end

function ranking:draw()
    -- NAO CRIEI LOOP PARA DESENHAR OS BOTOES NA TELA PQ NESSA TELA TEM APENAS UM BOTAO ENT DECIDI TRATAR COMO UMA VARIAVEL E NAO UMA TABELA
    love.graphics.clear(0.953, 0.953, 0.953, 1)

    love.graphics.setLineWidth(5)
    love.graphics.setColor(0,0,0,1)

    if self.botaoVoltar.isHovering then
        love.graphics.setColor(0.8, 0.8, 0.8, 1)
    else
        love.graphics.setColor(1,1,1,1)
    end

    love.graphics.rectangle("fill", self.botaoVoltar.x, self.botaoVoltar.y, self.botaoVoltar.width, self.botaoVoltar.height)

    love.graphics.setColor(0, 0, 0, 1)
    love.graphics.setLineWidth(3)

    love.graphics.rectangle("line", self.botaoVoltar.x, self.botaoVoltar.y, self.botaoVoltar.width, self.botaoVoltar.height)

    local posicaoTexto = self.botaoVoltar.y + (self.botaoVoltar.height / 2) - (self.fonteBotoes:getHeight() / 2)

    love.graphics.printf(self.botaoVoltar.text, self.botaoVoltar.x, posicaoTexto, self.botaoVoltar.width, "center")

    --CRIAR UM LACO DE REPETICAO PARA ADICIONAR AS PARTIDAS QUE APARECERAO NO HISTORICO

    love.graphics.setColor(0, 0, 0, 1)
    
    love.graphics.print("Funcionalidade desativada (Mude de branch para ter acesso ao jogo com banco de dados)", 200, 200)

    -- Percorre a tabela que preenchemos lá no enter()
    for i, jogador in ipairs(self.listaRanking) do

        love.graphics.setColor(0,0,0,1)
        -- Calcula o espaçamento vertical (Y) para cada linha ficar embaixo da outra
        local posicaoY = 100 + (i * 100) 

        self.posicaoRetangulo = (100 + posicaoRetangulo) * i

        local posicaoTexto = (posicaoY + (100 / 2) - (self.fonteBotoes:getHeight() / 2))


        love.graphics.rectangle("line", 100, posicaoY, 1700, 100)
        
        local texto = jogador.posicao .. "º - " .. jogador.nome .. ": " .. jogador.pontuacao .. " pts"
        
        love.graphics.printf(texto, 100, posicaoTexto, 1700, "center")
    end
    
    love.graphics.setColor(1, 1, 1, 1)
end

function ranking:update()
    local mx = love.mouse.getX()
    local my = love.mouse.getY()

    if mx > self.botaoVoltar.x and
       mx < self.botaoVoltar.x + self.botaoVoltar.width and
       my > self.botaoVoltar.y and
       my < self.botaoVoltar.y + self.botaoVoltar.height
    then
        self.botaoVoltar.isHovering = true
    else
        self.botaoVoltar.isHovering = false
    end
    
end

function ranking:mousepressed(x, y, button, istouch)
    if button == 1 then
        if self.botaoVoltar.isHovering then
            GameState.switch('menuInicial')
        end
    end
end

return ranking