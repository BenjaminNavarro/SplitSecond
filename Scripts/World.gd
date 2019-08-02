extends Node2D

class_name GameWorld

onready var _root: Main = get_tree().get_root().get_node("Root")

# Called when the node enters the scene tree for the first time.
func _ready():
	var qte_ui := _root.get_node("UI/QTEPrompt")
	var triggers = get_tree().get_nodes_in_group("qte_triggers")
	for elem in triggers:
		var trigger := elem as QTETrigger
		print("connecting ", trigger, trigger.name)
		trigger.connect("quick_time_event", qte_ui, "start_qte", [trigger.action, $Player])
