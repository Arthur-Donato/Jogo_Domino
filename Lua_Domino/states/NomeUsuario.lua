local config = require 'config'
local GameState = require 'lib.GameState'

local NomeUsuario = {}

-- CRIAR TELA PARA INSERIR NOME DO JOGADOR UTILIZANDO O DESIGN FEITO NO FIGMA
-- AO CLICAR NO BOTAO DE CONFIRMAR O NOME O JOGADOR SERA REDIRECIONADO PARA A TELA DE SELECIONAR DIFICULDADE, E O FLUXO CONTINUA NORMALMENTE DO JOGO COMO ERA ANTES

function NomeUsuario: enter()

    self.fonteBotoes = love.graphics.newFont(32)

    self.botaoConfirmar = {
        x = 1410,
        y = 878,
        width = 370,
        height = 90,
        text = "CONFIRMAR",
        isHovering = false
    }

    self.botaoVoltar = {
        x = 110,
        y = 878,
        width = 370,
        height = 90,
        text = "VOLTAR",
        isHovering = false
    }
end


function NomeUsuario: draw()
    love.graphics.clear(0.953, 0.953, 0.953, 1)
    love.graphics.setLineWidth(5)
    love.graphics.setColor(0,0,0,1)
    love.graphics.line(config.WIDTH/2,0,config.WIDTH/2,config.HEIGHT)

    love.graphics.setLineWidth(3)

    local tamanhoCircle = 50 * config.scaleX
    love.graphics.circle("fill", config.WIDTH / 4, config.HEIGHT / 2, tamanhoCircle)
    love.graphics.circle("fill", config.WIDTH / 1.33 , config.HEIGHT / 2, tamanhoCircle)

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
    

    if self.botaoConfirmar.isHovering then
        love.graphics.setColor(0.8, 0.8, 0.8, 1)
    else
        love.graphics.setColor(1,1,1,1)
    end

    love.graphics.rectangle("fill", self.botaoConfirmar.x, self.botaoConfirmar.y, self.botaoConfirmar.width, self.botaoConfirmar.height)

    love.graphics.setColor(0, 0, 0, 1)
    love.graphics.setLineWidth(3)

    love.graphics.rectangle("line", self.botaoConfirmar.x, self.botaoConfirmar.y, self.botaoConfirmar.width, self.botaoConfirmar.height)

    local posicaoTexto = self.botaoConfirmar.y + (self.botaoConfirmar.height / 2) - (self.fonteBotoes:getHeight() / 2)

    love.graphics.printf(self.botaoConfirmar.text, self.botaoConfirmar.x, posicaoTexto, self.botaoConfirmar.width, "center")


end

function NomeUsuario: update()
    local mx = love.mouse.getX()
    local my = love.mouse.getY()

    if mx > self.botaoVoltar.x and
       mx < self.botaoVoltar.x + self.botaoVoltar.width and
       my > self.botaoVoltar.y  and
       my < self.botaoVoltar.y + self.botaoVoltar.height
     then
        self.botaoVoltar.isHovering = true
     else
        self.botaoVoltar.isHovering = false
    end

    if mx > self.botaoConfirmar.x and
       mx < self.botaoConfirmar.x + self.botaoConfirmar.width and
       my > self.botaoConfirmar.y  and
       my < self.botaoConfirmar.y + self.botaoConfirmar.height
     then
        self.botaoConfirmar.isHovering = true
     else
        self.botaoConfirmar.isHovering = false
    end


end

function NomeUsuario: mousepressed(x,y, button)

    if button == 1 then
        if self.botaoVoltar.isHovering then
            GameState.switch('menuInicial')

        end

        if self.botaoConfirmar.isHovering then
            GameState.switch('selecionarDificuldade')
        end
    end
end

return NomeUsuario