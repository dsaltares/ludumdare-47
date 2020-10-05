extends Label

onready var ps4_controls := $PS4
onready var xbox_controls := $Xbox
onready var pc_controls := $PC

var showing := false

enum ControlType {
	PC,
	PS4,
	XBOX,
}

func _ready():
	var control_type = _get_control_type()
	pc_controls.visible = control_type == ControlType.PC
	ps4_controls.visible = control_type == ControlType.PS4
	xbox_controls.visible = control_type == ControlType.XBOX

func _on_timeout():
	showing = false
	hide()

func _on_first_button_pressed(body : KinematicBody):
	if !showing and body.is_in_group("player"):
		show()
		showing = true
		$Timer.start()

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
