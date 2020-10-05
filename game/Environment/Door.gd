extends StaticBody


func _on_pressure_plate_activated():
	$AnimationPlayer.play("Open")

func _on_pressure_plate_deactivated():
	$AnimationPlayer.play("Close")
