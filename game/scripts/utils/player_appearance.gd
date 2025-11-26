extends Resource
class_name PlayerAppearance

## Configuração de aparência do player com camadas personalizáveis

enum SkinType { SKIN_01, SKIN_02, SKIN_03, SKIN_04, SKIN_05 }
enum EyesType { EYES_01, EYES_02, EYES_03, EYES_04 }
enum ShirtType { SHIRT_01, SHIRT_02, SHIRT_03, SHIRT_04, SHIRT_05, SHIRT_06, SHIRT_07, SHIRT_08, SHIRT_09, SHIRT_10, SHIRT_11, SHIRT_12, SHIRT_13, SHIRT_14, SHIRT_15 }
enum FemaleFrontHairType { 
	HAIR_01, HAIR_02, HAIR_03, HAIR_04, HAIR_05_A, HAIR_06_A, HAIR_07_A, HAIR_08_A, 
	HAIR_09, HAIR_10, HAIR_11, HAIR_12, HAIR_13, HAIR_14, HAIR_15, HAIR_16, 
	HAIR_17, HAIR_18, HAIR_19, HAIR_20, HAIR_21_A, HAIR_22_A, HAIR_23_A, HAIR_24_A, 
	HAIR_25_A, HAIR_26_A, HAIR_27_A, HAIR_28_A, HAIR_29, HAIR_30 
}
enum MaleFrontHairType { 
	HAIR_01, HAIR_02, HAIR_03, HAIR_04, HAIR_05, HAIR_06, HAIR_07, HAIR_08, 
	HAIR_09, HAIR_10, HAIR_11, HAIR_12, HAIR_13, HAIR_14, HAIR_15, HAIR_16, 
	HAIR_17, HAIR_18, HAIR_19, HAIR_20, HAIR_21, HAIR_22, HAIR_23, HAIR_24, 
	HAIR_25_A, HAIR_26_A, HAIR_27_A, HAIR_28_A, HAIR_29, HAIR_30 
}
enum FemaleBackHairType { HAIR_05_B, HAIR_06_B, HAIR_07_B, HAIR_08_B, HAIR_21_B, HAIR_22_B, HAIR_23_B, HAIR_24_B, HAIR_25_B, HAIR_26_B, HAIR_27_B, HAIR_28_B }
enum MaleBackHairType { HAIR_25_B, HAIR_26_B, HAIR_27_B, HAIR_28_B }
enum ShoesType { SHOES_01, SHOES_02, SHOES_03, SHOES_04, SHOES_05, SHOES_06, SHOES_07, SHOES_08, SHOES_09, SHOES_10, SHOES_11, SHOES_12 }
enum PantsType { PANTS_01, PANTS_02, PANTS_03, PANTS_04, PANTS_05, PANTS_06, PANTS_07, PANTS_08, PANTS_09, PANTS_10, PANTS_11, PANTS_12 }
enum GlassesType { NONE, GLASSES_01, GLASSES_02, GLASSES_03, GLASSES_04, GLASSES_05, GLASSES_06 }
enum HatType { NONE, HAT_01, HAT_02, HAT_03, HAT_04, HAT_05, HAT_06 }

@export_group("Gender")
@export_enum("Female", "Male") var gender: int = 0  ## 0 = Female, 1 = Male

@export_group("Layer 1 - Skin")
@export var skin: SkinType = SkinType.SKIN_01

@export_group("Layer 2 - Eyes")
@export var eyes: EyesType = EyesType.EYES_01
@export var eyes_enabled: bool = true

@export_group("Layer 3 - Shirt")
@export var shirt: ShirtType = ShirtType.SHIRT_01
@export var shirt_enabled: bool = true

@export_group("Layer 4 - Front Hair")
@export var female_front_hair: FemaleFrontHairType = FemaleFrontHairType.HAIR_01
@export var male_front_hair: MaleFrontHairType = MaleFrontHairType.HAIR_01
@export var front_hair_enabled: bool = true

@export_group("Layer 5 - Shoes")
@export var shoes: ShoesType = ShoesType.SHOES_01
@export var shoes_enabled: bool = true

@export_group("Layer 6 - Pants")
@export var pants: PantsType = PantsType.PANTS_01
@export var pants_enabled: bool = true

@export_group("Layer 0 - Back Hair")
@export var female_back_hair: FemaleBackHairType = FemaleBackHairType.HAIR_05_B
@export var male_back_hair: MaleBackHairType = MaleBackHairType.HAIR_25_B
@export var back_hair_enabled: bool = false

@export_group("Accessories")
@export var glasses: GlassesType = GlassesType.NONE
@export var hat: HatType = HatType.NONE


# Helper functions to convert enums to filenames
func get_skin_filename() -> String:
	var prefix = "female" if gender == 0 else "male"
	return "%s_skin_%02d.png" % [prefix, skin + 1]


func get_eyes_filename() -> String:
	var prefix = "female" if gender == 0 else "male"
	return "%s_eyes_%02d.png" % [prefix, eyes + 1]


