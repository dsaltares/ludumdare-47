extends MarginContainer


# Declare member variables here. Examples:
# var a = 2
# var b = "text"


# Called when the node enters the scene tree for the first time.
func _ready():
	update_timer()
	EventBus.connect("key_obtained", self, "update_counter")
	yield(get_parent(), "ready")
	$HBoxContainer/Stats/TotalKeys.text = str(get_parent().total_keys)

func _process(delta):
	update_timer()

func update_counter():
	$HBoxContainer/Stats/CapturedKeys.text = str(get_parent().captured_keys)
	
func update_timer():
	var loop_timer = get_parent().get_node("Level/LoopTimer")
	
	if loop_timer:
		$HBoxContainer/Timer/TimeLeft.text = str(floor(loop_timer.time_left))
