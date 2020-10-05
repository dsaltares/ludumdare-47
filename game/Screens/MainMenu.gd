extends Control

func _process(delta: float) -> void:
	if Input.is_action_just_pressed("ui_accept"):
		EventBus.emit_signal("main_menu_done")
