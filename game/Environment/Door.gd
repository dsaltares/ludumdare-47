extends StaticBody


func _on_pressure_plate_activated(body):
	$AnimationPlayer.play("Open")

func _on_pressure_plate_deactivated(body):
	$AnimationPlayer.play("Close")
