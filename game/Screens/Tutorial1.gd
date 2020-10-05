extends Label

var showing := false

func _on_timeout():
	showing = false
	hide()

func _on_first_button_pressed(body : KinematicBody):
	if !showing and body.get_groups()[0] == "player":
		show()
		showing = true
		$Timer.start()
