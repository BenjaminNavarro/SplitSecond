extends Node2D

class_name GameWorld

onready var _root: Main = get_tree().get_root().get_node("Root")

var next_level_timer: Timer
var tutorial := false

# Called when the node enters the scene tree for the first time.
func _ready():
	if _root.current_level == 0:
		get_tree().paused = true
		tutorial = true
	var qte_ui := _root.get_node("UI/QTEPrompt")
	qte_ui.qte_duration = 1.0
	var triggers = get_tree().get_nodes_in_group("qte_triggers")
	for elem in triggers:
		var trigger := elem as QTETrigger
		# warning-ignore:return_value_discarded
		trigger.connect("quick_time_event", qte_ui, "start_qte", [$Player])
	# warning-ignore:return_value_discarded
	if $LevelEnd:
		$LevelEnd.connect("area_entered", self, "win")
	# waning-ignore:return_value_discarded
	if $Player:
		$Player.connect("died", self, "player_died")

func win(value):
	$Player.win(value)
	$LevelEnd/CollisionShape2D/CPUParticles2D.emitting = true
	$LevelEnd/CollisionShape2D/CPUParticles2D.restart()
	
	next_level_timer = Timer.new()
	add_child(next_level_timer)
	_root.current_level += 1
# warning-ignore:return_value_discarded
	next_level_timer.connect("timeout", _root.scene_manager, "load_level", [_root.current_level])
	next_level_timer.wait_time = 3
	next_level_timer.one_shot = true
	next_level_timer.start()
	
func player_died():
	var qte_ui := _root.get_node("UI/QTEPrompt")
	var triggers = get_tree().get_nodes_in_group("qte_triggers")
	for elem in triggers:
		var trigger := elem as QTETrigger
		trigger.disconnect("quick_time_event", qte_ui, "start_qte")
		
	next_level_timer = Timer.new()
	add_child(next_level_timer)
	if tutorial:
		# warning-ignore:return_value_discarded
		next_level_timer.connect("timeout", _root.scene_manager, "load_game")
	else:
		# warning-ignore:return_value_discarded
		next_level_timer.connect("timeout", _root.scene_manager, "load_level", [_root.current_level])
	next_level_timer.wait_time = 3
	next_level_timer.one_shot = true
	next_level_timer.start()