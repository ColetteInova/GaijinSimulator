@tool
extends Control
class_name DialogueWindow

## Janela de diálogo com avatar animado do personagem
## Aceita spritesheet como parâmetro externo e gerencia diálogos

signal dialogue_finished
signal dialogue_advanced

@export_group("Avatar Settings")
@export var avatar_background: Texture2D: ## Imagem de fundo do avatar
	set(value):
		avatar_background = value
		if is_inside_tree():
			call_deferred("_update_avatar_background")

@export var avatar_spritesheet: SpriteFrames:
	set(value):
		avatar_spritesheet = value
		if is_inside_tree():
			call_deferred("_setup_avatar")

@export var animation_name: String = "default": ## Nome da animação do SpriteFrames
	set(value):
		animation_name = value
		if is_inside_tree():
			call_deferred("_setup_avatar")

@export var play_animation: bool = true ## Se true, toca a animação do avatar

@export var avatar_size: Vector2 = Vector2(128, 128): ## Tamanho do avatar em pixels
	set(value):
		avatar_size = value
		if is_inside_tree():
			call_deferred("_update_avatar_size")

@export_group("Dialogue Settings")
@export var dialogue_lines: Array[DialogueLine] = []:  ## Lista de linhas de diálogo
	set(value):
		dialogue_lines = value
		if is_inside_tree():
			call_deferred("_update_dialogue_text")

@export var text_speed: float = 0.05 ## Velocidade de digitação (segundos por caractere)
@export var line_advance_delay: float = 3.0 ## Delay em segundos antes de avançar para próxima linha
@export var auto_advance: bool = false ## Avança automaticamente após terminar todas as linhas
@export var auto_advance_delay: float = 2.0 ## Delay antes de avançar automaticamente após última linha

@export_group("Window Style")
@export var window_theme: Theme

@onready var avatar_container: PanelContainer = %AvatarContainer
@onready var avatar_sprite: AnimatedSprite2D = %AvatarSprite
@onready var name_label: Label = %NameLabel
@onready var text_label: RichTextLabel = %TextLabel
@onready var panel: Panel = %Panel
@onready var avatar_background_texture_rect: TextureRect = %AvatarBackground
@onready var audio_player: AudioStreamPlayer = %AudioPlayer

var is_typing: bool = false
var current_char_index: int = 0
var typing_timer: float = 0.0
var full_text: String = ""
var current_dialogue_index: int = 0  ## Índice da linha atual
var current_sequence_index: int = 0  ## Índice da sequência atual (japonês/tradução)
var current_line: DialogueLine  ## Linha de diálogo atual
var current_sequence: Array[Dictionary] = []  ## Sequência de exibição atual


func _ready():
	if panel and window_theme:
		panel.theme = window_theme
	
	_update_avatar_size()
	_update_avatar_background()
	_setup_avatar()
	
	if not Engine.is_editor_hint():
		if dialogue_lines.size() > 0:
			current_dialogue_index = 0
			_start_dialogue_line(dialogue_lines[current_dialogue_index])


func _process(delta):
	if not Engine.is_editor_hint():
		# Efeito de digitação
		if is_typing:
			_type_text(delta)


func _setup_avatar():
	"""Configura o sprite do avatar com o SpriteFrames"""
	if not avatar_sprite or not avatar_spritesheet:
		return
	
	avatar_sprite.sprite_frames = avatar_spritesheet
	
	# Verifica se a animação existe no SpriteFrames
	if avatar_spritesheet.has_animation(animation_name):
		avatar_sprite.animation = animation_name
	else:
		# Usa a primeira animação disponível
		var animations = avatar_spritesheet.get_animation_names()
		if animations.size() > 0:
			avatar_sprite.animation = animations[0]
	
	# Ajusta a escala do sprite para caber no container
	_scale_avatar_sprite()
	
	if play_animation:
		avatar_sprite.play()


func _scale_avatar_sprite():
	"""Ajusta a escala do sprite para caber no tamanho do avatar"""
	if not avatar_sprite or not avatar_sprite.sprite_frames:
		return
	
	# Pega o tamanho real do frame atual
	var current_anim = avatar_sprite.animation
	if not avatar_sprite.sprite_frames.has_animation(current_anim):
		return
	
	var frame_count = avatar_sprite.sprite_frames.get_frame_count(current_anim)
	if frame_count == 0:
		return
	
	var frame_texture = avatar_sprite.sprite_frames.get_frame_texture(current_anim, 0)
	if not frame_texture:
		return
	
	var texture_size = frame_texture.get_size()
	
	# Calcula a escala necessária para caber no container mantendo proporção
	var scale_x = avatar_size.x / texture_size.x
	var scale_y = avatar_size.y / texture_size.y
	var final_scale = min(scale_x, scale_y)
	
	avatar_sprite.scale = Vector2(final_scale, final_scale)


func _update_avatar_size():
	"""Atualiza o tamanho do container do avatar"""
	if avatar_container:
		avatar_container.custom_minimum_size = avatar_size
		# Centraliza o sprite no container
		if avatar_sprite:
			avatar_sprite.position = avatar_size / 2
			_scale_avatar_sprite()
		# Atualiza o tamanho do background
		if avatar_background_texture_rect:
			avatar_background_texture_rect.custom_minimum_size = avatar_size
			avatar_background_texture_rect.size = avatar_size

