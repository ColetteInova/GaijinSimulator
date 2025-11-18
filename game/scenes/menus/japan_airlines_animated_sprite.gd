extends AnimatedSprite2D

# Configurações da animação de flutuação
@export var float_amplitude: float = 15.0  # Amplitude do movimento vertical em pixels
@export var float_duration: float = 2.5    # Duração de um ciclo completo em segundos
@export var auto_start: bool = true        # Inicia automaticamente

# Configurações de movimento para o centro
@export var move_to_center_delay: float = 2.0      # Delay antes de mover para o centro (segundos)
@export var move_to_center_duration: float = 3.0   # Duração do movimento até o centro (segundos)
@export var auto_move_to_center: bool = true       # Move automaticamente para o centro

var initial_position: Vector2
var tween: Tween
var float_tween: Tween
var has_moved_to_center: bool = false

func _ready():
	initial_position = position
	flip_h = true  # Vira o sprite horizontalmente
	if auto_start:
		start_floating_animation()
	
	if auto_move_to_center:
		# Aguarda o delay e então move para o centro
		await get_tree().create_timer(move_to_center_delay).timeout
		move_to_screen_center()

func move_to_screen_center():
	if has_moved_to_center:
		return
	
	has_moved_to_center = true
	
	# Para a animação de flutuação temporariamente
	if float_tween:
		float_tween.kill()
	
	# Obtém o centro da tela
	var viewport_size = get_viewport_rect().size
	var center_position = viewport_size / 2.0
	
	# Cria o tween de movimento para o centro
	tween = create_tween()
	tween.set_trans(Tween.TRANS_CUBIC)
	tween.set_ease(Tween.EASE_IN_OUT)
	
	# Move para o centro da tela
	tween.tween_property(
		self,
		"position",
		center_position,
		move_to_center_duration
	)
	
	# Quando terminar o movimento, atualiza a posição inicial e reinicia a flutuação
	tween.finished.connect(func():
		initial_position = position
		start_floating_animation()
	)

func start_floating_animation():
	# Cancela qualquer tween anterior
	if float_tween:
		float_tween.kill()
	
	# Cria um novo tween para a animação de flutuação
	float_tween = create_tween()
	float_tween.set_loops()  # Loop infinito
	float_tween.set_trans(Tween.TRANS_SINE)  # Transição suave senoidal
	float_tween.set_ease(Tween.EASE_IN_OUT)  # Suavização nas extremidades
	
	# Movimento para cima
	float_tween.tween_property(
		self, 
		"position:y", 
		initial_position.y - float_amplitude, 
		float_duration / 2
	)
	
	# Movimento para baixo
	float_tween.tween_property(
		self, 
		"position:y", 
		initial_position.y + float_amplitude, 
		float_duration / 2
	)
	
	# Retorno à posição inicial
	float_tween.tween_property(
		self, 
		"position:y", 
		initial_position.y, 
		float_duration / 2
	)

func stop_floating_animation():
	if float_tween:
		float_tween.kill()
		position.y = initial_position.y

func set_float_amplitude(new_amplitude: float):
	float_amplitude = new_amplitude
	if float_tween and float_tween.is_running():
		start_floating_animation()  # Reinicia com nova amplitude

func set_float_duration(new_duration: float):
	float_duration = new_duration
	if float_tween and float_tween.is_running():
		start_floating_animation()  # Reinicia com nova duração
