extends Control

signal language_selected(language: String)

@onready var title_label = $VBoxContainer/TitleLabel
@onready var language_container = $VBoxContainer/LanguageContainer

var languages = {
	"en": "English",
	"br": "Português (Brasil)",
	"es": "Español",
	"fr": "Français",
	"de": "Deutsch",
	"ja": "日本語",
	"zh": "中文"
}


func _ready():
	setup_language_buttons()
	
	# Verifica se o idioma já foi definido
	if GameSettings.is_language_set():
		# Se já tiver idioma definido, esconde esta cena
		queue_free()
	else:
		# Mostra a cena de seleção
		show()


func setup_language_buttons():
	# Remove botões existentes se houver
	for child in language_container.get_children():
		child.queue_free()
	
	# Carrega a fonte PressStart2P
	var font = preload("res://assets/fonts/pixel.ttf")
	
	# Cria um botão para cada idioma
	for lang_code in languages.keys():
		var button = Button.new()
		button.text = languages[lang_code]
		button.custom_minimum_size = Vector2(300, 50)
		button.pressed.connect(_on_language_button_pressed.bind(lang_code))
		
		# Estiliza o botão com a fonte PressStart2P
		button.add_theme_font_override("font", font)
		button.add_theme_font_size_override("font_size", 14)
		
		language_container.add_child(button)


func _on_language_button_pressed(lang_code: String):
	# Desabilita todos os botões para evitar cliques múltiplos
	for button in language_container.get_children():
		if button is Button:
			button.disabled = true
	
	# Salva o idioma selecionado
	GameSettings.set_language(lang_code)
	GameSettings.save_settings()
	
	# Emite o sinal
	language_selected.emit(lang_code)
	
	# Fecha a cena de seleção com transição
	print("Idioma selecionado: ", languages[lang_code])
	await SceneTransition.change_scene_to_file("res://scenes/menus/main_menu.tscn", 0.5, 0.8)
