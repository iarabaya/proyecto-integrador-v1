class_name ConsolePanel
extends PanelContainer

const PIXEL_FONT = preload("res://assets/fonts/pixelFont-7-8x14-sproutLands.ttf")

const CMD_TEXT: Dictionary = {
	"up": "mover_arriba",
	"down": "mover_abajo",
	"left": "mover_izquierda",
	"right": "mover_derecha",
	"jump": "saltar()",
	"jump_up": "saltar_arriba",
	"jump_down": "saltar_abajo",
	"jump_left": "saltar_izquierda",
	"jump_right": "saltar_derecha",
}

@onready var _scroll: ScrollContainer = $VBox/Scroll
@onready var _code_lines: VBoxContainer = $VBox/Scroll/CodeLines
@onready var _btn_toggle: Button = $VBox/Header/BtnToggle

var _line_labels: Array[Label] = []
var _expanded := false
var _expanded_height: float = 0.0

func _ready() -> void:
	_btn_toggle.pressed.connect(_toggle)
	# Store the full height from the editor layout
	await get_tree().process_frame
	_expanded_height = size.y
	# Start collapsed
	_scroll.visible = false
	_btn_toggle.text = "▼"
	size.y = $VBox/Header.size.y + 8.0   # just the header + small padding

func _toggle() -> void:
	_expanded = not _expanded
	_scroll.visible = _expanded
	_btn_toggle.text = "▲" if _expanded else "▼"
	if _expanded:
		size.y = _expanded_height
	else:
		size.y = $VBox/Header.size.y + 8.0

## Build all lines from the queue (call when program starts or queue changes)
func build_from_queue(queue: Array) -> void:
	_clear_lines()
	for i in queue.size():
		var cmd: String = queue[i]
		var text := "%d. %s" % [i + 1, CMD_TEXT.get(cmd, cmd)]
		var lbl := _make_label(text, Color.WHITE)
		_code_lines.add_child(lbl)
		_line_labels.append(lbl)

## Highlight the current step during execution
func highlight_line(index: int) -> void:
	for i in _line_labels.size():
		_line_labels[i].modulate = Color.DARK_BLUE
	if index >= 0 and index < _line_labels.size():
		_line_labels[index].modulate = Color.YELLOW
		_scroll_to_line(index)

## Mark a line with a result after it executes
func mark_line(index: int, result: String) -> void:
	if index < 0 or index >= _line_labels.size(): return
	var base_text: String = _line_labels[index].text
	_line_labels[index].text = base_text + " " + result
	if "✗" in result:
		_line_labels[index].add_theme_color_override("font_color", Color(1.0, 0.5, 0.5))
	elif "✓" in result:
		_line_labels[index].add_theme_color_override("font_color", Color(0.5, 1.0, 0.5))

## Add a final summary line
func add_summary(text: String, color: Color = Color.WHITE) -> void:
	var lbl := _make_label(text, color)
	_code_lines.add_child(lbl)
	_line_labels.append(lbl)
	await get_tree().process_frame
	_scroll.scroll_vertical = int(_scroll.get_v_scroll_bar().max_value)

## Clear all lines
func clear_lines() -> void:
	_clear_lines()

func _clear_lines() -> void:
	for lbl in _line_labels:
		lbl.queue_free()
	_line_labels.clear()

func _make_label(text: String, color: Color) -> Label:
	var lbl := Label.new()
	lbl.text = text
	lbl.add_theme_font_override("font", PIXEL_FONT)
	lbl.add_theme_font_size_override("font_size", 6)
	lbl.add_theme_color_override("font_color", color)
	lbl.autowrap_mode = TextServer.AUTOWRAP_WORD
	lbl.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	return lbl

func _scroll_to_line(index: int) -> void:
	await get_tree().process_frame
	if index < _line_labels.size():
		var lbl := _line_labels[index]
		_scroll.scroll_vertical = int(lbl.position.y)
