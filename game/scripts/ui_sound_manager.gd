extends Node

# Sons da UI
var click_sound = preload("res://assets/audios/sxfs/buttons/menu_pressed_sound.mp3")

# Players de áudio
var click_player: AudioStreamPlayer


func _ready():
	# Cria o player para sons de click
	click_player = AudioStreamPlayer.new()
	click_player.stream = click_sound
	click_player.bus = "SFX"
	add_child(click_player)


func play_click(delay: float = 0.0):
	"""Toca o som de click de botão
	
	Args:
		delay: Tempo em segundos antes de tocar o som (padrão: 0.0)
	"""
	if click_player:
		if delay > 0.0:
			await get_tree().create_timer(delay).timeout
		click_player.play()


func play_hover(_delay: float = 0.0):
	"""Toca o som de hover sobre botão (se houver)
	
	Args:
		_delay: Tempo em segundos antes de tocar o som (padrão: 0.0)
	"""
	# TODO: Implementar quando houver som de hover
	pass


func play_error(_delay: float = 0.0):
	"""Toca o som de erro (se houver)
	
	Args:
		_delay: Tempo em segundos antes de tocar o som (padrão: 0.0)
	"""
	# TODO: Implementar quando houver som de erro
	pass
