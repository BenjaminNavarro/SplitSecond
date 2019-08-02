extends Area2D

class_name QTETrigger

signal quick_time_event

export var action := "jump"

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.

# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass


func _on_QTETrigger_body_entered(body: PhysicsBody2D):
	if body and body.is_in_group("players"):
		print("Player is here")
		emit_signal("quick_time_event")
