@tool
extends Control
class_name DialogueWindow

## Janela de diálogo com avatar animado do personagem
## Aceita spritesheet como parâmetro externo e gerencia diálogos

signal dialogue_finished
signal dialogue_advanced
signal all_dialogues_completed  ## Emitido quando toda a conversa termina
signal choice_selected(choice: DialogueChoice)  ## Quando usuário escolhe

@export_group("Avatar Settings")
@export var avatar_background: Texture2D ## Background padrão do avatar
@export var avatar_size: Vector2 = Vector2(128, 128) ## Tamanho global dos avatares

@export_group("Dialogue Settings")
@export var dialogue_lines: Array[DialogueLine] = []: ## Lista de linhas de diálogo
	set(value):
		dialogue_lines = value
		if is_inside_tree():
			call_deferred("_update_dialogue_text")

@export var text_speed: float = 0.05 ## Velocidade de digitação (segundos por caractere)
@export var line_advance_delay: float = 3.0 ## Delay em segundos antes de avançar para próxima linha
@export var auto_advance: bool = false ## Avança automaticamente após terminar todas as linhas
@export var auto_advance_delay: float = 2.0 ## Delay antes de avançar automaticamente após última linha
@export var enable_manual_advance: bool = true ## Permite avançar manualmente pressionando botão

@export_group("Window Style")
@export var window_theme: Theme

@export_group("Animation Settings")
@export var start_delay: float = 0.0 ## Delay em segundos antes de iniciar o diálogo
@export var fade_in_duration: float = 0.6 ## Duração do fade in ao aparecer (em segundos)
@export var fade_out_duration: float = 0.3 ## Duração do fade out ao esconder (em segundos)
@export var enable_fade_in: bool = true ## Ativa/desativa o fade in inicial
@export var enable_fade_out: bool = true ## Ativa/desativa o fade out ao esconder

@onready var avatar_container: PanelContainer = %AvatarContainer
@onready var avatar_sprite: AnimatedSprite2D = %AvatarSprite
@onready var name_label: Label = %NameLabel
@onready var text_label: RichTextLabel = %TextLabel
@onready var panel: Panel = %Panel
@onready var avatar_background_texture_rect: TextureRect = %AvatarBackground
@onready var audio_player: AudioStreamPlayer = %AudioPlayer
@onready var choices_container: VBoxContainer = %ChoicesContainer
@onready var nationality_icon: Node = %NationalityBoxContainer
@onready var bilingual_box: Node = %BilingualBoxContainer
@onready var conversation_box: Node = %ConversationBoxContainer

# Temas para diferentes idiomas
var japanese_theme: Theme
var default_theme: Theme

# Variáveis internas de controle do avatar (configuradas dinamicamente por Character/DialogueLine)
var avatar_spritesheet: SpriteFrames
var animation_name: String = "default"
var avatar_position: int = 0
var play_animation: bool = true

var is_typing: bool = false
var current_char_index: int = 0
var typing_timer: float = 0.0
var full_text: String = ""
var audio_sync_mode: bool = false  ## Se true, usa sincronização com áudio
var audio_duration: float = 0.0  ## Duração total do áudio
var elapsed_time: float = 0.0  ## Tempo decorrido desde o início da digitação
var current_dialogue_index: int = 0 ## Índice da linha atual
var current_sequence_index: int = 0 ## Índice da sequência atual (japonês/tradução)
var current_line: DialogueLine ## Linha de diálogo atual
var current_sequence: Array[Dictionary] = [] ## Sequência de exibição atual
var initial_visible_position: float = 0.0 ## Posição Y inicial da janela
var can_advance: bool = true ## Flag para controlar se pode avançar o diálogo
var waiting_for_advance: bool = false ## Flag para indicar que está aguardando o usuário avançar
var waiting_for_choice: bool = false ## Flag para indicar que está aguardando escolha
var selected_choice: DialogueChoice = null ## Escolha selecionada pelo usuário
var dialogue_completed: bool = false ## Flag para indicar que todos os diálogos terminaram
var is_fading_out: bool = false ## Flag para indicar que está fazendo fade out
var dialogue_started: bool = false ## Flag para indicar que o diálogo foi iniciado


