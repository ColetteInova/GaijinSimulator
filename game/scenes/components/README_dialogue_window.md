# DialogueWindow Component

Componente de janela de diálogo com avatar animado do personagem.

## Características

- ✅ Avatar animado usando spritesheet
- ✅ Efeito de digitação no texto
- ✅ Configuração de spritesheet externa
- ✅ Nome do personagem personalizável
- ✅ Suporte a BBCode no texto
- ✅ Avanço automático opcional
- ✅ Sinais de eventos

## Uso Básico

### No Editor Godot

1. Adicione a cena `dialogue_window.tscn` como filho do seu nó
2. Configure as propriedades no inspetor:
   - **Avatar Spritesheet**: Textura do spritesheet
   - **Frame Width/Height**: Tamanho de cada frame
   - **Frames Horizontal/Vertical**: Quantidade de frames
   - **Character Name**: Nome do personagem
   - **Dialogue Text**: Texto do diálogo

### Por Script

```gdscript
# Exemplo 1: Configuração simples
var dialogue = $DialogueWindow
dialogue.set_dialogue("João", "Olá! Como você está?")

# Exemplo 2: Com avatar customizado
var avatar_texture = preload("res://assets/sprites/characters/player/avatar.png")
dialogue.set_avatar(avatar_texture, 4, 2, 64, 64)  # 4x2 frames, 64x64 pixels
dialogue.set_dialogue("Maria", "Bem-vindo ao jogo!")

# Exemplo 3: Conectar aos sinais
dialogue.dialogue_finished.connect(_on_dialogue_finished)
dialogue.dialogue_advanced.connect(_on_dialogue_advanced)

# Pular efeito de digitação
func _input(event):
    if event.is_action_pressed("ui_accept"):
        dialogue.skip_typing()

func _on_dialogue_finished():
    print("Diálogo terminou de digitar")

func _on_dialogue_advanced():
    print("Próximo diálogo")
```

## Propriedades Exportadas

### Avatar Settings
- `avatar_spritesheet` (Texture2D): Textura do spritesheet
- `frame_width` (int): Largura de cada frame
- `frame_height` (int): Altura de cada frame
- `frames_horizontal` (int): Frames na horizontal
- `frames_vertical` (int): Frames na vertical
- `animation_fps` (float): FPS da animação do avatar

### Dialogue Settings
- `character_name` (String): Nome do personagem
- `dialogue_text` (String): Texto do diálogo
- `text_speed` (float): Velocidade de digitação (segundos por caractere)
- `auto_advance` (bool): Avança automaticamente
- `auto_advance_delay` (float): Delay antes de avançar

### Window Style
- `window_theme` (Theme): Tema visual da janela

## Métodos Públicos

### `set_dialogue(character: String, text: String)`
Define o personagem e texto do diálogo.

### `set_avatar(spritesheet: Texture2D, h_frames: int, v_frames: int, width: int, height: int)`
Define o avatar do personagem com spritesheet.

### `skip_typing()`
Pula o efeito de digitação e mostra o texto completo.

## Sinais

### `dialogue_finished`
Emitido quando o texto termina de ser digitado.

### `dialogue_advanced`
Emitido quando o diálogo avança automaticamente (se `auto_advance` estiver ativo).

## Exemplo Completo

```gdscript
extends Node2D

@onready var dialogue = $DialogueWindow

func _ready():
    # Carregar avatar
    var avatar = preload("res://assets/sprites/characters/npc1/portrait.png")
    
    # Configurar diálogo
    dialogue.set_avatar(avatar, 4, 1, 128, 128)  # Spritesheet 4x1
    dialogue.animation_fps = 8.0
    dialogue.text_speed = 0.03
    dialogue.auto_advance = false
    
    # Conectar sinais
    dialogue.dialogue_finished.connect(_on_dialogue_done)
    
    # Iniciar conversa
    show_dialogue("NPC", "Olá, viajante! Seja bem-vindo à vila.")

func show_dialogue(character: String, text: String):
    dialogue.set_dialogue(character, text)
    dialogue.visible = true

func _input(event):
    if event.is_action_pressed("ui_accept"):
        if dialogue.is_typing:
            dialogue.skip_typing()
        else:
            # Próximo diálogo ou fechar
            dialogue.visible = false

func _on_dialogue_done():
    print("Pode pressionar Enter para continuar")
```

## Suporte a BBCode

O texto suporta formatação BBCode:

```gdscript
dialogue.set_dialogue("Mestre", "[color=yellow]Atenção![/color] Você encontrou um [b]item raro[/b]!")
```

## Customização Visual

Para customizar a aparência, você pode:

1. Criar um Theme personalizado e atribuir à propriedade `window_theme`
2. Modificar a cena `dialogue_window.tscn` diretamente
3. Ajustar os nós Panel, Labels conforme necessário
