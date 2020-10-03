extends Spatial

onready var Ghost = preload("res://Ghosts/Ghost.tscn")

export var player_path : NodePath
export var recording_rate := 1
export var max_ghosts := 5 

var player : Player
var player_recording := Recording.new()
var ghost_recordings := []
var recording := false

func set_player(_player: Player) -> void:
	player = _player
	
func clear_runs() -> void:
	player_recording = Recording.new()
	ghost_recordings = []
	
func start_recording() -> void:
	recording = true
	
func stop_recording() -> void:
	ghost_recordings.append(player_recording)
	player_recording = Recording.new()
	recording = false
	
func instance_ghosts() -> Array:
	var ghosts = []
	for recording in ghost_recordings:
		var ghost = Ghost.instance()
		ghost.init(recording)
		ghosts.append(ghost)
	return ghosts
	
func _physics_process(delta: float) -> void:
	if not recording:
		return
	player_recording.record(player.global_transform)
