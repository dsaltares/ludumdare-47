extends Spatial

onready var BulletScene := preload("res://LaserTurret/Bullet.tscn")
onready var shoot_timer := $ShootTimer
onready var shooting_position := $Graphics/ShootingPosition

func _ready() -> void:
	shoot_timer.connect("timeout", self, "shoot")
	
func shoot() -> void:
	var bullet = BulletScene.instance()
	bullet.bodies_to_ignore.append(self)
	print("shooting from: ", shooting_position.global_transform.origin)
	print("shooting ti: ", shooting_position.global_transform.basis.x)
	bullet.global_transform.origin = shooting_position.translation
#	bullet.global_transform.basis = shooting_position.global_transform.basis
	add_child(bullet)
