extends Node

func _ready():
	# Aguarda um frame para garantir que GameSettings foi inicializado
	await get_tree().process_frame
	
	# Inicia com fade out (mostra a cena gradualmente)
	await SceneTransition.fade_out(0.8)
	
	# Aguarda um pouco antes de verificar o idioma
	await get_tree().create_timer(0.3).timeout
	
	# Verifica se o idioma já foi definido
	if GameSettings.is_language_set():
		# Se já tiver idioma, vai direto para o menu principal com transição
		await SceneTransition.change_scene_to_file("res://scenes/menus/main_menu.tscn", 0.5, 0.8)
	else:
		# Se não tiver idioma, mostra a tela de seleção de idioma com transição
		await SceneTransition.change_scene_to_file("res://scenes/menus/language_selection.tscn", 0.5, 0.8)
