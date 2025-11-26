extends Node
class_name PlayerCustomizationManager

## Gerencia a customização da aparência do player
## Permite alterar cada aspecto da aparência e salvar/carregar presets

signal appearance_changed(appearance: PlayerAppearance)
signal customization_saved(slot_name: String)
signal customization_loaded(slot_name: String)

var current_appearance: PlayerAppearance
var preview_appearance: PlayerAppearance  ## Para preview antes de confirmar


func _ready():
	# Inicializa com aparência padrão se não houver uma
	if not current_appearance:
		current_appearance = PlayerAppearance.create_default()


## Inicializa o manager com uma aparência existente
func initialize_with_appearance(appearance: PlayerAppearance):
	current_appearance = appearance.duplicate(true)
	preview_appearance = appearance.duplicate(true)


## Cria uma nova aparência do zero
func create_new_appearance(gender: int = 0):
	if gender == 0:
		current_appearance = PlayerAppearance.create_default()
	else:
		current_appearance = PlayerAppearance.create_male_default()
	
	preview_appearance = current_appearance.duplicate(true)
	appearance_changed.emit(current_appearance)


## Altera o gênero e reseta para aparência padrão daquele gênero
func change_gender(new_gender: int):
	preview_appearance.gender = new_gender
	
	# Ajusta os valores padrão para o novo gênero
	if new_gender == 0:  # Female
		preview_appearance.female_front_hair = PlayerAppearance.FemaleFrontHairType.HAIR_01
		preview_appearance.female_back_hair = PlayerAppearance.FemaleBackHairType.HAIR_05_B
	else:  # Male
		preview_appearance.male_front_hair = PlayerAppearance.MaleFrontHairType.HAIR_01
		preview_appearance.male_back_hair = PlayerAppearance.MaleBackHairType.HAIR_25_B
	
	appearance_changed.emit(preview_appearance)


## Altera a skin
func change_skin(skin_type: PlayerAppearance.SkinType):
	preview_appearance.skin = skin_type
	appearance_changed.emit(preview_appearance)


## Altera os olhos
func change_eyes(eyes_type: PlayerAppearance.EyesType):
	preview_appearance.eyes = eyes_type
	appearance_changed.emit(preview_appearance)


## Altera a camisa
func change_shirt(shirt_type: PlayerAppearance.ShirtType):
	preview_appearance.shirt = shirt_type
	appearance_changed.emit(preview_appearance)


## Altera o cabelo frontal
func change_front_hair(hair_type_value: int):
	if preview_appearance.gender == 0:
		preview_appearance.female_front_hair = hair_type_value as PlayerAppearance.FemaleFrontHairType
	else:
		preview_appearance.male_front_hair = hair_type_value as PlayerAppearance.MaleFrontHairType
	appearance_changed.emit(preview_appearance)


## Altera o cabelo traseiro
func change_back_hair(hair_type_value: int, enabled: bool = true):
	preview_appearance.back_hair_enabled = enabled
	if preview_appearance.gender == 0:
		preview_appearance.female_back_hair = hair_type_value as PlayerAppearance.FemaleBackHairType
	else:
		preview_appearance.male_back_hair = hair_type_value as PlayerAppearance.MaleBackHairType
	appearance_changed.emit(preview_appearance)


## Altera os sapatos
func change_shoes(shoes_type: PlayerAppearance.ShoesType):
	preview_appearance.shoes = shoes_type
	appearance_changed.emit(preview_appearance)


## Altera as calças
func change_pants(pants_type: PlayerAppearance.PantsType):
	preview_appearance.pants = pants_type
	appearance_changed.emit(preview_appearance)


## Altera os óculos
func change_glasses(glasses_type: PlayerAppearance.GlassesType):
	preview_appearance.glasses = glasses_type
	appearance_changed.emit(preview_appearance)


## Altera o chapéu
func change_hat(hat_type: PlayerAppearance.HatType):
	preview_appearance.hat = hat_type
	appearance_changed.emit(preview_appearance)


## Toggle de visibilidade de camadas
func toggle_layer(layer_name: String, enabled: bool):
	match layer_name:
		"eyes":
			preview_appearance.eyes_enabled = enabled
		"shirt":
			preview_appearance.shirt_enabled = enabled
		"front_hair":
			preview_appearance.front_hair_enabled = enabled
		"back_hair":
			preview_appearance.back_hair_enabled = enabled
		"shoes":
			preview_appearance.shoes_enabled = enabled
		"pants":
			preview_appearance.pants_enabled = enabled
	
	appearance_changed.emit(preview_appearance)


## Confirma as alterações (aplica preview para current)
func confirm_changes():
	current_appearance = preview_appearance.duplicate(true)
	appearance_changed.emit(current_appearance)


## Cancela as alterações (reverte preview para current)
func cancel_changes():
	preview_appearance = current_appearance.duplicate(true)
	appearance_changed.emit(current_appearance)


