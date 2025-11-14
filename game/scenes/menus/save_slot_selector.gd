extends Control

enum Mode { SAVE, LOAD }

@onready var title_label = $Panel/VBoxContainer/TitleLabel
@onready var slots_container = $Panel/VBoxContainer/SlotsContainer
@onready var back_button = $Panel/VBoxContainer/BackButton

var current_mode: Mode = Mode.LOAD
var slot_buttons = []


func _ready():
	setup_ui()
	refresh_slots()
	back_button.pressed.connect(_on_back_pressed)


func setup_ui():
	# Configura o título baseado no modo
	if current_mode == Mode.SAVE:
		title_label.text = "SAVE_TITLE"
	else:
		title_label.text = "LOAD_TITLE"
	
	# Cria os botões de slot
	create_slot_buttons()


func create_slot_buttons():
	# Limpa botões existentes
	for child in slots_container.get_children():
		child.queue_free()
	
	slot_buttons.clear()
	
	# Cria 4 slots
	for i in range(SaveManager.MAX_SAVE_SLOTS):
		var slot_button = create_slot_button(i)
		slots_container.add_child(slot_button)
		slot_buttons.append(slot_button)


func create_slot_button(slot: int) -> Button:
	var button = Button.new()
	button.custom_minimum_size = Vector2(400, 60)
	button.pressed.connect(_on_slot_pressed.bind(slot))
	
	
	update_slot_button(button, slot)
	
	return button


func update_slot_button(button: Button, slot: int):
	if SaveManager.slot_has_save(slot):
		var info = SaveManager.get_slot_info(slot)
		var date = info.get("date", "Unknown")
		button.text = "SLOT_LABEL".format([slot + 1]) + "\n" + date
	else:
		button.text = "SLOT_EMPTY".format([slot + 1])


func refresh_slots():
	for i in range(slot_buttons.size()):
		update_slot_button(slot_buttons[i], i)


func set_mode(mode: Mode):
	current_mode = mode
	setup_ui()


func _on_slot_pressed(slot: int):
	UISoundManager.play_click()
	if current_mode == Mode.SAVE:
		_save_to_slot(slot)
	else:
		_load_from_slot(slot)


func _save_to_slot(slot: int):
	# Confirma se quer sobrescrever
	if SaveManager.slot_has_save(slot):
		# TODO: Adicionar diálogo de confirmação
		pass
	
	# Cria dados de exemplo para salvar
	var save_data = SaveManager.create_example_save_data()
	
	if SaveManager.save_game(slot, save_data):
		print("Game saved to slot ", slot)
		refresh_slots()
		# TODO: Mostrar mensagem de sucesso
		await get_tree().create_timer(0.5).timeout
		_on_back_pressed()
	else:
		print("Failed to save game")
		# TODO: Mostrar mensagem de erro


func _load_from_slot(slot: int):
	if not SaveManager.slot_has_save(slot):
		print("No save in slot ", slot)
		# TODO: Mostrar mensagem de erro
		return
	
	var save_data = SaveManager.load_game(slot)
	
	if not save_data.is_empty():
		print("Game loaded from slot ", slot)
		# TODO: Carregar a cena do jogo com os dados
		# Por enquanto, só volta ao menu
		await get_tree().create_timer(0.5).timeout
		_on_back_pressed()
	else:
		print("Failed to load game")
		# TODO: Mostrar mensagem de erro


func _on_back_pressed():
	UISoundManager.play_click()
	await SceneTransition.change_scene_to_file("res://scenes/menus/main_menu_screen.tscn", 0.3, 0.5)
