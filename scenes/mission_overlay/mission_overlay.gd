class_name MissionOverlay
extends CanvasLayer

@onready var _lbl_title:    Label  = $Background/Panel/Margin/VBox/LblTitle
@onready var _lbl_goal:     Label  = $Background/Panel/Margin/VBox/LblGoal
@onready var _lbl_concepts: Label  = $Background/Panel/Margin/VBox/LblConcepts
@onready var _btn_close:    Button = $Background/Panel/Margin/VBox/BtnClose

func _ready() -> void:
	visible = false
	_btn_close.pressed.connect(close)

func setup(mission: Dictionary) -> void:
	_lbl_title.text = mission.get("title", "Misión")
	_lbl_goal.text = mission.get("goal", "")
	var concepts: Array = mission.get("concepts", [])
	if concepts.size() > 0:
		_lbl_concepts.text = "Conceptos: " + ", ".join(concepts)
	else:
		_lbl_concepts.visible = false

func open() -> void:
	visible = true

func close() -> void:
	visible = false

func toggle() -> void:
	if visible:
		close()
	else:
		open()