## Reseta para aparência padrão
func reset_to_default():
	if preview_appearance.gender == 0:
		preview_appearance = PlayerAppearance.create_default()
	else:
		preview_appearance = PlayerAppearance.create_male_default()
	
	appearance_changed.emit(preview_appearance)


## Salva a aparência atual como preset
func save_preset(preset_name: String) -> bool:
	var save_path = "user://customizations/%s.tres" % preset_name
	
	# Cria o diretório se não existir
	DirAccess.make_dir_recursive_absolute("user://customizations")
	
	var result = ResourceSaver.save(current_appearance, save_path)
	if result == OK:
		customization_saved.emit(preset_name)
		return true
	else:
		push_error("Failed to save customization preset: %s" % preset_name)
		return false


## Carrega um preset salvo
func load_preset(preset_name: String) -> bool:
	var load_path = "user://customizations/%s.tres" % preset_name
	
	if not FileAccess.file_exists(load_path):
		push_error("Customization preset not found: %s" % preset_name)
		return false
	
	var loaded_appearance = ResourceLoader.load(load_path) as PlayerAppearance
	if loaded_appearance:
		current_appearance = loaded_appearance.duplicate(true)
		preview_appearance = loaded_appearance.duplicate(true)
		appearance_changed.emit(current_appearance)
		customization_loaded.emit(preset_name)
		return true
	else:
		push_error("Failed to load customization preset: %s" % preset_name)
		return false


## Lista todos os presets salvos
func list_presets() -> Array[String]:
	var presets: Array[String] = []
	var dir = DirAccess.open("user://customizations")
	
	if dir:
		dir.list_dir_begin()
		var file_name = dir.get_next()
		
		while file_name != "":
			if not dir.current_is_dir() and file_name.ends_with(".tres"):
				presets.append(file_name.get_basename())
			file_name = dir.get_next()
		
		dir.list_dir_end()
	
	return presets


## Deleta um preset
func delete_preset(preset_name: String) -> bool:
	var file_path = "user://customizations/%s.tres" % preset_name
	
	if FileAccess.file_exists(file_path):
		var dir = DirAccess.open("user://customizations")
		if dir:
			var error = dir.remove(file_path)
			return error == OK
	
	return false


## Exporta a aparência atual como Resource para uso no jogo
func get_current_appearance() -> PlayerAppearance:
	return current_appearance.duplicate(true)


## Exporta o preview da aparência
func get_preview_appearance() -> PlayerAppearance:
	return preview_appearance.duplicate(true)


## Randomiza a aparência
func randomize_appearance():
	var rng = RandomNumberGenerator.new()
	rng.randomize()
	
	# Mantém o gênero
	var gender = preview_appearance.gender
	
	# Randomiza cada aspecto
	preview_appearance.skin = rng.randi_range(0, 4) as PlayerAppearance.SkinType
	preview_appearance.eyes = rng.randi_range(0, 3) as PlayerAppearance.EyesType
	preview_appearance.shirt = rng.randi_range(0, 14) as PlayerAppearance.ShirtType
	preview_appearance.shoes = rng.randi_range(0, 11) as PlayerAppearance.ShoesType
	preview_appearance.pants = rng.randi_range(0, 11) as PlayerAppearance.PantsType
	
	if gender == 0:  # Female
		preview_appearance.female_front_hair = rng.randi_range(0, 29) as PlayerAppearance.FemaleFrontHairType
		if rng.randf() > 0.5:
			preview_appearance.female_back_hair = rng.randi_range(0, 11) as PlayerAppearance.FemaleBackHairType
			preview_appearance.back_hair_enabled = true
		else:
			preview_appearance.back_hair_enabled = false
	else:  # Male
		preview_appearance.male_front_hair = rng.randi_range(0, 29) as PlayerAppearance.MaleFrontHairType
		if rng.randf() > 0.5:
			preview_appearance.male_back_hair = rng.randi_range(0, 3) as PlayerAppearance.MaleBackHairType
			preview_appearance.back_hair_enabled = true
		else:
			preview_appearance.back_hair_enabled = false
	
	# Acessórios opcionais
	preview_appearance.glasses = rng.randi_range(0, 6) as PlayerAppearance.GlassesType
	preview_appearance.hat = rng.randi_range(0, 6) as PlayerAppearance.HatType
	
	appearance_changed.emit(preview_appearance)


## Obtém informações sobre as opções disponíveis
func get_available_options(layer: String) -> int:
	match layer:
		"skin":
			return 5
		"eyes":
			return 4
		"shirt":
			return 15
		"female_front_hair":
			return 30
		"male_front_hair":
			return 30
		"female_back_hair":
			return 12
		"male_back_hair":
			return 4
		"shoes":
			return 12
		"pants":
			return 12
		"glasses":
			return 7  # Including NONE
		"hat":
			return 7  # Including NONE
	
	return 0
