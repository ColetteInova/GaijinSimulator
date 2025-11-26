extends Node
class_name PlayerSpriteBuilder

## Constrói SpriteFrames a partir de spritesheets de camadas do player

const FRAME_WIDTH = 64
const FRAME_HEIGHT = 98
const COLUMNS = 9
const ROWS = 8

## Estrutura: [linha, nome_da_direção]
const DIRECTIONS = [
	[0, "down"],
	[1, "down_right"],
	[2, "right"],
	[3, "up_right"],
	[4, "up"],
	[5, "up_left"],
	[6, "left"],
	[7, "down_left"]
]


static func create_spriteframes_from_texture(texture_path: String) -> SpriteFrames:
	"""Cria um SpriteFrames a partir de um spritesheet de camada"""
	var texture = load(texture_path)
	if not texture:
		push_error("Failed to load texture: " + texture_path)
		return null
	
	var sprite_frames = SpriteFrames.new()
	
	# Cria animações para cada direção
	for direction_data in DIRECTIONS:
		var row = direction_data[0]
		var dir_name = direction_data[1]
		
		# Cria animação idle (coluna 0)
		var idle_name = "idle_" + dir_name
		sprite_frames.add_animation(idle_name)
		sprite_frames.set_animation_speed(idle_name, 12.0)
		sprite_frames.set_animation_loop(idle_name, true)
		
		var idle_texture = create_atlas_texture(texture, 0, row)
		sprite_frames.add_frame(idle_name, idle_texture)
		
		# Cria animação walk (colunas 1-8)
		var walk_name = "walk_" + dir_name
		sprite_frames.add_animation(walk_name)
		sprite_frames.set_animation_speed(walk_name, 12.0)
		sprite_frames.set_animation_loop(walk_name, true)
		
		for col in range(1, COLUMNS):
			var walk_texture = create_atlas_texture(texture, col, row)
			sprite_frames.add_frame(walk_name, walk_texture)
	
	return sprite_frames


static func create_atlas_texture(texture: Texture2D, col: int, row: int) -> AtlasTexture:
	"""Cria um AtlasTexture de uma região específica do spritesheet"""
	var atlas = AtlasTexture.new()
	atlas.atlas = texture
	atlas.region = Rect2(
		col * FRAME_WIDTH,
		row * FRAME_HEIGHT,
		FRAME_WIDTH,
		FRAME_HEIGHT
	)
	return atlas
