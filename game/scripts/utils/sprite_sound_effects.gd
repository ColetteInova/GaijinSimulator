extends Node
class_name SpriteSoundEffects

## Sistema de efeitos sonoros para sprites animados
## Adicione este script como filho de qualquer sprite para ter controle de sons

# Sinais para notificar quando sons são tocados
signal sound_started(sound_name: String)
signal sound_finished(sound_name: String)

## Configurações de Sons
@export_group("Sound Effects")
@export var spawn_sound: AudioStream  ## Som ao aparecer na tela
@export var movement_sound: AudioStream  ## Som durante movimento
@export var idle_sound: AudioStream  ## Som quando parado/flutuando
@export var disappear_sound: AudioStream  ## Som ao desaparecer

@export_group("Sound Settings")
@export var spawn_sound_volume: float = 0.0  ## Volume do som de spawn (dB)
@export var movement_sound_volume: float = 0.0  ## Volume do som de movimento (dB)
@export var idle_sound_volume: float = -10.0  ## Volume do som idle (dB)
@export var disappear_sound_volume: float = 0.0  ## Volume do som de desaparecer (dB)

@export_group("Delay Settings")
@export var spawn_delay: float = 0.0  ## Delay antes de tocar spawn (segundos)
@export var movement_delay: float = 0.0  ## Delay antes de tocar movimento (segundos)
@export var idle_delay: float = 0.0  ## Delay antes de tocar idle (segundos)
@export var disappear_delay: float = 0.0  ## Delay antes de tocar disappear (segundos)

@export_group("Speed Settings")
@export_range(0.1, 4.0, 0.01) var spawn_pitch: float = 1.0  ## Velocidade do som de spawn (1.0 = normal)
@export_range(0.1, 4.0, 0.01) var movement_pitch: float = 1.0  ## Velocidade do som de movimento (1.0 = normal)
@export_range(0.1, 4.0, 0.01) var idle_pitch: float = 1.0  ## Velocidade do som idle (1.0 = normal)
@export_range(0.1, 4.0, 0.01) var disappear_pitch: float = 1.0  ## Velocidade do som de disappear (1.0 = normal)

@export_group("Playback Options")
@export var auto_play_spawn: bool = true  ## Toca automaticamente ao aparecer
@export var loop_idle_sound: bool = true  ## Loop no som idle
@export var loop_movement_sound: bool = false  ## Loop no som de movimento
@export_enum("Master", "SFX", "Music", "UI", "Ambient") var sound_bus: String = "SFX"  ## Bus de áudio a usar

# Audio players internos
var spawn_player: AudioStreamPlayer
var movement_player: AudioStreamPlayer
var idle_player: AudioStreamPlayer
var disappear_player: AudioStreamPlayer

# Estado interno
var is_playing_movement: bool = false
var is_playing_idle: bool = false


func _ready():
	_setup_audio_players()
	
	if auto_play_spawn:
		play_spawn_sound(spawn_delay)


func _setup_audio_players():
	"""Configura os audio players"""
	# Spawn sound player
	spawn_player = AudioStreamPlayer.new()
	spawn_player.name = "SpawnSoundPlayer"
	spawn_player.bus = sound_bus
	spawn_player.volume_db = spawn_sound_volume
	spawn_player.pitch_scale = spawn_pitch
	add_child(spawn_player)
	spawn_player.finished.connect(_on_spawn_sound_finished)
	
	# Movement sound player
	movement_player = AudioStreamPlayer.new()
	movement_player.name = "MovementSoundPlayer"
	movement_player.bus = sound_bus
	movement_player.volume_db = movement_sound_volume
	movement_player.pitch_scale = movement_pitch
	add_child(movement_player)
	movement_player.finished.connect(_on_movement_sound_finished)
	
	# Idle sound player
	idle_player = AudioStreamPlayer.new()
	idle_player.name = "IdleSoundPlayer"
	idle_player.bus = sound_bus
	idle_player.volume_db = idle_sound_volume
	idle_player.pitch_scale = idle_pitch
	add_child(idle_player)
	idle_player.finished.connect(_on_idle_sound_finished)
	
	# Disappear sound player
	disappear_player = AudioStreamPlayer.new()
	disappear_player.name = "DisappearSoundPlayer"
	disappear_player.bus = sound_bus
	disappear_player.volume_db = disappear_sound_volume
	disappear_player.pitch_scale = disappear_pitch
	add_child(disappear_player)
	disappear_player.finished.connect(_on_disappear_sound_finished)


# ============================================================================
# Métodos públicos para tocar sons
# ============================================================================

func play_spawn_sound(delay: float = 0.0):
	"""Toca o som de spawn/aparecimento
	
	Args:
		delay: Tempo em segundos antes de tocar o som (padrão: 0.0)
	"""
	if spawn_sound and spawn_player:
		if delay > 0.0:
			await get_tree().create_timer(delay).timeout
		spawn_player.stream = spawn_sound
		spawn_player.play()
		sound_started.emit("spawn")


func play_movement_sound(delay: float = 0.0):
	"""Toca o som de movimento
	
	Args:
		delay: Tempo em segundos antes de tocar o som (padrão: 0.0)
	"""
	if movement_sound and movement_player and not is_playing_movement:
		if delay > 0.0:
			await get_tree().create_timer(delay).timeout
		movement_player.stream = movement_sound
		if loop_movement_sound:
			# Cria um AudioStreamRandomPitch ou similar se quiser variação
			pass
		movement_player.play()
		is_playing_movement = true
		sound_started.emit("movement")


