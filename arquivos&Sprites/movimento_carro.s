.data
	.include "Carro0.data"
	.include "Explosion0.data"
	.include "Explosion1.data"
	.include "Explosion2.data"
	.include "Win.data"
	.include "Gasolina.data"
	.include "Empty.data"
	.include "Pause.data"
	
	sfxEmpty: .word 3,58,300,54,500,1,51,600,1,48,1200,0
	sfxStart: .word 4,16,100,53,800,1,53,700,1,53,800,1,72,400,1
	sfxLevel: .word 31,7,80,64,300,0,61,300,0,54,300,1,64,100,0,61,100,1,63,600,0,54,600,0,59,600,1,71,100,1,61,100,0,54,100,0,59,100,1,63,200,1,63,100,0,54,100,1,64,100,1,63,200,0,54,200,0,59,200,1,61,200,0,54,200,0,59,200,1,71,200,0,54,200,0,59,200,1,63,200,0,54,200,0,59,200,1,61,1200,0,54,1200,0,49,1200,0
	sfxExplosion: .word 1,127,120,30,1500,0
	sfxWin: .word 52,7,100,61,200,0,59,200,1,61,100,0,59,100,1,66,500,0,58,500,0,54,100,1,54,100,1,54,100,1,54,200,1,68,100,0,59,100,0,54,500,0,70,300,0,61,300,1,71,100,0,63,100,1,70,100,0,63,100,1,68,100,0,63,100,1,70,800,0,61,800,0,54,100,1,54,100,1,54,500,0,61,100,0,73,200,0,70,200,0,66,200,1,73,100,0,70,100,1,74,800,0,69,800,0,66,100,1,66,100,1,66,100,1,66,400,0,74,100,0,69,100,1,76,100,0,71,100,1,74,100,0,69,100,1,76,100,0,71,100,1,78,1000,0,70,1000,0,66,100,1,66,100,1,66,100,1,66,400,1

.macro PAUSE(%num)
	li a0,%num
	li a7,32
	ecall
.end_macro

.text


.include "menu.s"

# s0 = posição x do carro
# s1 = velocidade pista
# s2 = posição pista
# s3 = frame atual
# s4 = musica atual
# s5 = fase atual
# s6 = contador de tempo
# s7 = gasolina
# s8 = gasolina spawnada?
# s9 = posição y da gasolina
start:
	li s1,0
	li s3,0
	li s6,0
	li s7,1000
	li s8,0
	call setInicioPista
	call setInicioCarro
	call showFrameAtual
	PAUSE(50)
	la s4,sfxStart
	call soundPlay
	j checkTecladoJogo
# posição inicial do carro e frame inicial
setInicioCarro:
	li s0,112		# s0: posição horizontal do carro (x)
printCarro:
	li a1,172		# a1: posição vertical do carro (y)
	la a0,Carro0 		# a0: endereço imagem
	
	li t0,0xFF0		# t0 = 0x00000FF0
	add t0,t0,s3		# t0 = 0x00000FF0 ou 0x00000FF1 dependendo do frame
	slli t0,t0,20		# 0x00000FF0 -> 0xFF000000 ou 0x00000FF1 -> 0xFF100000
	
	li t2,320
	mul t2,t2,a1		# t2 = altura x posição vertical
	add t2,t2,s0		# t2 + posição horizontal
	add t0,t0,t2		# t0 = endereco da posicao de impressao da sprite
		
	lw t1,0(a0)		# t1 = largura da imagem (em pixels)
	lw t2,4(a0)		# t2 = altura da imagem (em pixels)
	
	li t3,0			# t3 = contador de colunas
	li t4,0			# t4 = contador de linhas

	addi a0,a0,8		# a0 = primeiro pixel da imagem

	# loop de impressao: salva os pixels da imagem na memoria do monitor, de 4 em 4 pixels.
loop_printColunaCarro:
	bge t3,t1,loop_printLinhaCarro	# se a quantidade de colunas == contador de colunas -> próxima linha
	lw t5,0(a0)			# coloca o a0(imagem) no t5
	sw t5,0(t0)			# guarda t5 no t0(endereço de print)
	addi t0,t0,4			# +4 pixeis ao endereço print
	addi a0,a0,4			# +4 pixeis ao endereço da imagem
	addi t3,t3,4			# +4 colunas no contador
	j loop_printColunaCarro

