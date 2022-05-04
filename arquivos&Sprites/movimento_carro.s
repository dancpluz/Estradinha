.data
	PRETO: .byte 255,255,255,255
	.include "Carro0.data"
	
.text

#inverter frame atual*
#posição inicial do carro e frame inicial
setInicioCarro:
	li s0,0xFF200604	# endereço do frame que está sendo mostrado
	li s3,0			# s3: frame atual
	sw zero,0(s0)		# mostra frame zero
	
	li s1,144		# s1: posição horizontal do carro (x)
	li s2,104		# s2: posição vertical do carro (y)
	call printCarro
	j checkTecladoMove
	
printCarro:
	la a0,Carro0 		# a0: endereço imagem
	li t0,0xFF0		# t0 = 0x00000FF0
	add t0,t0,s3		# t0 = 0x00000FF0 ou 0x00000FF1 dependendo do frame
	slli t0,t0,20		# 0x00000FF0 -> 0xFF000000 ou 0x00000FF1 -> 0xFF100000
	
	li t2,320
	mul t2,t2,s2		# t2 = altura x posição vertical
	add t2,t2,s1		# t2 + posição horizontal
	add t0,t0,t2		# t0 = endereco da posicao de impressao da sprite
		
	lw t1,0(a0)		# t1 = largura da imagem (em pixels)
	lw t2,4(a0)		# t2 = altura da imagem (em pixels)
	
	li t3,0			# t3 = contador de colunas
	li t4,0			# t4 = contador de linhas

	addi a0,a0,8		# a0 = primeiro pixel da imagem

	# loop de impressao: salva os pixels da imagem na memoria do monitor, de 4 em 4 pixels.
loop_printColuna:
	bge t3,t1,loop_printLinha	# se a quantidade de colunas == contador de colunas -> próxima linha
	lw t5,0(a0)			# coloca o a0(imagem) no t5
	sw t5,0(t0)			# guarda t5 no t0(endereço de print)
	addi t0,t0,4			# +4 pixeis ao endereço print
	addi a0,a0,4			# +4 pixeis ao endereço da imagem
	addi t3,t3,4			# +4 colunas no contador
	j loop_printColuna
loop_printLinha:
	bge t4,t2,exit_printCarro	# se a quantidade de linhas == contador de linhas -> fim
	addi t0,t0,320			# +320 pixeis == próxima linha ao endereço print
	sub t0,t0,t1			# endereço print - largura da imagem (primeira coluna)
	li t3,0				# zera contador de colunas
	addi t4,t4,1			# +1 linha no contador
	j loop_printColuna
exit_printCarro:
	ret

checkTecladoMove: 
	li t1,0xFF200000			# carrega o endereço de controle do KDMMIO
loop_checkTecladoMove: 	
	lw t0,0(t1)				# Le bit de Controle Teclado
   	andi t0,t0,0x0001			# mascara o bit menos significativo
   	beq t0,zero,loop_checkTecladoMove	# não tem tecla pressionada então volta ao loop
   	lw t2,4(t1)				# le o valor da tecla
   	
   	li t3,0x61
   	beq t2,t3,moveCarroEsquerda		# se tecla = 'a' move carro pra esquerda
	li t3,0x64
	beq t2,t3,moveCarroDireita		# se tecla = 'd' move carro pra direita
	j loop_checkTecladoMove

moveCarroEsquerda:
	addi s1,s1,-4		# remove x pixeis da posição horizontal
	xori s3,s3,1		# inverte o frame
	call printApagador	# limpa o frame anterior
	call printCarro
	call showFrameAtual	# mostra o frame atual
	j checkTecladoMove
	
moveCarroDireita:
	addi s1,s1,4		# remove x pixeis da posição horizontal
	xori s3,s3,1		# inverte o frame
	call printApagador	# limpa o frame anterior
	call printCarro
	call showFrameAtual	# mostra o frame atual
	j checkTecladoMove

printApagador:
	la a0,PRETO 		# a0: endereço imagem	
	li a1,0			# a1: (x) posiçao horizontal (divisivel por 4)
	li a2,100		# a2: (y) posicao vertical (divisivel por 4)

	li t0,0xFF0		# t0 = 0x00000FF0 
	add t0,t0,s3		# t0 = 0x00000FF0 ou 0x00000FF1 dependendo do frame
	slli t0,t0,20		# 0x00000FF0 -> 0xFF000000 ou 0x00000FF1 -> 0xFF100000
	
	li t2,320
	mul t2,t2,a2		# t2 = altura x posição vertical
	add t2,t2,a1		# t2 + posição horizontal
	add t0,t0,t2		# t0 = endereco da posicao de impressao da sprite
		
	li t1,320		# t1 = largura da imagem (em pixels)
	li t2,22		# t2 = altura da imagem (em pixels)
	
	li t3,0			# t3 = contador de colunas
	li t4,0			# t4 = contador de linhas

	# loop de impressao: salva os pixels da imagem na memoria do monitor, de 4 em 4 pixels.
loop_printApagadorColuna:
	bge t3,t1,loop_printApagadorLinha	# se a quantidade de colunas == contador de colunas -> próxima linha
	lw t5,0(a0)				# coloca o a0(imagem) no t5
	sw t5,0(t0)				# guarda t5 no t0(endereço de print)
	addi t0,t0,4				# +4 pixeis ao endereço print
	addi t3,t3,4				# +4 colunas no contador
	j loop_printApagadorColuna
loop_printApagadorLinha:
	bge t4,t2,exit_printApagador		# se a quantidade de linhas == contador de linhas -> fim
	addi t0,t0,320				# +320 pixeis == próxima linha ao endereço print
	sub t0,t0,t1				# endereço print - largura da imagem (primeira coluna)
	li t3,0					# zera contador de colunas
	addi t4,t4,1				# +1 linha no contador
	j loop_printApagadorColuna
exit_printApagador:
	ret

#inverte o frame de 0 pra 1 e vice versa
invertFrameAtual:
	li t0,0xFF200604
	xori s3,s3,0x001	# escolhe a outra frame
	sw s3,0(t0)		# seleciona o Frame atual
	ret
	
showFrameAtual:
	li t0,0xFF200604
	sw s3,0(t0)
	ret
