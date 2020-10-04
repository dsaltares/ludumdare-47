extends KinematicBody
class_name Player

signal killed

enum States {
	Appearing,
	Regular,
	Dying,
}

const MAX_RUNNING_SPEED := 10.0
const MAX_FALLING_SPEED := 20.0
const TIME_TO_MAX_SPEED := 0.1
const JUMP_HEIGHT := 3.5
const DISTANCE_TO_PEAK := 5.0
const DISTANCE_AFTER_PEAK := 3.0

var move_dir := 0
var last_move_dir := 0
var gravity := 0.0
var velocity := Vector3.ZERO
var pressed_jump := false
var snap_vec := Vector3.DOWN
var was_grounded := false
var jumping := false
var dead := false
var state = States.Appearing

onready var coyote_timer := $CoyoteTimer
onready var appear_timer := $AppearTimer
onready var die_timer := $DieTimer
onready var turn_tween := $TurnTween
onready var graphics := $Graphics
onready var mesh := $Graphics/Body

func kill() -> void:
	if state != States.Dying:
		state = States.Dying
		die_timer.start()

func _ready() -> void:
	die_timer.connect("timeout", self, "on_die_timer_timeout")
	appear_timer.connect("timeout", self, "on_appear_timer_timeout")

func _process(_delta: float) -> void:
	_update_dissolve_amount()	
	
	last_move_dir = move_dir
	move_dir = 0
	
	if state == States.Dying or state == States.Appearing:
		return
		
	if Input.is_action_pressed("move_right"):
		move_dir += 1
	if Input.is_action_pressed("move_left"):
		move_dir += -1
		
	if Input.is_action_just_pressed("jump"):
		pressed_jump = true

func _physics_process(delta: float) -> void:	
	_update_horizontal_velocity(delta)
	_update_vertical_velocity(delta)
	_move()
	_update_look_dir()

func _update_dissolve_amount() -> void:
	var amount = 0.0
	
	if state == States.Appearing:
		amount = appear_timer.time_left / appear_timer.wait_time
	elif state == States.Dying:
		amount = 1 - die_timer.time_left / die_timer.wait_time

	mesh.get_surface_material(0).set_shader_param("dissolve_amount", amount)

func _update_horizontal_velocity(delta : float) -> void:
	if abs(move_dir) > 0.0:
		velocity.x += move_dir * (MAX_RUNNING_SPEED/TIME_TO_MAX_SPEED) * delta
		velocity.x = clamp(velocity.x, -MAX_RUNNING_SPEED, MAX_RUNNING_SPEED)
	else:
		var prev_move_dir = sign(velocity.x)
		var min_speed = 0.0 if prev_move_dir > 0.0 else velocity.x
		var max_speed = velocity.x if prev_move_dir > 0.0 else 0.0
		velocity.x -= prev_move_dir * (MAX_RUNNING_SPEED/TIME_TO_MAX_SPEED) * delta
		velocity.x = clamp(velocity.x, min_speed, max_speed)

func _update_vertical_velocity(delta : float) -> void:
	var grounded := is_on_floor()
	
	if was_grounded and not grounded and not jumping:
		coyote_timer.start()
		
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
	
	pressed_jump = false
	was_grounded = grounded

func _update_look_dir() -> void:
	var angle = graphics.rotation.y
	if move_dir < 0:
		angle = deg2rad(180)
	elif move_dir > 0:
		angle = 0
		
	if sign(move_dir) != 0 and sign(move_dir) != sign(last_move_dir):
		turn_tween.interpolate_property(
			graphics,
			"rotation",
			graphics.rotation,
			-Vector3(0, angle, 0),
			0.25,
			Tween.TRANS_LINEAR,
			Tween.EASE_IN_OUT,
			0
		)
		
		turn_tween.start()

func _move() -> void:
	velocity = move_and_slide_with_snap(velocity, snap_vec, Vector3.UP)
	transform.origin.z = 0

func on_appear_timer_timeout() -> void:
	state = States.Regular

func on_die_timer_timeout() -> void:
	emit_signal("killed")