func _update_avatar_background():
	"""Atualiza a imagem de fundo do avatar"""
	if avatar_background_texture_rect:
		avatar_background_texture_rect.texture = avatar_background
		# Garante que o fundo preencha todo o container
		avatar_background_texture_rect.custom_minimum_size = avatar_size
		avatar_background_texture_rect.size = avatar_size


func _update_character_name():
	"""Atualiza o nome do personagem"""
	if name_label and current_line:
		name_label.text = current_line.character_name


func _update_dialogue_text():
	"""Atualiza o texto do diálogo"""
	if dialogue_lines.size() > 0:
		current_dialogue_index = 0
		_start_dialogue_line(dialogue_lines[current_dialogue_index])


func _start_dialogue_line(line: DialogueLine):
	"""Inicia uma nova linha de diálogo"""
	if not line:
		return
	
	current_line = line
	current_sequence = line.get_display_sequence()
	current_sequence_index = 0
	
	# Atualiza avatar se a linha tem um definido
	if line.character_avatar:
		avatar_spritesheet = line.character_avatar
		animation_name = line.character_avatar_animation
		_setup_avatar()
	
	# Atualiza nome do personagem
	if name_label:
		name_label.text = line.character_name
	
	# Inicia a primeira sequência
	if current_sequence.size() > 0:
		_display_sequence(current_sequence[current_sequence_index])


func _display_sequence(sequence_data: Dictionary):
	"""Exibe uma sequência (japonês ou tradução)"""
	_display_text(sequence_data.get("text", ""))
	
	# Toca o áudio se disponível
	var audio: AudioStream = sequence_data.get("audio", null)
	if audio and audio_player:
		audio_player.stream = audio
		audio_player.play()

func _display_text(text: String):
	"""Inicia a exibição do texto com efeito de digitação"""
	full_text = text
	current_char_index = 0
	is_typing = true
	typing_timer = 0.0
	text_label.text = ""


func _type_text(delta):
	"""Processa o efeito de digitação"""
	typing_timer += delta
	
	if typing_timer >= text_speed:
		typing_timer = 0.0
		
		if current_char_index < full_text.length():
			current_char_index += 1
			text_label.text = full_text.substr(0, current_char_index)
		else:
			is_typing = false
			dialogue_finished.emit()
			
			# Verifica se há mais sequências na mesma linha (japonês -> tradução)
			if current_sequence_index < current_sequence.size() - 1:
				current_sequence_index += 1
				var delay = current_line.delay_between_languages if current_line else 1.5
				await get_tree().create_timer(delay).timeout
				_display_sequence(current_sequence[current_sequence_index])
			# Avança automaticamente para a próxima linha após delay configurável
			elif has_next_dialogue():
				await get_tree().create_timer(line_advance_delay).timeout
				next_dialogue()
			elif auto_advance:
				await get_tree().create_timer(auto_advance_delay).timeout
				dialogue_advanced.emit()


func skip_typing():
	"""Pula o efeito de digitação e mostra o texto completo"""
	if is_typing:
		is_typing = false
		current_char_index = full_text.length()
		text_label.text = full_text
		dialogue_finished.emit()


func next_dialogue() -> bool:
	"""Avança para a próxima frase do diálogo. Retorna true se avançou, false se era a última"""
	if current_dialogue_index < dialogue_lines.size() - 1:
		current_dialogue_index += 1
		current_sequence_index = 0
		_start_dialogue_line(dialogue_lines[current_dialogue_index])
		return true
	return false


func previous_dialogue() -> bool:
	"""Volta para a frase anterior do diálogo. Retorna true se voltou, false se era a primeira"""
	if current_dialogue_index > 0:
		current_dialogue_index -= 1
		current_sequence_index = 0
		_start_dialogue_line(dialogue_lines[current_dialogue_index])
		return true
	return false
	if current_dialogue_index > 0:
		current_dialogue_index -= 1
		current_sequence_index = 0
		_start_dialogue_line(dialogue_lines[current_dialogue_index])
		return true
	return false


func has_next_dialogue() -> bool:
	"""Verifica se há próxima frase"""
	return current_dialogue_index < dialogue_lines.size() - 1


func has_previous_dialogue() -> bool:
	"""Verifica se há frase anterior"""
	return current_dialogue_index > 0


func set_dialogue(lines: Array[DialogueLine]):
	"""Define a lista de linhas de diálogo"""
	dialogue_lines = lines
	current_dialogue_index = 0
	current_sequence_index = 0


func set_dialogue_single(line: DialogueLine):
	"""Define uma única linha de diálogo"""
	dialogue_lines = [line]
	current_dialogue_index = 0
	current_sequence_index = 0


func set_avatar(spriteframes: SpriteFrames, anim_name: String = "default", size: Vector2 = Vector2(128, 128)):
	"""Define o avatar do personagem usando SpriteFrames"""
	avatar_spritesheet = spriteframes
	animation_name = anim_name
	avatar_size = size


func set_avatar_background(background_texture: Texture2D):
	"""Define a imagem de fundo do avatar"""
	avatar_background = background_texture


func play_avatar_animation(anim_name: String = ""):
	"""Toca uma animação específica do avatar"""
	if not avatar_sprite:
		return
	
	if anim_name != "":
		if avatar_sprite.sprite_frames and avatar_sprite.sprite_frames.has_animation(anim_name):
			avatar_sprite.play(anim_name)
	else:
		avatar_sprite.play()


func stop_avatar_animation():
	"""Para a animação do avatar"""
	if avatar_sprite:
		avatar_sprite.stop()
