extends Sprite

var current_time := 0.0

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


func _process(delta):
	current_time += delta
	scale.x = 0.9 + 0.1 * cos(current_time * 2.0 * PI / 2.0)
