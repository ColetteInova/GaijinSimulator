@tool
extends VBoxContainer

@export var icon_texture: Texture2D:
	set(value):
		icon_texture = value
		if icon_rect:
			icon_rect.texture = value

@export var label_text: String = "":
	set(value):
		label_text = value
		if label:
			label.text = value

@export var translation_key: String = "":
	set(value):
		translation_key = value
		if label:
			label.text = tr(value) if value != "" else ""

@onready var icon_rect: TextureRect = $InfoItemIconTextureRect
@onready var label: Label = $Label

func _ready() -> void:
	if icon_texture:
		icon_rect.texture = icon_texture
	
	if translation_key != "":
		label.text = tr(translation_key)
	elif label_text != "":
		label.text = label_text
