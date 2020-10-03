extends KinematicBody
class_name Player

const MAX_RUNNING_SPEED := 10.0
const MAX_FALLING_SPEED := 20.0
const TIME_TO_MAX_SPEED := 0.1
const JUMP_HEIGHT := 3.5
const DISTANCE_TO_PEAK := 5.0
const DISTANCE_AFTER_PEAK := 3.0

var move_dir := Vector3.ZERO
var gravity := 0.0
var velocity := Vector3.ZERO
var pressed_jump := false
var snap_vec := Vector3.DOWN
var was_grounded := false
var jumping := false

onready var coyote_timer := $CoyoteTimer

func _process(_delta: float) -> void:
	move_dir = Vector3.ZERO
	if Input.is_action_pressed("move_right"):
		move_dir += Vector3.RIGHT
	if Input.is_action_pressed("move_left"):
		move_dir += Vector3.LEFT
		
	if Input.is_action_just_pressed("jump"):
		pressed_jump = true

func _physics_process(delta: float) -> void:
	var grounded := is_on_floor()
	
	if was_grounded and not grounded and not jumping:
		coyote_timer.start()
	
	if move_dir.length_squared() > 0.0:
		velocity.x += move_dir.x * (MAX_RUNNING_SPEED/TIME_TO_MAX_SPEED) * delta
		velocity.x = clamp(velocity.x, -MAX_RUNNING_SPEED, MAX_RUNNING_SPEED)
	else:
		var prev_move_dir = sign(velocity.x)
		var min_speed = 0.0 if prev_move_dir > 0.0 else velocity.x
		var max_speed = velocity.x if prev_move_dir > 0.0 else 0.0
		velocity.x -= prev_move_dir * (MAX_RUNNING_SPEED/TIME_TO_MAX_SPEED) * delta
		velocity.x = clamp(velocity.x, min_speed, max_speed)

	if (grounded or not coyote_timer.is_stopped()) and pressed_jump:
		var jump_speed = 2 * JUMP_HEIGHT * MAX_RUNNING_SPEED / DISTANCE_TO_PEAK
		velocity.y = jump_speed
		snap_vec = Vector3.ZERO
		coyote_timer.stop()
		jumping = true
	elif not grounded:
		var jump_section_distance = DISTANCE_TO_PEAK if velocity.y > 0.0 else DISTANCE_AFTER_PEAK
		gravity = -2 * JUMP_HEIGHT * pow(MAX_RUNNING_SPEED, 2) / pow(jump_section_distance, 2)
		velocity.y += gravity * delta
	else:
		snap_vec = Vector3.DOWN
		velocity.y = -0.1
		jumping = false
		
	velocity = move_and_slide_with_snap(velocity, snap_vec, Vector3.UP)
	
	pressed_jump = false
	was_grounded = grounded
