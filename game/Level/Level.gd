extends Spatial
class_name Level

signal player_looped

onready var player := $Player
onready var ghost_container := $Ghosts
onready var exit_trigger := $ExitTrigger

func _ready() -> void:
	GhostManager.set_player(player)
	var ghosts = GhostManager.instance_ghosts()
	for ghost in ghosts:
		ghost_container.add_child(ghost)
		
	exit_trigger.connect("player_entered", self, "on_player_entered")
	exit_trigger.connect("ghost_entered", self, "on_ghost_entered")

func on_player_entered() -> void:
	emit_signal("player_looped")

func on_ghost_entered(ghost : Node) -> void:
	ghost.queue_free()