func stop_movement_sound():
	"""Para o som de movimento"""
	if movement_player and is_playing_movement:
		movement_player.stop()
		is_playing_movement = false


func play_idle_sound(delay: float = 0.0):
	"""Toca o som idle/flutuação
	
	Args:
		delay: Tempo em segundos antes de tocar o som (padrão: 0.0)
	"""
	if idle_sound and idle_player and not is_playing_idle:
		if delay > 0.0:
			await get_tree().create_timer(delay).timeout
		idle_player.stream = idle_sound
		idle_player.play()
		is_playing_idle = true
		sound_started.emit("idle")


func stop_idle_sound():
	"""Para o som idle"""
	if idle_player and is_playing_idle:
		idle_player.stop()
		is_playing_idle = false


func play_disappear_sound(delay: float = 0.0):
	"""Toca o som de desaparecimento
	
	Args:
		delay: Tempo em segundos antes de tocar o som (padrão: 0.0)
	"""
	if disappear_sound and disappear_player:
		if delay > 0.0:
			await get_tree().create_timer(delay).timeout
		disappear_player.stream = disappear_sound
		disappear_player.play()
		sound_started.emit("disappear")


func stop_all_sounds():
	"""Para todos os sons"""
	if spawn_player:
		spawn_player.stop()
	if movement_player:
		movement_player.stop()
	if idle_player:
		idle_player.stop()
	if disappear_player:
		disappear_player.stop()
	
	is_playing_movement = false
	is_playing_idle = false


# ============================================================================
# Métodos auxiliares para controle de volume
# ============================================================================

func set_spawn_volume(volume_db: float):
	"""Define o volume do som de spawn"""
	spawn_sound_volume = volume_db
	if spawn_player:
		spawn_player.volume_db = volume_db


func set_movement_volume(volume_db: float):
	"""Define o volume do som de movimento"""
	movement_sound_volume = volume_db
	if movement_player:
		movement_player.volume_db = volume_db


func set_idle_volume(volume_db: float):
	"""Define o volume do som idle"""
	idle_sound_volume = volume_db
	if idle_player:
		idle_player.volume_db = volume_db


func set_disappear_volume(volume_db: float):
	"""Define o volume do som de desaparecimento"""
	disappear_sound_volume = volume_db
	if disappear_player:
		disappear_player.volume_db = volume_db


func set_master_volume(volume_db: float):
	"""Define o volume de todos os sons"""
	set_spawn_volume(volume_db)
	set_movement_volume(volume_db)
	set_idle_volume(volume_db)
	set_disappear_volume(volume_db)


# ============================================================================
# Métodos auxiliares para controle de velocidade (pitch)
# ============================================================================

func set_spawn_pitch(pitch: float):
	"""Define a velocidade do som de spawn"""
	spawn_pitch = pitch
	if spawn_player:
		spawn_player.pitch_scale = pitch


func set_movement_pitch(pitch: float):
	"""Define a velocidade do som de movimento"""
	movement_pitch = pitch
	if movement_player:
		movement_player.pitch_scale = pitch


func set_idle_pitch(pitch: float):
	"""Define a velocidade do som idle"""
	idle_pitch = pitch
	if idle_player:
		idle_player.pitch_scale = pitch


func set_disappear_pitch(pitch: float):
	"""Define a velocidade do som de desaparecimento"""
	disappear_pitch = pitch
	if disappear_player:
		disappear_player.pitch_scale = pitch


func set_master_pitch(pitch: float):
	"""Define a velocidade de todos os sons"""
	set_spawn_pitch(pitch)
	set_movement_pitch(pitch)
	set_idle_pitch(pitch)
	set_disappear_pitch(pitch)


# ============================================================================
# Callbacks de finalização de sons
# ============================================================================

func _on_spawn_sound_finished():
	sound_finished.emit("spawn")


func _on_movement_sound_finished():
	is_playing_movement = false
	sound_finished.emit("movement")
	
	# Se está em loop, toca novamente
	if loop_movement_sound and movement_sound:
		play_movement_sound()


func _on_idle_sound_finished():
	is_playing_idle = false
	sound_finished.emit("idle")
	
	# Se está em loop, toca novamente
	if loop_idle_sound and idle_sound:
		play_idle_sound()


func _on_disappear_sound_finished():
	sound_finished.emit("disappear")


# ============================================================================
# Métodos de conveniência
# ============================================================================

func is_any_sound_playing() -> bool:
	"""Verifica se algum som está tocando"""
	return (spawn_player and spawn_player.playing) or \
		   (movement_player and movement_player.playing) or \
		   (idle_player and idle_player.playing) or \
		   (disappear_player and disappear_player.playing)


func get_current_playing_sounds() -> Array[String]:
	"""Retorna lista de sons que estão tocando atualmente"""
	var playing: Array[String] = []
	
	if spawn_player and spawn_player.playing:
		playing.append("spawn")
	if movement_player and movement_player.playing:
		playing.append("movement")
	if idle_player and idle_player.playing:
		playing.append("idle")
	if disappear_player and disappear_player.playing:
		playing.append("disappear")
	
	return playing
