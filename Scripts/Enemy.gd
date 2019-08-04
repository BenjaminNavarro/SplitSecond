extends Node2D

class_name Enemy

export var max_translation := 100.0
export var patrol_time := 10.0
export var direction := "left"
var _origin_pos: Vector2
var _time := 0.0
var kill_timer: Timer

# Called when the node enters the scene tree for the first time.
func _ready():
	_origin_pos = position

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	_time += delta
	var dx = max_translation * sin(_time/patrol_time * 2.0 * PI)
	if direction == "left":
		dx *= -1.0
	elif direction != "right":
		dx = 0.0
	position = _origin_pos + Vector2(dx, 0)

func kill():
	$Area2D.queue_free()
	$QTETrigger.queue_free()
	$CPUParticles2D.emitting = true
	$CPUParticles2D.restart()
	
	kill_timer = Timer.new()
	# warning-ignore:return_value_discarded
	kill_timer.connect("timeout", self, "queue_free")
	add_child(kill_timer)
	kill_timer.set_wait_time(1)
	kill_timer.one_shot = true
	kill_timer.start()