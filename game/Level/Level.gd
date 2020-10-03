extends Spatial
class_name Level

onready var player := $Player
onready var ghost_container := $Ghosts

func _ready() -> void:
	GhostManager.set_player(player)
	var ghosts = GhostManager.instance_ghosts()
	for ghost in ghosts:
		ghost_container.add_child(ghost)
		
