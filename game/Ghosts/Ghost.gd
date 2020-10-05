extends KinematicBody
class_name Ghost

enum States {
	START,
	PLAYING_RECORDING,
	IDLE,
	DISSOLVING,
}

const GRAVITY = -10.0

const ENVIRONMENT_LAYER = 1
const PLAYER_LAYER = 2
const GHOSTS_LAYER = 4

onready var become_solid_timer := $BecomeSolidTimer
onready var dissolve_timer := $DissolveTimer
onready var mesh := $Body
onready var tween := $Tween

var state = States.START
var recording := Recording
var current_frame := 0
var velocity := Vector3.ZERO
var snap_vec := Vector3.ZERO

func _ready() -> void:
	collision_layer = 0
	collision_mask = ENVIRONMENT_LAYER
	mesh.set_surface_material(0, mesh.get_surface_material(0).duplicate())

func init(_recording) -> void:
	recording = _recording
	global_transform = recording.transforms[0]

func _process(_delta: float) -> void:
	_update_dissolve_amount()

func _physics_process(delta: float) -> void:
	if state == States.START or state == States.PLAYING_RECORDING:
		var transform : Transform = recording.transforms[current_frame]
		global_transform = transform
		current_frame += 1
		if current_frame >= recording.transforms.size():
			state = States.IDLE
			tween.interpolate_property(
				mesh.get_surface_material(0),
				"shader_param/alpha",
				0.75, 1.0,
				0.5,
				Tween.TRANS_CUBIC,
				Tween.EASE_IN_OUT
			)
			tween.start()
		return

	if state == States.IDLE:
		if recording.killed_at_end:
			dissolve()
			return
			
		collision_layer = GHOSTS_LAYER
		collision_mask = ENVIRONMENT_LAYER + PLAYER_LAYER + GHOSTS_LAYER

		if is_on_floor():
			velocity.y = -0.1
			snap_vec = Vector3.DOWN
		else:
			velocity.y += GRAVITY * delta
			snap_vec = Vector3.ZERO

		velocity = move_and_slide_with_snap(velocity, snap_vec, Vector3.UP)
		transform.origin.z = 0

func dissolve() -> void:
	state = States.DISSOLVING
	dissolve_timer.start()
	collision_layer = 0
	collision_mask = 0

func _on_BecomeSolidTimer_timeout() -> void:
	if state == States.START:
		state = States.PLAYING_RECORDING

func _update_dissolve_amount() -> void:
	var amount = 0.0
	
	if state == States.START:
		amount = become_solid_timer.time_left / become_solid_timer.wait_time
	elif state == States.DISSOLVING:
		amount = 1.0 - dissolve_timer.time_left / dissolve_timer.wait_time
		
	mesh.get_surface_material(0).set_shader_param("dissolve_amount", amount)
