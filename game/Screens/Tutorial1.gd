extends Label

var showing := false

func _on_timeout():
	showing = false
	hide()

func _on_first_button_pressed(body : KinematicBody):
	if !showing and body.is_in_group("player"):
		show()
		showing = true
		$Timer.start()
