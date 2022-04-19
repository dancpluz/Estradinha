# para aprimorar o desempenho, fazer as sprites terem largura  
# multipla de 4 e alterar as istrucoes de lb e sb para lw e sw.

.data	
	# dados das imagens que serao impressas (as duas primeiras words sao suas dimensoes, o restante sao as informacoes de cor de cada pixel (1 pixel por byte)
	.include "./img/carro.data"
	.include "./img/road-fighter.data"

.text	
	# seleciona o frame 0
#	li t0, 0xFF200604	# carrega o endereco de selecao de frame
#	li t1, 0		# t1 = 0
#	sw t1 0(t0)		# salva 0 no endereco, fazendo que o frame atual seja o 0.
	
	la a0, road_fighter
	li a1, 0
	li a2, 0
	li a3, 0
	call PRINT_SPRITE
	
	
	la a0, carro
	li a1, 100
	li a2, 100
	li a3, 0
	call PRINT_SPRITE
	
	j EXIT
		
PRINT_SPRITE:
	# a0: endereco da imagem
	# a1: posicao horizontal (x)
	# a2: posicao vertical (y)
	# a3: frame de impressao (0 ou 1)
	
	li t0, 0xFF0		# t0 = 0x00000FF0
	add t0, t0, a3	
	slli t0, t0, 20		# t0 = endereco base do monitor (frame igual ao valor em a3)
	
	li t2, 320
	mul t2, t2, a2
	add t2, t2, a1
	add t0, t0, t2		# t0 = endereco da posicao de impressao da sprite
		
	lw t1, 0(a0)		# t1 = largura da imagem (em pixels)
	lw t2, 4(a0)		# t2 = altura da imagem (em pixels)
	
	li t3, 0		# t3 = contador de colunas
	li t4, 0		# t4 = contador de linhas
	
	addi a0, a0, 8		# a0 = primeiro pixel da imagem
			
	# loop de impressao: salva os pixels da imagem na memoria do monitor, de 4 em 4 pixels.
	PRINT_LOOP:
	bge t3, t1, NEXT_LINE	
	lb t5, 0(a0)
	sb t5, 0(t0)
	addi t0, t0, 1
	addi a0, a0, 1
	addi t3, t3 1
	j PRINT_LOOP
	
	NEXT_LINE:
	bge t4, t2, DONE
	addi t0, t0, 320
	sub t0, t0, t1
	li t3, 0
	addi t4, t4, 1
	j PRINT_LOOP
	
	DONE:
	ret

EXIT:	li a7, 10
	ecall
