gameState = "menuInicial"
local GameState = require 'lib.GameState'
local sqlite3 = require("lsqlite3")

function love.load()
    --ADICIONANDO A TELA PARA SER RECONHECIDA COMO UM ESTADO
    GameState.register("menuInicial", require 'states.MenuInicial')
    GameState.register("selecionarDificuldade", require 'states.SelecionarDificuldade')
    GameState.register('inserirNomeJogador', require 'states.NomeUsuario')
    GameState.register("sairJogo", require 'states.SairJogo')
    GameState.register("ranking", require 'states.Ranking')
    GameState.register("Game", require 'states.Game')
    GameState.register('Vencedor', require 'states.Vencedor')

    -- pega o tamanho da tela do computador e cria a janela de acordo
    local width,height = love.window.getDesktopDimensions()
    love.window.setMode(width,height)
    love.graphics.printf("largura:".. width.." altura:"..height,width/2,height/2,love.graphics.getWidth(),center)


    love.filesystem.setIdentity("ProjetoDomino")
    
    -- 2. Força o LÖVE a criar essa pasta fisicamente no seu Linux agora mesmo
    love.filesystem.createDirectory("")

    -- 3. Pega o caminho completo da pasta
    local caminho_db = love.filesystem.getSaveDirectory() .. "/dados_do_jogo.db"
    
    -- (Opcional) Printa no console para você saber exatamente onde o arquivo .db está sendo salvo
    print("O banco de dados será salvo em: " .. caminho_db)

    -- 4. Tenta abrir/criar o banco, mas agora pegamos a mensagem de erro se der errado
    DB, codigoErro, msgErro = sqlite3.open(caminho_db)

    -- 5. Trava de segurança: se o db for nil, ele avisa o porquê e não deixa o jogo dar crash!
    if not DB then
        print("FALHA CRÍTICA NO SQLITE: Não foi possível criar o banco de dados.")
        print("Motivo do erro: " .. tostring(msgErro))
        return -- Sai da função para não dar erro na linha 39
    end

    -- 6. O comando SQL para criar a tabela (o mesmo de antes)
    local query_criar_tabela = [[
        CREATE TABLE IF NOT EXISTS historico_partidas (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            nome_jogador TEXT NOT NULL,
            pontuacao INTEGER,
            dificuldade TEXT NOT NULL,
            data_partida DATETIME DEFAULT CURRENT_TIMESTAMP
        );
    ]]

    DB:exec(query_criar_tabela)
    print("Tabela 'historico_partidas' verificada/criada com sucesso!")

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

function love.quit()
    if DB and DB:isopen() then
        DB:close()
        print("Banco de dados fechado e dados descarregados no disco!")
    end
end