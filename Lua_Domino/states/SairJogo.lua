local GameState = require 'lib.GameState'
local config = require 'config'

local btnDisposicaoTelaY = 0
local btnSpace = 20 * config.scaleY



local sairJogo = { }


local function calcular_disposicao_botoes(botoes)
    --APLICAR UM LOGICA DIFERENTE PARA CALCULAR A POSICAO DOS BOTOES VISTO QUE OS BOTOES AGORA ESTAO DISPOSTOS NA HORIZONTAL E NAO NA VERTICAL
    -- USAR APENAS A METADE DA TELA E O TAMANHO DOS BOTOES
    local posicaoAtualX = (config.WIDTH / 2) - config.btnResponsiveY * 7

    for _,piece in ipairs(botoes) do
        btnDisposicaoTelaY = (config.HEIGHT / 2) - config.btnResponsiveY 

        piece.x = posicaoAtualX
        piece.y = btnDisposicaoTelaY

        posicaoAtualX = posicaoAtualX + (piece.width * 2.3) + btnSpace
    end


end


function sairJogo:enter()
    self.title = "Domino"
    self.fonteBotoes = love.graphics.newFont(32 * config.scaleX)

    

    self.botoes = {
         {
            id = "botaoConfirmarSaida",
            width = config.btnResponsiveX,
            height = config.btnResponsiveY,
            x = 0,
            y = 0,
            text = "CONFIRMAR",
            isHovering = false
        },

        {
            id = "botaoVoltarMenu",
            width = config.btnResponsiveX,
            height = config.btnResponsiveY,
            x = 0,
            y = 0,
            text = "VOLTAR",
            isHovering = false
        },
    }

    calcular_disposicao_botoes(self.botoes)
    
end

function sairJogo:draw()
    --CRIANDO A LINHA PARA DIVIDIR A TELA
    love.graphics.clear(0.953, 0.953, 0.953, 1)
    love.graphics.setLineWidth(5)

    love.graphics.setColor(0,0,0,1)

    love.graphics.line(config.WIDTH / 2 ,0,config.WIDTH / 2,config.HEIGHT)

    love.graphics.setLineWidth(3)

    --CRIANDO OS CIRCULOS
    local tamanhoCircle = 50 * config.scaleX
    love.graphics.circle("fill", config.WIDTH*0.1, config.HEIGHT * 0.2, tamanhoCircle)
    love.graphics.circle("fill", config.WIDTH* 0.25, config.HEIGHT * 0.2, tamanhoCircle)
    love.graphics.circle("fill", config.WIDTH * 0.38, config.HEIGHT * 0.2, tamanhoCircle)

    love.graphics.circle("fill", config.WIDTH * 0.1, config.HEIGHT * 0.68, tamanhoCircle)
    love.graphics.circle("fill", config.WIDTH * 0.25, config.HEIGHT * 0.68, tamanhoCircle)
    love.graphics.circle("fill", config.WIDTH * 0.38, config.HEIGHT * 0.68, tamanhoCircle)

    love.graphics.circle("fill", config.WIDTH * 0.6, config.HEIGHT * 0.2, tamanhoCircle)
    love.graphics.circle("fill", config.WIDTH * 0.75, config.HEIGHT * 0.2, tamanhoCircle)
    love.graphics.circle("fill", config.WIDTH * 0.9, config.HEIGHT * 0.2, tamanhoCircle)

    love.graphics.circle("fill", config.WIDTH * 0.6, config.HEIGHT * 0.68, tamanhoCircle)
    love.graphics.circle("fill", config.WIDTH * 0.75, config.HEIGHT * 0.68, tamanhoCircle)
    love.graphics.circle("fill", config.WIDTH * 0.9, config.HEIGHT * 0.68, tamanhoCircle)


    for _,piece in ipairs(self.botoes) do
        if piece.isHovering then
            love.graphics.setColor(0.8,0.8,0.8,1)
        else
            love.graphics.setColor(1,1,1,1)
        end

        love.graphics.rectangle("fill", piece.x, piece.y, piece.width, piece.height)

        love.graphics.setColor(0, 0, 0, 1)
        love.graphics.setLineWidth(3)

        love.graphics.rectangle("line", piece.x, piece.y, piece.width, piece.height)

        love.graphics.setLineWidth(1)

        love.graphics.setFont(self.fonteBotoes)

        local posicaoTexto = piece.y + (piece.height / 2) - self.fonteBotoes:getHeight() / 2

        love.graphics.printf(piece.text, piece.x, posicaoTexto, piece.width, "center")
    end
end

function sairJogo:update()
    local mx = love.mouse.getX()
    local my = love.mouse.getY()


    for _,piece in ipairs(self.botoes) do
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

function sairJogo:mousepressed(x, y, button, istouch)
    
    if button == 1 then
        for _,piece in ipairs(self.botoes) do
            if piece.isHovering and (piece.id == "botaoConfirmarSaida") then
                os.exit(0)
            end

            if piece.isHovering and (piece.id == "botaoVoltarMenu") then
                GameState.switch('menuInicial')
            end
        end
    end
end


return sairJogo