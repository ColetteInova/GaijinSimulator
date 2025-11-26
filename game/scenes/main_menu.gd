extends Control

@onready var start_game_btn = $MarginContainer/HBoxContainer/VBoxContainer/MenuContainer/StartGameButton
@onready var load_btn = $MarginContainer/HBoxContainer/VBoxContainer/MenuContainer/LoadButton
@onready var options_btn = $MarginContainer/HBoxContainer/VBoxContainer/MenuContainer/OptionsButton
@onready var exit_btn = $MarginContainer/HBoxContainer/VBoxContainer/MenuContainer/ExitButton
@onready var game_logo = $MarginContainer/HBoxContainer/VBoxContainer/GameLogo

var options_scene = preload("res://scenes/menus/options_menu.tscn")


func _ready():
	# Define o idioma baseado nas configurações
	if GameSettings.is_language_set():
		var lang = GameSettings.get_language()
		TranslationServer.set_locale(lang)
	
	# Inicia a música do menu principal
	MusicManager.play_music("res://assets/audios/menus/main_menu_music.mp3", 1.5, 0.0)
	
	# Conecta os sinais dos botões
	start_game_btn.pressed.connect(_on_start_game_pressed)
	load_btn.pressed.connect(_on_load_pressed)
	options_btn.pressed.connect(_on_options_pressed)
	exit_btn.pressed.connect(_on_exit_pressed)
	
	# Verifica se há saves disponíveis
	_update_load_button_state()
	
	# Inicia as animações de entrada
	_play_entrance_animations()


func _update_load_button_state():
	var has_saves = false
	for i in range(SaveManager.MAX_SAVE_SLOTS):
		if SaveManager.slot_has_save(i):
			has_saves = true
			break
	
	# Desabilita o botão de carregar se não houver saves
	load_btn.disabled = not has_saves


func _on_start_game_pressed():
	UISoundManager.play_click()
	print("Starting new game...")
	
	# Inicia a transição de música antes da cena
	MusicManager.play_music("res://assets/audios/menus/main_menu_music.mp3", 1.5, -10.0)  # Música diferente quando implementada
	
	await SceneTransition.change_scene_to_file("res://scenes/start_scene/start_game_scene.tscn", 0.5, 0.8)


func _on_load_pressed():
	UISoundManager.play_click()
	print("Opening load game screen...")
	await SceneTransition.change_scene_to_file("res://scenes/menus/save_slot_selector.tscn", 0.3, 0.5)


func _on_options_pressed():
	UISoundManager.play_click()
	print("Opening options...")
	# Instancia a tela de opções como overlay
	var options_instance = options_scene.instantiate()
	add_child(options_instance)
	options_instance.tree_exited.connect(_on_options_closed)


func _on_exit_pressed():
	UISoundManager.play_click()
	print("Exiting game...")
	await SceneTransition.fade_in(0.5)
	get_tree().quit()


func _play_entrance_animations():
	# Estado inicial - elementos invisíveis e fora de posição
	game_logo.modulate.a = 0
	game_logo.scale = Vector2(0.5, 0.5)
	
	start_game_btn.modulate.a = 0
	start_game_btn.position.x = -50
	
	load_btn.modulate.a = 0
	load_btn.position.x = -50
	
	options_btn.modulate.a = 0
	options_btn.position.x = -50
	
	exit_btn.modulate.a = 0
	exit_btn.position.x = -50
	
	# Animação de entrada do logo
	var logo_tween = create_tween()
	logo_tween.set_parallel(true)
	logo_tween.tween_property(game_logo, "modulate:a", 1.0, 0.8)\
		.set_ease(Tween.EASE_OUT)\
		.set_trans(Tween.TRANS_CUBIC)
	logo_tween.tween_property(game_logo, "scale", Vector2(1.0, 1.0), 0.8)\
		.set_ease(Tween.EASE_OUT)\
		.set_trans(Tween.TRANS_BACK)
	
	# Aguarda a animação do logo terminar
	await logo_tween.finished
	
	# Animação de entrada dos botões (em sequência)
	var buttons_tween = create_tween()
	
	# Start Game Button
	buttons_tween.tween_property(start_game_btn, "modulate:a", 1.0, 0.4)\
		.set_ease(Tween.EASE_OUT)
	buttons_tween.parallel().tween_property(start_game_btn, "position:x", 0, 0.4)\
		.set_ease(Tween.EASE_OUT)\
		.set_trans(Tween.TRANS_CUBIC)
	
	# Load Button
	buttons_tween.tween_property(load_btn, "modulate:a", 1.0, 0.4)\
		.set_ease(Tween.EASE_OUT)
	buttons_tween.parallel().tween_property(load_btn, "position:x", 0, 0.4)\
		.set_ease(Tween.EASE_OUT)\
		.set_trans(Tween.TRANS_CUBIC)
	
	# Options Button
	buttons_tween.tween_property(options_btn, "modulate:a", 1.0, 0.4)\
		.set_ease(Tween.EASE_OUT)
	buttons_tween.parallel().tween_property(options_btn, "position:x", 0, 0.4)\
		.set_ease(Tween.EASE_OUT)\
		.set_trans(Tween.TRANS_CUBIC)
	
	# Exit Button
	buttons_tween.tween_property(exit_btn, "modulate:a", 1.0, 0.4)\
		.set_ease(Tween.EASE_OUT)
	buttons_tween.parallel().tween_property(exit_btn, "position:x", 0, 0.4)\
		.set_ease(Tween.EASE_OUT)\
		.set_trans(Tween.TRANS_CUBIC)
	
	# Aguarda os botões terminarem e inicia loop do logo
	await buttons_tween.finished
	_animate_logo_loop()


func _animate_logo_loop():
	# Animação sutil em loop apenas para o logo
	var tween = create_tween()
	tween.set_loops()
	tween.set_parallel(true)
	
	# Flutuação vertical muito sutil
	tween.tween_property(game_logo, "position:y", game_logo.position.y - 8, 2.5)\
		.set_ease(Tween.EASE_IN_OUT)\
		.set_trans(Tween.TRANS_SINE)
	tween.tween_property(game_logo, "position:y", game_logo.position.y + 8, 2.5)\
		.set_ease(Tween.EASE_IN_OUT)\
		.set_trans(Tween.TRANS_SINE)\
		.set_delay(2.5)
	
	# Efeito de brilho sutil
	tween.tween_property(game_logo, "modulate:a", 0.85, 3.0)\
		.set_ease(Tween.EASE_IN_OUT)\
		.set_trans(Tween.TRANS_SINE)
	tween.tween_property(game_logo, "modulate:a", 1.0, 3.0)\
		.set_ease(Tween.EASE_IN_OUT)\
		.set_trans(Tween.TRANS_SINE)\
		.set_delay(3.0)


func _animate_logo():
	# Função antiga - mantida para compatibilidade mas não utilizada
	pass


func _on_options_closed():
	# Chamado quando a tela de opções é fechada
	print("Options closed, resuming main menu")
