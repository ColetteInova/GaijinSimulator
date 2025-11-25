extends Resource
class_name Character

## Representa um personagem reutilizável para diálogos

const Nationality = preload("res://scripts/utils/nationality.gd")
const NativeLevel = preload("res://scripts/utils/conversation_level.gd")

@export var character_name: String = ""  ## Nome do personagem
@export var avatar_spritesheet: SpriteFrames  ## SpriteFrames do avatar
@export var avatar_background: Texture2D  ## Fundo do avatar (opcional - sobrescreve o padrão)
@export_enum("Left", "Right") var avatar_position: int = 0  ## Posição do avatar (0 = Esquerda, 1 = Direita)
@export var play_animation: bool = true  ## Se true, toca a animação do avatar
@export var nationality: Nationality.Type = Nationality.Type.JAPAN  ## Nacionalidade do personagem (obrigatório)
@export var is_bilingual: bool = false  ## Se true, mostra traduções bilíngues
@export var native_level: NativeLevel.Level = NativeLevel.Level.N5  ## Nível do idioma nativo do personagem (N1-N5)
@export var text_theme: Theme  ## Tema personalizado para o texto do diálogo (fonte, cor, etc)
