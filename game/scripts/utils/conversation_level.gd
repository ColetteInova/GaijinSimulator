extends Object
class_name NativeLevel

## Classe utilitária para gerenciar níveis de conversação (JLPT para japonês, etc)

enum Level {
	N1,
	N2,
	N3,
	N4,
	N5
}

## Retorna o caminho do ícone do livro para o nível especificado
static func get_book_icon_path(level: Level) -> String:
	var level_name = Level.keys()[level].to_lower()
	return "res://assets/sprites/UIs/ui_books/book_" + level_name + ".png"

## Retorna a textura do ícone do livro para o nível especificado
static func get_book_icon_texture(level: Level) -> Texture2D:
	var icon_path = get_book_icon_path(level)
	return load(icon_path)

## Retorna o nome do nível como string (ex: "N1", "N2")
static func get_level_name(level: Level) -> String:
	return Level.keys()[level]

## Retorna o nível a partir do nome (ex: "N1" -> Level.N1)
static func get_level_from_name(level_name: String) -> Level:
	match level_name.to_upper():
		"N1":
			return Level.N1
		"N2":
			return Level.N2
		"N3":
			return Level.N3
		"N4":
			return Level.N4
		"N5":
			return Level.N5
		_:
			return Level.N5  # Default
