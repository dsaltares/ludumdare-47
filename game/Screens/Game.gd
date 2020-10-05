extends Spatial
class_name Game

onready var LevelScene := preload("res://Level/Level.tscn")
onready var level := $Level
onready var camera := $Camera

func _ready() -> void:
	camera.set_target(level.player)
	GhostManager.start_recording()
	connect_level_signals()
	EventBus.connect("player_kill_started", GhostManager, "pause_recording")
	EventBus.connect("player_dissolve_started", GhostManager, "pause_recording")
	EventBus.connect("player_entered_exit_portal", self, "on_player_entered_exit_portal")
	EventBus.connect("player_killed", self, "on_player_killed")
	EventBus.connect("player_dissolved", self, "new_run")
	
func _process(delta: float) -> void:
	if Input.is_action_just_pressed("quit"):
		get_tree().quit()
		
	if Input.is_action_just_pressed("restart"):
		GhostManager.clear_runs()
		var _ret = get_tree().reload_current_scene()
		
	if Input.is_action_just_pressed("new_run"):
		level.dissolve_player()
		
	if Input.is_action_just_pressed("shake"):
		EventBus.emit_signal("shake_requested")

func on_level_ready() -> void:
	camera.set_target(level.player)
	GhostManager.start_recording()
	
func on_player_killed() -> void:
	var player_killed = true
	new_run(player_killed)

func new_run(player_killed := false) -> void:
	GhostManager.stop_recording(player_killed)
	level.queue_free()
	level = LevelScene.instance()
	connect_level_signals()
	add_child(level)

func connect_level_signals() -> void:
	level.connect("ready", self, "on_level_ready")
	level.connect("player_looped", self, "new_run")
	level.connect("loop_timeout", self, "new_run")

func on_player_entered_exit_portal() -> void:
	print("EXIT PORTAL")