-- lib/Gamestate.lua

-- Inicializa o nosso gerenciador
local Gamestate = {}
Gamestate.states = {} -- Armazena todas as telas (estados)
Gamestate.current = nil -- Aponta para a tela ativa no momento

-- Função para trocar de estado
-- 'stateName' é o nome do estado para o qual queremos ir (ex: 'menu')
-- '...' são parâmetros opcionais que podemos passar para a nova tela
function Gamestate.switch(stateName, ...)
  assert(Gamestate.states[stateName], "Tentativa de trocar para um estado inexistente: " .. stateName)
  
  -- Se houver uma função 'exit' no estado atual, chame-a para limpeza
  if Gamestate.current and Gamestate.current.exit then
    Gamestate.current:exit()
  end

  -- Troca para o novo estado
  Gamestate.current = Gamestate.states[stateName]
  
  -- Chama a função 'enter' do novo estado, passando os parâmetros
  if Gamestate.current.enter then
    Gamestate.current:enter(...)
  end
end

-- Função para registrar um novo estado
function Gamestate.register(name, state)
  Gamestate.states[name] = state
end

-- Funções que serão chamadas pelo main.lua e delegadas para o estado atual
function Gamestate.update(dt)
  if Gamestate.current and Gamestate.current.update then
    Gamestate.current:update(dt)
  end
end

function Gamestate.draw()
  if Gamestate.current and Gamestate.current.draw then
    Gamestate.current:draw()
  end
end

function Gamestate.keypressed(key, scancode, isrepeat)
  if Gamestate.current and Gamestate.current.keypressed then
    Gamestate.current:keypressed(key, scancode, isrepeat)
  end
end

function Gamestate.mousepressed(x, y, button, istouch)
    if Gamestate.current and Gamestate.current.mousepressed then
        Gamestate.current:mousepressed(x, y, button, istouch)
    end
end

function Gamestate.textinput(t)
    if Gamestate.current and Gamestate.current.textinput then
        Gamestate.current:textinput(t)
    end
end

-- Adicione outras funções do LÖVE aqui (mousemoved, keyreleased, etc.) conforme precisar

return Gamestate