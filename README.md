# Three To Five

Jogo educacional de raciocínio rápido feito na **Godot Engine 4.6**. A fábrica parou, e você é o operário de plantão. Ande até a máquina central e resolva as contas do painel: são três números, e você escolhe as duas operações (`+`, `-`, `*`, `/`) que fazem o resultado dar **5**. A cada 5 acertos, um setor da fábrica volta a funcionar.

```
  2  [ * ]  5  [ - ]  5   = 5     CORRETO! +160
```

> Na primeira vez que você usa a máquina, ela explica as regras e propõe uma conta de calibração sem tempo. Este guia cobre o resto: instalar, rodar e jogar.

**Documentação:** [GDD](GDD-ThreeToFive.pdf) · [Manual de Reconstrução do Ambiente](ManualDeReconstrucao-ThreeToFive.pdf)

---

## 1. Requisitos

| Item | Versão / detalhe |
|---|---|
| Sistema operacional | Windows 10/11 (64 bits). Linux e macOS também rodam o projeto pelo editor |
| Engine (só para rodar pelo código-fonte) | **Godot Engine 4.6**, versão Standard (não precisa da versão .NET/C#) |
| Placa de vídeo | Compatível com OpenGL 3.3 (o projeto usa o renderizador *Compatibility*) |
| Navegador (versão Web) | Chrome, Edge ou Firefox atualizados |
| Entrada | Teclado e mouse |

O projeto não usa plugins nem bibliotecas externas. Fontes e sons já vêm dentro da pasta.

---

## 2. Jeito mais rápido: executável

1. Baixe o executável na página de *Releases* do repositório: <https://github.com/joaofilipigtissi/ThreeToFive/releases>.
2. **Windows:** extraia o `.zip` e dê dois cliques em `ThreeToFive.exe`.
   - Se o Windows SmartScreen avisar, clique em **Mais informações → Executar assim mesmo**. O aviso aparece porque o jogo não tem assinatura digital.
3. **Web:** abra o link da versão Web, publicado na mesma página.

Se preferir rodar pelo código-fonte, siga as seções 3 a 5.

---

## 3. Baixar o código-fonte

**Opção A: clonar com Git**

```bash
git clone https://github.com/joaofilipigtissi/ThreeToFive.git
cd ThreeToFive/three-to-five
```

**Opção B: baixar o ZIP**

1. No GitHub, clique em **Code → Download ZIP**.
2. Extraia em qualquer pasta.
3. O projeto da Godot fica na subpasta **`three-to-five/`**, onde está o arquivo `project.godot`.

---

## 4. Instalar a engine

1. Baixe a **Godot 4.6 (Standard)** em <https://godotengine.org/download>. Versões anteriores ficam em <https://godotengine.org/download/archive/>.
2. A Godot não precisa de instalação: basta extrair o `.zip` e abrir o executável (ex.: `Godot_v4.6-stable_win64.exe`).
3. Na primeira vez que abrir o projeto, a Godot importa sozinha as imagens, sons e fontes, criando a pasta `.godot/`. Isso pode levar alguns segundos.

---

## 5. Executar pelo editor

1. Abra a Godot 4.6 e, no **Gerenciador de Projetos**, clique em **Importar**.
2. Selecione o arquivo **`three-to-five/project.godot`** e clique em **Importar e Editar**.
3. Pressione **F5** ou clique em **▶ (Executar Projeto)**. O jogo abre no menu inicial.

Pela linha de comando:

```bash
godot --path three-to-five
```

### Gerar o executável (para a equipe)

O projeto já vem com os presets de exportação **Windows Desktop** e **Web**.

1. No editor, abra **Editor → Gerenciar Modelos de Exportação** e baixe os modelos da 4.6. Isso só precisa ser feito uma vez.
2. Abra **Projeto → Exportar**, escolha o preset e clique em **Exportar Projeto**.
   - Windows: gera `build/windows/ThreeToFive.exe`, com tudo embutido num único arquivo.
   - Web: gera `build/web/index.html`. Para testar localmente, use **Executar no Navegador** no próprio editor. Para publicar, suba a pasta no itch.io (marcando "This file will be played in the browser") ou no GitHub Pages.

---

## 6. Como jogar

### Iniciando uma partida

1. No menu, clique em **JOGAR** (ou aperte Enter). O menu também mostra o seu recorde.
2. Você aparece na fábrica, ainda escura. O objetivo está escrito na parte de baixo da tela.
3. Ande até a máquina. Quando aparecer **"Pressione E"**, aperte **E**.
4. Na primeira vez, a máquina explica a situação e as regras. Clique em **CONTINUAR** (ou aperte Enter) para avançar as falas.
5. Resolva a **conta de calibração**, que não tem tempo. Depois dela, começam as rodadas valendo pontos.

### Controles

| Ação | Comando |
|---|---|
| Andar | **W A S D** ou **setas** |
| Usar a máquina | **E** (perto da máquina) |
| Escolher uma operação | Clicar no seletor e escolher `+`, `-`, `*` ou `/` |
| Enviar a resposta | Botão **CONFIRMAR** |
| Avançar a fala da máquina | Botão **CONTINUAR** ou Enter |
| Sair do painel | **ESC** |
| Voltar ao menu (fora do painel) | **ESC** |

### Objetivo e regras

- Monte uma expressão com os três números, **na ordem em que aparecem**, cujo resultado seja exatamente **5**.
- A **precedência matemática vale**: `*` e `/` são calculados antes de `+` e `-`.
  - `1 + 9 - 4` = 6 (errado)
  - `1 * 9 - 4` = 5 (certo)
- A divisão é real: `7 / 2 = 3.5`.
- Toda conta tem pelo menos uma solução.
- Se errar, dá para tentar de novo enquanto ainda houver tempo.

### Pontuação

| Situação | O que acontece |
|---|---|
| **Acerto** | **100 pontos + 10 por segundo que sobrou** no cronômetro. A tela pisca em verde e o tempo das próximas rodadas cai 0,5 s. |
| **Erro** | O painel treme. Você não perde pontos e pode tentar de novo. |
| **Tempo esgotado** | Aparece "TEMPO ESGOTADO!" e uma nova conta começa em 1,2 s. Você não perde pontos. |

Os pontos e o **recorde** ficam sempre no canto superior esquerdo. O recorde fica salvo no computador.

### Progressão: os 4 setores

A cada **5 acertos**, um setor é religado: uma luz da máquina acende, a fábrica clareia e o motor fica mais forte.

| Setor | Tempo por conta | O que muda |
|---|---|---|
| 1 - Recepção | 10 s → 8 s | Só soma e subtração |
| 2 - Montagem | 7,5 s → 5,5 s | Contas que exigem `*` ou `/` |
| 3 - Alta Produção | 5 s → 3 s | Contas variadas |
| 4 - Núcleo Central | 3 s | Só uma combinação funciona |

- **Vitória:** religar os 4 setores (20 acertos). A máquina mostra a pontuação final, e você escolhe entre **JOGAR MAIS** (modo infinito, para bater o recorde) e **MENU**.
- **Derrota:** não existe. O jogo não tem vidas, e o desafio é ser rápido o bastante conforme o tempo diminui.

---

## 7. Limitações conhecidas

- Ainda não há trilha musical, apenas efeitos sonoros (cliques, acerto, erro, passos, motor da máquina).
- A fábrica tem uma única sala. Os setores aparecem nas luzes da máquina e na iluminação.
- O alvo é sempre 5, e não há como escolher a dificuldade.
- Voltar ao menu no meio da partida zera os pontos da sessão. O recorde continua salvo.
- Não existe versão mobile (controles de toque).

---

## 8. Estrutura do repositório

```
ThreeToFive/
├── README.md
├── GDD-ThreeToFive.pdf                  # Game Design Document (versão 2.0)
├── ManualDeReconstrucao-ThreeToFive.pdf
└── three-to-five/                       # Projeto Godot
    ├── project.godot                    # Cena inicial: MainMenu.tscn
    ├── export_presets.cfg               # Presets Windows e Web
    ├── Scenes/
    │   ├── MainMenu.tscn                # Menu (JOGAR, SAIR, recorde)
    │   ├── Main.tscn                    # Fábrica: operário, máquina, HUD
    │   ├── Machine/Machine.tscn         # Máquina (interação, luzes, motor)
    │   ├── Machine/MachinePanel.tscn    # Painel da conta + caixa de fala
    │   └── Player/Player.tscn           # Operário
    ├── Scripts/
    │   ├── GameManager.gd               # Pontos, recorde, setores, geração das contas
    │   ├── Machinepanel.gd              # Rodadas, cronômetro, tutorial, calibração
    │   ├── Machine.gd                   # "Pressione E", luzes de setor, som do motor
    │   ├── Main.gd                      # Paredes da sala, câmera, HUD, iluminação
    │   ├── Player.gd                    # Movimento, animação, passos
    │   ├── MainMenu.gd / MenuButton.gd  # Menu
    ├── fonts/                           # PrStart (pixel art)
    └── sounds/                          # click, success, error, game_over,
                                         # footstep, machine_hum, sector_up
```

### Onde mexer

- **Quantidade de acertos por setor, tempo e pontos:** constantes no topo de `GameManager.gd` (`HITS_PER_SECTOR`, `START_TIME`, `MIN_TIME`, `TIME_STEP`, `BASE_POINTS`, `BONUS_PER_SECOND`).
- **Falas da máquina:** funções `_start_tutorial`, `_finish_calibration` e `_announce_sector` em `Machinepanel.gd`.
- **Área onde o operário pode andar:** variáveis `walk_left`, `walk_right`, `walk_top` e `walk_bottom` do nó `Main`, editáveis no Inspetor.

---

## 9. Equipe

- João Filipi Girardi Tissi
- Pedro Baschung Bertazzon
- Kelwin Gameiro dos Santos
- João Lucas Lima Castro Rover

Engenharia de Software · Turma A · PAC 3

## Créditos

- Engine: [Godot Engine](https://godotengine.org/)
- Fonte: Press Start (Codeman38)
- Sons de passos, motor e setor: criados para o projeto
