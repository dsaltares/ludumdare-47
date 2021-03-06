extends Spatial
class_name Level

signal player_looped
signal loop_timeout

const TOTAL_KEYS := 3

onready var player := $Player
onready var ghost_container := $Ghosts
onready var loop_timer := $LoopTimer

func _ready() -> void:
	EventBus.connect("player_entered_exit_portal", self, "on_player_entered_exit_portal")
	GhostManager.set_player(player)
	var ghosts = GhostManager.instance_ghosts()
	for ghost in ghosts:
		ghost_container.add_child(ghost)
	

func _process(delta: float) -> void:
	EventBus.emit_signal("loop_timer_updated", loop_timer.time_left)

func on_player_entered() -> void:
	emit_signal("player_looped")

func on_ghost_entered(ghost : Node) -> void:
	ghost.queue_free()
	
func on_loop_timer_timeout() -> void:
	player.kill()

func dissolve_player() -> void:
	player.dissolve()

func on_player_entered_exit_portal() -> void:
	loop_timer.paused = true
