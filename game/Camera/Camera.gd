extends Camera

const TRANS := Tween.TRANS_SINE
const EASE := Tween.EASE_IN_OUT

export var min_distance := 48.0
export var max_distance := 52.0
export var max_distance_speed := 20.0
export var height := 2.0
export var camera_distance := 50
export var max_yaw_shake := 3
export var max_pitch_shake := 3
export var max_roll_shake := 3

onready var shake_tween := $Shake
onready var frequency_timer := $Frequency
onready var duration_timer := $Duration

var amplitude := 0.0
var target : KinematicBody
var prev_target_pos := Vector3.ZERO
var prev_y := 0

func set_target(_target : KinematicBody) -> void:
	target = _target
	if target:
		prev_target_pos = target.global_transform.origin

func _ready() -> void:
	EventBus.connect("shake_requested", self, "_on_shake_requested")
	frequency_timer.connect("timeout", self, "_on_Frequency_timeout")
	duration_timer.connect("timeout", self, "_on_Duration_timeout")

func _physics_process(delta: float) -> void:
	if not target:
		return
		
	var target_pos = target.global_transform.origin
	var target_speed = (target_pos - prev_target_pos).length() / delta
	var weight = clamp(target_speed / max_distance_speed, 0.0, 1.0)
	var distance = lerp(min_distance, max_distance, weight)
	var pos_y = floor(1 + target_pos.y / 10) * 10 if target.is_on_floor() else prev_y 
	var camera_target_pos = Vector3(
		clamp(target_pos.x, -26, 26),
		pos_y,
		target_pos.z + distance
	)
	translation = translation.linear_interpolate(camera_target_pos, 0.075)
	prev_target_pos = target_pos
	prev_y = pos_y

func _on_shake_requested(duration := 0.2, amplitude := 1.0, frequency := 50) -> void:
	_start_shake(duration, amplitude, frequency)
	
func _on_Frequency_timeout() -> void:
	_new_shake()
	
func _on_Duration_timeout() -> void:
	_reset()
	frequency_timer.stop()
	
func _start_shake(duration, amplitude, frequency) -> void:
	self.amplitude = amplitude
	duration_timer.wait_time = duration
	frequency_timer.wait_time = 1 / float(frequency)
	duration_timer.start()
	frequency_timer.start()
	_new_shake()
	
func _new_shake() -> void:
	var half_amplitude := amplitude / 2.0
	var max_pitch = deg2rad(max_pitch_shake)
	var max_yaw = deg2rad(max_pitch_shake)
	var max_roll = deg2rad(max_roll_shake)
	var random_shake := Vector3(
		rand_range(-half_amplitude * max_pitch, half_amplitude * max_pitch),
		rand_range(-half_amplitude * max_yaw, half_amplitude * max_yaw),
		rand_range(-half_amplitude * max_roll, half_amplitude * max_roll)
	)
	shake_tween.interpolate_property(
		self,
		"rotation",
		self.rotation,
		random_shake,
		frequency_timer.wait_time,
		TRANS,
		EASE
	)
	shake_tween.start()
	
func _reset() -> void:
	shake_tween.interpolate_property(
		self,
		"rotation",
		self.rotation,
		Vector3.ZERO,
		frequency_timer.wait_time,
		TRANS,
		EASE
	)
	shake_tween.start()
