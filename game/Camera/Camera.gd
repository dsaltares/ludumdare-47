extends Camera

export var min_distance := 10.0
export var max_distance := 12.0
export var max_distance_speed := 20.0
export var height := 2.0

var target : Spatial
var prev_target_pos := Vector3.ZERO

func set_target(_target : Spatial) -> void:
	target = _target
	if target:
		prev_target_pos = target.global_transform.origin

func _physics_process(delta: float) -> void:
	if not target:
		return
		
	var target_pos = target.global_transform.origin
	var target_speed = (target_pos - prev_target_pos).length() / delta
	var weight = clamp(target_speed / max_distance_speed, 0.0, 1.0)
	var distance = lerp(min_distance, max_distance, weight)
	var camera_target_pos = Vector3(
		target_pos.x,
		target_pos.y + height,
		target_pos.z + distance
	)
	translation = translation.linear_interpolate(camera_target_pos, 0.075)
	prev_target_pos = target_pos
