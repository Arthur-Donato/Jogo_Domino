--Informações importates:
-- Este arquivo define as configurações do jogo, incluindo dimensões da janela e escalas responsivas para elementos da interface do usuário.
-- Para a sua execução correta, certifique-se de que o módulo 'config' seja carregado antes de usar suas propriedades em outros arquivos.
-- Ao executar o "local config = require "config"", só será executado uma unica vez, mesmo que seja chamado em vários arquivos diferentes...
-- Assim, caso deseje recalcular alguma variável, será necessário criar uma função para isso dentro deste arquivo ().


local config = {}

-- Pega dimensões atuais da janela
config.WIDTH, config.HEIGHT = love.graphics.getDimensions()

-- Base para responsividade
config.baseWidth = 1920
config.baseHeight = 1080

config.scaleX = config.WIDTH / config.baseWidth --Determinando a proporção da largura da tela(porcetagem)
config.scaleY = config.HEIGHT / config.baseHeight

config.btnResponsiveX = 370 * config.scaleX -- Determinando tamanho dos botoes de forma responsiva
config.btnResponsiveY = 90 * config.scaleY
config.fonteBotoes = love.graphics.newFont(32 * config.scaleX)

return config
