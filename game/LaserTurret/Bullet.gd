extends Area
class_name Bullet

export var speed := 15.0

onready var BulletHitEffectScene := preload("res://LaserTurret/BulletHitEffect.tscn")

var bodies_to_ignore = []

func _physics_process(delta: float) -> void:
	global_transform.origin += get_global_transform().basis.x * speed * delta

func _on_Bullet_body_entered(body: Node) -> void:
	if body in bodies_to_ignore:
		return 
	
	if body.has_method("kill"):
		body.kill()
		
	var hit_effect = BulletHitEffectScene.instance()
	hit_effect.global_transform = global_transform
	get_tree().root.add_child(hit_effect)
		
	queue_free()
