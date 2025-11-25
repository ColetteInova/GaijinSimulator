extends Node

@export var dialogue_start_delay: float = 1.0  ## Delay em segundos antes de iniciar o DialogueWindow

@onready var dialogue_window = $DialogueWindow  # Ajuste o caminho se necessário


func _ready():
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
