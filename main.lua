local qtdLinhas = 10
local qtdColunas = 8

local mapa = {}
local listaAberta = {}

local inicio = 0
local fim = 0

local alturaTopo = 50
local titulo = display.newText( "Desenhe as paredes", display.contentCenterX, alturaTopo/2, native.systemFont, alturaTopo )
titulo:setFillColor(1,1,1)

local larguraCelula =  display.contentWidth / qtdColunas
local alturaCelula =  (display.contentHeight - alturaTopo) / qtdLinhas

local etapa = 0;
local timerAEstrela;


local function cliqueCelula(event)
  local celula = event.target
  
  if(etapa == 0)then
    if(celula.bloqueada)then
      celula:setFillColor(255,0,0)
      celula.bloqueada = false
    else
      celula:setFillColor(0,0,0)
      celula.bloqueada = true
    end
  end
  
  if(etapa == 1)then
    if(inicio ~= 0)then
      inicio:setFillColor(255,0,0)
    end
    inicio = celula
    inicio:setFillColor(0,255,0)
	inicio.bloqueada = true
    
  end
  
  if(etapa == 2)then
    if(fim ~= 0)then
      fim:setFillColor(255,0,0)
    end
    fim = celula
    fim:setFillColor(0,0,255)
    
  end
	
end

function contaTabela(T)
	local contagem = 0
	for _ in pairs(T) do contagem = contagem + 1 end
	return contagem
end

local function desenhaMapa()
  for x = 1, qtdColunas do
    mapa[x] = {}
    
    for y = 1, qtdLinhas do
     	local celula = display.newRect((x-1)*larguraCelula, (y-1)*alturaCelula+alturaTopo, larguraCelula, alturaCelula);
    	celula.anchorX = 0
      	celula.anchorY  = 0
      	celula.strokeWidth = 2
      
      	celula:setStrokeColor(255,255,255)
      	celula:setFillColor(255,0,0)
      
      	celula.bloqueada = false
      	celula.fechada = false
      	celula.idX = x
      	celula.idY = y
      
      	local tamanhoFont = celula.height/4
      
      	celula.F = display.newText('F=0',celula.x+5, celula.y+5, native.systemFont, tamanhoFont)
      	celula.F.anchorX = 0
      	celula.F.anchorY  = 0
      	celula.F.valor = 0
      
        celula.G = display.newText('G=0',celula.x + celula.width,
				celula.y+celula.height,
				native.systemFont,
				tamanhoFont)

      	celula.G.anchorX = 1
      	celula.G.anchorY = 1
      	celula.G.valor = 0
      
      	
      	celula.H = display.newText('H=0',celula.x+5,
			celula.y+celula.height,
			native.systemFont,
			 tamanhoFont)
      	celula.H.anchorX = 0
      	celula.H.anchorY = 1
      	celula.H.valor = 0
      
      	celula.pai = 0
      	celula.nome = celula.idX .. celula.idY
      
      	celula:addEventListener( "tap", cliqueCelula )
      	mapa[x][y] = celula
      	
      
    end
    
  end
  
end

local function montaCaminho()
  titulo.text = "Caminho encontrado!"
  local anterior = fim
  for i=1, fim.G.valor do
    pai = anterior.pai
	if(pai.nome ~= inicio.nome)then
    	pai:setFillColor(.7,.2,.9)
	end
    anterior=pai
    
  end
  
end


local function aEstrela()
  
	if(contaTabela(listaAberta) == 0)then
		titulo.text = "Não é possivel encontrar o caminho"
		timer.pause(timerAEstrela)
		return
	end

    local menor = 0
  	local primeira = true
  
  	--encontra o menor F da lista Aberta
    for key, value in pairs(listaAberta) do
    	if primeira then
      		menor = listaAberta[key]
      		primeira = false
      	end
        
    	if(listaAberta[key].F.valor < menor.F.valor) then
      		menor = listaAberta[key]
      		
      	end
    end
  	local celulaAtual = menor
  	listaAberta[celulaAtual.nome] = nil
  
  	print(celulaAtual.nome)
  
  	celulaAtual.fechada = true
  
  	
  	if(celulaAtual.nome == fim.nome)then
    	timer.pause(timerAEstrela)
    	montaCaminho()
    elseif(celulaAtual.nome ~= inicio.nome)then
    	celulaAtual:setFillColor(.5,.5,0)
    end
  	
  
  	local vizinhos = {
    	{0, -1}, --cima
    	{0, 1}, --baixo
    	{-1, 0}, --esquerda
    	{1, 0} --direita
    }
  	for i=1, #vizinhos do
    	
    	xVizinho = celulaAtual.idX + vizinhos[i][1]
    	yVizinho = celulaAtual.idY + vizinhos[i][2]
    
    	if(xVizinho > 0 and yVizinho > 0 and xVizinho <= qtdColunas and yVizinho <= qtdLinhas)then
      		
      		vizinho = mapa[xVizinho][yVizinho]
      
      		if(vizinho.bloqueada==false and vizinho.fechada==false)then
        		if(vizinho.nome ~= fim.nome)then
        			vizinho:setFillColor(0,.5,.5)
          		end
        
        		if((vizinho.G.valor == 0) or (celulaAtual.G.valor +1 < vizinho.G.valor))then
          			listaAberta[vizinho.nome] = vizinho
          			vizinho.G.valor = celulaAtual.G.valor +1
          			vizinho.G.text = 'G='..vizinho.G.valor
          
          			vizinho.H.valor = math.abs(vizinho.idX - fim.idX) + math.abs(vizinho.idY - fim.idY)
          			vizinho.H.text = 'H='..vizinho.H.valor
          
          			vizinho.F.valor = vizinho.G.valor + vizinho.H.valor
          			vizinho.F.text = 'F='..vizinho.F.valor
          
          			vizinho.pai = celulaAtual
          		end
        	end
      
      	end
    end
      
      

end


local function onKeyEvent( event )
  	if(event.phase == 'up')then 
    	
    	if(event.keyName == 'space')then
        	etapa = etapa+1
    
            if(etapa == 1)then
                titulo.text = 'Defina o inicio'
            end
            if(etapa == 2)then
                titulo.text = 'Defina o fim'
            end
      		if(etapa == 3)then
                titulo.text = 'Calculando...'
        		print('aEstrela')
   				listaAberta[inicio.nome] = inicio
        		timerAEstrela = timer.performWithDelay( 1000, aEstrela, -1) 
            end
        end
    end

    return false
end

desenhaMapa()
Runtime:addEventListener( "key", onKeyEvent )