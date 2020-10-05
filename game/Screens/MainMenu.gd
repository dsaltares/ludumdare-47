extends Spatial

enum ControlType {
	PC,
	PS4,
	XBOX,
}

onready var ps4_controls := $CanvasLayer/Controls/Pivot/PS4
onready var xbox_controls := $CanvasLayer/Controls/Pivot/Xbox
onready var pc_controls := $CanvasLayer/Controls/Pivot/PC
onready var animation_player := $AnimationPlayer

func _ready() -> void:
	_show_correct_controls()
	animation_player.play("intro")
	yield(animation_player, "animation_finished")
	animation_player.play("loop")

func _input(event: InputEvent) -> void:
	if event.is_pressed():
		EventBus.emit_signal("main_menu_done")

func _show_correct_controls() -> void:
	var control_type = _get_control_type()
	pc_controls.visible = control_type == ControlType.PC
	ps4_controls.visible = control_type == ControlType.PS4
	xbox_controls.visible = control_type == ControlType.XBOX
	
func _get_control_type():
	var has_joypad := Input.get_connected_joypads().size() > 0
	if not has_joypad:
		return ControlType.PC
	var joypad_name = Input.get_joy_name(0).to_lower()
	var names = [
		"dualshock",
		"ps4",
		"sony",
		"playstation"
	]
	for name in names:
		if joypad_name.find(name) != -1:
			return ControlType.PS4
	return ControlType.XBOX