func get_shirt_filename() -> String:
	var prefix = "female" if gender == 0 else "male"
	return "%s_shirt_%02d.png" % [prefix, shirt + 1]


func get_front_hair_filename() -> String:
	if gender == 0:  # Female
		match female_front_hair:
			FemaleFrontHairType.HAIR_01: return "female_hair_01.png"
			FemaleFrontHairType.HAIR_02: return "female_hair_02.png"
			FemaleFrontHairType.HAIR_03: return "female_hair_03.png"
			FemaleFrontHairType.HAIR_04: return "female_hair_04.png"
			FemaleFrontHairType.HAIR_05_A: return "female_hair_05_a.png"
			FemaleFrontHairType.HAIR_06_A: return "female_hair_06_a.png"
			FemaleFrontHairType.HAIR_07_A: return "female_hair_07_a.png"
			FemaleFrontHairType.HAIR_08_A: return "female_hair_08_a.png"
			FemaleFrontHairType.HAIR_09: return "female_hair_09.png"
			FemaleFrontHairType.HAIR_10: return "female_hair_10.png"
			FemaleFrontHairType.HAIR_11: return "female_hair_11.png"
			FemaleFrontHairType.HAIR_12: return "female_hair_12.png"
			FemaleFrontHairType.HAIR_13: return "female_hair_13.png"
			FemaleFrontHairType.HAIR_14: return "female_hair_14.png"
			FemaleFrontHairType.HAIR_15: return "female_hair_15.png"
			FemaleFrontHairType.HAIR_16: return "female_hair_16.png"
			FemaleFrontHairType.HAIR_17: return "female_hair_17.png"
			FemaleFrontHairType.HAIR_18: return "female_hair_18.png"
			FemaleFrontHairType.HAIR_19: return "female_hair_19.png"
			FemaleFrontHairType.HAIR_20: return "female_hair_20.png"
			FemaleFrontHairType.HAIR_21_A: return "female_hair_21_a.png"
			FemaleFrontHairType.HAIR_22_A: return "female_hair_22_a.png"
			FemaleFrontHairType.HAIR_23_A: return "female_hair_23_a.png"
			FemaleFrontHairType.HAIR_24_A: return "female_hair_24_a.png"
			FemaleFrontHairType.HAIR_25_A: return "female_hair_25_a.png"
			FemaleFrontHairType.HAIR_26_A: return "female_hair_26_a.png"
			FemaleFrontHairType.HAIR_27_A: return "female_hair_27_a.png"
			FemaleFrontHairType.HAIR_28_A: return "female_hair_28_a.png"
			FemaleFrontHairType.HAIR_29: return "female_hair_29.png"
			FemaleFrontHairType.HAIR_30: return "female_hair_30.png"
	else:  # Male
		match male_front_hair:
			MaleFrontHairType.HAIR_01: return "male_hair_01.png"
			MaleFrontHairType.HAIR_02: return "male_hair_02.png"
			MaleFrontHairType.HAIR_03: return "male_hair_03.png"
			MaleFrontHairType.HAIR_04: return "male_hair_04.png"
			MaleFrontHairType.HAIR_05: return "male_hair_05.png"
			MaleFrontHairType.HAIR_06: return "male_hair_06.png"
			MaleFrontHairType.HAIR_07: return "male_hair_07.png"
			MaleFrontHairType.HAIR_08: return "male_hair_08.png"
			MaleFrontHairType.HAIR_09: return "male_hair_09.png"
			MaleFrontHairType.HAIR_10: return "male_hair_10.png"
			MaleFrontHairType.HAIR_11: return "male_hair_11.png"
			MaleFrontHairType.HAIR_12: return "male_hair_12.png"
			MaleFrontHairType.HAIR_13: return "male_hair_13.png"
			MaleFrontHairType.HAIR_14: return "male_hair_14.png"
			MaleFrontHairType.HAIR_15: return "male_hair_15.png"
			MaleFrontHairType.HAIR_16: return "male_hair_16.png"
			MaleFrontHairType.HAIR_17: return "male_hair_17.png"
			MaleFrontHairType.HAIR_18: return "male_hair_18.png"
			MaleFrontHairType.HAIR_19: return "male_hair_19.png"
			MaleFrontHairType.HAIR_20: return "male_hair_20.png"
			MaleFrontHairType.HAIR_21: return "male_hair_21.png"
			MaleFrontHairType.HAIR_22: return "male_hair_22.png"
			MaleFrontHairType.HAIR_23: return "male_hair_23.png"
			MaleFrontHairType.HAIR_24: return "male_hair_24.png"
			MaleFrontHairType.HAIR_25_A: return "male_hair_25_a.png"
			MaleFrontHairType.HAIR_26_A: return "male_hair_26_a.png"
			MaleFrontHairType.HAIR_27_A: return "male_hair_27_a.png"
			MaleFrontHairType.HAIR_28_A: return "male_hair_28_a.png"
			MaleFrontHairType.HAIR_29: return "male_hair_29.png"
			MaleFrontHairType.HAIR_30: return "male_hair_30.png"
	return ""


