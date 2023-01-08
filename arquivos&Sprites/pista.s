.data
	.include "Pista_Level1.data"
	.include "Pista_Level2.data"
.text

# s1 = velocidade pista
# s2 = posição pista
# s3 = frame atual
# s5 = fase atual
	

setInicioPista:	
	li s2,3160		# s2 = posição pista
	li s1,0
	j printPistaAtual
setNivel1:
	la a0,Pista_Level1
	j printPistaContinue

printPistaAtual:
	beqz s5,setNivel1
	la a0,Pista_Level2
 	# endereço da imagem
printPistaContinue:	
	li t0,0xFF0 	# t0 = 0x00000FF0
	add t0,t0,s3	# t0 = 0x00000FF0 ou 0x00000FF1 dependendo do frame
	slli t0,t0,20	# 0x00000FF0 -> 0xFF000000 ou 0x00000FF1 -> 0xFF100000
	
	li t3,0xC300	# contador de pixeis (tela)

	sub s2,s2,s1	# altura - velocidade atual

	li t2,208	# 208 largura e contador
	mul t1,s2,t2	# altura X posição = posição a ser mostrada (t1)

 	add a0,a0,t1	# endereço imagem - posição

	addi t0,t0,32	# endereço print + 30

	addi a0,a0,8	# primeiros pixeis

    # loop de impressao: salva os pixels da imagem na memoria do monitor, de 4 em 4 pixels.
loop_printColunaPista:
	blez t2,loop_printLinhaPista	# se a quantidade de colunas == contador de colunas -> próxima linha
	lw t5,0(a0)            	# coloca o a0(imagem) no t5
	sw t5,0(t0)            	# guarda t5 no t0(endereço de print)
	addi t0,t0,4            	# +4 pixeis ao endereço print
	addi a0,a0,4            	# +4 pixeis ao endereço da imagem
	addi t2,t2,-4            	# -4 pro contador
	addi t3,t3,-4            	# -4 pixeis no contador total
	j loop_printColunaPista
loop_printLinhaPista:
	li t2,208			# reseta contador
	addi t0,t0,112		# +60 pixeis == próxima linha ao endereço print
	blez t3,exit_printPista	# se o contador de pixeis == 0 -> fim
	j loop_printColunaPista

exit_printPista:
	ret

	