func _ready():
	japanese_theme = load("res://assets/themes/dialogue_window_japanese.tres")
	default_theme = window_theme if window_theme else load("res://assets/themes/dialogue_window.tres")
	
	if panel and window_theme:
		panel.theme = window_theme
	
	# Armazena a posição inicial da janela
	initial_visible_position = global_position.y
	
	# Configura o text_label
	if text_label:
		text_label.mouse_filter = Control.MOUSE_FILTER_IGNORE
		text_label.get_v_scroll_bar().visible = false
		text_label.scroll_active = false
		text_label.bbcode_enabled = true  # Habilita BBCode para quebras de linha
	
	_update_avatar_size()
	_update_avatar_background()
	
	if not Engine.is_editor_hint():
		# Inicia invisível se houver delay ou diálogos configurados
		if start_delay > 0 or dialogue_lines.size() > 0:
			visible = false
		
		# Aguarda o delay configurado antes de iniciar
		if start_delay > 0:
			await get_tree().create_timer(start_delay).timeout
		
		# Torna visível e inicia os diálogos
		if dialogue_lines.size() > 0:
			visible = true
			dialogue_started = true
			
			# Aplica fade in inicial se ativado
			if enable_fade_in:
				modulate.a = 0.0
				_fade_in()
			
			current_dialogue_index = 0
			_start_dialogue_line(dialogue_lines[current_dialogue_index])


func _process(delta):
	if not Engine.is_editor_hint():
		# Efeito de digitação
		if is_typing:
			_type_text(delta)
		
		# Verifica se houve scroll na tela e esconde a janela
		_check_scroll_visibility()


func _input(event):
	if Engine.is_editor_hint() or not enable_manual_advance or not can_advance:
		return
	
	# Obtém a tecla configurada para avançar o diálogo
	var advance_key_string = GameSettings.get_key_binding("dialogue_advance")
	if advance_key_string == "":
		advance_key_string = "X"  # Fallback para X se não estiver configurado
	
	# Verifica se a tecla de avançar foi pressionada (configurada ou Enter)
	if event is InputEventKey and event.pressed and not event.echo:
		var key_string = OS.get_keycode_string(event.keycode)
		# Aceita tanto a tecla configurada quanto Enter
		if key_string == advance_key_string or event.keycode == KEY_ENTER or event.keycode == KEY_KP_ENTER:
			if is_typing:
				# Se está digitando, pula a digitação
				skip_typing()
				# Bloqueia avanço temporariamente
				can_advance = false
				await get_tree().create_timer(0.2).timeout
				can_advance = true
			elif waiting_for_advance:
				# Se está aguardando, desbloqueia para continuar
				waiting_for_advance = false
				can_advance = false
				await get_tree().create_timer(0.2).timeout
				can_advance = true
			elif not is_typing and dialogue_lines.size() > 0:
				# Se terminou de digitar, avança para próxima linha
				if has_next_dialogue():
					next_dialogue()
			else:
				# Se era a última linha, esconde a janela e emite sinal
				dialogue_completed = true
				await _fade_out()
				all_dialogues_completed.emit()
				dialogue_advanced.emit()
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


