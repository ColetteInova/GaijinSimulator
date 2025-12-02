extends Control
class_name VideoPlaylistPlayer

## Componente reutilizável de VideoPlayer com suporte a playlist.
## Permite reproduzir múltiplos vídeos em sequência com opção de loop no último vídeo.

## Emitido quando um vídeo começa a tocar
signal video_started(index: int, stream: VideoStream)
## Emitido quando um vídeo termina
signal video_finished(index: int, stream: VideoStream)
## Emitido quando a playlist inteira termina (se loop_last estiver desabilitado)
signal playlist_finished
## Emitido quando o loop do último vídeo reinicia
signal last_video_looped
## Emitido quando o vídeo de finalização começa
signal closing_video_started
## Emitido quando o vídeo de finalização termina (fim de tudo)
signal closing_video_finished

## Lista de vídeos da playlist
@export var playlist: Array[VideoStream] = []

## Vídeo de finalização (tocado após chamar finish_and_close())
@export var closing_video: VideoStream = null

## Se verdadeiro, o último vídeo da playlist ficará em loop
@export var loop_last_video: bool = true

## Se verdadeiro, inicia a reprodução automaticamente ao entrar na cena
@export var autoplay: bool = true

## Expande o vídeo para preencher o container
@export var expand_video: bool = true

## Volume do áudio do vídeo (0.0 a 1.0)
@export_range(0.0, 1.0) var volume: float = 1.0:
	set(value):
		volume = value
		if _video_player:
			_video_player.volume_db = linear_to_db(volume)

## Índice do vídeo atual na playlist
var current_index: int = 0

## Referência interna ao VideoStreamPlayer
var _video_player: VideoStreamPlayer

## Flag para controlar se está em loop
var _is_looping: bool = false

## Flag para indicar se está tocando o vídeo de finalização
var _is_playing_closing: bool = false

## Flag para indicar que deve tocar o vídeo de finalização após o loop atual terminar
var _pending_close: bool = false


func _ready() -> void:
	_setup_video_player()
	
	if autoplay and playlist.size() > 0:
		play_playlist()


func _setup_video_player() -> void:
	# Cria o VideoStreamPlayer interno
	_video_player = VideoStreamPlayer.new()
	_video_player.name = "VideoStreamPlayer"
	_video_player.set_anchors_preset(Control.PRESET_FULL_RECT)
	_video_player.expand = expand_video
	_video_player.volume_db = linear_to_db(volume)
	_video_player.loop = false  # Controlamos o loop manualmente, exceto no último vídeo
	
	# Conecta o sinal de término do vídeo
	_video_player.finished.connect(_on_video_finished)
	
	add_child(_video_player)


func _on_video_finished() -> void:
	# Se estava tocando o vídeo de finalização
	if _is_playing_closing:
		_is_playing_closing = false
		closing_video_finished.emit()
		return
	
	var finished_stream = playlist[current_index] if current_index < playlist.size() else null
	video_finished.emit(current_index, finished_stream)
	
	# Verifica se é o último vídeo
	if current_index >= playlist.size() - 1:
		# Se estava aguardando para fechar, toca o vídeo de finalização
		if _pending_close:
			_pending_close = false
			_play_closing_video()
			return
		
		if loop_last_video:
			# O loop nativo do VideoStreamPlayer cuida disso
			# Só emitimos o sinal quando o vídeo reinicia
			_is_looping = true
			last_video_looped.emit()
			# Não precisa fazer nada, o loop nativo já está ativo
		else:
			# Playlist terminou
			playlist_finished.emit()
	else:
		# Próximo vídeo
		current_index += 1
		_play_video_at_index(current_index)


func _play_video_at_index(index: int) -> void:
	if index < 0 or index >= playlist.size():
		push_error("VideoPlaylistPlayer: Índice inválido: %d" % index)
		return
	
	var stream = playlist[index]
	
	if stream == null:
		push_error("VideoPlaylistPlayer: Vídeo nulo no índice: %d" % index)
		return
	
	# Se é o último vídeo e loop_last_video está ativo, usa o loop nativo
	# para evitar o piscar na transição
	var is_last_video = index >= playlist.size() - 1
	_video_player.loop = is_last_video and loop_last_video
	
	_video_player.stream = stream
	_video_player.play()
	
	video_started.emit(index, stream)


