extends Sprite2D

# Configurações de responsividade
@export_group("Responsive Settings")
@export var maintain_aspect_ratio: bool = true
@export var fit_mode: FitMode = FitMode.CONTAIN
@export var anchor_position: AnchorPosition = AnchorPosition.CENTER
@export var margin: Vector2 = Vector2(50, 50)
@export var max_scale: float = 3.0
@export var min_scale: float = 0.5

@export_group("Animation")
@export var enable_floating: bool = true
@export var float_speed: float = 1.0
@export var float_amount: float = 20.0
@export var enable_rotation: bool = false
@export var rotation_speed: float = 0.5

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

var initial_texture_size: Vector2
var viewport_size: Vector2
var time: float = 0.0
var initial_position: Vector2


func _ready():
	if texture:
		initial_texture_size = texture.get_size()
	
	# Conecta ao sinal de redimensionamento da viewport
	get_viewport().size_changed.connect(_on_viewport_resized)
	
	# Configura posição e escala inicial
	_update_responsive_transform()
	initial_position = position


func _on_viewport_resized():
	_update_responsive_transform()


func _process(delta):
	if not is_inside_tree():
		return
	
	# Atualiza se a viewport mudou de tamanho
	var current_viewport_size = get_viewport_rect().size
	if current_viewport_size != viewport_size:
		_update_responsive_transform()
	
	# Animações
	if enable_floating or enable_rotation:
		time += delta
		_animate(delta)


func _update_responsive_transform():
	viewport_size = get_viewport_rect().size
	
	if not texture:
		return
	
	# Calcula a escala baseada no modo de ajuste
	var target_scale = _calculate_scale()
	
	# Limita a escala
	target_scale.x = clamp(target_scale.x, min_scale, max_scale)
	target_scale.y = clamp(target_scale.y, min_scale, max_scale)
	
	scale = target_scale
	
	# Atualiza a posição baseada no anchor
	position = _calculate_position()
	initial_position = position


func _calculate_scale() -> Vector2:
	if fit_mode == FitMode.NONE:
		return scale
	
	var sprite_size = initial_texture_size
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


func _animate(delta: float):
	if enable_floating:
		var float_offset = sin(time * float_speed) * float_amount
		position.y = initial_position.y + float_offset
	
	if enable_rotation:
		rotation += rotation_speed * delta
