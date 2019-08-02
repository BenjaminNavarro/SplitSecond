extends Control

class_name QTEPrompt

onready var _qte_progress: ProgressBar = get_node("MarginContainer/PanelContainer/MarginContainer/VBoxContainer/ProgressBar")
var start_qte := false
var current_qte_time := 0.0
var qte_duration := 1.0

var actions = ["jump", "crouch", "attack"]
var expected_action := ""
var player_to_notify: Player = null

# Called when the node enters the scene tree for the first time.
func _ready():
	visible = false
	pass

func start_qte(action: String, player: Player):
	print("QTE time!", action)
	expected_action = action
	player_to_notify = player
	get_tree().paused = true
	visible = true
	start_qte = true
	
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

func _input(event: InputEvent):
	if start_qte:
		var jump = Input.is_action_pressed("ui_up")
		if expected_action == "jump" and jump:
			print("QTE success!")
			_end_qte()
			player_to_notify.execute_action(expected_action)