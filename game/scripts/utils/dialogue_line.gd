extends Resource
class_name DialogueLine

## Representa uma linha de diálogo com suporte a múltiplos idiomas e áudio

enum DisplayMode {
	JAPANESE_ONLY,           ## Mostra apenas japonês
	TRANSLATED_ONLY,         ## Mostra apenas a tradução
	JAPANESE_THEN_TRANSLATED ## Mostra japonês primeiro, depois a tradução
}

@export_group("Text Content")
@export var use_translation_key: bool = false  ## Se true, usa chave de tradução; se false, usa texto literal

@export var japanese_text: String = ""  ## Texto em japonês (literal ou chave de tradução)
@export var translated_text: String = ""  ## Texto traduzido (literal ou chave de tradução)

@export_group("Audio")
@export var japanese_audio: AudioStream  ## Áudio da fala em japonês
@export var translated_audio: AudioStream  ## Áudio da fala traduzida

@export_group("Display Settings")
@export var display_mode: DisplayMode = DisplayMode.JAPANESE_THEN_TRANSLATED  ## Modo de exibição
@export var delay_between_languages: float = 1.5  ## Delay entre japonês e tradução (se aplicável)

@export_group("Character")
@export var character_name: String = ""  ## Nome do personagem falando
@export var character_avatar: SpriteFrames  ## Avatar do personagem
@export var character_avatar_animation: String = "default"  ## Animação do avatar


func get_japanese_text() -> String:
	"""Retorna o texto em japonês (traduzido se for chave)"""
	if use_translation_key and japanese_text:
		return tr(japanese_text)
	return japanese_text


func get_translated_text() -> String:
	"""Retorna o texto traduzido (traduzido se for chave)"""
	if use_translation_key and translated_text:
		return tr(translated_text)
	return translated_text


func has_japanese() -> bool:
	"""Verifica se tem texto em japonês"""
	return japanese_text != ""


func has_translation() -> bool:
	"""Verifica se tem texto traduzido"""
	return translated_text != ""


func should_play_japanese() -> bool:
	"""Verifica se deve exibir/tocar o japonês"""
	return has_japanese() and (display_mode == DisplayMode.JAPANESE_ONLY or display_mode == DisplayMode.JAPANESE_THEN_TRANSLATED)


func should_play_translation() -> bool:
	"""Verifica se deve exibir/tocar a tradução"""
	return has_translation() and (display_mode == DisplayMode.TRANSLATED_ONLY or display_mode == DisplayMode.JAPANESE_THEN_TRANSLATED)


func get_display_sequence() -> Array[Dictionary]:
	"""Retorna a sequência de exibição do diálogo
	Cada item do array contém: {text: String, audio: AudioStream, is_japanese: bool}"""
	var sequence: Array[Dictionary] = []
	
	match display_mode:
		DisplayMode.JAPANESE_ONLY:
			if has_japanese():
				sequence.append({
					"text": get_japanese_text(),
					"audio": japanese_audio,
					"is_japanese": true
				})
		
		DisplayMode.TRANSLATED_ONLY:
			if has_translation():
				sequence.append({
					"text": get_translated_text(),
					"audio": translated_audio,
					"is_japanese": false
				})
		
		DisplayMode.JAPANESE_THEN_TRANSLATED:
			if has_japanese():
				sequence.append({
					"text": get_japanese_text(),
					"audio": japanese_audio,
					"is_japanese": true
				})
			if has_translation():
				sequence.append({
					"text": get_translated_text(),
					"audio": translated_audio,
					"is_japanese": false
				})
	
	return sequence
