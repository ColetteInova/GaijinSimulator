extends Node

# Aparência customizada do player
var player_appearance: PlayerAppearance = null

# Dados do personagem atual
var character_data = {
	"name": "",
	"character_id": "",
	"character_sprite": "",
	"level": 1,
	"experience": 0,
	"health": 100,
	"energy": 100,
	"money": 1000,
	"location": "home",
	"day": 1,
	"time": "morning"
}


func _ready():
	# Configura o arquivo de save do player
	SimpleSettings.config_files.set("player", {"path": "user://player.ini"})
	SimpleSettings.load()
	load_data()
	load_appearance()


func set_character_info(character_name: String, character_id: String, sprite_path: String):
	"""Define as informações básicas do personagem"""
	character_data["name"] = character_name
	character_data["character_id"] = character_id
	character_data["character_sprite"] = sprite_path
	save_data()


func get_character_name() -> String:
	return character_data["name"]


func get_character_id() -> String:
	return character_data["character_id"]


func get_character_sprite() -> String:
	return character_data["character_sprite"]


func reset_character():
	"""Reseta os dados do personagem"""
	character_data = {
		"name": "",
		"character_id": "",
		"character_sprite": "",
		"level": 1,
		"experience": 0,
		"health": 100,
		"energy": 100,
		"money": 1000,
		"location": "home",
		"day": 1,
		"time": "morning"
	}
	save_data()


func get_all_data() -> Dictionary:
	"""Retorna todos os dados do personagem"""
	return character_data.duplicate()


func load_from_save(save_dict: Dictionary):
	"""Carrega os dados do personagem de um save"""
	if save_dict.has("character"):
		character_data = save_dict["character"].duplicate()
		save_data()


func save_data():
	"""Salva todos os dados do personagem no player.ini"""
	SimpleSettings.set_value("player", "character/name", character_data["name"])
	SimpleSettings.set_value("player", "character/character_id", character_data["character_id"])
	SimpleSettings.set_value("player", "character/character_sprite", character_data["character_sprite"])
	SimpleSettings.set_value("player", "stats/level", character_data["level"])
	SimpleSettings.set_value("player", "stats/experience", character_data["experience"])
	SimpleSettings.set_value("player", "stats/health", character_data["health"])
	SimpleSettings.set_value("player", "stats/energy", character_data["energy"])
	SimpleSettings.set_value("player", "stats/money", character_data["money"])
	SimpleSettings.set_value("player", "game/location", character_data["location"])
	SimpleSettings.set_value("player", "game/day", character_data["day"])
	SimpleSettings.set_value("player", "game/time", character_data["time"])
	SimpleSettings.save()


func load_data():
	"""Carrega os dados do personagem do player.ini"""
	character_data["name"] = SimpleSettings.get_value("player", "character/name", "")
	character_data["character_id"] = SimpleSettings.get_value("player", "character/character_id", "")
	character_data["character_sprite"] = SimpleSettings.get_value("player", "character/character_sprite", "")
	character_data["level"] = SimpleSettings.get_value("player", "stats/level", 1)
	character_data["experience"] = SimpleSettings.get_value("player", "stats/experience", 0)
	character_data["health"] = SimpleSettings.get_value("player", "stats/health", 100)
	character_data["energy"] = SimpleSettings.get_value("player", "stats/energy", 100)
	character_data["money"] = SimpleSettings.get_value("player", "stats/money", 1000)
	character_data["location"] = SimpleSettings.get_value("player", "game/location", "home")
	character_data["day"] = SimpleSettings.get_value("player", "game/day", 1)
	character_data["time"] = SimpleSettings.get_value("player", "game/time", "morning")


func has_character() -> bool:
	"""Verifica se já existe um personagem salvo"""
	return character_data["name"] != "" and character_data["character_id"] != ""


func update_stat(stat_name: String, value):
	"""Atualiza uma estatística específica"""
	if character_data.has(stat_name):
		character_data[stat_name] = value
		save_data()


func add_money(amount: int):
	"""Adiciona dinheiro ao personagem"""
	character_data["money"] += amount
	save_data()


func remove_money(amount: int) -> bool:
	"""Remove dinheiro do personagem. Retorna false se não tiver dinheiro suficiente"""
	if character_data["money"] >= amount:
		character_data["money"] -= amount
		save_data()
		return true
	return false


func add_experience(amount: int):
	"""Adiciona experiência ao personagem"""
	character_data["experience"] += amount
	# TODO: Sistema de level up
	save_data()


func get_time_of_day() -> String:
	"""Retorna o período do dia atual (morning, afternoon, night)"""
	return character_data.get("time", "morning")


func set_time_of_day(time: String):
	"""Define o período do dia (morning, afternoon, night)"""
	if time in ["morning", "afternoon", "night"]:
		character_data["time"] = time
		save_data()


func advance_time():
	"""Avança o período do dia (morning -> afternoon -> night -> morning)"""
	var current_time = get_time_of_day()
	match current_time:
		"morning":
			set_time_of_day("afternoon")
		"afternoon":
			set_time_of_day("night")
		"night":
			set_time_of_day("morning")
			# Avança o dia quando volta para manhã


## Gerenciamento de Aparência do Player
func set_player_appearance(appearance: PlayerAppearance):
	"""Define a aparência customizada do player"""
	player_appearance = appearance.duplicate(true)
	save_appearance()


func get_player_appearance() -> PlayerAppearance:
	"""Retorna a aparência atual do player"""
	if not player_appearance:
		# Se não houver aparência configurada, cria uma padrão
		player_appearance = PlayerAppearance.create_default()
		save_appearance()
	return player_appearance


func save_appearance():
	"""Salva a aparência do player"""
	if player_appearance:
		var save_path = "user://player_appearance.tres"
		var result = ResourceSaver.save(player_appearance, save_path)
		if result != OK:
			push_error("Failed to save player appearance")


func load_appearance():
	"""Carrega a aparência salva do player"""
	var load_path = "user://player_appearance.tres"
	
	if FileAccess.file_exists(load_path):
		var loaded = ResourceLoader.load(load_path) as PlayerAppearance
		if loaded:
			player_appearance = loaded
		else:
			push_warning("Failed to load player appearance, using default")
			player_appearance = PlayerAppearance.create_default()
	else:
		player_appearance = PlayerAppearance.create_default()


func reset_appearance():
	"""Reseta a aparência para o padrão"""
	player_appearance = PlayerAppearance.create_default()
	save_appearance()
