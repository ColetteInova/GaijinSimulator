extends Resource
class_name DialogueLine

## Representa uma linha de diálogo com suporte a múltiplos idiomas e áudio

enum DisplayMode {
	NATIVE_ONLY,           ## Mostra apenas texto nativo
	TRANSLATED_ONLY,         ## Mostra apenas a tradução
	NATIVE_THEN_TRANSLATED ## Mostra nativo primeiro, depois a tradução
}

@export_group("Text Content")
@export var use_translation_key: bool = false  ## Se true, usa chave de tradução; se false, usa texto literal

@export var native_text: String = ""  ## Texto nativo do personagem (literal ou chave de tradução)
@export var translated_text: String = ""  ## Texto traduzido (literal ou chave de tradução)

@export_group("Audio")
@export var native_audio: AudioStream  ## Áudio da fala nativa
@export var translated_audio: AudioStream  ## Áudio da fala traduzida

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
	"""Retorna o texto nativo (traduzido se for chave)"""
	if use_translation_key and native_text:
		return tr(native_text)
	return native_text


func get_translated_text() -> String:
	"""Retorna o texto traduzido (traduzido se for chave)"""
	if use_translation_key and translated_text:
		return tr(translated_text)
	return translated_text


func has_native() -> bool:
	"""Verifica se tem texto nativo"""
	return native_text != ""


func has_translation() -> bool:
	"""Verifica se tem texto traduzido"""
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
					"audio": native_audio,
					"is_native": true
				})
		
		DisplayMode.TRANSLATED_ONLY:
			if has_translation():
				sequence.append({
					"text": get_translated_text(),
					"audio": translated_audio,
					"is_native": false
				})
		
		DisplayMode.NATIVE_THEN_TRANSLATED:
			if has_native():
				sequence.append({
					"text": get_native_text(),
					"audio": native_audio,
					"is_native": true
				})
			if has_translation():
				sequence.append({
					"text": get_translated_text(),
					"audio": translated_audio,
					"is_native": false
				})
	
	return sequence
