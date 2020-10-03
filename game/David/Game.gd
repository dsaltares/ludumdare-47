extends Spatial
class_name Game

onready var LevelScene := preload("res://Level/Level.tscn")
onready var level := $Level
onready var camera := $Camera

func _ready() -> void:
	camera.set_target(level.player)
	GhostManager.start_recording()
	connect_level_signals()

func _process(delta: float) -> void:
	if Input.is_action_just_pressed("quit"):
		get_tree().quit()
		
	if Input.is_action_just_pressed("restart"):
		GhostManager.clear_runs()
		var _ret = get_tree().reload_current_scene()
		
	if Input.is_action_just_pressed("new_run"):
		new_run()

func on_level_ready() -> void:
	camera.set_target(level.player)
	GhostManager.start_recording()

func new_run() -> void:
	GhostManager.stop_recording()
	level.queue_free()
	level = LevelScene.instance()
	connect_level_signals()
	add_child(level)

func connect_level_signals() -> void:
	level.connect("ready", self, "on_level_ready")
	level.connect("player_looped", self, "new_run")
