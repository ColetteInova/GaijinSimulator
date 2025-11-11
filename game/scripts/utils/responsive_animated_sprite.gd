extends AnimatedSprite2D

# Script para AnimatedSprite2D responsivo que se adapta ao tamanho da tela

@export_group("Responsive Settings")
@export var maintain_aspect_ratio: bool = true
@export var fit_mode: FitMode = FitMode.CONTAIN
@export var anchor_position: AnchorPosition = AnchorPosition.CENTER
@export var margin: Vector2 = Vector2(50, 50)
@export var max_scale: float = 3.0
@export var min_scale: float = 0.5

@export_group("Animation Settings")
@export var auto_play: bool = true
@export var auto_play_animation: String = "default"
@export var animation_speed_scale: float = 1.0

@export_group("Movement")
@export var enable_floating: bool = false
@export var float_speed: float = 1.0
@export var float_amount: float = 20.0
@export var enable_rotation_animation: bool = false
@export var rotation_speed: float = 0.5
@export var enable_breathing: bool = false
@export var breathing_speed: float = 2.0
@export var breathing_amount: float = 0.1

enum FitMode {
	CONTAIN,    # Mantém sprite dentro da tela
	COVER,      # Cobre toda a tela
	FILL,       # Preenche sem manter proporção
	NONE        # Não redimensiona
}

enum AnchorPosition {
	CENTER,
	TOP_LEFT,
	TOP_RIGHT,
	BOTTOM_LEFT,
	BOTTOM_RIGHT,
	TOP_CENTER,
	BOTTOM_CENTER,
	CENTER_LEFT,
	CENTER_RIGHT
}

var viewport_size: Vector2
var time: float = 0.0
var initial_position: Vector2
var base_scale: Vector2
var initial_frame_size: Vector2


func _ready():
	# Pega o tamanho do primeiro frame para cálculos
	if sprite_frames and sprite_frames.has_animation(animation):
		var frame_texture = sprite_frames.get_frame_texture(animation, 0)
		if frame_texture:
			initial_frame_size = frame_texture.get_size()
	else:
		initial_frame_size = Vector2(32, 32)  # Tamanho padrão
	
	# Conecta ao sinal de redimensionamento da viewport
	get_viewport().size_changed.connect(_on_viewport_resized)
	
	# Configura posição e escala inicial
	_update_responsive_transform()
	initial_position = position
	base_scale = scale
	
	# Inicia animação automática
	if auto_play and sprite_frames and sprite_frames.has_animation(auto_play_animation):
		play(auto_play_animation)
		speed_scale = animation_speed_scale


func _on_viewport_resized():
	_update_responsive_transform()


func _process(delta):
	if not is_inside_tree():
		return
	
	# Atualiza se a viewport mudou de tamanho
	var current_viewport_size = get_viewport_rect().size
	if current_viewport_size != viewport_size:
		_update_responsive_transform()
	
	# Animações adicionais
	time += delta
	_apply_animations(delta)


func _update_responsive_transform():
	viewport_size = get_viewport_rect().size
	
	if initial_frame_size == Vector2.ZERO:
		return
	
	# Calcula a escala baseada no modo de ajuste
	var target_scale = _calculate_scale()
	
	# Limita a escala
	target_scale.x = clamp(target_scale.x, min_scale, max_scale)
	target_scale.y = clamp(target_scale.y, min_scale, max_scale)
	
	scale = target_scale
	base_scale = target_scale
	
	# Atualiza a posição baseada no anchor
	position = _calculate_position()
	initial_position = position


func _calculate_scale() -> Vector2:
	if fit_mode == FitMode.NONE:
		return scale
	
	var sprite_size = initial_frame_size
	var available_size = viewport_size - margin * 2
	
	match fit_mode:
		FitMode.CONTAIN:
			# Mantém proporção, cabe dentro da tela
			var scale_x = available_size.x / sprite_size.x
			var scale_y = available_size.y / sprite_size.y
			var uniform_scale = min(scale_x, scale_y)
			return Vector2(uniform_scale, uniform_scale) if maintain_aspect_ratio else Vector2(scale_x, scale_y)
		
		FitMode.COVER:
			# Mantém proporção, cobre toda a tela
			var scale_x = available_size.x / sprite_size.x
			var scale_y = available_size.y / sprite_size.y
			var uniform_scale = max(scale_x, scale_y)
			return Vector2(uniform_scale, uniform_scale) if maintain_aspect_ratio else Vector2(scale_x, scale_y)
		
		FitMode.FILL:
			# Preenche sem manter proporção
			return Vector2(
				available_size.x / sprite_size.x,
				available_size.y / sprite_size.y
			)
	
	return Vector2.ONE


func _calculate_position() -> Vector2:
	var pos = Vector2.ZERO
	
	match anchor_position:
		AnchorPosition.CENTER:
			pos = viewport_size / 2
		
		AnchorPosition.TOP_LEFT:
			pos = margin
		
		AnchorPosition.TOP_RIGHT:
			pos = Vector2(viewport_size.x - margin.x, margin.y)
		
		AnchorPosition.BOTTOM_LEFT:
			pos = Vector2(margin.x, viewport_size.y - margin.y)
		
		AnchorPosition.BOTTOM_RIGHT:
			pos = viewport_size - margin
		
		AnchorPosition.TOP_CENTER:
			pos = Vector2(viewport_size.x / 2, margin.y)
		
		AnchorPosition.BOTTOM_CENTER:
			pos = Vector2(viewport_size.x / 2, viewport_size.y - margin.y)
		
		AnchorPosition.CENTER_LEFT:
			pos = Vector2(margin.x, viewport_size.y / 2)
		
		AnchorPosition.CENTER_RIGHT:
			pos = Vector2(viewport_size.x - margin.x, viewport_size.y / 2)
	
	return pos


func _apply_animations(_delta: float):
	# Animação de flutuação
	if enable_floating:
		var float_offset = sin(time * float_speed) * float_amount
		position.y = initial_position.y + float_offset
	
	# Animação de rotação
	if enable_rotation_animation:
		rotation += rotation_speed * _delta
	
	# Animação de "respiração" (pulsação de escala)
	if enable_breathing:
		var breathing_scale = 1.0 + sin(time * breathing_speed) * breathing_amount
		scale = base_scale * breathing_scale


# Funções auxiliares para controlar animações externamente
func play_animation(anim_name: String, custom_speed: float = 1.0):
	"""Toca uma animação específica com velocidade customizada"""
	if sprite_frames and sprite_frames.has_animation(anim_name):
		play(anim_name)
		speed_scale = custom_speed


func pause_animation():
	"""Pausa a animação atual"""
	pause()


func resume_animation():
	"""Resume a animação"""
	play()


func set_anchor(new_anchor: AnchorPosition):
	"""Muda a posição de ancoragem"""
	anchor_position = new_anchor
	_update_responsive_transform()


func set_fit_mode(new_mode: FitMode):
	"""Muda o modo de ajuste"""
	fit_mode = new_mode
	_update_responsive_transform()


func enable_all_effects():
	"""Ativa todos os efeitos de movimento"""
	enable_floating = true
	enable_rotation_animation = true
	enable_breathing = true


func disable_all_effects():
	"""Desativa todos os efeitos de movimento"""
	enable_floating = false
	enable_rotation_animation = false
	enable_breathing = false
	position = initial_position
	rotation = 0
	scale = base_scale