## Inicia a reprodução da playlist do início
func play_playlist() -> void:
	current_index = 0
	_is_looping = false
	_is_playing_closing = false
	_pending_close = false
	
	if playlist.size() > 0:
		_play_video_at_index(0)
	else:
		push_warning("VideoPlaylistPlayer: Playlist está vazia")


## Inicia a reprodução a partir de um índice específico
func play_from_index(index: int) -> void:
	if index < 0 or index >= playlist.size():
		push_error("VideoPlaylistPlayer: Índice inválido: %d" % index)
		return
	
	current_index = index
	_is_looping = false
	_is_playing_closing = false
	_pending_close = false
	_play_video_at_index(index)


## Finaliza o loop e toca o vídeo de encerramento
## O vídeo de encerramento só começa após o vídeo atual em loop terminar
func finish_and_close() -> void:
	if closing_video == null:
		push_warning("VideoPlaylistPlayer: Nenhum vídeo de finalização definido")
		playlist_finished.emit()
		return
	
	if _is_looping:
		# Desativa o loop para que o vídeo termine naturalmente
		_video_player.loop = false
		_pending_close = true
		_is_looping = false
	else:
		# Se não está em loop, toca o vídeo de finalização imediatamente
		_play_closing_video()


## Toca o vídeo de finalização
func _play_closing_video() -> void:
	_is_playing_closing = true
	_video_player.loop = false
	_video_player.stream = closing_video
	_video_player.play()
	
	closing_video_started.emit()


## Verifica se está aguardando para tocar o vídeo de finalização
func is_pending_close() -> bool:
	return _pending_close


## Verifica se está em loop no último vídeo
func is_looping() -> bool:
	return _is_looping


## Verifica se está tocando o vídeo de finalização
func is_playing_closing_video() -> bool:
	return _is_playing_closing


## Pausa a reprodução
func pause() -> void:
	if _video_player:
		_video_player.paused = true


## Retoma a reprodução
func resume() -> void:
	if _video_player:
		_video_player.paused = false


## Para a reprodução completamente
func stop() -> void:
	if _video_player:
		_video_player.stop()


## Verifica se está reproduzindo
func is_playing() -> bool:
	return _video_player != null and _video_player.is_playing()


## Verifica se está pausado
func is_paused() -> bool:
	return _video_player != null and _video_player.paused


## Pula para o próximo vídeo
func next_video() -> void:
	if current_index < playlist.size() - 1:
		current_index += 1
		_play_video_at_index(current_index)


## Volta para o vídeo anterior
func previous_video() -> void:
	if current_index > 0:
		current_index -= 1
		_play_video_at_index(current_index)


## Adiciona um vídeo à playlist
func add_video(stream: VideoStream) -> void:
	playlist.append(stream)


## Remove um vídeo da playlist pelo índice
func remove_video_at(index: int) -> void:
	if index >= 0 and index < playlist.size():
		playlist.remove_at(index)
		
		# Ajusta o índice atual se necessário
		if current_index >= playlist.size():
			current_index = max(0, playlist.size() - 1)


## Limpa a playlist
func clear_playlist() -> void:
	stop()
	playlist.clear()
	current_index = 0


## Define uma nova playlist
func set_playlist(new_playlist: Array[VideoStream]) -> void:
	stop()
	playlist = new_playlist
	current_index = 0


## Retorna o número total de vídeos na playlist
func get_playlist_size() -> int:
	return playlist.size()


## Retorna o VideoStream atual
func get_current_video() -> VideoStream:
	if current_index >= 0 and current_index < playlist.size():
		return playlist[current_index]
	return null


## Retorna a posição atual de reprodução em segundos
func get_stream_position() -> float:
	if _video_player:
		return _video_player.stream_position
	return 0.0


## Define a posição de reprodução em segundos
func seek(position: float) -> void:
	if _video_player:
		_video_player.stream_position = position
