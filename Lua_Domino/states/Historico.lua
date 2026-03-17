local GameState = require 'lib.GameState'
local config = require 'config'

local historico = {

    listaRanking = {}
}

local function calcularPosicaoDoBotao(botao)
    local posicaoAtualX = config.WIDTH - botao.width * 1.25
    local posicaoAtualY = config.HEIGHT - botao.height * 2

    botao.x = posicaoAtualX
    botao.y = posicaoAtualY
end

function historico:enter()
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

    self.listaRanking = {}

    local query = [[
        SELECT nome_jogador, SUM(pontuacao) as pontuacao_total
        FROM historico_partidas
        GROUP BY nome_jogador
        ORDER BY pontuacao_total desc
        LIMIT 5 
    ]]
    
    local posicao = 1
    for linha in DB:nrows(query) do
        table.insert(self.listaRanking, {
            posicao = posicao,
            nome = linha.nome_jogador,
            pontuacao = linha.pontuacao_total
        })

        posicao = posicao + 1
    end
end

function historico:draw()
    -- NAO CRIEI LOOP PARA DESENHAR OS BOTOES NA TELA PQ NESSA TELA TEM APENAS UM BOTAO ENT DECIDI TRATAR COMO UMA VARIAVEL E NAO UMA TABELA
    love.graphics.clear(0.953, 0.953, 0.953, 1)

    love.graphics.setLineWidth(5)
    love.graphics.setColor(0,0,0,1)

    love.graphics.line(config.WIDTH / 2, 0, config.WIDTH / 2, config.HEIGHT)

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
    
    love.graphics.print("--- TOP 10 JOGADORES ---", 300, 50)

    -- Percorre a tabela que preenchemos lá no enter()
    for i, jogador in ipairs(self.listaRanking) do
        -- Calcula o espaçamento vertical (Y) para cada linha ficar embaixo da outra
        local posicaoY = 100 + (i * 35) 
        
        -- Monta o texto bonitinho. Ex: "1º - Arthur: 150 pts (Difícil)"
        local texto = jogador.posicao .. "º - " .. jogador.nome .. ": " .. jogador.pontuacao .. " pts"
        
        love.graphics.print(texto, 300, posicaoY)
    end
    
    love.graphics.setColor(1, 1, 1, 1)
end

function historico:update()
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

function historico:mousepressed(x, y, button, istouch)
    if button == 1 then
        if self.botaoVoltar.isHovering then
            GameState.switch('menuInicial')
        end
    end
end

return historico