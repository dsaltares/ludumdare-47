extends MarginContainer

const ALERT_COLOR = Color("920000")
const NORMAL_COLOR = Color(1, 1, 1, 1)

onready var TotalKeys := $HBoxContainer/Stats/TotalKeys
onready var CapturedKeys := $HBoxContainer/Stats/CapturedKeys
onready var TimeLeft := $HBoxContainer/Timer/TimeLeft
onready var FlashTimer := $FlashTimer
onready var TickPlayer := $TickPlayer
onready var Buzzer := $Buzzer

var total_keys = 0 setget set_total_keys
var captured_keys = 0 setget set_captured_keys
var flashing := false

func _ready():
	EventBus.connect("loop_timer_updated", self, "update_timer")

func set_total_keys(_total_keys : int) -> void:
	total_keys = _total_keys
	TotalKeys.text = str(total_keys)

func set_captured_keys(_captured_keys : int) -> void:
	captured_keys = _captured_keys
	CapturedKeys.text = str(captured_keys)

func update_timer(time_left):
	TimeLeft.text = str(ceil(time_left))
	
	if time_left > 5:
		flashing = false
		TimeLeft.add_color_override("font_color", NORMAL_COLOR)
	elif !flashing:
		flash_and_tick()
		
		
func flash_and_tick():
	flashing = true
	for seconds in range(1, 6):
		TimeLeft.add_color_override("font_color", ALERT_COLOR)
		TickPlayer.play()
	
		FlashTimer.start()
		yield(FlashTimer, "timeout")
		
		TimeLeft.add_color_override("font_color", NORMAL_COLOR)
		
		FlashTimer.start()
		yield(FlashTimer, "timeout")
		
		TimeLeft.add_color_override("font_color", ALERT_COLOR)
