extends Camera2D

onready var player: Player = get_parent().get_node("Player")

# Called when the node enters the scene tree for the first time.
func _ready():
	_reposition_camera()

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _physics_process(delta):
	_reposition_camera()

func _reposition_camera():
	position.x = player.position.x + 160