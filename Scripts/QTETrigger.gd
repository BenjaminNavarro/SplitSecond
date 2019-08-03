extends Area2D

class_name QTETrigger

signal quick_time_event

func _on_QTETrigger_body_entered(body: PhysicsBody2D):
	print(body)
	if body and body.is_in_group("players"):
		emit_signal("quick_time_event")
