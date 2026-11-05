# Three To Five

Joguinho de raciocínio rápido feito em **Godot 4.6**: o jogo mostra três números e você tem que escolher os dois operadores certos para que a conta dê **5**, antes que o tempo acabe.

```
  2  [ * ]  5  [ - ]  5   =  5   ✔
```

## Como jogar

1. A cada rodada aparecem três números sorteados (ex.: `9  4  1`).
2. Entre eles há dois seletores de operador: `+`, `-`, `*` ou `/`.
3. Monte a expressão que resulte em **5** e clique em **CONFIRMAR**.
4. Acertou: **+100 pontos**, o painel pisca em verde e a próxima rodada fica mais rápida.
5. Errou: o painel treme e aparece o resultado em vermelho.
6. Se o tempo zerar, aparece "Tempo esgotado!" e uma nova rodada começa.

### Regras da conta

- A **precedência matemática é respeitada**: `*` e `/` são calculados antes de `+` e `-`.
  - `1 + 9 - 4` = 6 ❌
  - `1 * 9 - 4` = 5 ✔
- Divisão por zero retorna 0.
- A divisão é real (`7 / 2 = 3.5`), então o resultado só vale se for exatamente 5.

### Dificuldade

- Cada rodada começa com **10 segundos**.
- A cada acerto o tempo da rodada cai **0,5 s**, até o mínimo de 3 s.
- Não há fim de jogo: o desafio é fazer a maior pontuação possível.

## Como rodar

**Requisitos:** [Godot Engine 4.6](https://godotengine.org/download) (versão padrão, sem .NET).

1. Abra o Godot e clique em **Importar**.
2. Selecione o arquivo `project.godot` desta pasta.
3. Pressione **F5** (ou o botão ▶) para rodar.

> O projeto está configurado com o renderizador **Forward+** e driver **D3D12** no Windows. Se a máquina não suportar, troque em *Projeto → Configurações do Projeto → Renderização* para *Compatibility* ou para Vulkan.

## Estrutura do projeto

```
ThreeToFive/
├── project.godot      # Configuração do projeto (cena principal: main.tscn)
├── main.tscn          # Cena única: painel da "máquina", labels, botões, timer e sons
├── main.gd            # Toda a lógica do jogo
├── icon.svg           # Ícone do projeto
├── fonts/
│   ├── PrStart.ttf    # Fonte pixel art "Press Start" usada na interface
│   └── prstartk.ttf
└── sounds/
    ├── click.wav      # Clique no botão
    ├── success.wav    # Acerto
    ├── error.wav      # Erro
    └── game_over.wav  # Tempo esgotado
```

### Principais funções de `main.gd`

| Função | O que faz |
|---|---|
| `start_new_round()` | Sorteia uma das 23 combinações de números, reseta operadores e reinicia o timer |
| `update_timer()` | Chamada a cada segundo pelo `RoundTimer`; trata o tempo esgotado |
| `check_expression()` | Monta a expressão escolhida, calcula, compara com o alvo e dá pontos |
| `evaluate_expression()` | Avalia `a op1 b op2 c` respeitando a precedência de `*` e `/` |
| `calculate()` | Executa uma única operação entre dois números |
| `shake_panel()` / `success_effect()` / `result_bounce()` | Animações (tweens) de erro e acerto |
| `_on_confirm_button_*()` | Efeitos de hover/clique do botão CONFIRMAR |

### Adicionando novas rodadas

As combinações ficam na lista `possible_rounds` dentro de `start_new_round()`. Basta adicionar um novo trio, garantindo que exista pelo menos uma combinação de operadores que dê 5:

```gdscript
var possible_rounds = [
    [2, 5, 5],   # 2 * 5 - 5 = 5
    [1, 9, 4],   # 1 * 9 - 4 = 5
    [6, 2, 1],   # 6 - 2 + 1 = 5
    # ...
]
```

Para mudar o número alvo, altere a variável `target` no topo do script (e o texto do `TargetLabel` na cena).

## Problemas conhecidos / ideias de melhoria

- Durante os 2 segundos de pausa entre rodadas, dá para clicar em CONFIRMAR de novo e pontuar duas vezes. Desabilitar o botão nesse intervalo resolve.
- Como o tempo da rodada diminui de 0,5 em 0,5, o contador pode mostrar valores como `Tempo: 9.5`.
- O texto inicial dos labels na cena (`Score: 0`, `Tempo restante: 10s`) é diferente do usado no script (`Pontos:`, `Tempo:`).
- A função `update_expression_display()` lê os operadores, mas ainda não atualiza nada na tela.
- Arquivos que podem ser removidos do repositório: `main.tscn*.tmp`, `main.gltf`, `main.gltf.import` e `main0.bin` (sobras do editor).
- Ideias: tela de game over com recorde, vidas, alvo variável por rodada, rodadas geradas automaticamente.

## Créditos

- Engine: [Godot](https://godotengine.org/)
- Fonte: Press Start (Codeman38)
