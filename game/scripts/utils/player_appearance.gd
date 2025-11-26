extends Resource
class_name PlayerAppearance

## Configuração de aparência do player com camadas personalizáveis

@export_group("Gender")
@export_enum("Female", "Male") var gender: int = 0  ## 0 = Female, 1 = Male

@export_group("Layer 1 - Skin")
@export var skin_texture: String = "female_skin_01.png"  ## Nome do arquivo de skin

@export_group("Layer 2 - Eyes")
@export var eyes_texture: String = "female_eyes_01.png"  ## Nome do arquivo de olhos
@export var eyes_enabled: bool = true

@export_group("Layer 3 - Shirt")
@export var shirt_texture: String = "female_shirt_01.png"  ## Nome do arquivo de camisa
@export var shirt_enabled: bool = true

@export_group("Layer 4 - Front Hair")
@export var front_hair_texture: String = "female_hair_01.png"  ## Nome do arquivo de cabelo frontal
@export var front_hair_enabled: bool = true

@export_group("Layer 5 - Shoes")
@export var shoes_texture: String = "female_shoes_01.png"  ## Nome do arquivo de sapatos
@export var shoes_enabled: bool = true

@export_group("Layer 6 - Pants")
@export var pants_texture: String = "female_pants_01.png"  ## Nome do arquivo de calças
@export var pants_enabled: bool = true

@export_group("Layer 0 - Back Hair")
@export var back_hair_texture: String = "female_hair_05_b.png"  ## Nome do arquivo de cabelo traseiro
@export var back_hair_enabled: bool = false

@export_group("Accessories")
@export var glasses_texture: String = ""  ## Nome do arquivo de óculos (vazio = sem óculos)
@export var hat_texture: String = ""  ## Nome do arquivo de chapéu (vazio = sem chapéu)


static func create_default() -> PlayerAppearance:
	"""Cria uma aparência padrão básica"""
	var appearance = PlayerAppearance.new()
	appearance.gender = 0  # Female
	appearance.skin_texture = "female_skin_01.png"
	appearance.eyes_texture = "female_eyes_01.png"
	appearance.eyes_enabled = true
	appearance.shirt_texture = "female_shirt_01.png"
	appearance.shirt_enabled = true
	appearance.front_hair_texture = "female_hair_01.png"
	appearance.front_hair_enabled = true
	appearance.shoes_texture = "female_shoes_01.png"
	appearance.shoes_enabled = true
	appearance.pants_texture = "female_pants_01.png"
	appearance.pants_enabled = true
	appearance.back_hair_enabled = false
	appearance.glasses_texture = ""
	appearance.hat_texture = ""
	return appearance


static func create_male_default() -> PlayerAppearance:
	"""Cria uma aparência padrão masculina"""
	var appearance = PlayerAppearance.new()
	appearance.gender = 1  # Male
	appearance.skin_texture = "male_skin_01.png"
	appearance.eyes_texture = "male_eyes_01.png"
	appearance.eyes_enabled = true
	appearance.shirt_texture = "male_shirt_01.png"
	appearance.shirt_enabled = true
	appearance.front_hair_texture = "male_hair_01.png"
	appearance.front_hair_enabled = true
	appearance.shoes_texture = "male_shoes_01.png"
	appearance.shoes_enabled = true
	appearance.pants_texture = "male_pants_01.png"
	appearance.pants_enabled = true
	appearance.back_hair_enabled = false
	appearance.glasses_texture = ""
	appearance.hat_texture = ""
	return appearance


func get_gender_folder() -> String:
	"""Retorna o nome da pasta do gênero"""
	return "female" if gender == 0 else "male"


func get_layer_path(layer: String, texture_name: String) -> String:
	"""Retorna o caminho completo para uma textura de camada"""
	var base_path = "res://assets/sprites/characters/player/"
	var gender_folder = get_gender_folder()
	return base_path + gender_folder + "/" + layer + "/" + texture_name


func get_accessory_path(texture_name: String) -> String:
	"""Retorna o caminho para um acessório unisex"""
	if texture_name.is_empty():
		return ""
	return "res://assets/sprites/characters/player/unisex_accessories/" + texture_name
