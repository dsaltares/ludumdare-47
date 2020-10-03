extends Spatial
class_name Game

onready var LevelScene := preload("res://Level/Level.tscn")
onready var level := $Level
onready var camera := $Camera

func _ready() -> void:
	camera.set_target(level.player)
	GhostManager.start_recording()

func _process(delta: float) -> void:
	if Input.is_action_just_pressed("quit"):
		get_tree().quit()
		
	if Input.is_action_just_pressed("restart"):
		GhostManager.clear_runs()
		var _ret = get_tree().reload_current_scene()
		
	if Input.is_action_just_pressed("new_run"):
		GhostManager.stop_recording()
		level.queue_free()
		level = LevelScene.instance()
		level.connect("ready", self, "on_level_ready")
		add_child(level)

func on_level_ready() -> void:
	camera.set_target(level.player)
	GhostManager.start_recording()
