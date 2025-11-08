extends Node

var difficulty_level := "Normal"
var sound_volume := 0.8
var graphics_quality := "High"
var control_scheme := "Keyboard"
var language := "English"
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
    "move_right": "D",
    "jump": "Space",
    "crouch": "Ctrl",
    "shoot": "Left Mouse Button",
    "aim": "Right Mouse Button"
}


func _ready():
    SimpleSettings.config_files = {
        game = {
            path = "user://game.ini",
        },
        player = {
            path = "user://player.ini",
        },
    }
    SimpleSettings.load()
    print_settings()

func save_settings():
    SimpleSettings.save_all()

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

