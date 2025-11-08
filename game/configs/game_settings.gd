extends Node

var difficulty_level := "Normal"
var sound_volume := 0.8
var graphics_quality := "High"
var control_scheme := "Keyboard"
var language := "br"
var subtitles_enabled := true
var auto_save_enabled := true
var tutorial_enabled := true
var max_framerate := 60
var fullscreen_enabled := true
var mouse_sensitivity := 1.0
var vibration_enabled := false
var hud_opacity := 1.0
var chat_enabled := true
var crosshair_style := "Default"
var key_bindings := {
	"move_forward": "W",
	"move_backward": "S",
	"move_left": "A",
	"move_right": "D"
}


func _ready():
	SimpleSettings.config_files.set("game", {"path": "user://game.ini"})
	SimpleSettings.load()
	load_settings()
	print_settings()

func load_settings():
	difficulty_level = get_difficulty_level()
	sound_volume = get_sound_volume()
	graphics_quality = get_graphics_quality()
	control_scheme = get_control_scheme()
	language = get_language()
	subtitles_enabled = get_subtitles_enabled()
	auto_save_enabled = get_auto_save_enabled()
	tutorial_enabled = get_tutorial_enabled()
	max_framerate = get_max_framerate()
	fullscreen_enabled = get_fullscreen_enabled()
	mouse_sensitivity = get_mouse_sensitivity()
	vibration_enabled = get_vibration_enabled()
	hud_opacity = get_hud_opacity()
	chat_enabled = get_chat_enabled()
	crosshair_style = get_crosshair_style()
	key_bindings = get_key_bindings()

func save_settings():   
	SimpleSettings.set_value("game", "gameplay/difficulty_level", difficulty_level)
	SimpleSettings.set_value("game", "audio/sound_volume", sound_volume)
	SimpleSettings.set_value("game", "graphics/quality", graphics_quality)
	SimpleSettings.set_value("game", "controls/scheme", control_scheme)
	SimpleSettings.set_value("game", "general/language", language)
	SimpleSettings.set_value("game", "accessibility/subtitles_enabled", subtitles_enabled)
	SimpleSettings.set_value("game", "general/auto_save_enabled", auto_save_enabled)
	SimpleSettings.set_value("game", "general/tutorial_enabled", tutorial_enabled)
	SimpleSettings.set_value("game", "graphics/max_framerate", max_framerate)
	SimpleSettings.set_value("game", "graphics/fullscreen_enabled", fullscreen_enabled)
	SimpleSettings.set_value("game", "controls/mouse_sensitivity", mouse_sensitivity)
	SimpleSettings.set_value("game", "controls/vibration_enabled", vibration_enabled)
	SimpleSettings.set_value("game", "graphics/hud_opacity", hud_opacity)
	SimpleSettings.set_value("game", "general/chat_enabled", chat_enabled)
	SimpleSettings.set_value("game", "graphics/crosshair_style", crosshair_style)
	SimpleSettings.set_value("game", "controls/key_bindings", key_bindings)
	SimpleSettings.save()

func reset_to_defaults():
	difficulty_level = "Normal"
	sound_volume = 0.8
	graphics_quality = "High"
	control_scheme = "Keyboard"
	language = "English"
	subtitles_enabled = true
	auto_save_enabled = true
	tutorial_enabled = true
	max_framerate = 60
	fullscreen_enabled = true
	mouse_sensitivity = 1.0
	vibration_enabled = false
	hud_opacity = 1.0
	chat_enabled = true
	crosshair_style = "Default"
	key_bindings = {
		"move_forward": "W",
		"move_backward": "S",
		"move_left": "A",
		"move_right": "D",
		"jump": "Space",
		"crouch": "Ctrl",
		"shoot": "Left Mouse Button",
		"aim": "Right Mouse Button"
	}
	save_settings()    

func print_settings():
	print("Difficulty Level: ", difficulty_level)
	print("Sound Volume: ", sound_volume)
	print("Graphics Quality: ", graphics_quality)
	print("Control Scheme: ", control_scheme)
	print("Language: ", language)
	print("Subtitles Enabled: ", subtitles_enabled)
	print("Auto Save Enabled: ", auto_save_enabled)
	print("Tutorial Enabled: ", tutorial_enabled)
	print("Max Framerate: ", max_framerate)
	print("Fullscreen Enabled: ", fullscreen_enabled)
	print("Mouse Sensitivity: ", mouse_sensitivity)
	print("Vibration Enabled: ", vibration_enabled)
	print("HUD Opacity: ", hud_opacity)
	print("Chat Enabled: ", chat_enabled)
	print("Crosshair Style: ", crosshair_style)
	print("Key Bindings: ", key_bindings)   

