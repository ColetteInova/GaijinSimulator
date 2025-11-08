extends Control

@onready var start_game_btn = $SideMenu/MenuContainer/StartGameButton
@onready var load_btn = $SideMenu/MenuContainer/LoadButton
@onready var options_btn = $SideMenu/MenuContainer/OptionsButton
@onready var exit_btn = $SideMenu/MenuContainer/ExitButton


func _ready():
	# Define o idioma baseado nas configurações
	if GameSettings.is_language_set():
		var lang = GameSettings.get_language()
		TranslationServer.set_locale(lang)
	
	# Conecta os sinais dos botões
	start_game_btn.pressed.connect(_on_start_game_pressed)
	load_btn.pressed.connect(_on_load_pressed)
	options_btn.pressed.connect(_on_options_pressed)
	exit_btn.pressed.connect(_on_exit_pressed)
	
	# Verifica se há saves disponíveis
	_update_load_button_state()


func _update_load_button_state():
	var has_saves = false
	for i in range(SaveManager.MAX_SAVE_SLOTS):
		if SaveManager.slot_has_save(i):
			has_saves = true
			break
	
	# Desabilita o botão de carregar se não houver saves
	load_btn.disabled = not has_saves


func _on_start_game_pressed():
	print("Starting new game...")
	# TODO: Implementar início de novo jogo
	await SceneTransition.change_scene_to_file("res://scenes/game/game_scene.tscn", 0.5, 0.8)


func _on_load_pressed():
	print("Opening load game screen...")
	await SceneTransition.change_scene_to_file("res://scenes/menus/save_slot_selector.tscn", 0.3, 0.5)


func _on_options_pressed():
	print("Opening options...")
	# TODO: Implementar tela de opções
	pass


func _on_exit_pressed():
	print("Exiting game...")
	await SceneTransition.fade_in(0.5)
	get_tree().quit()
