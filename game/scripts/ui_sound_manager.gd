extends Node

# Sons da UI
var click_sound = preload("res://assets/audios/menu_pressed_sound.mp3")

# Players de áudio
var click_player: AudioStreamPlayer


func _ready():
	# Cria o player para sons de click
	click_player = AudioStreamPlayer.new()
	click_player.stream = click_sound
	add_child(click_player)


func play_click():
	"""Toca o som de click de botão"""
	if click_player:
		click_player.play()


func play_hover():
	"""Toca o som de hover sobre botão (se houver)"""
	# TODO: Implementar quando houver som de hover
	pass


func play_error():
	"""Toca o som de erro (se houver)"""
	# TODO: Implementar quando houver som de erro
	pass
