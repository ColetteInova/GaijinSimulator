extends Node

## Gerenciador de período do dia
## Centraliza a lógica de horários e períodos do dia

enum TimeOfDay { MORNING, AFTERNOON, NIGHT }

signal time_of_day_changed(new_time: TimeOfDay)
signal hour_changed(new_hour: int)

var current_hour: int = 8  # Hora atual (0-23)
var current_time_of_day: TimeOfDay = TimeOfDay.MORNING
var use_system_time: bool = false  # Se true, usa hora do sistema ao invés do PlayerData


func _ready():
	# Carrega a hora salva do jogador ou usa hora do sistema
	if use_system_time:
		_sync_with_system_time()
	elif PlayerData:
		_sync_with_player_data()
	else:
		# Fallback para hora do sistema se não tiver PlayerData
		_sync_with_system_time()


func _sync_with_system_time():
	"""Sincroniza com a hora atual do sistema"""
	var time_dict = Time.get_datetime_dict_from_system()
	current_hour = time_dict.hour
	print("DayTimeManager - Hora do sistema: ", current_hour)
	_update_time_of_day_from_hour()


func _sync_with_player_data():
	"""Sincroniza com os dados do PlayerData"""
	var saved_time = PlayerData.get_time_of_day()
	print("DayTimeManager - Tempo salvo no PlayerData: ", saved_time)
	match saved_time:
		"morning":
			current_time_of_day = TimeOfDay.MORNING
			current_hour = 8  # Hora padrão da manhã
		"afternoon":
			current_time_of_day = TimeOfDay.AFTERNOON
			current_hour = 14  # Hora padrão da tarde
		"night":
			current_time_of_day = TimeOfDay.NIGHT
			current_hour = 20  # Hora padrão da noite
		_:
			current_time_of_day = TimeOfDay.MORNING
			current_hour = 8
	print("DayTimeManager - Período configurado: ", get_time_of_day_string(), " Hora: ", current_hour)


func get_time_of_day() -> TimeOfDay:
	"""Retorna o período do dia atual"""
	return current_time_of_day


func get_time_of_day_string() -> String:
	"""Retorna o período do dia como string (morning, afternoon, night)"""
	match current_time_of_day:
		TimeOfDay.MORNING:
			return "morning"
		TimeOfDay.AFTERNOON:
			return "afternoon"
		TimeOfDay.NIGHT:
			return "night"
		_:
			return "morning"


func get_hour() -> int:
	"""Retorna a hora atual (0-23)"""
	return current_hour


func set_hour(hour: int):
	"""Define a hora atual e atualiza o período do dia automaticamente"""
	hour = clampi(hour, 0, 23)
	
	if current_hour != hour:
		current_hour = hour
		hour_changed.emit(hour)
		_update_time_of_day_from_hour()


func _update_time_of_day_from_hour():
	"""Atualiza o período do dia baseado na hora atual"""
	var old_time = current_time_of_day
	
	# 06:01 - 12:00 = Manhã (hora 6-11)
	if current_hour >= 6 and current_hour < 12:
		current_time_of_day = TimeOfDay.MORNING
	# 12:01 - 18:00 = Tarde (hora 12-17)
	elif current_hour >= 12 and current_hour <= 17:
		current_time_of_day = TimeOfDay.AFTERNOON
	# 18:01 - 06:00 = Noite (hora 18-23, 0-5)
	else:
		current_time_of_day = TimeOfDay.NIGHT
	
	# Notifica mudança se houve alteração
	if old_time != current_time_of_day:
		time_of_day_changed.emit(current_time_of_day)
		_save_to_player_data()


func set_time_of_day(time: TimeOfDay):
	"""Define o período do dia manualmente e ajusta a hora"""
	if current_time_of_day != time:
		current_time_of_day = time
		
		# Ajusta a hora para corresponder ao período
		match time:
			TimeOfDay.MORNING:
				current_hour = 8
			TimeOfDay.AFTERNOON:
				current_hour = 14
			TimeOfDay.NIGHT:
				current_hour = 20
		
		time_of_day_changed.emit(time)
		hour_changed.emit(current_hour)
		_save_to_player_data()


func advance_time_period():
	"""Avança para o próximo período do dia"""
	match current_time_of_day:
		TimeOfDay.MORNING:
			set_time_of_day(TimeOfDay.AFTERNOON)
		TimeOfDay.AFTERNOON:
			set_time_of_day(TimeOfDay.NIGHT)
		TimeOfDay.NIGHT:
			set_time_of_day(TimeOfDay.MORNING)
			# Avança o dia quando volta para manhã
			if PlayerData:
				PlayerData.character_data["day"] += 1
				PlayerData.save_data()


func advance_hours(hours: int):
	"""Avança N horas"""
	var new_hour = (current_hour + hours) % 24
	set_hour(new_hour)


func _save_to_player_data():
	"""Salva o período atual no PlayerData"""
	if PlayerData:
		PlayerData.set_time_of_day(get_time_of_day_string())


func get_time_display() -> String:
	"""Retorna uma string formatada para exibição (ex: "08:00")"""
	return "%02d:00" % current_hour


func is_morning() -> bool:
	return current_time_of_day == TimeOfDay.MORNING


func is_afternoon() -> bool:
	return current_time_of_day == TimeOfDay.AFTERNOON


func is_night() -> bool:
	return current_time_of_day == TimeOfDay.NIGHT
