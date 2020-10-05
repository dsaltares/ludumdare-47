extends Spatial

export var shooting_rate := 2.0

onready var BulletScene := preload("res://LaserTurret/Bullet.tscn")
onready var shoot_timer := $ShootTimer
onready var shooting_position := $Graphics/ShootingPosition
onready var laser_sfx := $LaserSFX

func _ready() -> void:
	shoot_timer.set("wait_time", shooting_rate)
	shoot_timer.connect("timeout", self, "shoot")
	shoot_timer.start()
	
func shoot() -> void:
	var bullet = BulletScene.instance()
	bullet.bodies_to_ignore.append(self)
	add_child(bullet)
	bullet.global_transform.origin = shooting_position.global_transform.origin
	laser_sfx.play()