func _update_avatar_position():
	"""Atualiza a posição do avatar (esquerda ou direita)"""
	if not avatar_container or not text_label:
		return
	
	var hbox_panel = avatar_container.get_parent()
	if not hbox_panel or not hbox_panel is HBoxContainer:
		return
	
	# Move o avatar para a posição correta no HBox do painel
	if avatar_position == 0:  # Esquerda
		hbox_panel.move_child(avatar_container, 0)
	else:  # Direita
		hbox_panel.move_child(avatar_container, hbox_panel.get_child_count() - 1)
	
	# Move e alinha o NameLabel no HBox do nome
	if name_label:
		var hbox_name = name_label.get_parent()
		if hbox_name and hbox_name is HBoxContainer:
			# Tenta encontrar o InfoPanel e InfoHBoxContainer
			var info_panel = hbox_name.get_node_or_null("InfoPanel")
			var info_hbox = null
			if info_panel:
				info_hbox = info_panel.get_node_or_null("InfoHBoxContainer")
			
			if avatar_position == 0:  # Esquerda
				hbox_name.alignment = BoxContainer.ALIGNMENT_BEGIN
				name_label.size_flags_horizontal = Control.SIZE_SHRINK_BEGIN
				name_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_LEFT
				
				# Reordena para [NameLabel, InfoPanel]
				hbox_name.move_child(name_label, 0)
				if info_panel:
					hbox_name.move_child(info_panel, 1)
				
				# Alinha InfoHBoxContainer à esquerda
				if info_hbox:
					info_hbox.alignment = BoxContainer.ALIGNMENT_BEGIN
					
			else:  # Direita
				hbox_name.alignment = BoxContainer.ALIGNMENT_END
				name_label.size_flags_horizontal = Control.SIZE_SHRINK_END
				name_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_RIGHT
				
				# Reordena para [InfoPanel, NameLabel]
				if info_panel:
					hbox_name.move_child(info_panel, 0)
				hbox_name.move_child(name_label, hbox_name.get_child_count() - 1)
				
				# Alinha InfoHBoxContainer à direita
				if info_hbox:
					info_hbox.alignment = BoxContainer.ALIGNMENT_END


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
	
	# Atualiza todas as configurações do personagem usando Character resource
	if line.character:
		avatar_spritesheet = line.character.avatar_spritesheet
		animation_name = line.character_avatar_animation
		play_animation = line.character.play_animation
		
		# Atualiza background do personagem se definido (sobrescreve o padrão)
		if line.character.avatar_background:
			avatar_background = line.character.avatar_background
		
		# Atualiza posição do avatar
		avatar_position = line.character.avatar_position
		
		# Atualiza a bandeira de nacionalidade
		if nationality_icon:
			var flag_path = Nationality.get_flag_path(line.character.nationality)
			var flag_texture = load(flag_path)
			if flag_texture:
				nationality_icon.icon_texture = flag_texture
		
		# Atualiza o ícone do nível nativo no ConversationBoxContainer
		if conversation_box:
			var level_texture = NativeLevel.get_book_icon_texture(line.character.native_level)
			if level_texture:
				conversation_box.icon_texture = level_texture
		
		# Aplica o tema de texto do personagem se disponível
		if line.character.text_theme and text_label:
			text_label.theme = line.character.text_theme
		elif text_label and default_theme:
			text_label.theme = default_theme
		
		# Aplica as mudanças
		_setup_avatar()
		_update_avatar_background()
		_update_avatar_position()
	
	# Esconde bilingual_box se o personagem não é bilíngue ou não há character
	# Se bilíngue, mostra bilingual_box e esconde conversation_box
	# Se não bilíngue, mostra conversation_box e esconde bilingual_box
	if bilingual_box and conversation_box:
		if line.character and line.character.is_bilingual:
			bilingual_box.visible = true
			conversation_box.visible = false
		else:
			bilingual_box.visible = false
			conversation_box.visible = true
	
	# Atualiza nome do personagem
	if name_label and line.character:
		name_label.text = line.character.character_name
	
	# Toca animação inicial (start) se existir, depois vai para default
	if avatar_sprite and avatar_sprite.sprite_frames:
		if avatar_sprite.sprite_frames.has_animation("start"):
			avatar_sprite.play("start")
			# Aguarda a animação "start" terminar, depois vai para default
			await avatar_sprite.animation_finished
			if avatar_sprite.sprite_frames.has_animation("default"):
				avatar_sprite.play("default")
		elif avatar_sprite.sprite_frames.has_animation("default"):
			avatar_sprite.play("default")
	
	# Inicia a primeira sequência
	if current_sequence.size() > 0:
		_display_sequence(current_sequence[current_sequence_index])


