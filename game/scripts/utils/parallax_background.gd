@tool
extends Control

## Background Parallax com nuvens
## Permite definir uma imagem de fundo e múltiplas camadas de nuvens com velocidades diferentes
## Suporta 3 períodos do dia: Manhã (06:01-12:00), Tarde (12:01-18:00), Noite (18:01-06:00)
## Usa DayTimeManager para sincronizar o período do dia

@export_group("Morning (06:01 - 12:00)")
@export var morning_background: Texture2D
@export var morning_cloud_layers: Array[SpriteParallaxLayer] = []

@export_group("Afternoon (12:01 - 18:00)")
@export var afternoon_background: Texture2D
@export var afternoon_cloud_layers: Array[SpriteParallaxLayer] = []
@export_group("Night (18:01 - 06:00)")
@export var night_background: Texture2D
@export var night_cloud_layers: Array[SpriteParallaxLayer] = []

@export_group("Time Settings")
@export var auto_update_time: bool = true  ## Se true, usa DayTimeManager para definir o período
@export_enum("Morning", "Afternoon", "Night") var manual_time: int = 0:  ## Usado quando auto_update_time é false
	set(value):
		manual_time = value
		if not auto_update_time and is_inside_tree():
			_update_for_manual_time()

@export_group("Movement Settings")
@export var move_left: bool = true  ## Se true, todas as camadas movem para esquerda; se false, para direita

@onready var background_sprite: TextureRect = $Background
var cloud_containers: Array[Control] = []


func _ready():
	if not Engine.is_editor_hint():
		if auto_update_time and DayTimeManager:
			# Conecta ao sinal de mudança de período
			DayTimeManager.time_of_day_changed.connect(_on_time_changed)
		_update_current_period()
		_setup_background()
		_setup_clouds()


func _process(delta):
	if not Engine.is_editor_hint():
		_update_clouds(delta)


func _update_for_manual_time():
	"""Atualiza quando o tempo manual é alterado no editor"""
	if not auto_update_time:
		_setup_background()
		_setup_clouds()


func _update_current_period():
	"""Atualiza o período atual baseado nas configurações"""
	# Método simplificado - não precisa armazenar estado local


func _on_time_changed(_new_time):
	"""Callback quando o período do dia muda no DayTimeManager"""
	_setup_background()
	_setup_clouds()


func _get_current_background() -> Texture2D:
	"""Retorna a textura de fundo do período atual"""
	var time_period = _get_time_period()
	
	match time_period:
		0:  # MORNING
			return morning_background
		1:  # AFTERNOON
			return afternoon_background
		2:  # NIGHT
			return night_background
		_:
			return morning_background


func _get_current_cloud_layers() -> Array[SpriteParallaxLayer]:
	"""Retorna as camadas de nuvens do período atual"""
	var time_period = _get_time_period()
	
	match time_period:
		0:  # MORNING
			return morning_cloud_layers
		1:  # AFTERNOON
			return afternoon_cloud_layers
		2:  # NIGHT
			return night_cloud_layers
		_:
			return morning_cloud_layers


func _get_time_period() -> int:
	"""Retorna o período atual (0=Morning, 1=Afternoon, 2=Night)"""
	if auto_update_time and DayTimeManager:
		return int(DayTimeManager.get_time_of_day())
	else:
		return manual_time


func _setup_background():
	"""Configura o sprite de fundo"""
	if background_sprite:
		var current_bg = _get_current_background()
		if current_bg:
			background_sprite.texture = current_bg


func _setup_clouds():
	"""Cria os containers para cada camada de nuvens"""
	# Limpa containers existentes
	for container in cloud_containers:
		if is_instance_valid(container):
			container.queue_free()
	cloud_containers.clear()
	
	# Obtém as camadas do período atual
	var current_layers = _get_current_cloud_layers()
	
	# Cria novos containers para cada camada
	for layer in current_layers:
		if layer and layer.cloud_texture:
			var container = _create_cloud_layer(layer)
			add_child(container)
			cloud_containers.append(container)


