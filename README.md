# 🚗 RoadFighter_RISC-V 🏎
Recriação do jogo Road Fighter (NES) em Assembly. Projeto em RISC-V da matéria ISC na UNB. \

![upload-road-fighter-1575231313140](https://user-images.githubusercontent.com/64702639/160934977-a04cc4e6-6c98-43d6-b299-9f5ba6c1797d.jpeg)

# Dicas
- Usar word invés de byte
- Comentar tudo que fazer
- Cor transparente magenta
- Tamanho dos sprites em múltiplos de 4
- Convenção para nomes de funções
- Ver projetos anteriores no "Execute" do RARS
- Menus com 1 e 2 para selecionar
- Mais díficil são os detalhes
- movimentações serão feitas através de uma função que printa o sprite na coordenada X, apaga e printa de novo na coordenada Y
- Endereço final = multiplicação da resolução e depois transforma para hexadecimal / ex: 320 x 240 = 76.800 = 12C00
- Combustivel é um temporizador, o tempo conta mesmo se o carro estiver parado. Se o carro bater em um carro colorido, tempo += 5, se morrer, tempo -= 5 /// jogo acaba quando tempo = 0
- carros vermelhos mudam de posição apenas uma vez /// carros azuis mudam de posição constantemente /// carros amarelos não mudam de posição.

# Pesquisas:
- [X] Vídeo discord transformando bitmap em .data
- [ ] Sprite do carro na tela
- [ ] Carro mexendo com teclado
- [ ] Como fazer a função de movimentação



# Progresso:
- [X] Printar alguma coisa no bitmap
- [ ] Fazer um pixel se mexer
- [ ] Mapa e todos os sprites printáveis
- [ ] Utilização do teclado
- [ ] Movimentação
- [ ] Áudio