loop_printLinhaCarro:
	addi t0,t0,320			# +320 pixeis == próxima linha ao endereço print
	sub t0,t0,t1			# endereço print - largura da imagem (primeira coluna)
	li t3,0				# zera contador de colunas
	addi t4,t4,1			# +1 linha no contador
	bge t4,t2,exit_printCarro	# se a quantidade de linhas == contador de linhas -> fim
	j loop_printColunaCarro
exit_printCarro:
	ret

checkTecladoJogo:
	li t1,0xFF200000			# carrega o endereço de controle do KDMMIO
	lw t0,0(t1)				# Le bit de Controle Teclado
   	andi t0,t0,0x0001			# mascara o bit menos significativo
   	addi s6,s6,1				# +1 contador de tempo
   	beq t0,zero,printRepeat			# não tem tecla pressionada printa dnv
   	lw t2,4(t1)				# le o valor da tecla
   	li t3,0x77				
   	beq t2,t3,aumentarVelocidade		# se tecla = 'w' aumenta velocidade
   	li t3,0x61
   	beq t2,t3,moveCarroEsquerda		# se tecla = 'a' move carro pra esquerda
	li t3,0x64
	beq t2,t3,moveCarroDireita		# se tecla = 'd' move carro pra direita
	li t3,0x1B
	beq t2,t3,pauseJogo				# se tecla = 'esc' reseta

	j checkTecladoJogo

pauseJogo:
	la a0,Pause
	li a1,198
	li a2,190
	call printSprite
loop_pauseJogo:
	li t1,0xFF200000			# carrega o endereço de controle do KDMMIO
	lw t0,0(t1)				# Le bit de Controle Teclado
   	andi t0,t0,0x0001			# mascara o bit menos significativo
	beq t0,zero,loop_pauseJogo		# não tem tecla pressionada volta
   	lw t2,4(t1)				# le o valor da tecla
   	li t3,0x1B
   	beq t2,t3,checkTecladoJogo
   	j loop_pauseJogo
   
timeReset:
	li s6,0	
	j checkTecladoJogo

spawnGasolina:
	# s9 = posição y da gasolina
	# s8 = tem gasosa? (0,1)
	li s8,1
	li s9,0
	ret
spawnGasolinaAtual:
	beqz s8,exit_spawnGasolina
	la a0,Gasolina
	li a1,100
	addi s9,s9,10
	mv a2,s9
	
	#li t0,240
	call printSprite
	PAUSE(60) 
	call showFrameAtual
	j checkTecladoJogo
	
exit_spawnGasolina:
	blez s7,carroParando	
	ret
checkColisaoGasolina:
	blez s7,carroParando		# se a gasosa < 0, acaba
	li t0,80
	bge s0,t0,ColisaoGasolinaX
	ret
ColisaoGasolinaX:
	li t1,110
	ble s0,t1,ColisaoGasolinaY
	ret
ColisaoGasolinaY:
	li t2,152
	bge s9,t2,ColisaoGasolinaY2
	ret
ColisaoGasolinaY2:
	li t3,172
	ble s9,t3,aumentaGasolina
	ret
	# s0 < 128
	# se o 112<s0<128 e o 152<s9<172
aumentaGasolina:
	addi s7,s7,300
	li s8,0
	li s9,0
	ret

checkGasolina:
	srli t0,s1,1
	sub s7,s7,t0

	bnez s8,checkColisaoGasolina	# se gasosa tiver spawnada checa colisão
	li t1,400
	ble s7,t1,spawnGasolina  	# se gasosa tiver menor que 400
	
	#mv a0,s7
	#li a7,1
	#ecall
	
	blez s7,carroParando
	ret

printRepeat:
	beqz s1,timeReset		# se a velocidade for 0, reseta o tempo
	xori s3,s3,1			# inverte frame
	call checkGasolina		
	call checkWin
	call checkCollisionPista
	call printPistaAtual	
	call printCarro
	call spawnGasolinaAtual
	PAUSE(60)# temp
	call showFrameAtual
	j checkTecladoJogo 
	
aumentarVelocidade:
	# s1 = velocidade pista
	li t0,15
	beq s1,t0,printRepeat
	
	addi s1,s1,1
	j printRepeat

moveCarroEsquerda:
	beqz s1,timeReset
	addi s0,s0,-4
	j printRepeat

moveCarroDireita:
	beqz s1,timeReset
	addi s0,s0,4
	j printRepeat

