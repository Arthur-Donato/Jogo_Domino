gameState = "menuInicial"
local GameState = require 'lib.GameState'

function love.load()
    --ADICIONANDO A TELA PARA SER RECONHECIDA COMO UM ESTADO
    GameState.register("menuInicial", require 'states.MenuInicial')
    GameState.register("selecionarDificuldade", require 'states.SelecionarDificuldade')
    GameState.register('inserirNomeJogador', require 'states.NomeUsuario')
    GameState.register("sairJogo", require 'states.SairJogo')
    GameState.register("historico", require 'states.Historico')
    GameState.register("Game", require 'states.Game')
    GameState.register('Vencedor', require 'states.Vencedor')

    -- pega o tamanho da tela do computador e cria a janela de acordo
    local width,height = love.window.getDesktopDimensions()
    love.window.setMode(width,height)
    love.graphics.printf("largura:".. width.." altura:"..height,width/2,height/2,love.graphics.getWidth(),center)

    --INICIANDO O JOGO NA TELA DE MENU INICIAL
    GameState.switch("menuInicial")
    
end

function love.update(dt)
    GameState.update(dt)
    
end

function love.draw()
    GameState.draw()

    
end

function love.mousepressed(x, y, button, istouch)
    GameState.mousepressed(x, y, button, istouch)
end

function love.keypressed(key, scancode, isrepeat)
    -- O keypressed cuida APENAS do keypressed (teclas como Enter, Backspace, setas)
    GameState.keypressed(key, scancode, isrepeat)
end

function love.textinput(t)
    print("1. O main.lua ouviu a letra: " .. t)
    -- O textinput cuida APENAS das letras digitadas (a, b, c, A, ç, etc)
    if GameState.textinput then
        GameState.textinput(t)
    end
end