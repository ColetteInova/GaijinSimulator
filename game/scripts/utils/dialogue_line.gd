extends Resource
class_name DialogueLine

## Representa uma linha de diálogo com suporte a múltiplos idiomas e áudio

enum DisplayMode {
	NATIVE_ONLY,           ## Mostra apenas texto nativo
	TRANSLATED_ONLY,         ## Mostra apenas a tradução
	NATIVE_THEN_TRANSLATED ## Mostra nativo primeiro, depois a tradução
}

@export_group("Text Content")
@export var use_csv_file: bool = false  ## Se true, busca mensagens de um arquivo CSV externo
@export_file("*.csv") var csv_file_path: String = ""  ## Caminho para o arquivo CSV com mensagens
@export var message_key: String = ""  ## Chave da mensagem no arquivo CSV (ex: COMISSER_DIALOG1)

@export var native_text: String = ""  ## Texto nativo do personagem
@export var translated_text: String = ""  ## Texto traduzido

@export_group("Audio")
@export_dir var audio_folder_path: String = ""  ## Pasta base com áudios (ex: res://assets/audios/dialogues/character1/)

@export_group("Display Settings")
@export var display_mode: DisplayMode = DisplayMode.NATIVE_THEN_TRANSLATED  ## Modo de exibição
@export var delay_between_languages: float = 1.5  ## Delay entre japonês e tradução (se aplicável)

@export_group("Character")
@export var character: Character  ## Referência ao personagem que fala
@export var character_avatar_animation: String = "default"  ## Animação específica desta linha

@export_group("Choices")
@export_enum("None", "Single", "Multiple") var choice_type: int = 0  ## Tipo de escolha (0=Nenhuma, 1=Única, 2=Múltipla)
@export var choices: Array[DialogueChoice] = []  ## Opções de escolha disponíveis
@export var min_choices: int = 1  ## Mínimo de escolhas (para tipo múltipla)
@export var max_choices: int = 1  ## Máximo de escolhas (para tipo múltipla)


func get_native_text() -> String:
	"""Retorna o texto nativo"""
	if use_csv_file and csv_file_path and message_key:
		return _get_text_from_csv("native")
	return native_text


func get_translated_text() -> String:
	"""Retorna o texto traduzido"""
	if use_csv_file and csv_file_path and message_key:
		# Converte locale (ex: pt_BR) para código curto (ex: br)
		var locale = TranslationServer.get_locale()
		var lang_code = locale.split("_")[0]  # Pega apenas a primeira parte
		# Mapeia pt para br
		if lang_code == "pt":
			lang_code = "br"
		return _get_text_from_csv(lang_code)
	return translated_text


func _get_text_from_csv(column: String) -> String:
	"""Busca o texto da coluna especificada no arquivo CSV usando a message_key"""
	var file = FileAccess.open(csv_file_path, FileAccess.READ)
	if not file:
		push_error("Não foi possível abrir o arquivo CSV: " + csv_file_path)
		return ""
	
	# Lê a primeira linha (cabeçalho)
	var header_line = file.get_csv_line()
	var column_index = -1
	
	# Encontra o índice da coluna desejada (remove espaços)
	for i in range(header_line.size()):
		var header_col = header_line[i].strip_edges().to_lower()
		if header_col == column.to_lower():
			column_index = i
			break
	
	if column_index == -1:
		print("Colunas disponíveis: ", header_line)
		push_error("Coluna '" + column + "' não encontrada no CSV")
		file.close()
		return ""
	
	# Busca a linha com a chave especificada
	while not file.eof_reached():
		var line = file.get_csv_line()
		if line.size() > 0:
			var key = line[0].strip_edges()
			if key == message_key:
				if column_index < line.size():
					var result = line[column_index].strip_edges()
					file.close()
					return result
				break
	
	file.close()
	push_error("Chave '" + message_key + "' não encontrada no CSV")
	return ""


func has_native() -> bool:
	"""Verifica se tem texto nativo"""
	if use_csv_file and csv_file_path and message_key:
		return true
	return native_text != ""


func has_translation() -> bool:
	"""Verifica se tem texto traduzido"""
	if use_csv_file and csv_file_path and message_key:
		return true
	return translated_text != ""


func should_play_native() -> bool:
	"""Verifica se deve exibir/tocar o texto nativo"""
	return has_native() and (display_mode == DisplayMode.NATIVE_ONLY or display_mode == DisplayMode.NATIVE_THEN_TRANSLATED)


func should_play_translation() -> bool:
	"""Verifica se deve exibir/tocar a tradução"""
	return has_translation() and (display_mode == DisplayMode.TRANSLATED_ONLY or display_mode == DisplayMode.NATIVE_THEN_TRANSLATED)


func get_display_sequence() -> Array[Dictionary]:
	"""Retorna a sequência de exibição do diálogo
	Cada item do array contém: {text: String, audio: AudioStream, is_native: bool}"""
	var sequence: Array[Dictionary] = []
	
	match display_mode:
		DisplayMode.NATIVE_ONLY:
			if has_native():
				sequence.append({
					"text": get_native_text(),
					"audio": _get_audio_for_language("native"),
					"is_native": true
				})
		
		DisplayMode.TRANSLATED_ONLY:
			if has_translation():
				var locale = TranslationServer.get_locale()
				var lang_code = locale.split("_")[0]
				if lang_code == "pt":
					lang_code = "br"
				sequence.append({
					"text": get_translated_text(),
					"audio": _get_audio_for_language(lang_code),
					"is_native": false
				})
		
		DisplayMode.NATIVE_THEN_TRANSLATED:
			if has_native():
				sequence.append({
					"text": get_native_text(),
					"audio": _get_audio_for_language("native"),
					"is_native": true
				})
			if has_translation():
				var locale = TranslationServer.get_locale()
				var lang_code = locale.split("_")[0]
				if lang_code == "pt":
					lang_code = "br"
				sequence.append({
					"text": get_translated_text(),
					"audio": _get_audio_for_language(lang_code),
					"is_native": false
				})
	
	return sequence


func _get_audio_for_language(language: String) -> AudioStream:
	"""Carrega o áudio para o idioma especificado baseado na pasta e message_key
	Estrutura esperada: audio_folder_path/native|br|en/message_key.mp3|.ogg|.wav
	"""
	# Se audio_folder_path não estiver definido, retorna null
	if audio_folder_path == "":
		push_warning("audio_folder_path não definido para carregar áudio automaticamente")
		return null
	
	# Se message_key não estiver definida, não há como carregar o áudio
	if message_key == "":
		push_warning("message_key não definida para carregar áudio automaticamente")
		return null
	
	# Garante que o caminho termina com /
	var base_path = audio_folder_path
	if not base_path.ends_with("/"):
		base_path += "/"
	
	# Constrói o caminho: base_path/language/message_key.extensão
	var audio_path_base = base_path + language + "/" + message_key
	
	# Tenta diferentes extensões de áudio
	var extensions = [".mp3", ".ogg", ".wav"]
	for ext in extensions:
		var audio_path = audio_path_base + ext
		if ResourceLoader.exists(audio_path):
			var audio = load(audio_path)
			if audio is AudioStream:
				return audio
	
	# Se não encontrou, retorna null e exibe um aviso
	push_warning("Áudio não encontrado para idioma '" + language + "' com key '" + message_key + "' em: " + audio_path_base)
	return null
