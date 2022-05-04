.data
# Numero de Notas a tocar
sfxLevelNum: .word 31
# lista de nota,duração,nota,duração,nota,duração,...
#sfxCarro: 45,50
sfxLevel: 64,300,0,61,300,0,54,300,1,64,100,0,61,100,1,63,600,0,54,600,0,59,600,1,71,100,1,61,100,0,54,100,0,59,100,1,63,200,1,63,100,0,54,100,1,64,100,1,63,200,0,54,200,0,59,200,1,61,200,0,54,200,0,59,200,1,71,200,0,54,200,0,59,200,1,63,200,0,54,200,0,59,200,1,61,1200,0,54,1200,0,49,1200,1
#som: nota,duração,toca ao mesmo tempo?
.text
soundSet:
	la s0,sfxLevelNum	# define o endereço do número de notas
	lw s1,0(s0)		# le o numero de notas
	la s0,sfxLevel		# define o endereço das notas
	li t0,0			# zera o contador de notas
	li a2,7			# define o instrumento
	li a3,100		# define o volume

soundLoop:
	beq t0,s1, FIM		# contador chegou no final? então  vá para FIM
	lw a0,0(s0)		# le o valor da nota
	lw a1,4(s0)		# le a duracao da nota
	lw a4,8(s0)		# le se pula ou n
	
	bnez a4,soundLoopTimer

	li a7,31		
	ecall
	
	addi s0,s0,12		# incrementa para o endereço da próxima nota
	addi t0,t0,1		# incrementa o contador de notas
	j soundLoop
	
soundLoopTimer:
	li a7,33		
	ecall

	addi s0,s0,12		# incrementa para o endereço da próxima nota
	addi t0,t0,1		# incrementa o contador de notas
	j soundLoop
FIM:
	ret