func _display_sequence(sequence_data: Dictionary):
	"""Exibe uma sequência (japonês ou tradução)"""
	var text: String = sequence_data.get("text", "")
	
	# Verifica se o texto contém caracteres japoneses e ajusta o tema
	if _is_japanese_text(text):
		if text_label and japanese_theme:
			text_label.theme = japanese_theme
	else:
		if text_label and default_theme:
			text_label.theme = default_theme
		
	# Inicia a animação do avatar ao começar a exibir o texto
	# Tenta usar a animação "talk", se não existir, usa a animação padrão
	if avatar_sprite and play_animation:
		if avatar_sprite.sprite_frames and avatar_sprite.sprite_frames.has_animation("talk"):
			avatar_sprite.play("talk")
		else:
			avatar_sprite.play()
	
	# Toca o áudio se disponível e calcula a velocidade de digitação
	var audio: AudioStream = sequence_data.get("audio", null)
	if audio:
		# Calcula a velocidade de digitação baseada na duração do áudio
		_display_text_with_audio(text, audio)
	else:
		# Usa a velocidade padrão se não houver áudio
		_display_text(text)

func _display_text(text: String):
	"""Inicia a exibição do texto com efeito de digitação"""
	# Habilita BBCode no RichTextLabel para suportar quebras de linha
	if text_label:
		text_label.bbcode_enabled = true
		# Converte \n para [br] que é o formato de quebra de linha do RichTextLabel
		full_text = text.replace("\n", "[br]")
	else:
		full_text = text
	
	# Desativa modo de sincronização com áudio
	audio_sync_mode = false
	
	current_char_index = 0
	is_typing = true
	typing_timer = 0.0
	text_label.text = ""


func _display_text_with_audio(text: String, audio: AudioStream):
	"""Inicia a exibição do texto sincronizado com o áudio"""
	# Habilita BBCode no RichTextLabel para suportar quebras de linha
	if text_label:
		text_label.bbcode_enabled = true
		# Converte \n para [br] que é o formato de quebra de linha do RichTextLabel
		full_text = text.replace("\n", "[br]")
	else:
		full_text = text
	
	# Ativa modo de sincronização com áudio
	audio_sync_mode = true
	audio_duration = audio.get_length()
	elapsed_time = 0.0
	
	# Inicia a digitação
	current_char_index = 0
	is_typing = true
	typing_timer = 0.0
	text_label.text = ""
	
	# Toca o áudio
	if audio_player:
		audio_player.stream = audio
		audio_player.play()


func _count_visible_characters(text: String) -> int:
	"""Conta o número de caracteres visíveis (excluindo tags BBCode)"""
	var count = 0
	var i = 0
	var in_tag = false
	
	while i < text.length():
		var current_char = text[i]
		
		if current_char == '[':
			in_tag = true
		elif current_char == ']':
			in_tag = false
		elif not in_tag:
			count += 1
		
		i += 1
	
	return count


