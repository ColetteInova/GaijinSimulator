extends Control

@onready var back_btn = $MarginContainer/VBoxContainer/BackButton
@onready var master_volume_slider = $MarginContainer/VBoxContainer/ScrollContainer/OptionsContainer/AudioSection/MasterVolumeSlider
@onready var music_volume_slider = $MarginContainer/VBoxContainer/ScrollContainer/OptionsContainer/AudioSection/MusicVolumeSlider
@onready var sfx_volume_slider = $MarginContainer/VBoxContainer/ScrollContainer/OptionsContainer/AudioSection/SFXVolumeSlider
@onready var fullscreen_check = $MarginContainer/VBoxContainer/ScrollContainer/OptionsContainer/VideoSection/FullscreenCheck
@onready var vsync_check = $MarginContainer/VBoxContainer/ScrollContainer/OptionsContainer/VideoSection/VsyncCheck
@onready var language_option = $MarginContainer/VBoxContainer/ScrollContainer/OptionsContainer/GameSection/LanguageOption


func _ready():
	# Conecta os sinais
	back_btn.pressed.connect(_on_back_pressed)
	master_volume_slider.value_changed.connect(_on_master_volume_changed)
	music_volume_slider.value_changed.connect(_on_music_volume_changed)
	sfx_volume_slider.value_changed.connect(_on_sfx_volume_changed)
	fullscreen_check.toggled.connect(_on_fullscreen_toggled)
	vsync_check.toggled.connect(_on_vsync_toggled)
	language_option.item_selected.connect(_on_language_selected)
	
	# Carrega as configurações salvas
	_load_settings()
	
	# Configura opções de idioma
	_setup_language_options()


func _load_settings():
	# Áudio
	master_volume_slider.value = GameSettings.get_master_volume()
	music_volume_slider.value = GameSettings.get_music_volume()
	sfx_volume_slider.value = GameSettings.get_sfx_volume()
	
	# Vídeo
	fullscreen_check.button_pressed = GameSettings.get_fullscreen()
	vsync_check.button_pressed = GameSettings.get_vsync()


func _setup_language_options():
	language_option.clear()
	language_option.add_item("English", 0)
	language_option.add_item("Português (BR)", 1)
	language_option.add_item("Español", 2)
	language_option.add_item("日本語", 3)
	
	# Seleciona o idioma atual
	var current_lang = GameSettings.get_language()
	match current_lang:
		"en":
			language_option.selected = 0
		"pt_BR":
			language_option.selected = 1
		"es":
			language_option.selected = 2
		"ja":
			language_option.selected = 3


func _on_master_volume_changed(value: float):
	GameSettings.set_master_volume(value)


func _on_music_volume_changed(value: float):
	GameSettings.set_music_volume(value)


func _on_sfx_volume_changed(value: float):
	GameSettings.set_sfx_volume(value)


func _on_fullscreen_toggled(toggled_on: bool):
	GameSettings.set_fullscreen(toggled_on)
	if toggled_on:
		DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_FULLSCREEN)
	else:
		DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_WINDOWED)


func _on_vsync_toggled(toggled_on: bool):
	GameSettings.set_vsync(toggled_on)
	if toggled_on:
		DisplayServer.window_set_vsync_mode(DisplayServer.VSYNC_ENABLED)
	else:
		DisplayServer.window_set_vsync_mode(DisplayServer.VSYNC_DISABLED)


func _on_language_selected(index: int):
	var lang_code = ""
	match index:
		0:
			lang_code = "en"
		1:
			lang_code = "pt_BR"
		2:
			lang_code = "es"
		3:
			lang_code = "ja"
	
	GameSettings.set_language(lang_code)
	TranslationServer.set_locale(lang_code)


func _on_back_pressed():
	UISoundManager.play_click()
	print("Returning to main menu...")
	queue_free()  # Remove a tela de opções, voltando ao menu principal
