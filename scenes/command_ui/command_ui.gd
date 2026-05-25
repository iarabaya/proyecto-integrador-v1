extends CanvasLayer

const PIXEL_FONT = preload("res://assets/fonts/pixelFont-7-8x14-sproutLands.ttf")

signal execute_requested(moves: Array)
signal restart_requested()

const MAX_SLOTS := 5
const CMD_LABEL: Dictionary = {
	"up": "↑", "down": "↓", "left": "←", "right": "→", "jump": "○",
	"jump_up": "↑○", "jump_down": "↓○", "jump_left": "←○", "jump_right": "→○",
}

var _queue: Array[String] = []
var _slot_labels: Array[Label] = []

@onready var _btn_up:      Button        = $Panel/Margin/HBox/DPad/BtnUp
@onready var _btn_down:    Button        = $Panel/Margin/HBox/DPad/BtnDown
@onready var _btn_left:    Button        = $Panel/Margin/HBox/DPad/BtnLeft
@onready var _btn_right:   Button        = $Panel/Margin/HBox/DPad/BtnRight
@onready var _btn_jump:    Button        = $Panel/Margin/HBox/DPad/BtnJump
@onready var _slots_hbox:  HBoxContainer = $Panel/Margin/HBox/Queue/Slots
@onready var _btn_execute: Button        = $Panel/Margin/HBox/Buttons/BtnExecute
@onready var _btn_clear:   Button        = $Panel/Margin/HBox/Buttons/BtnClear
@onready var _btn_restart: Button        = $Panel/Margin/HBox/Buttons/BtnRestart
@onready var _btn_levels: Button = $PanelMenu/BtnLevels


func _ready() -> void:
	# Build slot panels in code
	for i in MAX_SLOTS:
		var slot := PanelContainer.new()
		slot.size_flags_horizontal = Control.SIZE_EXPAND_FILL

		var lbl := Label.new()
		lbl.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
		lbl.vertical_alignment   = VERTICAL_ALIGNMENT_CENTER
		lbl.text = str(i + 1)
		slot.add_child(lbl)
		_slots_hbox.add_child(slot)
		_slot_labels.append(lbl)

	_btn_up.pressed.connect(func(): _enqueue("up"))
	_btn_down.pressed.connect(func(): _enqueue("down"))
	_btn_left.pressed.connect(func(): _enqueue("left"))
	_btn_right.pressed.connect(func(): _enqueue("right"))
	_btn_jump.pressed.connect(func(): _enqueue("jump"))
	_btn_execute.pressed.connect(_on_execute)
	_btn_clear.pressed.connect(_on_clear)
	_btn_restart.pressed.connect(func(): restart_requested.emit())
	_btn_levels.pressed.connect(func(): get_tree().change_scene_to_file.call_deferred("res://scenes/level_select/level_select.tscn"))


func lock(locked: bool) -> void:
	for btn in [_btn_up, _btn_down, _btn_left, _btn_right, _btn_jump, _btn_execute]:
		btn.disabled = locked

func _enqueue(cmd: String) -> void:
	if _queue.size() >= MAX_SLOTS: return
	_queue.append(cmd)
	_refresh_slots()

func _on_execute() -> void:
	if _queue.is_empty(): return
	execute_requested.emit(_queue.duplicate())

func _on_clear() -> void:
	_queue.clear()
	_refresh_slots()

func _refresh_slots() -> void:
	for i in MAX_SLOTS:
		_slot_labels[i].text = CMD_LABEL.get(_queue[i], "?") if i < _queue.size() else str(i + 1)
