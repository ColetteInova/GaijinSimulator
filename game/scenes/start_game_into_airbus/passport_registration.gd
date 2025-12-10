extends Control
class_name PassportRegistration

## Passport Registration - Formulário de cadastro do jogador estilo passaporte

signal registration_completed(data: Dictionary)
signal appearance_changed(appearance: PlayerAppearance)

# Referências aos nós da UI
@onready var first_name_input: LineEdit = $FormContainer/ScrollContainer/FormFields/FirstNameContainer/FirstNameInput
@onready var last_name_input: LineEdit = $FormContainer/ScrollContainer/FormFields/LastNameContainer/LastNameInput
@onready var gender_option: OptionButton = $FormContainer/ScrollContainer/FormFields/GenderContainer/GenderOption
@onready var orientation_option: OptionButton = $FormContainer/ScrollContainer/FormFields/OrientationContainer/OrientationOption
@onready var country_option: OptionButton = $FormContainer/ScrollContainer/FormFields/CountryContainer/CountryOption

# Customização de aparência
@onready var skin_option: OptionButton = $FormContainer/ScrollContainer/FormFields/AppearanceSection/SkinContainer/SkinOption
@onready var eyes_option: OptionButton = $FormContainer/ScrollContainer/FormFields/AppearanceSection/EyesContainer/EyesOption
@onready var hair_option: OptionButton = $FormContainer/ScrollContainer/FormFields/AppearanceSection/HairContainer/HairOption

@onready var confirm_button: Button = $FormContainer/ConfirmButton

# Dados do formulário
var current_appearance: PlayerAppearance

# Listas para tradução
var gender_keys = ["GENDER_FEMALE", "GENDER_MALE"]
var orientation_keys = [
	"ORIENTATION_HETEROSEXUAL",
	"ORIENTATION_HOMOSEXUAL",
	"ORIENTATION_BISEXUAL",
	"ORIENTATION_PANSEXUAL",
	"ORIENTATION_ASEXUAL",
	"ORIENTATION_OTHER",
	"ORIENTATION_PREFER_NOT_SAY"
]
var country_keys = [
	"COUNTRY_BRAZIL",
	"COUNTRY_USA",
	"COUNTRY_JAPAN",
	"COUNTRY_UK",
	"COUNTRY_GERMANY",
	"COUNTRY_FRANCE",
	"COUNTRY_ITALY",
	"COUNTRY_SPAIN",
	"COUNTRY_PORTUGAL",
	"COUNTRY_CANADA",
	"COUNTRY_MEXICO",
	"COUNTRY_ARGENTINA",
	"COUNTRY_CHINA",
	"COUNTRY_KOREA",
	"COUNTRY_INDIA",
	"COUNTRY_AUSTRALIA",
	"COUNTRY_OTHER"
]


func _ready():
	# Inicializa a aparência padrão
	current_appearance = PlayerAppearance.create_default()
	
	# Configura os dropdowns
	_setup_gender_options()
	_setup_orientation_options()
	_setup_country_options()
	_setup_appearance_options()
	
	# Conecta sinais
	gender_option.item_selected.connect(_on_gender_changed)
	skin_option.item_selected.connect(_on_skin_changed)
	eyes_option.item_selected.connect(_on_eyes_changed)
	hair_option.item_selected.connect(_on_hair_changed)
	confirm_button.pressed.connect(_on_confirm_pressed)
	
	# Atualiza o preview inicial
	_emit_appearance_changed()


func _setup_gender_options():
	"""Configura as opções de gênero com traduções"""
	gender_option.clear()
	for key in gender_keys:
		gender_option.add_item(tr(key))


func _setup_orientation_options():
	"""Configura as opções de orientação sexual com traduções"""
	orientation_option.clear()
	for key in orientation_keys:
		orientation_option.add_item(tr(key))


func _setup_country_options():
	"""Configura as opções de país com traduções"""
	country_option.clear()
	for key in country_keys:
		country_option.add_item(tr(key))


func _setup_appearance_options():
	"""Configura as opções de aparência"""
	_update_skin_options()
	_update_eyes_options()
	_update_hair_options()


