extends KinematicBody
class_name Player

enum States {
	Appearing,
	Regular,
	Dying,
	Win,
}

export var MAX_RUNNING_SPEED := 10.0
export var MAX_FALLING_SPEED := 20.0
export var TIME_TO_MAX_SPEED := 0.1
export var JUMP_HEIGHT := 3.5
export var DISTANCE_TO_PEAK := 5.0
export var DISTANCE_AFTER_PEAK := 3.0

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
onready var mesh := $Graphics/character/rig/Skeleton/Cube
onready var die_sfx := $DieSFX
onready var dissolve_fx := $DissolveSFX
onready var jump_sfx := $JumpSFX
onready var appear_sfx := $AppearSFX
onready var key_pickup_sfx := $KeyPickupSFX
onready var win_sfx := $WinSFX
onready var animation_tree := $AnimationTree

func kill() -> void:
	if state != States.Dying:
		state = States.Dying
		dead = true
		die_timer.start()
		die_sfx.play()
		EventBus.emit_signal("shake_requested")
		EventBus.emit_signal("player_kill_started")

func dissolve() -> void:
	if state != States.Dying:
		state = States.Dying
		die_timer.start()
		dissolve_fx.play()
		EventBus.emit_signal("shake_requested")
		EventBus.emit_signal("player_dissolve_started")

func _ready() -> void:
	EventBus.connect("key_obtained", self, "on_key_obtained")
	EventBus.connect("player_entered_exit_portal", self, "win")
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
	if state == States.Dying or state == States.Win:
		return
		
	_update_horizontal_velocity(delta)
	_update_vertical_velocity(delta)
	_move()
	_update_look_dir()

func _update_dissolve_amount() -> void:
	var amount = 1.0
	
	if state == States.Appearing:
		amount = 1 - appear_timer.time_left / appear_timer.wait_time
	elif state == States.Dying:
		amount = die_timer.time_left / die_timer.wait_time

	var material = mesh.get_surface_material(0)
	material.set_shader_param("alpha", amount)
	

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
		
	if is_on_floor():
		var ground_anim := "Idle" if abs(move_dir) == 0 else "Run" 
		var state_machine = animation_tree["parameters/playback"]
		state_machine.travel(ground_anim)

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
		jump_sfx.play()
		var state_machine = animation_tree["parameters/playback"]
		state_machine.travel("Jump")
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
	if dead:
		EventBus.emit_signal("player_killed")
	else:
		EventBus.emit_signal("player_dissolved")

func on_key_obtained() -> void:
	key_pickup_sfx.play()

func win() -> void:
	state = States.Win
	var state_machine = animation_tree["parameters/playback"]
	state_machine.travel("Celebrate")
	win_sfx.play()
	yield(get_tree().create_timer(3), "timeout")
	EventBus.emit_signal("player_won")