func get_back_hair_filename() -> String:
	if gender == 0:  # Female
		match female_back_hair:
			FemaleBackHairType.HAIR_05_B: return "female_hair_05_b.png"
			FemaleBackHairType.HAIR_06_B: return "female_hair_06_b.png"
			FemaleBackHairType.HAIR_07_B: return "female_hair_07_b.png"
			FemaleBackHairType.HAIR_08_B: return "female_hair_08_b.png"
			FemaleBackHairType.HAIR_21_B: return "female_hair_21_b.png"
			FemaleBackHairType.HAIR_22_B: return "female_hair_22_b.png"
			FemaleBackHairType.HAIR_23_B: return "female_hair_23_b.png"
			FemaleBackHairType.HAIR_24_B: return "female_hair_24_b.png"
			FemaleBackHairType.HAIR_25_B: return "female_hair_25_b.png"
			FemaleBackHairType.HAIR_26_B: return "female_hair_26_b.png"
			FemaleBackHairType.HAIR_27_B: return "female_hair_27_b.png"
			FemaleBackHairType.HAIR_28_B: return "female_hair_28_b.png"
	else:  # Male
		match male_back_hair:
			MaleBackHairType.HAIR_25_B: return "male_hair_25_b.png"
			MaleBackHairType.HAIR_26_B: return "male_hair_26_b.png"
			MaleBackHairType.HAIR_27_B: return "male_hair_27_b.png"
			MaleBackHairType.HAIR_28_B: return "male_hair_28_b.png"
	return ""


func get_shoes_filename() -> String:
	var prefix = "female" if gender == 0 else "male"
	return "%s_shoes_%02d.png" % [prefix, shoes + 1]


func get_pants_filename() -> String:
	var prefix = "female" if gender == 0 else "male"
	return "%s_pants_%02d.png" % [prefix, pants + 1]


func get_glasses_filename() -> String:
	if glasses == GlassesType.NONE:
		return ""
	return "unisex_glasses%d.png" % glasses


func get_hat_filename() -> String:
	if hat == HatType.NONE:
		return ""
	return "unisex_hat%d.png" % hat


static func create_default() -> PlayerAppearance:
	"""Cria uma aparência padrão básica"""
	var appearance = PlayerAppearance.new()
	appearance.gender = 0  # Female
	appearance.skin = SkinType.SKIN_01
	appearance.eyes = EyesType.EYES_01
	appearance.eyes_enabled = true
	appearance.shirt = ShirtType.SHIRT_01
	appearance.shirt_enabled = true
	appearance.female_front_hair = FemaleFrontHairType.HAIR_01
	appearance.front_hair_enabled = true
	appearance.shoes = ShoesType.SHOES_01
	appearance.shoes_enabled = true
	appearance.pants = PantsType.PANTS_01
	appearance.pants_enabled = true
	appearance.back_hair_enabled = false
	appearance.glasses = GlassesType.NONE
	appearance.hat = HatType.NONE
	return appearance


static func create_male_default() -> PlayerAppearance:
	"""Cria uma aparência padrão masculina"""
	var appearance = PlayerAppearance.new()
	appearance.gender = 1  # Male
	appearance.skin = SkinType.SKIN_01
	appearance.eyes = EyesType.EYES_01
	appearance.eyes_enabled = true
	appearance.shirt = ShirtType.SHIRT_01
	appearance.shirt_enabled = true
	appearance.male_front_hair = MaleFrontHairType.HAIR_01
	appearance.front_hair_enabled = true
	appearance.shoes = ShoesType.SHOES_01
	appearance.shoes_enabled = true
	appearance.pants = PantsType.PANTS_01
	appearance.pants_enabled = true
	appearance.back_hair_enabled = false
	appearance.glasses = GlassesType.NONE
	appearance.hat = HatType.NONE
	return appearance


func get_gender_folder() -> String:
	"""Retorna o nome da pasta do gênero"""
	return "female" if gender == 0 else "male"


func get_layer_path(layer: String) -> String:
	"""Retorna o caminho completo para uma textura de camada usando enums"""
	var base_path = "res://assets/sprites/characters/player/"
	var gender_folder = get_gender_folder()
	var filename = ""
	
	match layer:
		"layer1_skin":
			filename = get_skin_filename()
		"layer2_eyes":
			filename = get_eyes_filename()
		"layer3_shirt":
			filename = get_shirt_filename()
		"layer4_front_hair":
			filename = get_front_hair_filename()
		"layer5_shoes":
			filename = get_shoes_filename()
		"layer6_pants":
			filename = get_pants_filename()
		"layer0_back_hair":
			filename = get_back_hair_filename()
	
	if filename.is_empty():
		return ""
	return base_path + gender_folder + "/" + layer + "/" + filename


func get_accessory_path(accessory_type: String) -> String:
	"""Retorna o caminho para um acessório unisex"""
	var filename = ""
	
	if accessory_type == "glasses":
		filename = get_glasses_filename()
	elif accessory_type == "hat":
		filename = get_hat_filename()
	
	if filename.is_empty():
		return ""
	return "res://assets/sprites/characters/player/unisex_accessories/" + filename