func _create_cloud_layer(layer: Resource) -> Control:
	"""Cria um container com nuvens para uma camada específica"""
	var container = Control.new()
	container.name = "CloudLayer_" + str(cloud_containers.size())
	container.anchor_right = 1.0
	container.anchor_bottom = 1.0
	container.mouse_filter = Control.MOUSE_FILTER_IGNORE
	
	# Calcula quantas nuvens são necessárias para cobrir a tela + scroll
	var screen_width = get_viewport_rect().size.x
	var cloud_width = layer.cloud_texture.get_width() * layer.scale
	var cloud_height = layer.cloud_texture.get_height() * layer.scale
	var overlap = 2.0  # Pixels de sobreposição para evitar emendas
	var num_clouds = ceil(screen_width / cloud_width) + 4  # +4 para garantir cobertura sem emendas visíveis
	
	# Cria as nuvens de forma mais eficiente
	for i in range(num_clouds):
		var cloud = TextureRect.new()
		cloud.texture = layer.cloud_texture
		cloud.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_COVERED
		cloud.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
		# Usa custom_minimum_size para garantir tamanho exato
		cloud.custom_minimum_size = Vector2(cloud_width, cloud_height)
		cloud.size = Vector2(cloud_width, cloud_height)
		# Posiciona com overlap para evitar vãos entre sprites
		cloud.position = Vector2(i * cloud_width - (i * overlap), layer.y_position)
		cloud.modulate = layer.tint
		cloud.mouse_filter = Control.MOUSE_FILTER_IGNORE
		# Filtro linear para movimento mais suave e sem emendas
		cloud.texture_filter = CanvasItem.TEXTURE_FILTER_LINEAR_WITH_MIPMAPS
		container.add_child(cloud)
	
	container.set_meta("speed", layer.speed)
	container.set_meta("cloud_width", cloud_width)
	container.set_meta("overlap", overlap)
	container.set_meta("num_clouds", num_clouds)
	container.set_meta("move_left", move_left)
	
	return container


func _update_clouds(delta):
	"""Atualiza a posição das nuvens para criar efeito parallax"""
	for container in cloud_containers:
		if not is_instance_valid(container):
			continue
			
		var speed = container.get_meta("speed", 0.0)
		var cloud_width = container.get_meta("cloud_width", 0.0)
		var overlap = container.get_meta("overlap", 0.0)
		var num_clouds = container.get_meta("num_clouds", 0)
		var move_left = container.get_meta("move_left", true)
		
		if cloud_width == 0 or num_clouds == 0:
			continue
		
		# Move todas as nuvens no container de forma otimizada
		var movement = speed * delta
		var effective_width = cloud_width - overlap  # Largura efetiva considerando overlap
		
		for cloud in container.get_children():
			if cloud is TextureRect:
				# Move a nuvem na direção configurada
				if move_left:
					cloud.position.x -= movement
					# Reposiciona quando passa completamente da tela (loop sem emendas)
					if cloud.position.x <= -cloud_width:
						# Encontra a nuvem mais à direita
						var rightmost_x = -999999.0
						for other_cloud in container.get_children():
							if other_cloud is TextureRect and other_cloud != cloud:
								rightmost_x = max(rightmost_x, other_cloud.position.x)
						# Posiciona com overlap para evitar vãos
						cloud.position.x = rightmost_x + effective_width
				else:
					cloud.position.x += movement
					# Reposiciona quando passa completamente da tela (loop sem emendas)
					var screen_width = get_viewport_rect().size.x
					if cloud.position.x >= screen_width:
						# Encontra a nuvem mais à esquerda
						var leftmost_x = 999999.0
						for other_cloud in container.get_children():
							if other_cloud is TextureRect and other_cloud != cloud:
								leftmost_x = min(leftmost_x, other_cloud.position.x)
						# Posiciona com overlap para evitar vãos
						cloud.position.x = leftmost_x - effective_width


func refresh():
	"""Recarrega as nuvens (útil para mudanças no editor)"""
	if is_inside_tree():
		_setup_background()
		_setup_clouds()
