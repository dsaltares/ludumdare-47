extends KinematicBody
class_name Ghost

const GRAVITY = -10.0
const ENVIRONMENT_LAYER = 1
const GHOSTS_LAYER = 4

var recording := Recording
var current_frame := 0
var velocity := Vector3.ZERO
var snap_vec := Vector3.ZERO

func init(_recording) -> void:
	recording = _recording
	global_transform = recording.transforms[0]
	
func _physics_process(delta: float) -> void:
	if current_frame < recording.transforms.size():
		var transform : Transform = recording.transforms[current_frame]
		global_transform = transform
		current_frame += 1
		return
		
	collision_mask = ENVIRONMENT_LAYER + GHOSTS_LAYER
		
	if is_on_floor():
		velocity.y = -0.1
		snap_vec = Vector3.DOWN
	else:
		velocity.y += GRAVITY * delta
		snap_vec = Vector3.ZERO
		
	velocity = move_and_slide_with_snap(velocity, snap_vec, Vector3.UP)
	
