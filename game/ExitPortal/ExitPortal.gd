extends Spatial

onready var light_left := $Graphics/PillarLeft/LightLeft
onready var light_right := $Graphics/PillarRight/LightRight
onready var back := $Graphics/Back
onready var right_light_tween := $RightLightTween
onready var left_light_tween := $LeftLightTween
onready var player_interact_area := $PlayerInteractArea

const NUM_REQUIRED_KEYS := 1
const OPEN_COLOR := Color.greenyellow
const CLOSED_COLOR := Color.red
const TWEEN_DURATION := 0.5

var interacted = false

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
	
func _process(delta: float) -> void:
	_update_graphics()

func _physics_process(delta: float) -> void:
	if interacted:
		return 
		
	var player_in_portal = player_interact_area.get_overlapping_bodies().size() != 0
	var has_keys = has_all_keys()
	if player_in_portal and has_keys:
		interacted = true
		EventBus.emit_signal("player_entered_exit_portal")


func _on_PlayerApproachArea_body_entered(body: Node) -> void:
	lights_on()

func _on_PlayerApproachArea_body_exited(body: Node) -> void:
	lights_off()
	back.visible = true

func has_all_keys() -> bool:
	return get_tree().get_nodes_in_group("keys").size() == 0

func _update_graphics() -> void:
	var all_keys = has_all_keys()
	var color = OPEN_COLOR if all_keys else CLOSED_COLOR
	light_left.light_color = color
	light_right.light_color = color
	back.visible = not all_keys
