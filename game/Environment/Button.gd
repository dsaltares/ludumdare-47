extends Spatial

signal pressure_plate_activated
signal pressure_plate_deactivated

var body_count := 0

# Called when the node enters the scene tree for the first time.
func _ready():
	pass

# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	print(translation)

func _on_Area_body_entered(body):
	body_count += 1
	
	if body_count == 1:
		$AnimationPlayer.play("Activation")
		emit_signal("pressure_plate_activated", body)

func _on_Area_body_exited(body):
	body_count -= 1
	
	if body_count == 0:
		$AnimationPlayer.play_backwards("Activation")
		emit_signal("pressure_plate_deactivated", body)
