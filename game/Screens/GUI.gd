extends MarginContainer

var total_keys = 0 setget set_total_keys
var captured_keys = 0 setget set_captured_keys

func _ready():
	EventBus.connect("loop_timer_updated", self, "update_timer")

func set_total_keys(_total_keys : int) -> void:
	total_keys = _total_keys
	$HBoxContainer/Stats/TotalKeys.text = str(total_keys)

func set_captured_keys(_captured_keys : int) -> void:
	captured_keys = _captured_keys
	$HBoxContainer/Stats/CapturedKeys.text = str(captured_keys)

func update_timer(time_left):
	$HBoxContainer/Timer/TimeLeft.text = str(floor(time_left))

