extends Spatial

onready var light_left := $Graphics/PillarLeft/LightLeft
onready var light_right := $Graphics/PillarRight/LightRight
onready var back := $Graphics/Back
onready var right_light_tween := $RightLightTween
onready var left_light_tween := $LeftLightTween

const NUM_REQUIRED_KEYS := 1
const OPEN_COLOR := Color.greenyellow
const CLOSED_COLOR := Color.red
const TWEEN_DURATION := 0.5

func _ready() -> void:
	lights_off()
	
func lights_on() -> void:
	right_light_tween.interpolate_property(
		light_right,
		"light_energy",
		0.0,
		1.0,
		TWEEN_DURATION,
		Tween.TRANS_QUAD,
		Tween.EASE_IN_OUT
	)
	right_light_tween.start()
	left_light_tween.interpolate_property(
		light_left,
		"light_energy",
		0.0,
		1.0,
		TWEEN_DURATION,
		Tween.TRANS_QUAD,
		Tween.EASE_IN_OUT
	)
	left_light_tween.start()
	
func lights_off() -> void:
	right_light_tween.interpolate_property(
		light_right,
		"light_energy",
		1.0,
		0.0,
		TWEEN_DURATION,
		Tween.TRANS_QUAD,
		Tween.EASE_IN_OUT
	)
	right_light_tween.start()
	left_light_tween.interpolate_property(
		light_left,
		"light_energy",
		1.0,
		0.0,
		TWEEN_DURATION,
		Tween.TRANS_QUAD,
		Tween.EASE_IN_OUT
	)
	left_light_tween.start()


func _on_PlayerInteractArea_body_entered(body: Node) -> void:
	if not (body is Player):
		return
	
	var player = body as Player
	var has_all_keys = player.num_keys == NUM_REQUIRED_KEYS
	if has_all_keys:
		EventBus.emit_signal("player_entered_exit_portal")


func _on_PlayerApproachArea_body_entered(body: Node) -> void:
	lights_on()
	
	if not (body is Player):
		return
	
	var player = body as Player
	var has_all_keys = player.num_keys == NUM_REQUIRED_KEYS
	var color = OPEN_COLOR if has_all_keys else CLOSED_COLOR
	light_left.light_color = color
	light_right.light_color = color
	back.visible = not has_all_keys


func _on_PlayerApproachArea_body_exited(body: Node) -> void:
	lights_off()
	back.visible = true
