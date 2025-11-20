extends Resource
class_name Character

## Representa um personagem reutilizável para diálogos

@export var character_name: String = ""  ## Nome do personagem
@export var avatar_spritesheet: SpriteFrames  ## SpriteFrames do avatar
@export var avatar_background: Texture2D  ## Fundo do avatar (opcional - sobrescreve o padrão)
@export_enum("Left", "Right") var avatar_position: int = 0  ## Posição do avatar (0 = Esquerda, 1 = Direita)
@export var play_animation: bool = true  ## Se true, toca a animação do avatar
