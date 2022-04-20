# para aprimorar o desempenho, fazer as sprites terem largura  
# multipla de 4 e alterar as istrucoes de lb e sb para lw e sw.

.data	
	# dados das imagens que serao impressas (as duas primeiras words sao suas dimensoes, o restante sao as informacoes de cor de cada pixel (1 pixel por byte)
	.include "Carro0.data"

.text	
	# seleciona o frame 0
#	li t0, 0xFF200604	# carrega o endereco de selecao de frame
#	li t1, 0		# t1 = 0
#	sw t1 0(t0)		# salva 0 no endereco, fazendo que o frame atual seja o 0.

	li s0,0			# zera o contador
CONTA:  addi s0,s0,1		# incrementa o contador
	jal KEY2		# le o teclado	blocking
	j CONTA			# volta ao loop


MOVER_ESQUERDA:
	addi a1, a1, 16
	call PRINT_SPRITE
	
PRINT:		
	la a0, Carro0
	li a1, 144
	li a2, 104
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
	mul t2, t2, a2		# t2 = altura x posição vertical
	add t2, t2, a1		# t2 + posição horizontal
	add t0, t0, t2		# t0 = endereco da posicao de impressao da sprite
		
	lw t1, 0(a0)		# t1 = largura da imagem (em pixels)
	lw t2, 4(a0)		# t2 = altura da imagem (em pixels)
	
	li t3, 0		# t3 = contador de colunas
	li t4, 0		# t4 = contador de linhas
	
	addi a0, a0, 8		# a0 = primeiro pixel da imagem
			
	# loop de impressao: salva os pixels da imagem na memoria do monitor, de 4 em 4 pixels.
	PRINT_LOOP:
	bge t3, t1, NEXT_LINE	
	lw t5, 0(a0)
	sw t5, 0(t0)
	addi t0, t0, 4
	addi a0, a0, 4
	addi t3, t3, 4
	j PRINT_LOOP
	
	NEXT_LINE:
	bge t4, t2, DONE
	addi t0, t0, 320
	sub t0, t0, t1
	li t3, 0
	addi t4, t4, 1
	j PRINT_LOOP
	
	DONE:
	j KEY2
	ret

EXIT:	li a7, 10
	ecall



KEY2:	li t1,0xFF200000		# carrega o endereço de controle do KDMMIO
	lw t0,0(t1)			# Le bit de Controle Teclado
	andi t0,t0,0x0001		# mascara o bit menos significativo
   	beq t0,zero,FIM   	   	# Se não há tecla pressionada então vai para FIM
  	lw t2,4(t1) 			# le o valor da tecla tecla
  	li t3,0x97
  	beq t2,t3,MOVER_ESQUERDA		# if t2 == 'a' 0x61
	sw t2,12(t1)  
	j PRINT			# escreve a tecla pressionada no display
FIM:	ret				# retorna
	