showFrameAtual:
	li t0,0xFF200604
	sw s3,0(t0)
	ret

	
checkWin:
	li t0,100
	ble s2,t0,victory
	ret
victory:
	li s1,0
	xori s3,s3,1
	call printPistaAtual
	call printCarro
	call showFrameAtual
		
	PAUSE(100)
	
	xori s3,s3,1
	call printPistaAtual
	call printCarro
	la a0,Win
	li a1,96
	li a2,32
	call printSprite
	call showFrameAtual
	
	li t0,8		# contador vezes pisca
	la s4,sfxWin
	call soundPlay
	j victory_loop
victory_loop:
	blez t0,printMenu
	PAUSE(500)
	xori s3,s3,1
	call showFrameAtual
	addi t0,t0,-1
	j victory_loop

checkCollisionPista:
	li t0,88
	li t1,172	
	blt s0,t0,explodeCarro
	bgt s0,t1,explodeCarro
	ret	

carroParando:
	blez s1,gameOver
	addi s1,s1,-1
	xori s3,s3,1
	call printPistaAtual
	call printCarro
	call showFrameAtual
	PAUSE(200)
	j carroParando

gameOver:
	xori s3,s3,1
	call printPistaAtual
	call printCarro
	la a0,Empty
	li a1,118
	li a2,200
	call printSprite
	call showFrameAtual
	la s4,sfxEmpty
	call soundPlay
	PAUSE(2000)
	call start

explodeCarro:
	mv a1,s0
	li a2,172
	li s1,0 	#zera velocidade da pista
	
	xori s3,s3,1
	call printPistaAtual
	la a0,Explosion0
	call printSprite
	call showFrameAtual

	la s4,sfxExplosion
	call soundPlay
	
	mv a1,s0
	li a2,172
	
	PAUSE(200)
	
	xori s3,s3,1
	call printPistaAtual
	la a0,Explosion1
	call printSprite
	call showFrameAtual
	
	PAUSE(200)
	
	xori s3,s3,1
	call printPistaAtual
	la a0,Explosion2
	call printSprite
	call showFrameAtual
	
	la s4,sfxEmpty
	call soundPlay
	PAUSE(500)
	
	j start
# a0: endereço sprite
# a1: posição horizontal do sprite (x)
# a2: posição vertical do sprite (y)
# s3: frame atual
# t1: largura da imagem (em pixels)
# t2: altura da imagem (em pixels)
printSprite:
	li t0,0xFF0		# t0 = 0x00000FF0
	add t0,t0,s3		# t0 = 0x00000FF0 ou 0x00000FF1 dependendo do frame
	slli t0,t0,20		# 0x00000FF0 -> 0xFF000000 ou 0x00000FF1 -> 0xFF100000
	
	li t2,320
	mul t2,t2,a2		# t2 = altura x posição vertical
	add t2,t2,a1		# t2 + posição horizontal
	add t0,t0,t2		# t0 = endereco da posicao de impressao da sprite
		
	lw t1,0(a0)		# t1 = largura da imagem (em pixels)
	lw t2,4(a0)		# t2 = altura da imagem (em pixels)
	
	li t3,0			# t3 = contador de colunas
	li t4,0			# t4 = contador de linhas

	addi a0,a0,8		# a0 = primeiro pixel da imagem

	# loop de impressao: salva os pixels da imagem na memoria do monitor, de 4 em 4 pixels.
loop_printColunaSprite:
	bge t3,t1,loop_printLinhaSprite	# se a quantidade de colunas == contador de colunas -> próxima linha
	lw t5,0(a0)			# coloca o a0(imagem) no t5
	sw t5,0(t0)			# guarda t5 no t0(endereço de print)
	addi t0,t0,4			# +4 pixeis ao endereço print
	addi a0,a0,4			# +4 pixeis ao endereço da imagem
	addi t3,t3,4			# +4 colunas no contador
	j loop_printColunaSprite

loop_printLinhaSprite:
	addi t0,t0,320			# +320 pixeis == próxima linha ao endereço print
	sub t0,t0,t1			# endereço print - largura da imagem (primeira coluna)
	li t3,0				# zera contador de colunas
	addi t4,t4,1			# +1 linha no contador
	bge t4,t2,exit_printSprite	# se a quantidade de linhas == contador de linhas -> fim
	j loop_printColunaSprite
exit_printSprite:
	ret

.include "pista.s"
.include "som.s"


