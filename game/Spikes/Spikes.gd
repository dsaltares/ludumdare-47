extends Spatial
class_name Spikes

export var start_idle := false
export var idle_duration := 2.0

onready var tween := $Tween
onready var moving_parts := $MovingParts

var hide_offset = Vector3.DOWN * 1.0
var time := 0.5

func _ready() -> void:
	init_tween()

func init_tween() -> void:
	tween.interpolate_property(
		moving_parts,
		"translation",
		moving_parts.translation,
		moving_parts.translation + hide_offset,
		time,
		Tween.TRANS_QUINT,
		Tween.EASE_IN,
		idle_duration
	)
	tween.interpolate_property(
		moving_parts,
		"translation",
		moving_parts.translation + hide_offset,
		moving_parts.translation,
		time,
		Tween.TRANS_QUINT,
		Tween.EASE_IN_OUT,
		idle_duration * 2 + time
	)
	if !start_idle:
		tween.start()
	else:
		$Timer.connect("timeout", tween, "start")
		$Timer.start()


func _on_Area_body_entered(body: Node) -> void:
	if body.has_method("kill"):
		body.kill()
