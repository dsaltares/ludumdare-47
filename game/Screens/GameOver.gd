extends ColorRect

func _input(event: InputEvent) -> void:
	if event.is_pressed():
		EventBus.emit_signal("game_over_done")
