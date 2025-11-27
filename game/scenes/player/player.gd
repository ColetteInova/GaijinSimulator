extends CharacterBody2D

## Player com movimentação em 8 direções e sistema modular de camadas

const BREATHING_AMPLITUDE: float = 0.01
const BREATHING_SPEED: float = 2.0

@export_group("Movement")
@export var speed: float = 200.0  ## Velocidade de movimento em pixels/segundo
@export var enable_diagonal: bool = true  ## Permite movimento diagonal

@export_group("Appearance")
@export var appearance: PlayerAppearance  ## Configuração de aparência do player

@export_group("Camera")
@export var camera_zoom: Vector2 = Vector2.ONE

# Referências para as camadas de sprite
var sprite_container: Node2D
var sprite_layers: Dictionary = {}
var layer_order = [
	"back_hair",    # Layer 0
	"skin",         # Layer 1
	"eyes",         # Layer 2
	"shirt",        # Layer 3
	"pants",        # Layer 6
	"shoes",        # Layer 5
	"front_hair",   # Layer 4
	"glasses",      # Acessório
	"hat"           # Acessório
]

# Controle de animação
var current_direction: Vector2 = Vector2.DOWN
var is_moving: bool = false
var last_animation: String = ""
var breathing_time: float = 0.0
var breathing_enabled: bool = false
var player_camera: Camera2D

# Teclas configuráveis (carregadas do GameSettings)
var key_up: int = KEY_W
var key_down: int = KEY_S
var key_left: int = KEY_A
var key_right: int = KEY_D



func _ready():
	create_sprite_container()
	player_camera = get_node_or_null("Camera2D")
	# Cria as camadas de sprite
	setup_sprite_layers()
	
	# Carrega a aparência (usa default se não configurada)
	if not appearance:
		# Tenta carregar do PlayerData primeiro
		if PlayerData and PlayerData.player_appearance:
			appearance = PlayerData.player_appearance
		else:
			appearance = PlayerAppearance.create_default()
	
	apply_appearance()
	
	# Carrega as configurações de teclas
	load_key_bindings()
	
	# Inicia com animação idle para baixo
	play_animation("idle_down")
	update_breathing_state()
	apply_camera_zoom()


func create_sprite_container():
	"""Garante um nó separado para manipular as camadas de sprite"""
	if sprite_container:
		return
	
	sprite_container = Node2D.new()
	sprite_container.name = "SpriteContainer"
	add_child(sprite_container)


func setup_sprite_layers():
	"""Cria os nós AnimatedSprite2D para cada camada"""
	if not sprite_container:
		create_sprite_container()

	sprite_layers.clear()
	for layer_name in layer_order:
		var sprite = AnimatedSprite2D.new()
		sprite.name = layer_name.capitalize()
		sprite_container.add_child(sprite)
		sprite_layers[layer_name] = sprite


func apply_appearance():
	"""Aplica a configuração de aparência carregando as texturas"""
	if not appearance:
		push_warning("No appearance configured")
		return
	
	# Aplica skin (obrigatória)
	load_layer("skin", "layer1_skin")
	
	# Aplica eyes
	if appearance.eyes_enabled:
		load_layer("eyes", "layer2_eyes")
	
	# Aplica shirt
	if appearance.shirt_enabled:
		load_layer("shirt", "layer3_shirt")
	
	# Aplica front hair
	if appearance.front_hair_enabled:
		load_layer("front_hair", "layer4_front_hair")
	
	# Aplica shoes
	if appearance.shoes_enabled:
		load_layer("shoes", "layer5_shoes")
	
	# Aplica pants
	if appearance.pants_enabled:
		load_layer("pants", "layer6_pants")
	
	# Aplica back hair
	if appearance.back_hair_enabled:
		load_layer("back_hair", "layer0_back_hair")
	
	# Aplica acessórios
	if appearance.glasses != PlayerAppearance.GlassesType.NONE:
		load_accessory("glasses", "glasses")
	
	if appearance.hat != PlayerAppearance.HatType.NONE:
		load_accessory("hat", "hat")


func load_layer(layer_name: String, folder: String):
	"""Carrega uma camada específica do player"""
	if not sprite_layers.has(layer_name):
		return
	
	var sprite: AnimatedSprite2D = sprite_layers[layer_name]
	var texture_path = appearance.get_layer_path(folder)
	
	var sprite_frames = PlayerSpriteBuilder.create_spriteframes_from_texture(texture_path)
	if sprite_frames:
		sprite.sprite_frames = sprite_frames
		sprite.visible = true


func load_accessory(layer_name: String, accessory_type: String):
	"""Carrega um acessório unisex"""
	if not sprite_layers.has(layer_name):
		return
	
	var sprite: AnimatedSprite2D = sprite_layers[layer_name]
	var texture_path = appearance.get_accessory_path(accessory_type)
	
	var sprite_frames = PlayerSpriteBuilder.create_spriteframes_from_texture(texture_path)
	if sprite_frames:
		sprite.sprite_frames = sprite_frames
		sprite.visible = true


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


func _process(delta: float) -> void:
	if breathing_enabled and sprite_container:
		breathing_time = wrapf(breathing_time + delta * BREATHING_SPEED, 0.0, TAU)
		var scale_factor = 1.0 + sin(breathing_time) * BREATHING_AMPLITUDE
		sprite_container.scale = Vector2(scale_factor, scale_factor)


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
	update_breathing_state()


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
	"""Toca a animação em todas as camadas ativas"""
	# Só muda a animação se for diferente da atual
	if animation_name == last_animation:
		return
	
	# Toca a animação em todas as camadas que têm essa animação
	for layer_name in sprite_layers:
		var sprite: AnimatedSprite2D = sprite_layers[layer_name]
		if sprite.visible and sprite.sprite_frames and sprite.sprite_frames.has_animation(animation_name):
			sprite.play(animation_name)
	
	last_animation = animation_name


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


func apply_camera_zoom():
	"""Aplica o zoom exportado à Camera2D anexada"""
	if player_camera:
		player_camera.zoom = camera_zoom


func update_breathing_state():
	"""Alterna a animação de respiração conforme o movimento"""
	if is_moving:
		stop_breathing_animation()
	else:
		start_breathing_animation()


func start_breathing_animation():
	"""Inicia a animação suave de respiração durante o idle"""
	if breathing_enabled or not sprite_container:
		return
	
	breathing_enabled = true
	breathing_time = 0.0


func stop_breathing_animation():
	"""Interrompe a animação de respiração quando o player anda"""
	if not breathing_enabled or not sprite_container:
		return
	
	breathing_enabled = false
	breathing_time = 0.0
	sprite_container.scale = Vector2.ONE
