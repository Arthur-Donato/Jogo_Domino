local config = require "config" --Classe com as variáveis globais para configuração do jogo
local GameState = require 'lib.GameState'


local btnDisposicaoTelaX = 0
local btnSpaceY = 20 * config.scaleY -- Espaçamento entre os botões

local menuInicial = {}


local function calcular_disposicao_botoes(botoes)
    local posicaoAtualY = (config.HEIGHT/2) -btnSpaceY - config.btnResponsiveY * 2 -- deixando o segundo botao no centro da tela
    for _,piece in ipairs(botoes) do
        btnDisposicaoTelaX = (config.WIDTH / 2) - piece.width / 2
        piece.x = btnDisposicaoTelaX
        piece.y = posicaoAtualY


        posicaoAtualY = posicaoAtualY + piece.height + btnSpaceY
    end
end

function menuInicial:enter()
    self.title = "Domino"

    self.botoes = {
        {
            id = "botaoIniciarJogo",
            width = config.btnResponsiveX,
            height = config.btnResponsiveY,
            text = "Iniciar Jogo",
            x = 0,
            y = 0,
            isHovering = false
        },

        {
            id = "botaoHistorico",
            width = config.btnResponsiveX,
            height = config.btnResponsiveY,
            text = "Histórico",
            x = 0,
            y = 0,
            isHovering = false
        },

        {   
            id = "botaoSairJogo",
            width = config.btnResponsiveX*0.9,
            height = config.btnResponsiveY*0.9,
            text = "Sair do Jogo",
            x = 0,
            y = 0,
            isHovering = false
        }
    }

    self.fonteBotoes = love.graphics.newFont(32 * config.scaleX)
    calcular_disposicao_botoes(self.botoes)

end

function menuInicial:draw()
    --CRIANDO A LINHA PARA DIVIDIR A TELA AO MEIO
    love.graphics.clear(0.953, 0.953, 0.953, 1)
    love.graphics.setLineWidth(5)

    love.graphics.setColor(0,0,0,1)

    love.graphics.line(config.WIDTH/2,0,config.WIDTH/2,config.HEIGHT)

    
    --CRIANDO AS CIRCUNFERENCIAS PRESENTES NA TELA

    local tamanhoCircle = 50 * config.scaleX

    love.graphics.circle("fill", config.WIDTH*0.1, config.HEIGHT*0.2, tamanhoCircle)
    love.graphics.circle("fill", config.WIDTH*0.38, config.HEIGHT*0.2, tamanhoCircle)
    love.graphics.circle("fill", config.WIDTH*0.1, config.HEIGHT*0.68, tamanhoCircle)
    love.graphics.circle("fill", config.WIDTH*0.38, config.HEIGHT*0.68,tamanhoCircle)
    love.graphics.circle("fill", config.WIDTH*0.61, config.HEIGHT*0.2, tamanhoCircle)
    love.graphics.circle("fill", config.WIDTH*0.88, config.HEIGHT*0.2, tamanhoCircle)
    love.graphics.circle("fill", config.WIDTH*0.61, config.HEIGHT*0.68,tamanhoCircle)
    love.graphics.circle("fill", config.WIDTH*0.88, config.HEIGHT*0.68,tamanhoCircle)

    --CRIANDO O BOTAO DE INICIO DE JOGO
    for _,piece in ipairs(self.botoes) do
        
        if piece.isHovering then
            love.graphics.setColor(0.8, 0.8, 0.8, 1)
        else
            love.graphics.setColor(1, 1, 1, 1)
        end

        love.graphics.rectangle("fill", piece.x, piece.y, piece.width, piece.height)

        love.graphics.setColor(0,0,0,1)
        love.graphics.setLineWidth(3)

        love.graphics.rectangle("line", piece.x, piece.y, piece.width, piece.height)

        love.graphics.setLineWidth(1)

        love.graphics.setFont(self.fonteBotoes)

        local posicaoTexto = piece.y + (piece.height / 2) - (self.fonteBotoes:getHeight() / 2)

        love.graphics.printf(piece.text, piece.x, posicaoTexto, piece.width, "center")


    end
    
end

function menuInicial:update()
    --FAZENDO A LOGICA PARA ALTERAR O HOVERING DOS BOTOES 
    local mx = love.mouse.getX()
    local my = love.mouse.getY()

    for _,piece in ipairs(self.botoes) do
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

function menuInicial:mousepressed(x, y, button, istouch)
    if button == 1 then

        if self.botoes[1].isHovering then
            GameState.switch('selecionarDificuldade')
        end

        if self.botoes[2].isHovering then
            GameState.switch('historico')
        end

        if self.botoes[3].isHovering then
            GameState.switch('sairJogo')
        end
        
    end
end

return menuInicial