# Getter methods
func get_difficulty_level() -> String:
	return SimpleSettings.get_value("game", "gameplay/difficulty_level", difficulty_level)

func get_sound_volume() -> float:
	return SimpleSettings.get_value("game", "audio/sound_volume", sound_volume)

func get_graphics_quality() -> String:
	return SimpleSettings.get_value("game", "graphics/quality", graphics_quality)

func get_control_scheme() -> String:
	return SimpleSettings.get_value("game", "controls/scheme", control_scheme)

func get_language() -> String:
	return SimpleSettings.get_value("game", "general/language", language)

func get_subtitles_enabled() -> bool:
	return SimpleSettings.get_value("game", "accessibility/subtitles_enabled", subtitles_enabled)

func get_auto_save_enabled() -> bool:
	return SimpleSettings.get_value("game", "general/auto_save_enabled", auto_save_enabled)

func get_tutorial_enabled() -> bool:
	return SimpleSettings.get_value("game", "general/tutorial_enabled", tutorial_enabled)

func get_max_framerate() -> int:
	return SimpleSettings.get_value("game", "graphics/max_framerate", max_framerate)

func get_fullscreen_enabled() -> bool:
	return SimpleSettings.get_value("game", "graphics/fullscreen_enabled", fullscreen_enabled)

func get_mouse_sensitivity() -> float:
	return SimpleSettings.get_value("game", "controls/mouse_sensitivity", mouse_sensitivity)

func get_vibration_enabled() -> bool:
	return SimpleSettings.get_value("game", "controls/vibration_enabled", vibration_enabled)

func get_hud_opacity() -> float:
	return SimpleSettings.get_value("game", "graphics/hud_opacity", hud_opacity)

func get_chat_enabled() -> bool:
	return SimpleSettings.get_value("game", "general/chat_enabled", chat_enabled)

func get_crosshair_style() -> String:
	return SimpleSettings.get_value("game", "graphics/crosshair_style", crosshair_style)

func get_key_bindings() -> Dictionary:
	return SimpleSettings.get_value("game", "controls/key_bindings", key_bindings)

func get_key_binding(action: String) -> String:
	var bindings = get_key_bindings()
	return bindings.get(action, "")

# Setter methods
func set_difficulty_level(value: String):
	difficulty_level = value
	SimpleSettings.set_value("game", "gameplay/difficulty_level", value)

func set_sound_volume(value: float):
	sound_volume = value
	SimpleSettings.set_value("game", "audio/sound_volume", value)

func set_graphics_quality(value: String):
	graphics_quality = value
	SimpleSettings.set_value("game", "graphics/quality", value)

func set_control_scheme(value: String):
	control_scheme = value
	SimpleSettings.set_value("game", "controls/scheme", value)

func set_language(value: String):
	language = value
	SimpleSettings.set_value("game", "general/language", value)

func set_subtitles_enabled(value: bool):
	subtitles_enabled = value
	SimpleSettings.set_value("game", "accessibility/subtitles_enabled", value)

func set_auto_save_enabled(value: bool):
	auto_save_enabled = value
	SimpleSettings.set_value("game", "general/auto_save_enabled", value)

func set_tutorial_enabled(value: bool):
	tutorial_enabled = value
	SimpleSettings.set_value("game", "general/tutorial_enabled", value)

func set_max_framerate(value: int):
	max_framerate = value
	SimpleSettings.set_value("game", "graphics/max_framerate", value)

func set_fullscreen_enabled(value: bool):
	fullscreen_enabled = value
	SimpleSettings.set_value("game", "graphics/fullscreen_enabled", value)

func set_mouse_sensitivity(value: float):
	mouse_sensitivity = value
	SimpleSettings.set_value("game", "controls/mouse_sensitivity", value)

func set_vibration_enabled(value: bool):
	vibration_enabled = value
	SimpleSettings.set_value("game", "controls/vibration_enabled", value)

func set_hud_opacity(value: float):
	hud_opacity = value
	SimpleSettings.set_value("game", "graphics/hud_opacity", value)

func set_chat_enabled(value: bool):
	chat_enabled = value
	SimpleSettings.set_value("game", "general/chat_enabled", value)

func set_crosshair_style(value: String):
	crosshair_style = value
	SimpleSettings.set_value("game", "graphics/crosshair_style", value)

func set_key_bindings(value: Dictionary):
	key_bindings = value
	SimpleSettings.set_value("game", "controls/key_bindings", value)

func set_key_binding(action: String, key: String):
	key_bindings[action] = key
	SimpleSettings.set_value("game", "controls/key_bindings", key_bindings)
