extends PanelContainer
class_name UIWindow

## Uma janela de interface reutilizável com título e conteúdo customizável
##
## Esta classe fornece uma janela estilizada usando os sprites de UI do jogo.
## Pode ser usada para criar diálogos, menus e outras interfaces de janela.

## Sinal emitido quando o botão de fechar é pressionado
signal window_closed

## Título da janela
@export var window_title: String = "Window":
	set(value):
		window_title = value
		if _title_label:
			_title_label.text = value

## Se a janela pode ser fechada pelo botão X
@export var closeable: bool = true:
	set(value):
		closeable = value
		if _close_button:
			_close_button.visible = value

## Se a janela pode ser arrastada
@export var draggable: bool = false

## Referências aos nós filhos
var _title_label: Label
var _close_button: Button
var _content_container: VBoxContainer
var _title_bar: HBoxContainer

## Variáveis para arrastar
var _dragging: bool = false
var _drag_offset: Vector2 = Vector2.ZERO

func _ready() -> void:
	_setup_references()
	_setup_signals()
	_apply_properties()

func _setup_references() -> void:
	"""Configura as referências aos nós filhos"""
	_title_bar = $MarginContainer/VBoxContainer/TitleBar
	_title_label = $MarginContainer/VBoxContainer/TitleBar/Title
	_close_button = $MarginContainer/VBoxContainer/TitleBar/CloseButton
	_content_container = $MarginContainer/VBoxContainer/Content/ContentContainer

func _setup_signals() -> void:
	"""Conecta os sinais necessários"""
	if _close_button:
		_close_button.pressed.connect(_on_close_button_pressed)
	
	if draggable and _title_bar:
		_title_bar.gui_input.connect(_on_title_bar_gui_input)

func _apply_properties() -> void:
	"""Aplica as propriedades exportadas"""
	if _title_label:
		_title_label.text = window_title
	if _close_button:
		_close_button.visible = closeable

func _process(_delta: float) -> void:
	if _dragging:
		global_position = get_global_mouse_position() - _drag_offset

## Adiciona um nó ao container de conteúdo da janela
func add_content(node: Node) -> void:
	if _content_container:
		_content_container.add_child(node)

## Remove todo o conteúdo da janela
func clear_content() -> void:
	if _content_container:
		for child in _content_container.get_children():
			child.queue_free()

## Fecha a janela
func close_window() -> void:
	window_closed.emit()
	queue_free()

## Mostra a janela
func show_window() -> void:
	show()

## Esconde a janela
func hide_window() -> void:
	hide()

func _on_close_button_pressed() -> void:
	"""Callback para quando o botão de fechar é pressionado"""
	close_window()

func _on_title_bar_gui_input(event: InputEvent) -> void:
	"""Gerencia o input na barra de título para arrastar"""
	if event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_LEFT:
			if event.pressed:
				_dragging = true
				_drag_offset = get_global_mouse_position() - global_position
			else:
				_dragging = false
