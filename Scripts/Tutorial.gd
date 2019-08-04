extends Node

onready var _root: Main = get_tree().get_root().get_node("Root")
onready var _qte_prompt: QTEPrompt = _root.get_node("UI/QTEPrompt")

var current_screen := 0
var tutorial_in_progress := true

func _ready():
	var first := true
	for child in $Screens.get_children():
		if first:
			first = false
			child.visible = true
		else:
			child.visible = false
	if _qte_prompt.joypad_available:
		$Button.icon = load("res://Assets/UI/DownButton.png")
	elif not OS.has_touchscreen_ui_hint():
		$Button.icon = load("res://Assets/UI/RightArrow.png")
	else:
		$Button.icon = null
	$Button.connect("pressed", self, "next_screen")
	

func next_screen():
	$Screens.get_children()[current_screen].visible = false
	current_screen += 1
	if current_screen >= $Screens.get_children().size():
		get_tree().paused = false
		tutorial_in_progress = false
		$Button.queue_free()
		_qte_prompt.qte_duration = 10.0
	else:
		$Screens.get_children()[current_screen].visible = true

func _input(event):
	if Input.is_action_just_pressed("ui_accept"):
		if tutorial_in_progress:
			next_screen()