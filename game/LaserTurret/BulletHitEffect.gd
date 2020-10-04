extends Spatial
class_name BulletHitEffect

onready var env_hit_sfx := $EnvHitSFX

func _ready() -> void:
	env_hit_sfx.connect("finished", self, "queue_free")
	env_hit_sfx.play()
