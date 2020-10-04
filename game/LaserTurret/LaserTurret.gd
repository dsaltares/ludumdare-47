extends Spatial

onready var BulletScene := preload("res://LaserTurret/Bullet.tscn")
onready var shoot_timer := $ShootTimer
onready var shooting_position := $Graphics/ShootingPosition
onready var laser_sfx := $LaserSFX

func _ready() -> void:
	shoot_timer.connect("timeout", self, "shoot")
	
func shoot() -> void:
	var bullet = BulletScene.instance()
	bullet.bodies_to_ignore.append(self)
	bullet.global_transform.origin = shooting_position.translation
	add_child(bullet)
	laser_sfx.play()
