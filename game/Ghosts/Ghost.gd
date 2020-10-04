extends KinematicBody
class_name Ghost

enum States {
	START,
	PLAYING_RECORDING,
	IDLE
}

const GRAVITY = -10.0

const ENVIRONMENT_LAYER = 1
const PLAYER_LAYER = 2
const GHOSTS_LAYER = 4

onready var become_solid_timer := $BecomeSolidTimer
onready var mesh := $Body

var state = States.START
var recording := Recording
var current_frame := 0
var velocity := Vector3.ZERO
var snap_vec := Vector3.ZERO

func _ready() -> void:
	collision_layer = 0
	collision_mask = ENVIRONMENT_LAYER

func init(_recording) -> void:
	recording = _recording
	global_transform = recording.transforms[0]

func _process(_delta: float) -> void:
	if state != States.START:
		return

	var amount = 1.0 - become_solid_timer.time_left / become_solid_timer.wait_time
	mesh.get_surface_material(0).set_shader_param("amount", amount)


func _physics_process(delta: float) -> void:
	if  state != States.IDLE:
		var transform : Transform = recording.transforms[current_frame]
		global_transform = transform
		current_frame += 1
		if current_frame >= recording.transforms.size():
			state = States.IDLE
		return

	if state == States.IDLE:
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

func _on_BecomeSolidTimer_timeout() -> void:
	if state == States.START:
		state = States.PLAYING_RECORDING
		collision_layer = GHOSTS_LAYER
		collision_mask = ENVIRONMENT_LAYER + PLAYER_LAYER
