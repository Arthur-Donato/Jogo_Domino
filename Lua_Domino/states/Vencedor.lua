local GameState = require "lib.GameState"
local config = require "config"

local Vencedor = {}

function Vencedor:enter(vencedor, mensagem)
    self.vencedor = vencedor or "empate"
    self.mensagem = mensagem or ""
    self.fonteTitulo = love.graphics.newFont(48 * config.scaleX)
    self.fonteTexto = love.graphics.newFont(26 * config.scaleX)

    self:inserirDadosNoBancoDeDados()
end

function Vencedor:draw()
    if self.vencedor == "jogador" then
        love.graphics.clear(0.2, 0.7, 0.2, 1) -- verde
    elseif self.vencedor == "ia" then
        love.graphics.clear(0.8, 0.2, 0.2, 1) -- vermelho
    else
        love.graphics.clear(0.9, 0.8, 0.2, 1) -- amarelo
    end

    love.graphics.setColor(1, 1, 1, 1)

    love.graphics.setFont(self.fonteTitulo)

    local titulo = ""
    if self.vencedor == "jogador" then
        titulo = "Jogador venceu!"
    elseif self.vencedor == "ia" then
        titulo = "A IA venceu!"
    else
        titulo = "Empate!"
    end

    love.graphics.printf(titulo, 0, config.HEIGHT / 2 - 100, config.WIDTH, "center")

    love.graphics.setFont(self.fonteTexto)
    love.graphics.printf(self.mensagem, 0, config.HEIGHT / 2, config.WIDTH, "center")

    love.graphics.printf("Pressione ENTER para voltar ao menu", 0, config.HEIGHT / 2 + 100, config.WIDTH, "center")
end

function Vencedor:keypressed(key)
    if key == "return" or key == "kpenter" then
        GameState.switch("menuInicial")
    end
end

return Vencedor