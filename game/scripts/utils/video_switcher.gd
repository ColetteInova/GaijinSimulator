extends VideoStreamPlayer

## Lista de vídeos para reproduzir em loop
@export var video_list: Array[VideoStream] = []

## Tempo em segundos para trocar de vídeo
@export var switch_interval: float = 10.0

## Duração do fade in/out em segundos
@export var fade_duration: float = 0.5

## Ativar movimento horizontal do vídeo
@export var enable_movement: bool = true

## Velocidade de movimento horizontal (pixels por segundo)
@export var movement_speed: float = 20.0

## Direção do movimento (-1 = esquerda, 1 = direita, 0 = parado)
@export_enum("Esquerda", "Direita", "Aleatório") var movement_direction: int = 0

## Se deve reproduzir os vídeos em ordem aleatória
@export var random_order: bool = false

## Se deve repetir a lista quando chegar ao final
@export var loop_playlist: bool = true

var current_video_index: int = 0
var time_elapsed: float = 0.0
var active: bool = false
var is_transitioning: bool = false
var fade_progress: float = 0.0
var target_alpha: float = 1.0
var current_direction: int = 1  # 1 = direita, -1 = esquerda
var movement_offset: float = 0.0
var original_position: Vector2 = Vector2.ZERO

enum FadeState {
	NONE,
	FADE_OUT,
	FADE_IN
}

var fade_state: FadeState = FadeState.NONE


func _ready() -> void:
	if video_list.is_empty():
		push_warning("VideoSwitcher: Lista de vídeos está vazia!")
		return
	
	# Configurar para auto-play e loop
	autoplay = false
	
	# Salvar posição original
	original_position = position
	
	# Iniciar invisível para fazer fade in
	modulate.a = 0.0
	
	# Definir direção inicial
	set_movement_direction()
	
	# Iniciar com o primeiro vídeo
	play_current_video()
	active = true
	
	# Começar com fade in
	start_fade_in()


func set_movement_direction() -> void:
	if movement_direction == 2:  # Aleatório
		current_direction = 1 if randf() > 0.5 else -1
	elif movement_direction == 0:  # Esquerda
		current_direction = -1
	else:  # Direita
		current_direction = 1


func _process(delta: float) -> void:
	if not active or video_list.is_empty():
		return
	
	# Processar movimento horizontal
	if enable_movement:
		process_movement(delta)
	
	# Processar fade se estiver em transição
	if fade_state != FadeState.NONE:
		process_fade(delta)
		return
	
	time_elapsed += delta
	
	# Trocar de vídeo quando o tempo passar
	if time_elapsed >= switch_interval:
		start_transition()
		time_elapsed = 0.0


func process_movement(delta: float) -> void:
	# Mover horizontalmente
	movement_offset += movement_speed * current_direction * delta
	position.x = original_position.x + movement_offset


func process_fade(delta: float) -> void:
	fade_progress += delta
	var alpha: float = 0.0
	
	if fade_state == FadeState.FADE_OUT:
		# Fade out: de 1.0 para 0.0
		alpha = 1.0 - (fade_progress / fade_duration)
		alpha = clamp(alpha, 0.0, 1.0)
		modulate.a = alpha
		
		if fade_progress >= fade_duration:
			# Fade out completo, trocar vídeo
			change_to_next_video()
			start_fade_in()
	
	elif fade_state == FadeState.FADE_IN:
		# Fade in: de 0.0 para 1.0
		alpha = fade_progress / fade_duration
		alpha = clamp(alpha, 0.0, 1.0)
		modulate.a = alpha
		
		if fade_progress >= fade_duration:
			# Fade in completo
			fade_state = FadeState.NONE
			is_transitioning = false


func start_transition() -> void:
	if is_transitioning:
		return
	
	is_transitioning = true
	start_fade_out()


func start_fade_out() -> void:
	fade_state = FadeState.FADE_OUT
	fade_progress = 0.0


func start_fade_in() -> void:
	fade_state = FadeState.FADE_IN
	fade_progress = 0.0


func change_to_next_video() -> void:
	if random_order:
		# Não usar random se só tiver 1 vídeo
		if video_list.size() <= 1:
			return
		
		# Escolher um vídeo diferente do atual
		var new_index: int = current_video_index
		while new_index == current_video_index:
			new_index = randi() % video_list.size()
		
		current_video_index = new_index
	else:
		current_video_index += 1
		
		if current_video_index >= video_list.size():
			if loop_playlist:
				current_video_index = 0
			else:
				active = false
				stop()
				return
	
	# Resetar posição e trocar direção
	movement_offset = 0.0
	position = original_position
	set_movement_direction()
	
	play_current_video()


func play_current_video() -> void:
	if video_list.is_empty():
		return
	
	if current_video_index >= video_list.size():
		if loop_playlist:
			current_video_index = 0
		else:
			active = false
			return
	
	stream = video_list[current_video_index]
	play()


func next_video() -> void:
	start_transition()


func previous_video() -> void:
	if is_transitioning:
		return
	
	is_transitioning = true
	fade_state = FadeState.FADE_OUT
	fade_progress = 0.0
	
	# Aguardar fade out antes de trocar
	await get_tree().create_timer(fade_duration).timeout
	
	current_video_index -= 1
	
	if current_video_index < 0:
		if loop_playlist:
			current_video_index = video_list.size() - 1
		else:
			current_video_index = 0
	
	play_current_video()
	start_fade_in()


func pause_playback() -> void:
	active = false
	paused = true


func resume_playback() -> void:
	active = true
	paused = false


func stop_playback() -> void:
	active = false
	stop()
	current_video_index = 0
	time_elapsed = 0.0
