
# Numero de Notas a tocar
# lista de nota,duração,nota,duração,nota,duração,...
#sfxCarro: 45,50
#sfxLevel: 31,7,100,64,300,0,61,300,0,54,300,1,64,100,0,61,100,1,63,600,0,54,600,0,59,600,1,71,100,1,61,100,0,54,100,0,59,100,1,63,200,1,63,100,0,54,100,1,64,100,1,63,200,0,54,200,0,59,200,1,61,200,0,54,200,0,59,200,1,71,200,0,54,200,0,59,200,1,63,200,0,54,200,0,59,200,1,61,1200,0,54,1200,0,49,1200,1
.data
#sfxEmpty: .word 3,58,300,54,500,1,51,600,1,48,1200,0
#primeiros 3 numeros são numero de notas, instrumento e volume
#som: nota,duração,toca ao mesmo tempo? t1, t2, t3
.text

# s4 = musica atual
soundSet:
	la s4,sfxEmpty		# define o endereço das notas
soundPlay:
	lw t1,0(s4)		# le o numero de notas
	lw a2,4(s4)		# le o instrumento
	lw a3,8(s4)		# le o volume
	addi s4,s4,12		# pula para as notas
	li t0,0			# zera o contador de notas
soundLoop:
	beq t0,t1, soundLoopFim	# contador chegou no final? então  vá para FIM
	lw a0,0(s4)		# le o valor da nota
	lw a1,4(s4)		# le a duracao da nota
	lw t2,8(s4)		# le se pula ou n
	
	bnez t2,soundLoopTimer	# se n for zero toca separado

	li a7,31		# toca o som	
	ecall
	
	addi s4,s4,12		# incrementa para o endereço da próxima nota
	addi t0,t0,1		# incrementa o contador de notas
	j soundLoop
	
soundLoopTimer:
	li a7,33		# toca o som no seu tempo
	ecall
	
	#mv a0,a1
	#li a7,32
	#ecall

	addi s4,s4,12		# incrementa para o endereço da próxima nota
	addi t0,t0,1		# incrementa o contador de notas
	j soundLoop
soundLoopFim:
	ret
