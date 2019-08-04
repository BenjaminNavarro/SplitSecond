extends KinematicBody2D
class_name Player

export var WALK_FORCE = 2000
export var WALK_MIN_SPEED = 10
export var WALK_MAX_SPEED = 350
export var STOP_FORCE = 2000
export var JUMP_FORCE = 2000
export var GRAVITY = 200

var walk_left := false
var walk_right := true
var walk_up := false
var walk_down := false
var jump := false
var crouch := false
var attack := false
var velocity := Vector2()
var is_colliding := false
var is_under_object := false
var crouch_timer: Timer
var first_collision := true
var current_time := 0.0

onready var _root: Main = get_tree().get_root().get_node("Root")
onready var _fx_player: FXPlayer = _root.get_node("FXPlayer")
var collision_sound = preload("res://Assets/Sound/FX/wall_collision.wav")
var sword_sound = preload("res://Assets/Sound/FX/sword.wav")
var jump_sound = preload("res://Assets/Sound/FX/jump.wav")
var crouch_sound = preload("res://Assets/Sound/FX/crouch.wav")
var win_sound = preload("res://Assets/Sound/FX/win.wav")
var die_sound = preload("res://Assets/Sound/FX/die.wav")

signal died

func _ready():
	# warning-ignore:return_value_discarded
	$Area2D.connect("area_entered", self, "_on_hitbox_collision")
	# warning-ignore:return_value_discarded
	$Weapon/Area2D.connect("area_entered", self, "_on_weapon_collision")
	$RayCast2D.enabled = true

func execute_action(action: String):
	if action == "jump":
		jump = true
		_fx_player.play_at(jump_sound, position)
	if action == "crouch":
		crouch = true
		is_under_object = false
		crouch_timer = Timer.new()
		# warning-ignore:return_value_discarded
		crouch_timer.connect("timeout", self, "_stop_crouching")
		add_child(crouch_timer)
		crouch_timer.set_wait_time(1)
		crouch_timer.one_shot = true
		crouch_timer.start()
		_fx_player.play_at(crouch_sound, position)
	if action == "attack":
		$AnimationPlayer.play("Attack")
		_fx_player.play_at(sword_sound, position)
		attack = true

# warning-ignore:unused_argument
func win(value):
	_fx_player.play_at(win_sound, position)
	stop()

func stop():
	scale.y = 1
	set_physics_process(false)
		
func kill():
	stop()
	$Sprite.visible = false
	$Particles2D.emitting = true
	$Particles2D.restart()
	$Area2D.disconnect("area_entered", self, "_on_hitbox_collision")
	
	_fx_player.play_at(die_sound, position)
	
	emit_signal("died")
	
func _on_hitbox_collision(collider):
	#var collider = value.get_parent()
	#print(value.name, ", ", collider.name)
	if (collider.is_in_group("obstacles")):
		kill()
	elif (collider.is_in_group("enemies")):
		kill()

func _on_weapon_collision(collider):
	# var collider = value.get_parent()
	if collider.is_in_group("enemies"):
		(collider.get_parent() as Enemy).kill()
		$AnimationPlayer.seek(0)
		$AnimationPlayer.pause_mode = true

func _physics_process(delta: float):
	handle_motion(delta)
	
func handle_motion(delta: float):
	current_time += delta
	
	var force = Vector2()	
		
	var stop_left_right = true
	var stop_up_down = true
	
	if walk_left:
		if velocity.x <= WALK_MIN_SPEED and velocity.x > -WALK_MAX_SPEED:
			force.x -= WALK_FORCE
			stop_left_right = false
	elif walk_right:
		if velocity.x >= -WALK_MIN_SPEED and velocity.x < WALK_MAX_SPEED:
			force.x += WALK_FORCE
			stop_left_right = false
		
	if walk_up:
		if velocity.y <= WALK_MIN_SPEED and velocity.y > -WALK_MAX_SPEED:
			force.y -= WALK_FORCE
			stop_up_down = false
	elif walk_down:
		if velocity.y >= -WALK_MIN_SPEED and velocity.y < WALK_MAX_SPEED:
			force.y += WALK_FORCE
			stop_up_down = false

	if stop_left_right:
		var vsign = sign(velocity.x)
		var vlen = abs(velocity.x)
		
		vlen -= STOP_FORCE * delta
		if vlen < 0:
			vlen = 0
		
		velocity.x = vlen * vsign
		
		
	if stop_up_down:
		var vsign = sign(velocity.y)
		var vlen = abs(velocity.y)
		
		vlen -= STOP_FORCE * delta
		if vlen < 0:
			vlen = 0
		
		velocity.y = vlen * vsign
	
	if jump:
		jump = false
		velocity.y -= JUMP_FORCE
		
	var animation_scaling = 0.93 + 0.07 * cos(current_time * 2.0 * PI * 2)
			
	if crouch and not is_under_object and $RayCast2D.is_colliding():
		is_under_object = true
	elif crouch and is_under_object and not $RayCast2D.is_colliding():
		crouch = false
		_fx_player.play_at(crouch_sound, position)
	if crouch:
		scale.y = 0.5
		$RayCast2D.scale.y = 2.0
	else:
		scale.y = 1.0
		$RayCast2D.scale.y = 1.0
	
	$Sprite.scale.y = 0.6 * scale.y * animation_scaling
		
	velocity.y += GRAVITY
	
	# Integrate forces to velocity
	velocity += force * delta
	# warning-ignore:return_value_discarded 
	velocity = move_and_slide(velocity)
	
	var collisionCounter = get_slide_count()
	if collisionCounter > 0:
		if not is_colliding:
			is_colliding = true
			if not first_collision and not crouch:
				_fx_player.play_at(collision_sound, position)
	else:
		is_colliding = false
	if first_collision:
		first_collision = false
		
func _stop_crouching():
	if not $RayCast2D.is_colliding():
		crouch = false
		is_under_object = false