func _type_text(delta):
	"""Processa o efeito de digitação"""
	if audio_sync_mode and audio_duration > 0:
		# Modo de sincronização com áudio: calcula posição baseado no tempo
		elapsed_time += delta
		
		# Calcula qual caractere deveria estar visível baseado no tempo decorrido
		var progress = clamp(elapsed_time / audio_duration, 0.0, 1.0)
		var target_char_index = int(progress * full_text.length())
		
		# Atualiza o texto se mudou o índice
		if target_char_index != current_char_index:
			current_char_index = target_char_index
			
			# Garante que não corta no meio de uma tag BBCode
			# Se estamos no meio de uma tag, avança até o final dela
			var check_pos = current_char_index - 1
			while check_pos >= 0:
				if full_text[check_pos] == '[':
					# Encontrou início de tag, precisa incluir até o final
					var tag_end = full_text.find(']', check_pos)
					if tag_end != -1 and tag_end >= current_char_index:
						# Estamos no meio da tag, avança até o final
						current_char_index = tag_end + 1
					break
				elif full_text[check_pos] == ']':
					# Já passou de uma tag completa, está ok
					break
				check_pos -= 1
			
			text_label.text = full_text.substr(0, current_char_index)
			
			# Auto-scroll quando criar uma linha nova
			if text_label.get_v_scroll_bar():
				text_label.get_v_scroll_bar().value = text_label.get_v_scroll_bar().max_value
		
		# Verifica se terminou
		if current_char_index >= full_text.length():
			is_typing = false
			audio_sync_mode = false
			# Volta para a animação default quando o texto termina
			if avatar_sprite and avatar_sprite.sprite_frames:
				if avatar_sprite.sprite_frames.has_animation("default"):
					avatar_sprite.play("default")
				else:
					avatar_sprite.play()
			dialogue_finished.emit()
			_handle_dialogue_advance()
	else:
		# Modo normal: usa velocidade de digitação por caractere
		typing_timer += delta
		
		if typing_timer >= text_speed:
			typing_timer = 0.0
			
			if current_char_index < full_text.length():
				current_char_index += 1
				
				# Pula tags BBCode para não exibi-las caractere por caractere
				# Se encontrar [br], pula os 4 caracteres de uma vez
				while current_char_index < full_text.length() and full_text[current_char_index - 1] == '[':
					# Procura o final da tag
					var tag_end = full_text.find(']', current_char_index - 1)
					if tag_end != -1:
						current_char_index = tag_end + 1
					else:
						break
				
				text_label.text = full_text.substr(0, current_char_index)
				
				# Auto-scroll quando criar uma linha nova
				if text_label.get_v_scroll_bar():
					text_label.get_v_scroll_bar().value = text_label.get_v_scroll_bar().max_value
			else:
				is_typing = false
				# Volta para a animação default quando o texto termina
				if avatar_sprite and avatar_sprite.sprite_frames:
					if avatar_sprite.sprite_frames.has_animation("default"):
						avatar_sprite.play("default")
					else:
						avatar_sprite.play()
				dialogue_finished.emit()
				_handle_dialogue_advance()


func _handle_dialogue_advance():
	"""Gerencia o avanço do diálogo após completar a digitação"""
	# Aguarda o usuário pressionar para avançar
	waiting_for_advance = true
	can_advance = false
	await get_tree().create_timer(0.2).timeout
	can_advance = true
	
	# Aguarda até que waiting_for_advance seja false (usuário pressionou a tecla)
	while waiting_for_advance:
		await get_tree().process_frame
	
	# Verifica se há mais sequências na mesma linha (japonês -> tradução)
	if current_sequence_index < current_sequence.size() - 1:
		current_sequence_index += 1
		_display_sequence(current_sequence[current_sequence_index])
	# Verifica se a linha atual tem escolhas
	elif current_line and current_line.choice_type != 0 and current_line.choices.size() > 0:
		_show_choices()
		
		# Aguarda até que uma escolha seja feita
		waiting_for_choice = true
		while waiting_for_choice:
			await get_tree().process_frame
		
		# Processa a escolha selecionada
		if selected_choice:
			_process_choice(selected_choice)
	# Avança para a próxima linha se houver
	elif has_next_dialogue():
		next_dialogue()
	else:
		# Último diálogo - esconde a janela e emite sinal
		dialogue_completed = true
		await _fade_out()
		all_dialogues_completed.emit()
		if auto_advance:
			dialogue_advanced.emit()


func skip_typing():
	"""Pula o efeito de digitação e mostra o texto completo"""
	if is_typing:
		is_typing = false
		audio_sync_mode = false
		current_char_index = full_text.length()
		text_label.text = full_text
		
		# Para o áudio se estiver tocando
		if audio_player and audio_player.playing:
			audio_player.stop()
		
		# Volta para a animação default quando pula o texto
		if avatar_sprite and avatar_sprite.sprite_frames:
			if avatar_sprite.sprite_frames.has_animation("default"):
				avatar_sprite.play("default")
			else:
				avatar_sprite.play()
		
		dialogue_finished.emit()
		
		# Ativa a lógica de avanço após completar
		_handle_dialogue_advance()


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
	dialogue_completed = false
	visible = true


