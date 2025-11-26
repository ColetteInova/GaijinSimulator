extends Node
## Gerenciador global de música com transições suaves entre cenas
##
## Este script deve ser adicionado como AutoLoad no projeto
## Permite fade in/out e transição suave entre diferentes músicas

# Players de áudio para fazer crossfade
var audio_player_1: AudioStreamPlayer
var audio_player_2: AudioStreamPlayer

# Controle de qual player está ativo
var current_player: AudioStreamPlayer
var next_player: AudioStreamPlayer

# Configurações padrão
var default_fade_duration: float = 1.0
var default_volume_db: float = 0.0

# Estado atual
var is_transitioning: bool = false
var current_music_path: String = ""


func _ready():
	# Cria os dois players de áudio
	audio_player_1 = AudioStreamPlayer.new()
	audio_player_1.bus = "Music"
	audio_player_1.volume_db = -80.0  # Começa silenciado
	add_child(audio_player_1)
	
	audio_player_2 = AudioStreamPlayer.new()
	audio_player_2.bus = "Music"
	audio_player_2.volume_db = -80.0  # Começa silenciado
	add_child(audio_player_2)
	
	# Define o player atual
	current_player = audio_player_1
	next_player = audio_player_2


## Toca uma música com fade in
func play_music(music_path: String, fade_duration: float = -1.0, volume_db: float = -1.0):
	if fade_duration < 0:
		fade_duration = default_fade_duration
	if volume_db <= -80:
		volume_db = default_volume_db
	
	# Se já está tocando a mesma música, não faz nada
	if current_music_path == music_path and current_player.playing:
		return
	
	# Carrega a música
	var music = load(music_path) as AudioStream
	if not music:
		push_error("MusicManager: Não foi possível carregar a música: " + music_path)
		return
	
	# Para qualquer transição em andamento
	if is_transitioning:
		# Completa a transição anterior imediatamente
		_complete_transition()
	
	# Se há música tocando, faz crossfade
	if current_player.playing:
		await _crossfade_to(music, fade_duration, volume_db)
	else:
		# Primeira música, apenas fade in
		current_player.stream = music
		current_player.play()
		await _fade_in(current_player, fade_duration, volume_db)
	
	current_music_path = music_path


## Faz crossfade entre a música atual e uma nova
func _crossfade_to(new_music: AudioStream, duration: float, target_volume: float):
	is_transitioning = true
	
	# Configura o próximo player
	next_player.stream = new_music
	next_player.volume_db = -80.0
	next_player.play()
	
	# Cria tweens para fade out e fade in simultâneos
	var tween = create_tween()
	tween.set_parallel(true)
	
	# Fade out do player atual
	tween.tween_property(current_player, "volume_db", -80.0, duration)\
		.set_ease(Tween.EASE_IN_OUT)\
		.set_trans(Tween.TRANS_CUBIC)
	
	# Fade in do próximo player
	tween.tween_property(next_player, "volume_db", target_volume, duration)\
		.set_ease(Tween.EASE_IN_OUT)\
		.set_trans(Tween.TRANS_CUBIC)
	
	await tween.finished
	
	# Para o player anterior
	current_player.stop()
	
	# Troca os players
	var temp = current_player
	current_player = next_player
	next_player = temp
	
	is_transitioning = false


## Faz fade in em um player
func _fade_in(player: AudioStreamPlayer, duration: float, target_volume: float):
	is_transitioning = true
	
	player.volume_db = -80.0
	
	var tween = create_tween()
	tween.tween_property(player, "volume_db", target_volume, duration)\
		.set_ease(Tween.EASE_OUT)\
		.set_trans(Tween.TRANS_CUBIC)
	
	await tween.finished
	is_transitioning = false


## Para a música com fade out
func stop_music(fade_duration: float = -1.0):
	if fade_duration < 0:
		fade_duration = default_fade_duration
	
	if not current_player.playing:
		return
	
	is_transitioning = true
	
	var tween = create_tween()
	tween.tween_property(current_player, "volume_db", -80.0, fade_duration)\
		.set_ease(Tween.EASE_IN)\
		.set_trans(Tween.TRANS_CUBIC)
	
	await tween.finished
	
	current_player.stop()
	current_music_path = ""
	is_transitioning = false


## Pausa a música com fade out
func pause_music(fade_duration: float = -1.0):
	if fade_duration < 0:
		fade_duration = default_fade_duration
	
	if not current_player.playing:
		return
	
	var tween = create_tween()
	tween.tween_property(current_player, "volume_db", -80.0, fade_duration)\
		.set_ease(Tween.EASE_IN)\
		.set_trans(Tween.TRANS_CUBIC)
	
	await tween.finished
	
	current_player.stream_paused = true


## Resume a música com fade in
func resume_music(fade_duration: float = -1.0, volume_db: float = -1.0):
	if fade_duration < 0:
		fade_duration = default_fade_duration
	if volume_db <= -80:
		volume_db = default_volume_db
	
	if not current_player.stream_paused:
		return
	
	current_player.stream_paused = false
	
	await _fade_in(current_player, fade_duration, volume_db)


## Define o volume da música atual
func set_volume(volume_db: float, duration: float = 0.0):
	if not current_player.playing:
		return
	
	if duration <= 0:
		current_player.volume_db = volume_db
	else:
		var tween = create_tween()
		tween.tween_property(current_player, "volume_db", volume_db, duration)\
			.set_ease(Tween.EASE_IN_OUT)\
			.set_trans(Tween.TRANS_CUBIC)


## Completa qualquer transição em andamento imediatamente
func _complete_transition():
	# Remove todos os tweens ativos
	for tween in get_tree().get_nodes_in_group("tweens"):
		if tween.is_valid():
			tween.kill()
	
	is_transitioning = false


## Retorna se há música tocando
func is_playing() -> bool:
	return current_player.playing


## Retorna o caminho da música atual
func get_current_music() -> String:
	return current_music_path
