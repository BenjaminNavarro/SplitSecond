extends Control

class_name QTEPrompt

onready var _qte_progress: ProgressBar = get_node("MarginContainer/PanelContainer/MarginContainer/VBoxContainer/HBoxContainer/ProgressBar")
onready var _qte_remaining_time: ProgressBar = get_node("MarginContainer/PanelContainer/MarginContainer/VBoxContainer/HBoxContainer/Label")
onready var _buttons_container: ProgressBar = get_node("MarginContainer/PanelContainer/MarginContainer/VBoxContainer/GridContainer")
var qte_started := false
var current_qte_time := 0.0
var qte_duration := 1.0
var joypad_available := false

var actions = ["jump", "crouch", "attack"]
onready var buttons = [_buttons_container.get_node("TopButton"), _buttons_container.get_node("RightButton"), _buttons_container.get_node("LeftButton")] #  _buttons_container.get_node("BottomButton"),
var executed_action := ""
var player_to_notify: Player = null

# Called when the node enters the scene tree for the first time.
func _ready():
	_generate_random_indexes()
	visible = false
	
	for button in buttons:
		var btn = button as Button
		btn.connect("pressed", self, "_register_action", [btn])
		
	joypad_available = Input.get_connected_joypads().size() > 0
	Input.connect("joy_connection_changed", self, "_on_joy_connection_changed")
	_update_ui()

func start_qte(player: Player):
	player_to_notify = player
	executed_action = ""
	
	get_tree().paused = true
	visible = true
	qte_started = true
	
	var indexes = _generate_random_indexes()
	print(indexes)
	for i in range(buttons.size()):
		var btn = buttons[i] as Button
		if indexes[i] < actions.size():
			btn.text = actions[indexes[i]].to_upper()
		else:
			btn.text = "  "
	
func _end_qte():
	qte_started = false
	visible = false
	current_qte_time = 0.0
	get_tree().paused = false

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	if qte_started:
		_qte_progress.value = (1.0 - current_qte_time / qte_duration) * 100
		_qte_remaining_time.text = "%.2f s" % (qte_duration -  current_qte_time)
		current_qte_time += delta
		if current_qte_time >= qte_duration:
			_end_qte()
		
		if not executed_action.empty():
			player_to_notify.execute_action(executed_action)
			_end_qte()
			
func _register_action(button: Button):
	if qte_started:
		executed_action = button.text.to_lower()
			
func _generate_random_indexes():
	var indexes = [randi() % buttons.size()]
	for i in range(0, buttons.size() - 1):
		while true:
			var idx = randi() % buttons.size()
			if indexes.count(idx) == 0:
				indexes.push_back(idx)
				break
	return indexes
	
func _update_ui():
	if joypad_available:
		buttons[0].icon = load("res://Assets/UI/UpButton.png")
		buttons[1].icon = load("res://Assets/UI/RightButton.png")
		buttons[2].icon = load("res://Assets/UI/LeftButton.png")
	elif not OS.has_touchscreen_ui_hint():
		buttons[0].icon = load("res://Assets/UI/UpArrow.png")
		buttons[1].icon = load("res://Assets/UI/RightArrow.png")
		buttons[2].icon = load("res://Assets/UI/LeftArrow.png")
	else:
		for btn in buttons:
			btn.icon = null
	
func _on_joy_connection_changed(device_id, connected):
	if connected:
		print(Input.get_joy_name(device_id))
		joypad_available = true
	else:
		print("Keyboard")
		joypad_available = false
	_update_ui()