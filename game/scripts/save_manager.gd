extends Node

const MAX_SAVE_SLOTS = 4
const SAVE_DIR = "user://saves/"
const SAVE_FILE_PREFIX = "save_slot_"
const SAVE_FILE_EXTENSION = ".dat"

signal save_completed(slot: int)
signal load_completed(slot: int)
signal save_deleted(slot: int)


func _ready():
	# Cria o diretório de saves se não existir
	_ensure_save_directory()


func _ensure_save_directory():
	var dir = DirAccess.open("user://")
	if not dir.dir_exists("saves"):
		dir.make_dir("saves")


func get_save_file_path(slot: int) -> String:
	if slot < 0 or slot >= MAX_SAVE_SLOTS:
		push_error("Invalid save slot: " + str(slot))
		return ""
	return SAVE_DIR + SAVE_FILE_PREFIX + str(slot) + SAVE_FILE_EXTENSION


func save_game(slot: int, save_data: Dictionary) -> bool:
	if slot < 0 or slot >= MAX_SAVE_SLOTS:
		push_error("Invalid save slot: " + str(slot))
		return false
	
	var file_path = get_save_file_path(slot)
	
	# Adiciona metadados
	save_data["metadata"] = {
		"slot": slot,
		"timestamp": Time.get_unix_time_from_system(),
		"date": Time.get_datetime_string_from_system(),
		"game_version": ProjectSettings.get_setting("application/config/version")
	}
	
	# Salva o arquivo
	var file = FileAccess.open(file_path, FileAccess.WRITE)
	if file == null:
		push_error("Failed to open file for writing: " + file_path)
		return false
	
	var json_string = JSON.stringify(save_data, "\t")
	file.store_string(json_string)
	file.close()
	
	print("Game saved to slot ", slot)
	save_completed.emit(slot)
	return true


func load_game(slot: int) -> Dictionary:
	if slot < 0 or slot >= MAX_SAVE_SLOTS:
		push_error("Invalid save slot: " + str(slot))
		return {}
	
	var file_path = get_save_file_path(slot)
	
	if not FileAccess.file_exists(file_path):
		print("Save file does not exist: ", file_path)
		return {}
	
	var file = FileAccess.open(file_path, FileAccess.READ)
	if file == null:
		push_error("Failed to open file for reading: " + file_path)
		return {}
	
	var json_string = file.get_as_text()
	file.close()
	
	var json = JSON.new()
	var parse_result = json.parse(json_string)
	
	if parse_result != OK:
		push_error("Failed to parse save file: " + file_path)
		return {}
	
	var save_data = json.data
	print("Game loaded from slot ", slot)
	load_completed.emit(slot)
	return save_data


func slot_has_save(slot: int) -> bool:
	if slot < 0 or slot >= MAX_SAVE_SLOTS:
		return false
	return FileAccess.file_exists(get_save_file_path(slot))


func get_slot_info(slot: int) -> Dictionary:
	if not slot_has_save(slot):
		return {}
	
	var save_data = load_game(slot)
	if save_data.is_empty():
		return {}
	
	return save_data.get("metadata", {})


func delete_save(slot: int) -> bool:
	if slot < 0 or slot >= MAX_SAVE_SLOTS:
		push_error("Invalid save slot: " + str(slot))
		return false
	
	var file_path = get_save_file_path(slot)
	
	if not FileAccess.file_exists(file_path):
		print("Save file does not exist: ", file_path)
		return false
	
	var dir = DirAccess.open(SAVE_DIR)
	var error = dir.remove(SAVE_FILE_PREFIX + str(slot) + SAVE_FILE_EXTENSION)
	
	if error != OK:
		push_error("Failed to delete save file: " + file_path)
		return false
	
	print("Save deleted from slot ", slot)
	save_deleted.emit(slot)
	return true


func get_all_saves() -> Array:
	var saves = []
	for i in range(MAX_SAVE_SLOTS):
		var info = {
			"slot": i,
			"exists": slot_has_save(i),
			"metadata": get_slot_info(i)
		}
		saves.append(info)
	return saves


# Função helper para criar um save de exemplo
func create_example_save_data() -> Dictionary:
	return {
		"player": {
			"name": "Player",
			"level": 1,
			"position": {"x": 0, "y": 0}
		},
		"world": {
			"current_scene": "res://scenes/game/game_scene.tscn"
		},
		"settings": GameSettings.get_language()
	}
