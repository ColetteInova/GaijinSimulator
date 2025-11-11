extends CanvasLayer

@onready var color_rect = $ColorRect
@onready var animation_player = $AnimationPlayer

var is_transitioning = false


func _ready():
	# Garante que a transição começa invisível
	color_rect.color.a = 0.0
	# Fica sempre no topo
	layer = 100


func fade_in(duration: float = 0.5):
	"""Fade in - tela fica visível (preta)"""
	if is_transitioning:
		await transition_finished()
	
	is_transitioning = true
	
	var tween = create_tween()
	tween.set_ease(Tween.EASE_IN_OUT)
	tween.set_trans(Tween.TRANS_CUBIC)
	tween.tween_property(color_rect, "color:a", 1.0, duration)
	
	await tween.finished
	is_transitioning = false


func fade_out(duration: float = 0.5):
	"""Fade out - tela fica transparente"""
	if is_transitioning:
		await transition_finished()
	
	is_transitioning = true
	
	var tween = create_tween()
	tween.set_ease(Tween.EASE_IN_OUT)
	tween.set_trans(Tween.TRANS_CUBIC)
	tween.tween_property(color_rect, "color:a", 0.0, duration)
	
	await tween.finished
	is_transitioning = false


func change_scene_to_file(scene_path: String, fade_in_duration: float = 0.5, fade_out_duration: float = 0.5):
	"""Transição completa: fade in -> troca cena -> fade out"""
	if is_transitioning:
		await transition_finished()
	
	# Fade in (escurece a tela)
	await fade_in(fade_in_duration)
	
	# Troca a cena
	get_tree().change_scene_to_file(scene_path)
	
	# Aguarda a cena carregar
	await get_tree().process_frame
	
	# Fade out (clareia a tela)
	await fade_out(fade_out_duration)


func transition_finished():
	"""Aguarda a transição atual terminar"""
	while is_transitioning:
		await get_tree().process_frame
