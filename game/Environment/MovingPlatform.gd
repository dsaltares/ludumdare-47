extends KinematicBody

export var idle_duration := 1.0
export var move_to := Vector3.RIGHT * 3
export var time := 2.0
export var connected_to_button = false

onready var tween := $Tween

var follow := Vector3.ZERO

func _ready() -> void:
	follow = translation
	init_tween()

func init_tween() -> void:
	tween.interpolate_property(
		self,
		"follow",
		translation,
		translation + move_to,
		time,
		Tween.TRANS_LINEAR,
		Tween.EASE_IN_OUT,
		idle_duration
	)
	tween.interpolate_property(
		self,
		"follow",
		translation + move_to,
		translation,
		time,
		Tween.TRANS_LINEAR,
		Tween.EASE_IN_OUT,
		idle_duration + time
	)
	
	if !connected_to_button:
		tween.start()
	
func _physics_process(delta: float) -> void:
	translation = translation.linear_interpolate(follow, 0.075)

func _on_pressure_plate_activated(body : KinematicBody):
	tween.resume_all()

func _on_pressure_plate_deactivated(body : KinematicBody):
	tween.stop_all()
