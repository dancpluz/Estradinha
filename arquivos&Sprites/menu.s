.data
	.include "Menu_Level1.data"
	.include "Menu_Level2.data"
	sfxSelect:.word 1,7,70,63,100,0
	
.text

# s3 = frame atual
# printa a imagem1 no frame0 e imagem2 no frame1

printMenu:
	li s0,0xFF200604	# endere�o do frame que est� sendo mostrado
	li s3,0			# frame incial 0
	sw zero,0(s0)		# mostra frame zero
	
	li s0,0xFF000000	# Frame0
	li s1,0xFF100000	# Frame1
	la t0,Menu_Level1	# endere�o da imagem1
	la t1,Menu_Level2	# endere�o da imagem2
	li t2,0x12C00		# contador de pixeis

	addi t0,t0,8		# primeiro pixel da imagem1
	addi t1,t1,8		# primeiro pixel da imagem2
loop_printMenu: 	
	beqz t2,checkTecladoMenu	
	lw t5,0(t0)		# Coloca a imagem1 no t5
	sw t5,0(s0)		# Guarda t5 no Frame0(s0)
	lw t5,0(t1)		# Coloca a imagem2 no t5
	sw t5,0(s1)		# Guarda t5 no Frame1(s1)

	addi t0,t0,4		#+4 pixeis do endere�o imagem1
	addi t1,t1,4		#+4 pixeis do endere�o imagem2
	addi s0,s0,4		#+4 pixeis do frame 0
	addi s1,s1,4		#+4 pixeis do frame 1
	addi t2,t2,-4		#-4 para o contador de pixeis
	j loop_printMenu
	
checkTecladoMenu:	
	li t1,0xFF200000			# carrega o endere�o de controle do KDMMIO
loop_checkTecladoMenu:
	lw t0,0(t1)				# Le bit de Controle Teclado
	andi t0,t0,0x0001			# mascara o bit menos significativo
   	beqz t0,loop_checkTecladoMenu     	# Se n�o h� tecla pressionada ent�o volta loop
  	lw t2,4(t1) 				# le o valor da tecla tecla
 
  	li t3,0x77
  	beq t2,t3,invertFrameAtualMenu		# se tecla = 'w' troca frame
  	li t3,0x73
  	beq t2,t3,invertFrameAtualMenu		# se tecla = 's' troca frame
  	li t3,0x20
  	beq t2,t3,selectedLevel			# se tecla = ' ' seleciona level
	j loop_checkTecladoMenu

#inverte o frame de 0 pra 1 e vice versa
invertFrameAtualMenu:
	li s0,0xFF200604
	xori s3,s3,1		# escolhe a outra frame
	sw s3,0(s0)		# seleciona o Frame atual
	
	la s4,sfxSelect
	call soundPlay
	j checkTecladoMenu

#verifica o level selecionado e muda a posi��o do bloco preto
selectedLevel:
	beqz s3,selectedLevel_1
	j selectedLevel_2

selectedLevel_1:
	li a1,124		# a1: (x) posi�ao horizontal (divisivel por 4)
	li a2,160		# a2: (y) posicao vertical (divisivel por 4)
	call print_selectedLevel
	
selectedLevel_2:
	beqz s3,selectedLevel_1	# se s3 -> frame0
	li a1,124		# a1: (x) posi�ao horizontal (divisivel por 4)
	li a2,178		# a2: (y) posicao vertical (divisivel por 4)
	call print_selectedLevel

#print
print_selectedLevel:
	li t0,0xFF0		# t0 = 0x00000FF0 
	add t0,t0,s3		# t0 = 0x00000FF0 ou 0x00000FF1 dependendo do frame
	slli t0,t0,20		# 0x00000FF0 -> 0xFF000000 ou 0x00000FF1 -> 0xFF100000
	
	li t2,320
	mul t2,t2,a2		# t2 = altura x posi��o vertical
	add t2,t2,a1		# t2 + posi��o horizontal
	add t0,t0,t2		# t0 = endereco da posicao de impressao da sprite
		
	li t1,92		# t1 = largura da imagem (em pixels)
	li t2,18		# t2 = altura da imagem (em pixels)
	
	li t3,0			# t3 = contador de colunas
	li t4,0			# t4 = contador de linhas

			
	# loop de impressao: salva os pixels da imagem na memoria do monitor, de 4 em 4 pixels.
loop_printColuna:
	bge t3,t1,loop_printLinha	# se a quantidade de colunas == contador de colunas -> pr�xima linha
	sw zero,0(t0)			# guarda t5 no t0(endere�o de print)
	addi t0,t0,4			# +4 pixeis ao endere�o print
	addi t3,t3,4			# +4 colunas no contador
	j loop_printColuna
loop_printLinha:
	bge t4,t2,exitSelectedLevel	# se a quantidade de linhas == contador de linhas -> fim
	addi t0,t0,320			# +320 pixeis == pr�xima linha ao endere�o print
	sub t0,t0,t1			# endere�o print - largura da imagem (primeira coluna)
	li t3,0				# zera contador de colunas
	addi t4,t4,1			# +1 linha no contador
	j loop_printColuna

limparTela:
	li t0,0xFF000000	# t0 = frame 1
	li t1,0xFF100000	# t1 = frame 2
	li t2,0x12C00		#contador de pixeis
	
loop_limparTela:
	beqz t2,exit_limparTela
	sw zero,0(t0)
	sw zero,0(t1)
	
	addi t0,t0,4
	addi t1,t1,4
	addi t2,t2,-4
	j loop_limparTela
exit_limparTela:
	ret

exitSelectedLevel:	
	#ir para level 1 ou 2 dependendo do frame atual(s3)
	la s4,sfxLevel
	call soundPlay
	call limparTela
	mv s5,s3		# fase atual

#.include "som.s"
