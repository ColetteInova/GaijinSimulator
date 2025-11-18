extends Resource
class_name SpriteParallaxLayer

## Recurso que define uma camada para o ParallaxBackground

@export var cloud_texture: Texture2D
@export var speed: float = 10.0  ## Velocidade de movimento em pixels por segundo (valores menores = mais lento)
@export var y_position: float = 50.0  ## Posição Y das nuvens na tela
@export var scale: float = 1.0  ## Escala das nuvens
@export var tint: Color = Color.WHITE  ## Cor/tint das nuvens
@export var move_left: bool = true  ## Se true, move para esquerda; se false, move para direita


func _init(
	p_texture: Texture2D = null,
	p_speed: float = 10.0,
	p_y_position: float = 50.0,
	p_scale: float = 1.0,
	p_tint: Color = Color.WHITE,
	p_move_left: bool = true
):
	cloud_texture = p_texture
	speed = p_speed
	y_position = p_y_position
	scale = p_scale
	tint = p_tint
	move_left = p_move_left
