extends CanvasLayer

const PIXEL_FONT = preload("res://assets/fonts/pixelFont-7-8x14-sproutLands.ttf")

signal execute_requested(moves: Array)
signal restart_requested()

const MAX_SLOTS := 25
const SLOT_WIDTH := 50     # ← fixed width per slot 
const CMD_LABEL: Dictionary = {
	"up": "↑", "down": "↓", "left": "←", "right": "→", "jump": "○",
	"jump_up": "↑○", "jump_down": "↓○", "jump_left": "←○", "jump_right": "→○",
}

var _queue: Array[String] = []
var _slot_nodes: Array[PanelContainer] = []
var _selected: Array[int] = [] 

@onready var _btn_up:      TextureButton        = $Panel/Margin/HBox/DPad/BtnUp
@onready var _btn_down:    TextureButton        = $Panel/Margin/HBox/DPad/BtnDown
@onready var _btn_left:    TextureButton        = $Panel/Margin/HBox/DPad/BtnLeft
@onready var _btn_right:   TextureButton        = $Panel/Margin/HBox/DPad/BtnRight
@onready var _btn_jump:    Button        = $Panel/Margin/HBox/DPad/BtnJump

@onready var _scroll:      ScrollContainer = $Panel/Margin/HBox/Queue/ScrollContainer
@onready var _slots_hbox:  HBoxContainer = $Panel/Margin/HBox/Queue/ScrollContainer/Slots

@onready var _btn_execute: Button        = $Panel/Margin/HBox/Buttons/BtnExecute
@onready var _btn_clear:   Button        = $Panel/Margin/HBox/Buttons/BtnClear
@onready var _btn_restart: Button        = $Panel/Margin/HBox/Buttons/BtnRestart

@onready var _btn_levels: Button = $PanelMenu/BtnLevels


func _ready() -> void:
	# buttons signals
	_btn_up.pressed.connect(func(): _enqueue("up"))
	_btn_down.pressed.connect(func(): _enqueue("down"))
	_btn_left.pressed.connect(func(): _enqueue("left"))
	_btn_right.pressed.connect(func(): _enqueue("right"))
	_btn_jump.pressed.connect(func(): _enqueue("jump"))
	_btn_execute.pressed.connect(_on_execute)
	_btn_clear.pressed.connect(_on_clear)
	_btn_restart.pressed.connect(_on_restart)
	_btn_levels.pressed.connect(func(): get_tree().change_scene_to_file.call_deferred("res://scenes/level_select/level_select.tscn"))


func lock(locked: bool) -> void:
	for btn in [_btn_up, _btn_down, _btn_left, _btn_right, _btn_jump, _btn_execute]:
		btn.disabled = locked

func _enqueue(cmd: String) -> void:
	if _queue.size() >= MAX_SLOTS: return
	_deselect_all()
	_queue.append(cmd)
	_add_slot_node(cmd, _queue.size())
	_scroll_to_end()        

func _on_execute() -> void:
	if _queue.is_empty(): return
	_deselect_all()
	execute_requested.emit(_queue.duplicate())

func _on_restart() -> void:
	_on_clear()
	restart_requested.emit()

func _on_clear() -> void:
	if _selected.is_empty():
		# Nothing selected → clear everything
		_queue.clear()
		_clear_slot_nodes()
	else:
		# Delete only selected slots (process in reverse to keep indices valid)
		_selected.sort()
		_selected.reverse()
		for i in _selected:
			_queue.remove_at(i)
			_slot_nodes[i].queue_free()
			_slot_nodes.remove_at(i)
		_selected.clear()

func clear_queue() -> void:
	_selected.clear()
	_queue.clear()
	_clear_slot_nodes()

# ── Slot management ──────────────────────────────────────────────────

func _add_slot_node(cmd: String, _index: int) -> void:
	var slot := PanelContainer.new()
	slot.custom_minimum_size.x = SLOT_WIDTH

	var lbl := Label.new()
	lbl.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	lbl.vertical_alignment   = VERTICAL_ALIGNMENT_CENTER
	lbl.text = CMD_LABEL.get(cmd, "?")
	lbl.add_theme_font_override("font", PIXEL_FONT)
	slot.add_child(lbl)
	
	slot.gui_input.connect(func(event: InputEvent):
		if event is InputEventMouseButton and event.pressed and event.button_index == MOUSE_BUTTON_LEFT:
			_toggle_select(_slot_nodes.find(slot))
	)

	_slots_hbox.add_child(slot)
	_slot_nodes.append(slot)

func _clear_slot_nodes() -> void:
	for node in _slot_nodes:
		node.queue_free()
	_slot_nodes.clear()

func _toggle_select(index: int) -> void:
	if index < 0 or index >= _slot_nodes.size(): return

	if index in _selected:
		_selected.erase(index)
		_slot_nodes[index].modulate = Color.WHITE
	else:
		_selected.append(index)
		_slot_nodes[index].modulate = Color(1.0, 0.7, 0.7, 1.0)   # reddish tint = selected

func _scroll_to_end() -> void:
	# Wait one frame for the layout to update, then scroll to the right edge
	await get_tree().process_frame
	_scroll.scroll_horizontal = int(_scroll.get_h_scroll_bar().max_value)

func _deselect_all() -> void:
	for i in _selected:
		if i < _slot_nodes.size():
			_slot_nodes[i].modulate = Color.WHITE
	_selected.clear()
