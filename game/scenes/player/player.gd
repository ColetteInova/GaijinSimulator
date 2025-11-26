extends CharacterBody2D

## Player com movimentação em 8 direções e animações correspondentes

@export_group("Movement")
@export var speed: float = 200.0  ## Velocidade de movimento em pixels/segundo
@export var enable_diagonal: bool = true  ## Permite movimento diagonal

@onready var animated_sprite: AnimatedSprite2D = $AnimatedSprite2D

# Controle de animação
var current_direction: Vector2 = Vector2.DOWN
var is_moving: bool = false

# Teclas configuráveis (carregadas do GameSettings)
var key_up: int = KEY_W
var key_down: int = KEY_S
var key_left: int = KEY_A
var key_right: int = KEY_D


func _ready():
	# Carrega as configurações de teclas
	load_key_bindings()
	# Inicia com animação idle para baixo
	play_animation("idle_down")


func _physics_process(_delta: float):
	# Captura o input de movimento
	var input_direction = get_input_direction()
	
	# Atualiza velocidade
	if input_direction != Vector2.ZERO:
		velocity = input_direction * speed
		is_moving = true
		current_direction = input_direction
	else:
		velocity = Vector2.ZERO
		is_moving = false
	
	# Move o personagem
	move_and_slide()
	
	# Atualiza a animação baseada na direção e movimento
	update_animation()


func load_key_bindings():
	"""Carrega as configurações de teclas do GameSettings"""
	if not GameSettings:
		push_warning("GameSettings não encontrado, usando teclas padrão")
		return
	
	var bindings = GameSettings.key_bindings
	
	# Converte string para Key code
	key_up = string_to_keycode(bindings.get("move_up", "W"))
	key_down = string_to_keycode(bindings.get("move_down", "S"))
	key_left = string_to_keycode(bindings.get("move_left", "A"))
	key_right = string_to_keycode(bindings.get("move_right", "D"))


func string_to_keycode(key_string: String) -> int:
	"""Converte uma string de tecla para o código da tecla"""
	key_string = key_string.to_upper().strip_edges()
	
	# Mapa de strings para keycodes
	var key_map = {
		"W": KEY_W, "A": KEY_A, "S": KEY_S, "D": KEY_D,
		"UP": KEY_UP, "DOWN": KEY_DOWN, "LEFT": KEY_LEFT, "RIGHT": KEY_RIGHT,
		"SPACE": KEY_SPACE, "SHIFT": KEY_SHIFT, "CTRL": KEY_CTRL,
		"E": KEY_E, "Q": KEY_Q, "R": KEY_R, "F": KEY_F,
		"Z": KEY_Z, "X": KEY_X, "C": KEY_C, "V": KEY_V,
		"TAB": KEY_TAB, "ESCAPE": KEY_ESCAPE, "ENTER": KEY_ENTER
	}
	
	return key_map.get(key_string, KEY_W)  # Retorna W como padrão


func get_input_direction() -> Vector2:
	"""Captura o input do jogador e retorna a direção normalizada"""
	var direction = Vector2.ZERO
	
	# Captura teclas configuradas ou setas
	if Input.is_action_pressed("ui_right") or Input.is_key_pressed(key_right):
		direction.x += 1
	if Input.is_action_pressed("ui_left") or Input.is_key_pressed(key_left):
		direction.x -= 1
	if Input.is_action_pressed("ui_down") or Input.is_key_pressed(key_down):
		direction.y += 1
	if Input.is_action_pressed("ui_up") or Input.is_key_pressed(key_up):
		direction.y -= 1
	
	# Se diagonal está desabilitado, prioriza um eixo
	if not enable_diagonal and direction.x != 0 and direction.y != 0:
		# Prioriza o eixo com maior movimento
		if abs(direction.x) > abs(direction.y):
			direction.y = 0
		else:
			direction.x = 0
	
	return direction.normalized()


func update_animation():
	"""Atualiza a animação baseada na direção atual e se está se movendo"""
	var animation_name = get_animation_for_direction(current_direction, is_moving)
	play_animation(animation_name)


func get_animation_for_direction(direction: Vector2, moving: bool) -> String:
	"""Retorna o nome da animação apropriada para a direção e estado de movimento"""
	if direction == Vector2.ZERO:
		direction = Vector2.DOWN  # Padrão para baixo se não houver direção
	
	# Normaliza e determina a direção predominante
	var angle = direction.angle()
	
	# Converte o ângulo para uma das 8 direções
	# 0° = direita, 90° = baixo, 180° = esquerda, -90° = cima
	var dir_name = ""
	
	# Determina a direção baseada no ângulo (com tolerância de 22.5° para cada direção)
	if angle >= -PI/8 and angle < PI/8:
		dir_name = "left"
	elif angle >= PI/8 and angle < 3*PI/8:
		dir_name = "down_left"
	elif angle >= 3*PI/8 and angle < 5*PI/8:
		dir_name = "down"
	elif angle >= 5*PI/8 and angle < 7*PI/8:
		dir_name = "down_right"
	elif angle >= 7*PI/8 or angle < -7*PI/8:
		dir_name = "right"
	elif angle >= -7*PI/8 and angle < -5*PI/8:
		dir_name = "up_right"
	elif angle >= -5*PI/8 and angle < -3*PI/8:
		dir_name = "up"
	else:  # -3*PI/8 a -PI/8
		dir_name = "up_left"
	
	# Adiciona prefixo walk_ ou idle_
	var prefix = "walk_" if moving else "idle_"
	return prefix + dir_name


func play_animation(animation_name: String):
	"""Toca a animação se ela existir e não estiver já tocando"""
	if animated_sprite.sprite_frames.has_animation(animation_name):
		if animated_sprite.animation != animation_name:
			animated_sprite.play(animation_name)
	else:
		push_warning("Animation not found: " + animation_name)


func set_direction(direction: Vector2):
	"""Define manualmente a direção do player (útil para cutscenes)"""
	current_direction = direction.normalized()
	update_animation()


func set_speed(new_speed: float):
	"""Altera a velocidade do player"""
	speed = new_speed


func stop_movement():
	"""Para o movimento do player"""
	velocity = Vector2.ZERO
	is_moving = false
	update_animation()
