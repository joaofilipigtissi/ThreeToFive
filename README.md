# Three To Five

Jogo de raciocínio rápido feito na **Godot Engine 4.6**. A cada rodada aparecem três números, e você precisa escolher os dois operadores matemáticos (`+`, `-`, `*`, `/`) que fazem a conta dar **5** antes que o tempo acabe. Quanto mais você acerta, menos tempo tem.

```
  2  [ * ]  5  [ - ]  5   =  5  -  CORRETO
```

> O jogo ainda não tem tutorial interno. Este guia explica tudo o que é preciso para instalar, rodar e jogar.

---

## 1. Requisitos

| Item | Versão / detalhe |
|---|---|
| Sistema operacional | Windows 10/11 (64 bits), Linux (64 bits) ou macOS 10.15+ |
| Engine | **Godot Engine 4.6**, versão padrão (**não** precisa da versão .NET/C#) |
| Placa de vídeo | Compatível com Vulkan, Direct3D 12 ou Metal (o projeto usa o renderizador *Forward+*) |
| Git (opcional) | Qualquer versão recente, só para clonar o repositório |
| Entrada | Mouse (o teclado também funciona, veja a seção de controles) |

O projeto não usa plugins, addons nem bibliotecas externas. Fontes e sons já vêm dentro da pasta.

---

## 2. Como baixar o projeto

**Opção A: clonar com Git**

```bash
git clone <URL-DO-REPOSITORIO>
cd ThreeToFive
```

**Opção B: baixar o ZIP**

1. Baixe o arquivo `.zip` do projeto (no GitHub: botão **Code → Download ZIP**).
2. Extraia em qualquer pasta. Exemplo: `C:\Jogos\ThreeToFive`.
3. Confira se o arquivo `project.godot` está na pasta extraída.

---

## 3. Instalando a engine e configurando o ambiente

1. Acesse <https://godotengine.org/download> e baixe a **Godot 4.6, versão Standard**, para o seu sistema.
   - Versões anteriores estão em <https://godotengine.org/download/archive/>.
2. A Godot não precisa de instalação: basta extrair o `.zip` e abrir o executável (ex.: `Godot_v4.6-stable_win64.exe`).
3. Não há dependências para instalar. Na primeira abertura, a Godot importa sozinha os sons, as fontes e o ícone (isso cria a pasta `.godot/`). Pode levar alguns segundos.

> Se você abrir o projeto numa versão **anterior** à 4.6, a Godot vai avisar que o projeto foi feito numa versão mais nova. Use a 4.6 para evitar problemas.

---

## 4. Como executar o jogo

### Pelo editor da Godot (recomendado)

1. Abra a Godot 4.6.
2. No **Gerenciador de Projetos**, clique em **Importar**.
3. Navegue até a pasta do projeto e selecione o arquivo **`project.godot`**.
4. Clique em **Importar e Editar**.
5. Com o editor aberto, pressione **F5** ou clique no botão **▶ (Executar Projeto)** no canto superior direito.
   - A cena principal (`main.tscn`) já está configurada e abre direto.

### Pela linha de comando

Com o executável da Godot no PATH (ou usando o caminho completo dele):

```bash
# dentro da pasta do projeto
godot --path .
```

No Windows, por exemplo:

```bat
"C:\Godot\Godot_v4.6-stable_win64.exe" --path "C:\Jogos\ThreeToFive"
```

### Se a tela ficar preta ou o jogo não abrir

O projeto usa *Forward+* com Direct3D 12 no Windows. Em PCs mais antigos ou com driver de vídeo desatualizado, faça o seguinte:

1. No editor, vá em **Projeto → Configurações do Projeto → Renderização → Renderizador**.
2. Mude **Método de Renderização** para **Compatibility** (ou mude o driver do Windows para **vulkan**).
3. Salve e reinicie o editor quando ele pedir.

---

## 5. Como jogar

### Iniciando uma partida

A partida começa **automaticamente** assim que o jogo abre. Não há menu inicial. Para recomeçar do zero, feche a janela e execute de novo.

### Tela do jogo

```
┌──────────────────────────────────────────┐
│ Alvo: 5          Pontos: 0     Tempo: 10 │
│                                          │
│    9   [ + ▼ ]   4   [ + ▼ ]   1         │
│                                          │
│              [ CONFIRMAR ]               │
│                                          │
│ Resultado:                               │
└──────────────────────────────────────────┘
```

### Controles

| Ação | Mouse | Teclado |
|---|---|---|
| Escolher o 1º operador | Clicar no primeiro seletor e escolher `+`, `-`, `*` ou `/` | `Tab` até o seletor, `Enter`/`Espaço` para abrir, setas para escolher, `Enter` para confirmar |
| Escolher o 2º operador | Clicar no segundo seletor e escolher o operador | Mesmo esquema do anterior |
| Enviar a resposta | Clicar em **CONFIRMAR** | `Tab` até o botão e `Enter`/`Espaço` |
| Sair do jogo | Fechar a janela | `F8` no editor encerra a execução |

O que cada operador faz:

| Operador | Significado |
|---|---|
| `+` | Soma |
| `-` | Subtração |
| `*` | Multiplicação |
| `/` | Divisão |

### Objetivo

Montar uma expressão com os três números, **na ordem em que aparecem**, cujo resultado seja exatamente **5**. Fazer o máximo de pontos possível.

### Regras

- A ordem dos números é fixa: você só escolhe os operadores.
- A **precedência matemática é respeitada**: `*` e `/` são calculados antes de `+` e `-`.
  - `1 + 9 - 4` = 6 
  - `1 * 9 - 4` = 5 
- A divisão é real: `7 / 2 = 3.5`. Só vale se o resultado for exatamente 5.
- Divisão por zero dá 0.
- Toda rodada tem pelo menos uma combinação correta.

### Acerto, erro e progressão

| Situação | O que acontece |
|---|---|
| **Acertou** | +100 pontos, som de sucesso, resultado em verde, painel pisca. O tempo das próximas rodadas cai 0,5 s. |
| **Errou** | Som de erro, resultado em vermelho, painel treme. Nenhum ponto é perdido. |
| **Tempo esgotado** | Som de fim de tempo e a mensagem "Tempo esgotado!". Nenhum ponto é perdido. |

Depois de qualquer um dos três casos, uma nova rodada começa em 2 segundos.

- O tempo começa em **10 s** por rodada e diminui a cada acerto, até o mínimo de **3 s**.
- **Não existe condição de vitória nem de derrota**: o jogo é infinito, no estilo *high score*. O desafio é ir o mais longe possível enquanto o tempo diminui.

---

## 6. Limitações conhecidas e funcionalidades não implementadas

**Limitações / bugs conhecidos**

- Durante a pausa de 2 s entre rodadas, dá para clicar em CONFIRMAR de novo e pontuar duas vezes.
- Como o tempo da rodada cai de 0,5 em 0,5, o contador pode mostrar valores quebrados, como `Tempo: 9.5`.
- Antes da primeira jogada, os textos da tela podem aparecer como `Score: 0` / `Tempo restante: 10s` e depois mudar para `Pontos:` / `Tempo:`.
- Errar ou deixar o tempo acabar não tem penalidade.
- Os números saem de uma lista fixa de 23 combinações, então elas se repetem.
- A pontuação não é salva: fechar o jogo zera tudo.
- O projeto foi configurado e testado principalmente no Windows (driver D3D12).

**Ainda não implementado**

- Tutorial dentro do jogo.
- Menu inicial, botão de pausa e opção de reiniciar sem fechar o jogo.
- Tela de game over, sistema de vidas e recorde (*high score*) salvo.
- Alvo diferente de 5 ou níveis de dificuldade selecionáveis.
- Geração automática de rodadas.
- Builds exportadas (`.exe`, Linux, Web): por enquanto o jogo só roda pelo editor da Godot.

---

## 7. Estrutura do projeto

```
ThreeToFive/
├── project.godot      # Configuração do projeto (cena principal: main.tscn)
├── main.tscn          # Cena única: painel, labels, seletores, botão, timer e sons
├── main.gd            # Toda a lógica do jogo
├── icon.svg           # Ícone do projeto
├── fonts/
│   ├── PrStart.ttf    # Fonte pixel art usada na interface
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
| `start_new_round()` | Sorteia os números da rodada, reseta os operadores e reinicia o timer |
| `update_timer()` | Chamada a cada segundo; atualiza o tempo e trata o tempo esgotado |
| `check_expression()` | Monta a expressão, calcula, compara com o alvo e dá os pontos |
| `evaluate_expression()` | Avalia `a op1 b op2 c` respeitando a precedência de `*` e `/` |
| `calculate()` | Faz uma operação entre dois números |
| `shake_panel()` / `success_effect()` / `result_bounce()` | Animações de erro e acerto |

### Adicionando novas rodadas

As combinações ficam na lista `possible_rounds`, dentro de `start_new_round()`. Para adicionar uma, inclua um trio que tenha pelo menos uma solução:

```gdscript
var possible_rounds = [
    [2, 5, 5],   # 2 * 5 - 5 = 5
    [1, 9, 4],   # 1 * 9 - 4 = 5
    [6, 2, 1],   # 6 - 2 + 1 = 5
    # ...
]
```

Para mudar o alvo, altere a variável `target` no topo do script e o texto do `TargetLabel` na cena.

---

## 8. Equipe

- João Filipi Girardi Tissi
- Pedro Baschung Bertazzon
- Kelwin Gameiro dos Santos
- João Lucas Lima Castro Rover

Engenharia de Software · Turma A · PAC 3

## Créditos

- Engine: [Godot Engine](https://godotengine.org/)
- Fonte: Press Start (Codeman38)