func _update_skin_options():
	"""Atualiza opções de pele"""
	skin_option.clear()
	for i in range(5):  # SKIN_01 to SKIN_05
		skin_option.add_item(tr("PASSPORT_SKIN") + " " + str(i + 1))


func _update_eyes_options():
	"""Atualiza opções de olhos"""
	eyes_option.clear()
	for i in range(4):  # EYES_01 to EYES_04
		eyes_option.add_item(tr("PASSPORT_EYES") + " " + str(i + 1))


func _update_hair_options():
	"""Atualiza opções de cabelo baseado no gênero"""
	hair_option.clear()
	var hair_count = 30  # Ambos os gêneros têm 30 opções de cabelo frontal
	for i in range(hair_count):
		hair_option.add_item(tr("PASSPORT_HAIR") + " " + str(i + 1))


func _on_gender_changed(index: int):
	"""Quando o gênero é alterado"""
	current_appearance.gender = index  # 0 = Female, 1 = Male
	
	# Reseta o cabelo para o primeiro do novo gênero
	if index == 0:
		current_appearance.female_front_hair = PlayerAppearance.FemaleFrontHairType.HAIR_01
	else:
		current_appearance.male_front_hair = PlayerAppearance.MaleFrontHairType.HAIR_01
	
	hair_option.select(0)
	_update_hair_options()
	_emit_appearance_changed()


func _on_skin_changed(index: int):
	"""Quando a pele é alterada"""
	current_appearance.skin = index as PlayerAppearance.SkinType
	_emit_appearance_changed()


func _on_eyes_changed(index: int):
	"""Quando os olhos são alterados"""
	current_appearance.eyes = index as PlayerAppearance.EyesType
	_emit_appearance_changed()


func _on_hair_changed(index: int):
	"""Quando o cabelo é alterado"""
	if current_appearance.gender == 0:
		current_appearance.female_front_hair = index as PlayerAppearance.FemaleFrontHairType
	else:
		current_appearance.male_front_hair = index as PlayerAppearance.MaleFrontHairType
	_emit_appearance_changed()


func _emit_appearance_changed():
	"""Emite o sinal de mudança de aparência"""
	appearance_changed.emit(current_appearance)


func _on_confirm_pressed():
	"""Quando o botão de confirmar é pressionado"""
	var registration_data = {
		"first_name": first_name_input.text.strip_edges(),
		"last_name": last_name_input.text.strip_edges(),
		"gender": gender_option.selected,
		"gender_key": gender_keys[gender_option.selected],
		"orientation": orientation_option.selected,
		"orientation_key": orientation_keys[orientation_option.selected],
		"country": country_option.selected,
		"country_key": country_keys[country_option.selected],
		"appearance": current_appearance.duplicate(true)
	}
	
	# Valida dados mínimos
	if registration_data["first_name"].is_empty():
		push_warning("First name is required")
		return
	
	# Salva a aparência no PlayerData
	if PlayerData:
		PlayerData.set_player_appearance(current_appearance)
		PlayerData.character_data["name"] = registration_data["first_name"] + " " + registration_data["last_name"]
		PlayerData.save_data()
	
	registration_completed.emit(registration_data)


func get_current_appearance() -> PlayerAppearance:
	"""Retorna a aparência atual configurada"""
	return current_appearance


func set_initial_appearance(appearance: PlayerAppearance):
	"""Define uma aparência inicial"""
	if appearance:
		current_appearance = appearance.duplicate(true)
		
		# Atualiza os dropdowns para refletir a aparência
		gender_option.select(current_appearance.gender)
		skin_option.select(current_appearance.skin)
		eyes_option.select(current_appearance.eyes)
		
		if current_appearance.gender == 0:
			hair_option.select(current_appearance.female_front_hair)
		else:
			hair_option.select(current_appearance.male_front_hair)
		
		_emit_appearance_changed()


## Atualiza os labels quando o idioma muda
func update_translations():
	"""Atualiza todas as traduções dos elementos UI"""
	_setup_gender_options()
	_setup_orientation_options()
	_setup_country_options()
	_update_skin_options()
	_update_eyes_options()
	_update_hair_options()