func set_dialogue_single(line: DialogueLine):
	"""Define uma única linha de diálogo"""
	dialogue_lines = [line]
	current_dialogue_index = 0
	current_sequence_index = 0
	dialogue_completed = false
	visible = true


func set_avatar(spriteframes: SpriteFrames, anim_name: String = "default", avatar_custom_size: Vector2 = Vector2(76, 76)):
	"""Define o avatar do personagem usando SpriteFrames"""
	avatar_spritesheet = spriteframes
	animation_name = anim_name
	avatar_size = avatar_custom_size


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


func _is_japanese_text(text: String) -> bool:
	"""Verifica se o texto contém caracteres japoneses (Hiragana, Katakana ou Kanji)"""
	for i in range(text.length()):
		var char_code = text.unicode_at(i)
		# Hiragana: 0x3040-0x309F
		# Katakana: 0x30A0-0x30FF
		# Kanji: 0x4E00-0x9FFF
		# Full-width characters: 0xFF00-0xFFEF
		if (char_code >= 0x3040 and char_code <= 0x309F) or \
		   (char_code >= 0x30A0 and char_code <= 0x30FF) or \
		   (char_code >= 0x4E00 and char_code <= 0x9FFF) or \
		   (char_code >= 0xFF00 and char_code <= 0xFFEF):
			return true
	return false


func _check_scroll_visibility():
	"""Verifica se houve scroll e esconde a janela se necessário"""
	# Não mostra a janela se o diálogo foi completado, está fazendo fade out, ou ainda não iniciou
	if dialogue_completed or is_fading_out or not dialogue_started:
		return
	
	var current_y = global_position.y
	var scroll_threshold = 50.0  # Threshold em pixels para considerar scroll
	
	if abs(current_y - initial_visible_position) > scroll_threshold:
		visible = false
	else:
		visible = true


func _show_choices():
	"""Mostra as opções de escolha ao usuário"""
	if not choices_container or not current_line:
		return
	
	# Limpa escolhas anteriores
	for child in choices_container.get_children():
		child.queue_free()
	
	# Esconde o painel de diálogo e mostra o container de escolhas
	if panel:
		panel.visible = false
	choices_container.visible = true
	
	# Cria botões para cada escolha
	for choice in current_line.choices:
		var button = Button.new()
		button.text = choice.choice_text
		button.pressed.connect(_on_choice_button_pressed.bind(choice))
		choices_container.add_child(button)


func _on_choice_button_pressed(choice):
	"""Callback quando um botão de escolha é pressionado"""
	selected_choice = choice
	waiting_for_choice = false
	
	# Esconde as escolhas e mostra o painel novamente
	choices_container.visible = false
	if panel:
		panel.visible = true


func _process_choice(choice):
	"""Processa a escolha selecionada"""
	# Emite sinal para quem quiser escutar
	choice_selected.emit(choice)
	
	# Se tem índice de próximo diálogo, redireciona
	if choice.next_dialogue_index >= 0 and choice.next_dialogue_index < dialogue_lines.size():
		current_dialogue_index = choice.next_dialogue_index
		current_sequence_index = 0
		_start_dialogue_line(dialogue_lines[current_dialogue_index])
	# Senão, continua sequencialmente
	elif has_next_dialogue():
		next_dialogue()
	else:
		# Último diálogo - esconde a janela e emite sinal
		dialogue_completed = true
		await _fade_out()
		all_dialogues_completed.emit()
		dialogue_advanced.emit()


func _fade_in():
	"""Aplica o efeito de fade in na janela"""
	var tween = create_tween()
	tween.tween_property(self, "modulate:a", 1.0, fade_in_duration).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_OUT)


func _fade_out():
	"""Aplica o efeito de fade out antes de esconder a janela"""
	is_fading_out = true
	if enable_fade_out:
		var tween = create_tween()
		tween.tween_property(self, "modulate:a", 0.0, fade_out_duration).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN)
		await tween.finished
	visible = false
	is_fading_out = false
	# Restaura o alpha para o próximo uso
	modulate.a = 1.0


func _on_all_dialogues_completed() -> void:
	pass # Replace with function body.
