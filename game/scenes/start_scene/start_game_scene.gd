extends Node

@export var dialogue_start_delay: float = 1.0  ## Delay em segundos antes de iniciar o DialogueWindow
@export var background_music: String = ""  ## Caminho para a música de fundo desta cena
@export var music_fade_duration: float = 1.5  ## Duração do fade da música
@export var music_volume_db: float = -10.0  ## Volume da música em dB

@onready var dialogue_window = $DialogueWindow  # Ajuste o caminho se necessário


func _ready():
	# Toca a música de fundo se configurada
	if background_music != "":
		MusicManager.play_music(background_music, music_fade_duration, music_volume_db)
	if dialogue_window:
		# Conecta o sinal para detectar quando a conversa termina
		dialogue_window.all_dialogues_completed.connect(_on_dialogue_completed)
		
		# Aguarda o delay configurado antes de iniciar
		await get_tree().create_timer(dialogue_start_delay).timeout
		
		# Inicia os diálogos
		if dialogue_window.dialogue_lines.size() > 0:
			dialogue_window.visible = true
			dialogue_window._start_dialogue_line(dialogue_window.dialogue_lines[0])


func _on_dialogue_completed():
	print("Conversa completa! Teste funcionando.")
	# Aqui você pode adicionar lógica para ir para próxima cena, etc.
