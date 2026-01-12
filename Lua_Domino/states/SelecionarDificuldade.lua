local GameState = require 'lib.GameState'
local config = require 'config'

local btnDisposicaoTelaX = 0
local btnSpaceY = 20 * config.scaleY -- Espaçamento entre os botões

local selecionarDificuldade = {}

local function calcular_disposicao_botoes(botoes)
    local posicaoAtualY = (config.HEIGHT/2) -btnSpaceY - config.btnResponsiveY * 2 -- deixando o segundo botao no centro da tela
    for _,piece in ipairs(botoes) do
        btnDisposicaoTelaX = (config.WIDTH / 2) - piece.width / 2
        piece.x = btnDisposicaoTelaX
        piece.y = posicaoAtualY


        posicaoAtualY = posicaoAtualY + piece.height + btnSpaceY
    end
end

function selecionarDificuldade:enter()
    self.fonteBotoes = love.graphics.newFont(32* config.scaleX)

    -- Lista sequencial de botões
    self.botoes = {
        {
            id = "facil",
            x = 0, y = 0,
            width = config.btnResponsiveX, 
            height = config.btnResponsiveY,
            text = "Fácil",
            isHovering = false
        },
        {
            id = "medio",
            x = 0, y = 0,
            width = config.btnResponsiveX, 
            height = config.btnResponsiveY,
            text = "Médio",
            isHovering = false
        },
        {
            id = "dificil",
            x = 0, y = 0,
            width = config.btnResponsiveX, 
            height = config.btnResponsiveY,
            text = "Difícil",
            isHovering = false
        },
        {
            id = "voltar",
            x = 0, y = 0,
            width = config.btnResponsiveX*0.8, 
            height = config.btnResponsiveY*0.8,
            text = "Voltar",
            isHovering = false
        }
    }
    calcular_disposicao_botoes(self.botoes)
end



function selecionarDificuldade:draw()
    
    love.graphics.clear(0.953, 0.953, 0.953, 1)
    love.graphics.setLineWidth(5)
    love.graphics.setColor(0,0,0,1)
    love.graphics.line(config.WIDTH/2,0,config.WIDTH/2,config.HEIGHT)

    love.graphics.setLineWidth(3)

    local tamanhoCircle = 50 * config.scaleX
    love.graphics.circle("fill", config.WIDTH / 4, config.HEIGHT / 2, tamanhoCircle)
    love.graphics.circle("fill", config.WIDTH / 1.33 , config.HEIGHT / 2, tamanhoCircle)

    -- Loop para desenhar todos os botões

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

function selecionarDificuldade:update()
    local mx, my = love.mouse.getX(), love.mouse.getY()

    for _, botao in ipairs(self.botoes) do
        if mx > botao.x and mx < botao.x + botao.width and
           my > botao.y and my < botao.y + botao.height then
            botao.isHovering = true
        else
            botao.isHovering = false
        end
    end
end

function selecionarDificuldade:mousepressed(x, y, button, istouch)
    if button == 1 then
        for _, botao in ipairs(self.botoes) do
            if botao.isHovering then
                if botao.id == "voltar" then
                    GameState.switch('menuInicial')
                elseif botao.id == "facil" then
                    GameState.switch('Game')
                elseif botao.id == "medio" then
                    -- lógica para dificuldade média
                elseif botao.id == "dificil" then
                    -- lógica para dificuldade difícil
                end
            end
        end
    end
end

return selecionarDificuldade
