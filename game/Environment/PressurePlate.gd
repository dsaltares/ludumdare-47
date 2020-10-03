extends Spatial

signal pressure_plate_activated
signal pressure_plate_deactivated

# Called when the node enters the scene tree for the first time.
func _ready():
	pass

# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	print(translation)

func _on_Area_body_entered(body):
	$AnimationPlayer.play("Activation")
	emit_signal("pressure_plate_activated")

func _on_Area_body_exited(body):
	$AnimationPlayer.play_backwards("Activation")
	emit_signal("pressure_plate_deactivated")


func _on_pressure_plate_activated():
	pass # Replace with function body.
