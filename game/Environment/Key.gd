extends Spatial


func _on_body_entered(body):
	EventBus.emit_signal("key_obtained")
	queue_free()
