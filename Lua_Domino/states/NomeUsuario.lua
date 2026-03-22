local config = require 'config'
local GameState = require 'lib.GameState'
local utf8 = require 'utf8'

NomeUsuario = {
    nomeJogador = "",
    limiteCaracteresNome= 10
}

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

    love.keyboard.setKeyRepeat(true)
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


    -- COMEÇANDO A CRIAR O RETANGULO ONDE O USUARIO IRÁ INSERIR O NOME

    love.graphics.setColor(0.8, 0.8, 0.8, 1)

    love.graphics.rectangle("fill", love.graphics.getWidth() / 2 - 350, 360, 700, 400)

    love.graphics.setColor(0, 0, 0, 1)

    love.graphics.rectangle("line", love.graphics.getWidth() / 2 - 350, 360, 700, 400)

    posicaoTexto = 360 + (200 /2) - (self.fonteBotoes:getHeight() / 2)

    love.graphics.setFont(self.fonteBotoes)
    love.graphics.printf("Insira seu nome de jogador: ", love.graphics.getWidth() / 2 - 350, posicaoTexto, 700, "center")

    posicaoTexto = 360 + (400 / 2) - (self.fonteBotoes:getHeight() / 2)

    love.graphics.printf(self.nomeJogador, love.graphics.getWidth() / 2 - 350, posicaoTexto + 14, 700, "center")

    love.graphics.setColor(1,1,1,1)


end

function NomeUsuario: textinput(t)
    if string.len(self.nomeJogador) < self.limiteCaracteresNome then
        self.nomeJogador = self.nomeJogador .. t
    end
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

function NomeUsuario: keypressed(key, scancode, isrepeat)
    if key == "backspace" then
        local byteoff = utf8.offset(self.nomeJogador, -1)

        if byteoff then
            self.nomeJogador = string.sub(self.nomeJogador, 1, byteoff - 1)
        end

    elseif key == "return" or key == "kpenter" then
        if string.len(self.nomeJogador) > 0 and string.len(self.nomeJogador) < self.limiteCaracteresNome then
            print("Nome confirmado: " .. self.nomeJogador)

            GameState.switch('selecionarDificuldade')
        end
    end
end

function NomeUsuario: mousepressed(x,y, button)

    if button == 1 then
        if self.botaoVoltar.isHovering then
            GameState.switch('menuInicial')

        end

        if self.botaoConfirmar.isHovering then
            --IMPLANTAR A MESMA LOGICA DO BOTAO ENTER

            if string.len(self.nomeJogador) > 0  and string.len(self.nomeJogador) < self.limiteCaracteresNome then
                
                GameState.switch('selecionarDificuldade')
            end
        
        end
    end
end

return NomeUsuario