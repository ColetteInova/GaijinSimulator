extends Control

## Script principal da cena StartGameIntoAirbus
## Conecta o PassportRegistration com o Player para preview em tempo real

@onready var passport_registration: PassportRegistration = $MarginContainer/Panel/HBoxContainer/PassportRegistration
@onready var player: CharacterBody2D = $MarginContainer/Panel/HBoxContainer/VBoxContainer/Player


func _ready():
	# Conecta o sinal de mudança de aparência do formulário
	if passport_registration:
		passport_registration.appearance_changed.connect(_on_appearance_changed)
		passport_registration.registration_completed.connect(_on_registration_completed)


func _on_appearance_changed(appearance: PlayerAppearance):
	"""Atualiza o preview do player quando a aparência muda"""
	if player and appearance:
		player.appearance = appearance.duplicate(true)
		player.apply_appearance()


func _on_registration_completed(data: Dictionary):
	"""Quando o registro é completado, salva e continua o jogo"""
	print("Registration completed: ", data)
	
	# Os dados já foram salvos no PlayerData pelo PassportRegistration
	# Aqui você pode adicionar lógica adicional como:
	# - Transição para a próxima cena
	# - Salvar dados adicionais
	# - Iniciar diálogos
	
	# Exemplo: Salvar dados extras no PlayerData
	if PlayerData:
		PlayerData.character_data["gender"] = data["gender"]
		PlayerData.character_data["orientation"] = data["orientation_key"]
		PlayerData.character_data["country"] = data["country_key"]
		PlayerData.save_data()
	
	# TODO: Adicionar transição para próxima cena
	# get_tree().change_scene_to_file("res://scenes/next_scene.tscn")
