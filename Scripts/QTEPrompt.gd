extends Control

class_name QTEPrompt

onready var _qte_progress: ProgressBar = get_node("MarginContainer/PanelContainer/MarginContainer/VBoxContainer/ProgressBar")
onready var _buttons_container: ProgressBar = get_node("MarginContainer/PanelContainer/MarginContainer/VBoxContainer/GridContainer")
var start_qte := false
var current_qte_time := 0.0
var qte_duration := 1.0

var actions = ["jump", "crouch", "attack"]
onready var buttons = [_buttons_container.get_node("TopButton"), _buttons_container.get_node("RightButton"), _buttons_container.get_node("BottomButton"), _buttons_container.get_node("LeftButton")]
var expected_action := ""
var executed_action := ""
var player_to_notify: Player = null

# Called when the node enters the scene tree for the first time.
func _ready():
	randomize()
	_generate_random_indexes()
	visible = false
	
	for button in buttons:
		var btn = button as Button
		btn.connect("pressed", self, "_register_action", [btn])

func start_qte(action: String, player: Player):
	expected_action = action
	player_to_notify = player
	executed_action = ""
	
	get_tree().paused = true
	visible = true
	start_qte = true
	
	var indexes = _generate_random_indexes()
	for i in range(buttons.size()):
		var btn = buttons[i] as Button
		if indexes[i] < actions.size():
			btn.text = actions[indexes[i]].to_upper()
		else:
			btn.text = "  "
	
func _end_qte():
	start_qte = false
	visible = false
	current_qte_time = 0.0
	get_tree().paused = false

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	if start_qte:
		_qte_progress.value = (1.0 - current_qte_time / qte_duration) * 100
		current_qte_time += delta
		if current_qte_time >= qte_duration:
			_end_qte()
		
		if not executed_action.empty():
			if executed_action == expected_action:
				player_to_notify.execute_action(expected_action)
			_end_qte()
			
func _register_action(button: Button):
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