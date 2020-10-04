extends Area

const SPEED = 15.0

var bodies_to_ignore = []

func _physics_process(delta: float) -> void:
	global_transform.origin += get_global_transform().basis.x * SPEED * delta

func _on_Bullet_body_entered(body: Node) -> void:
	if body in bodies_to_ignore:
		return 
		
	if body.has_method("kill"):
		body.kill()
		
	queue_free()
